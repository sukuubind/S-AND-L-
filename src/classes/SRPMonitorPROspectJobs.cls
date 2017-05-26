global without sharing class SRPMonitorPROspectJobs implements Database.Batchable<SObject>, Database.Stateful {
    global String query = '';
    global boolean schedulePROspectScheduleBatch = false;
     global Datetime startTime = null;
    public SRPMonitorPROspectJobs(String query){
    	this.query = query;
    }
     global Database.QueryLocator start(Database.BatchableContext BC){
        Datetime currentStamp = System.now();
        Time t = currentStamp.timeGMT();
        String month = (String.valueOf(currentStamp.monthGmt()).length()==1 ? '0'+String.valueOf(currentStamp.monthGmt()) : String.valueOf(currentStamp.monthGmt()));
        String thisDate = ((String.valueOf(currentStamp.dayGmt())).length() == 1 ? '0'+String.valueOf(currentStamp.dayGmt()) : String.valueOf(currentStamp.dayGmt()));
        String hour = (String.valueOf(currentStamp.hourGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.hourGmt()) : String.valueOf(currentStamp.hourGmt()));
        String minute = (String.valueOf(currentStamp.minuteGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.minuteGmt()) : String.valueOf(currentStamp.minuteGmt()));
        String timeStamp = String.valueOf(currentStamp.yearGmt())+'-'+month+'-'+thisDate+'T'+hour+':'+minute+':00.000Z';
        System.Debug(query+timestamp);
        
        
        if(Test.isRunningTest())
        {
        	this.query = this.query +  timeStamp +' limit 2';
        }else{
        	this.query = this.query + timeStamp +' order by c.NextFireTime asc';
        }
        startTime = System.now();
        return Database.getQueryLocator(this.query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    	Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
    	String prospectApexClassId = setting.PROspect_Apex_Class_ID__c;
    	List<CronTrigger> ctList = (List<CronTrigger>)scope;
    	List<Id> cronJobDetailId = new List<Id>();
		for(CronTrigger c : ctList){
		    cronJobDetailId.add(c.CronJobDetailId);
		}
		List<CronJobDetail> cjdList = [Select c.Name, c.JobType, c.Id From CronJobDetail c where Id in :cronJobDetailId];
		List<AsyncApexJob> asyncs = [SELECT Id, ApexClass.Name, MethodName, JobItemsProcessed, ApexClassId, CompletedDate, CreatedById, 
												  CreatedDate, NumberOfErrors, JobType, Status, ExtendedStatus, TotalJobItems
                      FROM AsyncApexJob where ApexClassId = :prospectApexClassId  and (Status != 'Completed')
                      Order by CreatedDate DESC ];
    	Boolean prospectScheduleBatchFound = false;
    	Boolean inProgressAsyncJobFound = false;
    	List<AsyncApexJob> erroredAsyncs = new List<AsyncApexJob>();
    	List<AsyncApexJob> inProgressAsyncs = new List<AsyncApexJob>();
    	for(AsyncApexJob thisAsync : asyncs){
    		if(thisAsync.Status == 'Failed'){
    			erroredAsyncs.add(thisAsync);
    		}else{
    			inProgressAsyncs.add(thisAsync);
    		}
    	}
    	
    	for(CronJobDetail cjd : cjdList){
    		if(cjd.Name.startsWith('ProspectScheduleBatch')){
    			prospectScheduleBatchFound = true;
    			break;
    		}
    	}
    	
    	List<RecordType> recordTypeList = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Batch_Job__c' and r.DeveloperName = 'PROspect_Status' limit 1];
	        
	        Batch_Job__c bj = new Batch_Job__c();
	        String comments = '';
	        String status = '';
	        
	       
    	
    	
    	
    	if(prospectScheduleBatchFound){
    		comments = comments + 'A schedule job for PROspectScheduleBatch is found. PROspect appears to be running per schedule.';
    		status = 'HEALTHY';
    		// TODO: Insert Email Alert to send an email to the team about Schedule job in available
    	}else{
    		if(erroredAsyncs.size() > 0 && inProgressAsyncs.size() > 0){
    			if(inProgressAsyncs[0].CreatedDate > erroredAsyncs[0].CreatedDate){
    				inProgressAsyncJobFound = true;
    			}
    		}else if(inProgressAsyncs.size() > 0 && erroredASyncs.size() == 0){
    			inProgressAsyncJobFound = true;
    		}
    		
    	}
    	if(!prospectScheduleBatchFound && inProgressAsyncJobFound){
    		comments = comments + 'A future job was not found but found a currently in progress PROspectScheduleBatch job. PROspect appears to be running per schedule.';
    		status = 'RUNNING';
    		//TODO: Insert Email Alert to send an email to the team about job in progress
    	}
    	if(!prospectScheduleBatchFound && !inProgressAsyncJobFound){
    		//TODO: Insert Email Alert to send an email to the team about no jobs available and one has been kickstarted
    		comments = comments + 'PROspect may be DOWN. Neither a schedule job nor an in progress PROspectScheduleBatch found. PROspect has been restarted. Please login into Salesforce and confirm.';
    		schedulePROspectScheduleBatch = true;
    		status = 'DOWN';
    		
    	}
    	   if(status != null && status != ''){
    	   	bj.comments__c = comments;
	        bj.RecordTypeId = recordTypeList[0].Id;
	        bj.Custom_Property_1__c = status;
	        insert bj;
    	   }
    	    
    	
    	
    	
    }
    
    global void finish(Database.BatchableContext BC){
        
	         Datetime endTime = System.now();
	         Long timeTakenToRun = endTime.getTime() - startTime.getTime();
	         Long seconds = timeTakenToRun / 1000;
			 Integer minutes = Integer.valueOf(seconds / 60);
	         
	         Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
	         Integer BATCH_SIZE = Integer.valueOf(setting.PROspect_Monitor_Batch_Size__c);
	         Integer MINUTES_FROM_NOW = Integer.valueOf(setting.PROspect_Monitor_Interval__c);
	         String query = 'Select c.TimesTriggered, c.TimeZoneSidKey, c.State, c.StartTime, c.PreviousFireTime, c.OwnerId, c.NextFireTime, c.LastModifiedById, c.Id, c.EndTime, c.CronJobDetailId, c.CronJobDetail.Name, c.CronExpression, c.CreatedDate, c.CreatedById From CronTrigger c where c.NextFireTime >=  ';
	         
			 SRPMonitorPROspectJobs monitorBatch = new SRPMonitorPROspectJobs(query);
			   if(!Test.isRunningTest()){
			         String cronID = System.scheduleBatch(monitorBatch, 'SRPMonitorPROspectJobs-'+System.now(), MINUTES_FROM_NOW - minutes, BATCH_SIZE);
	            }
	         
	         
		          BATCH_SIZE = Integer.valueOf(setting.Prospect_Batch_Size__c);
		          MINUTES_FROM_NOW = Integer.valueOf(setting.PROspect_Schedule__c);
		          query = ProspectConstants.PROLOG_SCHEDULE_QUERY;
		         ProspectScheduleBatch proBatch = new ProspectScheduleBatch(query);
		          if(!Test.isRunningTest() && schedulePROspectScheduleBatch){
		             String cronID = System.scheduleBatch(proBatch, 'ProspectScheduleBatch'+System.now(), MINUTES_FROM_NOW, BATCH_SIZE);
		          }
	         
	         
	         
	         
	         
        
    }
}