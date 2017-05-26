/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class SRPOpportunityAfterUpdateTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    
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
	//update o;
	
    
    peList = [SELECT Id FROM DeltakSRP__Program_Enrollment__c WHERE DeltakSRP__Enrolled_Student__c = :c1.Id AND DeltakSRP__Academic_Program__c = :ap.Id];
    //System.Assert(peList.size() > 0);
    
    o.StageName = 'Registered';
    update o;
    
    o.StageName = 'Start';
    update o;
    
    a.Abbreviation__c = 'TST2';
    //update a;
    
    o.StageName = 'Roll';
    o.Program_Enrollment_Update__c = 'Roll';
    o.DeltakSRP__Sub_Stage__c = 'Start Next Term'; 
    //update o;
    
    o.StageName = 'Accepted/Admitted';
    o.Program_Enrollment_Update__c = 'New';
    //update o;
    }
}