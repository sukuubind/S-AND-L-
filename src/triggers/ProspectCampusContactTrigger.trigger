trigger ProspectCampusContactTrigger on Campus_Contacts__c (after insert, after update, before insert, 
before update, after delete) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.OverrideProspectCampusContactTrigger__c); 
    
    if(bypassTrigger)   return; 
    
	if(trigger.isInsert && trigger.isAfter){
		ProspectTeamMemberTriggerHandler.handleCampusContactAfterInsert(trigger.new);
	}
	
	if(trigger.isDelete && trigger.isAfter){
		ProspectTeamMemberTriggerHandler.handleCampusContactAfterDelete(trigger.old); 
	}
}