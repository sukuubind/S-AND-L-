public without sharing class SRPCourseEnrollmentUpdateBatch implements Database.Batchable<sObject>{
	public SRPCourseEnrollmentUpdateBatch(){
		
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String Query = 'Select DeltakSRP__Academic_Section__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Section__r.Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c from DeltakSRP__Course_Enrollment__c';
        if(Test.isRunningTest()){
        	Query = Query + ' limit 10';
        }
        return Database.getQueryLocator(query);
    }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope){
    	system.debug('scope>>>>'+scope);
    	
    	List<DeltakSRP__Course_Enrollment__c>courseenrollmentToUpdate = new List<DeltakSRP__Course_Enrollment__c>();
    	
    	for(sObject s: Scope){ 
    		DeltakSRP__Course_Enrollment__c ce = (DeltakSRP__Course_Enrollment__c)s;
    		courseenrollmentToUpdate.add(ce);
    	}
    	
    	if(courseenrollmentToUpdate.size()>0){
			SRPCourseEnrollmentTriggerHandler.updateNumberOfTermsOutOnContact_Schedule(courseenrollmentToUpdate);
    	}
    		//SRPCourseEnrollmentTriggerHandler.updateCourseCompletePercentageOnContact(courseenrollmentToUpdate);
    		//update courseenrollmentToUpdate;
    }
    
    public void finish(Database.BatchableContext BC){
    	system.debug('batch process scheduled is complete>>>>');
    	if(!Test.isRunningTest()){
    		SRPCourseEnrollmentUpdateBatch courseEnrollmentBatch = new SRPCourseEnrollmentUpdateBatch();
         String cronID = System.scheduleBatch(courseEnrollmentBatch, 'Number of Terms Out'+System.now(), 1440, 200);
    	}
    	
          
    }
	
}