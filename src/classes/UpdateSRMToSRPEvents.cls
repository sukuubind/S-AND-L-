global class UpdateSRMToSRPEvents implements  Database.Batchable<Sobject>{

	//TODO: query for deltak student events types, and switch to srp student events
	global String Query = 'Select Id, Completed_Date__c, Type, Event_status__c, Result__c from Event where (whoId != null or whatId != null)';
   
    global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
   	global String AccountId;
    
    global UpdateSrmToSrpEvents(){
    	
    }
    
   	
   global UpdateSrmToSrpEvents(String AccId, String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
    	this.Accountid = accId;
    System.debug('UpdateSrmToSrpEventsBatch***');
  }
     
   global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
		    mail.setSenderDisplayName('Batch Processing- Events');
		    mail.setSubject('Tasks Batch Process Started');
		    mail.setPlainTextBody('Events Batch Process has started at:'+ DateTime.now());
		    
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Events Batch Process has started at:'+ DateTime.now()});
    
    //ID srmRecType = [SELECT IsActive, Description, Name, NamespacePrefix, Id, DeveloperName, SobjectType FROM RecordType where (Name = 'Deltak: Student Event' or Name ='Deltak: Student Event*') AND NamespacePrefix != 'DeltakSRP' limit 1].Id;
    
    //query = query + ' where Id = \'00UJ0000005vt1r\'';
      return Database.getQueryLocator(query+ 'and RecurrenceStartDateTime=null And (Recordtype.name = \'Deltak: Student Event\' or Recordtype.name = \'Deltak: Student Event*\') and ((DeltakSRP__Completed_Date__c = null and Completed_Date__c != null) or (DeltakSRP__Event_status__c = null and Event_status__c != null) or (DeltakSRP__Result__c = null and Result__c != null)) and WhatId in (select Id from Opportunity where AccountId = \'' + this.AccountId + '\')');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     ID srpRecType = [select id from recordtype where name = 'Deltak: Student Event' and NamespacePrefix ='DeltakSRP' limit 1].Id;
     
     
     List <Event> events = new List<Event>();
     
     List<String> processingErrorList = new List<String>(); 
     
     for(Sobject e1 : scope)
     { 
     	try {
     	
	       Event e = (event) e1;
	       
	       e.RecordTypeId = srpRecType;
	       
	       if(e.Completed_Date__c != null)
	       e.DeltakSRP__Completed_Date__c = e.Completed_Date__c;
	       
	       if(e.Event_status__c != null)
	       e.DeltakSRP__Event_status__c = e.Event_status__c;
	       
	       if(e.Result__c != null)
	       e.DeltakSRP__Result__c = e.Result__c;
	       
	       events.add(e);
       
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + e1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
     
     Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.update(events, dmlo);
      
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
		    mail.setSenderDisplayName('Batch Processing- Events');
		    mail.setSubject('Events Batch Process Completed');
		    mail.setPlainTextBody('Events Batch Process has completed at:'+ DateTime.now());
		    
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Events Batch Process has completed at:'+ DateTime.now()});
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