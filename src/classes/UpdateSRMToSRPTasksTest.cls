@isTest
private class UpdateSRMToSRPTasksTest {

    static testMethod void myUnitTest() {
    	
    	SRPTriggerOverrideInSRM__c setting = new SRPTriggerOverrideInSRM__c();
    	setting.SRPTaskTrigger__c = true;
    	setting.SRPTaskTriggerBefore__c = true;
    	setting.SRPTaskTriggerDelete__c = true;
    	setting.setupownerid = userinfo.getuserid();
    	insert setting;
    	
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
    	
    	Id srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
    	
    	Opportunity o = new Opportunity();
    	o.name = 'test Oppty';
    	o.CloseDate = system.today() + 100;
    	o.StageName = 'New Inquiry';
    	o.AccountId = a.id;
    	o.RecordTypeId = srmOppRecordType;
    	insert o;

    	Id taskRecordType = [Select Id from RecordType where name= 'Deltak: Student'].Id;
    	
        List<Task> tasksToInsert = new List<Task>();
        //for(Integer i=0; i<2; i++){
            Task t = new Task();
            t.completed_date__c = system.today();
            t.WhoId = c.Id;
            t.WhatId = o.Id;
            t.type = 'Call';
            t.Result__c = 'Successful';
            t.Event_status__c = 'Not Started';
            t.DeltakSRP__Event_status__c = null;
            t.RecordTypeId = taskRecordType;
            TasksToInsert.add(t);
        //}
        insert tasksToinsert;
      
      tasksToinsert[0].DeltakSRP__Event_status__c = null;
      update tasksToinsert[0];
      
       test.starttest();
       	String chatterFeedItemId = postChatterGroupFeedItem('Tasks');
       UpdateSrmToSrpTasks testObj = new UpdateSrmToSrpTasks(a.Id,chatterFeedItemId,new List<String>{'test@email.com'}); 
        Id BatchId = Database.executeBatch(testObj, 200); 
       test.stoptest(); 
       
       Task tasktoverify = [Select completed_date__c, deltaksrp__completed_date__c from Task where Id =:tasksToInsert[0].Id];
       system.assertequals(tasktoverify.completed_date__c, tasktoverify.deltaksrp__completed_date__c);
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