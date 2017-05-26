global class DuplicateOpportunityCheck {
    Webservice static List <String> check (Id contactID, string key5) {
        //Contact [] contacts = [SELECT Id FROM Contact WHERE Id = :contactID];
        
        //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Student Opportunity' LIMIT 1];
        List <String> dupOpps = new List <String>();
        Opportunity [] opportunityList = [SELECT Id, Name
                                          FROM Opportunity
                                          WHERE Student__r.Id = :contactID
                                          AND Account.Goldmine_Key5__c = :key5                                     
                                          AND StageName <> 'Start'
                                          AND StageName <> 'Closed - Duplicate'
                                          AND RecordType.Name = 'Student Opportunity'
                                          AND Sub_Stage__c <> 'Duplicate Record'
                                          ];
         System.Debug(opportunityList);
        
        for (Opportunity opp : opportunityList) {
            System.debug('DuplicateOpportunityCheck: Adding opportunity named '+opp.Name);
            dupOpps.add(opp.Id);
        }
        return dupOpps;                    
    }
    
    /*Edited by Abha S. - 06/21/12   (Web Scheduler related)
    This method checks if there exists duplicates for the lead then returns the last modified opportunity which is not dormant**/
    Webservice static Opportunity check_webSch (String Key5, String RasID, String webPhone1, String webEmail)  {
         Opportunity retOpp;
   
         System.debug('Key5 =============  '+Key5);
         
         Opportunity[] opportunityList = [SELECT Id, Student__r.Alternate_Phone__c, Student__r.Alternate_Email__c, LastModifiedDate, webschedulerstatus__c, Source__c, Student__r.Email, Student__r.Work_Phone__c, Student__r.HomePhone
                                          FROM Opportunity                                       
                                          WHERE Student__r.Person__r.RasID__c = :RasID
                                          AND Account.Goldmine_Key5__c =: Key5
                                          AND StageName <> 'Dormant'
                                          ORDER BY LastModifiedDate DESC                                     
                                          ];
                                          
        
         
         if(opportunityList.isEmpty() == false){            
             for(Opportunity opp : opportunityList){   
                 System.Debug('Opportunity ID = = = = = = = = = '+opp.Id);                                
                 System.Debug('LastActivityDate = '+opp.LastModifiedDate);
                 System.Debug('web scheduler status  = '+opp.webschedulerstatus__c);
                 System.Debug('Source  = '+opp.Source__c);
                 System.Debug('Key5  = '+Account.Goldmine_Key5__c);
                 System.Debug('Email  = '+opp.Student__r.Email);
                 System.Debug('Phone1 (Work)  = '+opp.Student__r.Work_Phone__c);
                 System.Debug('Phone2 (Home)  = '+opp.Student__r.HomePhone);
             }
           retOpp = opportunityList[0]; 
         
       /*  if(retOpp != null){
            if(webPhone1 <> retOpp.Student__r.Work_Phone__c){
                retOpp.Student__r.Alternate_Phone__c = webPhone1;
                System.debug('Phone1 - LP - '+webPhone1);
            }
            if(webEmail <> retOpp.Student__r.Email){
                retOpp.Student__r.Alternate_Email__c = webEmail;
                System.debug('Email _ LP - '+webEmail);
            }
            
            update retOpp.Student__r;
            
         } */
        /* Opportunity[] opportunityList = [SELECT Id, LastModifiedDate, webschedulerstatus__c, Source__c, Student__r.Email, Student__r.Work_Phone__c, Student__r.HomePhone
                                          FROM Opportunity                                       
                                          WHERE Student__r.Person__r.RasID__c = :RasID
                                          AND Account.Goldmine_Key5__c =: Key5
                                          AND StageName <> 'Dormant'
                                          ORDER BY LastModifiedDate DESC                                     
                                          ];
                                          
        
         
         if(opportunityList.isEmpty() == false){            
             for(Opportunity opp : opportunityList){   
                 System.Debug('Opportunity ID = = = = = = = = = '+opp.Id);                                
                 System.Debug('LastActivityDate = '+opp.LastModifiedDate);
                 System.Debug('web scheduler status  = '+opp.webschedulerstatus__c);
                 System.Debug('Source  = '+opp.Source__c);
                 System.Debug('Key5  = '+Account.Goldmine_Key5__c);
                 System.Debug('Email  = '+opp.Student__r.Email);
                 System.Debug('Phone1 (Work)  = '+opp.Student__r.Work_Phone__c);
                 System.Debug('Phone2 (Home)  = '+opp.Student__r.HomePhone);
             }
            
             
             retOpp = opportunityList[0];
         
             Contact[] studentAffiliation =  [SELECT Id, Alternate_Phone__c, Alternate_Email__c, Work_Phone__c, Email
                                              FROM Contact
                                              WHERE Id =: opportunityList[0].Student__r.Id
                                             ];
                                         
            if(webPhone1 <> studentAffiliation[0].Work_Phone__c){
                studentAffiliation[0].Alternate_Phone__c = webPhone1;
                System.debug('Phone1 - LP - '+webPhone1);
            }
            if(webEmail <> studentAffiliation[0].Email){
                studentAffiliation[0].Alternate_Email__c = webEmail;
                System.debug('Email _ LP - '+webEmail);
            }    
        
            update studentAffiliation[0]; */
        }
        return retOpp;
    }
}