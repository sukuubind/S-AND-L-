trigger ProspectTeamMemberTrigger on Team_Member__c (after insert, after update, 
                                                     before insert, before update, 
                                                     after delete) {
    if(Trigger.isBefore && Trigger.isInsert){
        ProspectTeamMemberTriggerHandler.handleBeforeInsert(Trigger.new);
    }else if(Trigger.isAfter && Trigger.isInsert){
        ProspectTeamMemberTriggerHandler.handleAfterInsert(Trigger.new);
    }else if(Trigger.isBefore && Trigger.isUpdate){
        DeltakSRP__Trigger_Override__c triggerOverride = DeltakSRP__Trigger_Override__c.getInstance(); 
        Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.DeltakSRP__Override_All__c || triggerOverride.Override_Team_Member__c); 
        if(bypassTrigger)   return;
        ProspectTeamMemberTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.old);
    }else if(Trigger.isAfter && Trigger.isUpdate){
        DeltakSRP__Trigger_Override__c triggerOverride = DeltakSRP__Trigger_Override__c.getInstance(); 
        Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.DeltakSRP__Override_All__c || triggerOverride.Override_Team_Member__c); 
        if(bypassTrigger)   return;
        ProspectTeamMemberTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.old);
    }else if(Trigger.isAfter && Trigger.isDelete){
        DeltakSRP__Trigger_Override__c triggerOverride = DeltakSRP__Trigger_Override__c.getInstance(); 
        Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.DeltakSRP__Override_All__c || triggerOverride.Override_Team_Member__c); 
        if(bypassTrigger)   return; 
        ProspectTeamMemberTriggerHandler.handleAfterDelete(Trigger.old);
    }
}