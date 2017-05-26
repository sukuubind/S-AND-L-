global with sharing class SRPBatchSetPendingActivityDate implements Database.Batchable<sObject>, Database.Stateful{
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    private SRPSetPendingActivityDateClass setPendingDate = new SRPSetPendingActivityDateClass();
    
    private Task [] tasks = null;
    private Event [] events = null;
    string activityCompleted = 'Completed'; 
    
    
    global srpbatchSetPendingActivityDate(String q, String e, String f, String v){     
        Query=q; Entity=e; Field=f;Value=v;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
            
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('Beginning of new batch...');
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        Set <Id> oppIds = new Set<Id>();
        
        for(integer i=0; i<scope.size(); i++){
             //Only process it if it's an Opportunity record
             if(scope[i].getsObjectType() == Opportunity.sObjectType) {
                Opportunity o = (Opportunity) scope[i];
                oppIds.add(o.Id);
             }
        }
        
        tasks = [SELECT WhatId, ActivityDate FROM Task  
        WHERE Status != :activityCompleted
        AND ActivityDate > :System.today()
        AND WhatId IN :oppIds];
    
        events = [SELECT WhatId, ActivityDate FROM Event
        WHERE deltaksrp__Event_Status__c != :activityCompleted
        AND ActivityDate > :System.today()
        AND WhatId IN :oppIds];
        
        for(integer i=0; i<scope.size(); i++){
             //Only process it if it's an Opportunity record
             if(scope[i].getsObjectType() == Opportunity.sObjectType) {
                Opportunity o = (Opportunity) scope[i];
                
                
            
                List <Date> dateList = new List<Date> ();
                
                for (Task t : tasks) {
                    if (t.WhatId == o.Id) {
                        dateList.add(t.ActivityDate);
                    }
                }               
                
                for (Event e : events) {
                    if (e.WhatId == o.Id) {
                        dateList.add(e.ActivityDate);
                    }
                }
                
                Date earliestDate = setPendingDate.getEarliestDate(dateList);
                
                System.Debug('--> earliestDate ' + earliestDate + ' for Opportunity ' + o.Id);
                System.Debug('dateList --> ' + dateList);
                
                o.deltaksrp__Pending_Activity_Date__c = earliestDate;
                oppsToUpdate.add(o);
                
             }
        }
        
        try {
            update oppsToUpdate;
        }
        
        catch(Exception e){
            System.Debug('Error updating Pending Activity Date - Error = ' + e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    
    
    static testMethod void batchSetPendingActivityDate() {       
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Opportunity;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('Student Opportunity');
        Id recTypeId = rt.getRecordTypeId();
        
        Opportunity o = new Opportunity();        
            o.CloseDate = System.today();
            o.Name='Test'; 
            o.StageName = 'New Inquiry';  
            o.RecordTypeID = recTypeId ;
        insert o;
        string query = 
            'SELECT Id FROM Opportunity WHERE RecordType.Name = \'Student Opportunity\'';
         
        
        Test.startTest();

        System.debug('Query ----> ' + query);
        ID batchId = null;
        
        batchSetPendingActivityDate updatePendingActivityDate = new batchSetPendingActivityDate (query, '', '', '');
        batchId = Database.executeBatch(updatePendingActivityDate); 
         
        Test.stopTest();
        
    }

}