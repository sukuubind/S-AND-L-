/**
 Author: Pratik Tanna
 Date: 8/14/2013
 Description: Test class for Lead Trigger and other helper classes
 */
@isTest(seealldata=true)
private class SRPLeadTriggerHandlerTest {
	
	static testMethod void myUnitTest7() {
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
	        c.FirstName = 'fname8';
	        c.LastName = 'lname8';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        // Test Case for Brand New Lead
	        
	        List<Lead> leadlist = new List<Lead>();
	        
	        Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'fname8';
	        l.LastName = 'lname8';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        
	        leadlist.add(l);
	        
	        l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        
	        leadlist.add(l);
	        
	        
	       test.starttest();
	       system.debug('queries issues###'+ Limits.getQueries());
	       system.debug('queries limit###'+ Limits.getLIMitQueries());
	        insert leadlist;
	       system.debug('queries issues###'+ Limits.getQueries());
	       system.debug('queries limit###'+ Limits.getLIMitQueries()); 
	       test.stopTest(); 
	}
	
    static testMethod void myUnitTest() {
        
        user u = [Select Id from user where id=: userinfo.getUserId()];
        
        system.runas(u){
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
	        c.FirstName = 'fname1';
	        c.LastName = 'lname1';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        // Test Case for Brand New Lead
	        Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        l.country = 'United States';
	        test.starttest();
	        insert l;
	        System.Test.stopTest();
	        
	        //Opportunity o = new Opportunity();
	        //o = [Select Id, stagename from Opportunity where accountId = :a.Id];
	        //system.assertequals(o.stagename, 'New Inquiry');
	        
	        system.debug('total queries consumed 1>>>>'+Limits.getAggregateQueries());
	         
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
	        
	        
	        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
	        rapc.Academic_Program__c = ap.Id;
	        rapc.Program_Code__c = 'MSCS';
	        insert rapc;
	        
	        // testing case for exact duplicate
	        
	        Lead l2 = new Lead();
	        l2.Status = 'Open';
	        l2.Company = 'Deltak';
	        l2.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l2.FirstName = 'fname1';
	        l2.LastName = 'lname1';
	        l2.RecordTypeId = rt2.Id;
	        l2.DeltakSRP__AcademicProgram__c = 'MSCS';
	        l2.DeltakSRP__Lead_Source_ID__c = '12345';
	        l2.Phone = '1234567890';
	        l2.country = 'United States';
	        
	        insert l2;
	        
	        system.debug('total queries consumed 2>>>>'+Limits.getAggregateQueries());
        }
    }
    
    static testMethod void myUnitTest2() {
        
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
        c.FirstName = 'fname2';
        c.LastName = 'lname2';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt4.Id;
        insert c;
        
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
        
        
        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
        rapc.Academic_Program__c = ap.Id;
        rapc.Program_Code__c = 'MSCS';
        insert rapc;
         System.Test.startTest();
         Lead l3 = new Lead();
            l3.Status = 'Open';
            l3.Company = 'Deltak';
            l3.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
            l3.FirstName = 'fname2';
            l3.LastName = 'lname2';
            l3.RecordTypeId = rt2.Id;
            l3.DeltakSRP__AcademicProgram__c = 'MSCS';
            l3.DeltakSRP__Lead_Source_ID__c = '123456';
            l3.email = 'testemail@salesforce.com';
                   
            insert l3;
            system.debug('total queries consumed 3>>>>'+Limits.getAggregateQueries());
            test.stoptest();
        }
        
        static testMethod void myUnitTest3() {
        
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
        c.FirstName = 'fname3';
        c.LastName = 'lname3';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt4.Id;
        insert c;
        
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
        
        
        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
        rapc.Academic_Program__c = ap.Id;
        rapc.Program_Code__c = 'MSCS';
        insert rapc;
        
        Lead l4 = new Lead();
            l4.Status = 'Open';
            l4.Company = 'Deltak';
            l4.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
            l4.FirstName = 'fname4';
            l4.LastName = 'lname4';
            l4.RecordTypeId = rt2.Id;
            l4.DeltakSRP__AcademicProgram__c = 'MSCS2';
            l4.DeltakSRP__Lead_Source_ID__c = '123456';
            l4.email = 'testemail@salesforce.com';
            
            Test.startTest();       
            insert l4;
            test.stopTest();
            system.debug('total queries consumed 4>>>>'+Limits.getAggregateQueries());
        
        } 
        
