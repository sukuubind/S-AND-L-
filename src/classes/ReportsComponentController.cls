public with sharing class ReportsComponentController {
    public String emailAddress {get; set; }
    public List<Opportunity> oppList { set; }
    
    
    public ReportsComponentController(){
        
    }
    
    public List<Opportunity> getOppList(){
        System.Debug('@vignesh -- emailAddress: '+emailAddress);
        if(emailAddress!=null)
        {
            //Map<String,List<String>> emailPgmMap = new Map<String,List<String>>();
            List<Email_Partner_Reports__c> emailPgmList = new List<Email_Partner_Reports__c>();
            List<String> pgms = new List<String>();
            emailPgmList = Email_Partner_Reports__c.getAll().values();
            if(emailPgmList!=null && emailPgmList.size()>0)
            {
                
                for(Email_Partner_Reports__c ePL: emailPgmList)
                {
                    if(ePL.Email_Address__c==emailAddress)
                    {
                        
                            pgms.add(ePL.Program_Id__c);
                        
                    }
                    
                }
                
            }
        
        List<Opportunity> oppList = [Select o.Mailing_Country__c, 
                                            o.Mailing_State__c,
                                            o.Student__r.Email,
                                            o.Student__r.HomePhone,
                                            o.Student__r.MobilePhone,
                                            o.Student__r.Work_Phone__c,
                                            o.Student__r.FirstName,
                                            o.Student__r.LastName,
                                            o.Program__r.Program_Category__c,
                                            o.Program__r.Program_Title__c,
                                            o.Program_Degree_Type__c,
                                            o.OK_to_Text__c,
                                            o.Specialization__r.Spec_Title__c, 
                                            o.How_Heard_Detail__c,
                                            o.IM_Type__c,
                                            o.IM_Username__c From Opportunity o 
                                            where o.Program__r.Id in : pgms and
                                            o.createdDate = YESTERDAY];
        
        return oppList;
        }else
        {
            return null;
        }
    }
}