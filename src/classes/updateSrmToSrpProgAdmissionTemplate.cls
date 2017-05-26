/*
- Query existing SRM Program Admission Templates
- Create new SRP FProgram Admission Templates records
- Associate SRP Program Admission Templates with SRM Program Admission Templates record via bi-directional look up
*/


global without sharing class updateSrmToSrpProgAdmissionTemplate implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id,Name, School__c, SRP_Program_Admission_Template__c, Comments__c, Application_Fee__c, Description__c, Order__c, Program__c,Program__r.Academic_Program__c, Type__c, Required__c FROM Program_Admission_Template__c'; 
	global Id AccountId {get;set;}

	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}

	global updateSrmToSrpProgAdmissionTemplate(Id accId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = accId;
		System.debug('updateSrmToSrpProgAdmissionTemplate');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Program Admission Templates');
			mail.setSubject('Program Admission Templates Batch Process Started');
			mail.setPlainTextBody('Program Admission Templates - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Program Admission Templates - Batch Process has started at:'+ DateTime.now()});
   		
		System.debug('Query->'+query+' Where School__c=\''+((String)AccountId).substring(0,15)+'\'');
		
      return Database.getQueryLocator(query+' Where School__c=\''+((String)AccountId).substring(0,15)+'\' AND SRP_Program_Admission_Template__c = null'); //+' AND Id=\'a0MJ0000002jCrw\'');
   } 
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Program_Admission_Template__c> srpProgramAdmissionTemplate = new List<DeltakSRP__Program_Admission_Template__c>();
     List <Program_Admission_Template__c> srmProgramAdmissionTemplate = new List<Program_Admission_Template__c>();
     
     Map<Id,DeltakSRP__Program_Admission_Template__c> srmProgramAdmissionTemplateMap = new Map<Id,DeltakSRP__Program_Admission_Template__c>();
     
     List<String> processingErrorList = new List<String>();
     
     for(Sobject c1 : scope)
     { 
     	try {
	     	
	     	DeltakSRP__Program_Admission_Template__c per1 = new DeltakSRP__Program_Admission_Template__c();
	     	
	     	per1.SRM_Program_Admission_Template__c = c1.Id; 
	     	per1.DeltakSRP__Matching_ID__c = c1.Id; // need to be removed - make non required in package
	     	per1.DeltakSRP__Application_Fee__c = ((Program_Admission_Template__c)c1).Application_Fee__c;
	     	per1.DeltakSRP__Comments__c = ((Program_Admission_Template__c)c1).Comments__c;
	     	per1.DeltakSRP__Description__c = ((Program_Admission_Template__c)c1).Description__c;
	     	per1.DeltakSRP__Order__c = ((Program_Admission_Template__c)c1).Order__c;
	     	per1.DeltakSRP__Required__c = ((Program_Admission_Template__c)c1).Required__c;
	     	per1.DeltakSRP__Type__c = ((Program_Admission_Template__c)c1).Type__c;
	     	per1.DeltakSRP__Program__c = ((Program_Admission_Template__c)c1).Program__r.Academic_Program__c;
	     	per1.Name = ((Program_Admission_Template__c)c1).Name;
	     	
	     	srpProgramAdmissionTemplate.add(per1);
	     	 
	     	// SRM Calendar to SRP Calendar map
	     	srmProgramAdmissionTemplateMap.put(((Program_Admission_Template__c)c1).Id, per1);
	     	
     	} catch(Exception e) {
     		processingErrorList.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}
     }
     
      
      Database.DMLOptions dmlo = new Database.DMLOptions();
      dmlo.optAllOrNone = false;
      List<Database.SaveResult> srList= Database.insert(srpProgramAdmissionTemplate, dmlo);
      
      Integer cCount = 0;
      
      List<String> insertErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + srpProgramAdmissionTemplate[cCount].SRM_Program_Admission_Template__c + ' Message(s): ' + sr.getErrors());
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
      List<DeltakSRP__Program_Admission_Template_Selection__c> patselectionList = new List<DeltakSRP__Program_Admission_Template_Selection__c>();
      for(DeltakSRP__Program_Admission_Template__c dpat: srpProgramAdmissionTemplate){
      	try {
	      	
	      	DeltakSRP__Program_Admission_Template_Selection__c patSelection = new DeltakSRP__Program_Admission_Template_Selection__c();
	      	patSelection.DeltakSRP__Academic_Program__c = dpat.DeltakSRP__Program__c;
	      	patSelection.Name = dpat.Name;
	      	patSelection.DeltakSRP__Ext_Program_Admission_Template__c = dpat.DeltakSRP__Matching_ID__c;
	      	patselectionList.add(patSelection);
	      	
      	} catch(Exception e) {
      		processingErrorList2.add('Processing Error -- Name: ' + dpat.Name + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
      	}
      }
      
      
      Database.DMLOptions dmlo2 = new Database.DMLOptions();
      dmlo2.optAllOrNone = false;
      List<Database.SaveResult> srList2= Database.insert(patselectionList, dmlo2);
      
      Integer cCount2 = 0;
      
      List<String> insertErrorList2 = new List<String>();
      
      for(Database.SaveResult sr : srList2)
      {
        if(!sr.isSuccess())
        {
        	insertErrorList.add('Insert Error -- Id: ' + patselectionList[cCount2].Name + ' Message(s): ' + sr.getErrors());
        }
        
        cCount2++;
                
      }
     
     if(processingErrorList2.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(processingErrorList2);
     }
      
     if(insertErrorList2.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(insertErrorList2);
     }
      
      
      
      
      
      
      
      
      List<String> processingErrorList3 = new List<String>();
      
      //Now update old spec with new spec record
       for(Sobject c1 : scope)
     { 
     	try {
     	
	     	Program_Admission_Template__c  per2 = ((Program_Admission_Template__c )c1);
	     	per2.SRP_Program_Admission_Template__c = (srmProgramAdmissionTemplateMap.get(per2.Id)).Id;
	     	
	     	srmProgramAdmissionTemplate.add(per2);  
     	} catch(Exception e) {
     		processingErrorList2.add('Processing Error -- Id: ' + c1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
     	}   
     }
     
      
      Database.DMLOptions dmlo3 = new Database.DMLOptions();
      dmlo3.optAllOrNone = false;
      List<Database.SaveResult> srList3= Database.update(srmProgramAdmissionTemplate, dmlo3);
      
      List<String> saveErrorList = new List<String>();
      
      for(Database.SaveResult sr : srList3)
      {
        if(!sr.isSuccess())
        {
        	saveErrorList.add('Save Error -- Id: ' + sr.getId() + ' Message(s): ' + sr.getErrors());
        }
                
      }
     
     
     if(processingErrorList3.size() > 0)
     {
     	this.postCommentsToChatterFeedItem(processingErrorList3);
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
			mail.setSenderDisplayName('Batch Processing- Program Admission Templates');
			mail.setSubject('Program Admission Templates Batch Process Completed');
			mail.setPlainTextBody('Program Admission Templates Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Program Admission Templates Batch Process has completed at:'+ DateTime.now()});
   		
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