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
@isTest(SeeAllData=true)
private class LeadProcessorTest {
    
    static testMethod void testEmailRegex(){
        String email = LeadProcessor.validateEmail('test@rasmussen.edu');
        System.AssertEquals('test@rasmussen.edu', email);
        email = LeadProcessor.validateEmail('testrasmussen.edu');
        System.assertEquals('',email);
    }
    private static LeadProcessor.LP_Person populatePersonFields(String contactName, String rasId){
        LeadProcessor.LP_Person lp_person = new LeadProcessor.LP_Person();
        lp_person.ContactName = contactName;
        lp_person.RasId = rasId;
        return lp_person;
    }
    private static LeadProcessor.LP_Affiliaiton populateAffiliationFields(String address1, String address2, String besttime,
                                                                          String city, String email, String gender,
                                                                          String hsgradyr, String newKey5, String phone1,
                                                                          String phone2, String phone3, String state,
                                                                          String title, String utextperm, String zip){
        LeadProcessor.LP_Affiliaiton lp_affl = new LeadProcessor.LP_Affiliaiton();
        lp_affl.Address1 = address1;
        lp_affl.Address2 = address2;
        lp_affl.BestTime = besttime;
        lp_affl.City = city;
        lp_affl.Email = email;
        lp_affl.Gender = gender;
        lp_affl.HSGradYear = hsgradyr;
        lp_affl.newKey5 = newKey5;
        lp_affl.Phone1 = phone1;
        lp_affl.Phone2 = phone2;
        lp_affl.phone3 = phone3;
        lp_affl.State = state;
        lp_affl.Title = title;
        lp_affl.utextperm = utextperm;
        lp_affl.Zip = zip;
        
        return lp_affl;
    }
    private static LeadProcessor.LP_Opportunity populateOpportunityFields1(String company, String courseinterest, Datetime datecreated,
                                                                          String filename, Integer gmId, String highlevel, Integer imsid,
                                                                          String key1, String key2, String key5, String newKey4,
                                                                          String notes, String other_colleges, String ownerId,
                                                                          String program, String program2){
        LeadProcessor.LP_Opportunity lp_oppty = new LeadProcessor.LP_Opportunity();
        lp_oppty.Company = company;
        lp_oppty.CourseInterest = courseinterest;
        lp_oppty.DateCreated = datecreated;
        lp_oppty.filename = filename;
        lp_oppty.GMId = gmid;
        lp_oppty.HighLevel = highlevel;
        lp_oppty.IMSID = imsid;
        lp_oppty.Key1 = key1;
        lp_oppty.Key2 = key2;
        lp_oppty.Key5 = key5;
        lp_oppty.newKey4 = newKey4;
        lp_oppty.notes = notes;
        lp_oppty.Other_Colleges = other_colleges;
        lp_oppty.OwnerId = ownerid;
        lp_oppty.Program = program;
        lp_oppty.Program2 = program2;
        
        
        
        
        return lp_oppty;
    }
    private static LeadProcessor.LP_Opportunity populateOpportunityFields2(LeadProcessor.LP_Opportunity lp_oppty, String r_campaign, String referal,
                                                                          String refrdOppty, String refrdPers, String source, String tfrdOppty,
                                                                          String uadcampgn, String uadgroup, String ucampgntyp, String ucampus,
                                                                          String udesc,String uhowhrd, String uhscode, String uimname, 
                                                                          String uimtype,String uintlead, String umodality, Date uoptindt, 
                                                                          String uoptoutcam,String urefkeywrd, String urefrdby, String urefurl){
                                                                            
    
        lp_oppty.R_Campaign = r_campaign;
        lp_oppty.Referal = referal;
        lp_oppty.referredByOpportunity = refrdoppty;
        lp_oppty.referredByPerson = refrdPers;
        lp_oppty.Source = source;
        lp_oppty.TransferredFromOpportunity = tfrdOppty;
        lp_oppty.UADCAMPGN = uadcampgn;
        lp_oppty.UADGROUP = uadgroup;
        lp_oppty.UCAMPGNTYP = ucampgntyp;
        lp_oppty.ucampus = ucampus;
        lp_oppty.udescribe = udesc;
        lp_oppty.uhowheard = uhowhrd;
        lp_oppty.uhscode = uhscode;
        lp_oppty.UIMName = uimname;
        lp_oppty.UIMType = uimtype;
        lp_oppty.UINTLEAD = uintlead;
        lp_oppty.UModality = umodality;
        lp_oppty.uoptindt = uoptindt;
        lp_oppty.UOptOutCam = uoptoutcam;
        lp_oppty.UrefKeyWrd = urefkeywrd;
        lp_oppty.urefrdby = urefrdby;
        lp_oppty.urefurl = urefurl;
    return lp_oppty;
    }
    private static LeadProcessor.LP_Failure populateFailureFields(String failure, String description){
        LeadProcessor.LP_Failure fail = new LeadProcessor.LP_Failure();
        fail.failure = failure;
        fail.failureDescription = description;
        return fail;
    }
  static testMethod void myUnitTest() {
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', '1234323214', '', 'joe@johns.com', '', '', '', '', '','SHU11', '2010-05-03 10:50:31 pm', '', 'Duke Thompson', '?', '?', '?', '?', '?','?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', '?',addedFields);
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
        System.AssertEquals('Success', returnString[0]);
        
        
        List<Contact> test1Contact = [select id, FirstName, LastName from Contact where FirstName = 'Codoneasdf'
            and LastName = 'Codoneasdf'];
         System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        //Id contactId = test1Contact[0].Id;
        
        Test.stopTest();
        }
    } 
 
    static testMethod void LF_myUnitTest() {
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
       
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '00000000-0000-0000-0000-000000000000');
        
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', '?', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', '', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', 
                                                '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                
        LeadProcessor.LP_Failure lp_fail = null;
        
        List<String> returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
        System.AssertEquals('Success', returnString[0]);
        
        
        List<Contact> test1Contact = [select id, FirstName, LastName from Contact where FirstName = 'Codoneasdf'
            and LastName = 'Codoneasdf'];
         System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        //Id contactId = test1Contact[0].Id;
        
        
         lp_fail = populateFailureFields('RASID', 'error description');
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
        
        
        
        Test.stopTest();
        }
    }
  
    
    static testMethod void testPersonInsertFail(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '', '', '', '', '', 'SHU11', '2010-05-03 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', '?','?', addedFields);
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
            System.AssertEquals(0, test1Person.size());
        System.AssertEquals('Failure', returnString[0]);
       
        Test.stopTest();
        }
    }
    static testMethod void testContactInsertFail(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns', '', '', '', '', '', 'SHU11', '2010-05-03 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', '?','?', addedFields);
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
            
        System.AssertEquals('Failure', returnString[0]);
       
        Test.stopTest();
        }
    }
    static testMethod void testMyUnitTest2(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
            
            Account a = new Account();
            a.Goldmine_key5__c = 'SHU11';
            a.Name = 'Test';
            a.Type = 'Deltak Partner';
            insert a;
        
            String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
            Test.startTest();
            LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
            //Test2 - Valid Ras Id - Should create Person, Affiliation, and Opportunity
           List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf1122 Codoneasdf1122', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', '1234532635','1253647234', 'joe@johns.com', '', '', '', '', '', 'SHU11', '2010-05-03 10:50:31 pm', '', 'Duke Thompson', '?','?', '?', '?', '?', '?', '11110000-0000-0000-0000-000000000000', '?', '?', '?', '?', addedFields);
         List<Person__c> test2Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Codoneasdf1122'
                and Last_Name__c = 'Codoneasdf1122'];
            System.assertEquals(test2Person[0].RasId__c,'11110000-0000-0000-0000-000000000000');
            
            List<Contact> test2Contact = [select id, FirstName, LastName from Contact where FirstName = 'Codoneasdf1122'
                and LastName = 'Codoneasdf1122'];
           System.assertEquals(test2Contact[0].FirstName,'Codoneasdf1122' ); 
       //     Id contact2Id = test2Contact[0].Id;
            
           /** List<Opportunity> test2Opportunity = [Select Id, Student__c from Opportunity where Student__c = :contact2Id];
            System.assertEquals(test2Opportunity[0].Student__c, contact2Id); **/
            
            Test.stopTest();
        }
    }
    static testMethod void testMyUnitTest3(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
            Account a = new Account();
            a.Goldmine_key5__c = 'SHU11';
            a.Name = 'Test';
            a.Type = 'Deltak Partner';
            insert a;
        
            String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
                
            //Test3 - Duplicate Lead - Should create case
           // LeadProcessor.run(111, 'Fred Fields', '123 Main Street', 'Apt 123', 'Chicago', 'IL', '60666', '1111111111', '2222222222', 'joe@johns.com', 'Male', '?', 'MBA', '?', '1990', 'SHU11', '2010-04-21', '?', GoldmineUser, '?', '?', '?', '?', '?', '?', '12345678-0000-0000-0000-000000000000', '?', '?', '?', '?', addedFields);
            Opportunity newopp = new Opportunity();
            newOpp.name = 'From Lead' + '111';
            newOpp.AccountId = a.id;
            newOpp.StageName = 'New Inquiry';
            newOpp.CloseDate = date.newInstance(2100, 1, 1);
            insert newOpp;
            Test.startTest();   
            LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();       
            LeadProcessor.run(111, 'Fred Fields', '123 Main Street', '(no string passed)', 'Chicago', 'IL', '60666', '1111111111', '2222222222', 'joe@johns.com', 'f', '?', 'MBA', '?', '1990', 'SHU11', '2010-04-21', '?', GoldmineUser, '?', '?', '?', '?', '?', '?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', '?','?', addedFields);
            Test.stopTest();
        }
    }
    
    
    /** @AbhaS. 07/12/2012 - WebScheduler related
        This tests the scenario where there is a duplicate opportunity being inserted but the source field on this opportunity contains 'RFI' string
        the first opportunity's source does not contain 'RFI' 
        **/ 
    static testMethod void LF_myUnitTest4_DupOppCheck_WebSch() {
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];       
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',emailencodingkey='UTF-8', lastname='Testing',languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='newuser11@testorg.com');
        insert u2;// inserting the defined user
        
        Id user_id = u2.Id;
        System.debug('################################################ u2 user id = '+user_id);
        
        System.runAs(u2) {        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        Test.startTest();
        
        /**first opportunity insertion **/
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');
        
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'TestRFITest', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                                                    
        LeadProcessor.LP_Failure lp_fail = null;
        
        List<String> returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                                        from Person__c 
                                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        System.debug('VS -- test1Person'+test1Person);
        
        System.AssertEquals('Success', returnString[0]);
         System.debug('###################### oppty_web id first opp:    '+returnString[1]);
        List<Contact> test1Contact = [select id, FirstName, LastName 
                                        from Contact 
                                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
         System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        //Id contactId = test1Contact[0].Id;
                
         lp_fail = populateFailureFields('RASID', 'error description');
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
      
        
        //second opportunity insertion - duplicate
        
        addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');
        
        lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');       
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'TestSource', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');                                                                            
        lp_fail = null;
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        
        System.Debug('VS -- Return List'+returnString);
        test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                        from Person__c 
                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        
        System.debug('VS -- test1Person'+test1Person);      
        System.AssertEquals('Success', returnString[0]);
        System.debug('###################### oppty_web id:    '+returnString[1]);
        
        Id opp_id = (Id)returnString[1];
        
        Opportunity returnedOpp = [select Id, webschedulerstatus__c
                        from Opportunity
                        where Id =: opp_id ];
        System.debug('###################### oppty_web web scheduler status :    '+returnedOpp.webschedulerstatus__c);
        System.assertEquals('New', returnedOpp.webschedulerstatus__c);
        
        test1Contact = [select id, FirstName, LastName 
                        from Contact 
                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
        System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        
        lp_fail = populateFailureFields('RASID', 'error description');       
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);       
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
        
        /**third opportunity being inserted **/
        addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');
        
        lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'RFITest', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                                              
        lp_fail = null;
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                        from Person__c 
                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        System.debug('VS -- test1Person'+test1Person);
        
        System.AssertEquals('Success', returnString[0]);
        System.debug('###################### oppty_web id:    '+returnString[1]);
        
        opp_id = (Id)returnString[1];
        
        returnedOpp = [select Id, webschedulerstatus__c
                        from Opportunity
                        where Id =: opp_id ];
        System.debug('###################### oppty_web web scheduler status III :    '+returnedOpp.webschedulerstatus__c);
        System.assertEquals('New', returnedOpp.webschedulerstatus__c);
        
        test1Contact = [select id, FirstName, LastName 
                        from Contact 
                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
        System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        //Id contactId = test1Contact[0].Id;
        
        
        lp_fail = populateFailureFields('RASID', 'error description');       
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
        
        Test.stopTest();
        }
    }
    
    
    /** @AbhaS. 07/12/2012 - WebScheduler related
        This tests the scenario where there is a duplicate opportunity being inserted but the source field on this opportunity contains 'RFI' string
        the first opportunity's source also contains 'RFI' 
        **/
        
      
       static testMethod void LF_myUnitTest5_DupOppCheck_WebSch() {
        
        /*
            Fadi for SRP Deployment
        */
      /*  String currentProfileId = userinfo.getProfileId();
        currentProfileId = currentProfileId.substring(0, 15);
        List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
        Set<String> srpProfiles = new Set<String>();
        SRPProfilesList = SRP_Profiles_List__c.getall().values();
        for(SRP_Profiles_List__c spl: SRPProfilesList){
            srpProfiles.add(spl.ProfileId__c);
        }
        if(srpProfiles.contains(currentProfileId))
            return;*/
        
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];        
        Profile p = [SELECT Id FROM profile WHERE name='Integration Profile'];       
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',emailencodingkey='UTF-8', lastname='Testing',languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='newuser11@testorg.com');
        insert u2;// inserting the defined user
        
        Id user_id = u2.Id;
        System.debug('################################################ u2 user id = '+user_id);
        
        System.runAs(u2) {        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        Test.startTest();
         /**first opportunity insertion **/
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();      
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');      
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead','SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');      
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'TestSource', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                                                    
        LeadProcessor.LP_Failure lp_fail = null;        
        List<String> returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                                        from Person__c 
                                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        System.debug('VS -- test1Person line 629 '+test1Person);      
        System.AssertEquals('Success', returnString[0]);
        System.debug('###################### oppty_web id:    '+returnString[1]);
       
        List<Contact> test1Contact = [select id, FirstName, LastName 
                                        from Contact 
                                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
        System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
                
        lp_fail = populateFailureFields('RASID', 'error description');
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        System.AssertEquals('Success', returnString[0]);
         System.debug('###################### oppty_web id first opp:    '+returnString[1]);
         
        System.AssertEquals(true, returnString[1].contains('a0J'));
      
        
        /**second opportunity insertion - duplicate**/
        
        addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');
        
        lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe11@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'RFITest', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                                              
        lp_fail = null;
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                        from Person__c 
                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        System.debug('VS -- test1Person lin 667 - '+test1Person);
        
        System.AssertEquals('Success', returnString[0]);
        System.debug('###################### oppty_web id:    '+returnString[1]);
        
        Id opp_id = (Id)returnString[1];
        
        Opportunity returnedOpp = [select Id, webschedulerstatus__c
                        from Opportunity
                        where Id =: opp_id ];
        System.debug('###################### oppty_web web scheduler status II line 677 - :    '+returnedOpp.webschedulerstatus__c);
        System.assertEquals('New', returnedOpp.webschedulerstatus__c);
        
     /*AAC   test1Contact = [select id, FirstName, LastName,  Alternate_Phone__c, Alternate_Email__c, Work_Phone__c, Email
                        from Contact 
                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
        System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        System.assertEquals(test1Contact[0].Alternate_Email__c, 'joe11@johns.com');*/
        //Id contactId = test1Contact[0].Id;
        
        
        lp_fail = populateFailureFields('RASID', 'error description');       
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List line 691 - '+returnString);
        
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
                
        /** Third Opportunity being inserted **/
        addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '11110000-0000-0000-0000-000000000000');
        
        lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', user_id+'', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', 'Test', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', '?', '?', '', '', Date.today(), '?', '?', '?', '?');
                                                                              
        lp_fail = null;
        
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List line 710 - '+returnString);
        test1Person = [select id, First_Name__c, Last_Name__c, RasID__c 
                        from Person__c 
                        where First_Name__c = 'Job' and Last_Name__c = 'Johns'];
        System.debug('VS -- test1Person line 714 - '+test1Person);
        
       System.AssertEquals('Success', returnString[0]);
        System.debug('###################### oppty_web id line 717 - :    '+returnString[1]);
        
       opp_id = (Id)returnString[1];
        
       returnedOpp = [select Id, webschedulerstatus__c
                       from Opportunity
                       where Id =: opp_id ];
        System.debug('###################### oppty_web web scheduler status III :    '+returnedOpp.webschedulerstatus__c);
        System.assertEquals(null, returnedOpp.webschedulerstatus__c);
        
        test1Contact = [select id, FirstName, LastName 
                        from Contact 
                        where FirstName = 'Codoneasdf' and LastName = 'Codoneasdf'];
        System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        Id contactId = test1Contact[0].Id;
        
        
        lp_fail = populateFailureFields('RASID', 'error description');       
        returnString = LeadProcessor.lp_with_handle_failure(lp_pers, lp_affl, lp_oppty, lp_fail);
        
        System.Debug('VS -- Return List'+returnString);
        
        System.AssertEquals('Success', returnString[0]);
        System.AssertEquals(true, returnString[1].contains('a0J'));
        
        Test.stopTest();
        }
    }
   
    
    static testMethod void testKey2(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '','', '', '', '', '', 'SHU11', '2010-07-01 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', 'transferred', addedFields);
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
        System.AssertEquals('Success', returnString[0]); 
        if(returnString[0] == 'Success'){
         /** System.assertEquals(test1Person[0].RasId__c,null);
          System.assertEquals('http://www.sacredheartonline.com/request-information.asp', returnString[2]);
          System.assertEquals('phone 3', returnString[3]);**/ 
          System.assertEquals('3-6 months', returnString[3]);
        }
        
        List<Contact> test1Contact = [select id, FirstName, LastName from Contact where FirstName = 'Codoneasdf'
            and LastName = 'Codoneasdf'];
       //  System.assertEquals(test1Contact[0].FirstName,'Codoneasdf' );
        //Id contactId = test1Contact[0].Id;
        
        
        
        Test.stopTest();
        }
    }
    static testMethod void testConvertDate(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        Test.startTest();
        String outputDate = LeadProcessor.convertDateTime('2/17/2011 4:21:53 pm');
        
        System.AssertEquals('2011-2-17 16:21:53', outputDate);
         outputDate = LeadProcessor.convertDateTime('2/18/2011');
        System.AssertEquals('2011-2-18 00:00:00', outputDate);
        
        outputDate = LeadProcessor.convertDateTime('2/17/2011 12:21:53 pm');
        
        System.AssertEquals('2011-2-17 12:21:53', outputDate);
        
        Test.stopTest();
        }
    }
    
    static testMethod void testOpportunityInsertFailure(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        
        Campaign camp = new Campaign();
        camp.Bucket_Campaign__c = true;
        camp.name = 'Bucket Campaign';
        insert camp;
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        //Test 1 - Zero Ras Id - Should create Affiliation and Opportunity and Person with null RasId
        //List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '', '', '', '', '', 'SHU11', '2010-05-03 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '00000000-0000-0000-0000-000000000000', '?', '?', '?', 'transferredfromopportunity', addedFields);
        List<String> returnString = LeadProcessor.run(588821, 'Codoneasdf Codoneasdf', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '', '','', '', '', '', 'SHU11', '2010-0503 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '1234567890', '?', '?', '?', 'transferredfromopportunity', addedFields);
        
        System.Debug('VS -- Return List'+returnString);
        List<Person__c> test1Person = [select id, First_Name__c, Last_Name__c, RasID__c from Person__c where First_Name__c = 'Job'
            and Last_Name__c = 'Johns'];
            System.debug('VS -- test1Person'+test1Person);
        System.AssertEquals('Failure', returnString[0]);
      
        
        
        Test.stopTest();
        }
    }
    
    static testMethod void duplicateContactScenario(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        Person__c pe = new Person__c();
        pe.First_Name__c = 'TesTFirstNameUnit';
        pe.Last_Name__c = 'TestLastNameUnit';
        pe.RasId__c = '123-456-7890';
        insert pe;
        
        List<RecordType> recordTypes = [select id, Name from RecordType where Name = 'Deltak Student' ];
        
        Contact c = new Contact();
        c.Person__c = pe.id;
        c.AccountId = a.id;
        c.RecordTypeId = recordTypes[0].id;
        c.LastName = 'TesTFirstNameUnit';
        c.FirstName = 'TestLastNameUnit';
        insert c;
        Test.startTest();
        insertCampaign();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        List<String> returnString = LeadProcessor.run(588821, 'TesTFirstNameUnit TestLastNameUnit', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '','', '', '', '', '', 'SHU11', '2010-05-03 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '123-456-7890', '?', '?', '?', 'transferred', addedFields);
        
        List<Case> caseList = [Select id, Contactid, AccountId, CreatedDate, Subject from Case where Type = 'Goldmine Lead'];
        System.Debug('VS __ DEBUG '+caseList);
        String caseSubjectAffl = 'Potential Duplicate Affiliation - ' +  'SHU' 
                        + ' ' + 'TestFirstName TestLastName' + ' ' + 'joe@johns.com';
        String caseSubjectOpp = 'Potential Duplicate Opportunity - ' +  'SHU' 
                        + ' ' + 'TestFirstName TestLastName' + ' ' + 'joe@johns.com';
        // This scenario will have duplciate contact and duplicate opportunity created. So, we wil have two cases created in this scenario.
              
        //System.AssertEquals(0, caseList.size()); 
        System.Debug('VS -- Return List'+returnString);
        
        Test.stopTest();
        
        }
    }
    static testMethod void testGetRatingOwnerId(){
        String ratingOwnerId = 'Low00500000000001234';
        List<String> returnString = LeadProcessor.getOwnerIdRating(ratingOwnerId);
        System.AssertEquals('Low',  returnString[0]);
        System.AssertEquals('00500000000001234', returnString[1]);
    } 
    
    static testMethod void duplicateOpportunityScenario(){
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        Person__c pe = new Person__c();
        pe.First_Name__c = 'TesTFirstName';
        pe.Last_Name__c = 'TestLastName';
        pe.RasId__c = '123-456-7890';
        insert pe;
        
        List<String> recordTypeName = new List<String>();
        recordTypeName.add('Deltak Student');
        recordTypeName.add('Student Opportunity');
        
        List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordTypeName];
        Map<String, Id> recordTypeNameToId = new Map<String, Id>();
        
        for(RecordType thisRecord : recordTypes){
            recordTypeNameToId.put(thisRecord.Name, thisRecord.Id);
        }
        Contact c = new Contact();
        c.Person__c = pe.id;
        c.AccountId = a.id;
        c.RecordTypeId = recordTypeNameToId.get('Deltak Student');
        c.LastName = 'TestLastName';
        c.FirstName = 'TestFirstName';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Student__c = c.id;
        opp.AccountId = a.Id;
        opp.RecordTypeId = recordTypeNameToId.get('Student Opportunity');
        opp.StageName = 'New Inquiry';
        opp.Name = 'New Opportunity';
        opp.CloseDate = System.today();
        insert opp;
        Test.startTest();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = setAdditionalFields();
        List<String> returnString = LeadProcessor.run(588821, 'TestFirstName TestLastName', '123 Main Street', 'Apt 123', 'Flgzsyqdohrnw', 'IL', 'RNnWJNpn', '', 'NuZWdCWH', 'joe@johns.com', '','', '', '', '', '', 'SHU11', '2010-05-03 15:50:31', '', 'Duke Thompson', '?', '?', '?', '?', '?', '?', '123-456-7890', '?', '?', '?', 'transferred', addedFields);
        List<Lead_Failure__c> lead_fail_List = [Select Id from lead_Failure__c where RasId__c = '123-456-7890' and Duplicate_Opportunity__c = :true ];
        System.AssertEquals(1, lead_fail_List.size());
        
        List<Case> caseList = [Select id, Contactid, AccountId, CreatedDate, Subject from Case where Type = 'Goldmine Lead'];
        System.Debug('VS __ DEBUG '+caseList);
        String caseSubjectAffl = 'Potential Duplicate Affiliation - ' +  'SHU' 
                        + ' ' + 'TestFirstName TestLastName' + ' ' + 'joe@johns.com';
        String caseSubjectOpp = 'Potential Duplicate Opportunity - ' +  'SHU' 
                        + ' ' + 'TestFirstName TestLastName' + ' ' + 'joe@johns.com';
        // This scenario will have duplciate contact and duplicate opportunity created. So, we wil have two cases created in this scenario.
              
        System.AssertEquals(0, caseList.size());
        /*System.AssertNotEquals('Lead Processor Error in Salesforce', caseList[0].Subject);
        System.AssertNotEquals('Lead Processor Error in Salesforce', caseList[1].Subject);
        System.AssertEquals(c.Id, caseList[0].ContactId);
        System.AssertEquals(a.Id, caseList[0].AccountId);
        System.AssertEquals(c.Id, caseList[1].ContactId);
        System.AssertEquals(a.Id, caseList[1].AccountId);*/
        
        System.Debug('VS -- Return List'+returnString);
        
        Test.stopTest();
        
        }
    }
    
    static testmethod void lp_runTestWithSRPBoundInquiry()
    {
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
       
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'SHU11';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '00000000-0000-0000-0000-000000000000');
        
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'SHU11', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'SHU11', 'Duke Thompson', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', 'LeadID:ALWRJ6LQS3WTRN22YNNQ', '?', '', '');
        
        lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', '', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', 
                                                '?', '?', '', '', Date.today(), '?', '?', '?', '?');
        lp_oppty.referredByOpportunity = null;
        lp_oppty.OwnerId = '00560000002AiID';
        LeadProcessor.lp_run(lp_pers, lp_affl, lp_oppty);
    
        }
    }
    static testmethod void testEventCreation()
    {
        System.debug('>--->testEventCreation started');
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Johns Hopkins AAP Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Integration Profile'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
       
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'JHUAAP';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '00000000-0000-0000-0000-000000000000');
        System.debug('>--->testEventCreation created lp_pers');
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'JHUAAP', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        System.debug('>--->testEventCreation created lp_affl');
        DateTime eventDT = DateTime.now().addDays(5);
        String eventDTString = 'Event Date: ' + eventDT.year() + '-' + eventDT.month() + '-' + eventDT.day() + '-' + eventDT.hour() + '-' + eventDT.minute() + '-' + eventDT.second();
        System.debug('>--->testEventCreation event date String - ' + eventDTString);
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', '', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'JHUAAP', 'Duke Thompson', eventDTString, '', '?', '', '');
        System.debug('>--->testEventCreation created lp_oppty');
        //lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', '', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', 
        //                                        '?', '?', '', '', Date.today(), '?', '?', '?', '?');
        lp_oppty.referredByOpportunity = null;
        lp_oppty.OwnerId = '00560000002AiID';
        System.debug('>--->testEventCreation started lp_run');
        LeadProcessor.lp_run(lp_pers, lp_affl, lp_oppty);
        System.debug('>--->testEventCreation ended lp_run');
        
        }
    
    }
    
    static testmethod void testPurdueOnGround()
    {
        System.debug('>--->testPurdueOnGround started');
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Johns Hopkins AAP Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Integration Profile'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
       
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'Purdue';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'test purdue program';
        ap.School__c = a.Id;
        ap.Active__c = true;
        ap.Program_Title__c = 'test purdue program';
        ap.DegreeType__c = 'Course';
        ap.Abbrev__c = 'tpp';
        //ap.Restricted_States__c = 'IL;';
        ap.On_Ground_Only__c = true;
        ap.Campus_Program_Id__c = 'testpurdueprogram';
        insert ap;
        
        Goldmine_to_Salesforce_Program__c gtsp = new Goldmine_to_Salesforce_Program__c();
        gtsp.Account__c = a.Id;
        gtsp.Program_Id__c = ap.Id;
        gtsp.Goldmine_Program__c = 'goldmineprogramtest';
        insert gtsp;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '00000000-0000-0000-0000-000000000000');
        System.debug('>--->testPurdueOnGround created lp_pers');
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'JHUAAP', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        System.debug('>--->testPurdueOnGround created lp_affl');
        
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', 'goldmineprogramtest', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'Purdue', 'Duke Thompson', '', '', '?', '', '');
        System.debug('>--->testPurdueOnGround created lp_oppty');
        //lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', '', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', 
        //                                        '?', '?', '', '', Date.today(), '?', '?', '?', '?');
        lp_oppty.referredByOpportunity = null;
        lp_oppty.OwnerId = '00560000002AiID';
        System.debug('>--->testPurdueOnGround started lp_run');
        LeadProcessor.lp_run(lp_pers, lp_affl, lp_oppty);
        System.debug('>--->testPurdueOnGround ended lp_run');
        
        }
    
    }
    
    static testmethod void testQueensRestrictedStates()
    {
        System.debug('>--->testQueensRestrictedStates started');
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Johns Hopkins AAP Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Integration Profile'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
       
        System.runAs(u2) {
        
        Account a = new Account();
        a.Goldmine_key5__c = 'Queens';
        a.Name = 'Queens University';
        a.Type = 'Deltak Partner';
        insert a;
        
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'test queens program';
        ap.School__c = a.Id;
        ap.Active__c = true;
        ap.Program_Title__c = 'test queens program';
        ap.DegreeType__c = 'Course';
        ap.Abbrev__c = 'tqp';
        ap.Restricted_States__c = 'IL';
        ap.On_Ground_Only__c = false;
        
        insert ap;
        
        Goldmine_to_Salesforce_Program__c gtsp = new Goldmine_to_Salesforce_Program__c();
        gtsp.Account__c = a.Id;
        gtsp.Program_Id__c = ap.Id;
        gtsp.Goldmine_Program__c = 'goldmineprogramtest';
        insert gtsp;
        
        String GoldmineUser = 'Duke Thompson';
        if(urole != null && urole.Users != null && urole.Users.size() > 0)
            GoldmineUser = urole.Users[0].GM_Name__c;
        
        LeadProcessor.LP_Person lp_pers = populatePersonFields('Codoneasdf Codoneasdf', '00000000-0000-0000-0000-000000000000');
        System.debug('>--->testQueensRestrictedStates created lp_pers');
        LeadProcessor.LP_Affiliaiton lp_affl = populateAffiliationFields('123 Main Street', 'Apt 123', '', 'Flgzsyqdohrnw', 'joe@johns.com', '', '', 'JHUAAP', '', 'NuZWdCWH', 'phone 3', 'IL', '?', 'yes', 'RNnWJNpn');
        System.debug('>--->testQueensRestrictedStates created lp_affl');
        
        LeadProcessor.LP_Opportunity lp_oppty = populateOpportunityFields1('?', 'goldmineprogramtest', Datetime.now(), 'http://www.sacredheartonline.com/request-information.asp', 588821, '', 12310, 'Individual', '08 New Lead', 
                                                                            'Queens', 'Duke Thompson', '', '', '?', '', '');
        System.debug('>--->testQueensRestrictedStates created lp_oppty');
        //lp_oppty = populateOpportunityFields2(lp_oppty, 'TestCode', '', '?', '?', '', '?', '', '', '', '', 'ALWRJ6LQS3WTRN22YNNQ', '', '', 
        //                                        '?', '?', '', '', Date.today(), '?', '?', '?', '?');
        lp_oppty.referredByOpportunity = null;
        lp_oppty.OwnerId = '00560000002AiID';
        System.debug('>--->testQueensRestrictedStates started lp_run');
        LeadProcessor.lp_run(lp_pers, lp_affl, lp_oppty);
        System.debug('>--->testQueensRestrictedStates ended lp_run');
        
        }
    
    }
    
    /*
    Girija: added testWorkExpAndGpa and testAssignGpa
    */  
    static testmethod void testWorkExpAndGpa()
    {
        String key5 = 'JHUAAP';
        String notes = 'workexp=5#gpa=4.0 and above';
        
        Account a = new Account();
        a.Goldmine_key5__c = 'JHUAAP';
        a.Name = 'Test';
        a.Type = 'Deltak Partner';
        insert a;
        
        Opportunity newopp = new Opportunity();
        newOpp.name = 'testOpp';
        newOpp.AccountId = a.id;
        newOpp.StageName = 'New Inquiry';
        newOpp.CloseDate = date.newInstance(2100, 1, 1);
        insert newOpp;
        
        LeadProcessor.getWorkExpAndGpa(key5,notes,newopp);        
        system.assertEquals(newopp.Yrs_Wrk_Exp__c,5.00);
        
        notes= 'workexp=10';
        LeadProcessor.getWorkExpAndGpa(key5,notes,newopp);        
        system.assertEquals(newopp.Yrs_Wrk_Exp__c,10.00);
        
        notes= 'gpa=4.0 and above';
        LeadProcessor.getWorkExpAndGpa(key5,notes,newopp);        
        system.assertEquals(newopp.GPA__c,4.0);        
        
    }
    
    static testmethod void testAssignGpa()
    {
        String gpaVal = '3.99 – 3.50';
        Double gpa = LeadProcessor.assignGpaValue(gpaVal);
        system.assertEquals(gpa,3.75);
        
        gpaVal = '3.49 – 3.0';
        gpa = LeadProcessor.assignGpaValue(gpaVal);
        system.assertEquals(gpa,3.25);
        
        gpaVal = '2.99 – 2.50';                     
        gpa = LeadProcessor.assignGpaValue(gpaVal);
        system.assertEquals(gpa,2.75);
        
        gpaVal = '2.49 or below';
        gpa = LeadProcessor.assignGpaValue(gpaVal);
        system.assertEquals(gpa,2.49);  
        
    }   
    
    private static LeadProcessor.LeadRouter_AdditionalFields setAdditionalFields(){
        //insertCampaign();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = new LeadProcessor.LeadRouter_AdditionalFields();
        addedFields.Company = '';
        addedFields.filename = 'http://www.sacredheartonline.com/request-information.asp';
        addedFields.Key1 = 'Individual';
        addedFields.Key2 = '08 New Lead';
        addedFields.notes = 'LeadID:ALWRJ6LQS3WTRN22YNNQ | Country_Of_citizenship: India | Type_Of_Law_Degree:';
        addedFields.Other_Colleges = 'Other Colleges';
        addedFields.phone3 = 'phone 3';
        addedFields.Program = '';
        addedFields.Program2 = '';
        addedFields.R_Campaign = 'TestCode';
        addedFields.Referal = '';
        addedFields.Source = '';      
        addedFields.UADCAMPGN = '';
        addedFields.UADGROUP = '';
        addedFields.UCAMPGNTYP = '';
        addedFields.ucampus = '';
        addedFields.udescribe = 'ALWRJ6LQS3WTRN22YNNQ';
        addedFields.Key5 = 'SHU11';
        addedFields.uoptindt = '02/17/2011 3:38:32.197 pm';
        addedFields.utextperm = 'yes';
        return addedFields;
    }
    
    private static Id insertCampaign(){
        Campaign camp = new Campaign();
        camp.Name = 'New Campaign';
        camp.Campaign_Code__c = 'TestCode';
        camp.Lowest_Level_in_Hierarchy__c = true;
        camp.StartDate = System.today() - 1;
        camp.EndDate = System.today() + 3;
        camp.Bucket_Campaign__c = true;
        camp.isActive = true;
        insert camp;
        
        return camp.id;
    }
    
}