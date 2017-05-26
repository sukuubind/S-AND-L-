trigger EntrollmentHistoryTrigger on DeltakSRP__Enrollment_History__c (after insert, after update, before update) {

     if (Trigger.isAfter) {
        if (Trigger.isInsert) { 
            
        }
        if (Trigger.isUpdate) {
            SRPEnrollmentHistoryTriggerHelper.FindReturnAndReenterProgramEnrollments(Trigger.New);
            //Saved Cached objects
            SRPEnrollmentHistoryTriggerHelper.SaveAllUpdatedObjects();
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate){
    	SRPEnrollmentHistoryTriggerHelper.handleBeforeUpdate(Trigger.old, Trigger.new);
    }
}