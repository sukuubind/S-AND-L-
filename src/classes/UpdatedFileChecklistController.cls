public with sharing class UpdatedFileChecklistController {

    
    public List<DeltakSRP__Program_Admission_Document__c> docs {get; private set;}   
    
    /**
     * @description Extension constructor
     * Populates the list of Program Admission Documents for PDF generation
     */
    public UpdatedFileCheckListController(ApexPages.StandardController controller) {    
        docs = 
            [Select 
                RecordType.Name, 
                DeltakSRP__Date_Received__c, 
                DeltakSRP__Order__c, DeltakSRP__Status__c, 
                DeltakSRP__Status_Boolean__c, 
                DeltakSRP__Comments__c, Detail__c,
                DeltakSRP__Degree_Conferral_Date__c  
             From 
                DeltakSRP__Program_Admission_Document__c
             Where     
                DeltakSRP__Opportunity__c = :controller.getId()
             Order By 
                DeltakSRP__Order__c];     
    }
}