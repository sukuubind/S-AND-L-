@isTest(seealldata=true)
private class UpdateSRMToSRPEventsTest{
    static testMethod void myUnitTest() {
    	
    	Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
    	Academic_Program__c ap = new Academic_Program__c();
        ap.School__c = a.Id;
        insert ap;
    	    	
    	Id srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
    	
    	Opportunity o = new Opportunity();
    	o.name = 'test Oppty';
    	o.CloseDate = system.today() + 100;
    	o.StageName = 'New Inquiry';
    	o.AccountId = a.id;
    	o.RecordTypeId = srmOppRecordType;
    	o.Program__c = ap.Id;
        insert o;
    	
    	ID srmRecType = [select id from recordtype where name = 'Deltak: Student Event*'].Id;
        List<Event> eventsToInsert = new List<Event>();
        for(Integer i=0; i<200; i++){
          Event e = new Event();
          e.DurationInMinutes = 10;
          e.recordtypeid = srmRecType;
          e.ActivityDateTime = system.today();
          e.Completed_Date__c = system.today();
          e.WhoId = c.Id;
          e.whatid = o.id;
          EventsToInsert.add(e);
        }
        insert eventsToinsert;
      system.debug('eventsToinsert>>>>'+eventsToinsert[0].RecurrenceStartDateTime);
       test.starttest();
       String chatterFeedItemId = postChatterGroupFeedItem('Program Admission Documents');
       UpdateSrmToSrpEvents testObj = new UpdateSrmToSrpEvents(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
        Id BatchId = Database.executeBatch(testObj, 200); 
       test.stoptest(); 
       
       Event e = [Select Completed_Date__c, DeltakSRP__Completed_Date__c from event where Id = :eventsToInsert[0].Id];
       
       system.assertequals(e.Completed_Date__c, e.deltaksrp__Completed_Date__c);
    }
    
     private static String postChatterGroupFeedItem(String targetUpdate)
	{
		String chatterFeedItemId;
		
		 
		CollaborationGroup cg = new CollaborationGroup();
		cg.Name = 'SRM To SRP Migration Status Test';
		cg.CollaborationType='Private';
		insert cg;
		
		String chatterFeedId = cg.Id + '';
		
		if(chatterFeedId != null && chatterFeedId != '')
		{
		
			FeedItem fi = new FeedItem();
	      	fi.Body = 'Update ' + targetUpdate + ' batch process queued by [' + UserInfo.getUserEmail() +']';
	      	fi.ParentId = chatterFeedId;
	      	insert fi;
	      
	      	chatterFeedItemId = fi.Id + '';
		
		}
		
		return chatterFeedItemId;
		
	}
    
}