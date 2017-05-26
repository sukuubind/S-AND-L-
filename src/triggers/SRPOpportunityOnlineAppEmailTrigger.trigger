trigger SRPOpportunityOnlineAppEmailTrigger on Opportunity (after insert, after update) {
	/*
	List<Opportunity> oppList = [Select owner.email, deltaksrp__student__r.name, account.owner.name  from Opportunity where Id in: Trigger.New];
	Map<Id, string> OpptyIdToEmailMap = new Map<Id, String>();
	
	for(Opportunity o: oppList){
		OpptyIdToEmailMap.put(o.Id, o.owner.email);
	}
	
	if(Trigger.isInsert){
		for(Opportunity o: Trigger.New){
			system.debug('o1>>>>'+o);
			if(o.Online_Application_Stage__c == 'Registered to Apply'){
				SRPEmailSenderClass.sendemailviatemplate(o.Id, OpptyIdToEmailMap.get(o.Id));
			}
		}
	}
	
	if(Trigger.isUpdate){
		for(Opportunity o: Trigger.New){
			system.debug('o2>>>>'+o);
			if(o.Online_Application_Stage__c == 'Registered to Apply' 
				&& Trigger.oldMap.get(o.Id).Online_Application_Stage__c != 'Registered to Apply')
			{
				SRPEmailSenderClass.sendemailviatemplate(o.Id, OpptyIdToEmailMap.get(o.Id));
			}
		}
	}
	*/
}