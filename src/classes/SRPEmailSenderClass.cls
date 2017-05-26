public class SRPEmailSenderClass {
	@future
	public static void sendemailviatemplate(Id Opportunityid, String owneremail){
		try{
			system.debug('owneremail>>>>'+owneremail);
			Opportunity o = [Select SRP_Student_name__c, SRP_Owner_Name__c from Opportunity where Id=: Opportunityid];
			User u = [Select email from User where Id =: Userinfo.getUserId()];
			system.debug('u.email>>>>'+u.email);
			
			if(owneremail != null){
				/*Contact c =  [select id, Email from Contact where email <> null and firstname = 'Pratik' limit 1];
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
				EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'SRP_Application_Registered_To_Apply'];
		 
				mail.setSenderDisplayName('Deltak Online Application');
				mail.setTargetObjectId(c.id); // Specify who the email should be sent to.
				system.debug('et.id>>>>'+et.id);
				mail.setTemplateId(et.id);
					
				String[] addr = new String[]{'pratik.tanna@deltak-innovation.com'}; // max 10 addresses 
		        mail.setToAddresses(addr);
				mail.setwhatId(opportunityid);
		 		mail.setsaveasactivity(false);
		 		
		 		Savepoint sp = Database.setSavepoint();
 					Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    			Database.rollback(sp);*/
	    			String htmlbody = o.SRP_Student_name__c + ' has registered for the Online Application. To view their progress, click the following link - <br/><br/>' + 
	    				'https://cs10.salesforce.com/'+opportunityid;
	    			Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
	    			String[] addr = new String[]{owneremail}; // max 10 addresses 
		        	emailtosend.setToAddresses(addr);
				    emailToSend.setToAddresses(addr);
				    emailtoSend.setReplyTo('noreply@online.edu'); 
				     //emailToSend.setPlainTextBody(mail.getPlainTextBody());     
				    emailToSend.setHTMLBody(htmlbody);
			        emailToSend.setSubject('Application Received –  '+o.SRP_Owner_Name__c);
				    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailtosend});
			}	
		}Catch(Exception e){
			system.debug('exception>>>'+e.getmessage());
		}	
	}
}