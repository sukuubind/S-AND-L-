public with sharing class SRPOpp_StudentChanged {
public static void studentChanged(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
        
        SetPerson(oldOpps, newOpps);
        
        //MoveTasks(oldOpps, newOpps);
        
        MoveEvents(oldOpps, newOpps);
    }
    
    public static void SetPerson(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
        Contact [] studentContacts; 
        Set<id> newStudentIds = new Set<id>();
        Map <Id, String> oppsId_to_FirstName = new Map<Id, String>();
        Map <Id, String> oppsId_to_LastName = new Map<Id, String>();
        Map <Id, Id> oppsId_to_Student_Person = new Map<Id, Id>();
          
        for (Opportunity newRecord : newOpps) { 
            newStudentIds.add(newRecord.deltaksrp__Student__c);
        }
        
        /*********************************************************************************************************************
        //If the Contact ID on the Opportunity changes, change the Opportunity's person lookup to the newly 
        //  referenced contact's person
        //**********************************************************************************************************************/
        //Get the IDs for the Person lookup off of the Contact (Affiliation)      
        studentContacts = [select FirstName, LastName, deltaksrp__Person__c,Id
                                  FROM Contact
                                  WHERE Id in :newStudentIds];
        for (Contact c : studentContacts ){
            System.debug('****  Person__c = '+c.deltaksrp__Person__c);
            oppsId_to_Student_Person.put(c.Id, c.deltaksrp__Person__c);
            oppsId_to_FirstName.put(c.Id, c.FirstName);
            oppsId_to_LastName.put(c.Id, c.LastName);
        }
        
        
    
        for (integer record = 0; record < newOpps.size(); record++) {
            Opportunity newRecord = newOpps[record];
            Opportunity oldRecord = oldOpps[record];  
            
            if (newRecord.Student__c != oldRecord.deltaksrp__Student__c ) { 
                
                //If Student__c is null, set Person__c to null
                if (newRecord.deltaksrp__Student__c==null) {
                    newRecord.SRP_Person__c = null;
                    System.debug('--- newRecord.Student__c = Null');
                }           
                
                //Get the Person__c field of the Contact lookup 
                else {
                    newRecord.SRP_Person__c = oppsId_to_Student_Person.get(newRecord.deltaksrp__Student__c);
                }
            }
        }    
    }
    
    /*public static void MoveTasks(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
                //the ids of the opportunities being updated
        Set <Id> oppIds = new Set<Id>();
        
        //the previous affiliation id to the changed affiliation id
        Map <Id, Id> oldId_to_newId = new Map<Id,Id>();
         
        for (Opportunity o : newOpps) {
            oppIds.add(o.Id);
        }
        
        System.debug('oppIds --> ' + oppIds);
        
        Opportunity [] newOppsArray = newOpps;
        Opportunity [] oldOppsArray = oldOpps;
        
        //populate the map
        for (integer i = 0; i < newOppsArray.size(); i++ ) {
            oldId_to_newId.put(oldOppsArray[i].deltaksrp__Student__c, newOppsArray[i].deltaksrp__Student__c);     
        }
        
        System.debug('oldId_to_newId map populated: ' + oldId_to_newId);
        
        //get the tasks which are related to the changed opportunities
        //ALL ROWS gets all tasks including the ones in activity history
        Task [] tasks = [
                        SELECT WhoId 
                        FROM Task 
                        WHERE WhatId in :oppIds
                        AND IsDeleted = false 
                        LIMIT 1000
                        ALL ROWS];
        
        List <Task> updatedTasks = new List <Task>();
                 
        for (Task t : tasks) {
            
            Id newWhoId = oldId_to_newId.get(t.WhoId);
            System.debug('Task who id set to ' + newWhoId);
            
            t.WhoId = newWhoId;         
            
            updatedTasks.add(t);            
        }
        
        
        
        //this sets a static variable which is used to prevent a recurrsive loop exception       
        ReassignActivitiesHelper.setChangingStudentLookupOnOpportunity();
        System.debug('Updating tasks...');  
        
        try {
            update updatedTasks;        
        }
        catch(Exception e) {
            //if it's a validation error then ignore it 
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                System.debug(e);
            }
            
            else {
                throw e;
                System.debug(e);
            }
        }
    }   */
    
    public static void MoveEvents(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
        Set <Id> oppIds = new Set<Id>();
        Map <Id, Id> oldId_to_newId = new Map<Id,Id>();
         
        for (Opportunity o : newOpps) {
            oppIds.add(o.Id);
        }
        
        System.debug('oppIds --> ' + oppIds);
        
        Opportunity [] newOppsArray = newOpps;
        Opportunity [] oldOppsArray = oldOpps;
        
        for (integer i = 0; i < newOppsArray.size(); i++ ) {
            oldId_to_newId.put(oldOppsArray[i].deltaksrp__Student__c, newOppsArray[i].deltaksrp__Student__c);     
        }
        
        System.debug('oldId_to_newId map populated: ' + oldId_to_newId);
        //get the tasks which are related to the changed opportunities
        //ALL ROWS gets all events including the ones in activity history
        Event [] events = [SELECT WhoId 
                           FROM Event 
                           WHERE WhatId in :oppIds
                           AND IsDeleted = false 
                           LIMIT 1000
                           ALL ROWS];
                           
        List <Event> updatedEvents = new List <Event>();
         
        for (Event e : events) {
            
            Id newWhoId = oldId_to_newId.get(e.WhoId);
            System.debug('Event whoid set to ' + newWhoId);
            
            e.WhoId = newWhoId;         
            
            updatedEvents.add(e);           
        }
        //this sets a static variable which is used to prevent a recurrsive loop exception       
        ReassignActivitiesHelper.setChangingStudentLookupOnOpportunity();
        System.debug('Updating events...');
        try {
            update updatedEvents;       
        }
        catch(Exception e) {
            //if it's a validation error then ignore it 
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                System.debug(e);
            }
            
            else {
                throw e;
                System.debug(e);
            }
        }
    }
}