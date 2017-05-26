trigger SRMUserTrigger on User (after insert) {
    if(Trigger.isInsert){
        list<id> uid = new list<id>();
        Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId 
                                                FROM Profile where UserLicenseId  in 
                                                (SELECT Id FROM UserLicense where name ='Salesforce'
                                                  OR name ='Chatter Free')]);
        for(user uacct:trigger.new){
             if(profileIds.containskey(uacct.ProfileId ))
            {
            // Look for user license and filter only for Salesforce and Chatter License - TODO
            uid.add(uacct.id);
            }
        }
     SRMUserContactHandler.createNewStaffContact(uid);
    }
}