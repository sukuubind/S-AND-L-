trigger LiveChatFeedbackTrigger on Live_Chat_Feedback__c (after insert, after update, before insert, 
before update) {



  /*
  SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPSOATupleTrigger__c); 
 System.debug('>--->'+triggerOverride);
 System.debug('>---> checked bypass');   
    if(bypassTrigger)   return;
   System.debug('>---> beyond bypass');
  */ 
   
  if(trigger.isBefore && trigger.isInsert)
  {
  		LiveChatFeedbackTriggerHandler.handleBeforeInsert(Trigger.New);  
  }
  









}