@isTest
private with sharing class SRPWarningBarControllerTest {
	static testMethod void MyUnitTest() {
		
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
  		RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
  		RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'Student Opportunity' limit 1];
  		
        Account a = new Account();
    	a.recordTypeid = rt1.Id;
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
		
		DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
		
		  //insert a contact
        Contact c1 = new Contact();        
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.id;
        c1.DoNotCall = true;
        c1.DeltakSRPSMS__Ok_To_Text__c = true;
        c1.HasOptedOutOfEmail = true;
        c1.Recorded_Call__c = 'Yes';
        insert c1;
        
        Contact c2 = new Contact();        
        c2.FirstName='Joe';
        c2.LastName='Smith';
        c2.AccountId = a.id;
        c2.DoNotCall = false;
        c2.DeltakSRPSMS__Ok_To_Text__c = false;
        c2.HasOptedOutOfEmail = false;
        c2.Recorded_Call__c = 'No';
        insert c2;
		
		Opportunity o = new Opportunity();
		o.RecordType = rt2;
        o.CloseDate=system.today() + 365;
        o.StageName='dormant';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.deltaksrp__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        insert o;
        
        Opportunity o4 = new Opportunity();
		o4.RecordType = rt2;
        o4.CloseDate=system.today() + 365;
        o4.StageName='dormant';
        o4.deltaksrp__Academic_Program__c = ap.Id;           
        o4.AccountID=a.Id;
        o4.deltaksrp__Student__c=c1.Id;   
        o4.Start_Date__c = system.today() + 10;
        o4.Name='Test '; 
        insert o4;
        
        
		ApexPages.Standardcontroller sc = new Apexpages.Standardcontroller(o);
		
		SRPWarningBarController testObj = new SRPWarningBarController(sc);
		
		Opportunity o3 = new Opportunity();
		o3.RecordType = rt3;
        o3.CloseDate=system.today() + 365;
        o3.StageName='dormant';
        o3.deltaksrp__Academic_Program__c = ap.Id;           
        o3.AccountID=a.Id;
        o3.Student__c=c1.Id;   
        o3.Start_Date__c = system.today() + 10;
        o3.Name='Test 3 '; 
        insert o3;
		
		ApexPages.Standardcontroller sc3 = new Apexpages.Standardcontroller(o3);
		
		SRPWarningBarController testObj3 = new SRPWarningBarController(sc3);
		
		Opportunity o2 = new Opportunity();
		o2.RecordType = rt2;
        o2.CloseDate=system.today() + 365;
        o2.StageName='dormant';
        o2.deltaksrp__Academic_Program__c = ap.Id;           
        o2.AccountID=a.Id;
        o2.Student__c=c2.Id;   
        o2.Start_Date__c = system.today() + 10;
        o2.Name='Test 2 '; 
        insert o2;
        
        ApexPages.Standardcontroller sc2 = new Apexpages.Standardcontroller(o2);
		
		SRPWarningBarController testObj2 = new SRPWarningBarController(sc2);
	}
}