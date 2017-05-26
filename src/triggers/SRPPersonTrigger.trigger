trigger SRPPersonTrigger on DeltakSRP__Person__c (before insert, before update) {

SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPPersonTrigger__c); 
    
    if(bypassTrigger)   return;
    
    if(trigger.isinsert || trigger.isUpdate){
    	SRPPersonTriggerHandler.onbeforeinsert(trigger.new);
    }
    
}