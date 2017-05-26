public with sharing class SRPOfferAppointmentCreateTask {

	public SRPOfferAppointmentCreateTask(){
	}
	  	
	@future
	public static void createOfferAppointmentTask(List<Id> opty) 
	{ 	   
	    List<String> recordType = new List<String>();
	    recordType.add('Deltak: Student');
	    List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordType];
	    Map<String, Id> recordTypeNameToId = new Map<String, Id>();
	    if(recordTypes != null && recordTypes.size() > 0)
	    {
	        for(RecordType thisRecordType : recordTypes){
	            recordTypeNameToId.put(thisRecordType.Name, thisRecordType.Id);
	        }
		} 
		String loggedinUserId = UserInfo.getUserId();
	    List<Task> taskListToInsert = new List<Task>();
	    List<Opportunity> op = new List<Opportunity>();
	    op = [Select id, Student__c, DeltakSRP__webschedulerstatus__c from Opportunity where id in :opty];  
	    
	    List<opportunity> opplist = new List<Opportunity>();
	    for(Opportunity o : op)
	    {    	
		    Task t = new Task();
		    t.RecordTypeId = recordTypeNameToId.get('Deltak: Student');
		    t.OwnerId = loggedinUserId;
		    t.Subject = 'Offered Appointment';
		    t.Type = 'Offered Appointment';
		    t.WhatId = o.id;
		    t.WhoId = o.Student__c ;
		    t.Status = 'Completed';
		    t.Priority = 'Normal';
		    t.Result__c = 'Complete';
		    t.ActivityDate = Date.today();
		    
		    taskListToInsert.add(t); 
		    o.DeltakSRP__Last_Attempt__c = Date.today();
		    opplist.add(o);
		      
	    }	    
	    if(taskListToInsert.size() != 0 && taskListToInsert!= null) 
	    	insert taskListToInsert;	 
	    
	//    if(!Test.isRunningTest()){
	    if(opplist.size() != 0 && opplist != null)
	    	update opplist;
	 //   }
	    }
}