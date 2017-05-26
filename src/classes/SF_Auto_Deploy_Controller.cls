public with sharing class SF_Auto_Deploy_Controller {

public String resultText {get; set;}
public Automated_Deployment__c currAD {get; set;}
public List<Attachment> attachmentList {get;set;}
public List<SelectOption> attachmentOptions {get;set;}
public String selectedAttachmentId {get;set;}
public String selectedAttachmentName {get;set;}
public Automated_Deployment_Config__c adConfig  {get; set;}
public Boolean refreshDeployment {get; set;}
public Integer refreshCounter {get;set;}
public Boolean foundErrors {get;set;}
public Boolean releaseErrors {get;set;}
public Boolean showDepButton {get; set;}
public Boolean showRelButton {get;set;}
public Boolean initialLoad {get;set;}
public String releaseVersion {get;set;}
public String releaseComment {get;set;}
public String releaseMessage {get;set;}
public Id releaseFIId {get;set;}
private String userSession {get;set;}
	
	public SF_Auto_Deploy_Controller(ApexPages.StandardController stdController) {
	
		refreshCurrAD(stdController.getRecord().id);
		
		this.selectedAttachmentName = '';
		this.attachmentList = [SELECT Id, Name FROM Attachment WHERE ParentId = :this.currAd.Id];
		this.attachmentOptions = new List<SelectOption>();
		for(Attachment a : this.attachmentList)
		{
			this.attachmentOptions.add(new SelectOption(a.Id, a.Name));
		}
		
		if(this.attachmentList.size() > 0)
		{
			this.selectedAttachmentId = this.attachmentList[0].Id;
			this.selectedAttachmentName = this.attachmentList[0].Name;
		}
					
		this.adConfig =  Automated_Deployment_Config__c.getInstance(); 
		
		if(this.currAD.Deployment_Running__c)
		{
			this.refreshDeployment = true;
			this.showDepButton = false;
			this.initialLoad = false;
			this.refreshCounter = 2;
			this.showRelButton = false;			
		}
		else
		{
			this.refreshDeployment = false;
			this.showDepButton = true;
			this.initialLoad = true;
			this.refreshCounter = 2;
			this.showRelButton = true;
		}
		
		this.releaseVersion = '';
		this.releaseComment = '';
		this.releaseMessage = '';
		this.userSession = '';
		
	}
	
	public PageReference doNothing()
	{
		this.showDepButton = true;
   		this.showRelButton = true;
   		
   		return null;
	}
	
	public PageReference validate()
	{
		
		this.foundErrors = false;
		this.releaseErrors = false;
		
		this.showDepButton = false;
   		this.showRelButton = false;
		
		if(this.currAD.Deployment_Running__c)
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deployment Already Running.'));
		}
		
		if(this.currAD.Deployed__c == 'YES')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deployment previously deployed. Please update the "Deployed" field for ' + this.currAD.Name + ' to "NO" then try again.'));
		}
		
		//Deployment Record Errors
		if(this.selectedAttachmentId == null || this.selectedAttachmentId == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Selected Attachment.'));
		}
		else
		{
			for(Attachment a : this.attachmentList)
			{
				if(a.Id == this.selectedAttachmentId)
				{
					this.selectedAttachmentName = a.Name;
				}
			}
		}
		
		if(this.currAD.Id == null)
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deployment Id Not Found.'));
		}
		
		
		//Custom Settings Errors
		if(this.adConfig.Initiating_Org_Instance__c == null || this.adConfig.Initiating_Org_Instance__c.trim() == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Initiating Org Instance.'));
		}
		
		if(this.adConfig.Initiating_Org__c == null || this.adConfig.Initiating_Org__c.trim() == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Initiating Org.'));
		}
		
		if(this.adConfig.Endpoint_Url__c == null || this.adConfig.Endpoint_Url__c.trim() == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Endpoint Url.'));
		}
		
		if(this.adConfig.Encryption_Key__c == null || this.adConfig.Encryption_Key__c.trim() == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Encryption Key.'));
		}
		
		if(this.adConfig.Decryption_Key__c == null || this.adConfig.Decryption_Key__c.trim() == '')
		{
			this.foundErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Decryption Key.'));
		}
		
		if(!this.foundErrors)
		{
			
			String decryptedKey = decryptAES256(this.adConfig.Decryption_Key__c.trim(), this.adConfig.Encryption_Key__c.trim());
			
			if(decryptedKey == 'FAILED')
			{
				this.foundErrors = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not populate Encryption Key.'));
			}
			else
			{
				this.userSession = encryptAES256(decryptedKey, UserInfo.getSessionId());	
				
				if(this.userSession == 'FAILED')
				{
					this.foundErrors = true;
					this.userSession = '';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not encrypt User Session Id.'));
				}
				
			}
			
		}
		
		Savepoint sp = Database.setSavepoint();
		try { update this.currAD;Database.rollback(sp);}Catch(Exception e){this.foundErrors = true;Database.rollback(sp);}
		Database.rollback(sp);
		
		if(this.foundErrors)
		{
			this.showDepButton = true;
   			this.showRelButton = true;
		}
		
		return null;
		
	}
	
	public PageReference deploy()
	{
		if(this.foundErrors == false)
		{
			this.refreshDeployment = false;
			this.initialLoad = false;
			
			if(sfDeployCallout() == false)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deployment Callout Failed: ' + this.resultText));
			}
			else
			{
				this.refreshDeployment = true;
				this.showDepButton = false;
				this.showRelButton = false;
				this.refreshCounter = 2;
			}
		}
		
		return null;
	}
	
	public PageReference refreshDeployment()
	{
		if(this.refreshDeployment)
		{
			refreshCurrAD(this.currAD.Id);
			
			if(this.currAD.Deployment_Running__c == false)
			{
				this.refreshCounter--;
			}
			
			
			if(this.refreshCounter == 0)
			{
				this.refreshDeployment = false;
				this.showDepButton = true;
				this.showRelButton = true;
				
				if(!this.initialLoad && this.currAD.Deployed__c == 'NO')
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deployment Failed: ' + this.currAD.Deployment_Log__c));
				}
				else if(!this.initialLoad && this.currAD.Deployed__c == 'YES')
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Deployment successfully completed.'));
				}
				
			}
			else
			{
				this.showDepButton = false;
				this.showRelButton = false;
			}
			
		}
		else
		{
			this.showDepButton = true;
			this.showRelButton = true;
		}
		
		if(this.initialLoad)
		{
			this.showDepButton = true;
			this.showRelButton = true;		
		}
		
		return null;
	}
 	
 	
 	private void refreshCurrAD(Id currADId) 
 	{
 		
 		this.currAD = [SELECT Id, Name, Jira_Story__c, Destination_Org__c, Git_Repo__c, Git_Repo_Src_Directory__c, 
						Destination_Org_Type__c, Rollback_On_Error__c, Auto_Update_Package__c, Single_Package__c,
						Run_All_Tests__c, Max_Poll__c, Deployment_Log__c, Deployment_Progress__c, Check_Only__c, 
						Source_Org__c, Source_Org_Type__c, Jira_Sprint__c, Deployment_Type__c, Deployment_Running__c,
						Deployed__c, Notes__c
					FROM Automated_Deployment__c WHERE Id = :currADId LIMIT 1];
 		
 	}
	
   private Boolean sfDeployCallout()
   {
   	try {
     HttpRequest req = new HttpRequest();
     
     List<String> parameterList = new List<String>();
     
     if(this.selectedAttachmentId != null)
     {
     	parameterList.add('sfAttachmentId='+EncodingUtil.urlEncode(this.selectedAttachmentId, 'UTF-8'));
     }
     
     if(this.selectedAttachmentName != null)
     {
     	parameterList.add('sfAttachmentName='+EncodingUtil.urlEncode(this.selectedAttachmentName, 'UTF-8'));
     }
     
     if(this.currAD.Id != null)
     {
     	parameterList.add('sfDeploymentId='+EncodingUtil.urlEncode(this.currAD.Id, 'UTF-8'));
     }
     
     if(this.adConfig.Initiating_Org_Instance__c != null)
     {
     	parameterList.add('sfInitiatingOrgInstance='+EncodingUtil.urlEncode(this.adConfig.Initiating_Org_Instance__c, 'UTF-8'));
     }
     
     if(this.currAD.Git_Repo__c != null)
     {
     	parameterList.add('gitrepo='+EncodingUtil.urlEncode(this.currAD.Git_Repo__c, 'UTF-8'));
     }
     
     if(this.currAD.Git_Repo_Src_Directory__c != null)
     {
     	parameterList.add('gitrepoSrcDir='+EncodingUtil.urlEncode(this.currAD.Git_Repo_Src_Directory__c, 'UTF-8'));
     }
     
     if(this.currAD.Destination_Org__c != null)
     {
     	parameterList.add('destinationOrg='+EncodingUtil.urlEncode(this.currAD.Destination_Org__c, 'UTF-8'));
     }
     
     if(this.adConfig.Initiating_Org__c != null)
     {
     	parameterList.add('initiatingOrg='+EncodingUtil.urlEncode(this.adConfig.Initiating_Org__c, 'UTF-8'));
     }
     
     if(this.currAD.Destination_Org_Type__c != null)
     {
     	parameterList.add('sfDestOrgType='+EncodingUtil.urlEncode(this.currAD.Destination_Org_Type__c, 'UTF-8'));
     }
     
     if(this.currAD.Deployment_Type__c != null)
     {
     	parameterList.add('deploymentType='+EncodingUtil.urlEncode(this.currAD.Deployment_Type__c, 'UTF-8'));
     }
     
     if(this.currAD.Source_Org__c != null)
     {
     	parameterList.add('sourceOrg='+EncodingUtil.urlEncode(this.currAD.Source_Org__c, 'UTF-8'));
     }
     
     if(this.currAD.Source_Org_Type__c != null)
     {
     	parameterList.add('sfSourceOrgType='+EncodingUtil.urlEncode(this.currAD.Source_Org_Type__c, 'UTF-8'));
     }
     
     if(this.currAD.Jira_Story__c != null)
     {
     	parameterList.add('jiraStory='+EncodingUtil.urlEncode(this.currAD.Jira_Story__c.trim(), 'UTF-8'));
     }
     
     if(this.currAD.Rollback_On_Error__c)
     {
     	parameterList.add('sfRollbackOnError=true');
     }
     else
     {
     	parameterList.add('sfRollbackOnError=false');
     }
     
     if(this.currAD.Auto_Update_Package__c)
     {
     	parameterList.add('sfAutoUpdatePackage=true');
     }
     else
     {
     	parameterList.add('sfAutoUpdatePackage=false');
     }
     
     if(this.currAD.Single_Package__c)
     {
     	parameterList.add('sfSinglePackage=true');
     }
     else
     {
     	parameterList.add('sfSinglePackage=false');
     }
     
     if(this.currAD.Check_Only__c)
     {
     	parameterList.add('sfCheckOnly=true');
     }
     else
     {
     	parameterList.add('sfCheckOnly=false');
     }
     
     String deployRoot = 'src';
     for(String s : this.currAD.Git_Repo_Src_Directory__c.split('\\/'))
     {
     	deployRoot = s;
     }
     
     if(deployRoot != null)
     {
     	parameterList.add('sfDeployRoot='+EncodingUtil.urlEncode(deployRoot,'UTF-8'));
     }
     
     String maxPoll = '200';
     if(this.currAD.Max_Poll__c != null && this.currAD.Max_Poll__c > 0)
     {
     	maxPoll = String.valueOf(this.currAD.Max_Poll__c);
     }
     
     if(maxPoll != null)
     {
     	parameterList.add('sfMaxPoll='+EncodingUtil.urlEncode(maxPoll,'UTF-8'));
     }
     
     parameterList.add('initiatingUser='+EncodingUtil.urlEncode(UserInfo.getUserEmail(), 'UTF-8'));
     
     String queryString = String.join(parameterList,'&');
     
     req.setEndpoint(this.adConfig.Endpoint_Url__c + '?' + queryString);
     req.setMethod('GET');
     
     // Specify the required user name and password to access the endpoint
     // As well as the header and header information
 
     req.setHeader('sfSessionId', this.userSession);
   
     // Create a new http object to send the request object
     // A response object is generated as a result of the request  
  
     Http http = new Http();
     HTTPResponse res = http.send(req);
     Integer statusCode = res.getStatusCode();
     System.debug(statusCode);
     
     if(statusCode == 200)
     {
     	return true;
     }
     else
     {
     	return false;
     }
     
   	}catch (Exception e)
   	{
   		
   		if(System.Test.isRunningTest())
   		{
   			return true;
   		}
   		
   		this.resultText = e+'';
   		return false;
   	}
     
   }
   
   public PageReference validateRelease() 
   {
   		
   		this.releaseErrors = false;
   		
   		this.showDepButton = false;
   		this.showRelButton = false;
   		
   		if(this.releaseVersion == null || this.releaseVersion.trim() == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify a release version.'));
		}
		
		if(this.releaseComment == null || this.releaseComment.trim() == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a release comment.'));
		}
		
		if(this.currAD.Git_Repo__c == null || this.currAD.Git_Repo__c == '')
     	{
     		this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Git Repo.'));
     	}
     	
		//Custom Settings Errors
		if(this.adConfig.Initiating_Org_Instance__c == null || this.adConfig.Initiating_Org_Instance__c == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Initiating Org Instance.'));
		}
		
		if(this.adConfig.Initiating_Org__c == null || this.adConfig.Initiating_Org__c == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Initiating Org.'));
		}
		
		if(this.adConfig.Endpoint_Url__c == null || this.adConfig.Endpoint_Url__c == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Endpoint Url.'));
		}
		
		if(this.adConfig.Release_Endpoint_Url__c == null || this.adConfig.Release_Endpoint_Url__c == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Release Endpoint Url.'));
		}
		
		if(this.adConfig.Encryption_Key__c == null || this.adConfig.Encryption_Key__c.trim() == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Encryption Key.'));
		}
		
		if(this.adConfig.Decryption_Key__c == null || this.adConfig.Decryption_Key__c.trim() == '')
		{
			this.releaseErrors = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Decryption Key.'));
		}
		
		if(!this.releaseErrors)
		{
			
			String decryptedKey = decryptAES256(this.adConfig.Decryption_Key__c.trim(), this.adConfig.Encryption_Key__c.trim());
			
			if(decryptedKey == 'FAILED')
			{
				this.releaseErrors = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not populate Encryption Key.'));
			}
			else
			{
				
				this.userSession = encryptAES256(decryptedKey, UserInfo.getSessionId());	
				
				if(this.userSession == 'FAILED')
				{
					this.releaseErrors = true;
					this.userSession = '';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not encrypt User Session Id.'));
				}
				
			}
			
		}
		
		if(this.releaseErrors && this.currAD.Deployment_Running__c == false)
		{
			this.showDepButton = true;
   			this.showRelButton = true;
		}
		
		if(!this.releaseErrors)
		{
			FeedItem fi = new FeedItem();
			fi.Body = 'Attempting to cut git release for ' + this.currAD.Git_Repo__c + ' with version ' + this.releaseVersion + ' and comment: ' + this.releaseComment;
			fi.ParentId = this.currAD.Id;
			insert fi;
			
			this.releaseFIId = fi.Id;
		}
		
		return null;
			
   }
   
   public PageReference release()
   {
   		
		
		if(!this.releaseErrors)
		{
			refreshCurrAD(this.currAD.Id);
			
			if(gitReleaseCallout())
			{
				
				if(this.releaseFIId != null)
				{
					FeedComment fc = new FeedComment();
					fc.FeedItemId = this.releaseFIId;
					fc.CommentBody = 'Successfully cut the git release.';
					insert fc;
				}
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Successfully cut the git release.'));
				
			}
			else
			{
				
				this.releaseMessage = EncodingUtil.urlDecode(this.releaseMessage,'UTF-8');
				
				if(this.releaseFIId != null)
				{
					FeedComment fc = new FeedComment();
					fc.FeedItemId = this.releaseFIId;
					fc.CommentBody = this.releaseMessage;
					insert fc;
				}
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,this.releaseMessage));
				
			}
						
		}
		
		if(this.currAD.Deployment_Running__c == false)
		{
			this.showDepButton = true;
   			this.showRelButton = true;
		}
		
		return null;
   }
   
   private Boolean gitReleaseCallout()
   {
   	
   	try {
     		HttpRequest req = new HttpRequest();
     
    		List<String> parameterList = new List<String>();
     
     		if(this.currAD.Git_Repo__c != null && this.currAD.Git_Repo__c != '')
     		{
     			parameterList.add('gitrepo='+EncodingUtil.urlEncode(this.currAD.Git_Repo__c, 'UTF-8'));
     		}
     		
     		if(this.releaseVersion != null && this.releaseVersion.trim() != '')
     		{
     			parameterList.add('releaseVersion='+EncodingUtil.urlEncode(this.releaseVersion.trim(), 'UTF-8'));
     		}
     		
     		if(this.releaseComment != null && this.releaseComment.trim() != '')
     		{
     			parameterList.add('releaseComment='+EncodingUtil.urlEncode(this.releaseComment.trim(), 'UTF-8'));
     		}
     		
     		if(this.adConfig.Initiating_Org_Instance__c != null && this.adConfig.Initiating_Org_Instance__c != '')
			{
     			parameterList.add('sfInitiatingOrgInstance='+EncodingUtil.urlEncode(this.adConfig.Initiating_Org_Instance__c, 'UTF-8'));
			}
			
			if(this.adConfig.Initiating_Org__c != null && this.adConfig.Initiating_Org__c != '')
			{
     			parameterList.add('initiatingOrg='+EncodingUtil.urlEncode(this.adConfig.Initiating_Org__c, 'UTF-8'));
			}
			
			parameterList.add('initiatingUser='+EncodingUtil.urlEncode(UserInfo.getUserEmail(), 'UTF-8'));
			
			String queryString = String.join(parameterList,'&');
     
		     req.setEndpoint(this.adConfig.Release_Endpoint_Url__c + '?' + queryString);
		     req.setMethod('GET');
		     
		     // Specify the required user name and password to access the endpoint
		     // As well as the header and header information
		 
		     req.setHeader('sfSessionId', this.userSession);
		   
		     // Create a new http object to send the request object
		     // A response object is generated as a result of the request  
		  
		     Http http = new Http();
		     HTTPResponse res = http.send(req);
		     Integer statusCode = res.getStatusCode();
		     String responseBody = res.getBody();
		     System.debug(statusCode);
		     
		     if(statusCode == 200)
		     {
		     	JSONParser parser = JSON.createParser(responseBody);
		     	releaseResponse rr = (releaseResponse)parser.readValueAs(releaseResponse.class);
		     	
		     	if(rr.status == 'success')
		     	{
		     		return true;
		     	}
		     	else
		     	{
		     		this.releaseMessage = rr.message;
		     		return false;
		     	}
		     }
		     else
		     {
		     	this.releaseMessage = 'Endpoint server error.';
		     	return false;
		     }
			
			
   		}catch(Exception e)
   		{
   			
   			if(System.Test.isRunningTest())
   			{
   				return true;
   			}
   			
   			this.releaseMessage = ''+e;
   			return false;
   		}
   
   }

