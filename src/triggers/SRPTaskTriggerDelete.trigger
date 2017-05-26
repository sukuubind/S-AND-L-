trigger SRPTaskTriggerDelete on Task (before delete) {

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPTaskTriggerDelete__c); 
    
    if(bypassTrigger)   return; 
     
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
    if (!loggedInUser.Profile.Name.contains('Integration')) {
        
         //get the record types and put them in a map
         //added 10/27/11
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Schema.DescribeSObjectResult R = Task.SObjectType.getDescribe();                
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        
        for (Schema.RecordTypeInfo rtInfo : RT) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        
        string errorMsg = 'You cannot delete a task which is closed.';
        for (integer record = 0; record < trigger.size; record++) {
            
            //added 10/27/11
            string taskRT = trigger.old[record].RecordTypeId;               
            
            if (trigger.old[record].IsClosed == true && 
               (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
                taskRT == null ||
                taskRT == ''))
                {
                    trigger.old[record].addError(errorMsg);
            }
        } 
    }
}