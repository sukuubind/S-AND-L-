/*
- Query existing Academic Program Specialization records for a given Partner
- Create new SRP Academic Program Specialization records
- Associate SRP  Academic Program Specialization with SRM  Academic Program Specialization record via bi-directional look up
*/

global without sharing class updateSrmToSrpAcademicProgramsSpeci implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id, Academic_Program__c,Academic_Program__r.Academic_Program__c , Name, Active__c, SRP_Academic_Specialization__c, School_Id__c, SpecialExtId__c, Specialization_Abbrev__c, Specialization_Description__c, Spec_Title__c FROM Academic_Specialization__c';	
	global Id AccountId {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	/*
	Academic_Program__c
	Active__c
	
	SpecialExtId__c
	Specialization_Abbrev__c
	Specialization_Description__c
	Spec_Title__c
	*/

	global updateSrmToSrpAcademicProgramsSpeci(Id acId, String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = acId;
		System.debug('updateSrmToSrpAcademicProgramsSpeci');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Academic Program Specialization');
			mail.setSubject('Academic Program Specialization Batch Process Started');
			mail.setPlainTextBody('Academic Program Specialization - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Academic Program Specialization - Batch Process has started at:'+ DateTime.now()});
   		
		System.debug('Query->'+query+' Where School_Id__c=\''+AccountId+'\''); //+'\' AND Id=\'a07J0000005Vaaj\'');
      
      return Database.getQueryLocator(query+' Where School_Id__c=\''+((String)AccountId).substring(0,15)+'\'' + ' and SRP_Academic_Specialization__c = null'); //+'\' AND Id=\'a07J0000005Vaaj\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Academic_Specialization__c> srpSpecs = new List<DeltakSRP__Academic_Specialization__c>();
     List <Academic_Specialization__c> srmSpecs = new List<Academic_Specialization__c>();
     
     Map<Id,DeltakSRP__Academic_Specialization__c> srmSpecsMap = new Map<Id,DeltakSRP__Academic_Specialization__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	DeltakSRP__Academic_Specialization__c per1 = new DeltakSRP__Academic_Specialization__c();
	     	
	     	per1.SRM_Academic_Specialization__c = c1.Id; 
	     	per1.Name = ((Academic_Specialization__c)c1).Name;
	     	per1.DeltakSRP__Academic_Program__c = ((Academic_Specialization__c)c1).Academic_Program__r.Academic_Program__c;
	     	per1.DeltakSRP__Active__c = ((Academic_Specialization__c)c1).Active__c; 
	     	per1.DeltakSRP__Specialization_Abbreviation__c = ((Academic_Specialization__c)c1).Specialization_Abbrev__c; 
	     	per1.DeltakSRP__Specialization_Description__c = ((Academic_Specialization__c)c1).Specialization_Description__c; 
	     	per1.DeltakSRP__Specialization_Title__c = ((Academic_Specialization__c)c1).Spec_Title__c;	
	     	
	     	
	     	System.debug('Per1->'+per1);
	     	
	     	srpSpecs.add(per1);
	     	 
	     	// SRM Spec to SRP Spec map
	     	srmSpecsMap.put(((Academic_Specialization__c)c1).Id, per1);
	     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(srpSpecs, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + srpSpecs[cCount].SRM_Academic_Specialization__c + ' Message(s): ' + sr.getErrors());
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
     	
	     	Academic_Specialization__c per2 = ((Academic_Specialization__c)c1);
	     	per2.SRP_Academic_Specialization__c = (srmSpecsMap.get(per2.Id)).Id;
	     	
	     	srmSpecs.add(per2);  
	     	 
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}  
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(srmSpecs, dmlo2);
      
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
			mail.setSenderDisplayName('Batch Processing- Academic Program Specialization');
			mail.setSubject('Academic Program Specialization Batch Process Completed');
			mail.setPlainTextBody('Academic Program Specialization Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Academic Program Specialization Batch Process has completed at:'+ DateTime.now()});
   		
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