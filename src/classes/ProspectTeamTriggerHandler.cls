public without sharing class ProspectTeamTriggerHandler {
	public static void handleBeforeInsert(List<Team__c> newList){
		
	}
	public static void handleAfterInsert(List<Team__c> newList){
		
	}
	public static void handleBeforeUpdate(List<Team__c> oldList, List<Team__c> newList){
		
	}
	public static void handleAfterUpdate(List<Team__c> oldList, List<Team__c> newList){
		System.Debug(' ProspectTeamTriggerHandler --- handleAfterUpdate');
		reOrderTeams(oldList, newList);
	}
	public static void reOrderTeams(List<Team__c> oldList, List<Team__c> newList){
		System.Debug('ProspectTeamTriggerHandler -- reOrderTeams');
		Set<Id> accountsToReorderTeams = new Set<id>();
		for(Integer i=0;i<newList.size();i++){
			Team__c newTeam = newList[i];
			Team__c oldTeam = oldList[i];
			System.Debug('newTeam.Active__c -- '+newTeam.Active__c);
			System.Debug('oldTeam.Active__c -- '+oldTeam.Active__c);
			if(newTeam.Active__c == false && newTeam.Active__c != oldTeam.Active__c){
				accountsToReorderTeams.add(newTeam.Team_Account__c);
			}
		}
		if(accountsToReorderTeams != null && accountsToReorderTeams.size() > 0){
			reorderTeamsForAccounts(accountsToReorderTeams);
		}
	}
	@future
	public static void reorderTeamsForAccounts(Set<id> accountIds){
		List<Team__c> teamsToReorder = [Select Id, Allocation_override__c, Team_Account__c, Team_Order__c from Team__c where Team_Account__c IN :accountIds and Active__c = true and Default_Team__c = false order by Team_Order__c asc];
		Map<id, List<Team__c>> accountsToOrderedTeams = new Map<Id, List<Team__c>>();
		for(Team__c thisTeam : teamsToReorder){
			List<Team__c> tempTeam = new List<Team__c>();
			if(accountsToOrderedTeams != null && accountsToOrderedTeams.containsKey(thisTeam.Team_Account__c)){
				tempTeam = accountsToOrderedTeams.get(thisTeam.Team_Account__c);
			}
			tempTeam.add(thisTeam);
			accountsToOrderedTeams.put(thisTeam.Team_Account__c, tempTeam);
		}
		List<Team__c> teamListToUpdate = new List<Team__c>();
		for(Id accountId : accountsToOrderedTeams.keySet()){
			List<Team__c> teamListForAccount = accountsToOrderedTeams.get(accountId);
			for(Integer i=0;i<teamListForAccount.size();i++){
				Team__c tempTeam = new Team__c(id = teamListForAccount.get(i).id);
				tempTeam.Team_Order__c = Double.valueOf(i+1);
				teamListToUpdate.add(tempTeam);
				
			}
		}
		if(teamListToUpdate != null && teamListToUpdate.size() > 0){
			Database.update(teamListToUpdate, true);
		}
	}
}