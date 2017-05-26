global class II_UTCourseEnrollmentBatchProcess implements Database.Batchable<sObject>, Database.Stateful{
   private final String Query;
   private final Integration_Interface__c ii;
   private List<Integration_Transaction__c> itErrorList;
   private Integer batchNumber ;
   private String batchErrorString ;
   private Boolean iiError;

   global II_UTCourseEnrollmentBatchProcess(String q, Integration_Interface__c ii){
             this.Query = q;
             this.ii = ii;
             this.itErrorList = new List<Integration_Transaction__c>();
             this.batchNumber = 0;
             this.iiError = false;
             this.batchErrorString = '';
            
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
   		
   	System.debug('query >---> ' + query);
   	this.ii.Last_Run_Started__c = Datetime.now();
   	this.ii.Number_of_Records_processed_On_Last_Run__c = 0;
   	this.ii.Status__c = 'Processing';
    update this.ii;
    return Database.getQueryLocator(query);
    
   }

   global void execute(Database.BatchableContext BC,List<sObject> scope)
   {
   	
   	  Savepoint sp = Database.setSavepoint();
   	
   	  try {
   	  	
	   	  this.batchNumber++;
	      
	      
	      List<Integration_Transaction__c> itList = new List<Integration_Transaction__c>();
	     
	      for(Sobject s : scope)
	      {
	      	
	      	Integration_Transaction__c it = (Integration_Transaction__c) s;
	      	
	      	if(it.Processing_Status__c == 'Queued')
			{
				itList.add(it);
			}
			
	      }	
	      
	      this.ii.Number_of_Records_processed_On_Last_Run__c += itList.size();
	      
	      	System.debug('itQueuedList >---> ' + itList);
	      	
	      	itList = II_ProcessUTCourseEnrollments.processIntegrationTransactions(this.ii, itList);
	      	
			Integer countErrors = 0;
				
			for(Integration_Transaction__c it : itList)
			{
				if(it.Processing_Status__c == 'Errored')
				{
					countErrors++;
					this.itErrorList.add(it);
				}
				else
				{
					it.Processing_Status__c = 'Completed';
					it.Last_Error__c = '';
				}
			}
			
			
			if(this.ii.Error_Log_Per__c == 'Batch' && countErrors > 0)
			{
				DeltakSRP__Error_Log__c el = generateErrorLog(countErrors);
				
				insert el;
				
				for(Integration_Transaction__c it : itList)
				{
					if(it.Processing_Status__c == 'Errored')
					{
						it.Latest_Error_Log__c = el.Id;
					}
					else
					{
						it.Latest_Error_Log__c = null;
					}
				}
			}
			
			update itList;
			
			if(this.ii.Raw_Header__c == null && System.Test.isRunningTest())
			{
				throw new II_ProcessUTCourseEnrollments.itDataException('Raw Header is invalid.');
			}
			
   	  } catch(Exception e) {
   	  	
   	  	Database.rollback( sp );
   	  	this.iiError = true;
   	  	this.batchErrorString += 'Batch #' + this.batchNumber + ' \r\nApex Class: II_UTCourseEnrollmentBatchProcess.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e + '\r\n\r\n';
   	  	   	  	
   	  }
   	  
      
   }

   global void finish(Database.BatchableContext BC){
		
		system.debug('Error_Log_Per__c >---> ' + this.ii.Error_Log_Per__c);
		
		if(this.ii.Error_Log_Per__c == 'Run' && !this.iiError)
		{
			
			List<Integration_Transaction__c> itTotalErrorList = [SELECT Id, Latest_Error_Log__c FROM Integration_Transaction__c WHERE 
					Integration_Interface__c = :this.ii.Id AND Processing_Status__c = 'Errored'];
			
			system.debug('Include_Old_Errors__c >---> ' + this.ii.Include_Old_Errors__c);
			system.debug('itTotalErrorList.size() >---> ' + itTotalErrorList.size());
			system.debug('itErrorList.size() >---> ' + this.itErrorList.size());
			
			if(this.ii.Include_Old_Errors__c == 'YES' && itTotalErrorList.size() > 0)
			{
				
				DeltakSRP__Error_Log__c el = generateErrorLog(itTotalErrorList.size());
				insert el;
				
				for(Integration_Transaction__c it : itTotalErrorList)
				{
					it.Latest_Error_Log__c = el.Id;
				}
				
				update itTotalErrorList;
				
			}
			else if(this.itErrorList.size() > 0)
			{
				
				DeltakSRP__Error_Log__c el = generateErrorLog(this.itErrorList.size());
				insert el;
				
				for(Integration_Transaction__c it : this.itErrorList)
				{
					it.Latest_Error_Log__c = el.Id;
				}
				
				update this.itErrorList;
				
			}
		}
		
		if(this.iiError)
		{
			
			if(this.batchErrorString.length() < 1000)
			{
				this.ii.Last_Error__c = this.batchErrorString;
			}
			else
			{
				this.ii.Last_Error__c = this.batchErrorString.substring(0,995) + '...';
			}
			
			DeltakSRP__Error_Log__c el = generateErrorLog(1);
			el.DeltakSRP__Detail__c = 'An Interface level exception has occured for Integration Interface: ' + this.ii.Interface_Identifier__c 
			+ '. Please review Integration Interface details.';
			insert el;
			
		}
		else
		{
			this.ii.Last_Error__c = '';
		}
		
		this.ii.Last_Run_Finished__c = DateTime.now();
		this.ii.Status__c = 'Ready';
		update this.ii;
   }
   
   private DeltakSRP__Error_Log__c generateErrorLog(Integer countErrors)
   {
   		String logType = '';
   		if(this.ii.Error_Log_Per__c != null)
   		{
   			logType = this.ii.Error_Log_Per__c;
   		}
   		
   		DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
  		el.OwnerId = this.ii.OwnerId;
  		el.DeltakSRP__Type__c = 'Apex';
  		el.DeltakSRP__Partner_Name__c = 'UTX';
  		el.DeltakSRP__Detail__c = countErrors + ' errors have occured for Integration Interface ' + logType + ' : ' + this.ii.Interface_Identifier__c;
  		el.DeltakSRP__Source_Name__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.ii.Id;
  		el.DeltakSRP__External_Id__c = this.ii.Interface_Identifier__c + ' : ' + DateTime.now().date() + ':' + DateTime.now().time() + DateTime.now().millisecond();
  		el.DeltakSRP__Object__c = 'Course Enrollment';
	      		
	    return el;
	    
   }

}