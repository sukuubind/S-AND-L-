trigger SRPOpportunityAfterAdmMgrUpdate on Opportunity (after update) {
	
	Id rtSRPOpportunityId = (Schema.SObjectType.Opportunity).getRecordTypeInfosByName().get('SRP Opportunity').getRecordTypeId();

	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
	    Boolean bypassTrigger = triggerOverride != null && 
	    (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityAfterUpdateTrigger__c); 
	
	if(triggerOverride != null)
	{
	  System.debug('triggerOverride >---> '+triggerOverride);     
	}
	
	if(bypassTrigger)   return;
	
	Set<Id> opptyAdmMgrUpdated = new Set<Id>();
	
	for(Opportunity opp : Trigger.New)
	{
  		Opportunity oldOpp = Trigger.OldMap.get(opp.Id);
  		if(opp.Admissions_Manager__c!=null && oldOpp.Admissions_Manager__c != opp.Admissions_Manager__c && opp.RecordTypeId == rtSRPOpportunityId)
  		{
  			opptyAdmMgrUpdated.add(opp.Id);
  		}
	}
	if(opptyAdmMgrUpdated!=null && opptyAdmMgrUpdated.size()>0)
	{
		 List<DeltakSRP__Student_Online_Application__c> soaUpd = new List<DeltakSRP__Student_Online_Application__c>();
		 List<DeltakSRP__Student_Online_Application__c> appList = [Select id, srp_unlock_email_recepient__c, DeltakSRP__Affiliation_Opportunity__r.Admissions_manager__c
	                                    from DeltakSRP__Student_Online_Application__c where DeltakSRP__Affiliation_Opportunity__c in : opptyAdmMgrUpdated];
		
		if(appList!=null && appList.size()>0)
		{
			for(DeltakSRP__Student_Online_Application__c app: appList)
			{
				DeltakSRP__Student_Online_Application__c updApp = new DeltakSRP__Student_Online_Application__c(id=app.id);
				updApp.srp_unlock_email_recepient__c = app.DeltakSRP__Affiliation_Opportunity__r.Admissions_manager__c;
				soaUpd.add(updApp);
			}
			
			Database.update(soaUpd);
		}
		
	}
    
}