global class DataPurgeJobBatch implements Database.Batchable<sObject>, Database.Stateful{
   private final String Query;
   private Data_Purge_Job__c dpj;
   private Boolean foundErrors;
   private Integer numRecProcessed;
   

   global DataPurgeJobBatch(String q, Data_Purge_Job__c dpj){
             this.Query = q;
             this.dpj = dpj;
             this.foundErrors = false;
             this.numRecProcessed = 0;
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
   		
   	System.debug('query >---> ' + query);
   	Data_Purge_Job__c dpjToUpd = new Data_Purge_Job__c();
   	dpjToUpd.Id = this.dpj.Id;
   	dpjToUpd.Last_Run_Started__c = Datetime.now();
   	if(this.dpj.Chain_Runs__c && this.dpj.Status__c == 'Queued' && this.dpj.Mode__c == 'On Demand')
   	{
   		dpjToUpd.Last_Chain_Run_Started__c = DateTime.now();
   		dpjToUpd.Last_Chain_Run_Total_Processed_Records__c = 0;
   		this.dpj.Last_Chain_Run_Total_Processed_Records__c = 0;
   	}
   	dpjToUpd.Status__c = 'Processing';
   	dpjToUpd.Last_Run_Number_of_Records_Processed__c = 0;
   	dpjToUpd.Last_Run_Error__c = '';
    update dpjToUpd;
    return Database.getQueryLocator(query);
    
   }

   global void execute(Database.BatchableContext BC,List<sObject> scope)
   {
   	
   	  
   	
   	  try {
   	  	
	   	   if(scope.size() > 0)
	   	   {
	   	   		delete scope;
	   	   		
	   	   		if(this.dpj.Remove_From_Recycle_Bin__c)
	   	   		{
	   	   			 DataBase.emptyRecycleBin(scope);
	   	   		}
	   	   		
	   	   }
	   	   
	   	   this.numRecProcessed += scope.size();
	   	   
	   	   if(this.dpj.Name == 'ERRORBATCH')
	   	   {
	   	   		throw new DataPurgeJobException('Custom Exception');
	   	   }
			
   	  } catch(Exception e) {
   	  	
		this.dpj.Last_Run_Error__c = 'Apex Class: DataPurgeJobBatch.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
		this.foundErrors = true;
   	  		  	
   	  }
   	  
      
   }

   global void finish(Database.BatchableContext BC){
				
		
   		try {
   			
   			Data_Purge_Job__c dpjToUpd = new Data_Purge_Job__c();
   			dpjToUpd.Id = this.dpj.Id;
   			
			if(this.foundErrors)
			{
				dpjToUpd.Last_Run_Error__c = this.dpj.Last_Run_Error__c;
				DeltakSRP__Error_Log__c el = generateErrorLog();
				insert el;
			}
			else
			{
				dpjToUpd.Last_Run_Error__c = '';
			}
			
			dpjToUpd.Last_Run_Number_of_Records_Processed__c = this.numRecProcessed;
			
	   		if(!this.foundErrors && this.dpj.Chain_Runs__c && this.dpj.Mode__c == 'On Demand' && dpjToUpd.Last_Run_Number_of_Records_Processed__c >= this.dpj.Batch_Size__c)
	   		{
	   			dpjToUpd.Status__c = 'Processing';
	   		}
	   		else
	   		{
	   			dpjToUpd.Status__c = 'Ready';
	   		}
	   		
	   		if(this.dpj.Chain_Runs__c && this.dpj.Mode__c == 'On Demand')
	   		{	
	   			if(this.dpj.Last_Chain_Run_Total_Processed_Records__c != null)
	   			{
	   				dpjToUpd.Last_Chain_Run_Total_Processed_Records__c = this.dpj.Last_Chain_Run_Total_Processed_Records__c + dpjToUpd.Last_Run_Number_of_Records_Processed__c;
	   			}
	   			else
	   			{
	   				dpjToUpd.Last_Chain_Run_Total_Processed_Records__c = dpjToUpd.Last_Run_Number_of_Records_Processed__c;
	   			}
	   		}
	   		
	   		if(this.dpj.Chain_Runs__c && dpjToUpd.Status__c == 'Ready' && this.dpj.Mode__c == 'On Demand')
	   		{
	   			dpjToUpd.Last_Chain_Run_Finished__c = DateTime.now();
	   		}
	   		
	   		dpjToUpd.Last_Run_Finished__c = Datetime.now();
	    	update dpjToUpd;
			
			if(this.dpj.Chain_Runs__c && dpjToUpd.Status__c == 'Processing' && this.dpj.Mode__c == 'On Demand')
	   		{
	   			DataPurgeJobSchedule dpjs = new DataPurgeJobSchedule();
	   			dpjs.kickoffBatch(dpjToUpd.Id);
	   		}
	   		
	   		if(this.dpj.Name == 'ERRORBATCHFINISH')
	   	   {
	   	   		throw new DataPurgeJobException('Custom Exception');
	   	   }
	   		
   		} catch(Exception e){
   			Data_Purge_Job__c dpjToUpd = new Data_Purge_Job__c();
   			dpjToUpd.Id = this.dpj.Id;
   			dpjToUpd.Status__c = 'Deactivated';
   			dpjToUpd.Last_Run_Error__c = 'Apex Class: DataPurgeJobBatch.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
   			update dpjToUpd;
   			
   			this.dpj.Last_Run_Error__c = 'Apex Class: DataPurgeJobBatch.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
   			DeltakSRP__Error_Log__c el = generateErrorLog();
			insert el;
   		}
   }
   
   private DeltakSRP__Error_Log__c generateErrorLog()
   {
   		
   		DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
  		el.OwnerId = this.dpj.OwnerId;
  		el.DeltakSRP__Type__c = 'Apex';
  		el.DeltakSRP__Partner_Name__c = 'WLY';
  		String errorDetails = 'Errors have occured for Data Purge Job [' + this.dpj.Name + ']: ' + this.dpj.Last_Run_Error__c;
  		if(errorDetails.length() < 255)
  		{
  			el.DeltakSRP__Detail__c = errorDetails;	
  		}
  		else
  		{
  			el.DeltakSRP__Detail__c = errorDetails.substring(0,250) + '...';
  		}
  		el.DeltakSRP__Source_Name__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.dpj.Id;
  		el.DeltakSRP__External_Id__c = this.dpj.Name + ' : ' + DateTime.now() + DateTime.now().millisecond();
  		el.DeltakSRP__Object__c = 'Data Purge Job';
	      		
	    return el;
	    
   }
   
   global class DataPurgeJobException extends Exception { }

}