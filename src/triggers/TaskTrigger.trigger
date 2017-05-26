trigger TaskTrigger on Task (after insert, after update) {
	
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
    	List<Batch_Job__c> batchJobList = new List<Batch_Job__c>();
        //Opportunity [] opps = [select Id FROM Opportunity];
        Set<Id> TaskIds = new Set<Id>();
        Map<Id, Date> OppID_to_LastAttempt = new Map<Id, Date>();
        Map<Id, DateTime> OppID_to_InitialContact = new Map<Id, DateTime>();
        Map<Id, Date> OppID_to_LastContact = new Map<Id, Date>();
        Map<Id, Date> OppID_to_AppointmentCompleted = new Map<Id, Date>();
            
        boolean updateOpp;
        Map<id,Opportunity> oppsToUpdate = new Map<id,Opportunity>();
        List <Task> tasksToUpdates = new List<Task>();
        
         //get the record types and put them in a map
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Schema.DescribeSObjectResult R = Task.SObjectType.getDescribe(); 
        Schema.DescribeSObjectResult BR = Batch_Job__c.SObjectType.getDescribe();                 
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos(); 
         List<Schema.RecordTypeInfo> BRT = BR.getRecordTypeInfos(); 
                       
        for (Schema.RecordTypeInfo rtInfo : RT) {
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        for (Schema.RecordTypeInfo rtInfo : BRT) {
           recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        //get the new WhatIDs pulled in trhough the trigger
        for(Task b : Trigger.new) {
            string taskRT = b.RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT ||
                taskRT == null ||
                taskRT == '') {
                TaskIds.add(b.WhatId);
            }
        }
        
        //Get the Last Attempt, Initial Contact and Last Contact from the 
        Opportunity [] taskOpps = null;
        if(taskIds != null && taskIds.size() >0 )
            taskOpps =  [select Id, Last_Attempt__c, Quality_Contact__c, Last_Contact__c, Appointment_Completed__c 
                                   FROM Opportunity 
                                   WHERE Id IN :taskIds
                                   for update];
                                   
       if(taskOpps != null){
        for (Opportunity o : taskOpps) {
            OppID_to_LastAttempt.put(o.Id, o.Last_Attempt__c);
            OppID_to_InitialContact.put(o.Id, o.Quality_Contact__c);
            OppID_to_LastContact.put(o.Id, o.Last_Attempt__c);
            OppID_to_AppointmentCompleted.put(o.Id, o.Appointment_Completed__c );
            oppsToUpdate.put(o.Id, o);
        }
       }
        
        System.debug('### Trigger size = '+trigger.size);
        
        for (integer record = 0; record < trigger.size; record++) {
        	Batch_Job__c thisbatchRecord = new Batch_Job__c();
        	thisbatchRecord.RecordTypeId = recordTypeName_to_recordTypeId.get('Migration');
        	thisbatchRecord.RecordId__c = trigger.new[record].WhatId;
            string taskRT = trigger.new[record].RecordTypeId;
            if ( recordTypeName_to_recordTypeId.get('Deltak: Student') == taskRT ||
                taskRT == null ||
                taskRT == '') {
                Date lastAttempt = OppID_to_LastAttempt.get(trigger.new[record].WhatId);
                Id whatId = trigger.new[record].WhatId;
                DateTime initialContact = ((OppID_to_InitialContact != null && OppID_to_InitialContact.containsKey(whatId)) ? OppID_to_InitialContact.get(whatId) : null );
              System.debug('@asha: TaskTrigger: Initial Contact ='+initialContact);
                boolean populateInitialContact = 
                    ((trigger.new[record].Type == 'Call - Outbound' || trigger.new[record].Type == 'Call - Inbound' || trigger.new[record].Type == 'Appointment') &&
                    trigger.new[record].Status == 'Completed' &&
                    (trigger.new[record].Result__c == 'Successful' ) &&
                    initialContact == null);
                
                boolean populateLastAttempt = 
                    ((trigger.new[record].Type == 'Call - Outbound' || trigger.new[record].Type == 'Call - Inbound' || trigger.new[record].Type == 'Transition Call') &&
                    trigger.new[record].Status == 'Completed' &&
                    (trigger.new[record].Result__c != 'Successful' ));
                    
                boolean populateLastContact = 
                    (((trigger.new[record].Type == 'Call - Outbound') || (trigger.new[record].Type == 'Call - Inbound') || (trigger.new[record].Type == 'Appointment') || (trigger.new[record].Type == 'Transition Call')) &&
                    trigger.new[record].Status == 'Completed' &&
                    (trigger.new[record].Result__c == 'Successful' ) &&
                    initialContact != null); 
                
                boolean populateAppointmentCompleted = 
                    (trigger.new[record].Type == 'Appointment' && 
                    trigger.new[record].Status == 'Completed' &&
                    (trigger.new[record].Result__c == 'Successful' ));
                 
                /** VS bug fix related to 516 START Adding conditional logic to check for What Id
                ** And Checking if What Id is an opportunity **/
                if(trigger.new[record].WhatId != null){
                   String whatIdVal = trigger.new[record].WhatId;
                   if(whatIdVal != null && whatIdVal.startsWith('006')){
                        if (populateInitialContact) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());  
                            thisbatchRecord.Custom_property_2__c = String.valueOf(t);
                            thisbatchRecord.Custom_Property_3__c = String.valueOf(d);
                            /*oppsToUpdate.get(trigger.new[record].WhatId).Quality_Contact__c = t;
                            oppsToUpdate.get(trigger.new[record].WhatId).Last_Contact__c = d; */
                            System.debug('!!! Quality_Contact__c updated');
                        }
                       
                       //set Last_Attempt__c 
                       if (populateLastAttempt) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());
                            thisbatchRecord.Custom_Property_4__c = String.valueOf(d);      
                            //oppsToUpdate.get(trigger.new[record].WhatId).Last_Attempt__c = d;            
                            System.debug('!!! Last_Attempt__c updated');
                        }
                       
                       //set Last_Contact__c
                       if (populateLastContact) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());  
                            thisbatchRecord.Custom_Property_3__c = String.valueOf(d);   
                            //oppsToUpdate.get(trigger.new[record].WhatId).Last_Contact__c = d;
                            System.debug('!!! Last_Contact__c updated');
                       }
                       
                       if (populateAppointmentCompleted) {
                            DateTime t=System.now();
                            date d = Date.newInstance(t.year(),t.month(),t.day());
                            thisbatchRecord.Custom_Property_5__c = String.valueOf(d);
                            //oppsToUpdate.get(trigger.new[record].WhatId).Appointment_Completed__c  = d;
                       }
                   batchJobList.add(thisbatchRecord);
                   }
                }
            }
        }
        System.Debug('batchJobList -- '+batchJobList);        
        try{
			if(batchJobList != null && batchJobList.size() > 0){
				Database.upsert(batchJobList, Batch_Job__c.RecordID__c, false);
			}
		}catch(DMLException e){
			System.Debug(e);
		}        
        //update the opportunities
        /** VS Adding try catch, null and size check as part of bug fix 516 START *
        try{
            if(oppsToUpdate != null && oppsToUpdate.size() > 0 && ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false)
             update oppsToUpdate.values();   
        }catch(Exception e){
            System.Debug(e);
        }**/
   }   
}