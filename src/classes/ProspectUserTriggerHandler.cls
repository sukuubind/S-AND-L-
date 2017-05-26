public without sharing class ProspectUserTriggerHandler {
    public static void handleBeforeInsert(List<User> newUserList){
        
    }
    public static void handleAfterInsert(List<User> newUserList){
        
    }
    public static void handleBeforeUpdate(List<User> newUserList, List<User> oldUserList){
        List<Id> userIdList = new List<Id>();
        for(Integer i = 0; i < newUserList.size(); i++){
            User newUser = newUserList[i];
            User oldUser = oldUserList[i];
            
            if(newUser.IsActive == false && oldUser.isActive == true){
                newUser.Prospect_Inactive__c = true;
                userIdList.add(newUser.id);
            }
        }
        if(userIdList.size()>0)
        {
            List<Team_Member__c> teamMemberList = [Select Id, Allocation__c,Which_Team__c from Team_Member__c where Who_Id__c IN :userIdList];
            List<Id> teamMemberListDelete = new List<Id>();
            
            
            
            for(Team_Member__c tm : teamMemberList){
                teamMemberListDelete.add(tm.id);
            }
            
            if(teamMemberListDelete != null && teamMemberListDelete.size() > 0){
                ProspectTeamMemberBatchDelete proBatch = new ProspectTeamMemberBatchDelete(teamMemberListDelete); 
                String cronID = System.scheduleBatch(proBatch, 'ProspectTeamMemberBatchDelete'+System.now(), 1, 100);
            }
        }
    }
   
}