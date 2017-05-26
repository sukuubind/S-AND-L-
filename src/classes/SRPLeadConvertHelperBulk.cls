/**
     * SRMLeadConvertHelperBulk
     * @description Class for converting leads automatically from the lead trigger in bulk
     * @author Pratik Tanna
     * @date 09/08/2014
*/

public without sharing class SRPLeadConvertHelperBulk {

 	@future(callout=true)
 	public static void convertleadCallout(Map<Id,String> leadToStageMap, Map<Id,Id> LeadIdToExistingOppOwnerId){

		List<Automated_Deployment_Credentials__c> adc = new List<Automated_Deployment_Credentials__c>();
		adc=[Select username__c, password__c, token__c from Automated_Deployment_Credentials__c where name =:Label.Development_Organization_Name];

		String username, password; 

		if(adc.size()>0){
		    username = adc[0].username__c;
		    password = adc[0].password__c + adc[0].token__c;
		}


		partnerSoapSforceCom.LoginResult loginResult;
		partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
		//if(!Test.isRunningTest())
			loginResult = sp.login(username, password);
		/*else{
			loginresult = new partnerSoapSforceCom.LoginResult();
			loginresult.serverurl = 'https://cs10.salesforce.com/services/Soap/u/32.0/00DJ0000001Mcdw';
			loginresult.sessionid = '00DJ0000001Mcdw!ARIAQIDzv6mmEkgNn1ZPAQM7YkzqaPxy5YPBCeal8RwT_88g1mKKyd_TdQdP2cuEf1ZFr4tnjzFzUGRzxNS4WpI6TrV86rq2';
		}*/
		system.debug('loginResult>>>>'+loginResult);

		if(loginresult!=null)
			convertLeadAfterLogin(loginresult.sessionid, loginresult.serverurl, leadtostagemap, LeadIdToExistingOppOwnerId);

 	}


	public Static void convertLeadAfterLogin(String sessionid, String ServerUrl, Map<Id,String> leadToStageMap, Map<Id, Id> LeadIdToExistingOppOwnerId){

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
		List<Lead> leadlist = [Select Id, SRP_Retain_Ownership__c, deltakSRP__Send_Email_On_Convert__c, OwnerId, deltakSRP__Contact__c, rfi_campaign_code__c, DeltakSRP__Academic_Institution_Lookup__c from Lead where id in:  leadToStageMap.keyset()];

 		LeadStatus status = [Select Id,MasterLabel From LeadStatus Where IsConverted=true Limit 1];
 		RecordType rt = [Select Id from RecordType where DeveloperName = 'SRP_Opportunity' and SobjectType = 'Opportunity'];

 		List<Campaign> clist = new List<Campaign>();
 		Map<String, Id> campCodeTOIdMap = new Map<String, Id>();
 		List<String> campaignCodes = new List<String>();

 		for(Lead l: leadlist){
 			campaignCodes.add(l.rfi_campaign_code__c);
 		}

 		clist = [Select Id,Campaign_code__c from Campaign where Campaign_code__c in: campaignCodes AND Lowest_Level_in_Hierarchy__c = true
                                             AND StartDate < :System.today()
                                             AND EndDate >= :System.today()
                                             And IsActive = true];

 		for(Campaign c: clist){
 			campCodeTOIdMap.put(c.Campaign_code__c, c.id);
 		}

 		String convertedstatus;
 		if(status != null)
 			convertedstatus = status.MasterLabel;
 		List<partnerSoapSforceCom.LeadConvert> lcList = new List<partnerSoapSforceCom.LeadConvert>();

        List<Lead> newleads = new List<Lead>();
        for(Lead l :leadlist){
        	if(LeadIdToExistingOppOwnerId.get(l.id) != null){
        		system.debug('inside retain ownership>>>>');
        		Lead newLead = new Lead(id=l.id);
	           	l.SRP_retain_ownership__c = true;
	           	l.ownerid = LeadIdToExistingOppOwnerId.get(l.id);
	           	newleads.add(newLead);
        	}
        }

        //if(newLeads.size()>0) update newleads;

        for(Lead l :leadlist){
        	system.debug('l.id>>>>'+l.id);
            partnerSoapSforceCom.LeadConvert lc = new partnerSoapSforceCom.LeadConvert();
            lc.leadid=l.Id;
            lc.ConvertedStatus=convertedstatus;
            lc.AccountId=l.DeltakSRP__Academic_Institution_Lookup__c;
            lc.ContactId=l.deltakSRP__Contact__c;
           	lc.doNotCreateOpportunity = false;

           	system.debug('LeadIdToExistingOppOwnerId>>>>'+LeadIdToExistingOppOwnerId);

           	if(LeadIdToExistingOppOwnerId.get(l.id) != null){
           	  system.debug('inside retain ownership>>>>');
           	  l.SRP_retain_ownership__c = true;
           	  l.ownerid = LeadIdToExistingOppOwnerId.get(l.id);
           	  lc.OwnerId=l.OwnerId;
           	}

           	//if(l.ownerid != null){
            //	lc.OwnerId=l.OwnerId;
           	//}

            if(l.OwnerId != UserInfo.getUserId())
               lc.SendNotificationEmail=l.deltakSRP__Send_Email_On_Convert__c;
            else
                lc.SendNotificationEmail=false;

            lc.OverwriteLeadSource=true;
            //lc.setOpportunityName(newOppName);
            lcList.add(lc);
	    }

		partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
		//soapSforceCom200608Apex.Apex apexWebSvc = new soapSforceCom200608Apex.Apex();
		//soapSforceCom200608Apex.SessionHeader_element sessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
        //apexWebSvc.timeout_x = 120000;
		//apexWebSvc.SessionHeader = sessionHeader;

		//sessionHeader.sessionId = sessionId;
		sp.SessionHeader = new partnerSoapSforceCom.SessionHeader_element();
	    sp.endpoint_x = ServerUrl;
	    sp.Sessionheader.sessionid = sessionid;
        // The Web services have a maximum timeout of 2 minutes. The timeout value is in milliseconds.
        sp.timeout_x = 120000;


		try{
		List<partnerSoapSforceCom.LeadConvertResult>results;
		if(!Test.isRunningTest())
			results = sp.convertlead(lclist);
		else{
			partnerSoapSforceCom.Leadconvertresult lcresult = new partnerSoapSforceCom.Leadconvertresult();
			lcresult.success = true;
			//results.add(lcresult);
		}
		system.debug('leadconvertresult>>>>'+results);

	    Map<Id, Lead> LeadIdToLeadMap = new Map<Id, Lead>();
	    List<Id> LeadIds = new List<Id>();
	    List<Id> OpportunityIds = new List<Id>();
	    List<Contact> contactsToUpdate = new List<Contact>();
	    List<Opportunity> oppsToUpdate = new List<Opportunity>();

	    for(partnerSoapSforceCom.LeadConvertResult result: results){
	    	leadIds.add(result.leadid);
	    	OpportunityIds.add(result.OpportunityId);
	    }

	    List<Lead> leads = [Select rfi_campaign_code__c, deltakSRP__contact__c, deltakSRP__contact__r.deltakSRP__Person__c, email,donotcall, hasoptedoutofemail, DeltakSRPSMS__Ok_To_Text__c, company from Lead where id in: leadIds];

	    for(lead l : leads){
	    	LeadIdToLeadMap.put(l.Id, l);
	    }

        List<Opportunity> newopps = [Select Id, accountid, createdbyid, ownerid, SRP_Retain_Ownership__c,DeltakSRP__webschedulerstatus__c, DeltakSRP__WebScheduler_Email__c, DeltakSRP__Email__c, campaignid, stagename, DeltakSRP__Student__r.DeltakSRP__Person__c, DeltakSRP__Sub_Stage__c, SRP_Person__c from Opportunity where Id in: OpportunityIds];
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
		for(Opportunity o: newOpps){
			oppMap.put(o.id, o);
		}

		for(partnerSoapSforceCom.LeadConvertResult result: results){
	            if(result.Success){
	               Id oppId = result.OpportunityId;
	               Id leadid = result.leadid;

	               system.debug('oppId>>>>'+oppId);

	               //Opportunity newopp = [Select ownerid, SRP_Retain_Ownership__c,DeltakSRP__webschedulerstatus__c, DeltakSRP__WebScheduler_Email__c, DeltakSRP__Email__c, campaignid, stagename, DeltakSRP__Student__r.DeltakSRP__Person__c, DeltakSRP__Sub_Stage__c, SRP_Person__c from Opportunity where Id=:oppid];
	               //Opportunity newOpp = new Opportunity(Id=oppid);
	               Opportunity newOpp = oppMap.get(oppID);
	               system.debug('newOpp>>>>'+newOpp);
	               for(Lead l: leadlist){
	               	system.debug('l.id>>>>'+l.id);
	               	system.debug('leadid>>>>'+leadid);
	               	if(l.id == result.LeadId){
	               		newOpp.StageName = leadTOStageMap.get(l.id);
	               		if(LeadIdToExistingOppOwnerId.get(l.id) != null)
	               			newopp.srp_retain_ownership__c = true;

	               		if(OppMap.get(oppid).DeltakSRP__Student__c != null)
	               			newOpp.SRP_Person__c = OppMap.get(oppid).DeltakSRP__Student__r.DeltakSRP__Person__c;
	               	}

	               }

	               if(newOpp.stageName == Label.Opportunity_Dormant_Stage_Name)
	               	newOpp.DeltakSRP__Sub_Stage__c = Label.Opportunity_Dormant_SubStage_Name;

	               newOpp.is_converted__c = true;

	               newOpp.RecordTypeId = rt.Id;

	               DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
				   Id leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
				   system.debug('leadEngineUserid>>>>'+leadEngineUserid);
	               system.debug('newopp.createdbyid>>>>'+newopp.createdbyid);
	               
	               if(newopp.srp_retain_ownership__c ==false && prospectSupportedAccount != null && prospectSupportedAccount.containsKey(newOpp.AccountId) && prospectSupportedAccount.get(newOpp.AccountId)==true){
	               	    newOpp.OwnerId = setting.PROspect_User_ID__c;
	               	    system.debug('newOpp.OwnerId1>>>>'+newOpp.OwnerId);
	               }else{
		               if(newOpp.OwnerId != newopp.createdbyid && newopp.srp_retain_ownership__c == false)
		               	newOpp.OwnerId = leadengineuserid;
	               }
	               system.debug('newOpp.OwnerId>>>>'+newOpp.OwnerId);

	               if(newOpp.DeltakSRP__Email__c!=null && newopp.DeltakSRP__webschedulerstatus__c == 'New' && newOpp.DeltakSRP__Email__c != LeadIdToLeadMap.get(leadid).email)
	               		newOpp.DeltakSRP__WebScheduler_Email__c = LeadIdToLeadMap.get(leadid).email;

	               if(clist.size()>0)
	                newopp.campaignid = campcodetoIdMap.get(LeadIdToLeadMap.get(leadid).rfi_campaign_Code__c);

	               //update newOpp;
	               oppstoUpdate.add(newopp);

	               if(LeadIdToLeadMap.get(leadid).deltakSRP__contact__c != null){
	                 //contact c = [Select ownerid, donotcall, hasoptedoutofemail, DeltakSRPSMS__Ok_To_Text__c from Contact where Id=:  currentlead.DeltakSRP__Contact__c];
	                 contact c = new Contact(Id=LeadIdToLeadMap.get(leadid).deltakSRP__contact__c);
	                 c.DoNotCall = LeadIdToLeadMap.get(leadid).DoNotCall;
	                 c.HasOptedOutOfEmail = LeadIdToLeadMap.get(leadid).HasOptedOutOfEmail;
	                 c.DeltakSRPSMS__Ok_To_Text__c = LeadIdToLeadMap.get(leadid).DeltakSRPSMS__Ok_To_Text__c;
	                 c.DeltakSRP__Employer_Company__c = LeadIdToLeadMap.get(leadid).Company;

	                 system.debug('c.ownerid>>>>'+c.ownerid);

	                 if(newOpp.ownerid != null)
	                 c.OwnerId = newOpp.ownerid;

	                 contactsToUpdate.add(c);
	                 //c.ownerid = leadExistingOppMap.get(LeadIdToLeadMap.get(leadid)).ownerid;
	                 //update c;

	               }//end if
	            }//end if result success

	        }//end for
		        if(contactstoupdate.size()>0) update contactstoupdate;
		        if(oppstoupdate.size()>0) update oppstoupdate;
	        }catch(Exception ex){
	        	if(!ex.getmessage().contains('Duplicate id in list')){
		        	 system.debug('e.getmessage>>>>'+ex.getmessage());
		             Recordtype rtype = [Select Id from RecordType where developername = 'Lead_Conversion_Error'];
		             DeltakSRP__Error_Log__c errlog = new DeltakSRP__Error_Log__c();
		             errlog.recordtypeid = rtype.id;
		             errlog.DeltakSRP__Type__c = 'Apex';
		             errlog.DeltakSRP__Object__c = 'Lead';
		             errlog.DeltakSRP__Detail__c = system.today() + ' : ' + ex.getmessage();
		             errlog.DeltakSRP__Source_Name__c = 'Lead Conversion: SRPLeadConverHelperBulk.cls';
		             insert errlog;
	        	}
	        }
		//}

    }
    /**
     * @description
     * This method is called from LeadTrigger for converting the associated lead
     * into a Contact / Opportunity
     */
    public static void convertLeads(Map<Lead,String> leadToStageMap, Map<lead, Opportunity> leadExistingOppMap ){
    		system.debug('leadToStageMap>>>>'+leadToStageMap);
    		system.debug('leadExistingOppMap>>>>'+leadExistingOppMap);
    		List<String> rficampcodes = new List<String>();
    		Map<Id,String> campcodesMap = new Map<Id, String>();
    		for(Lead l: leadToStageMap.keySet()){
    			rficampcodes.add(l.rfi_campaign_code__c);
    			campcodesmap.put(l.id, l.rfi_campaign_code__c);
    		}

    		List<Campaign> clist = new List<Campaign>();
    		Map<String, Campaign> campMap = new Map<String, Campaign>();


    		clist = [Select Id, Parent.Name, Campaign_Code__c from campaign where Campaign_Code__c in : rficampcodes and Campaign_Code__c != null and Campaign_Code__c != '' AND Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < :System.today()
                                                AND EndDate >= :System.today()
                                                And IsActive = true];
    		for(Campaign c: clist){
    			campMap.put(c.Campaign_Code__c, c);
    		}
			
			if(clist.size()==0)
    			clist = [Select Id from campaign where Name = : 'Bucket'];
    			
    		List<CampaignMember> cmlist = new List<CampaignMember>();
        	for(Lead l: leadToStageMap.keySet()){
    		try{
	            Lead currentLead = l;
	            system.debug('l.id>>>>'+l.id);
	            if(l.rfi_campaign_code__c != null && campmap.get(l.rfi_campaign_code__c) != null){
	                CampaignMember cmember = new CampaignMember();
	                cmember.leadId = l.Id;
	                cmember.CampaignID = campmap.get(l.rfi_campaign_code__c).Id;
	                cmember.Status='Sent';
	                cmlist.add(cmember);

	                if((campmap.get(campcodesmap.get(l.id)).Parent.Name == 'Conference' && l.DeltakSRP__Inquiry_Rating__c == 'Low') || l.LeadSource=='Mass Upload Lead')
	                	return;
	            }else{

	            	if(clist.size()>0){
	            		CampaignMember cmember = new CampaignMember();
		                cmember.leadId = l.Id;
		                cmember.CampaignID = clist[0].Id;
		                cmember.Status='Sent';
		                cmlist.add(cmember);
		                //database.insert(cmember, false);
	            	}
	            }



    		}catch(Exception e){
	            system.debug('Exception other than DML Exception is Caught>>>>'+e);
	            throw e;
	        }
        }

        system.debug('cmlist.size>>>>'+cmlist.size());
        if(cmlist.size() > 0){
        	system.debug('cmlist>>>>'+cmlist);
        	database.insert(cmlist, false);
        }

        Map<Id, String> leadidtoStageMAp = new Map<Id, String>();
        Map<Id, Id> LeadIdToExistingOppOwnerId = new Map<Id, Id>();
        for(Lead l: leadToStageMap.keySet()){
        	leadIdtoStagemap.put(l.id, leadToStageMap.get(l));
        }
        system.debug('leadIdtoStagemap>>>>'+leadIdtoStagemap);
        for(Lead l: leadExistingOppMap.keyset()){
        	LeadIdToExistingOppOwnerId.put(l.id, leadExistingOppMap.get(l).ownerid);
        }
        system.debug('LeadIdToExistingOppOwnerId>>>>'+LeadIdToExistingOppOwnerId);
        if(!Test.isRunningTest())
        	convertleadcallout(leadIdtoStagemap, LeadIdToExistingOppOwnerId);

	    //Lead convert fields
        /*List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
        for(Lead l :leadToStageMap.keyset()){
            Database.LeadConvert lc = new Database.LeadConvert();
            system.debug('l.id>>>>'+l.id);
            lc.setLeadId(l.Id);
            lc.setConvertedStatus(convertedStatus);
            lc.setAccountId(l.DeltakSRP__Academic_Institution_Lookup__c);
            lc.setContactId(l.deltakSRP__Contact__c);

           	if(l.ownerid != null)
            	lc.setOwnerId(l.OwnerId);

            if(l.OwnerId != UserInfo.getUserId())
                lc.setSendNotificationEmail(l.deltakSRP__Send_Email_On_Convert__c);
            else
                lc.setSendNotificationEmail(false);

            lc.setOverwriteLeadSource(true);
            //lc.setOpportunityName(newOppName);
            lcList.add(lc);
	    }
	    try{
	    List<Database.LeadConvertResult> results = Database.convertLead(lclist);*/

    }
}