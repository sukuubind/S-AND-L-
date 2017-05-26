trigger SRPPendingActivityDateTrigger_Event on Event (after insert, after update) {

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPPendingActivityDateTrigger_Event__c); 
    
    if(bypassTrigger)   return; 

    
    Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult R = Event.SObjectType.getDescribe();                
    List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
    
    for (Schema.RecordTypeInfo rtInfo : RT) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
    }
    
    //added 10/27/11
    string taskRT = trigger.new[0].RecordTypeId;    
    
    if (trigger.isInsert) {
        System.debug('Deltak: Student Event --> ' + recordTypeName_to_recordTypeId.get('Deltak: Student Event'));
        boolean isChangingStudentLookup = ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity();
        boolean isStudentRecType = (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == taskRT || taskRT == null || taskRT == ''); 
        System.debug('isChangingStudentLookup = ' + isChangingStudentLookup );
        System.debug('isStudentRecType = ' + isStudentRecType );  
        system.debug('due date = ' + trigger.new[0].ActivityDate);      
        if ( 
            (ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false)  &&  
            isStudentRecType &&
            trigger.new[0].ActivityDate > System.today()
            ) {
            System.debug('Calling SRPSetPendingActivityDateClass ...');
            SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
        }
    }
    
    string activityCompleted = 'Completed';
    if (trigger.isUpdate) {
        //only execute if isChangingStudentLookupOnOpportunity = false and the record type is student 
        //and either the activity Date (due date) is changing or the status is changing to something other than 'Completed'
        boolean isChangingStudentLookup = ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity();
        System.debug('isChangingStudentLookup = ' + isChangingStudentLookup );
        system.debug('due date = ' + trigger.new[0].ActivityDate); 
        if (
            ( isChangingStudentLookup == false) &&  
            (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == taskRT  || taskRT == null || taskRT == '') &&
            trigger.new[0].ActivityDate > System.today() &&
            (trigger.new[0].ActivityDate != trigger.old[0].ActivityDate ||trigger.new[0].deltaksrp__Event_Status__c != trigger.old[0].deltaksrp__Event_Status__c && trigger.new[0].deltaksrp__Event_Status__c != activityCompleted)) {
                system.debug('*** Setting Pending Activity Date on Event: '+ trigger.new[0].ActivityDate);
                SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
                setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
            }
    }
    
    if(trigger.new[0].deltaksrp__Event_Status__c == activityCompleted && (Trigger.old!=null && Trigger.old[0].deltaksrp__Event_Status__c!=activityCompleted)){
        
        List<Event> openEvents = new List<Event>();
        List<Task> openTasks = new List<Task>();
        
        if(!Test.isRunningTest()){
            openEvents = [Select Id from Event where deltaksrp__Event_Status__c != :activityCompleted and whatId = :trigger.new[0].WhatId];
            openTasks = [Select Id from Task where Status != :activityCompleted and whatId = :trigger.new[0].WhatId];
        }
        
        SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
        
        if(openevents.size()==0 && openTasks.size()==0 && (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == taskRT  || taskRT == null || taskRT == '')){
            setPendingDate.resetPendingActivityDate(trigger.new[0].WhatId); 
        }else{ 
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
        }   
    }
}