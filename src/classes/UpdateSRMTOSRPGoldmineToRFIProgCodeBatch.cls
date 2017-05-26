global without sharing class UpdateSRMTOSRPGoldmineToRFIProgCodeBatch implements  Database.Batchable<Sobject> {
	global final String Query = 'SELECT Program_Id__c, Specialization_Id__c, Account__c, GM2SFExtId__c, Goldmine_Program__c FROM Goldmine_to_Salesforce_Program__c';
	global Id AccountId {get;set;}
	
	global String chatterFeedItemId {get;set;}
	global List<String> emailAddressList {get;set;}
	
	global UpdateSRMTOSRPGoldmineToRFIProgCodeBatch(Id acId,String chatterFeedItemId, List<String> emailAddressList){
		this.chatterFeedItemId = chatterFeedItemId;
		this.emailAddressList = emailAddressList;
		this.AccountId = acId;
		System.debug('UpdateSRMTOSRMGoldmineToSFRFITOAPBatch');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	    
   	    if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Goldmine To SF Program');
			mail.setSubject('Users Batch Process Started');
			mail.setPlainTextBody('Goldmine To SF Programs - Batch Process has started at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Goldmine To SF Programs - Batch Process has started at:'+ DateTime.now()});
   		
      return Database.getQueryLocator(query+' Where Account__c=\''+AccountId+'\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     try {
	     
	     List <RFI_to_Academic_Programs_Code__c> objs = new List<RFI_to_Academic_Programs_Code__c>();
	     List<Id> progIds = new List<Id>();
	     List<Id> specIds = new List<Id>();
	     
	     List<DeltakSRP__Academic_Program__c> srpprogs = new List<DeltakSRP__Academic_Program__c>();
	     List<DeltakSRP__Academic_Specialization__c> srpspecs = new List<DeltakSRP__Academic_Specialization__c>();
	     
	     for(Sobject o1 : scope){
	     	if(((Goldmine_to_Salesforce_Program__c)o1).Program_Id__c != null)
	     		progIds.add(((Goldmine_to_Salesforce_Program__c)o1).Program_Id__c);	
	     		
	     	if(((Goldmine_to_Salesforce_Program__c)o1).Specialization_Id__c != null)	
	     		specIds.add(((Goldmine_to_Salesforce_Program__c)o1).Specialization_Id__c);
	     }
	     
	     srpprogs = [Select Id, Academic_Program__c from DeltakSRP__Academic_Program__c where Academic_Program__c in: progIds];
	     srpspecs = [Select Id, SRM_Academic_Specialization__c from DeltakSRP__Academic_Specialization__c where SRM_Academic_Specialization__c in: specIds];
	     
	     Map<Id,Id> srmtosrpprogsmap = new Map<Id, Id>();
	     Map<Id,Id> srmtosrpspecsmap = new Map<Id, Id>();
	     
	     for(DeltakSRP__Academic_Specialization__c das: srpspecs){
	     	srmtosrpspecsmap.put(das.SRM_Academic_Specialization__c, das.Id);
	     }
	     
	     for(DeltakSRP__Academic_Program__c dap: srpprogs){
	     	srmtosrpprogsmap.put(dap.Academic_Program__c, dap.Id);
	     }
	     
	     List<String> processingErrorList = new List<String>();
	     
	     for(Sobject o1 : scope)
	     { 
	     	try {
	     	
		     	if(srmtosrpprogsmap.get(((Goldmine_to_Salesforce_Program__c)o1).Program_Id__c) != null){
			     	RFI_to_Academic_Programs_Code__c obj = new RFI_to_Academic_Programs_Code__c();
			     	obj.Goldmine_To_SF_Program_Id__c = ((Goldmine_to_Salesforce_Program__c)o1).id;
			     	obj.Academic_Program__c = srmtosrpprogsmap.get(((Goldmine_to_Salesforce_Program__c)o1).Program_Id__c);
			     	obj.Academic_Specialization__c = srmtosrpspecsmap.get(((Goldmine_to_Salesforce_Program__c)o1).Specialization_Id__c);
			     	obj.Program_Code__c = ((Goldmine_to_Salesforce_Program__c)o1).Goldmine_Program__c;
			     	objs.add(obj);
			     	system.debug('obj>>>>'+objs);
		     	}	
		     	
	     	} catch(Exception e) {
	     		processingErrorList.add('Processing Error -- Id: ' + o1.Id + ' Line#: ' + e.getLineNumber() + ' Message(s): ' + e);
	     	}
	     }
	     
	     
	     
	      Database.DMLOptions dmlo = new Database.DMLOptions();
	      dmlo.optAllOrNone = false;
	      List<Database.SaveResult> srList= Database.insert(objs, dmlo);
	      
	      Integer cCount = 0;
	      
	      List<String> insertErrorList = new List<String>();
	      
	      for(Database.SaveResult sr : srList)
	      {
	        if(!sr.isSuccess())
	        {
	        	insertErrorList.add('Insert Error -- Id: ' + objs[cCount].Goldmine_To_SF_Program_Id__c + ' Message(s): ' + sr.getErrors());
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
	     
	     
     } catch(Exception e) {
     	this.postCommentsToChatterFeedItem(new List<String>{'Processing Error -- Line#: ' + e.getLineNumber() + ' Message(s): ' + e});
     }
     
    }

   global void finish(Database.BatchableContext BC){
   		
   		if(this.emailAddressList != null && this.emailAddressList.size() > 0)
   		{
	   	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
			mail.setToAddresses(this.emailAddressList);
			mail.setSenderDisplayName('Batch Processing- Goldmine to SF Program');
			mail.setSubject('Users Batch Process Completed');
			mail.setPlainTextBody('Goldmine To SF Programs Batch Process has completed at:'+ DateTime.now());
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
   		
   		this.postCommentsToChatterFeedItem(new List<String>{'Goldmine To SF Programs Batch Process has completed at:'+ DateTime.now()});
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