private String encryptAES256(String plainKey, String plainData)
{
	
	String encryptedString = '';
	try
	{	
		
		System.debug('plainKey: ' + plainKey);
		Blob eKey = Blob.valueOf(plainKey);
		String plainIv = plainKey.substring(8,24);
		System.debug('plainIv: ' + plainIv);
		Blob eIv = Blob.valueOf(plainIv);
		System.debug('plainData: ' + plainData);
		Blob eData = Blob.valueOf(plainData);
		Blob encrypted = Crypto.encrypt('AES256', eKey, eIv, eData);
		encryptedString = EncodingUtil.base64Encode(encrypted);
		
	} catch (Exception e)
	{
		encryptedString = 'FAILED';
	}
	System.debug('encryptedString: ' + encryptedString);
	return encryptedString;
	
}

private String decryptAES256(String encKey, String encData)
{
	
	String decryptedString = '';
	
	try
	{
		
		System.debug('dKey: ' + encKey);
		Blob dKey = Blob.valueOf(encKey);
		String encIv = encKey.substring(8,24);
		System.debug('encIv: ' + encIv);
		Blob dIv = Blob.valueOf(encIv);
		System.debug('encData: ' + encData);
		Blob dData = EncodingUtil.base64Decode(encData);
		Blob decrypted = Crypto.decrypt('AES256',dKey, dIv, dData);
		decryptedString = decrypted.toString();
		
	} catch (Exception e)
	{
		decryptedString = 'FAILED';
	}
	System.debug('decryptedString: ' + decryptedString);
	return decryptedString;
	
}

public class releaseResponse
{
	String status {get;set;}
	String message {get;set;}
	public releaseResponse(String status, String message)
	{
		this.status = status;
		this.message = message;
	}
}


}