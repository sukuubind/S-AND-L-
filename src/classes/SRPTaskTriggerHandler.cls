//V.1.0: (1/23/2015) Pratik Tanna: Added handler class for SRPTaskTrigger to populate last Activity field on Contact used in Go-Get report for SRP-717
public with sharing class SRPTaskTriggerHandler {
	public static void populateLastActivityOnAffiliation(List<Task> tasks){
		List<Contact> contactsToUpdate = new List<Contact>();
		List<Id> contactIds = new List<Id>();
		
		List<Task> taskList = [Select Id, whoid, ActivityDate from Task where id in:tasks and Status='Completed' and whoid != null];
		
		for(Task t: tasks){
			if((t.whoid)!=null && String.valueof(t.whoid).startswith('003')){
				contactIds.add(t.whoid);
				//TaskIdTOcontactIdMap.put(t.id,t.whoid);
			}	
		}
		
		system.debug('contactids>>>>'+contactids);
		
		if(contactIds.size() > 0){
			List<Contact> contacts = [Select last_completed_activity__c, (Select ActivityDate from Tasks where activitydate!=null ORDER BY ActivityDate DESC) from Contact where Id in: contactIds];
			
			for(Contact c: contacts){
				 for(Task t: c.tasks){
				 	if(t.ActivityDate != null && (t.ActivityDate>c.Last_completed_Activity__c || c.Last_completed_Activity__c==null)){
				 		c.Last_Completed_Activity__c = t.ActivityDate;
				 		system.debug('c.Last_Completed_Activity__c>>>>'+c.Last_Completed_Activity__c);
				 		contactstoupdate.add(c);
				 	}	
				 	break;
				 }
				 
			}
		}
		system.debug('contactstoupdate>>>>'+contactstoupdate);
		if(contactsToUpdate.size()>0)
			update contactstoupdate;
	}
}