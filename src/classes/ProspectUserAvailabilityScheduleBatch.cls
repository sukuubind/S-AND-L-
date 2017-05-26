global without sharing class ProspectUserAvailabilityScheduleBatch implements Database.Batchable<SObject> {
    global String query = '';
    public ProspectUserAvailabilityScheduleBatch(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.isRunningTest())
        {
        	this.query = this.query + ' limit 2';
        }
        
        return Database.getQueryLocator(this.query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){
            
        List<Team_Member_Availability__c> scopeList = (List<Team_Member_Availability__c>)scope;
             
        if(scopeList!=null && scopeList.size()>0)
        {
            List<String> userList = new List<String>();
            Map<String, Boolean> userAvailabilityMap = new Map<String, Boolean>();
            List<Team_Member_Availability__c> tmaUpdateBefore = new List<Team_Member_Availability__c>();
            //List<Team_Member_Availability__c> teamMemberAvblList = [Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c from Team_Member_Availability__c where Process_this_availability__c = true];
            for(Team_Member_Availability__c tma: scopeList)
            {
                userList.add(tma.Which_user__c);
                userAvailabilityMap.put(tma.Which_user__c, tma.Is_Team_Member_Available__c);
                Team_Member_Availability__c tmaUpd = new Team_Member_Availability__c(id=tma.id);
                if(tma.Widget_Override__c)
                {
                    tmaUpd.Widget_Override__c = false;
                    tmaUpdateBefore.add(tmaUpd);
                }
            }
            if(tmaUpdateBefore.size()>0)
            {
                Database.update(tmaUpdateBefore, false);
            }
            // Querying explicitly to send to Non-Future method - Allocation distribution; this duplicate query and List are needed to avoid Object by reference error.
            List<Team_Member__c> teamMemberOldList = new List<Team_Member__c>();
            if(userList!=null && userList.size()>0)
            {
                teamMemberOldList = [Select t.Who_Id__c, t.Which_Team__c, t.Team_Name__c, t.SystemModstamp, t.Name, t.Member_Name__c, t.LastModifiedDate, t.LastModifiedById, t.Is_Team_Active__c, t.IsDeleted, t.Id, t.ESC_Exempt__c, t.CreatedDate, t.CreatedById, t.Allocation__c, t.Allocation_Counter__c, t.Active__c From Team_Member__c t where t.Who_Id__c in :userList];
                system.debug('teamMemberOldList-->'+teamMemberOldList);
            }   
            
            List<Team_Member__c> teamMemberList = new List<Team_Member__c>();
            
            if(userList!=null && userList.size()>0)
            {
                teamMemberList = [Select t.Who_Id__c, t.Which_Team__c, t.Team_Name__c, t.SystemModstamp, t.Name, t.Member_Name__c, t.LastModifiedDate, t.LastModifiedById, t.Is_Team_Active__c, t.IsDeleted, t.Id, t.ESC_Exempt__c, t.CreatedDate, t.CreatedById, t.Allocation__c, t.Allocation_Counter__c, t.Active__c From Team_Member__c t where t.Who_Id__c in :userList];
                system.debug('teamMemberList-->'+teamMemberList);
                
                List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
                List<User> usersToUpdate = new List<User>();
                Map<Id, List<Team_Member__c>> whoIdToTeamMember = new Map<Id, List<Team_Member__c>>();
                for(Team_Member__c thisMember : teamMemberList){
                    List<Team_Member__c> teamMemberTempList = new List<Team_Member__c>();
                    if(whoIdToTeamMember != null && whoIdToTeamMember.containsKey(thisMember.Who_Id__c)){
                        teamMemberTempList = whoIdToTeamMember.get(thisMember.Who_Id__c);
                    }
                    teamMemberTempList.add(thisMember);
                    whoIdToTeamMember.put(thisMember.Who_Id__c, teamMemberTempList);
                }
                for(String usr: userList)
                {
                    if(whoIdToTeamMember != null && whoIdToTeamMember.containsKey(usr)){
                        List<Team_Member__c> teamMembersTemp = whoIdToTeamMember.get(usr);
                        Boolean checkboxVF = userAvailabilityMap.get(usr);
                        for(Team_Member__c thisMember : teamMembersTemp){
                            thisMember.Active__c = checkboxVF;
                            teamMembersToUpdate.add(thisMember);
                        }
                    }
                }
                
                
                if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
                    update teamMembersToUpdate;
                }
            
            
                // Change Process_this_availability__c to false for processed records.
                List<Team_Member_Availability__c> tmaUpdateList = new List<Team_Member_Availability__c>();
                List<Team_Member_Availability__c> afterUpdList = [Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c from Team_Member_Availability__c where Which_user__c in: userList];
                for(Team_Member_Availability__c tmaUpd: afterUpdList)
                {
                    Team_Member_Availability__c tma = new Team_Member_Availability__c(id=tmaUpd.id);
                    if(tmaUpd.Widget_Override__c)
                    {
                        tma.Widget_Override__c = false;
                    }
                    else
                    {
                        tma.Process_this_availability__c = false;
                    }
                    tmaUpdateList.add(tma);
                }
                
                if(tmaUpdateList != null && tmaUpdateList.size() > 0){
                        update tmaUpdateList;
                    }
                
                List<Team_Member__c> teamMemberAfterList = [Select t.Who_Id__c, t.Which_Team__c, t.Team_Name__c, t.SystemModstamp, t.Name, t.Member_Name__c, t.LastModifiedDate, t.LastModifiedById, t.Is_Team_Active__c, t.IsDeleted, t.Id, t.ESC_Exempt__c, t.CreatedDate, t.CreatedById, t.Allocation__c, t.Allocation_Counter__c, t.Active__c From Team_Member__c t where t.Who_Id__c in :userList];
                system.debug('teamMemberList-->'+teamMemberOldList);
                system.debug('teamMemberAfterList-->'+teamMemberAfterList);
                
                ProspectTeamMemberTriggerHandler.setFieldHistoryTracking(teamMemberAfterList, teamMemberOldList);
                ProspectTeamMemberTriggerHandler.distributeAllocationCounterToOthersNonFuture(teamMemberAfterList, teamMemberOldList);
                
            }
        }
    
    }
        
     global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest())
        {
	         Prospect_User_Availability_Setting__c setting = Prospect_User_Availability_Setting__c.getInstance(); 
	         Integer BATCH_SIZE = Integer.valueOf(setting.User_Avbl_Batch_Size__c);
	         Integer MINUTES_FROM_NOW = Integer.valueOf(setting.User_Avbl_Schedule__c);
	         String query = ProspectConstants.USER_AVBL_QUERY;
	         ProspectUserAvailabilityScheduleBatch proUABatch = new ProspectUserAvailabilityScheduleBatch(query);
	         String cronID = System.scheduleBatch(proUABatch, 'ProspectUserAvailabilityScheduleBatch-'+System.now(), MINUTES_FROM_NOW, BATCH_SIZE);
        }
    }
}