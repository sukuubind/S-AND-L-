// Pratik Tanna 03/28/2013 Added method to reset Pending Activity Date on Oppty for the Pending Activity Bug
 
public class SetPendingActivityDateClass {
    Batch_Job__c thisBatchRecord = null;
    public SetPendingActivityDateClass(){
    	
    }
    // Constructor build the batchRecord that needs to be upserted
    public SetPendingActivityDateClass(Id oppId){
         Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
         Schema.DescribeSObjectResult R = Batch_Job__c.SObjectType.getDescribe();                
         List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        
         for (Schema.RecordTypeInfo rtInfo : RT) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
         }
         
         thisBatchRecord = new Batch_Job__c();
         thisBatchRecord.RecordID__c = oppId;
         thisBatchRecord.RecordTypeId = recordTypeName_to_recordTypeId.get('Migration');
    }
    
    // Sets ths custom property field to "null" so the batch job can handle
    public void resetPendingActivityDate(Id oppId)  {
        System.debug('Method resetPendingActivityDate in class SetPendingActivityDateClass executing ...');
        thisbatchRecord.Custom_property_1__c = 'null'; //String.valueOf(t);
    }
    // Sets the pending activity date to the earliest date
    public void setPendingActivityDate(Id oppId, Date earliestDate){
        System.debug('Method setPendingActivityDate in class SetPendingActivityDateClass executing ...');
        thisbatchRecord.Custom_property_1__c = String.valueOf(earliestDate); 
    }
    // Upserts the batch record that is initialized in the constructor and the values set in various methods above
    public void commitPendingActivityDate(){
        try{
            if(thisbatchRecord != null){
                Database.upsert(thisbatchRecord, Batch_Job__c.RecordID__c, false);
            }
        }catch(DMLException e){
            System.Debug(e);
        }  
    }
    // Finds the earliest pending activity date based on the oppId in the parameter amongst all the activities available for the opportunity
    public Date getPendingActivityDate(Id oppID, Id activityId){
        string activityCompleted = 'Completed';
        Date pendingActivityDate = null;
        System.debug('Getting tasks & events which are complete, due date is past today, and are related to Opportunity ' + oppId );
        
        //Note that the ActivityDate in the following queries is the due date
        //get the pending tasks based on the activity date, status and the opportunity      
        Task [] pendingTasks = [SELECT Id, ActivityDate 
                                 FROM Task
                                 WHERE Status != :activityCompleted
                                 AND ActivityDate > :System.today()
                                 AND WhatId = : oppId
                                 //AND Id != :activityId
                                 order by ActivityDate asc];
        
        System.debug('pendingTasks = ' + pendingTasks);
        
        Event [] pendingEvents = [SELECT Id, ActivityDate
                                 FROM Event
                                 WHERE Event_Status__c != :activityCompleted
                                 AND ActivityDate > :System.today()
                                 AND WhatId = : oppId
                                 AND Id != :activityId
                                 order by ActivityDate asc];
        System.debug('pendingEvents = ' + pendingEvents);
        
        Date earliestTask = (pendingTasks != null && pendingTasks.size() > 0 ? pendingTasks[0].ActivityDate : null);
        Date earliestEvent = (pendingEvents != null && pendingEvents.size() > 0 ? pendingEvents[0].ActivityDate : null);
        // add logic to check if either dates are null
        if(earliestTask != null && earliestEvent == null){
            pendingActivityDate = earliestTask;
        }
        if(earliestTask == null && earliestEvent != null){
            pendingActivityDate = earliestEvent;
        }
        
        // add check for not null for both
        if(earliestTask != null && earliestEvent != null){
            if(earliestTask < earliestEvent){
                pendingActivityDate = earliestTask;
            }else{
                pendingActivityDate = earliestEvent;
            }
        }
        
        return pendingActivityDate;
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
								 WHERE Event_Status__c != :activityCompleted
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
	
		public void setPendingActivityDate(Id oppId)  {
		System.debug('Method setPendingActivityDate in class SetPendingActivityDateClass executing ...');
		
		Date earliestDate = getPendingActivityDate(oppId);
		
		Opportunity [] o = [Select Id, Pending_Activity_Date__c 
							FROM Opportunity
							WHERE Id = :oppId];
		if (o.size() > 0) {
			o[0].Pending_Activity_Date__c = earliestDate;
			update o;
		}
	}
}