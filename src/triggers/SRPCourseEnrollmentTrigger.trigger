trigger SRPCourseEnrollmentTrigger on DeltakSRP__Course_Enrollment__c (after delete, after insert, after update) {
	
	if(Trigger.isAfter && Trigger.isInsert){
             Map<Id, Contact> returnMap = SRPCourseEnrollmentTriggerHandler.handleAfterInsert(Trigger.new); 
            returnMap = SRPCourseEnrollmentTriggerHandler.updateCourseCompletePercentageOnContact(Trigger.New, returnMap);
		   returnMap = SRPCourseEnrollmentTriggerHandler.updateNumberOfTermsOutOnContact(Trigger.New, returnMap, null);
		   SRPCourseEnrollmentTriggerHandler.updateContacts(returnMap);
	}
	if(Trigger.isAfter && Trigger.isUpdate){
           Map<Id, Contact> returnMap = SRPCourseEnrollmentTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            returnMap =SRPCourseEnrollmentTriggerHandler.updateCourseCompletePercentageOnContact(Trigger.New, returnMap);
		   returnMap =SRPCourseEnrollmentTriggerHandler.updateNumberOfTermsOutOnContact(Trigger.New,returnMap, Trigger.old);
		   SRPCourseEnrollmentTriggerHandler.updateContacts(returnMap);
	}
	/*if(Trigger.isAfter && Trigger.isDelete){
          Map<Id, Contact> returnMap = SRPCourseEnrollmentTriggerHandler.handleAfterDelete(Trigger.new);
          SRPCourseEnrollmentTriggerHandler.updateContacts(returnMap);
	}*/
	

}