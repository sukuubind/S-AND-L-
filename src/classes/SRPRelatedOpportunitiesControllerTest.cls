@isTest
private with sharing class SRPRelatedOpportunitiesControllerTest {
	static testMethod void MyUnitTest() {
		
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
  		RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
  		RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'Student Opportunity' limit 1];
  		RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
  		
        Account a = new Account();
    	a.recordTypeid = rt1.Id;
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	Account a2 = new Account();
    	a2.recordTypeid = rt4.Id;
    	a2.Abbreviation__c = 'TAC2';
    	a2.name = 'test account 2';
    	insert a2;
		
		DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
        
        DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
        ap2.Name = 'abcde';
        ap2.DeltakSRP__School__c = a2.id;
        ap2.DeltakSRP__Degree_Type__c = 'Course';
        ap2.DeltakSRP__Abbrev__c = 'CID2';
        ap2.DeltakSRP__Program_Title__c = 'Course in CS2';
        insert ap2;
		
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
		
		 //insert a contact
        Contact c3 = new Contact();        
        c3.FirstName='Joe';
        c3.LastName='Smith';
        c3.AccountId = a2.id;
        insert c3;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = rt2.Id;
        o.CloseDate=system.today() + 365;
        o.StageName='dormant';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.deltaksrp__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        insert o;
        
        Opportunity o4 = new Opportunity();
		o4.RecordTypeId = rt2.Id;
        o4.CloseDate=system.today() + 365;
        o4.StageName='dormant';
        o4.deltaksrp__Academic_Program__c = ap.Id;           
        o4.AccountID=a.Id;
        o4.deltaksrp__Student__c=c1.Id;   
        o4.Start_Date__c = system.today() + 10;
        o4.Name='Test '; 
        insert o4;
        
        
		ApexPages.Standardcontroller sc = new Apexpages.Standardcontroller(o);
		
		SRPRelatedOpportunitiesController testObj = new SRPRelatedOpportunitiesController(sc);
		
		Opportunity o3 = new Opportunity();
		o3.RecordTypeId = rt3.Id;
        o3.CloseDate=system.today() + 365;
        o3.StageName='New Inquiry';
        o3.deltaksrp__Academic_Program__c = ap2.Id;           
        o3.AccountID=a2.Id;
        o3.Student__c=c3.Id; 
        o3.Start_Date__c = system.today() + 10;
        o3.Name='Test 3 '; 
        insert o3;
		
		ApexPages.Standardcontroller sc3 = new Apexpages.Standardcontroller(o3);
		
		SRPRelatedOpportunitiesController testObj3 = new SRPRelatedOpportunitiesController(sc3);
		
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
		
		SRPRelatedOpportunitiesController testObj2 = new SRPRelatedOpportunitiesController(sc2);
		
		Opportunity o5 = new Opportunity();
		o5.RecordType = rt2;
        o5.CloseDate=system.today() + 365;
        o5.StageName='dormant';
        o5.deltaksrp__Academic_Program__c = ap.Id;           
        o5.AccountID=a.Id;
        o5.Student__c=c2.Id;   
        o5.Start_Date__c = system.today() + 10;
        o5.Name='Test 2 '; 
        
        
        ApexPages.Standardcontroller sc5 = new Apexpages.Standardcontroller(o5);
		
		SRPRelatedOpportunitiesController testObj5 = new SRPRelatedOpportunitiesController(sc5);
		
	}
}