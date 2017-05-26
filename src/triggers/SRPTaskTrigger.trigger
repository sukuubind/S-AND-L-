trigger SRPTaskTrigger on Task (after insert, after update) {

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPTaskTrigger__c); 
    
    if(bypassTrigger)   return; 
         
       User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
       if (!loggedInUser.Profile.Name.contains('Integration')) {
        	
        	SRPTaskTriggerHandler.populateLastActivityOnAffiliation(Trigger.New); 
        	
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
            List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
            for (Schema.RecordTypeInfo rtInfo : RT) {
                System.debug(rtInfo.getName());
                System.debug(rtInfo.getRecordTypeId());
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
            
            system.debug('TaskIds>>>>'+TaskIds);
            
            //Get the Last Attempt, Initial Contact and Last Contact from the 
            Opportunity [] taskOpps = null;
            if(taskIds != null && taskIds.size() >0 )
                taskOpps =  [select Id, deltaksrp__Last_Attempt__c, deltaksrp__Quality_Contact__c, deltaksrp__Last_Contact__c, deltaksrp__Appointment_Completed__c 
                                       FROM Opportunity 
                                       WHERE Id IN :taskIds];
                                       
           if(taskOpps != null){
            for (Opportunity o : taskOpps) {
                OppID_to_LastAttempt.put(o.Id, o.deltaksrp__Last_Attempt__c);
                OppID_to_InitialContact.put(o.Id, o.deltaksrp__Quality_Contact__c);
                OppID_to_LastContact.put(o.Id, o.deltaksrp__Last_Attempt__c);
                OppID_to_AppointmentCompleted.put(o.Id, o.deltaksrp__Appointment_Completed__c );
                oppsToUpdate.put(o.Id, o);
            }
           }
            
            System.debug('### Trigger size = '+trigger.size);
            
            for (integer record = 0; record < trigger.size; record++) {
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
                        (trigger.new[record].deltaksrp__Result__c == 'Successful' ) &&
                        initialContact == null);
                    
                    boolean populateLastAttempt = 
                        ((trigger.new[record].Type == 'Call - Outbound' || trigger.new[record].Type == 'Call - Inbound' || trigger.new[record].Type == 'Transition Call') &&
                        trigger.new[record].Status == 'Completed' &&
                        (trigger.new[record].deltaksrp__Result__c != 'Successful' ));
                        
                    boolean populateLastContact = 
                        (((trigger.new[record].Type == 'Call - Outbound') || (trigger.new[record].Type == 'Call - Inbound') || (trigger.new[record].Type == 'Appointment') || (trigger.new[record].Type == 'Transition Call')) &&
                        trigger.new[record].Status == 'Completed' &&
                        (trigger.new[record].deltaksrp__Result__c == 'Successful' ) &&
                        initialContact != null);
                    
                    boolean populateAppointmentCompleted = 
                        (trigger.new[record].Type == 'Appointment' && 
                        trigger.new[record].Status == 'Completed' &&
                        (trigger.new[record].deltaksrp__Result__c == 'Successful' ));
                     
                    /** VS bug fix related to 516 START Adding conditional logic to check for What Id
                    ** And Checking if What Id is an opportunity **/
                    if(trigger.new[record].WhatId != null){
                       String whatIdVal = trigger.new[record].WhatId;
                       if(whatIdVal != null && whatIdVal.startsWith('006')){
                            if (populateInitialContact) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());  
                                
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Quality_Contact__c = t;
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Contact__c = d; 
                                System.debug('!!! Quality_Contact__c updated');
                            }
                           
                           system.debug('populateLastAttempt>>>>'+populateLastAttempt);
                           //set Last_Attempt__c 
                           if (populateLastAttempt) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());
                                
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Attempt__c = d;            
                                System.debug('!!! Last_Attempt__c updated');
                            }
                           
                           //set Last_Contact__c
                           if (populateLastContact) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());  
                                
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Contact__c = d;
                                System.debug('!!! Last_Contact__c updated');
                           }
                           
                           if (populateAppointmentCompleted) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Appointment_Completed__c  = d;
                                System.debug('!!! Appointment_Completed__c updated');
                           }
                       }
                    }
                }
            }
                    
            //update the opportunities
            /** VS Adding try catch, null and size check as part of bug fix 516 START **/
            try{
                if(oppsToUpdate != null && oppsToUpdate.size() > 0 && ReassignActivitiesHelper.isChangingStudentLookupOnOpportunity() == false)
                 update oppsToUpdate.values();   
            }catch(Exception e){
                System.Debug(e);
            }
       }   
}