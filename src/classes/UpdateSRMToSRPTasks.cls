global without sharing class UpdateSRMToSRPTasks implements  Database.Batchable<Sobject>{
	//original query
	//global String Query = 'Select Id, Completed_Date__c, Type, Event_status__c, Result__c from Task where (whoId != null or whatId != null) AND (DeltakSRP__Event_status__c = null AND Event_status__c != null) ';
	
	//changed by george to include tasks for opportunities for specific account
	global String Query = 'Select Id, Completed_Date__c, Type, Event_status__c, Result__c,DeltakSRP__Event_status__c from Task where ((DeltakSRP__Event_status__c = null AND Event_status__c != null) or (DeltakSRP__Completed_Date__c = null AND Completed_Date__c != null) or (DeltakSRP__Result__c = null AND Result__c != null)) and isrecurrence=false AND WhatId in (select Id from Opportunity ';
	
	global Id AccountId {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	//List<Task> tasklist = [Select Completed_Date__c, Type, Event_status__c, Result__c from Task];
	global UpdateSrmToSrpTasks(Id accId, String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = accId;
		System.debug('UpdateSrmToSrpTaskBatch***');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Tasks');
			mail.setSubject('Tasks Batch Process Started');
			mail.setPlainTextBody('Tasks Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Tasks Batch Process has started at:'+ DateTime.now()});
   		
		this.Query += ' where AccountId = \'' + this.AccountId + '\')';
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <Task> tasks = new List<Task>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject t1 : scope)
     { 
     	try {
     	
	     	Task t = (task) t1;
	     	t.DeltakSRP__Completed_Date__c = t.Completed_Date__c;
	     	t.DeltakSRP__Event_status__c = t.Event_status__c;
	     	t.DeltakSRP__Result__c = t.Result__c;
	     	tasks.add(t);
     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + t1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
     
     Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.update(tasks, dmlo);
      
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
			mail.setSenderDisplayName('Batch Processing- Tasks');
			mail.setSubject('Tasks Batch Process Completed');
			mail.setPlainTextBody('Tasks Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Tasks Batch Process has completed at:'+ DateTime.now()});
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