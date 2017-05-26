trigger LiveChatTranscriptTrigger on LiveChatTranscript (after insert, after update, before insert, 
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
  
  if(Trigger.isBefore && Trigger.IsInsert)
  {
  	LiveChatTranscriptTriggerHandler.handleBeforeInsert(Trigger.New);
  } 
  else if(trigger.isAfter && trigger.isInsert)
  {
        LiveChatTranscriptTriggerHandler.handleAfterInsert(Trigger.New);  
  }
  
  if(trigger.isAfter){
      LiveChatTranscriptTriggerHandler.createActivityHistoryOnOpportunity(Trigger.NewMap, Trigger.OldMap);
  }
  

}