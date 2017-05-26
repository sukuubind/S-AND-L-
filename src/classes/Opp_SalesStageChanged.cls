public class Opp_SalesStageChanged {
    
    
    public static Student_Enrollment__c populateEnrollmentRecord(Opportunity newRecord, 
                                                            Student_Enrollment__c enrollment, 
                                                            Boolean create,
                                                            Map <Id, String> campusId_to_CampusAbbrev){
        final string str_Fully_Committed = 'Fully Admitted';
        final string str_New = 'New';
        
        final string str_New_Provisional = 'New-Provisional';
        final string str_Provisional = 'Provisional';
        
        final string str_Conditional  = 'Conditional';
        final string str_New_Conditional  = 'New-Conditional';      
         
                string programAbbreviation = newrecord.Program_Abbrev__c;
                string schoolAbbreviation = campusId_to_CampusAbbrev.get(newrecord.AccountID);
                Date startDate = newRecord.Start_Date__c;
                            
                string startDateStr;                    
                if (newRecord.Start_Date__c != null) {
                    startDateStr = startDate.year() + '|' +  startDate.month() + '|' + startDate.day();
                }
                if(enrollment.id == null)
                    enrollment.Student_Affiliation__c = newrecord.Student__c;
                enrollment.Program__c = newrecord.Program__c;
                enrollment.Start_Date__c = newrecord.Start_Date__c;
                enrollment.Opportunity__c = newrecord.Id;
                enrollment.Specialization__c = newrecord.Specialization__c;            
                enrollment.Academic_Start_Date__c = newrecord.Academic_Start_Date__c;
                
                //******************************************************
                //START extra logic added for Deltak SIS release 8/2/11 - CB
                //******************************************************
                //If Acceptance Status = Fully Committed, then update Enrollment Status field on Student Enrollment object to New
                if (newRecord.Acceptance_Status__c == str_Fully_Committed) {
                    enrollment.Enrollment_Status__c =  str_New ;
                }
                
                //If Acceptance Status = Provisional, then update Enrollment Status field on Student Enrollment object to New-Provisional
                if (newRecord.Acceptance_Status__c ==  str_Provisional ) {
                    
                    enrollment.Enrollment_Status__c = str_New_Provisional ;
                    
                    //Additionally, pull over Provisional Reason value to New-Provisional Reason field on Student Enrollment object
                    enrollment.New_Provisional_Reason__c  = newrecord.Provisional_Reason__c; 
                }
                
                //Acceptance Status = Conditional, then update Enrollment Status field on Student Enrollment object to New-Conditional
                if (newRecord.Acceptance_Status__c ==  str_Conditional) {
                    enrollment.Enrollment_Status__c =  str_New_Conditional ;
                    enrollment.New_Conditional_Reason__c =
                     newRecord.Conditional_Reason__c;
                }
                //******************************************************
                // END extra logic added for Deltak SIS release 8/2/11 - CB
                //******************************************************
                
                //**********************************************************
                // CB - Add Wachment Student field - Start
                //**********************************************************
                enrollment.Wachman_Scholarship_Student__c = newRecord.Wachman_Student__c;
                //**********************************************************
                // CB - Add Wachment Student field - End
                //**********************************************************
                
                if(create)
                    enrollment.Name = schoolAbbreviation + ' / ' + programAbbreviation + ' / ' + startDateStr;
                
        return enrollment;
    }
    
    public static List<Student_Enrollment__c> salesStageChanged (List <Opportunity> newOpps) {
        
        List<Student_Enrollment__c> finalEnrollmentList = new List<Student_Enrollment__c>();
        List<Student_Enrollment__c> insertEnrollmentList = new List<Student_Enrollment__c>();
        List<Student_Enrollment__c> updateEnrollmentList = new List<Student_Enrollment__c>();
                
        Campus_Contacts__c [] campusContacts;    
        Program_Responsibility__c [] prgmResponsibility;
        Account [] accts;
        
        Map <Id, Id> Campus_to_employeeID = new Map<Id, Id>();
        Set<Id> prgmResponsibilitySetId = new Set<id>();
        Set<Id> prgmResponsibilitySetCC = new Set<id>();
        Set<String> prgmResponsibilitySetProgram = new Set<String>();
        Set<id> newIds = new Set<id>();
        
        Map<Id,Id> prgmResponsibilityMap = new Map<id,Id>();
        Map<Id,Id> account_to_OwnerIDyMap = new Map<id,Id>();
        Map<Id,String> prgmResponsibilitybyProgramMap = new Map<id,String>();
        Map <Id, Student_Enrollment__c> enrollmentID_to_enrollment_map = new Map<Id, Student_Enrollment__c>();
        
        Map <Id, String> campusId_to_CampusAbbrev = new Map<Id, String>();
        
        for(Opportunity o : newOpps) {    
            newIds.add(o.Id);
        }
         
        //System.debug('OpportunityTrigger - Stage changed to Start - Create Enrollment record...');
        Student_Enrollment__c [] studentEnrollments = [
            SELECT Id, Opportunity__c 
            FROM Student_Enrollment__c 
            WHERE Opportunity__c IN :newIds];
            
       // System.debug('OpportunityTrigger - number of student enrollments ' + studentEnrollments.size());
        
        for (Student_Enrollment__c e : studentEnrollments) {
            enrollmentID_to_enrollment_map.put(e.Id, e);
        }
        
        
        
        //get the OwnerIDs of users who are 
        campusContacts = [SELECT Id, Organization__c, Employee__r.Id 
                                    FROM Campus_Contacts__c
                                    WHERE Title__c = 'Student Services Coordinator'
                                    AND Active_User__c = 'ACTIVE'
                                    /*AND Organization__c = :accountId*/];
        
        prgmResponsibility = [SELECT Id, Campus_Contacts__c, Academic_Program__r.Abbrev__c
                                                               FROM Program_Responsibility__c
                                                               /*where Campus_Contacts__r.Organization__c = :accountId*/]; 
        
        accts = [SELECT ID, Abbreviation__c, OwnerID FROM Account];
        
        //get the owner of the campuses. This is used to set the owner of newly created enrollment records if the code
        //cannot find an owner in the program responsibilities  
      //  System.debug('OpportunityTrigger - creating map of accoutns and owners...');        
        for (Account a : accts) {
            account_to_OwnerIDyMap.put(a.Id, a.OwnerId);
            System.debug('OpportunityTrigger - Added owner '+a.ownerID+' for account ' + a.id +' to map...');
            campusId_to_CampusAbbrev.put(a.Id, a.Abbreviation__c);     
            System.debug('OpportunityTrigger - Added abrieviation '+a.Abbreviation__c+' for account ' + a.id +' to map...');
        }
         
        // System.debug('OpportunityTrigger - Set the program responsibility maps...');        
        //Set the program responsibility maps
        for (Program_Responsibility__c p : prgmResponsibility) {
            prgmResponsibilityMap.put(p.Campus_Contacts__c, p.Id);           
            prgmResponsibilitybyProgramMap.put(p.Campus_Contacts__c, p.Academic_Program__c);
            prgmResponsibilitySetId.add(p.Id);
            prgmResponsibilitySetCC.add(p.Campus_Contacts__c);
            prgmResponsibilitySetProgram.add(p.Academic_Program__r.Abbrev__c);
        }
        
            CreateEnrollmentRecord createEnrollment = null;
            createEnrollment = new CreateEnrollmentRecord(campusContacts,
                Campus_to_employeeID,               
                prgmResponsibilitySetCC,
                prgmResponsibilitySetProgram,
                prgmResponsibilitybyProgramMap,
                account_to_OwnerIDyMap);
            System.debug('Entering For Loop --- '+newOpps.size());  
        for (integer record = 0; record < newOpps.size(); record++) {
            Opportunity newRecord = newOpps[record];
            
                        
            if (newRecord.Student_Enrollment__c == null) {
                Student_Enrollment__c enrollment = new Student_Enrollment__c();
                
                
                     
                Boolean create = true;
                enrollment = populateEnrollmentRecord(newRecord, enrollment, create, campusId_to_CampusAbbrev);           
                
                            
                Id OwnerID = createEnrollment.enrollmentOwner(
                    newrecord.Program__c, 
                    newrecord.AccountId);
                            
                insertEnrollmentList.add(enrollment);          
                System.Debug('Record # -- '+record);
                        
                //set the opportunity's lookup the newly created enrollment record
                newRecord.Student_Enrollment__c = enrollment.Id;
            }
                   
            //There is already a student enrollment assocaited with this opportunity
            else {
                Student_Enrollment__c enrollment = enrollmentID_to_enrollment_map.get(newRecord.Student_Enrollment__c);
                if (enrollment == null) {
                //  System.debug('OpportunityTrigger - could not find enrollment record ('+newRecord.Student_Enrollment__c+') in enrollmentID_to_enrollment_map '+enrollmentID_to_enrollment_map);
                }
                        
                else {
                    Boolean create = true;
                enrollment = populateEnrollmentRecord(newRecord, enrollment, create, campusId_to_CampusAbbrev);
                            
                    
                            
                    
                    Id OwnerID = createEnrollment.enrollmentOwner(
                        campusContacts, 
                        Campus_to_employeeID, 
                        prgmResponsibilitySetCC, 
                        prgmResponsibilitySetProgram, 
                        prgmResponsibilitybyProgramMap, 
                        account_to_OwnerIDyMap, 
                        newrecord.Program__c, 
                        newrecord.AccountId);
                            
                       
                        updateEnrollmentList.add(enrollment);
                    }
            } // end if there is already an enrollment created for this opportunity
        }
        
        try {
            insert insertEnrollmentList;
        }
        catch (Exception e) {
            System.debug('Error inserting Enrollment List ' + insertEnrollmentList + '. Error = ' + e );
        }
        
        try {
            update updateEnrollmentList;
        }
        catch (Exception e) {
            System.debug('Error inserting Enrollment List ' + updateEnrollmentList + '. Error = ' + e );
        }
        
        finalEnrollmentList.addAll(insertEnrollmentList);
        finalEnrollmentList.addAll(updateEnrollmentList);
        
        //update the opportunities with the enrollment records
        
        System.debug('finalEnrollmentList = ' + finalEnrollmentList);
        System.debug('newOpps = ' + newOpps);
        
        
        System.Debug('Updating opportunities with the enrollment lookup');              
        for (Student_Enrollment__c enrollment : finalEnrollmentList) {
            for (Opportunity opp : newOpps) {
                if (opp.Id == enrollment.Opportunity__c) {
                    opp.Student_Enrollment__c = enrollment.Id;
                    //opportunities_to_update.add(opp);
                }
            }
        }   
            
        return finalEnrollmentList;
    }

}