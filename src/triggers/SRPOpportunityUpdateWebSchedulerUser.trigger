trigger SRPOpportunityUpdateWebSchedulerUser on Opportunity (before update) {

    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityUpdateWebSchedulerUser__c); 
    
    if(bypassTrigger)   return; 
    
    for(Integer i=0;i<Trigger.new.size();i++)
    {
        Opportunity c3 = Trigger.new[i];
        System.debug('DeltakSRP__cwschedappt__c = '+c3.DeltakSRP__cwschedappt__c);
        System.debug('DeltakSRP__WebScheduler_Email__c = '+c3.DeltakSRP__WebScheduler_Email__c);
        System.debug('DeltakSRP__webschedulerstatus__c = '+c3.DeltakSRP__webschedulerstatus__c);
        System.debug('Trigger.old[i].DeltakSRP__webschedulerstatus__c = '+Trigger.old[i].DeltakSRP__webschedulerstatus__c);
        System.debug('OwnerId = '+c3.OwnerId);
        System.debug('Trigger.old[i].OwnerId = '+Trigger.old[i].OwnerId);
        
        if(c3.DeltakSRP__cwschedappt__c==null && c3.DeltakSRP__WebScheduler_Email__c==null
            && c3.DeltakSRP__webschedulerstatus__c == 'New' 
            && Trigger.old[i].OwnerId!=c3.OwnerId  
            && String.valueOf(Trigger.old[i].OwnerId).subString(0,15)=='00532000003htmI')
        {
            //INSIDE LOGIC
            System.debug('OwnerId = '+c3.OwnerId);
            c3.DeltakSRP__Webscheduler_User__c = c3.OwnerId;
        }
    }
    

}