global without sharing class SRPEHUpdateForReporting implements  Database.Batchable<sObject> {

	
	global SRPEHUpdateForReporting(){
		
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		String query;
        
        query = 'Select Id, DeltakSRP__Program__c, createdDate, Week_Start_Date__c, Future_Enrollment_External_iD_Group_By__c, FE_External_ID_Group_By__c from DeltakSRP__Enrollment_History__c where Future_Enrollment_External_iD_Group_By__c = \'\' '; 
         if(Test.isRunningTest()){
            query = query + ' limit 15 ';
        }     
        return Database.getQueryLocator(query); 
		
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<DeltakSRP__Enrollment_History__c> ehRecords = (List<DeltakSRP__Enrollment_History__c>)scope;
		List<DeltakSRP__Enrollment_History__c> ehRecordsToUpdate = SRPEnrollmentHistoryTriggerHelper.updateEH_FE_ExternalID(ehRecords,false);
		if(ehRecordsToUpdate != null && ehRecordsToUpdate.size() > 0){
			Database.update(ehRecordsToUpdate, false);
		}
	}
	
	global void finish(Database.BatchableContext BC){
		DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
     	Integer BATCH_SIZE = 2000;
         Integer DAYS_FROM_NOW = Integer.valueOf(setting.FEP_Reporting_Schedule__c);
     	SRPEHUpdateForReporting fed = new SRPEHUpdateForReporting();
        if(!Test.isRunningTest()){
            String cronID = System.scheduleBatch(fed, 'SRPEHUpdateForReporting'+System.now(), DAYS_FROM_NOW, BATCH_SIZE);
        }
		
	}
}