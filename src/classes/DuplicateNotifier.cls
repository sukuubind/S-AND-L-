global class DuplicateNotifier {
    Webservice static boolean createCaseBySchoolProgram (string key5, 
                                                          string program,
                                                          string caseType,
                                                          string caseSubtype,
                                                          string caseSubject,
                                                          string caseDescription,
                                                          String affiliationId,
                                                          String personId) {
        
        Id OwnerId;
        String OwnerName='';
        string title = 'Director of Admission';
        
        Account [] school = [SELECT Id, Name, Owner.UserName,
        						OwnerId
                          FROM Account 
                          WHERE Goldmine_Key5__c = :key5];
        
        
        
        if (school.size() > 0) {                                                   
            Campus_Contacts__c [] campusContacts = [SELECT Id, Employee__r.Username 
                                                    FROM Campus_Contacts__c 
                                                    WHERE Organization__c = :school[0].Id
                                                    AND Title__c = :title
                                                    AND Active_User__c = 'ACTIVE'];
            
            
                                                            
            Program_Responsibility__c [] prgmResponsibility = [SELECT Id, Campus_Contacts__c, Academic_Program__r.Abbrev__c
                                                               FROM Program_Responsibility__c];
            
            Map<Id,Id> prgmResponsibilityMap = new Map<id,Id>();
            Map<Id,String> prgmResponsibilitybyProgramMap = new Map<id,String>();
            Set<Id> prgmResponsibilitySetId = new Set<id>();
            Set<Id> prgmResponsibilitySetCC = new Set<id>();
            Set<String> prgmResponsibilitySetProgram = new Set<String>();
            
            for (Program_Responsibility__c p : prgmResponsibility) {
                prgmResponsibilityMap.put(p.Campus_Contacts__c, p.Id);
                prgmResponsibilitybyProgramMap.put(p.Campus_Contacts__c, p.Academic_Program__r.Abbrev__c);
                prgmResponsibilitySetId.add(p.Id);
                prgmResponsibilitySetCC.add(p.Campus_Contacts__c);
                prgmResponsibilitySetProgram.add(p.Academic_Program__r.Abbrev__c);
            }               
                                       
            for (Campus_Contacts__c cc2 : campusContacts) {
                    if (prgmResponsibilitySetCC.contains(cc2.Id)) {
                        //if (prgmResponsibilityMap.get(cc2.Id)==program) {
                        //if (prgmResponsibilitySetProgram.contains(program) {
                            if (prgmResponsibilitybyProgramMap.get(cc2.Id)==program) {                              
                                OwnerName = cc2.Employee__r.UserName;
                                System.debug('Owner Name='+OwnerName);
                                break;
                            }
                        //}
                    }
                }                                                                                   
            
            
            if (OwnerName==null || OwnerName=='') {
                for (Campus_Contacts__c cc : campusContacts) {
                    
                    //if the campus contact does not have any Program Responsibilities assocaited with it
                    if (!prgmResponsibilitySetCC.contains(cc.Id)) {
                        OwnerName = cc.Employee__r.Username;
                        System.debug('Owner Name='+OwnerName);
                        break;
                    }
                }   
            }
            if (OwnerName==null || OwnerName=='') {
            	ownerName = school[0].OwnerId;
            }  
            
            if (OwnerName==null || OwnerName=='') {
                System.debug('Owner Name=NULL');
                return false;
            }
            
            else return createCaseByOwnerUsername(OwnerName, title, caseType, caseSubtype, caseSubject, caseDescription, school[0].Name, affiliationId, personId);
        }
        
        else return false;
    }
    
    /*Create a case by giving the following: 
                                  * Username of the person who should own the case
                                  * Title of the case
                                  * Type 
                                  * SubType
                                  * Description
                                  * Name of the Account that the case is associated with. Use '' if there if you do not want to specify an account
    */
                                  
    Webservice static boolean createCaseByOwnerUsername (string OwnerUserName, 
                                                          string title,
                                                          string caseType,
                                                          string caseSubtype,
                                                          string caseSubject,
                                                          string caseDescription,
                                                          string caseAccountName,
                                                          String AffiliationId,
                                                          String personId) {
        string caseStatus = 'New';  
        
        
        boolean accountSpecified = caseAccountName!='';  //This notes weather an account was specified  
        Case newCase = new Case();
            newCase.Status = caseStatus;
            newCase.Type = caseType;
            newCase.Sub_Type__c = caseSubtype;
            newCase.Subject = caseSubject;
            newCase.Description = caseDescription;
              
        User [] owner = null;
        if(OwnerUserName != null){
            if(!(OwnerUserName instanceof id)){
            
	            owner = [SELECT Id FROM User WHERE Username = :OwnerUserName];
	            
		        if (owner.size()==0) {
		            return false;
		        }
		        
		         newCase.OwnerID = owner[0].Id;
	          }else{
	          	newCase.OwnerId = OwnerUserName;
	          }
        }
        Account [] act = null;
        
        if (accountSpecified) { 
            act = [SELECT Id FROM Account WHERE Name = :caseAccountName];
            
            if (act.size()==0) {
                return false;
            }
        }
        
        
           
            
            if(AffiliationId != null && AffiliationId instanceof Id)
            	newCase.Contactid = AffiliationId;
            if(personId != null && personId instanceof Id)
            	newCase.Person__c = personId;
            
            if (accountSpecified) { 
                newCase.AccountId = act[0].Id;
            }
            
        insert newCase;     
        
        return true;                                        
    }
}