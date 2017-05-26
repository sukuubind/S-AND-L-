public with sharing class SRPIncomingSMSEmail {
	public SRPIncomingSMSEmail() {
		
	}
	public static void sendEmail(smagicinteract__Incoming_SMS__c[] incomingSMS) {
	
	//EmailTemplate contactET = [SELECT id FROM EmailTemplate WHERE developerName = 'Incoming_SMS_Email_Contact' limit 1];
	//EmailTemplate leadET = [SELECT id FROM EmailTemplate WHERE developerName = 'Incoming_SMS_Email_Lead' limit 1];
	
	/*List<Id> smsHistoryIds = new List<Id>();
	for (smagicinteract__Incoming_SMS__c sms :incomingSMS){
		smsHistoryIds.add(sms.DeltakSRPSMS__SMS_History__c);
	}
	
	List<smagicinteract__smsMagic__c> smsHistoryList = new List<smagicinteract__smsMagic__c>();
	smsHistoryList = [Select OwnerId, DeltakSRPSMS__Opportunity__r.OwnerId FROM smagicinteract__smsMagic__c where id in: smsHistoryIds];
	
	Map<ID, smagicinteract__smsMagic__c> smsHistoryMap = new Map<ID, smagicinteract__smsMagic__c>(); 
	for (smagicinteract__smsMagic__c sms :smsHistoryList){
		smsHistoryMap.put(sms.Id, sms);
	}*/
	
	List <Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage>();
	   	for (smagicinteract__Incoming_SMS__c sms :incomingSMS){
	      	System.debug(LoggingLevel.INFO, '$$SRPIncomingSMSEmail -> sendEmail');
	      	checkMessage(sms);
		  	/*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		  	if(sms.DeltakSRPSMS__Contact__c != null){
		  		mail.setTemplateId(contactET.id);
		  	}else if(sms.DeltakSRPSMS__Lead__c != null){
		  		mail.setTemplateId(leadET.id);
		  	}
			mail.setWhatId(sms.id);
			System.debug(LoggingLevel.INFO, '$$sms ->'+ sms);
			
			smagicinteract__smsMagic__c smsHistory = smsHistoryMap.get(sms.DeltakSRPSMS__SMS_History__c);
			
			System.debug(LoggingLevel.INFO, '$$smagicinteract__smsMagic__c ->'+ smsHistory);
			mail.setTargetObjectId(smsHistory.OwnerId);
			mail.setSaveAsActivity(false);
			mails.add(mail);	*/		
	   	}
	   	
	  /* 	for (smagicinteract__Incoming_SMS__c sms :incomingSMS){
	   		
	   		if(smsHistoryMap.get(sms.DeltakSRPSMS__SMS_History__c) != null && smsHistoryMap.get(sms.DeltakSRPSMS__SMS_History__c).DeltakSRPSMS__Opportunity__r.OwnerId != null){
		      	System.debug(LoggingLevel.INFO, '$$SRPIncomingSMSEmail -> sendEmail');
		      	checkMessage(sms);
			  	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			  	if(sms.DeltakSRPSMS__Contact__c != null){
			  		mail.setTemplateId(contactET.id);
			  	}else if(sms.DeltakSRPSMS__Lead__c != null){
			  		mail.setTemplateId(leadET.id);
			  	}
				mail.setWhatId(sms.id);
				System.debug(LoggingLevel.INFO, '$$sms ->'+ sms);
				
				smagicinteract__smsMagic__c smsHistory = smsHistoryMap.get(sms.DeltakSRPSMS__SMS_History__c);
				
				System.debug(LoggingLevel.INFO, '$$smagicinteract__smsMagic__c ->'+ smsHistory);
				mail.setTargetObjectId(smsHistory.DeltakSRPSMS__Opportunity__r.OwnerId);
				mail.setSaveAsActivity(false);
				mails.add(mail);	
	   		}			
	   	} */
	   	
	   //	Messaging.sendEmail(mails);
	}

	public static void  checkMessage(smagicinteract__Incoming_SMS__c incomingSMS){

        Map<String, DeltakSRP_SMSStopWords__c>  theStopSMS = DeltakSRP_SMSStopWords__c.getall();
        System.debug(LoggingLevel.INFO, 'theStopSMS'+theStopSMS);
        System.debug(LoggingLevel.INFO, 'incomingSMS'+incomingSMS);
        if(theStopSMS.containsKey(incomingSMS.smagicinteract__SMS_Text__c.trim().toUpperCase())){
        	System.debug(LoggingLevel.INFO, 'The Stop Keyword found');
        	if(incomingSMS.DeltakSRPSMS__Contact__c != null){
				updateContact(incomingSMS, false);
	        }
        	if(incomingSMS.DeltakSRPSMS__Lead__c != null){
				updateLead(incomingSMS, false);
	        }		        
        }
    	

        Map<String, DeltakSRP_SMSStartWords__c>  theStartSMS = DeltakSRP_SMSStartWords__c.getall();
        System.debug(LoggingLevel.INFO, 'theStartSMS'+theStartSMS);
        if(theStartSMS.containsKey(incomingSMS.smagicinteract__SMS_Text__c.trim().toUpperCase())){
        	System.debug(LoggingLevel.INFO, 'The Start Keyword found');
        	if(incomingSMS.DeltakSRPSMS__Contact__c != null){
				updateContact(incomingSMS, true);
	        }
        	if(incomingSMS.DeltakSRPSMS__Lead__c != null){
				updateLead(incomingSMS, true);
	        }		        
        }
    }

    public static void  updateContact(smagicinteract__Incoming_SMS__c incomingSMS, boolean receiveMessage){
	    Contact contacts = [Select id, DeltakSRPSMS__Ok_To_Text__c from Contact where id =: incomingSMS.DeltakSRPSMS__Contact__c];
    	if(receiveMessage){
    		contacts.DeltakSRPSMS__Ok_To_Text__c = true;
    	}else{
    		contacts.DeltakSRPSMS__Ok_To_Text__c = false;	
    	}
    	update contacts;
    	System.debug(LoggingLevel.INFO, 'Contacts Updated');
    }

    public static void  updateLead(smagicinteract__Incoming_SMS__c incomingSMS, boolean receiveMessage){
    	Lead lead = [Select id, DeltakSRPSMS__Ok_To_Text__c from Lead where id =: incomingSMS.DeltakSRPSMS__Lead__c];
    	if(receiveMessage){
    		lead.DeltakSRPSMS__Ok_To_Text__c = true;
    	}else{
    		lead.DeltakSRPSMS__Ok_To_Text__c = false;	
    	}
    	update lead;
    	System.debug(LoggingLevel.INFO, 'Lead Updated');
    }

	
}