global class BatchCaseEmailCounter implements Database.Batchable<sObject>{
    String query;
     
    global Database.querylocator start(Database.BatchableContext BC){
        Query = 'Select id,Email_Counter__c from Case where Email_Counter__c != 0 AND Case_Creation__c = \'Cherwell\'';   
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Case> scope){
       List<Case> CaseList = new List<Case>();
 
       for(Case s : scope){
           s.Email_Counter__c = 0; 
           CaseList.add(s); 
       }
 
       update CaseList;
    }
     
    global void finish(Database.BatchableContext BC){
    }
}