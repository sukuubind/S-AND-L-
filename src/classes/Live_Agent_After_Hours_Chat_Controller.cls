public without sharing class Live_Agent_After_Hours_Chat_Controller {

	public Boolean isAfterHoursUser {get;set;}
	public User currUser {get;set;}
	public Boolean foundErrors {get;set;}
	public Boolean showMessages {get;set;}
	public Boolean inAfterHoursWindow {get;set;}
	public Boolean successFlag {get; set;}
	public Boolean switchProfile {get;set;}
	public Boolean showHeader {get;set;}
	public String contentType {get;set;}
	public String profileUpdateMessage {get;set;}
	
	public Id afterHoursProfileId {get;set;}
	public Id normalHoursProfileId {get;set;}
	
	private String operation {get;set;}
	private String userId {get;set;}
	private String profileId {get;set;}
	private String isAfterHoursEnabled {get;set;}
	
	public Live_Agent_After_Hours_Chat_Controller() {
		
		this.operation = ApexPages.currentPage().getParameters().get('op');
		this.showMessages = false;
		this.successFlag = false;
		
		if(this.operation != null && this.operation == 'switchProfile')
		{	
			this.contentType = 'text/plain';
			this.inAfterHoursWindow = false;
			this.isAfterHoursUser = false;
			this.foundErrors = false;
			this.switchProfile = true;
			this.showHeader = false;
			
			this.userId = ApexPages.currentPage().getParameters().get('userId');
			this.profileId = ApexPages.currentPage().getParameters().get('profileId');
			this.isAfterHoursEnabled = ApexPages.currentPage().getParameters().get('isAfterHoursEnabled');
			refreshCurrentUser();
			
		}
		else
		{
			this.contentType = 'text/html';
			this.foundErrors = false;
			this.inAfterHoursWindow = false;
			this.switchProfile = false;
			this.showHeader = true;
			
			this.userId = UserInfo.getUserId();
			refreshCurrentUser();
			
			if(this.currUser != null && this.currUser.Is_After_Hours_User__c)
			{
				this.isAfterHoursUser = true;	
			}
			else
			{
				this.isAfterHoursUser = false;
			}
		}
		
		if(this.isAfterHoursUser)
		{
			
			try {
				afterHoursProfileId = Id.valueOf(this.currUser.After_Hours_Profile_Id__c);
			}catch(Exception e){
				this.foundErrors = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid After Hours Profile Id.'));
			}
			
			try {
				normalHoursProfileId = Id.valueOf(this.currUser.Normal_Hours_Profile_Id__c);
			}catch(Exception e){
				this.foundErrors = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Normal Hours Profile Id.'));
			}
			
			if(this.currUser.After_Hours_Cluster__c == null || this.currUser.After_Hours_Cluster__c == '')
			{
				this.foundErrors = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid After Hours Cluster.'));
			}
				
		}
		
	}
	
	public PageReference checkUserInAfterHoursWindow() {
		
		if(this.operation != null && this.operation == 'switchProfile')
		{
			if(this.currUser != null)
			{
				updateAfterHoursMode();
			}
			else
			{
				this.profileUpdateMessage = 'error: no User found';
				System.debug('updateProfile Error >---> ' + this.profileUpdateMessage);
			}
			
		}
		else
		{
		
			if(this.foundErrors == false && this.isAfterHoursUser)
			{
				
				try {
					
					
					if(isWithinAfterHours())
					{
						this.inAfterHoursWindow = true;
					}
					else
					{
						this.inAfterHoursWindow = false;
						this.foundErrors = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Outside After Hours Window.'));
					}
					
					
				} catch(Exception e) {
					this.foundErrors = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not retrieve After Hours Schedule.'));
				}
				
			}
		}
		
		return null;
		
	}
	
	public PageReference callUpdateAfterHoursMode() {
		
		System.debug('Entering callUpdateAfterHoursMode function');
		
		String chosenProfileId = '';
		String isAfterHoursEnabledString = '';
		this.successFlag = false;
		
		PageReference pg = ApexPages.currentPage();
		pg.setRedirect(true);
		
		Boolean isWithinAfterHours = false;
		try {
		
			isWithinAfterHours = isWithinAfterHours();
		
		} catch(Exception e) {
			
			this.showMessages = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not retrieve After Hours Schedule.'));
			
			return null;
			
		}
		
		if(isWithinAfterHours)
		{
			if(this.afterHoursProfileId != null && this.currUser.Is_After_Hours_Enabled__c)
			{
				chosenProfileId = afterHoursProfileId;
				isAfterHoursEnabledString = 'true';
			}
			else if(this.normalHoursProfileId != null && !this.currUser.Is_After_Hours_Enabled__c)
			{
				chosenProfileId = normalHoursProfileId;
				isAfterHoursEnabledString = 'false';
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not enable after hours mode. Profile Id Error. Please contact a system administrator.'));
				this.showMessages = true;
				return null;
			}
			
			HttpRequest req = new HttpRequest();
			String httpCallUrl = Label.Live_Agent_Site_Url + '?op=switchProfile&userId=' 
	     					+ this.userId + '&profileId=' + chosenProfileId + '&isAfterHoursEnabled=' + isAfterHoursEnabledString;
	     	System.debug('httpCallUrl >---> ' + httpCallUrl);
	     	req.setEndpoint(httpCallUrl);
	     	req.setMethod('GET');
			
			Http http = new Http();
			String resBody = '';
			if(System.Test.IsRunningTest() == false)
			{
	     		HTTPResponse res = http.send(req);
	     	    resBody = res.getBody();
			}
			else
			{
				resBody = 'updatedProfile';
			}
			
	     	System.debug(resBody);
	     	
	     	if(resBody == 'updatedProfile')
	     	{
	     		
	     		refreshCurrentUser();
	     		
	     		if(this.currUser.Is_After_Hours_Enabled__c)
	     		{
	     			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Successfully enabled after hours mode!'));
	     			this.successFlag = true;
	     		}
	     		else
	     		{
	     			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Successfully disabled after hours mode!'));
	     			this.successFlag = true;
	     		}
	     	}
	     	else
	     	{
	     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not enable after hours mode. Could not get a good response from site page. Please contact a system administrator.'));
	     	}
			
			this.showMessages = true;
		
	}
	else
	{
		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not in After Hours.'));
		this.showMessages = true;
		
		return null;
		
	}
		
		return null;
	}
	
	public void updateAfterHoursMode() {
		
		//this.currUser.Check_Live_Agent_After_Hours__c = false;
		//this.currUser.Is_After_Hours__c = '';
		
		if(this.isAfterHoursEnabled == null || this.isAfterHoursEnabled.toLowerCase() != 'true')
		{
			this.currUser.Is_After_Hours_Enabled__c = false;
		}
		else
		{
			this.currUser.Is_After_Hours_Enabled__c = true;
		}
		
		if(this.profileId != null)
		{
			try {
				
				this.currUser.ProfileId = this.profileId;
				System.debug('currUser >---> ' + this.currUser);
		
				try {
					update this.currUser;
					this.profileUpdateMessage = 'updatedProfile';
				} catch (Exception e) {
					this.profileUpdateMessage = 'error';
					System.debug('updateProfile Error >---> ' + e);
				}
		
			} catch (Exception e) {
				this.profileUpdateMessage = 'error: Invalid Profile Id';
				System.debug('updateProfile Error >---> ' + e);
			}
		}
		
	}
	
	private Boolean isWithinAfterHours()
	{
		
		String bhName = 'After Hours Live Agent Chat - ' + this.currUser.After_Hours_Cluster__c;
		
		BusinessHours bh = [SELECT Id FROM BusinesSHours WHERE Name = :bhName LIMIT 1];
					
		DateTime dt = DateTime.now();
		
		Datetime targetTime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second());
		
		return BusinessHours.isWithin(bh.Id,targetTime);
	}
	
	private void refreshCurrentUser() {
		try {
			this.currUser = [SELECT Id, Is_After_Hours_Enabled__c, ProfileId, After_Hours_Profile_Id__c, Normal_Hours_Profile_Id__c, 
			Is_After_Hours_User__c, After_Hours_Cluster__c FROM User
					WHERE Id = :this.userId AND Is_After_Hours_User__c = TRUE AND UserPermissionsLiveAgentUser = TRUE LIMIT 1];
					
		} catch(Exception e){
			this.currUser = null;
		}
	}

}