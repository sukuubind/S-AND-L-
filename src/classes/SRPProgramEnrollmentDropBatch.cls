global class SRPProgramEnrollmentDropBatch implements Database.Batchable<sObject> {
        
    Private string querytoExecute;
    
    global SRPProgramEnrollmentDropBatch(String strQuery){
        this.querytoExecute = strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(querytoExecute);
    }
    
    global void execute(Database.BatchableContext BC, List<DeltakSRP__Program_Enrollment__c> lstPE){
        SRPEnrollmentHistoryTriggerHelper.findDropProgramEnrollments(lstPE);
        SRPEnrollmentHistoryTriggerHelper.SaveAllUpdatedObjects();
    } 
    
    
    global void finish(Database.BatchableContext BC){
    }

}