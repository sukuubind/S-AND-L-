/*
- Query existing SRM Fiscal Calendars
- Create new SRP Fiscal Calendar records
- Associate SRP Fiscal Calendarn with SRM Fiscal Calendar record via bi-directional look up
*/


global without sharing class updateSrmToSrpFiscalCalendar implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id, OwnerId, Name, End_Date__c, Period__c, Start_Date__c, Year__c  FROM Fiscal_Calendar__c Where (SRP_Fiscal_Calendar__c = null OR SRP_Fiscal_Calendar__c = \'\')';	
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}

	global updateSrmToSrpFiscalCalendar(String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		System.debug('updateSrmToSrpFiscalCalendar');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Fiscal Calendar');
			mail.setSubject('Fiscal Calendar Batch Process Started');
			mail.setPlainTextBody('Fiscal Calendar - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Fiscal Calendar - Batch Process has started at:'+ DateTime.now()});
   		
		System.debug('Query->'+query);
      return Database.getQueryLocator(query); //+' AND Id=\'a006000000G8Xv7\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Fiscal_Calendar__c> srpCalendar = new List<DeltakSRP__Fiscal_Calendar__c>();
     List <Fiscal_Calendar__c> srmCalendar = new List<Fiscal_Calendar__c>();
     
     Map<Id,DeltakSRP__Fiscal_Calendar__c> srmCalendarMap = new Map<Id,DeltakSRP__Fiscal_Calendar__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
     	
	     	DeltakSRP__Fiscal_Calendar__c per1 = new DeltakSRP__Fiscal_Calendar__c();
	     	
	     	per1.SRM_Fiscal_Calendar__c = c1.Id; 
	     	per1.Name = ((Fiscal_Calendar__c)c1).Name;
	     	per1.DeltakSRP__End_Date__c = ((Fiscal_Calendar__c)c1).End_Date__c;
	     	per1.DeltakSRP__Period__c = ((Fiscal_Calendar__c)c1).Period__c;
	     	per1.DeltakSRP__Start_Date__c = ((Fiscal_Calendar__c)c1).Start_Date__c;
	     	per1.OwnerId = ((Fiscal_Calendar__c)c1).ownerId;
	     	
	     	srpCalendar.add(per1);
	     	 
	     	// SRM Calendar to SRP Calendar map
	     	srmCalendarMap.put(((Fiscal_Calendar__c)c1).Id, per1);
     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(srpCalendar, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + srpCalendar[cCount].SRM_Fiscal_Calendar__c + ' Message(s): ' + sr.getErrors());
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
     	
	     	Fiscal_Calendar__c per2 = ((Fiscal_Calendar__c)c1);
	     	per2.SRP_Fiscal_Calendar__c = (srmCalendarMap.get(per2.Id)).Id;
	     	
	     	srmCalendar.add(per2); 
     	    
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(srmCalendar, dmlo2);
      
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
			mail.setSenderDisplayName('Batch Processing- Fiscal Calendar');
			mail.setSubject('Fiscal Calendar Batch Process Completed');
			mail.setPlainTextBody('Fiscal Calendar Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Fiscal Calendar Batch Process has completed at:'+ DateTime.now()});
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