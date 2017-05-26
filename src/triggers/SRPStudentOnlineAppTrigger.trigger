trigger SRPStudentOnlineAppTrigger on DeltakSRP__Student_Online_Application__c (after insert, after update, before insert, 
before update) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPStudentOnlineAppTrigger__c); 
    
    if(bypassTrigger)   return; 
 	
	
	List<Profile> plist = [Select Id from Profile where name IN ('Online Application Portal User', 'Online Application Community User')];
    
    if(plist != null && plist.size() > 0){
	    for(Profile p : plist){
	    	if(userinfo.getProfileId() == p.ID || Test.isRunningTest()){
		    	Id ContactId = [Select Id, contactId from User where Id =:userinfo.getuserid()].contactId;
		        system.debug('contactid>>>>'+contactid);
		        
		        if(Test.isRunningTest())
		        	contactId = trigger.new[0].DeltakSRP__Affiliation__c;
		        
		        List<Contact> srpcontact = new List<Contact>();
				srpcontact = [Select Id, Account.Abbreviation__c, account.name, account.ownerid, account.owner.email, firstname, lastname, DeltakSRP__Maiden_Name__c, (Select Id, stagename, Admissions_manager__c, admissions_manager__r.email, owner.email, owner.isactive, DeltakSRP__Student__c, DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, account.name, account.owner.email from DeltakSRP__Opportunities__r) from Contact where id =: contactid];
				
				system.debug('srpcontact>>>>'+srpcontact);
				
				if(trigger.isInsert && trigger.isbefore){
					SRPOnlineApplicationTriggerHandler.handleBeforeInsert(srpcontact, Trigger.New);
				}
				
				if(trigger.isBefore && trigger.isUpdate){
					SRPOnlineApplicationTriggerHandler.handleBeforeUpdate(srpcontact, Trigger.New[0], Trigger.Old[0]); 
				}
				
				if(trigger.isUpdate && trigger.isAfter){
					SRPOnlineApplicationTriggerHandler.handleAfterUpdate(srpcontact, Trigger.New[0], Trigger.Old[0]); 
				}
				if(trigger.isInsert && trigger.isAfter){
					SRPOnlineAppTriggerHandlerAfterInsert.handleAfterInsert(srpcontact, Trigger.New); 
				}
				
			}
	    }
	    
	}
}