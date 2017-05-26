public with sharing class Opp_ProgramChanged {
	public static void programChangedToNull(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
		for (integer record = 0; record < newOpps.size(); record++) {
			Opportunity newRecord = newOpps[record];
			Opportunity oldRecord = oldOpps[record];
			
			if (newRecord.Program__c == null) {
				newRecord.Start_Date__c = null;
            	newRecord.Academic_Start_Date__c = null;
            	newRecord.Specialization__c = null;
			}        
		}
	}
}