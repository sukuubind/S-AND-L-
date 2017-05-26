/*
- Query existing SRM Program Admission Docs
- Create new SRP FProgram Admission Docs records
- Associate SRP Program Admission Docs with SRM Program Admission Doc record via bi-directional look up
*/


global without sharing class updateSrmToSrpProgAdmissionDocs implements  Database.Batchable<Sobject>,Database.Stateful {
	
	global final String Query = 'Select p.College_University__c, p.License_Number__c,p.Document_Name__c,p.Date_Taken__c,p.Quality_Points__c,p.RecordTypeId, p.Opportunity__r.Program__c,p.Yrs_Wrk_Exp__c, p.Waived__c, p.Visa_Number__c, p.Type__c, p.Transcript_Evaluation_Needed__c, p.Test_Score__c, p.State_Issued__c, p.SRP_Program_Admission_Document__c, p.Required__c, p.Relationship_to_Applicant__c, p.Record_Type_Name__c, p.Recommender_Name__c, p.Program_Name__c, p.Permanent_Resident_Number__c, p.Payment_Method__c, p.Override__c, p.Other__c, p.Order__c, p.Opportunity__c, p.Naturalization_Number__c, p.Lock_GPA__c, p.GPA__c, p.Fee_Amount__c, p.Expiration_Date__c, p.Do_Not_Add_Yrs_Wrk_Exp__c, p.Description__c, p.Degree_Conferral_Date__c, p.Date_Sent__c, p.Date_Scheduled__c, p.Date_Received__c, p.Date_Issued__c, p.Credits__c, p.Comments__c, p.Citizenship_Status__c From Program_Admission_Document__c p';
	global Id AccountId {get;set;}
	List<RecordType> srmDocsTypes {get;set;} 
	List<RecordType> srpDocsTypes {get;set;}
	global Map<id,id> srmToSrpDocType {get;set;}

	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}

	global updateSrmToSrpProgAdmissionDocs(Id accId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = accId;
		System.debug('updateSrmToSrpProgAdmissionDocs');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    srmToSrpDocType = new Map<Id,Id>();
   	    
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Program Admission Documents');
			mail.setSubject('Program Admission Documents Batch Process Started');
			mail.setPlainTextBody('Program Admission Documents - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Program Admission Documents - Batch Process has started at:'+ DateTime.now()});
   		
		System.debug('Query->'+query+' Where Opportunity__r.AccountId=\''+((String)AccountId).substring(0,15)+'\' AND SRP_Program_Admission_Document__c = null');
		
		srmDocsTypes = [SELECT SobjectType, DeveloperName, Id, Name, IsActive FROM RecordType where name IN ('Application','Application Fee','Citizenship Information','Letter of Recommendation','Licenses/Certifications','Other','Personal Statement','Registration Form','Resume','Test Score','Test Waiver','Transcript','Letter of Intent') AND SobjectType = 'Program_Admission_Document__c'];
		srpDocsTypes = [SELECT SobjectType, DeveloperName, Id, Name, IsActive FROM RecordType where name IN ('Application','Application Fee','Citizenship Information','Letter of Recommendation','License','Other','Personal Statement','Registration Form','Resume','Test Score','Test Waiver','Transcript','Letter of Intent') AND SobjectType = 'DeltakSRP__Program_Admission_Document__c'];
		
		for(RecordType t: srmDocsTypes )
		{
			
			for(RecordType t1: srpDocsTypes)
			{
				if(t.Name == t1.Name){
					srmToSrpDocType.put(t.Id, t1.Id);
				}
				else if (t.Name == 'Licenses/Certifications' && t1.Name == 'License' )
				{
					srmToSrpDocType.put(t.Id, t1.Id);
				}
			}
		}
		
      return Database.getQueryLocator(query+' Where Opportunity__r.AccountId=\''+((String)AccountId).substring(0,15)+'\' AND SRP_Program_Admission_Document__c = null'); //+' AND Id=\'a0MJ0000002jCrw\'');
   } 
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     
     try {
     
	     List <DeltakSRP__Program_Admission_Document__c> srpProgramAdmissionDocument = new List<DeltakSRP__Program_Admission_Document__c>();
	     List <Program_Admission_Document__c> srmProgramAdmissionDocument = new List<Program_Admission_Document__c>();
	     
	     Map<Id,DeltakSRP__Program_Admission_Document__c> srmProgramAdmissionDocumentMap = new Map<Id,DeltakSRP__Program_Admission_Document__c>();
	     
	     Set<Id> oppProgIds = new Set<Id>();
	     Map<id,id> progToSrpDocTemp = new Map<Id,Id>();    
	     
	     // get SRP Templates from SRM Templates values
	     for(Sobject p0 : scope)
	     { 
	     	oppProgIds.add( ((Program_Admission_Document__c)p0).Opportunity__r.Program__c );
	     }
	     
	      Program_Admission_Template__c [] templateList = [select SRP_Program_Admission_Template__c,Id,Program__c,Name,Type__c, Comments__c, Order__c, Required__c, Application_Fee__c
	                                                          FROM Program_Admission_Template__c 
	                                                          WHERE Program__c IN :oppProgIds];
	                                                     
	       System.debug('SRM Templates Lists->'+templateList);
	       
	       for(Program_Admission_Template__c tmp1 :templateList )
	       {
	       		progToSrpDocTemp.put(tmp1.Program__c, tmp1.SRP_Program_Admission_Template__c);
	       }
	     
	     List<String> processingErrorList = new List<String>();
	                                                          
	     for(Sobject p : scope)
	     { 
	     	try {
	     	
		     	DeltakSRP__Program_Admission_Document__c per1 = new DeltakSRP__Program_Admission_Document__c();
		     	
		     	per1.SRM_Program_Admission_Document__c = p.Id;
		     	per1.DeltakSRP__Program_Admission_Template__c = progToSrpDocTemp.get(((Program_Admission_Document__c)p).Opportunity__r.Program__c );
		     	per1.RecordTypeId = srmToSrpDocType.get(((Program_Admission_Document__c)p).RecordTypeId);
		     	//per1.Name = ((Program_Admission_Document__c)p).Name;
		     	per1.DeltakSRP__Yrs_Wrk_Exp__c = ((Program_Admission_Document__c)p).Yrs_Wrk_Exp__c;
		     	per1.DeltakSRP__Waived__c = ((Program_Admission_Document__c)p).Waived__c;
		     	per1.DeltakSRP__Visa_Number__c = ((Program_Admission_Document__c)p).Visa_Number__c;
		     	per1.DeltakSRP__Type__c = ((Program_Admission_Document__c)p).Type__c;
		     	per1.DeltakSRP__Transcript_Evaluation_Needed__c = ((Program_Admission_Document__c)p).Transcript_Evaluation_Needed__c;
		     	per1.DeltakSRP__Test_Score__c = ((Program_Admission_Document__c)p).Test_Score__c;
		     	per1.DeltakSRP__State_Issued__c = ((Program_Admission_Document__c)p).State_Issued__c;
		     	per1.DeltakSRP__Required__c = ((Program_Admission_Document__c)p).Required__c;
		     	per1.DeltakSRP__Relationship_to_Applicant__c = ((Program_Admission_Document__c)p).Relationship_to_Applicant__c;
		     	per1.DeltakSRP__Recommender_Name__c = ((Program_Admission_Document__c)p).Recommender_Name__c;
		     	per1.DeltakSRP__Program_Name__c = ((Program_Admission_Document__c)p).Program_Name__c;
		     	per1.DeltakSRP__Permanent_Resident_Number__c = ((Program_Admission_Document__c)p).Permanent_Resident_Number__c;
		     	per1.DeltakSRP__Payment_Method__c = ((Program_Admission_Document__c)p).Payment_Method__c;
		     	per1.DeltakSRP__Override__c = ((Program_Admission_Document__c)p).Override__c;
		     	per1.DeltakSRP__Other__c = ((Program_Admission_Document__c)p).Other__c;
		     	per1.DeltakSRP__Order__c = ((Program_Admission_Document__c)p).Order__c;
		     	per1.DeltakSRP__Opportunity__c = ((Program_Admission_Document__c)p).Opportunity__c;
		     	per1.DeltakSRP__Naturalization_Number__c = ((Program_Admission_Document__c)p).Naturalization_Number__c;
		     	//per1.DeltakSRP__Lock_GPA__c = ((Program_Admission_Document__c)p).Lock_GPA__c;
		        per1.DeltakSRP__Lock_GPA__c = true;
		     	per1.DeltakSRP__GPA__c = ((Program_Admission_Document__c)p).GPA__c;
		     	per1.DeltakSRP__Fee_Amount__c = ((Program_Admission_Document__c)p).Fee_Amount__c;
		     	per1.DeltakSRP__Expiration_Date__c = ((Program_Admission_Document__c)p).Expiration_Date__c;
		     	per1.DeltakSRP__Do_Not_Add_Yrs_Wrk_Exp__c = ((Program_Admission_Document__c)p).Do_Not_Add_Yrs_Wrk_Exp__c;
		     	per1.DeltakSRP__Description__c = ((Program_Admission_Document__c)p).Description__c;
		     	per1.DeltakSRP__Degree_Conferral_Date__c = ((Program_Admission_Document__c)p).Degree_Conferral_Date__c;
		     	per1.DeltakSRP__Date_Sent__c = ((Program_Admission_Document__c)p).Date_Sent__c;
		     	per1.DeltakSRP__Date_Scheduled__c = ((Program_Admission_Document__c)p).Date_Scheduled__c;
		     	per1.DeltakSRP__Date_Received__c = ((Program_Admission_Document__c)p).Date_Received__c;
		     	per1.DeltakSRP__Date_Issued__c = ((Program_Admission_Document__c)p).Date_Issued__c;
		     	per1.DeltakSRP__Credits__c = ((Program_Admission_Document__c)p).Credits__c;
		     	per1.DeltakSRP__Comments__c = ((Program_Admission_Document__c)p).Comments__c;
		     	per1.DeltakSRP__Citizenship_Status__c = ((Program_Admission_Document__c)p).Citizenship_Status__c;
		     	per1.DeltakSRP__Date_Taken__c =  ((Program_Admission_Document__c)p).Date_Taken__c;
		     	per1.DeltakSRP__Document_Name__c = ((Program_Admission_Document__c)p).Document_Name__c;
		     	per1.DeltakSRP__License_Number__c = ((Program_Admission_Document__c)p).License_Number__c;
		     	per1.DeltakSRP__Quality_Points__c = ((Program_Admission_Document__c)p).Quality_Points__c;
		     	per1.College_University__c = ((Program_Admission_Document__c)p).College_University__c;
		     	srpProgramAdmissionDocument.add(per1);
		     	
		     	// SRM Document to SRP Document map
		     	srmProgramAdmissionDocumentMap.put(((Program_Admission_Document__c)p).Id, per1);
		     	
	     	} catch(Exception e) {
	     		processingErrorList.add('Processing Error -- Id: ' + p.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
	     	}
	     }
	     
	     List<String> insertErrorList = new List<String>();
	     
	     Database.DMLOptions dmlo = new Database.DMLOptions();
		 dmlo.optAllOrNone = false;
		 List<Database.SaveResult> srList = new List<Database.SaveResult>();
	     
	     if(!test.isrunningtest())
	     {
	     	  srList = Database.insert(srpProgramAdmissionDocument, dmlo);
	     	  system.debug('srpProgramAdmissionDocument>>>>'+srpProgramAdmissionDocument);
	     	  
	     }
	     
	     Integer cCount = 0;
		      
	     for(Database.SaveResult sr : srList)
	     {
	       if(!sr.isSuccess())
	       {
	     	 	insertErrorList.add('Insert Error -- Id: ' + srpProgramAdmissionDocument[cCount].SRM_Program_Admission_Document__c + ' Message(s): ' + sr.getErrors());
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
	     
	      //Now update old spec with new spec record
	     for(Sobject c1 : scope)
	     { 
	     	try {
	     	
		     	Program_Admission_Document__c  per2 = ((Program_Admission_Document__c )c1);
		     	per2.SRP_Program_Admission_Document__c = (srmProgramAdmissionDocumentMap.get(per2.Id)).Id;
		     	
		     	srmProgramAdmissionDocument.add(per2);     
	     	} catch(Exception e) {
	     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
	     	}
	     }
	     
	     List<String> saveErrorList = new List<String>();
	     
	     Database.DMLOptions dmlo2 = new Database.DMLOptions();
		 dmlo2.optAllOrNone = false;
		 List<Database.SaveResult> srList2 = new List<Database.SaveResult>();
	     
	     if(!test.isrunningtest())
	     {
	     	 srList2 = Database.update(srmProgramAdmissionDocument, dmlo2);	     	
	     }
	     
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
	     
     }catch(Exception e) { 
     	this.postCommentsToChatterFeedItem(new List<String>{'Processing Error -- Line#: ' + e.getLineNumber() + 'Message(s): ' + e});
     }

    }

   global void finish(Database.BatchableContext BC){
   		
   		if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Program Admission Documents');
			mail.setSubject('Program Admission Documents Batch Process Completed');
			mail.setPlainTextBody('Program Admission Documents Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Program Admission Documents Batch Process has completed at:'+ DateTime.now()});
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