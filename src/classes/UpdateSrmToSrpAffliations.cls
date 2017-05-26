global without sharing class UpdateSrmToSrpAffliations implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT RecordTypeId,Person__r.Person__c, Alternate_email__c, Alternate_Phone__c, Best_Time_to_Contact__c, Country_of_Citizenship__c, Employer_Company__c, Employment_Status__c, Title, Gender__c, HS_Grad_Year__c, IM_Type__c, IM_Username__c, Maiden_Name__c, OK_to_Text__c, Original_Text_Opt_In_Date__c, Person__c, Preferred_Name__c, Preferred_Phone__c, Ethnicity__c, Student_Email__c, Student_ID__c, Time_Zone__c, Username__c, Work_Phone__c, DeltakSRP__Other_Email__c, OtherPhone, DeltakSRP__Best_Time_to_Contact__c, DeltakSRP__Citizenship__c, DeltakSRP__Employer_Company__c, DeltakSRP__Employment_Status__c, DeltakSRP__Job_Title__c, DeltakSRP__Gender__c, DeltakSRP__HS_Grad_Year__c, DeltakSRP__IM_Type__c, DeltakSRP__IM_Username__c, DeltakSRP__Maiden_Name__c, DeltakSRPSMS__Ok_To_Text__c, DeltakSRP__Original_Text_Opt_in_Date__c, DeltakSRP__Person__c, DeltakSRP__Preferred_Name__c, DeltakSRP__Preferred_Phone__c, DeltakSRP__Ethnicity__c, DeltakSRP__Student_Email__c, DeltakSRP__Student_ID__c, DeltakSRP__Time_Zone__c, DeltakSRP__Username__c, DeltakSRP__Work_Phone__c From Contact';
	global Id AccountId {get;set;}
	
	global ID srmStudentRecordType {get;set;}
	global ID srpStudentRecordType{get;set;}
	global ID srmDeltakFacultyID {get;set;}
	global ID srpFacultyID {get;set;}
	global final Map<ID,ID> recTypesMap;
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
		
	global UpdateSrmToSrpAffliations(Id acId, String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = acId;
		System.debug('UpdateSrmToSrpPersons');
		
		this.recTypesMap = new Map<ID,ID>();
		
		srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
		srpStudentRecordType = [Select Id from RecordType where name= 'SRP Student'].Id;
		srmDeltakFacultyID = [Select Id from RecordType where name= 'Deltak Faculty'].Id;
		srpFacultyID = [Select Id from RecordType where name= 'SRP Faculty'].Id;
		
		this.recTypesMap.put(srmStudentRecordType,srpStudentRecordType);
		this.recTypesMap.put(srmDeltakFacultyID,srpFacultyID);
		
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	   if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Person');
			mail.setSubject('Affliations Batch Process Started');
			mail.setPlainTextBody('Affliations - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Affliations - Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query+ ' Where AccountId=\''+AccountId +'\' AND ( RecordTypeID = \''+srmStudentRecordType+'\' OR RecordTypeID=\''+srmDeltakFacultyID+'\')');
      //AND Id=\'003J000000iBALZ\'
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List<Contact> contacts = new List<Contact>();
   
     List<String> processingErrorList = new List<String>();
     
     for(Sobject con1 : scope)
     { 
     	Contact con = new Contact(Id=con1.Id);
     	
     	try{
	     	
	  		con.DeltakSRP__Other_Email__c = ((Contact)con1).Alternate_email__c;
			con.OtherPhone= ((Contact)con1).Alternate_Phone__c;
			con.DeltakSRP__Best_Time_to_Contact__c= ((Contact)con1).Best_Time_to_Contact__c;
			
			String citizenship = ((Contact)con1).Country_of_Citizenship__c;
			if(citizenship != null && citizenship != ''){
				if(citizenship.equalsignorecase('USA') || citizenship.equalsignorecase('United State'))
					citizenship = 'United States';
			}
			
			con.DeltakSRP__Citizenship__c= citizenship;
			con.DeltakSRP__Employer_Company__c= ((Contact)con1).Employer_Company__c;
			con.DeltakSRP__Employment_Status__c= ((Contact)con1).Employment_Status__c;
			con.DeltakSRP__Job_Title__c= ((Contact)con1).Title;
			con.DeltakSRP__Gender__c= ((Contact)con1).Gender__c;
			con.DeltakSRP__HS_Grad_Year__c= ((Contact)con1).HS_Grad_Year__c;
			con.DeltakSRP__IM_Type__c= ((Contact)con1).IM_Type__c;
			con.DeltakSRP__IM_Username__c= ((Contact)con1).IM_Username__c;
			con.DeltakSRP__Maiden_Name__c= ((Contact)con1).Maiden_Name__c;
			
			if(((Contact)con1).OK_to_Text__c == 'Yes')
			{
				con.DeltakSRPSMS__Ok_To_Text__c = true;
			}
			else
			{
				con.DeltakSRPSMS__Ok_To_Text__c = false;
			}
			
			if(((Contact)con1).Original_Text_Opt_In_Date__c != null)
			{
				con.DeltakSRP__Original_Text_Opt_in_Date__c= Date.valueOf(((Contact)con1).Original_Text_Opt_In_Date__c);
			}
			
			con.DeltakSRP__Person__c= ((Contact)con1).Person__r.Person__c;
			con.DeltakSRP__Preferred_Name__c= ((Contact)con1).Preferred_Name__c;
			con.DeltakSRP__Preferred_Phone__c= ((Contact)con1).Preferred_Phone__c;
			con.DeltakSRP__Ethnicity__c= ((Contact)con1).Ethnicity__c;
			con.DeltakSRP__Student_Email__c= ((Contact)con1).Student_Email__c;
			con.DeltakSRP__Student_ID__c= ((Contact)con1).Student_ID__c;
			con.DeltakSRP__Time_Zone__c= ((Contact)con1).Time_Zone__c;
			con.DeltakSRP__Username__c= ((Contact)con1).Username__c;
			con.DeltakSRP__Work_Phone__c= ((Contact)con1).Work_Phone__c;
			
			con.RecordTypeId = recTypesMap.get(((Contact)con1).RecordTypeId);
			
			contacts.add(con);
     	} catch(Exception e){
     		processingErrorList.add('Processing Error -- Id: ' + con1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.update(contacts, dmlo);
      
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
			mail.setSubject('Affliations Batch Process Completed');
			mail.setPlainTextBody('Affliations Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Affliations Batch Process has completed at:'+ DateTime.now()});
		
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