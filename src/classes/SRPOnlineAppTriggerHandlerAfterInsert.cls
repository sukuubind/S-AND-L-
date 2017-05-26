public with sharing class SRPOnlineAppTriggerHandlerAfterInsert {

	public Static void handleAfterInsert(List<Contact> srpcontact, List<DeltakSRP__Student_Online_Application__c> studentOnlineApplications){
	        
	        system.debug('in after insert' +srpcontact[0].AccountId);
	        List<String> contactList = new List<String>();
	        for(Contact c: srpcontact){
	        	contactList.add(c.AccountId);
	        }
	        
	        List<Account> accountList = new List<Account>(); 
	        accountList = [Select SOA_Record_Type_ID__c from Account where Id IN :contactList];
	        Map<String, String> recToAccMap = new Map<String, String>();
	        for(Account a: accountList){
	        	recToAccMap.put(a.ID,a.SOA_Record_Type_ID__c);
	        }
	        
	        List<String> soaIdList = new List<String>();
	        for(DeltakSRP__Student_Online_Application__c s: studentOnlineApplications){
	        	soaIdList.add(s.Id);
	        }
	        
	        List<DeltakSRP__Student_Online_Application__c> soaAccList = new List<DeltakSRP__Student_Online_Application__c>();
	        soaAccList=[Select DeltakSRP__Affiliation__r.AccountId from DeltakSRP__Student_Online_Application__c where ID IN :soaIdList];
	        
	        system.debug('list soa' + soaAccList);
	        for(DeltakSRP__Student_Online_Application__c a: soaAccList){
		       	a.RecordTypeId = recToAccMap.get(a.DeltakSRP__Affiliation__r.AccountId);
	        }
	        
	        try{
	        	update(soaAccList);
	        }catch(DMLException e){
	        	system.debug('error after insert'+e);
	        }
	        
	        
	        
	    }
}