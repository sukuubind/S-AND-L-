/*
- Query existing Person records
- Create new Persons records using Deltak_SRP__Person
- Associate new Person record with Old Person record via bi-directional look up
*/

global without sharing class UpdateSrmToSrpPersons implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id,First_Name__c,Last_Name__c,Middle_name__C,person__c  FROM Person__c where person__c = null';
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global UpdateSrmToSrpPersons(String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		System.debug('UpdateSrmToSrpPersons');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	   
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Person');
			mail.setSubject('Batch Process Started');
			mail.setPlainTextBody('Person - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Person - Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query); //+' where Id = \'a0KJ00000029s4k\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Person__c> persons = new List<DeltakSRP__Person__c>();
     List <Person__c> oldPersons = new List<Person__c>();
     
     Map<Id,DeltakSRP__Person__c> oldPersonsMap = new Map<Id,DeltakSRP__Person__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	DeltakSRP__Person__c per1 = new DeltakSRP__Person__c();
	     	
	     	per1.DeltakSRP__First_Name__c = ((Person__c)c1).First_Name__c;
	     	per1.DeltakSRP__Last_Name__c = ((Person__c)c1).Last_Name__c;
	     	per1.DeltakSRP__Middle_Name__c = ((Person__c)c1).Middle_Name__c;
	     	per1.Na4Person__c = c1.id;
	     	persons.add(per1);
	     	
	     	// old person to new person map
	     	oldPersonsMap.put(((Person__c)c1).Id, per1);
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(persons, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + persons[cCount].Na4Person__c + ' Message(s): ' + sr.getErrors());
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
     	try{
     		
     		Person__c per2 = ((Person__c)c1);
     		per2.Person__c = (oldPersonsMap.get(per2.Id)).Id;
     	     	
     		oldPersons.add(per2);
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(oldPersons, dmlo2);
      
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
			mail.setSenderDisplayName('Batch Processing- Person');
			mail.setSubject('Person Batch Process Completed');
			mail.setPlainTextBody('Person Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Person Batch Process has completed at:'+ DateTime.now()});
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