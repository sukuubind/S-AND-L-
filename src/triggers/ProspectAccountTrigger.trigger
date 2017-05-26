trigger ProspectAccountTrigger on Account (after insert, after update, before insert, 
before update) {

    List<Account> updatedAccountList = new List<Account>();
    
    updatedAccountList = [Select a.Id,a.Name,a.OwnerId  From Account a
                          where id in :trigger.new 
                          AND (a.RecordType.DeveloperName = 'Campus_Partner' 
                          OR a.RecordType.DeveloperName = 'SRP_Account')];
    
    if(updatedAccountList.size() > 0 && updatedAccountList != null)         
    {      
        if(trigger.isinsert && trigger.isAfter){
            ProspectTeamMemberTriggerHandler.createTeamforNewAccounts(updatedAccountList);
        }
    
        if(trigger.isupdate && trigger.isAfter)
        {
            ProspectTeamMemberTriggerHandler.updateTeamOwner(updatedAccountList);
        }
    } 
}