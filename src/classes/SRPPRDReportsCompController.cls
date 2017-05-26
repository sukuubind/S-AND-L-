public with sharing class SRPPRDReportsCompController {
    public String emailAddress {get; set; }
    public List<Opportunity> oppList { set; }
    public Boolean isAccSRP {get; set;}
    public SRPPRDReportsCompController(){
        isAccSRP = false;
    }
    
    
    
    public List<Opportunity> getOppList(){
        System.Debug('@vignesh -- emailAddress: '+emailAddress);
        if(emailAddress!=null)
        {
            //Map<String,List<String>> emailPgmMap = new Map<String,List<String>>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Email_Partner_Reports__c> emailPgmList = new List<Email_Partner_Reports__c>();
            List<String> pgms = new List<String>();
            String pgmArray = '(';
            emailPgmList = Email_Partner_Reports__c.getAll().values();
            String partnerId = '';
            if(emailPgmList!=null && emailPgmList.size()>0)
            {
                
                for(Email_Partner_Reports__c ePL: emailPgmList)
                {
                    if(ePL.Email_Address__c==emailAddress)
                    {
                        pgms.add(ePL.Program_Id__c);
                        partnerId = ePL.Partner_Id__c;
                    }
                    
                }
                System.debug('pgmArray-->'+pgms);
                for(String p: pgms)
                {
                    if(pgmArray=='(' )
                        {
                            pgmARRAY = pgmArray + '\'' + p;
                        }else
                        {
                            pgmArray  = pgmArray + '\'' + ','+ '\'' + p;
                        }
                        
                }
                
            }
            System.debug('pgmArray-->'+pgmArray);
            
            if(partnerId!=null && partnerId!='')
            {
                
                for(Account acc: [SELECT Id, RecordType.DeveloperName From Account WHERE id = :partnerId])
                {
                    if(acc.RecordType.DeveloperName=='SRP_Account')
                    {
                        isAccSRP = true;
                    }
                }
             
                List<String> apiNames = new List<String>();
                Map<String,String> labelValueMap = new Map<String,String>();
                
                List<Partner_Report_Fields__c> prFlds = Partner_Report_Fields__c.getAll().values();
                System.debug('prFlds.size()-->'+prFlds.size());
                if(prFlds!=null && prFlds.size()>0)
                {
                    for(Partner_Report_Fields__c prf: prFlds)
                    {
                        if(prf.is_SRP__c==isAccSRP)
                        {
                            apiNames.add(prf.Field_API_Name__c);
                        }
                    }
                }
                String query = 'SELECT '; 
                if(isAccSRP)
                {
                    for(Integer i=0; i < apiNames.size(); i++) 
                    {
                      query += apiNames[i] + ',' ;
                    }  
                    query += 'Id FROM Opportunity';
                    query += ' WHERE DeltakSRP__Academic_Program__r.Id in ';
                    query +=  pgmArray;
                    query += '\') and CreatedDate ';
                    query += Label.Partner_Report_Duration;
                    System.debug('querySRP-->'+query); 
                }else
                {
                    for(Integer i=0; i < apiNames.size(); i++) 
                    {
                      query += apiNames[i] + ',' ;
                    }  
                    query += 'Id FROM Opportunity';
                    query += ' WHERE Program__r.Id in ';
                    query +=  pgmArray;
                    query += '\') and CreatedDate ';
                    query += Label.Partner_Report_Duration;
                    System.debug('querySRM-->'+query); 
                }
                 
                oppList = Database.query(query);  
            }else
            {
        
                oppList = [Select o.Mailing_Country__c, 
                                            o.Mailing_State__c,
                                            o.Student__r.Email,
                                            o.Student__r.HomePhone,
                                            o.Student__r.MobilePhone,
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
                                            where o.Program__r.Id in : pgms and o.CreatedDate = YESTERDAY];
            }
        
        return oppList;
        }else
        {
            return null;
        }
    }
}