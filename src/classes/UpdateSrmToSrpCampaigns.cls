global without sharing class UpdateSrmToSrpCampaigns implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT name,ActualCost, DeltakSRP__SRP_Actual_Cost__c, Id, DeltakSRP__Academic_Institution__c, RecordTypeId FROM Campaign where RecordType.Name= \'Student Marketing Campaigns\'';
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global UpdateSrmToSrpCampaigns(String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		System.debug('UpdateSrmToSrpCampaigns');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Campaigns');
			mail.setSubject('Campaign Batch Process Started');
			mail.setPlainTextBody('Campaign Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Campaign Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <Campaign> campaigns = new List<Campaign>();
     Id srpCampaignRecordTypeId = [Select Id from RecordType where name = 'SRP Campaign'].Id;
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	Campaign c = (Campaign) c1;
     	
     	try {
	     	c.DeltakSRP__SRP_Actual_Cost__c = c.ActualCost; 
	     	c.RecordTypeId = srpCampaignRecordTypeId;
	     	campaigns.add(c);
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
	Database.DMLOptions dmlo = new Database.DMLOptions();
     dmlo.optAllOrNone = false;
     List<Database.SaveResult> srList= Database.update(campaigns, dmlo);
      
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
			mail.setSubject('Campaign Batch Process Completed');
			mail.setPlainTextBody('Campaign Batch Process has completed at:'+ DateTime.now());
		
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Campaign Batch Process has completed at:'+ DateTime.now()});
   		
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