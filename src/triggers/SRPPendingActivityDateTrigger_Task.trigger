trigger SRPPendingActivityDateTrigger_Task on Task (after insert, after update) {
    //get the record types and put them in a map
     //added 10/27/11
 
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPPendingActivityDateTrigger_Task__c); 
    
    if(bypassTrigger)   return; 
 
  
    Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult R = Task.SObjectType.getDescribe();                
    List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
    
    for (Schema.RecordTypeInfo rtInfo : RT) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
    }
    
    //added 10/27/11
    string taskRT = trigger.new[0].RecordTypeId;    
    if (trigger.isInsert) {
        //only execute if isChangingStudentLookupOnOpportunity = false and the record type is student 
        if (ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false &&  
            (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || taskRT == null || taskRT == '') &&
            trigger.new[0].ActivityDate > System.today() ) {
            SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
        }
    }
    
    
    string activityCompleted = 'Completed';
    if (trigger.isUpdate) {
        //only execute if isChangingStudentLookupOnOpportunity = false and the record type is student 
        //and either the activity Date (due date) is changing or the status is changing to something other than 'Completed'
        if (
            (ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false) &&  
            (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || taskRT == null || taskRT == '') &&           
            (trigger.new[0].ActivityDate > System.today()) &&
            (trigger.new[0].ActivityDate != trigger.old[0].ActivityDate || trigger.new[0].Status != trigger.old[0].Status && trigger.new[0].Status != activityCompleted)) {
                SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
                setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
            }
    }
    
    if(trigger.new[0].Status == activityCompleted && (Trigger.old!=null && Trigger.old[0].Status!=activityCompleted)){
        List<Event> openEvents = new List<Event>();
        List<Task> openTasks = new List<Task>();
        
        if(!Test.isRunningTest()){
            openEvents = [Select Id from Event where deltaksrp__Event_Status__c != :activityCompleted and whatId = :trigger.new[0].WhatId];
            openTasks = [Select Id from Task where Status != :activityCompleted and whatId = :trigger.new[0].WhatId];
        }
        
        system.debug('openTasks>>>>'+openTasks);
        system.debug('trigger.Old[0]>>>>'+Trigger.Old[0]);
        system.debug('trigger.New[0]>>>>'+Trigger.New[0]);
        SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
        
        if(openevents.size()==0 && openTasks.size()==0 && (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || taskRT == null || taskRT == '')){
            setPendingDate.resetPendingActivityDate(trigger.new[0].WhatId);
        } else{ 
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId);
        }   
    }
}