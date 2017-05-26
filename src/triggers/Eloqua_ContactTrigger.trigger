trigger Eloqua_ContactTrigger on Contact (after delete, after insert, after update) {
    
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
      
    Set<Id> contactRecordsId = new Set<Id>();
    Set<String> emailList = new Set<String>();
    Map<String, List<Contact>> contactToEmailList = new Map<String, List<Contact>>();
    Map<String, Integer> shareCountMap = new Map<String, Integer>();
    Set<id> contactIdsWithNewEmailNullorEmpty = new Set<id>();
    Set<String> oldEmailswithValidNewEmail = new Set<String>();
    
    Set<String> oldEmailsWithNewEmailNullOrEmpty = new Set<String>(); 
    String ignoreEmail = 'none@smail.rasmussen.edu';
    
     //get the record types and put them in a map
     //added 10/28/11 - CB
    Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();             
    List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
    for (Schema.RecordTypeInfo rtInfo : RT) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() ); 
                
    }
    
    if(Trigger.isInsert){
        for(Contact c : Trigger.new){
            //added 10/28/11 - CB
            String RecTtype = c.RecordTypeId;
            System.Debug('RecordType on the Contact Record = '+RecTtype);
            if (RecTtype == '' || RecTtype == null || recordTypeName_to_recordTypeId.get('Deltak Student') == RecTtype) {
                if(c.Email != null && c.Email != '')
                    emailList.add(c.Email);
            }           
        }
    }
    System.Debug('VS -- Initial Email list---'+emailList);
    if(Trigger.isUpdate){
        Integer count = 0;
        while(count < Trigger.new.size()){
            //added 10/28/11 - CB
            String RecTtype = trigger.new[count].RecordTypeId;
            if (RecTtype == '' || RecTtype == null || recordTypeName_to_recordTypeId.get('Deltak Student') == RecTtype) {
                String newEmail = Trigger.new[count].Email;
                String oldEmail = Trigger.old[count].Email;
                if(newEmail != oldEmail){
                    if(newEmail != null && newEmail != ''){
                        emailList.add(newEmail);
                        if(oldEmail != null && oldEmail != ''){
                            oldEmailswithValidNewEmail.add(oldEmail);
                        }
                    }
                    if(newEmail == null || newEmail == ''){
                        oldEmailsWithNewEmailNullOrEmpty.add(oldEmail);
                        contactIdsWithNewEmailNullorEmpty.add(Trigger.new[count].id);
                    }
                }                
            }
            
            count++;
        }
    }
    if(Trigger.isDelete){
        for(Contact c : Trigger.old){
            //added 10/28/11 - CB
            String RecTtype = c.RecordTypeId;
            if (RecTtype == '' || RecTtype == null || recordTypeName_to_recordTypeId.get('Deltak Student') == RecTtype) {
                if(c.Email != null && c.Email != ''){
                    emailList.add(c.Email);
                }
            }
            
        }
    }
    
    if(Trigger.isDelete){
        List<Contact> contactList = [Select id,
                                            Share_Count__c
                                        From Contact
                                        Where email IN :emailList
                                    ];
        Map<id, Integer> shareCountMap1 = new Map<Id, Integer>();
        for(Contact contact1 : contactList){
            if(contact1.Share_Count__c > 0){
                shareCountMap1.put(contact1.Id, Integer.valueOf(String.valueOf(contact1.Share_Count__c)) - 1);
            }
        }
        if(shareCountMap1 != null && shareCountMap1.size() > 0){
                EloquaShareCountPersister.updateShareCount(shareCountMap, shareCountMap1);
        }
        
    }
    
    
    if(Trigger.isUpdate){
        // New Email is null or empty scenario
        List<Contact> unanimousContactList =    [Select id,
                                                        Email,
                                                        Share_Count__c 
                                                        From Contact
                                                        where Id IN :contactIdsWithNewEmailNullorEmpty
                                                        or email IN :emailList
                                                        or email IN :oldEmailsWithNewEmailNullOrEmpty
                                                        or email IN :oldEmailswithValidNewEmail
                                                  ];
        List<Contact> contactListWithNewEmailNullOrEmpty = new List<Contact>();
        List<Contact> contactsFornewUpdatedEmailList = new List<Contact>();
        List<Contact> contactListofOldEmailWithNewEmailNullOrEmpty = new List<Contact>();
        List<Contact> contactListOfOldEmailsWithValidNewEmail = new List<Contact>();
        
        for(Contact thisContact : unanimousContactList){
            if(contactIdsWithNewEmailNullorEmpty.contains(thisContact.id)){
                contactListWithNewEmailNullOrEmpty.add(thisContact);
            }else if(emailList.contains(thisContact.Email)){
                contactsFornewUpdatedEmailList.add(thisContact);
            }else if(oldEmailsWithNewEmailNullOrEmpty.contains(thisContact.Email)){
                contactListofOldEmailWithNewEmailNullOrEmpty.add(thisContact);
            }else if(oldEmailswithValidNewEmail.contains(thisContact.Email)){
                contactListOfOldEmailsWithValidNewEmail.add(thisContact);
            }
        }
        
        // Set the share count to zero for the records with new email is empty or null
        Map<id, Integer> shareCountMap1 = new Map<Id, Integer>();
        for(Contact contact1 : contactListWithNewEmailNullOrEmpty){
            shareCountMap1.put(contact1.Id, 0);
        }
        
        for(Contact contact2 : contactListofOldEmailWithNewEmailNullOrEmpty){
            shareCountMap.put(contact2.Email, Integer.valueOf(String.valueOf(contact2.Share_Count__c)) - 1);
        } 
        
        // TO DO : Decrement the share count for Update when email is changed from one valid old email to another valid new email
            System.Debug('VS -- Contact List of Old Emails with valid new email --- '+contactListOfOldEmailsWithValidNewEmail);
            for(Contact contact3 : contactListOfOldEmailsWithValidNewEmail){
                if(contact3.Share_Count__c > 0)
                    shareCountMap.put(contact3.Email, Integer.valueOf(String.valueOf(contact3.Share_Count__c)) - 1);
            }
        
        // Find all the contacts with similar emails and set the share count appropriately. The following logic is similar to isInsert
        for(Contact c : contactsFornewUpdatedEmailList){
            List<Contact> IdContactList = null;
            if(contactToEmailList != null && contactToEmailList.containsKey(c.Email)){
                IdContactList = contactToEmailList.get(c.Email);
            }else{
                IdContactList = new List<Contact>();
             }
            IdContactList.add(c);
            contactToEmailList.put(c.Email, IdContactList); 
        }   
        System.Debug('VS --- ContactToEMailList---'+contactToEmailList);
            // construct the share count map to pass to sharecountpersister
            if(contactToEmailList != null && contactToEmailList.size() > 0){
                for(String thisEmail : contactToEmailList.keySet()){
                    
                        
                        List<Contact> contactsForThisEmail = contactToEmailList.get(thisEmail);
                        Integer shareCount = contactsForThisEmail.size();
                        if(shareCount > 0){
                            shareCount = shareCount - 1;
                        }
                        shareCountMap.put(thisEmail, shareCount);
                    
                }
                System.Debug('VS --- Share Count Map --- '+shareCountMap);
                
            }
            if((shareCountMap != null && shareCountMap.size() > 0) || (shareCountMap1 != null && shareCountMap1.size() > 0))
                EloquaShareCountPersister.updateShareCount(shareCountMap, shareCountMap1);
            
    }
    
    
    if(Trigger.isInsert){
        // find all contacts with email address from the DML operation
    List<Contact> contactListByEmail = [Select Id
                                              ,Email
                                            From Contact
                                            where Email IN :emailList
                                        ];
        System.Debug('contactListByEmail ---- VS -- '+contactListByEmail);
        if(contactListByEmail != null && contactListByEmail.size() > 0){
            for(Contact c : contactListByEmail){
                if(c.EMail != null){ // We only care about non-null email addresses
                    List<Contact> IdContactList = null;
                    if(c.Email != ''){ // If email is not empty count towards logic
                        if(contactToEmailList != null && contactToEmailList.containsKey(c.Email)){
                             IdContactList = contactToEmailList.get(c.Email);
                             
                        }else{
                             IdContactList = new List<Contact>();
                            
                        }
                    IdContactList.add(c);
                    }else{ // if email is an empty string, make sure we default to zero
                        IdContactList = new List<Contact>();
                    }
                contactToEmailList.put(c.Email, IdContactList);
                }
            }
        }
        System.Debug('VS --- ContactToEMailList---'+contactToEmailList);
        // construct the share count map to pass to sharecountpersister
        if(contactToEmailList != null && contactToEmailList.size() > 0){
            for(String thisEmail : contactToEmailList.keySet()){
                List<Contact> contactsForThisEmail = contactToEmailList.get(thisEmail);
                Integer shareCount = contactsForThisEmail.size();
                if(shareCount > 0){
                    shareCount = shareCount - 1;
                }
                shareCountMap.put(thisEmail, shareCount);
            }
        System.Debug('VS --- Share Count Map --- '+shareCountMap);
        Map<id, Integer> shareCountMap1 = new Map<Id, Integer>();
        EloquaShareCountPersister.updateShareCount(shareCountMap, shareCountMap1);
        
        }
                                        
    }
}