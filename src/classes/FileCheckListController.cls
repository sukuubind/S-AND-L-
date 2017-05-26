public with sharing class FileCheckListController {
    private Opportunity opp;    
    //private Map <Id, String> recTypesMap;


//This will get the document templates based on the Opportunity's program and display them to the user
    public List <Program_Admission_Document__c> docs {
        get {
            
            Program_Admission_Document__c [] pad = [SELECT Detail__c, RecordType.Name, Date_Received__c, Order__c, Status__c, Status_Boolean__c, Comments__c, Degree_Conferral_Date__c  
                                                    FROM Program_Admission_Document__c
                                                    WHERE Opportunity__c = : opp.Id
                                                    ORDER BY Order__c];
        
        Return pad;
        
        }
        
        set; 
        
    }


public FileCheckListController(ApexPages.StandardController controller) {
        
        opp = (Opportunity)controller.getRecord();      
        RecordType [] recTypes = [select Id,Name from RecordType];
        
        /* RecTypesMap = new Map<Id, String> ();
        for (RecordType r : recTypes) {
            recTypesMap.put(r.Id, r.Name);
        }*/
    }
    
}