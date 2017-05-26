trigger EventAssociationToEnrollment on Event (before insert, before update) {
    
    
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
        Set <Id> whoIds = new Set<Id>();
        Map<Id, Id> enrollment_to_student = new Map<Id, Id>();
        
        
        //get a map of prefixes and the object name
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String,String> keyPrefixMap = new Map<String,String>{};
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet){
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           String tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
           keyPrefixMap.put(tempPrefix,tempName);
        }
        
        //get a list of the WhoIds (Contact lookups)
        System.debug('Get a list of the WhoIds in the changed events...');
        
        //get the record types and put them in a map
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Schema.DescribeSObjectResult R = Event.SObjectType.getDescribe();                
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        for (Schema.RecordTypeInfo rtInfo : RT) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        
        for(Event t : Trigger.new) {
            System.debug('WhoID = ' + t.WhoId);
             string eventRT = t.RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
           		eventRT == null ||
           		eventRT == '') {
                whoIds.add(t.WhoId);
            }
        }
        
        if (whoIds.size() > 0) {
            System.debug('Get a list of the Student_Affiliation__c records which have a Student_Affiliation__c lookup to one of the above whoIds...');
            Student_Enrollment__c [] enrollments = 
                [SELECT Id,Student_Affiliation__c 
                FROM Student_Enrollment__c
                WHERE Student_Affiliation__c IN :whoIds
                ORDER BY CreatedDate DESC];
            if (enrollments.size() > 0) {
                //only add the first enrollment if there's more than one which will be the most rescent one
                System.debug('Add to map of enrollment id to affiliation id <' + enrollments[0].Student_Affiliation__c + ' , ' + enrollments[0].Id + '>');  
                enrollment_to_student.put(enrollments[0].Student_Affiliation__c, enrollments[0].Id);
                    
                System.debug('Update the WhatId of the tasks...');
                
                for(Event t : Trigger.new) {
                     // CB 8/26/11
                    if (Trigger.isInsert) {
                        //only set the what Id to an enrollment if it is not already set to something
                        System.debug('WhatIdis was set to ' + t.WhatId);
                        if (t.WhatId == null) {                              
                            t.WhatId = enrollment_to_student.get(t.WhoId);
                            System.debug('WhatId set to ' + t.WhatId);
                        }
                    }
                    
                    if (Trigger.isUpdate) {
                        string objectType = null;
                        //if this is an update, we only want to change the student enrollment lookup if the what id is alrady a student enrollment lookup
                        if(t.WhatId!=null){
                            //using the prefix, this will set objectType to the object name of the what id
                            string tPrefix = t.WhatId;
                            tPrefix = tPrefix.subString(0,3);
                            objectType = keyPrefixMap.get(tPrefix);
                            System.debug('Task Id[' + t.id + '] is associated to Object of Type: ' + objectType);
                        }
                        
                        //only update the what id if there is not already one set, or if the one that is set is a student enrollment object
                        if (t.WhatId == null || 
                            (t.WhatId != null && objectType == 'Student_Enrollment__c')) { 
                            t.WhatId = enrollment_to_student.get(t.WhoId);
                            System.debug('WhatId was changed to ' + t.WhatId);
                        }
                    }
                }
                
            }
        }
    }
}