/*
 Class to update record type, and copy fields.
 
 Academic Programs
 Academic Specialization
 Academic Start Date
*/

global without sharing class UpdateSrmToSrpOpportunities implements  Database.Batchable<Sobject> { 
	
	global final String Query = 'Select Id,LP_UHSCODE__c,Transferred_from_Opportunity__c,Referred_By_Contact__c,Reactivated_By_Name__c,How_Heard_Detail__c,Referred_By_Opportunity__c,Home_Phone__c,Mobile_Phone__c,Work_Phone__c, Specialization__r.SRP_Academic_Specialization__c, RecordTypeID,Fiscal_Calendar__r.SRP_Fiscal_Calendar__c,Program__r.Academic_Program__c,Academic_Start_Date__c,Academic_Start_Date__r.Academic_Term__c,Acceptance_Status__c,Anticipated_Start_Date__c,Appointment_Completed__c,Campus_Schedule_Code__c,Commitment_Level__c,Conditional_Reason__c,cwschedappt__c,Date_Accepted__c,Date_Booked__c,Date_Registered__c,Date_Submitted__c,Discount__c,Discount_Type__c,Drop_Denied_Reason__c,Email_from_Student__c,Fiscal_Calendar__c,Flag_for_Concern__c,GPA__c,How_Heard__c,Initial_Contact__c,Initial_Start_Date__c,Inquiry_Rating__c,Interest_Timeframe__c,Last_Attempt__c,Last_Contact__c,LP_Campaign__c,LP_UADCAMPAIGN__c,LP_UADGROUP__c,LP_UREFKEYWORD__c,LP_UREFMEDIATYPE__c,LP_UREFPROMOTION__c,LP_UREURL__c,Modality__c,Motivation__c,Non_Matriculated__c,Obstacles__c,Other_Concerns__c,Other_Program__c,Payment_Type__c,Payment_Type_For_Books__c,Pending_Activity_Date__c,Flag_for_Concern_Reason__c,Program__c,Provisional_Reason__c,Quality_Contact__c,Reactivated_By__c,Reactivated_Date__c,Roll_Counter__c,Source__c,Specialization__c,Start_Date__c,Student__c,Sub_Stage__c,WebScheduler_Email__c,webschedulerstatus__c, Why_Now__c,Yrs_Wrk_Exp__c, accountId, ownerId From Opportunity';
	
	global ID srpOppRecordType {get;set;}
	global ID srmOppRecordType {get;set;}
	global ID srmGoundOppRecordType {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global Id AccountId {get;set;}
	
	global UpdateSrmToSrpOpportunities(Id acId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.srpOppRecordType = [Select id from RecordType where name = 'SRP Opportunity'].Id;
		this.srmGoundOppRecordType = [Select id from RecordType where name = 'On-Ground Opportunity'].Id;
		this.srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
		
		this.AccountId = acId;
		System.debug('UpdateSrmToSrpOpportunities');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Person');
			mail.setSubject('Opportunities Batch Process Started');
			mail.setPlainTextBody('Opportunities - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Opportunities - Batch Process has started at:'+ DateTime.now()});
		
		system.debug('query>>>>'+query + ' Where AccountId=\''+AccountId +'\'');
      return Database.getQueryLocator(query+ ' Where AccountId=\''+AccountId +'\' AND (RecordType.Name= \'On-Ground Opportunity\' OR RecordType.Name= \'Student Opportunity\')');
      //Id = \'a0KJ00000029s4k\' AND RecordTypeID=\''+srmOppRecordType+'\''
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <Opportunity> opps = new List<Opportunity>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject opp1 : scope)
     { 
     	try {
     		
	     	Opportunity opp = new Opportunity(Id=opp1.Id);
	     	
	     	if( ((Opportunity)opp1).RecordTypeId == srmOppRecordType || ((Opportunity)opp1).RecordTypeId == srmGoundOppRecordType){
	     		opp.RecordTypeID = srpOppRecordType;
	     	}
	     	
	     	opp.OwnerId = ((Opportunity)opp1).OwnerId;
	     	opp.DeltakSRP__Academic_Start_Date__c = ((Opportunity)opp1).Academic_Start_Date__r.Academic_Term__c;
	     	opp.DeltakSRP__Acceptance_Status__c =((Opportunity)opp1).Acceptance_Status__c;
	     	opp.DeltakSRP__Anticipated_Start_Date__c=((Opportunity)opp1).Anticipated_Start_Date__c;
	     	opp.DeltakSRP__Appointment_Completed__c=((Opportunity)opp1).Appointment_Completed__c;
	     	opp.DeltakSRP__Campus_Schedule_Code__c=((Opportunity)opp1).Campus_Schedule_Code__c;
	     	opp.DeltakSRP__Commitment_Level__c=((Opportunity)opp1).Commitment_Level__c;
	     	opp.DeltakSRP__Conditional_Reason__c=((Opportunity)opp1).Conditional_Reason__c;
	     	opp.DeltakSRP__cwschedappt__c=((Opportunity)opp1).cwschedappt__c;
	     	opp.DeltakSRP__Date_Accepted__c=((Opportunity)opp1).Date_Accepted__c;
	     	opp.DeltakSRP__Date_Booked__c=((Opportunity)opp1).Date_Booked__c;
	     	opp.DeltakSRP__Date_Registered__c=((Opportunity)opp1).Date_Registered__c;
	     	opp.DeltakSRP__Date_Submitted__c=((Opportunity)opp1).Date_Submitted__c;
	     	opp.DeltakSRP__Discount__c=((Opportunity)opp1).Discount__c;
	     	opp.DeltakSRP__Discount_Type__c=((Opportunity)opp1).Discount_Type__c;
	     	opp.DeltakSRP__Drop_Denied_Reason__c=((Opportunity)opp1).Drop_Denied_Reason__c;
	     	opp.DeltakSRP__Email_from_Student__c=((Opportunity)opp1).Email_from_Student__c;
	     	opp.DeltakSRP__Fiscal_Calendar__c=((Opportunity)opp1).Fiscal_Calendar__r.SRP_Fiscal_Calendar__c;
	     	opp.DeltakSRP__Flag_for_Concern__c=((Opportunity)opp1).Flag_for_Concern__c;
	     	opp.DeltakSRP__GPA__c=((Opportunity)opp1).GPA__c;
	     	opp.DeltakSRP__How_Heard__c=((Opportunity)opp1).How_Heard__c;
	     	opp.DeltakSRP__Initial_Attempt__c=((Opportunity)opp1).Initial_Contact__c;
	     	opp.DeltakSRP__Initial_Start_Date__c=((Opportunity)opp1).Initial_Start_Date__c;
	     	opp.DeltakSRP__Inquiry_Rating__c=((Opportunity)opp1).Inquiry_Rating__c;
	     	opp.DeltakSRP__Interest_Timeframe__c=((Opportunity)opp1).Interest_Timeframe__c;
	     	opp.DeltakSRP__Last_Attempt__c=((Opportunity)opp1).Last_Attempt__c;
	     	opp.DeltakSRP__Last_Contact__c=((Opportunity)opp1).Last_Contact__c;
	     	opp.DeltakSRP__LP_Campaign__c=((Opportunity)opp1).LP_Campaign__c;
	     	opp.DeltakSRP__LP_UADCAMPAIGN__c=((Opportunity)opp1).LP_UADCAMPAIGN__c;
	     	opp.DeltakSRP__LP_UADGROUP__c=((Opportunity)opp1).LP_UADGROUP__c;
	     	opp.Order_ID__c = ((Opportunity)opp1).LP_UHSCODE__c;
	     	opp.DeltakSRP__LP_UREFKEYWORD__c=((Opportunity)opp1).LP_UREFKEYWORD__c;
	     	opp.DeltakSRP__LP_UREF_MEDIATYPE__c=((Opportunity)opp1).LP_UREFMEDIATYPE__c;
	     	opp.DeltakSRP__LP_UREFPROMOTION__c=((Opportunity)opp1).LP_UREFPROMOTION__c;
	     	opp.DeltakSRP__LP_UREURL__c=((Opportunity)opp1).LP_UREURL__c;
	     	opp.DeltakSRP__Modality__c=((Opportunity)opp1).Modality__c;
	     	opp.DeltakSRP__Motivation__c=((Opportunity)opp1).Motivation__c;
	     	opp.DeltakSRP__Non_Matriculated__c=((Opportunity)opp1).Non_Matriculated__c;
	     	opp.DeltakSRP__Obstacles__c=((Opportunity)opp1).Obstacles__c;
	     	opp.DeltakSRP__Other_Concerns__c=((Opportunity)opp1).Other_Concerns__c;
	     	opp.DeltakSRP__Other_Program_Information__c=((Opportunity)opp1).Other_Program__c;
	     	opp.DeltakSRP__Payment_Type__c=((Opportunity)opp1).Payment_Type__c;
	     	opp.DeltakSRP__Payment_Type_For_Books__c=((Opportunity)opp1).Payment_Type_For_Books__c;
	     	opp.DeltakSRP__Pending_Activity_Date__c=((Opportunity)opp1).Pending_Activity_Date__c;
	     	opp.DeltakSRP__Primary_Concern_Reason__c=((Opportunity)opp1).Flag_for_Concern_Reason__c;
	     	opp.DeltakSRP__Academic_Program__c=((Opportunity)opp1).Program__r.Academic_Program__c;
	     	opp.DeltakSRP__Provisional_Reason__c=((Opportunity)opp1).Provisional_Reason__c;
	     	opp.DeltakSRP__Quality_Contact__c=((Opportunity)opp1).Quality_Contact__c;
	     	opp.DeltakSRP__Reactivated_By__c=((Opportunity)opp1).Reactivated_By__c;
	     	opp.DeltakSRP__Reactivated_Date__c=((Opportunity)opp1).Reactivated_Date__c;
	     	opp.DeltakSRP__Roll_Counter__c=((Opportunity)opp1).Roll_Counter__c;
	     	opp.DeltakSRP__Source__c=((Opportunity)opp1).Source__c;
	     	opp.DeltakSRP__Academic_Specialization__c=((Opportunity)opp1).Specialization__r.SRP_Academic_Specialization__c;
	     	opp.DeltakSRP__Start_Date__c=((Opportunity)opp1).Start_Date__c;
	     	opp.DeltakSRP__Student__c=((Opportunity)opp1).Student__c;
	     	opp.DeltakSRP__Sub_Stage__c=((Opportunity)opp1).Sub_Stage__c;
	     	opp.DeltakSRP__WebScheduler_Email__c=((Opportunity)opp1).WebScheduler_Email__c;
	     	opp.DeltakSRP__webschedulerstatus__c=((Opportunity)opp1).webschedulerstatus__c;
	     	opp.DeltakSRP__Why_Now__c=((Opportunity)opp1).Why_Now__c;
	     	opp.DeltakSRP__Years_Work_Experience__c=((Opportunity)opp1).Yrs_Wrk_Exp__c;
			opp.SRP_Referred_By_Opportunity__c = ((Opportunity)opp1).Referred_By_Opportunity__c;
			opp.DeltakSRP_How_Heard_Detail__c = ((Opportunity)opp1).How_Heard_Detail__c;
			opp.SRP_Reactivated_By_Name__c=((Opportunity)opp1).Reactivated_By_Name__c;
			opp.SRP_Transferred_from_Opportunity__c = ((Opportunity)opp1).Transferred_from_Opportunity__c;
	     	opps.add(opp);
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + opp1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}

     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.update(opps, dmlo);
      
      List<String> saveErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	saveErrorList.add('Save Error -- Id: ' + sr.getId() + ' Message(s): ' + sr.getErrors());
        }
                
      }
     
     
     if(processingErrorList.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(processingErrorList);
     }
      
     if(saveErrorList.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(saveErrorList);
     }
      
      
    }

   global void finish(Database.BatchableContext BC){
   		
   		if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Campaigns');
			mail.setSubject('Opportunities Batch Process Completed');
			mail.setPlainTextBody('Opportunities Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Opportunities Batch Process has completed at:'+ DateTime.now()});
   }
   
   
   private void postCommentsToChatterFeedItem(List<String> commentBodyList)
   {
   	
   		if(this.chatterFeedItemId != null && this.chatterFeedItemId != '')
   		{
   			List<FeedComment> fcList = new List<FeedComment>();
   			
   			for(String commentBody : commentBodyList)
   			{
   				FeedComment fc = new FeedComment();
        		fc.FeedItemId = this.chatterFeedItemId;
        		fc.CommentBody = commentBody;
        		fcList.add(fc);
   			}
   			
        	insert fcList;
   		}
   }

}