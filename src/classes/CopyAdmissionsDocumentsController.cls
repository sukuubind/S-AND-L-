public class CopyAdmissionsDocumentsController {
    private Opportunity opp;    
    private Map<String, Id> recTypesMap;
    
    //This will get the document templates based on the Opportunity's program and display them to the user
    public List <Program_Admission_Template__c> templates {
        get {
            Opportunity o=null;
                 
            o = [select Program__c FROM Opportunity WHERE id=:opp.Id LIMIT 1];
            
            if (o.Program__c != null) {
                Program_Admission_Template__c [] templateList = [select Name,Type__c, Comments__c, Order__c, Required__c, Application_Fee__c
                                                          FROM Program_Admission_Template__c 
                                                          WHERE Program__c = :o.Program__c
                                                          ORDER BY Order__c];
                if (templateList.size() == 0) {
                    return null;
                }
                
                else return templateList;
            }
            
            else { 
                return null;
            }
        }
        set; 
    }
    
    //Used to display error messages to the user    
    public string errorMsg {
        get; set;
    }
    
    
    public CopyAdmissionsDocumentsController(ApexPages.StandardController controller) {
        
        opp = (Opportunity)controller.getRecord();      
        
        // Updated on May 20, 2013 to include only record types for Program_Admission_Document__c object
        RecordType [] recTypes = [select Id,Name from RecordType Where SobjectType = 'Program_Admission_Document__c'];
        
        RecTypesMap = new Map<String, Id > ();
        for (RecordType r : recTypes) {
            recTypesMap.put(r.Name, r.Id);
        }
    }
    
    public CopyAdmissionsDocumentsController () {
        
    }
    
    
    //Cangel button takes the user back to the opportunity the oringinally came from
    public PageReference Cancel() {
        
            PageReference pg= new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
                pg.setRedirect(true);
                return pg;
    }
    
    //CopyDocs button   
    public PageReference CopyDocs () {
        
        //get the opportunity 
        if (opp == null) {
            opp = [select Id FROM Opportunity 
                             WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            
        }
        
        //if null, then there are no templates to move.
        if (templates == null) {
            errorMsg = 'Error: There are no templates to move.';
            return null;
        }
        
        List <Program_Admission_Document__c> opportunityDocs = new  List<Program_Admission_Document__c> ();
        
        //copy the tempaltes to the opportunityDocs list    
        for (Program_Admission_Template__c template : templates) {
            
            Program_Admission_Document__c doc = new Program_Admission_Document__c();                
                doc.Document_Name__c    = template.Name;
                doc.Comments__c         = template.Comments__c;
                //doc.Type__c           = template.Type__c;
                doc.Required__c         = true;
                doc.RecordTypeId        = recTypesMap.get(template.Type__c);
                doc.Opportunity__c      = opp.Id;
                doc.Order__c            = template.Order__c;
                doc.Fee_Amount__c       = template.Application_Fee__c; 
            opportunityDocs.add(doc);
        }
        
        //insert the docs
        insert opportunityDocs;
        
        //return back to the opportunity the user came from
        PageReference pg = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
                pg.setRedirect(true);
                return pg;
    }
}