trigger EventTrigger on Event ( after insert, after update) {
	
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
   /* if(Trigger.isBefore){
        Set<Id> contactIds = new Set<id>();
        
        for(Event e : Trigger.new){
            contactIds.add(e.WhoId);
        }
        Map<Id, String> idToTimeZone = new Map<Id, String>();
        List<Contact> contactList = [Select 
                                        c.Id,
                                        c.Time_Zone__c 
                                        From Contact c
                                        Where c.Id in :contactIds
                                    ];
        if(contactList != null && contactList.size() > 0){
            for(Contact thisContact : contactList){
                idToTimeZone.put(thisContact.id, thisContact.Time_Zone__c);
            }
        }
        for(Event e : Trigger.new){
            Id thisContactId = e.WhoId;
            if(idToTimeZone != null && idToTimeZone.containsKey(thisContactId)){
                String timeZone = idToTimeZone.get(thisContactId);
                System.debug('Time Zone '+timeZone);
                e.Time_Zone__c = timeZone;
            }
        }
    }*/
    
    if(Trigger.isAfter){
        Set<Id> eventIds = new Set<Id>();
        Map<Id, Date> OppID_to_LastAttempt = new Map<Id, Date>();
        Map<Id, DateTime> OppID_to_InitialContact = new Map<Id, DateTime>();
        Map<Id, Date> OppID_to_LastContact = new Map<Id, Date>();
        Map<Id, Date> OppID_to_AppointmentCompleted = new Map<Id, Date>();
        
        boolean updateOpp;
        Map<id,Opportunity> oppsToUpdate = new Map<id,Opportunity>();
        
           //get the record types and put them in a map
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Schema.DescribeSObjectResult R = Event.SObjectType.getDescribe();                
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        for (Schema.RecordTypeInfo rtInfo : RT) {           
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        
        for(Event b : Trigger.new) {
            string eventRT = b.RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
           		eventRT == null ||
           		eventRT == '') {
                eventIds.add(b.WhatId);
            }                 
        }
        
        Opportunity [] taskOpps =  [select Id, Last_Attempt__c, Quality_Contact__c, Last_Contact__c, Appointment_Completed__c  
                                   FROM Opportunity 
                                   WHERE Id IN :eventIds];
                                   
        for (Opportunity o : taskOpps) {
            OppID_to_LastAttempt.put(o.Id, o.Last_Attempt__c);
            OppID_to_InitialContact.put(o.Id, o.Quality_Contact__c);
            OppID_to_LastContact.put(o.Id, o.Last_Attempt__c);
            OppID_to_AppointmentCompleted.put(o.Id, o.Appointment_Completed__c );
            oppsToUpdate.put(o.Id, o);
        }
        //for (Task taskRecord : TaskIds) {
            
        //}    
        
        System.debug('### Trigger size = '+trigger.size);
        
        for (integer record = 0; record < trigger.size; record++) {
            string eventRT = trigger.new[record].RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
           		eventRT == null ||
           		eventRT == '') {
                Date lastAttempt = OppID_to_LastAttempt.get(trigger.new[record].WhatId);
                DateTime initialContact = OppID_to_InitialContact.get(trigger.new[record].WhatId);
                //oppsToUpdate.set()
                /*
                if (trigger.new[record].Result__c == 'Successful contact') {
                    trigger.new[record].Successful__c = true;
                    tasksToUpdates.add(trigger.new[record]);
                }
                */
                
                boolean populateInitialContact = 
                    ((trigger.new[record].Type == 'Call' ||             
                    trigger.new[record].Type == 'Appointment') &&
                    trigger.new[record].Event_Status__c == 'Completed' &&
                    (trigger.new[record].Result__c == 'Successful') &&
                    initialContact == null);           
                    
                boolean populateLastAttempt = 
                    ((trigger.new[record].Type == 'Call' ||             
                    trigger.new[record].Event_Status__c == 'Completed') &&
                    (trigger.new[record].Result__c != 'Successful'));
                        
                          
                boolean populateLastContact = 
                    ((trigger.new[record].Type == 'Call' ||             
                    trigger.new[record].Type == 'Appointment') &&
                    trigger.new[record].Event_Status__c == 'Completed' &&
                     (trigger.new[record].Result__c == 'Successful') &&
                    initialContact != null);            
                
                boolean populateAppointmentCompleted = 
                    (trigger.new[record].Type == 'Appointment' && 
                    trigger.new[record].Event_Status__c == 'Completed' &&
                    (trigger.new[record].Result__c == 'Successful' ));  
                          
                          
                    if(trigger.new[record].WhatId != null){
                       String whatIdVal = trigger.new[record].WhatId;
                       if(whatIdVal != null && whatIdVal.startsWith('006')){
                        if (populateInitialContact) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());  
                            //taskOpp.Quality_Contact__c = t;
                            oppsToUpdate.get(trigger.new[record].WhatId).Quality_Contact__c = t;
                            oppsToUpdate.get(trigger.new[record].WhatId).Last_Contact__c = d;
                            System.debug('!!! Quality_Contact__c updated');
                        }
                       
                       //set Last_Attempt__c 
                       if (populateLastAttempt) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());
                           oppsToUpdate.get(trigger.new[record].WhatId).Last_Attempt__c = d;
                            //taskOpp.Last_Attempt__c = d;
                            System.debug('!!! Last_Attempt__c updated');
                        }
                       
                       //set Last_Contact__c
                       if (populateLastContact) {               
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());  
                            oppsToUpdate.get(trigger.new[record].WhatId).Last_Contact__c = d;        
                            //taskOpp.Last_Contact__c = d;
                            System.debug('!!! Last_Contact__c updated');
                       }
                       
                       if (populateAppointmentCompleted) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());
                            oppsToUpdate.get(trigger.new[record].WhatId).Appointment_Completed__c  = d;
                        }
                       
                       //update taskOpp; 
                    }
                }
            }   
        }
        
            if (oppsToUpdate != null && oppsToUpdate.size() > 0 &&  ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false ) {
                try{
                    update oppsToUpdate.values();
                }
                catch(Exception e){
                    System.Debug(e);
                }
            }
        
            //update tasksToUpdates;
        }
    }
}