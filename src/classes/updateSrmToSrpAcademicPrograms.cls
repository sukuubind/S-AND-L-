/*
- Query existing Academic Program records
- Create new SRP Academic Program records
- Associate SRP  Academic Program with SRM  Academic Program record via bi-directional look up
*/

global without sharing class updateSrmToSrpAcademicPrograms implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id,Name,Abbrev__c,Active__c,Campus_Program_Id__c,DegreeType__c,Maturity_Status__c,On_Ground_Only__c,Payback_Type__c,Program_Category__c,Program_Description__c,ProgramExtId__c,Program_Stage__c,Program_Title__c,Require_Specialization__c,School__c,Academic_Program__c From  Academic_Program__c';
	global Id AccountId {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global updateSrmToSrpAcademicPrograms(Id acId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = acId;
		System.debug('updateSrmToSrpAcademicPrograms');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Academic Program');
			mail.setSubject('Academic Program Batch Process Started');
			mail.setPlainTextBody('Academic Program - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Academic Program - Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query+' Where School__c=\''+AccountId+'\'' + 'and Academic_Program__c = null'); //AND Id=\'a066000000CKiIg\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Academic_Program__c> srpPrograms = new List<DeltakSRP__Academic_Program__c>();
     List <Academic_Program__c> srmPrograms = new List<Academic_Program__c>();
     
     Map<Id,DeltakSRP__Academic_Program__c> srmProgramsMap = new Map<Id,DeltakSRP__Academic_Program__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
     	
	     	DeltakSRP__Academic_Program__c per1 = new DeltakSRP__Academic_Program__c();
			
			if(((Academic_Program__c)c1).Abbrev__c != null && ((Academic_Program__c)c1).Abbrev__c.length()>20)
	     		per1.DeltakSRP__Abbrev__c=((Academic_Program__c)c1).Abbrev__c.substring(0,19);
	     	else
	     		per1.DeltakSRP__Abbrev__c=((Academic_Program__c)c1).Abbrev__c;	     	
	     		
	     	per1.DeltakSRP__Active__c=((Academic_Program__c)c1).Active__c;
	     	if(per1.DeltakSRP__Campus_Program_Id__c != null)
	     		per1.DeltakSRP__Campus_Program_Id__c=((Academic_Program__c)c1).Campus_Program_Id__c + per1.id;
	     	per1.DeltakSRP__Degree_Type__c=((Academic_Program__c)c1).DegreeType__c;
	     	per1.DeltakSRP__Maturity_Status__c=((Academic_Program__c)c1).Maturity_Status__c;
	     	per1.DeltakSRP__On_Ground_Only__c=((Academic_Program__c)c1).On_Ground_Only__c;
	     	per1.DeltakSRP__Payback_Type__c=((Academic_Program__c)c1).Payback_Type__c;
	     	per1.DeltakSRP__Program_Category__c=((Academic_Program__c)c1).Program_Category__c;
	     	per1.DeltakSRP__Program_Description__c=((Academic_Program__c)c1).Program_Description__c;
	     	per1.DeltakSRP__SIS_Id__c=((Academic_Program__c)c1).ProgramExtId__c;
	     	per1.DeltakSRP__Program_Stage__c=((Academic_Program__c)c1).Program_Stage__c;
	     	per1.DeltakSRP__Program_Title__c=((Academic_Program__c)c1).Program_Title__c;
	     	per1.DeltakSRP__Require_Specialization__c=((Academic_Program__c)c1).Require_Specialization__c;
	     	per1.DeltakSRP__School__c=((Academic_Program__c)c1).School__c;
	     	per1.Name=((Academic_Program__c)c1).Name;
	     	per1.Academic_Program__c = c1.Id;
	
	     	srpPrograms.add(per1);
	     	
	     	// SRM Program to SRP Program map
	     	srmProgramsMap.put(((Academic_Program__c)c1).Id, per1);
     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(srpPrograms, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + srpPrograms[cCount].Academic_Program__c + ' Message(s): ' + sr.getErrors());
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
      
      //Now update old program with new program record
       for(Sobject c1 : scope)
     { 
     	try {
     	
	     	Academic_Program__c per2 = ((Academic_Program__c)c1);
	     	per2.Academic_Program__c = (srmProgramsMap.get(per2.Id)).Id;
	     	
	     	srmPrograms.add(per2);  
	     	 
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}  
     }
     
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.update(srmPrograms, dmlo2);
      
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
			mail.setSenderDisplayName('Batch Processing- Academic Program');
			mail.setSubject('Academic Program Batch Process Completed');
			mail.setPlainTextBody('Academic Program Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Academic Program Batch Process has completed at:'+ DateTime.now()});
   		
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