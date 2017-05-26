trigger SRPAttachmentTrigger on Attachment (after insert) {
  
  SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPAttachmentTrigger__c); 
    
    if(bypassTrigger)   return;
  
  List<Attachment> newRecords = Trigger.new;
  List<Attachment> oldRecords = Trigger.old;
  system.debug('inside attachment trigger>>>>');
  if(trigger.isAfter){
    if(trigger.isInsert){
      SRPAttachmentTriggerHandler.copyOpportunityApplicationTemplates(Trigger.New); 
      SRPAttachmentTriggerHandler.sendAttachmentEmail(Trigger.New); 
    }
  }else if(trigger.isBefore){
    if(trigger.isDelete){
      //SRPAttachmentTriggerHandler.doBeforeDelete(oldRecords);
    }
  }
}