global without sharing class UpdateSrmToSrpUserBatch implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Admissions_Email__c, DeltakSRP__Admissions_Email__c, DeltakSRP__Admissions_Extension__c, Admissions_Extension__c FROM User Where (Admissions_Email__c != null and DeltakSRP__Admissions_Email__c=null) or (Admissions_Extension__c != null and DeltakSRP__Admissions_Extension__c=null)';
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global UpdateSrmToSrpUserBatch(String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		System.debug('UpdateSrmToSrpUserBatch');
	} 
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   		if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Users');
			mail.setSubject('Users Batch Process Started');
			mail.setPlainTextBody('Users Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Users Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <User> users = new List<User>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject u1 : scope)
     { 
     	User u = (User) u1;
     	
     	try {
	     	
	     	u.DeltakSRP__Admissions_Email__c = u.Admissions_Email__c;
	     	u.DeltakSRP__Admissions_Extension__c = u.Admissions_Extension__c;
	     	users.add(u);
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + u.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}	
     }
     
     
     Database.DMLOptions dmlo = new Database.DMLOptions();
     dmlo.optAllOrNone = false;
     List<Database.SaveResult> srList= Database.update(users, dmlo);
      
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
			mail.setSenderDisplayName('Batch Processing- Users');
			mail.setSubject('Users Batch Process Completed');
			mail.setPlainTextBody('Users Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Users Batch Process has completed at:'+ DateTime.now()});
   		
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