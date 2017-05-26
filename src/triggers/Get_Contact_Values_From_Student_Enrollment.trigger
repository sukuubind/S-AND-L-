trigger Get_Contact_Values_From_Student_Enrollment on Student_Enrollment__c (after update, after insert) {
	
	String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
	
    Set<Id> eIds = new Set<Id>();
    Set<id> affiliationIds = new Set<id>();
    Map<Student_Enrollment__c, Contact> enrollment_to_contact = new Map<Student_Enrollment__c, Contact>();
    Map<Student_Enrollment__c, List<Student_Enrollment__c>> SE_to_ListSE= new Map<Student_Enrollment__c, List<Student_Enrollment__c>>();
        
    if(Trigger.isUpdate) {
       
        Integer count = 0;
         for (Student_Enrollment__c enrollments: trigger.new) {
            /* if((trigger.new[count].Student_Affiliation__c != trigger.old[count].Student_Affiliation__c)
                 || (trigger.new[count].Drop_Date__c != trigger.old[count].Drop_Date__c)
                 || (trigger.new[count].Drop_Reason__c != trigger.old[count].Drop_Reason__c)
                 || (trigger.new[count].Program__r.Program_Title__c != trigger.old[count].Program__r.Program_Title__c)
                 || (trigger.new[count].Specialization__r.Spec_Title__c != trigger.old[count].Specialization__r.Spec_Title__c)
                 || (trigger.new[count].Start_Date__c != trigger.old[count].Start_Date__c)
                 || (trigger.new[count].Drop_Common_Uses__c != trigger.old[count].Drop_Common_Uses__c)
                 || (trigger.new[count].Drop_Sub_Categories__c != trigger.old[count].Drop_Sub_Categories__c)
                 || (trigger.new[count].Enrollment_Status__c != trigger.old[count].Enrollment_Status__c)) {*/
                     affiliationIds.add(enrollments.Student_Affiliation__c);
                     eIds.add(enrollments.Id);
            /* }*/
         }
         System.debug('--> EID = ' + eids);
      }  
      
      if(Trigger.isInsert) {
           for (Student_Enrollment__c enrollments: trigger.new) {
               affiliationIds.add(enrollments.Student_Affiliation__c);
               eIds.add(enrollments.Id);
           }
      } 
      
      List <Contact> contactsToUpdate = new List<Contact>();
        
        Student_Enrollment__c [] studentEnrollments = 
            [SElECT CreatedDate, Student_Affiliation__c , Drop_Date__c, Drop_Reason__c , Program__r.Program_Title__c, Specialization__r.Spec_Title__c , Start_Date__c, 
            Enrollment_Status__c, Drop_Sub_Categories__c, Drop_Common_Uses__c, Do_Not_Register__c
            FROM Student_Enrollment__c 
            WHERE Id IN :eIds];
            
        Student_Enrollment__c [] siblingSE = [
            SELECT Id, CreatedDate, Student_Affiliation__c 
            FROM Student_Enrollment__c 
            WHERE Student_Affiliation__c IN :affiliationIds];
        
        for (Student_Enrollment__c enrollments: studentEnrollments ) {
            List <Student_Enrollment__c> siblingSEList = new List <Student_Enrollment__c>();
            for (Student_Enrollment__c enrollmentsSiblings : siblingSE) {
                if (enrollments.Student_Affiliation__c == enrollmentsSiblings.Student_Affiliation__c) {
                    siblingSEList.add(enrollmentsSiblings);
                }
            }
            SE_to_ListSE.put(enrollments, siblingSEList);
        }
            
        Contact[]  associatedContact = [select Drop_Date__c, Drop_Reason__c, Program__c, Specialization__c, Start_Date__c, Enrollment_Status__c, Drop_Sub_Categories__c, Drop_Common_Uses__c
                                                  from Contact
                                                  where Id IN :affiliationIds ];   
        for (Student_Enrollment__c enrollments: studentEnrollments ) {
            for (Contact c : associatedContact ) {
                if (enrollments.Student_Affiliation__c == c.Id) {
                    enrollment_to_contact.put(enrollments,c);
                    System.debug('Enrollments = ' + enrollments);
                }
            }  
        }
        
        System.debug('enrollment_to_contact --> '+ enrollment_to_contact);
        
        for (Student_Enrollment__c enrollments: studentEnrollments )
        {
            List<Student_Enrollment__c> siblingsSE = SE_to_ListSE.get(enrollments);
            DateTime created = enrollments.CreatedDate;
            boolean updateContact = true;
            for (Student_Enrollment__c sibling : siblingsSE ) {
                if (sibling.CreatedDate > created) {
                    updateContact = false;
                }
            }
            
            if (updateContact) {
                Contact c = enrollment_to_contact.get(enrollments);
                c.Drop_Date__c = enrollments.Drop_Date__c;
                c.Drop_Reason__c = enrollments.Drop_Reason__c;
                c.Start_Date__c = enrollments.Start_Date__c;
                c.Enrollment_Status__c = enrollments.Enrollment_Status__c;
                c.Drop_Sub_Categories__c = enrollments.Drop_Sub_Categories__c;
                c.Drop_Common_Uses__c = enrollments.Drop_Common_Uses__c;
                c.Program__c = enrollments.Program__r.Program_Title__c;
                c.Specialization__c = enrollments.Specialization__r.Spec_Title__c;
               c.Do_Not_Register__c = enrollments.Do_Not_Register__c;
                contactsToUpdate.add(c);
            }
        
        }                                       
        
        try{
            update contactsToUpdate;
        }
        catch(Exception e) {
            System.debug(' Error: '+e);
        }      
    
}