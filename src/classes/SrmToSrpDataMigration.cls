public without sharing class SrmToSrpDataMigration {

public  String selectedAccountId {get;set;}

public Contact dummyContact {get;set;}

public boolean updateUsers {get;set;}
public boolean updateCampaigns {get;set;}
public boolean updateActivities {get;set;}
public boolean updateTasks {get;set;}
public boolean updateAffliations {get;set;}
public boolean updateOpportunities {get;set;}
public boolean updateAcademicPrograms {get;set;}
public boolean updateAcademicSpecialization {get;set;}
public boolean updateAcademicStartDate {get;set;}
public boolean updateFiscalCalendar {get;set;}
public boolean updatePerson {get;set;}
public boolean updateProgramAdmissionDocs {get;set;}
public boolean updateProgramAdmissionsTemplate {get;set;}
public boolean updateEnrollementData {get;set;}
public boolean updateGMTOSFPrograms {get;set;}

public boolean renderChatterFeed {get;set;}
public String chatterFeedId {get;set;}
public String currBatchProcessId {get;set;}
public String currBatchProcessStatus {get;set;}
public boolean renderMigrationPoller {get;set;}

/*
Steps:
 
 2- Contant Data -> Record Types= Deltak Faculty, 
 								  Deltak Student, 
 								  Deltak Staff, 
 								  Deltak: Corporate Contact, 
 								  Deltak: Business Development Contact, 
 								  SRP Campus Contact, 
 								  SRP Student, 
 								  SRP Donor, 
 								  SRP Faculty, 
 								  SRP Parent, 
 								  SRP Recruiter, 
 								  SRP Reference
 3- Opportunity Data
 4- Activity -> Updates all activities 
 5- Campaign
 6- User -> Updates all users
*/

	public SrmToSrpDataMigration()
	{
		//Account record type Map
		//Opportunity record type Map
		//Affliation Record Type Map
		 dummyContact = new Contact();
		 dummyContact.Comments__c = UserInfo.getUserEmail();
		 
		 List<CollaborationGroup> cgList = [SELECT Id FROM CollaborationGroup WHERE Name = 'SRM To SRP Migration Status' LIMIT 1];
		 
		 if(cgList != null && cgList.size() > 0)
		 {
		 	this.chatterFeedId = cgList[0].Id;
		 	this.renderChatterFeed = true;
		 }
		 else
		 {
		 	this.renderChatterFeed = false;
		 	this.chatterFeedId = '';
		 }
		 
	}
	
	public PageReference runBatchUpdate()
	{
		Id batchprocessid = null;
		ID accountId = dummyContact.AccountId;
		
		List<String> emailAddressList = getEmailAddressList(this.dummyContact.Comments__c);
		
		Integer numSelections = this.countSelections();
		system.debug('numSelections>>>>'+numSelections); 
		if(numSelections == 1)
		{
		
			if(updateUsers)
			{
				system.debug('updateUsers>>>>'+updateUsers);
				String chatterFeedItemId = this.postChatterGroupFeedItem('Users');
				system.debug('chatterFeedItemId>>>>'+chatterFeedItemId);
				UpdateSrmToSrpUserBatch userBatch = new UpdateSrmToSrpUserBatch(chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(userBatch);
				updateUsers = false; 
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateCampaigns)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Campaigns');
				
				UpdateSrmToSrpCampaigns batch = new UpdateSrmToSrpCampaigns(chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updatePerson)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Persons');
				
				UpdateSrmToSrpPersons batch = new UpdateSrmToSrpPersons(chatterFeedItemId,emailAddressList);
				if(!Test.isrunningtest())
					batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateAffliations)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Affiliations');
				
				UpdateSrmToSrpAffliations batch = new UpdateSrmToSrpAffliations(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateAcademicPrograms)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Academic Programs');
				
				updateSrmToSrpAcademicPrograms batch = new updateSrmToSrpAcademicPrograms(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateAcademicSpecialization)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Academic Specializations');
				
				updateSrmToSrpAcademicProgramsSpeci batch = new updateSrmToSrpAcademicProgramsSpeci(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateFiscalCalendar)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Fiscal Calendars');
				
				updateSrmToSrpFiscalCalendar batch = new updateSrmToSrpFiscalCalendar(chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateAcademicStartDate)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Academic Start Dates');
				
				updateSrmToSrpAcademicStartDate batch = new updateSrmToSrpAcademicStartDate(accountId, chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateOpportunities)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Opportunities');
				
				UpdateSrmToSrpOpportunities batch = new UpdateSrmToSrpOpportunities(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateProgramAdmissionsTemplate)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Program Admissions Templates');
				
				updateSrmToSrpProgAdmissionTemplate batch = new updateSrmToSrpProgAdmissionTemplate(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateProgramAdmissionDocs)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Program Admissions Documents');
				
				updateSrmToSrpProgAdmissionDocs batch = new updateSrmToSrpProgAdmissionDocs(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateActivities)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Activities');
				
				UpdateSRMToSRPEvents batch = new UpdateSRMToSRPEvents(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateTasks)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Tasks');
				
				UpdateSRMToSRPTasks batch = new UpdateSRMToSRPTasks(accountId, chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateEnrollementData)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Enrollment Data');
				
				updateSrmToSrpEnrollment batch = new updateSrmToSrpEnrollment(accountId,chatterFeedItemId,emailAddressList);
				batchprocessid = Database.executeBatch(batch);
				
				this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			if(updateGMTOSFPrograms)
			{
				String chatterFeedItemId = this.postChatterGroupFeedItem('Goldmine To SF Programs');
				
				UpdateSRMTOSRPGoldmineToRFIProgCodeBatch batch = new UpdateSRMTOSRPGoldmineToRFIProgCodeBatch(accountId,chatterFeedItemId,emailAddressList);
	            batchprocessid = Database.executeBatch(batch);
	            
	            this.postChatterGroupFeedItemComment(chatterFeedItemId, 'Batch Id: ' + batchprocessid);
			}
			
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Update process Started. Batch Id is:'+batchprocessid);
			Apexpages.addMessage(myMsg);
			
			this.currBatchProcessId = batchprocessid;
			
			this.refreshBatchStatus();
		
		}
		else
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'You have selected ' + numSelections + ' objects to migrate. You must select 1.');
			Apexpages.addMessage(myMsg);
		}
		
		return null;
	}
	
	public void refreshBatchStatus()
	{
		if(this.currBatchProcessId != null && this.currBatchProcessId != '')
		{
			List<AsyncApexJob> aajList = [SELECT Id,Status FROM AsyncApexJob WHERE Id = :this.currBatchProcessId LIMIT 1];
			
			if(aajList != null && aajList.size() > 0)
			{
				this.currBatchProcessStatus = aajList[0].Status;
			}
			
			if(this.currBatchProcessStatus == 'Holding' || this.currBatchProcessStatus == 'Queued' || this.currBatchProcessStatus == 'Preparing' || this.currBatchProcessStatus == 'Processing')
			{
				this.renderMigrationPoller = true;
			}
			else
			{
				this.renderMigrationPoller = false;
			}
			
		}
		else
		{
			this.renderMigrationPoller = false;
		}
		
	}
	
	private List<String> getEmailAddressList(String emailAddresses)
	{
		List<String> emailAddressList = new List<String>();
		
		if(emailAddresses != null && emailAddresses.trim() != '')
		{
			emailAddressList = emailAddresses.split(',');
		}
		
		return emailAddressList;
	}
	
	private Integer countSelections()
	{
		
		Integer countSelections = 0;
		
		if(updateUsers)
		{
			countSelections++;
		}
		
		if(updateCampaigns)
		{
			countSelections++;
		}
		
		if(updatePerson)
		{
			countSelections++;
		}
		
		if(updateAffliations)
		{
			countSelections++;
		}
		
		if(updateAcademicPrograms)
		{
			countSelections++;
		}
		
		if(updateAcademicSpecialization)
		{
			countSelections++;
		}
		
		if(updateFiscalCalendar)
		{
			countSelections++;
		}
		
		if(updateAcademicStartDate)
		{
			countSelections++;
		}
		
		if(updateOpportunities)
		{
			countSelections++;
		}
		
		if(updateProgramAdmissionsTemplate)
		{
			countSelections++;
		}
		
		if(updateProgramAdmissionDocs)
		{
			countSelections++;
		}
		
		if(updateActivities)
		{
			countSelections++;
		}
		
		if(updateTasks)
		{
			countSelections++;
		}
		
		if(updateEnrollementData)
		{
			countSelections++;
		}
		
		if(updateGMTOSFPrograms){
			countSelections++;
		}
		
		return countSelections;
		
	}
	
	private String postChatterGroupFeedItem(String targetUpdate)
	{
		String chatterFeedItemId;
		
		if(this.chatterFeedId != null && this.chatterFeedId != '')
		{
		
			FeedItem fi = new FeedItem();
	      	fi.Body = 'Update ' + targetUpdate + ' batch process queued by [' + UserInfo.getUserEmail() +']';
	      	fi.ParentId = this.chatterFeedId;
	      	insert fi;
	      
	      	chatterFeedItemId = fi.Id + '';
		
		}
		
		return chatterFeedItemId;
		
	}
	
	private void postChatterGroupFeedItemComment(String chatterFeedItemId, String commentBody)
	{
		FeedComment fc = new FeedComment();
        fc.FeedItemId = chatterFeedItemId;
        fc.CommentBody = commentBody;
        insert fc;
	}


}