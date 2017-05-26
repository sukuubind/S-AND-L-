trigger SRPSendEmailForIncomingSMS on smagicinteract__Incoming_SMS__c (after insert) {

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPSendEmailForIncomingSMS__c); 
    
    if(bypassTrigger)   return; 
 

	smagicinteract__Incoming_SMS__c[] incomingSMS = Trigger.new;
	SRPIncomingSMSEmail.sendEmail(incomingSMS);
}