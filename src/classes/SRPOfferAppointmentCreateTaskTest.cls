@isTest(seealldata=true)
public with sharing class SRPOfferAppointmentCreateTaskTest {
	
	static testMethod void testTaskCreation() {
		
		RecordType rt = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
		RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
		
		Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
		
		contact c = new Contact();
        c.FirstName = 'fname1';
        c.LastName = 'lname1';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt2.Id;
        insert c;		
			
		Opportunity o2 = new Opportunity();
        o2.RecordTypeId = rt.Id;
        o2.Name = 'Test Opportunity';
        o2.StageName = 'New Inquiry';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c.Id;
        o2.Student__c = c.Id;
        o2.AccountId = a.Id;
        insert o2;
        
        List<id> opList = new List<id>();        
        opList.add(o2.id);
        
        SRPOfferAppointmentCreateTask.createOfferAppointmentTask(opList);
		
	}
	
	static testMethod void testcheckRec() {
		checkRecursive.runOnce();
	}

}