trigger SRPAcademicProgramTrigger on DeltakSRP__Academic_Program__c (before delete) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPAcademicProgramtrigger__c);
    
    if(bypassTrigger)   return;
	
		User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
	   if (!loggedInUser.Profile.Name.contains('Integration')) {
		string errorMsg = 'You cannot delete a Program which has an Opportunity.';
		Set<id> acadId = new Set<Id>();
		for(DeltakSRP__Academic_Program__c thisProgram : trigger.old){
			acadId.add(thisProgram.id);
		}
		
		Map<Id, Boolean> acadMap = new Map<Id, Boolean>();
		List<deltaksrp__Academic_Program__c> acadmicProgram = [Select 
														(Select Id 
															From deltaksrp__Opportunities__r 
															limit 3) 
													From deltaksrp__Academic_Program__c a 
													where a.Id IN :acadId 
												    ];
		if(acadmicProgram != null && acadmicProgram.size() > 0){
			for(deltaksrp__Academic_Program__c ac : acadmicProgram){
				List<Opportunity> opptyList = ac.deltaksrp__Opportunities__r;
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
    //}   
}