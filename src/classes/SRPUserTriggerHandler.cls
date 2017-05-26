public with sharing class SRPUserTriggerHandler {

	public SRPUserTriggerHandler()
	{
	
	}
	
	public void handleAfterInsert(List<User> newUsers)
	{
		
		DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
    	Id leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
    	
    	Prospect_Setting__c setting = Prospect_Setting__c.getInstance();
    	Id prospectEngineUserid = setting.PROspect_User_ID__c;

    	List<Id> portalUserContactIds = new List<Id>();

	    for(User u : newUsers)
	    {
	        if(u.IsPortalEnabled)
	        {
	            portalUserContactIds.add(u.ContactId);
	        }
	    }
		
		
		
		
	    if(portalUserContactIds.size() > 0)
	    {
	    
	        List<Contact> contactsToUpdate = new List<Contact>();
	    
	        contactsToUpdate = [SELECT Id, OwnerId, accountid, account.prospect_enabled__c FROM Contact WHERE Id IN :portalUserContactIds];
	    
	        if(contactsToUpdate.size() > 0)
	        {
	            for(Contact c :contactsToUpdate)
	            {
	            	if(c.account.prospect_enabled__c)
	                	c.OwnerId = prospectEngineUserid;
	                else
	                	c.ownerid = leadengineuserid;	
	            }
	        
	            update contactsToUpdate;
	        }
	    
	    }
		
	}

}