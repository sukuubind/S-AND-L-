/**
Abha Sharma - 09/05/2012 Adding Corporate User functionality
Venkat Santhanam - 11/17/2010 Adding Version Header
Chris Baker      - 11/17/2010 Added functionality for CR 47
Pratik Tanna     - 10/25/2015 Changed code to remove 'For Update' clause from all queries to resolve record unavailable issue
**/
trigger TaskTriggerBefore on Task (before insert, before update) {
    
    String currentProfileId = userinfo.getProfileId();
    currentProfileId = currentProfileId.substring(0, 15);
    List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
    Set<String> srpProfiles = new Set<String>();
    SRPProfilesList = SRP_Profiles_List__c.getall().values();
    for(SRP_Profiles_List__c spl: SRPProfilesList){
        srpProfiles.add(spl.ProfileId__c);
    }
    
    system.debug('***profiles: '+ srpProfiles);
    system.debug('***currentProfileId: '+ currentProfileId);
    
    if(srpProfiles.contains(currentProfileId))
        return;
        
    system.debug('***Could not find profile: '+ currentProfileId);
    
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
    if (!loggedInUser.Profile.Name.contains('Integration')) {
    //if (!userinfo.getName().contains('Data Migration')) {
    Set<Id> TaskIds = new Set<Id>();
    Map<Id, Id> taskId_to_OppID = new Map<Id, Id>();
    Set<Id> taskSet = new Set<Id>();
    Map<Id, Id> taskId_to_WhatID = new Map<Id, Id>();
    Map<Id, Id> oppId_to_ContactID = new Map<Id, Id>();
    Set<Id> contactIds = new Set<id>();
    
    string errorMsg = 'Only one appointment may be set for this student. There is already one appointment set for this student.';
    
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
    
    for(Task b : Trigger.new) {
         //added 10/27/11
        string taskRT = b.RecordTypeId;
        if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT  || 
        taskRT == null || taskRT == ''  ) {
            TaskIds.add(b.WhatId);  
            System.debug('WhatID in TaskIds = '+b.WhatId);  
            contactIds.add(b.WhoId);
            System.debug('Adding '+b.WhoId+' to contactIds...');            
            taskId_to_WhatID.put(b.Id, b.WhatID);
        }
        /**Corporate User - added by AbhaS 090512, modified by PhilW 091614
        ** if the record type of the task is 'Deltak: Corporate' then 'Related To' must be Opportunity or  **/
        
        else if (RecordTypeName_to_recordTypeId.get('Deltak: Corporate') == taskRT && b.Type != 'SMS'){
            System.debug('(Corp) Task ID in taskSet = '+b.Id);
            
            string whatIdVal = b.WhatId; /**Corporate User - added by AbhaS 091312**/
            string whoidval = b.whoid;
                       
            if(whoidval == null && (whatidval == null || (whatidval != null && (!(whatIdVal.startswith('006')) && (!(whatIdVal.startswith('500')))) && (b.Type != 'SMS')))){
                b.addError('You must associate this Corporate Task with a Lead or Contact (see “Name” field) or with an Opportunity or Case (see “Related To” field).');
            }
            
            system.debug('no error found>>>>');
 
        }
        /***/  
    }
     System.Debug('taskId_to_WhatID.keyset() -- VS'+taskId_to_WhatID.keyset());
    
    System.debug('TaskIds size = '+TaskIds.size());
    
    Opportunity [] taskOpps =  [select Id, Student__c
                               FROM Opportunity 
                               WHERE Id IN :taskIds];   
    
    System.debug('taskOpps size = '+taskOpps.size());
    
    for (Opportunity o : taskOpps) {
        oppId_to_ContactID.put(o.Id, o.Student__c);
    }
    
    Task [] tasksAssociatedWithOpps = [SELECT Id, WhatID , RecordTypeId
                                       FROM Task
                                       WHERE WhatId in :taskOpps
                                       AND Type = 'Appointment'
                                       and Id not in :taskId_to_WhatID.keyset()];
         System.Debug('tasksAssociatedWithOpps -- VS'+tasksAssociatedWithOpps);                              
    Event [] eventsAssociatedWithOpps  = [SELECT Id, WhatID , RecordTypeId
                                       FROM Event
                                       WHERE WhatId in :taskOpps
                                       AND Type = 'Appointment'];
    
    System.debug('tasksAssociatedWithOpps = ' + tasksAssociatedWithOpps);
    System.debug('eventsAssociatedWithOpps = ' + eventsAssociatedWithOpps);
    
    for (Task t : tasksAssociatedWithOpps) {
         //added 10/27/11
        string taskRT = t.RecordTypeId;
        if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
            taskRT == null || 
            taskRT == '' 
        ) {
            System.debug('Task ID in taskSet = '+t.Id);
            taskId_to_OppID.put(t.WhatId, t.Id );
            taskSet.add(t.Id);
        }
    }
    
    for (Event e : eventsAssociatedWithOpps) {
         //added 10/27/11
        string eventRT = e.RecordTypeId;
        string whatIdVal = e.WhatId;/**Corporate User - added by AbhaS 090512**/
        
        if (eventRecordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT  || 
            eventRT == null || 
            eventRT == '' ) {
            System.debug('event ID in taskSet = '+e.Id);
            taskId_to_OppID.put(e.WhatId, e.Id );
            taskSet.add(e.Id);
        }
        /**Corporate User - added by AbhaS 090512
        ** if the record type of the event is 'Deltak: Corporate EVent' then 'Related To' is required **/
       
        else if (eventRecordTypeName_to_recordTypeId.get('Deltak: Corporate Event') == eventRT){
            System.debug('(Corp) Event ID in eventSet = '+e.Id);
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
    
    System.debug('taskSet size = '+taskSet.size());
    
    
    for (integer record = 0; record < trigger.size; record++) {
         
        //*** USE CASE: Limit number of activities to 1 per Opportunity
        //Find out if there is already an appointmnet for the ooportunity associated with the trigger.new[record]               
        if(Trigger.isInsert || (trigger.old[record].Type != trigger.new[record].Type)){
            if (trigger.new[record].Type == 'Appointment' && 
                taskId_to_OppID.get(taskId_to_WhatID.get(trigger.new[record].Id))!=null ) {
                trigger.new[record].Type.addError(errorMsg);
                System.debug('----- already an appointment -------');
            }
        }
        
        //*** USE CASE: set the WhoID of the task to the student lookup on the opportunity
        //*** CB - 6/9/10 - Only set the WhoID if there is not one already set  
        if (trigger.new[record].WhoId == null) {
            ID contactID = oppId_to_ContactID.get(trigger.new[record].WhatId);
            System.debug('----- Who ID = ' + contactID);
            trigger.new[record].WhoId = contactID;
        }
    }
    
    /**VS Adding New Functionality to copy timezone from contact to Activity START **/
    System.Debug('In Task Trigger isBefore');
    for(Task e : Trigger.new){
        //added 10/27/11
        string taskRT = e.RecordTypeId;
        if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
        taskRT == null || taskRT == ''  ) {
            contactIds.add(e.WhoId);
        }
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
            System.debug('Adding to the idToTimeZone map. idToTimeZone ---> '+idToTimeZone);
        }
    }
    System.Debug('Task ---> '+Trigger.new);
    
      for(Task e : Trigger.new){
        //added 10/27/11
        string taskRT = e.RecordTypeId;
        if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
        taskRT == null || taskRT == '' ) {
            Id thisContactId = e.WhoId;
            if(idToTimeZone != null && idToTimeZone.containsKey(thisContactId)){
                String timeZone = idToTimeZone.get(thisContactId);
                System.debug('TaskTriggerBefore - Time Zone '+timeZone);
                e.Time_Zone__c = timeZone;
                
            }
        }
    }
    /**VS Adding New Functionality to copy timezone from contact to Activity END **/ 
   
    /** CB Adding Funcatinoality to imitate what the "Task - Completed Date" Workflow did. This code is part of CR 47 START ****/
    //If it's a new task and its Status is completed set Completed_Date__c to today's date and time
    if (trigger.isInsert) { 
        for(Task t : Trigger.new){
            //added 10/27/11
            string taskRT = t.RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
        taskRT == null || taskRT == '' ) {
                if (t.Status == 'Completed' && t.Chat_Transcript_Id__c == null) {
                	/*VR-SRP-57: CHANGE ADDED TO NOT RESET COMPLETED DATE AND SRM COMPLETED DATE FOR SMS RECORDS CONERTED TO COMPLETED TASKS*/
                	Datetime complDateBeforeReset = t.Completed_Date__c;
                	// SRP-57: Added 08/20/2015
                    t.Completed_Date__c = System.now();
                    
                    /*VR-SRP-57: CHANGE ADDED TO NOT RESET COMPLETED DATE AND SRM COMPLETED DATE FOR SMS RECORDS CONERTED TO COMPLETED TASKS*/
                   	if(t.Type == 'Text Outgoing' || t.Type == 'Text Incoming')
                   	{
                   		if (t.Subject == 'Outgoing SMS' || t.Subject == 'Incoming SMS')
                   		{
                   			if(complDateBeforeReset!=null)	
                   			{
                   				t.Completed_Date__c = complDateBeforeReset;
                   				t.deltaksrp__Completed_Date__c = t.Completed_Date__c;
                   			}
                   		}
                   	}
                }
            }
        }
    }
    
    //If it's an updated task and its Status changed and its Status is completed set Completed_Date__c to today's date and time
    if (trigger.isUpdate) {
        for (integer record = 0; record < trigger.size; record++) {
            //added 10/27/11
            
            string taskRT = trigger.new[record].RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT || 
        taskRT == null || taskRT == '' ) { 
                if (
                (trigger.new[record].Status  !=
                trigger.old[record].Status ) &&
                trigger.new[record].Status == 'Completed' && trigger.new[record].Chat_Transcript_Id__c == null) {
                	/*VR-SRP-57: CHANGE ADDED TO NOT RESET COMPLETED DATE AND SRM COMPLETED DATE FOR SMS RECORDS CONERTED TO COMPLETED TASKS*/
                	Datetime complDateBeforeReset = trigger.old[record].Completed_Date__c;
                	// SRP-57: Added 08/20/2015
                    trigger.new[record].Completed_Date__c = System.now();
                    
                    /*VR-SRP-57: CHANGE ADDED TO NOT RESET COMPLETED DATE AND SRM COMPLETED DATE FOR SMS RECORDS CONERTED TO COMPLETED TASKS*/
                   	if(trigger.old[record].Type == 'Text Outgoing' || trigger.old[record].Type == 'Text Incoming')
                   	{
                   		if (trigger.old[record].Subject == 'Outgoing SMS' || trigger.old[record].Subject == 'Incoming SMS')
                   		{
                   			trigger.new[record].Completed_Date__c = complDateBeforeReset;
                    		trigger.new[record].deltaksrp__Completed_Date__c = trigger.new[record].Completed_Date__c;
                   		}
                   	}
                }
            }
        }
    }
    /** CB Adding Funcatinoality to imitate what the "Task - Completed Date" Workflow did. This code is part of CR 47 END   ****/
    }
}