        static testMethod void myUnitTest4() {
        
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
        c.FirstName = 'fname4';
        c.LastName = 'lname4';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt4.Id;
        insert c;
        
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
        o2.StageName = 'Dormant';
        o2.DeltakSRP__Sub_Stage__c = 'Duplicate Record';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c.Id;
        o2.Student__c = c.Id;
        o2.DeltakSRP__Lead_Source_ID__c = '12345';
        o2.DeltakSRP__Academic_Program__c = ap.Id;
        o2.AccountId = a.Id;
        insert o2;
        
        
        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
        rapc.Academic_Program__c = ap.Id;
        rapc.Program_Code__c = 'MSCS';
        insert rapc;
        
        Lead l4 = new Lead();
            l4.Status = 'Open';
            l4.Company = 'Deltak';
            l4.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
            l4.FirstName = 'fname4';
            l4.LastName = 'lname4';
            l4.RecordTypeId = rt2.Id;
            l4.DeltakSRP__AcademicProgram__c = 'MSCS2';
            l4.DeltakSRP__Lead_Source_ID__c = '123456';
            l4.email = 'testemail@salesforce.com';
            
            Test.startTest();         
            insert l4;
            Test.stopTest();  
            system.debug('total queries consumed 5>>>>'+Limits.getAggregateQueries());
        
        } 
        
        static testMethod void myUnitTest5() {
        
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
        c.FirstName = 'fname5';
        c.LastName = 'lname5';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt4.Id;
        insert c;
        
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
        o2.StageName = 'Dormant';
        o2.DeltakSRP__Sub_Stage__c = 'Duplicate Record';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c.Id;
        o2.Student__c = c.Id;
        o2.DeltakSRP__Lead_Source_ID__c = '12345';
        o2.DeltakSRP__Academic_Program__c = ap.Id;
        o2.AccountId = a.Id;
        insert o2;
        
        
        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
        rapc.Academic_Program__c = ap.Id;
        rapc.Program_Code__c = 'MSCS';
        insert rapc;
        
        Lead l4 = new Lead();
            l4.Status = 'Open';
            l4.Company = 'Deltak';
            l4.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
            l4.FirstName = 'fname5';
            l4.LastName = 'lname5';
            l4.RecordTypeId = rt2.Id;
            l4.DeltakSRP__AcademicProgram__c = 'MSCS';
            l4.DeltakSRP__Lead_Source_ID__c = '123456';
            l4.email = 'testemail@salesforce.com';
            
            test.startTest();       
            insert l4;
            test.stopTest();
            system.debug('total queries consumed 6>>>>'+Limits.getAggregateQueries());
        
        } 
        
        static testMethod void myUnitTest6() {
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
        
        
        Account a2 = new Account();
        a2.recordTypeid = rt1.Id;
        a2.Abbreviation__c = 'TAC2';
        a2.name = 'test account2';
        insert a2;
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        contact c = new Contact();
        c.FirstName = 'fname6';
        c.LastName = 'lname6';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890';
        c.AccountId = a.Id;
        c.RecordTypeId = rt4.Id;
        insert c;
        
        contact c2 = new Contact();
        c2.FirstName = 'fname7';
        c2.LastName = 'lname7';
        c2.Email = 'testemail@salesforce.com';
        c2.Phone = '1234567890';
        c2.AccountId = a2.Id;
        c2.RecordTypeId = rt4.Id;
        insert c2;
        
        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
        
        DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
        ap2.Name = 'abcd2';
        ap2.DeltakSRP__School__c = a2.id;
        ap2.DeltakSRP__Degree_Type__c = 'Certificate2';
        ap2.DeltakSRP__Abbrev__c = 'CID2';
        ap2.DeltakSRP__Program_Title__c = 'Certificate in CS2';
        insert ap2;
        
       Opportunity o2 = new Opportunity();
        o2.RecordTypeId = rt3.Id;
        o2.Name = 'Test Opportunity';
        o2.StageName = 'Dormant';
        o2.DeltakSRP__Sub_Stage__c = 'Duplicate Record';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c2.Id;
        o2.DeltakSRP__Lead_Source_ID__c = '12345';
        o2.DeltakSRP__Academic_Program__c = ap2.Id;
        o2.AccountId = a2.Id;
        insert o2;
        
        
        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
        rapc.Academic_Program__c = ap2.Id;
        rapc.Program_Code__c = 'MSCS2';
        insert rapc;
        
        Lead l4 = new Lead();
            l4.Status = 'Open';
            l4.Company = 'Deltak';
            l4.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
            l4.FirstName = 'fname6';
            l4.LastName = 'lname6';
            l4.RecordTypeId = rt2.Id;
            l4.DeltakSRP__AcademicProgram__c = 'MSCS2';
            l4.DeltakSRP__Lead_Source_ID__c = '12345';
            l4.email = 'testemail@salesforce.com';
            
            test.startTest();       
            insert l4;
            test.stopTest();
            system.debug('total queries consumed 7>>>>'+Limits.getAggregateQueries());
        
        } 
  
}