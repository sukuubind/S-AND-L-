trigger SRPStudentOnlineApplicationEmailTrigger on DeltakSRP__Student_Online_Application__c (after insert, after update) {

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPStudentOnlineApplicationEmailTrigger__c); 
    
    if(bypassTrigger)   return; 
 
	
	Profile p = [Select Id from Profile where name = 'Online Application Portal User'];
	
	Map<Id, string> AppIdToOwneremailMap = new MAp<Id, String>();
	
	List<DeltakSRP__Student_Online_Application__c> appList = new List<DeltakSRP__Student_Online_Application__c>();
	
	applist = [Select SRP_unlock_request_email__c, SRP_Application_emails_sent__c, DeltakSRP__Application_Status__c, DeltakSRP__Affiliation_Opportunity__r.owner.email from DeltakSRP__Student_Online_Application__c where Id in: Trigger.New and SRP_Application_emails_sent__c = false];
	system.debug('applist>>>>'+applist);
	
	for(DeltakSRP__Student_Online_Application__c soa: applist){
		system.debug('soa.SRP_Application_emails_sent__c>>>>'+soa.SRP_Application_emails_sent__c);
		system.debug('soa.SRP_unlock_request_email__c>>>>'+soa.SRP_unlock_request_email__c);
		AppIdToOwnerEmailMap.put(soa.Id, soa.DeltakSRP__Affiliation_Opportunity__r.owner.email);
	}
	
	if(userinfo.getProfileId() == p.ID || Test.isRunningTest()){
		
		Id ContactId = [Select Id, contactId from User where Id =:userinfo.getuserid()].contactId;
		Contact c =  [select id, Email from Contact where email='pratik.tanna@deltak-innovation.com'  limit 1];
		
		Map<String,EmailTemplate> statusToEmailTemplate = new Map<String,EmailTemplate>();
		
		List<EmailTemplate> etList = [SELECT id, developerName FROM EmailTemplate WHERE developerName = 'SRP_Application_Partially_filled' OR developerName = 'SRP_Application_Submitted'];
		
		for(EmailTemplate et : etList)
		{
			
			if(et.developerName == 'SRP_Application_Partially_filled')
			{
				statusToEmailTemplate.put('In Progress', et);
			}
			else
			{
				statusToEmailTemplate.put('Submitted', et);
			}
			
		}
		
 		OrgWideEmailAddress owea;
 		OrgWideEmailAddress[] oweaList = [select Id from OrgWideEmailAddress where Address = 'noreply@deltak-innovation.com'];
 		
 		if(oweaList != null && oweaList.size() > 0)
 		{
 			owea = oweaList[0];
 		}
 		
		for(DeltakSRP__Student_Online_Application__c app: applist){
			String owneremail = AppIdToOwnerEmailMap.get(app.Id);
					
			if((trigger.isinsert && app.DeltakSRP__Application_Status__c == 'In Progress') || (app.DeltakSRP__Application_Status__c == 'In Progress' && Trigger.oldMap.get(app.Id).DeltakSRP__Application_Status__c != 'In Progress')){
				if(owneremail != null)
					SendEmailViaTemplate(app, owneremail, c, statusToEmailTemplate.get('In Progress'), owea);
			}
			
			if((app.DeltakSRP__Application_Status__c == 'Submitted' 
							&& Trigger.oldMap.get(app.Id).DeltakSRP__Application_Status__c != 'Submitted') ||
							(app.DeltakSRP__Application_Status__c == 'Submitted, Awaiting Payment' 
							&& Trigger.oldMap.get(app.Id).DeltakSRP__Application_Status__c != 'Submitted, Awaiting Payment')){
				
				if(owneremail != null)
					SendEmailViaTemplate(app, owneremail, c, statusToEmailTemplate.get('Submitted'), owea);				
			}
		}
		
	}	
	
	private void sendEmailViaTemplate(DeltakSRP__Student_Online_Application__c app, string owneremail, Contact c, EmailTemplate et, OrgWideEmailAddress owea){
		
		system.debug('owneremail>>>>'+owneremail);
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
 		system.debug('c.id>>>>'+c.id);
 		system.debug('et.id>>>>'+et.id); 
 		system.debug('app.Id>>>>'+app.Id);
 		
		mail.setSenderDisplayName('Deltak Online Application');
		mail.setTemplateId(et.id);
		String[] addr = new String[]{owneremail}; // max 10 addresses 
        mail.setToAddresses(addr);
        mail.setTargetObjectId(c.id);
		mail.setwhatId(app.Id);
		mail.setreplyto('noreply@online.com');
 		mail.setsaveasactivity(false);
 		
 		Savepoint sp = Database.setSavepoint();
 			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    	Database.rollback(sp);
 		
 		 Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
	     emailToSend.setToAddresses(addr);
	     //emailToSend.setPlainTextBody(mail.getPlainTextBody());     
	     emailToSend.setHTMLBody(mail.getHTMLBody());
         emailToSend.setSubject(mail.getSubject());
         if(owea != null)
         {
         	emailToSend.setOrgWideEmailAddressId(owea.Id);
         }
	     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailtosend});
		
	} 
}