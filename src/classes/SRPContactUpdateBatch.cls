global with sharing class SRPContactUpdateBatch implements Database.Batchable<sObject>{

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        query = 'Select Id, phone, mailingcountry, mailingstate, homephone, mobilephone, deltakSRP__work_phone__c from Contact where recordtype.developername = \'SRP_Contact\'';
        
             
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	List<Contact> contacts = new List<Contact>();
    	
        for(sObject s: Scope){ 
        	Contact c = (Contact)s;
        	contacts.add(c);
        }
        
        List<Contact> contacts2 = SRPContactTriggerHandler.onbeforeinsert(contacts);
        
        update contacts2;
        
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('batch process scheduled is complete>>>>');
        //Id batchInstanceId1 = Database.executeBatch(new SRPFutureEnrollmentDataCreationMissing()); 
        
    }
}