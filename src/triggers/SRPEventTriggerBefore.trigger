trigger SRPEventTriggerBefore on Event (before insert, before update) {

       SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPEventTriggerBefore__c); 
    
    if(bypassTrigger)   return; 
       
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
   if (!loggedInUser.Profile.Name.contains('Integration')) {
    string errorMsg = 'Only one appointment may be set for this student. There is already one appointment set for this student.';
    
    Set<Id> EventIds = new Set<Id>();
    Map<Id, Id> EventId_to_OppID = new Map<Id, Id>();
    Set<Id> eventSet = new Set<Id>();
    Map<Id, Id> eventId_to_WhatID = new Map<Id, Id>();
    Map<Id, Id> oppId_to_ContactID = new Map<Id, Id>();
    
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
    
    //event record type map
    //added 10/27/11
    Map<string, id> eventRecordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult Revent = Event.SObjectType.getDescribe();              
    List<Schema.RecordTypeInfo> RTevent = Revent.getRecordTypeInfos();              
    
    for (Schema.RecordTypeInfo rtInfo : RTevent) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        eventRecordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );            
    }
    
    System.debug('Abha - ET ');
    for(event b : Trigger.new) {
         //added 10/27/11
        string eventRT = b.RecordTypeId;
        if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
            System.debug('WhatID in eventIds = '+b.WhatId);
            eventIds.add(b.WhatId);  
            eventId_to_WhatID.put(b.Id, b.WhatID);
        }
         /**Corporate User - added by AbhaS 090512
          ** if the record type of the task is 'Deltak: Corporate' then 'Related To' is required **/
        
        else if (eventRecordTypeName_to_recordTypeId.get('Deltak: Corporate Event') == eventRT){
            System.debug('(Corp) Task ID in eventSet - Event trigger = '+b.Id);
            
            string whatIdVal = b.WhatId; /**Corporate User - added by AbhaS 091312**/
            string whoidval = b.whoid;
            
            system.debug('whatid>>>>'+b.whatid);
            system.debug('whatidval>>>>'+whatidval);
            if(b.WhatId == null && whoidval!=null && !whoidval.startswith('00Q')){
                b.addError('"Related To" field is required.');
            }
            /**Corporate User - added by AbhaS 091312
            the Related To field should be of type Opportunity**/
            
            else if(whoidval!=null && whatidval!=null && !whoidval.startswith('00Q') && !(whatIdVal.startswith('006')) && !(whatIdVal.startswith('500'))){
                b.addError('"Related To" field is required to be an "Opportunity".');
            }
        }
        /***/  
    }
    
    System.debug('eventIds size = '+eventIds.size());
    
    Opportunity [] eventOpps =  [select Id, Deltaksrp__Student__c
                               FROM Opportunity 
                               WHERE Id IN :eventIds];  
    
    System.debug('eventOpps size = '+eventOpps.size());
    
    
    for (Opportunity o : eventOpps) {
        oppId_to_ContactID.put(o.Id, o.deltaksrp__Student__c);
    }
    
    Task [] tasksAssociatedWithOpps = [SELECT Id, WhatID, RecordTypeId 
                                       FROM Task
                                       WHERE WhatId in :eventOpps
                                       AND Type = 'Appointment'];
                                       
    Event [] eventsAssociatedWithOpps = [SELECT Id, WhatID, RecordTypeId 
                                       FROM Event
                                       WHERE WhatId in :eventOpps
                                       AND Type = 'Appointment'];
    
    for (Task t : tasksAssociatedWithOpps) {
         //added 10/27/11
        string taskRT = t.RecordTypeId;
        if (RecordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT ||
                taskRT == null ||
                taskRT == '') {
            System.debug('Task ID in taskSet = '+t.Id);
            eventId_to_OppID.put(t.WhatId, t.Id );
        }
        
    }
    
    for (Event e : eventsAssociatedWithOpps) {
         //added 10/27/11
        string eventRT = e.RecordTypeId;
        if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
            System.debug('event ID in eventSet = '+e.Id);
            eventId_to_OppID.put(e.WhatId, e.Id );
        }
         /**Corporate User - added by AbhaS 090512
        ** if the record type of the task is 'Deltak: Corporate' then 'Related To' is required **/
        
        else if (eventRecordTypeName_to_recordTypeId.get('Deltak: Corporate Event') == eventRT){
            System.debug('(Corp) Event ID in eventSet = '+e.Id);
            
            string whatIdVal = e.WhatId; /**Corporate User - added by AbhaS 091312**/
            
            if(e.WhatId == null){
                e.addError('Related To field is required');
            }
            /**Corporate User - added by AbhaS 091312
            the Related To field should be of type Opportunity**/
            
            else if(!(whatIdVal.startswith('006'))){
                e.addError('Related To field is required to an Opportunity');
            }
        }
        /***/  
    }
    
    for (integer record = 0; record < trigger.size; record++) {
        
        trigger.new[record].DeltakSRP__Completed_Date__c = trigger.new[record].completed_date__c;
        trigger.new[record].DeltakSRP__Event_Status__c = trigger.new[record].event_status__c;
        trigger.new[record].DeltakSRP__Result__c = trigger.new[record].result__c;
        
        if (trigger.new[record].Type == 'Appointment' && 
            eventId_to_OppID.get(eventId_to_WhatID.get(trigger.new[record].Id))!=null && trigger.isinsert) {
            
             //added 10/27/11
            string eventRT = trigger.new[record].RecordTypeId;
            if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                trigger.new[record].Type.addError(errorMsg);
                System.debug('----- already an appointment -------');
            }
        }
        
        //set the WhoID of the task to the student lookup on the opportunity
        if (trigger.new[record].WhoId == null) {
             //added 10/27/11
            string eventRT = trigger.new[record].RecordTypeId;
            if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                ID contactID = oppId_to_ContactID.get(trigger.new[record].WhatId);
                System.debug('----- Who ID = ' + contactID);
                trigger.new[record].WhoId = contactID;
            }
        }
    }
    
    /** VS Adding New functionality to copy the time zone from contact to event START **/
    Set<Id> contactIds = new Set<id>();
        
        for(Event e : Trigger.new){
            //added 10/27/11
            string eventRT = e.RecordTypeId;
            if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                contactIds.add(e.WhoId);
            }
        }
        Map<Id, String> idToTimeZone = new Map<Id, String>();
        List<Contact> contactList = [Select 
                                        c.Id,
                                        c.deltaksrp__Time_Zone__c 
                                        From Contact c
                                        Where c.Id in :contactIds
                                    ];
        if(contactList != null && contactList.size() > 0){
            for(Contact thisContact : contactList){
                idToTimeZone.put(thisContact.id, thisContact.deltaksrp__Time_Zone__c);
            }
        }
        for(Event e : Trigger.new){
            //added 10/27/11
            string eventRT = e.RecordTypeId;
            if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                Id thisContactId = e.WhoId;
                if(idToTimeZone != null && idToTimeZone.containsKey(thisContactId)){
                    String timeZone = idToTimeZone.get(thisContactId);
                    System.debug('EventTriggerBefore - Time Zone '+timeZone);
                    e.Time_Zone__c = timeZone;
                }
            }
        }
    /** VS Adding New functionality to copy the time zone from contact to event END **/
    
    /** CB Adding Funcatinoality to imitate what the "Event - Completed Date" Workflow did. This code is part of CR 47 START ****/
    //If it's a new event and its Status is completed set Completed_Date__c to today's date and time
    if (trigger.isInsert) {
        for(Event e : Trigger.new){
            //added 10/27/11
            string eventRT = e.RecordTypeId;
            if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                if (e.deltaksrp__Event_Status__c == 'Completed') {
                    e.deltaksrp__Completed_Date__c = System.now();
                }
            }
        }
    }
    
    //If it's an updated event and its Status changed and its Status is completed set Completed_Date__c to today's date and time
    if (trigger.isUpdate) {
        for (integer record = 0; record < trigger.size; record++) {
            if (
            (trigger.new[record].deltaksrp__Event_Status__c  !=
            trigger.old[record].deltaksrp__Event_Status__c ) &&
            trigger.new[record].deltaksrp__Event_Status__c == 'Completed') {
                //added 10/27/11
                string eventRT = trigger.new[record].RecordTypeId;
                if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                eventRT == null ||
                eventRT == '') {
                    trigger.new[record].deltaksrp__Completed_Date__c = System.now();
                }
            }
        }
    }
    /** CB Adding Funcatinoality to imitate what the "Task - Completed Date" Workflow did. This code is part of CR 47 END   ****/
   }
}