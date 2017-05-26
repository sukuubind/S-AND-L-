@isTest(seealldata=true)
private class SRPOpportunityOwnerUpdateTriggerTest {

    static testMethod void myUnitTest() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
        
        DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
        Id leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
        
        System.Test.startTest();
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
        if(leadengineuserid != null)
            o2.OwnerId = leadengineuserid;
        else
            o2.OwnerId = '00560000001Z67x'; 
        insert o2;
        
        o2.OwnerId = userinfo.getUserId();
        update o2;
        
        Contact c2 = [Select ownerid from Contact where Id=: c.id];
        system.assertEquals(c2.ownerid, userinfo.getuserid());
    }
    static testMethod void testOppUpdateScenario(){
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
    RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];    
    
    Account a = new Account();
    a.recordTypeid = rt1.Id;
    a.Abbreviation__c = 'TST';
    a.name = 'test account';
    insert a;    
        
    DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
    ap.Name = 'abcd';
    ap.DeltakSRP__School__c = a.id;
    ap.DeltakSRP__Degree_Type__c = 'Certificate';
    ap.DeltakSRP__Abbrev__c = 'CID';
    ap.DeltakSRP__SIS_External_Id__c ='abcd';
    ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
    insert ap;    
    
    DeltakSRP__Academic_Start_Date__c aTerm = new DeltakSRP__Academic_Start_Date__c();
    aTerm.DeltakSRP__Academic_Program__c = ap.Id; 
    aTerm.DeltakSRP__Start_Date__c = DateTime.now().date();
    aTerm.DeltakSRP__End_Date__c = DateTime.now().date();
    insert aTerm;
    
    User testUser = new User();
    testUser.Username= 'testUser123457784564646@wileytest.com';
    testUser.Email = 'testuser1@company.com';
    testUser.Lastname = 'user';
    testUser.Firstname = 'test';
    testUser.Alias = 'test';
    testUser.CommunityNickname = '12346';
    //testUser.UserRole = [ select id from userrole where id ='00Ei0000000XInH' ];
    SObject prof = [ select id from profile where Name = 'Standard User' ];
    testUser.ProfileId = (Id) prof.get('Id');
    
    //testUser.CurrencyIsoCode = 'USD';
    testUser.TimeZoneSidKey = 'GMT';
    testUser.LocaleSidKey = 'en_US';
    testUser.EmailEncodingKey = 'ISO-8859-1';
    testUser.LanguageLocaleKey = 'en_US';
    testUser.UserPermissionsMobileUser = false;
    
    System.debug ( JSON.serializePretty( testUser ) );
    
    insert testUser;
    
    Contact c1 = new Contact();        
    c1.FirstName='Joe';
    c1.LastName='Smith';
    c1.DeltakSRP__Student_ID__c = '12341234';
    c1.AccountId = a.id;
    c1.DoNotCall = true;
    c1.DeltakSRPSMS__Ok_To_Text__c = true;
    c1.HasOptedOutOfEmail = true;
    c1.Recorded_Call__c = 'Yes';
    c1.DeltakSRP__Student_Services_Coordinator__c = testUser.Id;
    c1.MailingStreet = '123';
    c1.MailingCity = 'city';
    c1.MailingState = 'st';
    c1.MailingPostalcode = '1234';
    c1.DeltakSRP__Employer_Company__c = 'Company';
    c1.DeltakSRP__Employment_Status__c = 'Full-Time';
    insert c1;
    
    
    Opportunity o = new Opportunity();
    o.RecordTypeId = rt2.Id;
    o.Name = 'WileyTest';
    o.StageName = 'New Inquiry';
    o.AccountId = a.Id;
    o.DeltakSRP__Student__c = c1.Id;
    o.DeltakSRP__Academic_Program__c = ap.Id;
    o.DeltakSRP__Start_Date__c = DateTime.now().date();
    o.DeltakSRP__Academic_Start_Date__c = aTerm.Id;
    o.CloseDate = DateTime.now().date();
    o.DeltakSRP__Date_Submitted__c = DateTime.now().date();
    o.DeltakSRP__Date_Accepted__c = DateTime.now().date();
    o.DeltakSRP__Acceptance_Status__c = 'Fully Admitted';
    o.DeltakSRP__Drop_Denied_Reason__c = 'A1 - Admissions: Poor Experience w/ School';
    insert o;
    
    List<DeltakSRP__Program_Enrollment__c> peList = [SELECT Id FROM DeltakSRP__Program_Enrollment__c WHERE DeltakSRP__Enrolled_Student__c = :c1.Id AND DeltakSRP__Academic_Program__c = :ap.Id];
    System.AssertEquals(0,peList.size());
    
    o.StageName = 'Accepted/Admitted';
    o.Program_Enrollment_Update__c = 'New';
    update o;
    }
}