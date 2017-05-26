trigger SRPAcademicStartDateTrigger on DeltakSRP__Academic_Start_Date__c (after insert, after update) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPAcademicStartDateTrigger__c); 
    
    if(bypassTrigger)   return;
	
	    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
	    if (!loggedInUser.Profile.Name.contains('Integration')) {
	    
	        System.debug('Trigger record details: ' + trigger.new);
	        
	        Set<id> acadStartDateList = new Set<id>();
	        Map<Id, Date> idToStartDate = new Map<Id, Date>();
	       
	        
	        for(DeltakSRP__Academic_Start_Date__c thisDate : Trigger.new){
	                 acadStartDateList.add(thisDate.id);
	                idToStartDate.put(thisDate.id, thisDate.DeltakSRP__Start_Date__c);
	        }
	        // Bug Fix 657 VS START Making the updates batchable 
	        
	        if(acadStartDateList != null && acadStartDateList.size() > 0){
	            SRPBatchUpdateOpptyStartDates batchAPex = new SRPBatchUpdateOpptyStartDates(acadStartDateList, idToStartDate);
	            ID batchprocessid = Database.executeBatch(batchApex);
	        }
	    } 
   // }      
}