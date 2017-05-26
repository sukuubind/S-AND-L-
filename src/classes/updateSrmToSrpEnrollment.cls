/*
- Query existing Student Enrollments records
- Create new DeltakSRP__Program_Enrollment__c records using DeltakSRP__Program_Enrollment__c
- Associate new DeltakSRP__Program_Enrollment__c record with Old  Student Enrollments record via bi-directional look up
*/

global without sharing class updateSrmToSrpEnrollment implements  Database.Batchable<Sobject> {
	
	global final String Query = 'Select s.Student_Services_Coordinator__c, s.Student_Affiliation__r.AccountId, s.Student_Affiliation__c, s.Start_Date__c, s.Specialization__c,s.Specialization__r.SRP_Academic_Specialization__c, s.School__c, s.Returning_Provisional_Reason__c, s.Returning_Conditional_Reason__c, s.Returning_Conditional_Provisional_Term__c, s.Re_Enter_Provisional_Reason__c, s.Re_Enter_Date__c, s.Re_Enter_Conditional_Reason__c, s.Provisional__c, s.Provisional_Reason__c, s.Program__r.Academic_Program__c, s.Program__c, s.Opportunity__c, s.New_Provisional_Reason__c, s.New_Conditional_Reason__c, s.Name, s.Intended_Return_Date__c, s.Enrollment_Status__c, s.Drop_Sub_Categories__c, s.Drop_Reason__c, s.Drop_Date__c, s.Drop_Common_Uses__c, s.Do_Not_Register__c, s.Conditional__c, s.Conditional_Reason__c, s.Academic_Start_Date__r.Academic_Term__c, s.Academic_Start_Date__c From Student_Enrollment__c s';
	global Id AccountId {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global updateSrmToSrpEnrollment(Id acId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList; 
		
		this.AccountId = acId;
		System.debug('updateSrmToSrpEnrollment');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Enrollment');
			mail.setSubject('Batch Process Started');
			mail.setPlainTextBody('Enrollment - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
		
		this.postCommentsToChatterFeedItem(new List<String>{'Enrollment - Batch Process has started at:'+ DateTime.now()});
		
      return Database.getQueryLocator(query + ' Where s.Student_Affiliation__r.AccountId =\''+AccountId+'\' AND  (Program_Enrollment__c = null OR Program_Enrollment__c = \'\') AND (s.Program__c != null OR s.Program__c !=  \'\' ) AND(s.Academic_Start_Date__c != null OR s.Academic_Start_Date__c!=  \'\') '); //+' where Id = \'a0KJ00000029s4k\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Program_Enrollment__c> enrollments = new List<DeltakSRP__Program_Enrollment__c>();
     List <Student_Enrollment__c> oldEnrollments = new List<Student_Enrollment__c>();
     
     Map<Id,DeltakSRP__Program_Enrollment__c> oldEnrollmentsMap = new Map<Id,DeltakSRP__Program_Enrollment__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	DeltakSRP__Program_Enrollment__c per1 = new DeltakSRP__Program_Enrollment__c();
	     	
	     	per1.Student_Enrollment__c =  ((Student_Enrollment__c)c1).Id;
	     	per1.DeltakSRP__Enrollment_Start__c = ((Student_Enrollment__c)c1).Academic_Start_Date__r.Academic_Term__c;
	     	
	     	per1.DeltakSRP__Conditional__c = ((Student_Enrollment__c)c1).Conditional__c;
			per1.Conditional_Reason__c = ((Student_Enrollment__c)c1).Conditional_Reason__c;
			per1.DeltakSRP__Do_Not_Register__c = ((Student_Enrollment__c)c1).Do_Not_Register__c;
			per1.Drop_Common_Uses__c = ((Student_Enrollment__c)c1).Drop_Common_Uses__c;
			per1.DeltakSRP__Drop_Date__c = ((Student_Enrollment__c)c1).Drop_Date__c;
			per1.DeltakSRP__Drop_Reason__c = ((Student_Enrollment__c)c1).Drop_Reason__c;
			per1.DeltakSRP__Drop_Category__c = ((Student_Enrollment__c)c1).Drop_Sub_Categories__c;
			per1.DeltakSRP__Enrollment_Status__c = ((Student_Enrollment__c)c1).Enrollment_Status__c;
			per1.Intended_Return_Date__c = ((Student_Enrollment__c)c1).Intended_Return_Date__c;
			per1.New_Conditional_Reason__c = ((Student_Enrollment__c)c1).New_Conditional_Reason__c;
			per1.New_Provisional_Reason__c = ((Student_Enrollment__c)c1).New_Provisional_Reason__c;
			per1.DeltakSRP__Opportunity__c = ((Student_Enrollment__c)c1).Opportunity__c;
			per1.DeltakSRP__Academic_Program__c = ((Student_Enrollment__c)c1).Program__r.Academic_Program__c;
			per1.DeltakSRP__Provisional__c = ((Student_Enrollment__c)c1).Provisional__c;
			per1.Provisional_Reason__c = ((Student_Enrollment__c)c1).Provisional_Reason__c;
			per1.Re_Enter_Conditional_Reason__c = ((Student_Enrollment__c)c1).Re_Enter_Conditional_Reason__c;
			per1.Re_Enter_Date__c = ((Student_Enrollment__c)c1).Re_Enter_Date__c;
			per1.Re_Enter_Provisional_Reason__c = ((Student_Enrollment__c)c1).Re_Enter_Provisional_Reason__c;
			per1.Provisional_Reason__c = ((Student_Enrollment__c)c1).Provisional_Reason__c;
			per1.Returning_Conditional_Provisional_Term__c = ((Student_Enrollment__c)c1).Returning_Conditional_Provisional_Term__c;
			per1.Returning_Conditional_Reason__c = ((Student_Enrollment__c)c1).Returning_Conditional_Reason__c;
			per1.Returning_Provisional_Reason__c = ((Student_Enrollment__c)c1).Returning_Provisional_Reason__c;
			per1.DeltakSRP__Academic_Specialization__c = ((Student_Enrollment__c)c1).Specialization__r.SRP_Academic_Specialization__c;
			per1.DeltakSRP__Start_Date__c = ((Student_Enrollment__c)c1).Start_Date__c;
			per1.DeltakSRP__Enrolled_Student__c = ((Student_Enrollment__c)c1).Student_Affiliation__c;
			per1.DeltakSRP__Student_Services_Coordinator__c = ((Student_Enrollment__c)c1).Student_Services_Coordinator__c;
	     	
	     	enrollments.add(per1);
	     	
	     	// old person to new person map
	     	oldEnrollmentsMap.put(((Student_Enrollment__c)c1).Id, per1);
	     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(enrollments, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + enrollments[cCount].Student_Enrollment__c + ' Message(s): ' + sr.getErrors());
        }
        
        cCount++;
                
      }
     
     if(processingErrorList.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(processingErrorList);
     }
      
     if(insertErrorList.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(insertErrorList);
     }
      
      
      
      
      
      
      
      
      
      
      
     List<String> processingErrorList2 = new List<String>();
      
      //Now update old person with new DeltakSRP__Person__c record
       for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	Student_Enrollment__c per2 = ((Student_Enrollment__c)c1);
	     	per2.Program_Enrollment__c = (oldEnrollmentsMap.get(per2.Id)).Id;
	     	     	
	     	oldEnrollments.add(per2);
	     	
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(oldEnrollments, dmlo2);
      
      List<String> saveErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList2)
      {
        if(!sr.isSuccess())
        {
        	saveErrorList.add('Save Error -- Id: ' + sr.getId() + ' Message(s): ' + sr.getErrors());
        }
                
      }
     
     
     if(processingErrorList2.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(processingErrorList2);
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
			mail.setSenderDisplayName('Batch Processing- Enrollment');
			mail.setSubject('Enrollment Batch Process Completed');
			mail.setPlainTextBody('Enrollment Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
		
		this.postCommentsToChatterFeedItem(new List<String>{'Enrollment Batch Process has completed at:'+ DateTime.now()});
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