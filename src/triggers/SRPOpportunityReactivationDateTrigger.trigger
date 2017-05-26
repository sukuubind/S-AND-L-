trigger SRPOpportunityReactivationDateTrigger on Opportunity (before update, before insert, after update) {
    
    SRPOpportunityTriggerHandler parentName = new SRPOpportunityTriggerHandler();
    
    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityReactivationDateTrigger__c); 
    
    if(bypassTrigger)   return; 

    //RecordType srprecordtype = [Select Id from RecordType where name =: 'SRP Opportunity']; 
    
    if(Trigger.isInsert && Trigger.isBefore){
         parentName.handleRestrictedStates(trigger.new);
         parentName.handleNotesBeforeInsert(Trigger.new); 
    }   
    else if(Trigger.isBefore && Trigger.isUpdate)
    { 
        parentName.handleRestrictedStates(trigger.new);
        parentName.handleBeforeInsert(Trigger.New);
        parentName.handleLockDownDates(Trigger.new);
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Schema.RecordTypeInfo srprecordtype =  rtMapByName.get('SRP Opportunity');
        
        for(Opportunity o: Trigger.New){
            if(srprecordtype != null && o.RecordTypeId == srprecordtype.getRecordTypeId()){
                if(trigger.oldMap.get(o.Id).stagename == 'Dormant' && o.stagename <> 'Dormant'){
                    o.deltaksrp__reactivated_by__c = userinfo.getuserid();
                    system.debug('update reactivated by>>>>');
                }    
                    //o.DeltakSRP__Reactivated_Date__c = system.today();
            }
    	}
    }else if(Trigger.isAfter && Trigger.isUpdate){
    	
    	system.debug('In after update reactivation trigger');
    	parentName.handleNotes(Trigger.new, Trigger.old);
    }
    
}