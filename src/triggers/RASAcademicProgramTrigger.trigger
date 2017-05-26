trigger RASAcademicProgramTrigger on Academic_Program__c (before delete) {
	
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
	
	User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
   if (!loggedInUser.Profile.Name.contains('Integration')) {
	string errorMsg = 'You cannot delete a Program which has an Opportunity.';
	Set<id> acadId = new Set<Id>();
	for(Academic_Program__c thisProgram : trigger.old){
		acadId.add(thisProgram.id);
	}
	
	Map<Id, Boolean> acadMap = new Map<Id, Boolean>();
	List<Academic_Program__c> acadmicProgram = [Select 
													(Select Id 
														From Opportunities__r 
														limit 3) 
												From Academic_Program__c a 
												where a.Id IN :acadId 
											    ];
	if(acadmicProgram != null && acadmicProgram.size() > 0){
		for(Academic_Program__c ac : acadmicProgram){
			List<Opportunity> opptyList = ac.Opportunities__r;
			if(opptyList != null && opptyList.size() > 0){
				acadMap.put(ac.id, true);
			}
		} 
		
	}
	
	for (integer record = 0; record < trigger.size; record++) {
		if(acadMap != null && acadMap.containsKey(trigger.old[record].id)){
			trigger.old[record].addError(errorMsg);
		}
	}
   }
}