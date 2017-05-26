public without sharing class SRPAttachmentTriggerHandler {
	
	public static void sendAttachmentEmail(List<Attachment> triggerList){
		Map<Id, Id> attMap = new Map<Id, Id>();
		 List<Id> onlineAppIdList = new List<Id>();
		 List<DeltakSRP__Student_Online_Application__c> soalist = new List<DeltakSRP__Student_Online_Application__c>();
		 for(Attachment a : triggerList){
	      if(getObjectType(a.parentId) != 'Student Online Application')
	        continue;
	      else{
	        onlineAppIdList.add(a.ParentId);
	        attmap.put(a.parentId,a.Id);
	      }
	     }
	    
	    soalist = [Select SRP_Unlock_Request_Email__c, deltaksrp__submitted__c, SRP_Application_Emails_Sent__c, deltakSRP__Affiliation_Opportunity__r.owner.email, 
	    			deltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.email, SRP_Attachment_Email_Sent__c
	    			from DeltakSRP__Student_Online_Application__c where Id in: onlineAppIdList];
	    
	    List<DeltakSRP__Student_Online_Application__c> soalist2 = new List<DeltakSRP__Student_Online_Application__c>();
	    for(DeltakSRP__Student_Online_Application__c soa : soalist){
	    	system.debug('soa.deltaksrp__submitted__c>>>>'+soa.deltaksrp__submitted__c);
	    	if(soa.SRP_Application_Emails_Sent__c == true && soa.SRP_Attachment_Email_Sent__c == false && soa.deltaksrp__submitted__c == false){
	    		//sendemailforAttachment(soa, attmap.get(soa.Id));
	    		DeltakSRP__Student_Online_Application__c app = new DeltakSRP__Student_Online_Application__c();
	    		app = soa;
	    		app.SRP_Attachment_Email_Sent__c = true;
			    soalist2.add(app);
	    	}
	    }
	    
	    if(soalist.size()>0)
	    	update soalist2;
	}
	
	
	/*public static void sendEmailforAttachment(DeltakSRP__Student_Online_Application__c app, Id attachmentid){
	
			String emailaddress;
				
			emailaddress = app.SRP_Unlock_Request_Email__c;
				
			Contact c =  [select id, Email from Contact where firstname = 'Pratik' and email <> null limit 1];
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			List<EmailTemplate> et = new List<EmailTemplate> ();
			et = [SELECT id FROM EmailTemplate WHERE developerName = 'SRP_Attachment_Email'];
			
			if(et.size() > 0){ 		
				mail.setSenderDisplayName('Deltak Online Application');
				mail.setTemplateId(et[0].id);
				String[] addr = new String[]{emailaddress}; // max 10 addresses 
		        mail.setToAddresses(addr);
		        mail.setTargetObjectId(c.id);
				mail.setwhatId(attachmentid);
		 		mail.setsaveasactivity(false);
		 		
		 		Savepoint sp = Database.setSavepoint();
		 			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		    	Database.rollback(sp);
		 		
		 		 Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
			     emailToSend.setToAddresses(addr);
			     //emailToSend.setPlainTextBody(mail.getPlainTextBody());     
			     emailToSend.setHTMLBody(mail.getHTMLBody());
		         emailToSend.setSubject(mail.getSubject());
			     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailtosend});
			     
			     app.SRP_Attachment_Email_Sent__c = true;
			     update app;
			}  
		}*/
	
	 public static void copyOpportunityApplicationTemplates(List<Attachment> triggerList){
		 Map<String, Id> descMap = new Map<String, Id>();
	    Map<Id, List<Attachment>> oppAttachMap = new Map<Id, List<Attachment>>();
	    List<String> aDescription = new List<String>();
	    List<Id> onlineAppIdList = new List<Id>();
	    for(Attachment a : triggerList){
	      if(getObjectType(a.parentId) != 'Student Online Application')
	        continue;
	      else{
	        onlineAppIdList.add(a.ParentId);
	        aDescription.add(a.Description);
	      }
	    }
	    Map<Id, DeltakSRP__Student_Online_Application__c> appList = new Map<Id, DeltakSRP__Student_Online_Application__c>([SELECT DeltakSRP__Affiliation_Opportunity__c FROM DeltakSRP__Student_Online_Application__c WHERE Id IN :onlineAppIdList]);
	    for(Attachment a : triggerList){
	    	
	      if(getObjectType(a.parentId) != 'Student Online Application')
	        continue;
	        
	      List<Attachment> attachList = (oppAttachMap.get(appList.get(a.ParentId).DeltakSRP__Affiliation_Opportunity__c) != null) ? oppAttachMap.get(appList.get(a.ParentId).DeltakSRP__Affiliation_Opportunity__c) : new List<Attachment>();
	      attachList.add(a);
	      oppAttachMap.put(appList.get(a.ParentId).DeltakSRP__Affiliation_Opportunity__c, attachList);
	    }
	    system.debug('oppAttachMap.keySet()>>>>'+oppAttachMap.keySet());
	    List<DeltakSRP__Program_Admission_Document__c> oppDocumentList = [SELECT Id, DeltakSRP__Status__c,DeltakSRP__Opportunity__c, DeltakSRP__Ext_Program_Admission_Template__c FROM DeltakSRP__Program_Admission_Document__c WHERE DeltakSRP__Opportunity__c IN :oppAttachMap.keySet()];
	    Map<Id, DeltakSRP__Program_Document_Config__c> docConfigMap = new Map<Id, DeltakSRP__Program_Document_Config__c>([SELECT Id, DeltakSRP__Ext_Program_Admission_Template__c FROM DeltakSRP__Program_Document_Config__c WHERE Id IN :aDescription]);
	      system.debug('docConfigMap>>>>'+docConfigMap);
	      system.debug('oppDocumentList>>>>'+oppDocumentList);
	      system.debug('appList>>>>'+appList);
	      //Triple nested loop....what is this crap?
	      for(Id oppId : oppAttachMap.keySet()){
	        List<Attachment> attachmentList = oppAttachMap.get(oppId);
	        for(Attachment a : attachmentList){
	          DeltakSRP__Program_Document_Config__c docConfig = docConfigMap.get(a.Description);
	          for(DeltakSRP__Program_Admission_Document__c doc : oppDocumentList){
	            if(doc != null && docConfig != null && doc.DeltakSRP__Opportunity__c == oppId && doc.DeltakSRP__Ext_Program_Admission_Template__c == docConfig.DeltakSRP__Ext_Program_Admission_Template__c){
	              doc.DeltakSRP__Date_Received__c = Date.Today();
	              doc.DeltakSRP__Admission_Document__c = a.Id;
	            }
	          }
	        }
	      }
	      update oppDocumentList;
	 }    
	 
	 private static String getObjectType(String parentId){
    String prefix;
     Schema.SObjectType result;
       map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();   
      map<String, String> prefixMap = new map<String, String>();
       for (Schema.SObjectType ot : gd.values())
       {
          prefix = ot.getDescribe().getKeyPrefix();
          if (prefix != null)
          {
             prefixMap.put(prefix, ot.getDescribe().getLabel());
          }
     }
     if(parentId != null){
         String sub = String.valueOf(parentId).substring(0, 3);
         return prefixMap.get(sub);
     }else{
           return null;
       }
  }
}