public with sharing class SRPSetPendingActivityDateClass {
	
	public SRPSetPendingActivityDateClass(){
		
	}
	
public void resetPendingActivityDate(Id oppId)  {
		System.debug('Method resetPendingActivityDate in class SetPendingActivityDateClass executing ...');
		
		Opportunity [] o = [Select Id, deltaksrp__Pending_Activity_Date__c 
							FROM Opportunity
							WHERE Id = :oppId];
		if (o.size() > 0) {
			o[0].deltaksrp__Pending_Activity_Date__c = null;
			update o;
		}
	}
	
	public void setPendingActivityDate(Id oppId)  {
		System.debug('Method setPendingActivityDate in class SetPendingActivityDateClass executing ...');
		
		Date earliestDate = getPendingActivityDate(oppId);
		
		Opportunity [] o = [Select Id, Pending_Activity_Date__c 
							FROM Opportunity
							WHERE Id = :oppId];
		if (o.size() > 0) {
			o[0].deltaksrp__Pending_Activity_Date__c = earliestDate;
			update o;
		}
	}
	
	private Date getPendingActivityDate(Id oppId) {
		string activityCompleted = 'Completed';		
		List <Date> dateList = new List<Date> ();
		
		
		
		System.debug('Getting tasks & events which are complete, due date is past today, and are related to Opportunity ' + oppId );
		
		//Note that the ActivityDate in the following queries is the due date
		//get the pending tasks based on the activity date, status and the opportunity		
		Task [] pendingTasks = [SELECT Id, ActivityDate 
								 FROM Task
								 WHERE Status != :activityCompleted
								 AND ActivityDate > :System.today()
								 AND WhatId = : oppId];
		
		System.debug('pendingTasks = ' + pendingTasks);
		
		Event [] pendingEvents = [SELECT Id, ActivityDate
								 FROM Event
								 WHERE deltaksrp__Event_Status__c != :activityCompleted
								 AND ActivityDate > :System.today()
								 AND WhatId = : oppId];
		
		
		System.debug('pendingEvents = ' + pendingEvents);
		
		//if there are no pendingEvents or pendingTasks esnd back a NULL date
		if (pendingTasks.size() == 0 && pendingEvents.size() == 0 )	{
			System.debug('No pending tasks or events. Returning NULL...');
			return null;	
		}
		
		for (Task t : pendingTasks) {
			dateList.add(t.ActivityDate);
		}
		
		for (Event e : pendingEvents) {
			dateList.add(e.ActivityDate);
		}
		
		System.debug('Finding earlierst date ...');
		
		Date earliestDate = getEarliestDate(dateList);
		
		System.debug('earliest date = '  + earliestDate);
		
		return earliestDate;
	}
	
	public Date getEarliestDate(List <Date> dateList) {
		if (dateList.size() == 0 )
			return null;
			 
		Date earliestDate = dateList[0];
		
		for (Date d : dateList) {
			if (d < earliestDate) {
				earliestDate = d;
			}
		}
		
		return earliestDate;
	}
}