trigger ProspectCaseTrigger on Case (after insert, after update, before insert, before update) {
    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.ProspectCaseTrigger__c); 
    
    if(bypassTrigger)   return; 
   
    
    
    if(Trigger.isInsert && Trigger.isBefore){
    	ProspectCaseHandler casehandle = new ProspectCaseHandler();
    	caseHandle.intelligentlySetCaseType(Trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        
        ProspectLogHandler prospectLog = new ProspectLogHandler();
        prospectLog.createLogRecords_case(Trigger.new, null, null, false);
        
        
    } 
    if(Trigger.isAfter && Trigger.isUpdate){
        ProspectLogHandler prospectLog = new ProspectLogHandler();
        prospectLog.createProspectLogRecordForCase(Trigger.old, Trigger.new); 
    }
}