global class DataPurgeJobSchedule implements Schedulable {
   
   global void execute(SchedulableContext SC) {
		
		try {
			kickoffBatch(null);
		}catch(Exception e) {
			DeltakSRP__Error_Log__c el = generateErrorLog(e);
			insert el;
		}
		
   }
   
   global void kickoffBatch(Id dpjId)
   {
   		Integer runningBatchJobs = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
   		Integer dpjCount = 0;
   		
   		List<Data_Purge_Job__c> updateDpjBatchIds = new List<Data_Purge_Job__c>();
   		List<Data_Purge_Job__c> updateDpjStatuses = new List<Data_Purge_Job__c>();
   		List<Data_Purge_Job__c> dpjErrored = new List<Data_Purge_Job__c>();
   		
   		if(runningBatchJobs < 5)
   		{
   			List<Data_Purge_Job__c> dpjList = new List<Data_Purge_Job__c>();
   			
   			if(dpjId == null)
   			{
		   		
		   		DateTime dtNow = DateTime.now();
		   		
		   		DateTime dtToday = DateTime.newInstance(dtNow.Year(), dtNow.Month(), dtNow.Day(), 0,0,0);
		   		
		   		List<Data_Purge_Job__c> dpjList1 = [SELECT Id, Name, OwnerId, Object_API_Name__c, Query_Condition__c, Status__c, Last_Run_Started__c, 
		   		Last_Run_Finished__c, Last_Run_Error__c, Last_Run_Batch_Id__c, Query_Limit__c, Batch_Size__c, Last_Run_Number_of_Records_Processed__c,
		   		Mode__c, Remove_From_Recycle_Bin__c, Chain_Runs__c, Email_Per__c, Last_Chain_Run_Started__c, Last_Chain_Run_Finished__c,
		   		Last_Chain_Run_Total_Processed_Records__c   
		   		FROM Data_Purge_Job__c 
		   		WHERE Status__c = 'Ready' AND Mode__c = 'Once Hourly' ORDER BY Last_Run_Started__c DESC NULLS FIRST ];
		   		
		   		List<Data_Purge_Job__c> dpjList2 = [SELECT Id, Name, OwnerId, Object_API_Name__c, Query_Condition__c, Status__c, Last_Run_Started__c, 
		   		Last_Run_Finished__c, Last_Run_Error__c, Last_Run_Batch_Id__c, Query_Limit__c, Batch_Size__c, Last_Run_Number_of_Records_Processed__c,
		   		Mode__c, Remove_From_Recycle_Bin__c, Chain_Runs__c, Email_Per__c, Last_Chain_Run_Started__c, Last_Chain_Run_Finished__c,
		   		Last_Chain_Run_Total_Processed_Records__c   
		   		FROM Data_Purge_Job__c 
		   		WHERE Status__c = 'Ready' AND Mode__c = 'Once Daily' AND (Last_Run_Started__c < :dtToday OR Last_Run_Started__c = NULL) ORDER BY Last_Run_Started__c ASC NULLS FIRST ];
				
				Set<Data_Purge_Job__c> dpjSet = new Set<Data_Purge_Job__c>();
				dpjSet.addAll(dpjList1);
				dpjSet.addAll(dpjList2);
				
				dpjList.addAll(dpjSet);
				
   			}
   			else
   			{
   				dpjList = [SELECT Id, Name, OwnerId, Object_API_Name__c, Query_Condition__c, Status__c, Last_Run_Started__c, 
		   		Last_Run_Finished__c, Last_Run_Error__c, Last_Run_Batch_Id__c, Query_Limit__c, Batch_Size__c, Last_Run_Number_of_Records_Processed__c,
		   		Mode__c, Remove_From_Recycle_Bin__c, Chain_Runs__c, Email_Per__c, Last_Chain_Run_Started__c, Last_Chain_Run_Finished__c,
		   		Last_Chain_Run_Total_Processed_Records__c   
		   		FROM Data_Purge_Job__c 
		   		WHERE Id = :dpjId AND Status__c != 'Deactivated' AND Status__c != 'Queued' AND Mode__c = 'On Demand'];
   			}
   			
			while(runningBatchJobs < 5 && dpjCount < dpjList.size())
			{
				
				Data_Purge_Job__c dpj = dpjList[dpjCount];
				
				if(dpj.Name == 'ERRORSCHEDULE')
	   	   		{
	   	   			throw new DataPurgeJobBatch.DataPurgeJobException('Custom Exception');
	   	   		}
				
				String q = 'SELECT Id FROM ' + dpj.Object_API_Name__c;
				
				if(dpj.Query_Condition__c != null && dpj.Query_Condition__c.trim() != '')
				{
					q += ' WHERE ' + dpj.Query_Condition__c;
				}
				
				q += + ' LIMIT ' + dpj.Query_Limit__c;
				
				try {
					if(dpj.Status__c == 'Ready')
					{
						dpj.Status__c = 'Queued';
					}	
					Id batchInstanceId = Database.executeBatch(new DataPurgeJobBatch(q,dpj), Integer.valueOf(dpj.Batch_Size__c)); 
					runningBatchJobs++;
					
					if(dpj.Name == 'ERRORBATCHJOB')
	   	   			{
	   	   				throw new DataPurgeJobBatch.DataPurgeJobException('Custom Exception');
	   	   			}
					
					Data_Purge_Job__c dpjToUpd = new Data_Purge_Job__c();
					dpjToUpd.Id = dpj.Id;
					dpjToUpd.Last_Run_Batch_Id__c = batchInstanceId;
					
					
					updateDpjBatchIds.add(dpjToUpd);
					
					Data_Purge_Job__c dpjToUpdStatus = new Data_Purge_Job__c();
					dpjToUpdStatus.Id = dpj.Id;
					dpjToUpdStatus.Status__c = dpj.Status__c;
					
					updateDpjStatuses.add(dpjToUpdStatus);
					
				} catch(Exception e) {
					
					Data_Purge_Job__c dpjErr = new Data_Purge_Job__c();
					dpjErr.Id = dpj.Id;
					dpjErr.Last_Run_Error__c = 'Apex Class: DataPurgeJobSchedule.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
					
					dpjErrored.add(dpjErr);
					
				}finally {
				
					dpjCount++;
					
				}
			}
			
			if(updateDpjStatuses.size() > 0)
			{
				try {
					update updateDpjStatuses;
				}catch(Exception e) {}
			}
			
			if(updateDpjBatchIds.size() > 0)
			{
				update updateDpjBatchIds;
			}
			
			if(dpjErrored.size() > 0)
			{
				update dpjErrored;
			}
			
   		}
   }
   
   private DeltakSRP__Error_Log__c generateErrorLog(Exception e)
   {
   		
   		DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
  		el.DeltakSRP__Type__c = 'Apex';
  		el.DeltakSRP__Partner_Name__c = 'WLY';
  		String errorDetails = 'General errors have occured for one or more Data Purge Jobs: ' + 'Apex Class: DataPurgeJobSchedule.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
  		if(errorDetails.length() < 255)
  		{
  			el.DeltakSRP__Detail__c = errorDetails;
  		}
  		else
  		{
  			el.DeltakSRP__Detail__c = errorDetails.substring(0,250) + '...';
  		}
  		el.DeltakSRP__External_Id__c = 'Data Purge Job : ' + DateTime.now() + DateTime.now().millisecond();
  		el.DeltakSRP__Object__c = 'Data Purge Job';
	      		
	    return el;
	    
   }
   
}