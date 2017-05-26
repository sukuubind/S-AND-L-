global without sharing class updateSRPPersons implements  Database.Batchable<Sobject> {
	
	global final String Query = 'SELECT Id,deltaksrp__indexer__c  FROM deltaksrp__Person__c';
	
	global updateSRPPersons(){ 
		
		System.debug('UpdateSrmToSrpPersons');
	}
   	
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  /*  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(new String[] {'fadi.shami@deltak-innovation.com','Michelle.Mitchell@deltak-innovation.com'});
		mail.setReplyTo('fadi.shami@deltak-innovation.com');
		mail.setSenderDisplayName('Batch Processing- Person');
		mail.setSubject('Batch Process Started');
		mail.setPlainTextBody('Person - Batch Process has started at:'+ DateTime.now());
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		*/
		
      return Database.getQueryLocator(query); //+' where Id = \'a0KJ00000029s4k\'');
   }
   
   global void execute(Database.BatchableContext BC, List<SObject> scope){
     
     List <DeltakSRP__Person__c> persons = new List<DeltakSRP__Person__c>();

     
     for(Sobject c1 : scope)
     { 
     	
	//	((DeltakSRP__Person__c)c1).deltaksrp__Indexer__c = 'l';
     	persons.add(((DeltakSRP__Person__c)c1));

     }
     
      Database.SaveResult[] results = Database.update(persons);

      
    }

   global void finish(Database.BatchableContext BC){
   		
   		/*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(new String[] {'fadi.shami@deltak-innovation.com','Michelle.Mitchell@deltak-innovation.com'});
		mail.setReplyTo('fadi.shami@deltak-innovation.com');
		mail.setSenderDisplayName('Batch Processing- Campaigns');
		mail.setSubject('Person Batch Process Completed');
		mail.setPlainTextBody('Person Batch Process has completed at:'+ DateTime.now());
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); */
   }

}