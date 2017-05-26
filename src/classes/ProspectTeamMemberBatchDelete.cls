global without sharing class ProspectTeamMemberBatchDelete implements Database.Batchable<SObject> {
    global final string query;
    private final List<Id> ids;
    global ProspectTeamMemberBatchDelete (String q)
    {
       query = q;
    }
    global ProspectTeamMemberBatchDelete(List<Id> ids){
        this.ids = ids;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
       return Database.getQueryLocator([Select id, Which_Team__c, Allocation__c, Who_Id__c
                                    From Team_Member__c
                                    Where id in :this.ids ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id, Double> percentToDistribute = new Map<id, Double>();
        List<Team_Member__c> tmToDelete = new List<Team_Member__c>();
        List<id> userIds = new List<id>();
        for(sObject thisTMember_sObject : scope){
            Double thisDouble = Double.valueOf(0);
            
            Team_Member__c thisTMem = (Team_Member__c)thisTMember_sObject;
            
            if(percentToDistribute != null && percentToDistribute.containsKey(thisTMem.Which_Team__c)){
                thisDouble = percentToDistribute.get(thisTMem.Which_Team__c);
            }
            System.Debug('thisDouble -- '+thisDouble);
            thisDouble = thisDouble + (thisTMem.Allocation__c != null ? thisTMem.Allocation__c : 0);
            percentToDistribute.put(thisTMem.Which_Team__c, thisDouble);
            
            tmToDelete.add(thisTMem);
            userIds.add(thisTMem.Who_Id__c);
        }
        
        delete tmToDelete;
        if(percentToDistribute != null && percentToDistribute.size() > 0){
            Map<id, Double> teamToAllocationCounter = percentToDistribute;
            Boolean allocation = true;
            
        List<Team_Member__c> teamMemberList = [Select Id, Allocation_Counter__c, 
                                                      Active__c, Which_Team__c , Allocation__c
                                                 from Team_Member__c 
                                                 where Which_Team__c IN :teamToAllocationCounter.keySet() 
                                                 and Active__c = true];
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberList = new Map<id, List<Team_Member__c>>();
        for(Team_Member__c thisTeamMember : teamMemberList){
            List<Team_Member__c> teamMemberTemp = new List<Team_Member__c>();
            if(teamIdToTeamMemberList != null && teamIdToTeamMemberList.containsKey(thisTeamMember.Which_Team__c)){
                teamMemberTemp = teamIdToTeamMemberList.get(thisTeamMember.Which_Team__c);
            }
            teamMemberTemp.add(thisTeamMember);
            teamIdToTeamMemberList.put(thisTeamMember.Which_Team__c, teamMemberTemp);
        }
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        for(Id teamId : teamToAllocationCounter.keySet()){
            Double splitTheAllocationCounter = teamToAllocationCounter.get(teamId);
            List<Team_Member__c> activeMembersForTeam = teamIdToTeamMemberList.get(teamId);
            Integer remainingTeamMembersSize = activeMembersForTeam.size();
            Decimal splitForEachMember = splitTheAllocationCounter / remainingTeamMembersSize;
            for(Team_Member__c thisMember : activeMembersForTeam){
                if(thisMember.Allocation_Counter__c != null && !allocation){
                    thisMember.Allocation_Counter__c = thisMember.Allocation_Counter__c + splitForEachMember;
                }
                if(thisMember.Allocation__c != null && allocation){
                    thisMember.Allocation__c = thisMember.Allocation__c+ splitForEachMember;
                }
                
                teamMembersToUpdate.add(thisMember);
            }
            Team__c thisTeam = new Team__c(id=teamId);
            thisTeam.Allocation_Override__c = true;
            teamsToUpdate.add(thisTeam);
        }
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            Database.update(teamMembersToUpdate, false);
        }
        if(teamsToUpdate != null && teamsToUpdate.size() > 0){
            Database.update(teamsToUpdate, false);
        }
    
        }
        List<Team_Member_Availability__c> teamMemberAvblList = [Select Id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c from Team_Member_Availability__c where Which_user__c IN :userIds];
        if(teamMemberAvblList !=null && teamMemberAvblList.size() > 0)
        {
            Database.delete(teamMemberAvblList, false);
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
     
    }
}