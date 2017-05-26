trigger SRPEventTrigger on Event (after insert, after update) {
       
       SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPEventTrigger__c); 
    
    if(bypassTrigger)   return; 
       User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
       if (!loggedInUser.Profile.Name.contains('Integration')) {
       
        
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
            
            Opportunity [] taskOpps =  [select Id, deltaksrp__Last_Attempt__c, deltaksrp__Quality_Contact__c, deltaksrp__Last_Contact__c, deltaksrp__Appointment_Completed__c  
                                       FROM Opportunity 
                                       WHERE Id IN :eventIds];
                                       
            for (Opportunity o : taskOpps) {
                OppID_to_LastAttempt.put(o.Id, o.deltaksrp__Last_Attempt__c);
                OppID_to_InitialContact.put(o.Id, o.deltaksrp__Quality_Contact__c);
                OppID_to_LastContact.put(o.Id, o.deltaksrp__Last_Attempt__c);
                OppID_to_AppointmentCompleted.put(o.Id, o.deltaksrp__Appointment_Completed__c );
                oppsToUpdate.put(o.Id, o);
            }
            
            System.debug('### Trigger size = '+trigger.size);
            
            for (integer record = 0; record < trigger.size; record++) {
                string eventRT = trigger.new[record].RecordTypeId;
                if (recordTypeName_to_recordTypeId.get('Deltak: Student Event') == eventRT ||
                    eventRT == null ||
                    eventRT == '') {
                    Date lastAttempt = OppID_to_LastAttempt.get(trigger.new[record].WhatId);
                    DateTime initialContact = OppID_to_InitialContact.get(trigger.new[record].WhatId);
                    
                    boolean populateInitialContact = 
                        ((trigger.new[record].Type == 'Call' ||             
                        trigger.new[record].Type == 'Appointment') &&
                        trigger.new[record].DeltakSRP__Event_Status__c == 'Completed' &&
                        (trigger.new[record].DeltakSRP__Result__c == 'Successful') &&
                        initialContact == null);           
                        
                    boolean populateLastAttempt = 
                        ((trigger.new[record].Type == 'Call' ||             
                        trigger.new[record].DeltakSRP__Event_Status__c == 'Completed') &&
                        (trigger.new[record].DeltakSRP__Result__c != 'Successful'));
                            
                              
                    boolean populateLastContact = 
                        ((trigger.new[record].Type == 'Call' ||             
                        trigger.new[record].Type == 'Appointment') &&
                        trigger.new[record].DeltakSRP__Event_Status__c == 'Completed' &&
                         (trigger.new[record].DeltakSRP__Result__c == 'Successful') &&
                        initialContact != null);            
                    
                    boolean populateAppointmentCompleted = 
                        (trigger.new[record].Type == 'Appointment' && 
                        trigger.new[record].DeltakSRP__Event_Status__c == 'Completed' &&
                        (trigger.new[record].DeltakSRP__Result__c == 'Successful' ));  
                              
                              
                        if(trigger.new[record].WhatId != null){
                           String whatIdVal = trigger.new[record].WhatId;
                           if(whatIdVal != null && whatIdVal.startsWith('006')){
                            if (populateInitialContact) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());  
                                //taskOpp.Quality_Contact__c = t;
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Quality_Contact__c = t;
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Contact__c = d;
                                System.debug('!!! Quality_Contact__c updated');
                            }
                           
                           //set Last_Attempt__c 
                           if (populateLastAttempt) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());
                               oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Attempt__c = d;
                                //taskOpp.Last_Attempt__c = d;
                                System.debug('!!! Last_Attempt__c updated');
                            }
                           
                           //set Last_Contact__c
                           if (populateLastContact) {               
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());  
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Last_Contact__c = d;        
                                //taskOpp.Last_Contact__c = d;
                                System.debug('!!! Last_Contact__c updated');
                           }
                           
                           if (populateAppointmentCompleted) {
                                DateTime t=System.now();
                                date d = Date.newInstance(t.year(),t.month(),t.day());
                                oppsToUpdate.get(trigger.new[record].WhatId).deltaksrp__Appointment_Completed__c  = d;
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