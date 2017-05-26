global with sharing class SRPBatchUpdateOpptyStartDates implements  Database.Batchable<sObject> {
	global final string query;
	private final Set<Id> ids;
	private final Map<Id, Date> idToStartDate;
	global SRPBatchUpdateOpptyStartDates (String q)
	{
	   query = q;
	}
	global SRPBatchUpdateOpptyStartDates(Set<Id> ids, Map<Id, Date> idToStartDate){
		this.ids = ids;
		this.idToStartDate = idToStartDate;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
	
	   return Database.getQueryLocator([Select id,
										  deltaksrp__Start_Date__c,
										  deltaksrp__Academic_Start_Date__c
									From Opportunity
									Where Deltaksrp__Academic_Start_Date__c in :this.ids ]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
	
	 List<Opportunity> opptyToPersist = new List<Opportunity>();
	  for(sObject thisOppty_sObject : scope){
		Opportunity thisOppty = (Opportunity)thisOppty_sObject;
		Date startDate = this.idToStartDate.get(thisOppty.deltaksrp__Academic_Start_Date__c);
		thisOppty.deltaksrp__Start_Date__c = startDate;
		opptyToPersist.add(thisOppty);
		}
		update opptyToPersist;
	}
	
	
	global void finish(Database.BatchableContext BC){
	 
	}



}