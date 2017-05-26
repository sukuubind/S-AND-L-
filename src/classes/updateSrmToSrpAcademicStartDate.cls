/*
- Query existing SRM Fiscal Calendars
- Create new SRP Fiscal Calendar records
- Associate SRP Fiscal Calendarn with SRM Fiscal Calendar record via bi-directional look up
*/


global without sharing class updateSrmToSrpAcademicStartDate implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Academic_Term__c, End_Date__c,Program__r.Academic_Program__c, Fiscal_Calendar__c,Fiscal_Calendar__r.SRP_Fiscal_Calendar__c, LastModifiedDate,File_Complete_Deadline__c, Period__c, Program__c, Id, School__c, Start_Date__c, StartdateExtId__c FROM Academic_Start_Date__c Where (Academic_Term__c = null OR Academic_Term__c = \'\')';	
 
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	global string accountid;
	
	global updateSrmToSrpAcademicStartDate(Id acId, String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.accountid = acId;
		System.debug('updateSrmToSrpAcademicStartDate');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- AcademicStartDate');
			mail.setSubject('AcademicStartDate Batch Process Started');
			mail.setPlainTextBody('AcademicStartDate - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'AcademicStartDate - Batch Process has started at:'+ DateTime.now()});
   		
		System.debug('Query->'+query);
      return Database.getQueryLocator(query+' and Program__r.School__r.Id=\''+AccountId+'\''); //+' AND Id=\'a08J0000003LNnE\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Academic_Start_Date__c> srpStartDate = new List<DeltakSRP__Academic_Start_Date__c>();
     List <Academic_Start_Date__c> srmStartDate = new List<Academic_Start_Date__c>();
     
     Map<Id,DeltakSRP__Academic_Start_Date__c> srmStartDateMap = new Map<Id,DeltakSRP__Academic_Start_Date__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	DeltakSRP__Academic_Start_Date__c per1 = new DeltakSRP__Academic_Start_Date__c();
	     	
	     	per1.Academic_Start_Date__c = c1.Id; 
	     	per1.DeltakSRP__End_Date__c = ((Academic_Start_Date__c)c1).End_Date__c;
	     	
	     	if(((Academic_Start_Date__c)c1).Fiscal_Calendar__c != null){
	     	per1.DeltakSRP__Fiscal_Calendar__c = ((Academic_Start_Date__c)c1).Fiscal_Calendar__r.SRP_Fiscal_Calendar__c;
	     	}
	     	
	     	per1.DeltakSRP__Start_Date__c = ((Academic_Start_Date__c)c1).Start_Date__c;
	     	per1.DeltakSRP__StartdateExtId__c = ((Academic_Start_Date__c)c1).StartdateExtId__c;
	     	per1.File_Complete_Deadline__c = ((Academic_Start_Date__c)c1).File_Complete_Deadline__c; 
	     	
	     	if(((Academic_Start_Date__c)c1).program__c != null){
	     	per1.DeltakSRP__Academic_Program__c =  ((Academic_Start_Date__c)c1).Program__r.Academic_Program__c;
	     	}
	     	
	     	srpStartDate.add(per1);
	     	 
	     	// SRM Calendar to SRP Calendar map
	     	srmStartDateMap.put(((Academic_Start_Date__c)c1).Id, per1);
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
     List<String> insertErrorList = new List<String>();
     
     Database.DMLOptions dmlo = new Database.DMLOptions();
	 dmlo.optAllOrNone = false;
     List<Database.SaveResult> srList = new List<Database.SaveResult>();
     
     if(!test.isrunningtest())
     {
	      srList= Database.insert(srpStartDate, dmlo);    
     }
      
     Integer cCount = 0;
      
     for(Database.SaveResult sr : srList)
	 {
	 	if(!sr.isSuccess())
	    {
	    	insertErrorList.add('Insert Error -- Id: ' + srpStartDate[cCount].Academic_Start_Date__c + ' Message(s): ' + sr.getErrors());
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
     	
	     	Academic_Start_Date__c per2 = ((Academic_Start_Date__c)c1);
	     	per2.Academic_Term__c = (srmStartDateMap.get(per2.Id)).Id;
	     	
	     	srmStartDate.add(per2);   
     	  
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(srmStartDate, dmlo2);
      
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
			mail.setSenderDisplayName('Batch Processing- AcademicStartDate');
			mail.setSubject('AcademicStartDate Batch Process Completed');
			mail.setPlainTextBody('AcademicStartDate Batch Specialization Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'AcademicStartDate Batch Specialization Process has completed at:'+ DateTime.now()});
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