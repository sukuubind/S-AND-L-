@isTest(seealldata = true)
private class SRPOpportunityAfterOwnerTriggerTest {

    static testMethod void myUnitTest() {
        	Account a = new Account();
            a.Name = 'Test Account 2';
            insert a;
            
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';
            c.AccountID = a.Id;
            c.deltaksrp__Employer_Company__c = 'Apple';
            c.DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId();
            insert c;
            
            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
	        ap.Name = 'Test Program';
	        ap.DeltakSRP__School__c = a.Id;
	        insert ap;
            
            List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
            List<User> u = new List<User>();
            u = [Select Id from User where name ='Prospect Engine' LIMIT 1];
            
            if(u.size()==0)
            	u = [Select Id from User where id = : userinfo.getuserid()];
            
            Opportunity o = new Opportunity();
            o.CloseDate=system.today()+100;
            o.StageName='New Inquiry';
            o.deltaksrp__academic_Program__c = ap.Id;           
            o.AccountID=a.Id;
            o.deltaksrp__Student__c=c.Id;   
            o.deltaksrp__Start_Date__c = system.today();
            o.Name='Test '; 
            o.RecordTypeId = recList[0].Id;
            o.OwnerId = u[0].id;
            insert o;
            
            o.OwnerId = userinfo.getUserId();
            update o;
            
            Contact c2 = [Select ownerid from Contact where id=: c.Id];
            system.assertequals(c2.ownerid, userinfo.getuserid());
            
    }
}