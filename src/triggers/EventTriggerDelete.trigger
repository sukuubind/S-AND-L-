trigger EventTriggerDelete on Event (before delete) {
	
	String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
	
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
   if (!loggedInUser.Profile.Name.contains('Integration')) {
    string errorMsg = 'You cannot delete a task which is closed.';
    
    //get the record types and put them in a map
         //added 10/27/11
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Schema.DescribeSObjectResult R = Event.SObjectType.getDescribe();                
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        
        for (Schema.RecordTypeInfo rtInfo : RT) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
    
    for (integer record = 0; record < trigger.size; record++) {
        //added 10/27/11
        string taskRT = trigger.old[record].RecordTypeId;    
        if (trigger.old[record].Event_Status__c == 'Completed'  && 
           (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == taskRT ||                
            taskRT == null ||
            taskRT == '')) {
				trigger.old[record].addError(errorMsg);
        }
    }
   }
}