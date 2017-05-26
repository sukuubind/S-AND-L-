trigger SRPOpportunityAfterOwnerUpdateTrigger on Opportunity (after update) {
    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityAfterOwnerUpdateTrigger__c); 
     
    if(bypassTrigger)   return;
    
    Map<Id, Contact> ContactIdtoContactMap = new Map<Id, Contact>();
    List<Id> contactIds = new List<Id>();
    List<Contact> contactsToUpdate = new List<Contact>();
    Map<Id, Boolean> prospectSupportedAccount = new Map<Id, Boolean>();
        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        List<String> supportedAccountRecordTypes = new List<String>();
        supportedAccountRecordTypes.add(ProspectConstants.SRP_ACCOUNT_RECORDTYPE);
        supportedAccountRecordTypes.add(ProspectConstants.SRM_ACCOUNT_RECORDTYPE);
        List<Account> accountList = [Select Id, PRO_Distribution_End_Hours__c, PRO_Distribution_Hours_End_Minutes__c, 
                                            PRO_Distribution_Hours_Escalation_Minute__c, PRO_Distribution_Hours_Start_Minutes__c,
                                            PRO_Distribution_Start_Hours__c, PROspect_Enabled__c from Account
                                            Where Account.RecordType.DeveloperName IN :supportedAccountRecordTypes];
                                            
                                            
        for(Account thisAccount : accountList){
            prospectSupportedAccount.put(thisAccount.Id, thisAccount.PROspect_Enabled__c);
        }
    
    
    //User u = [Select Id from User where FirstName='SRP Lead' and LastName='Engine' LIMIT 1];
    DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
    Id leadEngineUserid = null;
    
    
    RecordType rt = [Select Id from RecordType where name= 'SRP Opportunity' LIMIT 1];
    List<Id> OpportunityIds = new List<Id>();
    for(Opportunity o: Trigger.New){
        if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(o.AccountId) && prospectSupportedAccount.get(o.AccountId)){
            leadEngineUserid = setting.PROspect_User_ID__c;
        }else{
            leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
        }
        
    	system.debug('leadEngineUserid>>>>'+leadEngineUserid);
        
        if(Trigger.oldMap.get(o.id).ownerId == leadEngineUserid 
                && (Trigger.oldMap.get(o.Id).ownerid != o.ownerid)
                && o.RecordTypeId == rt.id){
            system.debug('Trigger.oldMap.get(o.id).ownerId>>>>leadengineuserid>>>>'+Trigger.oldMap.get(o.id).ownerId+'>>>>'+leadEngineUserid);  
            system.debug('o.stagename>>>>'+o.stagename);
            contactIds.add(o.DeltakSRP__Student__c);
            OpportunityIds.add(o.id);
        }   
    }
    
    
    if(OpportunityIds .size() >0){
        List<DeltakSRP__Student_Online_Application__c> apps = [Select Id, DeltakSRP__Affiliation_Opportunity__r.ownerid,DeltakSRP__Affiliation_Opportunity__r.SRP_Owner_Email__c, ownerId,DeltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.Id,DeltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.Email from DeltakSRP__Student_Online_Application__c where DeltakSRP__Affiliation_Opportunity__c in :OpportunityIds];
	    List<DeltakSRP__Student_Online_Application__c> appsToUpdate = new List<DeltakSRP__Student_Online_Application__c>();
	    
	    for(DeltakSRP__Student_Online_Application__c a: apps){
	    	DeltakSRP__Student_Online_Application__c app = new DeltakSRP__Student_Online_Application__c(Id = a.id);
	    	app.Opportunity_Owner__c = a.DeltakSRP__Affiliation_Opportunity__r.ownerid;
	    	if(a.DeltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.Id == null){
                app.SRP_Unlock_Email_Recepient__c= a.DeltakSRP__Affiliation_Opportunity__r.ownerid;
                app.SRP_Unlock_Request_Email__c  = a.DeltakSRP__Affiliation_Opportunity__r.SRP_Owner_Email__c;
            }else
            {
            	app.SRP_Unlock_Email_Recepient__c= a.DeltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.Id;
            	app.SRP_Unlock_Request_Email__c  = a.DeltakSRP__Affiliation_Opportunity__r.Admissions_Manager__r.Email;
            }
	    	appsToUpdate.add(app);
	    }
	    
	    system.debug('appsToUpdate>>>>'+appsToUpdate);
	    if(appsToUpdate.size()>0)
	    	update appsToUpdate;
    }
    
    if(contactIds.size() > 0){
    
	    List<Contact> contacts = [Select Id, ownerId from Contact where ID in :contactIds];
	    
	    for(Contact c: contacts){
	        ContactIdToContactMap.put(c.Id, c);
	    }
	    
	    
	    for(Opportunity o: Trigger.New){
	        Contact c = contactIdToContactMap.get(o.DeltakSRP__Student__c); 
	        if(c != null){
	            c.OwnerId = o.ownerId;
	            contactsToUpdate.add(c);
	        }
	    }
	    
	    if(contactsToUpdate.size()>0)
	        update ContactsToUpdate;
    }        
}