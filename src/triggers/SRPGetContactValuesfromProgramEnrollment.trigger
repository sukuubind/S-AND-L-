trigger SRPGetContactValuesfromProgramEnrollment on DeltakSRP__Program_Enrollment__c (after insert, after update) {
    
    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPGetContactValuesfromProgramEnrollment__c); 
    
    if(bypassTrigger)   return;  
    
    
    Set<Id> eIds = new Set<Id>();
    Set<id> affiliationIds = new Set<id>();
    Map<DeltakSRP__Program_Enrollment__c, Contact> enrollment_to_contact = new Map<DeltakSRP__Program_Enrollment__c, Contact>();
    Map<DeltakSRP__Program_Enrollment__c, List<DeltakSRP__Program_Enrollment__c>> SE_to_ListSE= new Map<DeltakSRP__Program_Enrollment__c, List<DeltakSRP__Program_Enrollment__c>>();
        
    if(Trigger.isUpdate) {
       
        Integer count = 0;
         for (DeltakSRP__Program_Enrollment__c enrollments: trigger.new) {
            /* if((trigger.new[count].Student_Affiliation__c != trigger.old[count].Student_Affiliation__c)
                 || (trigger.new[count].Drop_Date__c != trigger.old[count].Drop_Date__c)
                 || (trigger.new[count].Drop_Reason__c != trigger.old[count].Drop_Reason__c)
                 || (trigger.new[count].Program__r.Program_Title__c != trigger.old[count].Program__r.Program_Title__c)
                 || (trigger.new[count].Specialization__r.Spec_Title__c != trigger.old[count].Specialization__r.Spec_Title__c)
                 || (trigger.new[count].Start_Date__c != trigger.old[count].Start_Date__c)
                 || (trigger.new[count].Drop_Common_Uses__c != trigger.old[count].Drop_Common_Uses__c)
                 || (trigger.new[count].Drop_Sub_Categories__c != trigger.old[count].Drop_Sub_Categories__c)
                 || (trigger.new[count].Enrollment_Status__c != trigger.old[count].Enrollment_Status__c)) {*/
                     affiliationIds.add(enrollments.DeltakSRP__Enrolled_Student__c);
                     eIds.add(enrollments.Id);
            /* }*/
         }
         System.debug('--> EID = ' + eids);
      }  
      
      if(Trigger.isInsert) {
           for (DeltakSRP__Program_Enrollment__c enrollments: trigger.new) {
               affiliationIds.add(enrollments.DeltakSRP__Enrolled_Student__c);
               eIds.add(enrollments.Id);
           }
      } 
      
      Set <Contact> contactsToUpdate = new Set<Contact>();
      Map<id,Contact> contactsToUpdateMap = new Map<id,Contact>();
        
        DeltakSRP__Program_Enrollment__c [] programEnrollments = 
            [SElECT id,CreatedDate, DeltakSRP__Enrolled_Student__c , deltakSRP__Drop_Date__c, deltakSRP__Drop_Reason__c , deltaksrp__academic_Program__r.deltaksrp__Program_Title__c, DeltakSRP__Academic_Specialization__r.DeltakSRP__Specialization_Title__c , deltaksrp__Start_Date__c, 
            deltaksrp__Enrollment_Status__c, deltaksrp__Drop_category__c, Drop_Common_Uses__c, DeltakSRP__Do_Not_Register__c
            FROM DeltakSRP__Program_Enrollment__c 
            WHERE Id IN :eIds];
            
        DeltakSRP__Program_Enrollment__c [] siblingPE = [
            SELECT Id, CreatedDate, DeltakSRP__Enrolled_Student__c 
            FROM DeltakSRP__Program_Enrollment__c 
            WHERE DeltakSRP__Enrolled_Student__c IN :affiliationIds];
        
        for (DeltakSRP__Program_Enrollment__c enrollments: programEnrollments ) {
            List <DeltakSRP__Program_Enrollment__c> siblingSEList = new List <DeltakSRP__Program_Enrollment__c>();
            for (DeltakSRP__Program_Enrollment__c enrollmentsSiblings : siblingPE) {
                if (enrollments.DeltakSRP__Enrolled_Student__c == enrollmentsSiblings.DeltakSRP__Enrolled_Student__c) {
                    siblingSEList.add(enrollmentsSiblings);
                }
            }
            SE_to_ListSE.put(enrollments, siblingSEList);
        }
            
        /*Contact[]  associatedContact = [select deltaksrp__Drop_Date__c, deltaksrp__Drop_Reason__c, deltaksrp__academic_Program__c, deltaksrp___Academic_Specialization__c, deltaksrp__Start_Date__c, deltaksrp__Enrollment_Status__c, deltaksrp__Drop_Sub_Categories__c, deltaksrp__Drop_Common_Uses__c
                                                  from Contact
                                                  where Id IN :affiliationIds ];   */
        Contact[]  associatedContact = [select id,do_not_register__c
                                                  from Contact
                                                  where Id IN :affiliationIds ];                                          
        for (DeltakSRP__Program_Enrollment__c enrollments: programEnrollments ) {
            for (Contact c : associatedContact ) {
                if (enrollments.DeltakSRP__Enrolled_Student__c == c.Id) {
                    enrollment_to_contact.put(enrollments,c);
                    System.debug('Enrollments = ' + enrollments);
                }
            }  
        }
        
        System.debug('enrollment_to_contact --> '+ enrollment_to_contact);
        
        for (DeltakSRP__Program_Enrollment__c enrollments: programEnrollments )
        {
            List<DeltakSRP__Program_Enrollment__c> siblingsSE = SE_to_ListSE.get(enrollments);
            DateTime created = enrollments.CreatedDate;
            boolean updateContact = true;
            for (DeltakSRP__Program_Enrollment__c sibling : siblingsSE ) {
                if (sibling.CreatedDate > created) {
                    updateContact = false;
                }
            }
            
            if (updateContact) {
                Contact c = enrollment_to_contact.get(enrollments);
                c.Drop_Date__c = enrollments.deltaksrp__Drop_Date__c;
                c.Drop_Reason__c = enrollments.DeltakSRP__Drop_Reason__c;
                c.Start_Date__c = enrollments.deltaksrp__Start_Date__c;
                c.Enrollment_Status__c = enrollments.deltaksrp__Enrollment_Status__c;
                c.Drop_Sub_Categories__c = enrollments.DeltakSRP__Drop_Category__c;
                c.Drop_Common_Uses__c = enrollments.Drop_Common_Uses__c;
                c.Program__c = enrollments.DeltakSRP__Academic_Program__r.DeltakSRP__Program_Title__c;
                c.Specialization__c = enrollments.DeltakSRP__Academic_Specialization__r.DeltakSRP__Specialization_Title__c;
                c.Do_Not_Register__c = enrollments.deltaksrp__Do_Not_Register__c;
                contactsToUpdate.add(c);
                contactsToUpdateMap.put(c.id,c);
                
            }
        
        }                                       
        
        try{
           // update contactsToUpdate;
           update contactsToUpdateMap.values();
        }
        catch(Exception e) {
            System.debug(' Error: '+e);
        }      
}