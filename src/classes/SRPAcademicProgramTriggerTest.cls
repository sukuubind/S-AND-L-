@istest
private class SRPAcademicProgramTriggerTest{
        static testMethod void myUnitTest() {
	        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname';
	        c.LastName = 'lname';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        
	        // Test Case for Brand New Lead
	 
	        
	         
	        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
	        ap.Name = 'abcd';
	        ap.DeltakSRP__School__c = a.id;
	        ap.DeltakSRP__Degree_Type__c = 'Certificate';
	        ap.DeltakSRP__Abbrev__c = 'CID';
	        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
	        insert ap;
	        
	        Opportunity o2 = new Opportunity();
	        o2.RecordTypeId = rt3.Id;
	        o2.Name = 'Test Opportunity';
	        o2.StageName = 'New Inquiry';
	        o2.CloseDate = system.today()+100;
	        o2.DeltakSRP__Student__c = c.Id;
	        o2.Student__c = c.Id;
	        o2.DeltakSRP__Lead_Source_ID__c = '12345';
	        o2.DeltakSRP__Academic_Program__c = ap.Id;
	        o2.AccountId = a.Id;
	        insert o2;
	        try
	        {
	        	delete ap;
	        }catch(Exception e){
	        	
	        }	
	        
        }
}