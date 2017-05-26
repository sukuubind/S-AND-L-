/*********************************************************
* Venkat Santhanam Modified from immediate opportunity update to batch update 
* Venkat Santhanam added version header on 08/27/2014
* Venkat Santhanam Modified for record lock fix on 08/27/2014
* Pratik Tanna Modified  for Resolved the Pending Activity Reset bug after the activity is complete on 03/28/2013
* Unknown Modified for get the record types and put them in a map on 10/27/2011
* Unknown Modified for changingStudentLookup on Task on 10/27/2011
* !!WARNING!! THIS TRIGGER IS NOT BULKIFIED AND WILL RUN ONLY FOR ONE TASK
*********************************************************/


trigger PendingActivityDateTrigger_Task on Task (after insert, after update) {  
    
    String currentProfileId = userinfo.getProfileId();
    currentProfileId = currentProfileId.substring(0, 15);
    List<SRP_Profiles_List__c> SRPProfilesList = SRP_Profiles_List__c.getall().values();
    Set<String> srpProfiles = new Set<String>();
    for(SRP_Profiles_List__c spl: SRPProfilesList){
        srpProfiles.add(spl.ProfileId__c);
    }
    if(srpProfiles.contains(currentProfileId) ){
        return; 
    }
    String whatID = trigger.new[0].WhatId;
    if(whatID == null || (whatID != null && !whatID.startsWith('006'))){
        return;
    }
    
    Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult R = Task.SObjectType.getDescribe();                
    List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
    
    for (Schema.RecordTypeInfo rtInfo : RT) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
    }
     
    SetPendingActivityDateClass setPendingDate = new SetPendingActivityDateClass(trigger.new[0].WhatId);
    Date earliestDate = setPendingDate.getPendingActivityDate(trigger.new[0].WhatId, trigger.new[0].Id);
    boolean pendingActivityDateCalled = false;
    String taskRT = trigger.new[0].RecordTypeId;    
    if (trigger.isInsert && trigger.isAfter) {
        //only execute if isChangingStudentLookupOnOpportunity = false and the record type is student 
        if (ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false &&  
            (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || taskRT == null || taskRT == '') &&
            trigger.new[0].ActivityDate > System.today() ) {
            /** Refactoring to find the date first and set only the date and not query again START **/
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId, earliestDate);
            pendingActivityDateCalled = true;
            /** Refactoring to find the date first and set only the date and not query again START **/
        }
    }
    
    
    String activityCompleted = 'Completed';
    if (trigger.isUpdate && trigger.isAfter) {
        //only execute if isChangingStudentLookupOnOpportunity = false and the record type is student 
        //and either the activity Date (due date) is changing or the status is changing to something other than 'Completed'
        if (
            (ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false) &&  
            (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || taskRT == null || taskRT == '') &&           
            (trigger.new[0].ActivityDate > System.today()) &&
            (trigger.new[0].ActivityDate != trigger.old[0].ActivityDate || trigger.new[0].Status != trigger.old[0].Status && trigger.new[0].Status != activityCompleted)) {
                setPendingDate.setPendingActivityDate(trigger.new[0].WhatId, earliestDate);
            }
    }
    
    if(trigger.new[0].Status == activityCompleted && 
      (trigger.old!=null && Trigger.old[0].Status!=activityCompleted)){
        pendingActivityDateCalled = true;
        if(earliestDate == null){
            setPendingDate.resetPendingActivityDate(trigger.new[0].WhatId);
        }else{
            setPendingDate.setPendingActivityDate(trigger.new[0].WhatId, earliestDate);
        }
        
    }
    if(pendingActivityDateCalled){
        setPendingDate.commitPendingActivityDate();
    }
}