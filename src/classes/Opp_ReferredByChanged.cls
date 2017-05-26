public class Opp_ReferredByChanged {
    public static void referredByChanged(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {     
        Set<id> newIds = new Set<id>();
        Set<id> newRefIds = new Set<id>();
        Map <Id, Id> oppsId_to_Referred_By_Person = new Map<Id, Id>();
        Opportunity [] refOpps;
            
        for (Opportunity newRecord : newOpps) { 
            newIds.add(newRecord.Id);
            newRefIds.add(newRecord.Referred_By_Opportunity__c);
        }
        //Get the IDs for the Person lookup off of the Referred by Opportunity 
        refOpps = [select Person__c, Id
        FROM Opportunity
        WHERE Id in :newRefIds];    
        
        for (integer record = 0; record < newOpps.size(); record++) {
            Opportunity newRecord = newOpps[record];
            Opportunity oldRecord = oldOpps[record];        
            
            for (Opportunity o : refOpps ){
                System.debug('****  Person__c = '+o.Person__c);
                oppsId_to_Referred_By_Person.put(o.Id, o.Person__c);
            }
                
            /*********************************************************************************************************************
            //Set Referred_By_Person__c by setting it to the Person who is related to the Referred by Opportunity field
            //****************************** ****************************************************************************************/
            //If Referred_By_Opportunity__c is null, set Referred_By_Person__c to null
            if (newRecord.Referred_By_Opportunity__c==null) {
                newRecord.Referred_By_Person__c = null;
                System.debug('--- newRecord.Referred_By_Opportunity__c = Null');
            }           
            //Get the Person__c field of the Referredy By Opportunity 
            else {
                newRecord.Referred_By_Person__c = oppsId_to_Referred_By_Person.get(newRecord.Referred_By_Opportunity__c);
                System.debug('--- newRecord.Referred_By_Person__r.Person__c = ' + oppsId_to_Referred_By_Person.get(newRecord.Referred_By_Opportunity__c));
            }
            
        }
    }
}