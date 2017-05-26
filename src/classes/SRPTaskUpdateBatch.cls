public with sharing class SRPTaskUpdateBatch implements database.Batchable<sObject> {
	public Datetime starttime;
    public Datetime endtime;
    public SRPTaskUpdateBatch(Datetime startTime, Datetime endTime){
		this.starttime = startTime;
        this.endtime = endTime;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		Datetime dt = (system.today() - 365);
		system.debug('dt>>>>'+dt);
		String Query = 'Select t.WhoId, t.WhatId, t.Weekly_Successful_Count__c, t.Weekly_Count__c, t.Type, t.Time_Zone__c, t.SystemModstamp, t.Successful__c, t.Subject, t.Status, t.SRP_Activity_Status__c, t.Result__c, t.ReminderDateTime, t.RecurrenceType, t.RecurrenceTimeZoneSidKey, t.RecurrenceStartDateOnly, t.RecurrenceMonthOfYear, t.RecurrenceInterval, t.RecurrenceInstance, t.RecurrenceEndDateOnly, t.RecurrenceDayOfWeekMask, t.RecurrenceDayOfMonth, t.RecurrenceActivityId, t.RecordTypeId, t.Priority, t.Pending_Count__c, t.OwnerId, t.NA3_Id__c, t.NA2_Id__c, t.MMSMSReceiptId__c, t.MMSMSDeliveryStatus__c, t.MMSMSDeliveryDateTime__c, t.Last_Mod_Date_Time__c, t.LastModifiedDate, t.LastModifiedById, t.IsVisibleInSelfService, t.IsReminderSet, t.IsRecurrence, t.IsDeleted, t.IsClosed, t.IsArchived, t.Id, t.Event_Status__c, t.Description, t.DeltakSRP__Type__c, t.DeltakSRP__Result__c, t.DeltakSRP__Event_Status__c, t.DeltakSRP__Completed_Date__c, t.CreatedDate, t.CreatedById, t.Completed_Date__c, t.Committed_Date__c, t.Chat_Transcript_Id__c, t.CallType, t.CallObject, t.CallDurationInSeconds, t.CallDisposition, t.Asked_for_Referral__c, t.Activity_Status__c, t.ActivityDate, t.AccountId From Task t where t.createddate > :starttime and t.createddate < :endtime'; 
		if(Test.isRunningTest()){
            Query = Query + ' Limit 5';
        }
        system.debug('query>>>>'+query);
        return Database.getQueryLocator(query);
    }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	List<Task>tasksToUpdate = new List<Task>();
    	
    	for(sObject s: Scope){ 
    		Task t = (Task)s;
    		tasksToUpdate.add(t);
    	}
    	
    	if(tasksToUpdate.size()>0){
    		SRPTaskTriggerHandler.populateLastActivityOnAffiliation(tasksToUpdate);
    		//update tasksToUpdate;
    	}	
    }
    
    public void finish(Database.BatchableContext BC){
    	system.debug('batch process scheduled is complete>>>>');
    }
}