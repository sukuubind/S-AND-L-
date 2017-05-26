global class UTCourseEnrollmentBatchProcess implements Database.Batchable<sObject>{
   global final String Query;

   global UTCourseEnrollmentBatchProcess(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
   	System.debug('query >---> ' + query);
    return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC,List<sObject> scope)
   {
      
      List<UT_Course_Enrollment__c> utceNewList = new List<UT_Course_Enrollment__c>();
      List<UT_Course_Enrollment__c> utceMissingOppsList = new List<UT_Course_Enrollment__c>();
      
      Set<Id> utceMissingIdSet = new Set<Id>();
      
      for(Sobject s : scope)
      {
      	
      	UT_Course_Enrollment__c utce = (UT_Course_Enrollment__c) s;
      	
      	if(utce.Status__c == 'New' && utce.Opportunity__c == null)
		{
			utceMissingOppsList.add(utce);
			utceMissingIdSet.add(utce.Id);
		}
		else if(utce.Status__c == 'New' && utce.Opportunity__c != null)
		{
			utceNewList.add(utce);
		}
		
      }	
      
      	System.debug('utceMissingOppsList >---> ' + utceMissingOppsList);
      	System.debug('utceNewList >---> ' + utceNewList);
      	
      	if(utceMissingOppsList.size() > 0 )
		{
			UTCourseEnrollmentCSVToSObject.createMissingOpps(utceMissingOppsList);
			
			String queryMissing = query + ' AND Id IN :utceMissingIdSet';
			
			List<UT_Course_Enrollment__c> updatedUTCEList = Database.query(queryMissing);
			
			System.debug('updatedUTCEList >---> ' + updatedUTCEList);
			
			utceNewList.addAll(updatedUTCEList);
			
		}
		
      if(utceNewList.size() > 0)
		{
			UTCourseEnrollmentCSVToSObject.processUTCourseEnrollmentRecords(utceNewList);
		}
      
   }

   global void finish(Database.BatchableContext BC){

   }

}