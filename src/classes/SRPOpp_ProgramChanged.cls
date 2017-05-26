public with sharing class SRPOpp_ProgramChanged {
	public static void programChangedToNull(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {
		for (integer record = 0; record < newOpps.size(); record++) {
			Opportunity newRecord = newOpps[record];
			Opportunity oldRecord = oldOpps[record];
			
			if (newRecord.DeltakSRP__Academic_Program__c == null) {
				newRecord.DeltakSRP__Start_Date__c = null;
            	newRecord.DeltakSRP__Academic_Start_Date__c = null;
            	newRecord.DeltakSRP__Academic_Specialization__c = null;
			}        
		}
	}
}