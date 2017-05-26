trigger CaseTrigger on Case (before insert, before update) {
    
    String currentProfileId = userinfo.getProfileId();
    currentProfileId = currentProfileId.substring(0, 15);
    List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
    Set<String> srpProfiles = new Set<String>();
    SRPProfilesList = SRP_Profiles_List__c.getall().values();
    for(SRP_Profiles_List__c spl: SRPProfilesList){
        srpProfiles.add(spl.ProfileId__c);
    }
    system.debug('Before SRP Profile Check>>>>');
    if(srpProfiles.contains(currentProfileId))
        return; 
    system.debug('After SRP Profile check>>>> ');
   User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
   if (!loggedInUser.Profile.Name.contains('Integration')) {
   
        Set<id> caseIdsNew = new Set<id>();
        
        //get a set of all the trigger records
        for(Case c : Trigger.new) {     
            caseIdsNew.add(c.ContactId);  
        }
        
        //create a list of all contacts that are associated with the list of triggers    
        Contact [] contacts = [SELECT Id, Person__r.Id 
                               FROM Contact
                               WHERE Id IN :caseIdsNew];
        
        System.debug('+++ contacts # '+contacts.size());    
        
        for (integer i=0; i<Trigger.size; i++) {
            
            //if the contact Id is not null, make the person lookup null and continue to the next Case
            if (trigger.new[i].ContactId == null) {
                 System.debug('+++ ContactID is null, set person lookup to null ');
                trigger.new[i].Person__c = null;
                continue;
            }
            
            //if the contactID is not null and it has changed, find out which contact is associated with this Case and 
            //set the person lookup on the case to the same one as the assocaited contact       
            if (trigger.isUpdate) {     
                if (trigger.new[i].ContactId != null &&
                    trigger.new[i].ContactId != trigger.old[i].ContactId) {
                    System.debug('+++ ContactID changed ');
                    for (Contact c : contacts) {
                        if (trigger.new[i].ContactId == c.Id) {                 
                            trigger.new[i].Person__c = c.Person__r.Id;                  
                            System.debug('+++ Update ' + trigger.new[i].Id + 'With Person Id '+ c.Person__r.Id);                
                        }
                    }
                }
            }
            
            if (trigger.isInsert) {     
                if (trigger.new[i].ContactId != null) {             
                    for (Contact c : contacts) {
                        if (trigger.new[i].ContactId == c.Id) {                 
                            trigger.new[i].Person__c = c.Person__r.Id;                  
                            System.debug('+++ Insert ' + trigger.new[i].Id + 'With Person Id '+ c.Person__r.Id);                
                        }
                    }
                }
            }
        }
   }
}