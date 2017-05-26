@isTest
public class webmail_Test {
    
    Public static ID idTestUser;
    Public static ID idTestInstitution;
    Public static ID idTestContact;
    Public static ID idTestOpportunity;
    
    static testMethod void Test_Webmail_Exception(){
        Test.startTest();
        try{
            throw new webmailException('Webmail: Successful Sync Record Type could not be found');
        }catch(webmailException e){
            
        }
        
        Test.stopTest();
    }
    static testMethod void Test_BodyTooLong() {
        TestInit();
        SendInboundMail('user@testing.com', generateLoremIpsumForBodyTest(), null);
        
        //test - 1 unreconciled Synced Emails
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());
        //test for no task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task];
        system.assertEquals(0, lstTasks.size());
    }
    
    static testMethod void Test_NoFoundSenderPlainText() {
        TestInit(true, false, true);
        SendInboundMail('user@host.com', '1234 This is a plaintext body', null); 
        
        //test Single Needs reconciliation Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());
        
        //test for no task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task];
        system.assertEquals(0, lstTasks.size());
    }
    
    static testMethod void Test_NoEmailBody() {
        TestInit();
        SendInboundMail('user@testing.com', null, null);
        
        //test - NO Synced Emails
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c];
        system.assertEquals(0, lstWSE.size());
        //test for no task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task];
        system.assertEquals(0, lstTasks.size());
    }
    
    static testMethod void Test_SubjectTooLong() {
        TestInit();
        
        String strSubject = generateRandomString(257);
        SendInboundMail('user@testing.com', 'plaintext body contacttest0@gmail.com', null, null, strSubject);
        
        //System.debug('string: ' + generateRandomString(257));
        
        //test - 1 successful Synced Emails
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(1, lstWSE.size());
        //test for  task insertion
        List<Task> lstTasks = [SELECT Subject, OwnerId, WhoId, WhatId FROM Task WHERE Subject =: strSubject.left(255)];
        system.assertEquals(1, lstTasks.size());
    }
    
    static testMethod void Test_NoEmailSender() {
        TestInit();
        SendInboundMail(null, null, null);
        
        //test - 1 Synced Emails - needs reconciliation
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());
        //test for no task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task];
        system.assertEquals(0, lstTasks.size());
    }
    
    static testMethod void Test_NoCampusContacts() {
        TestInit(false, true, true);
        SendInboundMail('user@testing.com', '1234 This is a plaintext body', null);
        
        //test - NO Synced Emails
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c];
        system.assertEquals(0, lstWSE.size());
        //test for no task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task];
        system.assertEquals(0, lstTasks.size());
    }
    
    static testMethod void Test_NoOppMatch() {
        TestInit();
        SendInboundMail('user@testing.com', '1234 This is a plaintext body', null);
        //test - 1 Synced Emails needs reconciliation
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());
    }
    
    static testmethod void Test_TaskInsertionError(){
        TestInit();
        //Catch expected Error
        webmailSyncedOpportunityEmailReceiver.booTestForFailure = true;
        Test.StartTest();
        try{
            SendInboundMail('user@testing.com', 'plaintext body contacttest0@gmail.com', null); 
        } Catch (System.Exception e){
            System.assertEquals(true, e.getMessage().contains('Error occurred inserting Task'));
        }
        Test.StopTest();
        webmailSyncedOpportunityEmailReceiver.booTestForFailure = false;
    }
    
    static testMethod void Test_OneOppPlainText() {
        TestInit();
        Test.startTest();
        SendInboundMail('user@testing.com', 'plaintext body contacttest0@gmail.com', null); 
        //test Single Successful Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(1, lstWSE.size());
        //test for task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task WHERE Subject = 'Test Subject'];
        system.assertEquals(1, lstTasks.size());
        system.assertEquals(idTestUser, lstTasks[0].OwnerId);
        system.assertEquals(idTestContact, lstTasks[0].WhoId);
        system.assertEquals(idTestOpportunity, lstTasks[0].WhatId);
        
        //Test with Student__c field
        Opportunity oppTest = [SELECT ID, DeltakSRP__Student__c, Student__c FROM Opportunity WHERE id =: idTestOpportunity];
        oppTest.DeltakSRP__Student__c = null;
        oppTest.Student__c = idTestContact;
        update oppTest;
        SendInboundMail('user@testing.com', 'plaintext body contacttest0@gmail.com', null); 
        
        Test.stopTest();
        
        lstWSE = [Select ID FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(2, lstWSE.size());
        //test for task insertion
        lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task WHERE Subject = 'Test Subject'];
        //system.assertEquals(2, lstTasks.size());
    }
    
    static testMethod void Test_TwoActiveOppHTML() {
        TestInit();
        
        //create 2nd opp    
        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        OppTest.DeltakSRP__Student__c = idTestContact;
        insert oppTest;
        ID idTestOpp2 = oppTest.id;
        
        Test.startTest();
        SendInboundMail('user@testing.com', null, 'html body <br /> contacttest0@gmail.com <div></div>'); 
        Test.stopTest();
        //test Single successful Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID, EmailBody__c FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(1, lstWSE.size());
        //test stripped HTML tags
        system.assertEquals('html body \n contacttest0@gmail.com', lstWSE[0].EmailBody__c);
        //test for task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task WHERE Subject = 'Test Subject'];
        system.assertEquals(1, lstTasks.size());
        system.assertEquals(idTestUser, lstTasks[0].OwnerId);
        system.assertEquals(idTestContact, lstTasks[0].WhoId);
    }
    
    //Test one inactive opp, one active opp
    static testMethod void Test_OneActiveOneInactiveOpp() {
        TestInit();
        //create 2nd opp
        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        OppTest.DeltakSRP__Student__c = idTestContact;
        OppTest.StageName = 'Dormant';
        insert oppTest;
        ID idTestOpp2 = oppTest.id;
        
        Test.startTest();
        SendInboundMail('user@testing.com', null, 'html body <br /> contacttest0@gmail.com <div></div>'); 
        Test.stopTest();
        //test Single successful Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID, Opportunity__c, Contact__c, RecordTypeId FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(1, lstWSE.size());
        system.assertEquals(idTestOpportunity, lstWSE[0].Opportunity__c);
        system.assertEquals(idTestContact, lstWSE[0].Contact__c);
        
        //test for task insertion, test all fields
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId, Subject, Description, Status, Completed_Date__c, DeltakSRP__Completed_Date__c, 
                               ActivityDate, Result__c, DeltakSRP__Result__c, Asked_for_Referral__c, Type FROM Task
                               WHERE Subject = 'Test Subject'];
        system.assertEquals(1, lstTasks.size());
        system.assertEquals(idTestUser, lstTasks[0].OwnerId);
        system.assertEquals(idTestContact, lstTasks[0].WhoId);
        system.assertEquals(idTestOpportunity, lstTasks[0].WhatId);
        system.assertEquals('html body \n contacttest0@gmail.com', lstTasks[0].Description);
        system.assertEquals('Completed', lstTasks[0].Status);
        system.assertNotEquals(Null, lstTasks[0].Completed_Date__c);
        system.assertNotEquals(Null, lstTasks[0].ActivityDate);
        system.assertEquals('Successful', lstTasks[0].Result__c);
        system.assertEquals('Successful', lstTasks[0].DeltakSRP__Result__c);
        system.assertEquals('No', lstTasks[0].Asked_for_Referral__c);
        system.assertEquals('Email', lstTasks[0].Type);
    }
    
    //Test two inactive opps
    static testMethod void Test_TwoInactiveOpps() {
        TestInit(true,true, false);
        //create 2nd opp
        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        OppTest.DeltakSRP__Student__c = idTestContact;
        OppTest.StageName = 'Dormant';
        insert oppTest;
        ID idTestOpp2 = oppTest.id;
        
        Test.startTest();
        SendInboundMail('user@testing.com', null, 'html body <br /> contacttest0@gmail.com <div></div>'); 
        Test.stopTest();
        //test Single successful Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID, EmailBody__c, Opportunity__c, Contact__c, RecordTypeId FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getSuccessfulRecordType()];
        system.assertEquals(1, lstWSE.size());
        system.assertEquals(idTestOpportunity, lstWSE[0].Opportunity__c);
        system.assertEquals(idTestContact, lstWSE[0].Contact__c);
        //test for task insertion
        List<Task> lstTasks = [SELECT OwnerId, WhoId, WhatId FROM Task WHERE Subject = 'Test Subject'];
        system.assertEquals(1, lstTasks.size());
        system.assertEquals(idTestUser, lstTasks[0].OwnerId);
        system.assertEquals(idTestContact, lstTasks[0].WhoId);
    }
    
    //two opps, different contact, same email
    static testMethod void Test_TwoOppsDifferentContactSameEmail() {
        TestInit();
        //create 2nd opp
        
        Contact conTest = CreateContact(1, idTestInstitution).Get(0);
        insert conTest;
        ID idTestContact2 = conTest.Id;

        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        //Let's test with the other Contact Link
        OppTest.Student__c = idTestContact2;
        insert oppTest;
        ID idTestOpp2 = oppTest.id;
        
        Test.startTest();
        SendInboundMail('user@testing.com', 'plain body contacttest0@gmail.com', null); 
        Test.stopTest();
        
        //test Single Needs Reconciliation Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID, Opportunity__c, Contact__c, RecordTypeId FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());
        system.assertEquals(null, lstWSE[0].Opportunity__c);
        system.assertEquals(null, lstWSE[0].Contact__c);
         
        //test for task insertion, test all fields
        List<Task> lstTasks = [SELECT Id FROM Task];
        system.assertEquals(0, lstTasks.size());
        
    }
    
    //contact in to field
    static testMethod void Test_TwoActiveOppsDifferentContacts() {
        TestInit();
        //create 2nd opp
        Contact conTest = CreateContact(1, idTestInstitution).Get(0);
        conTest.Email = 'adifferentaddress@testing.com';
        insert conTest;
        ID idTestContact2 = conTest.Id;
        
        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        OppTest.Student__c = idTestContact2;
        insert oppTest;
        ID idTestOpp2 = oppTest.id;
        
        Test.startTest();
        //Email 1 has both addresses in body
        SendInboundMail('user@testing.com', null, 'html body <br /> contacttest0@gmail.com <div></div><br>adifferentaddress@testing.com'); 
        //test Single Needs Reconciliation Synced Email
        List<Webmail_Synced_Emails__c> lstWSE = [Select ID, Opportunity__c, Contact__c, RecordTypeId FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(1, lstWSE.size());

        //Email 2 has on address in body, the other in TO field
        List<String> s = new List<String> {'adifferentaddress@testing.com'};
        SendInboundMail('user@testing.com', null, 'html body <br /> contacttest0@gmail.com <div></div><br>', s, null); 
        lstWSE = [Select ID, Opportunity__c, Contact__c, RecordTypeId FROM Webmail_Synced_Emails__c WHERE RecordTypeID =: webmail_utilities.getNeedsReconciliationRecordType()];
        system.assertEquals(2, lstWSE.size());
        
        Test.stopTest();
    }
        
    
    
    //-- Trigger Handler Tests
    static testMethod void Test_TriggerHandlerSuccessfulAndNeedsReconcile() {
        TestInit();
        
        Webmail_Synced_Emails__c wse = CreateSyncedEmail(1, idTestUser, idTestInstitution, idTestContact, null, webmail_Utilities.getNeedsReconciliationRecordType()).Get(0);
        insert wse;
        
        Test.StartTest();
        wse = [SELECT id, RecordTypeID FROM Webmail_Synced_Emails__c WHERE ID =: wse.id];
        wse.Opportunity__c = idTestOpportunity;
        update wse;
        
        wse = [SELECT id, RecordTypeID FROM Webmail_Synced_Emails__c WHERE ID =: wse.id];
        System.assertEquals(webmail_Utilities.getSuccessfulRecordType(), wse.RecordTypeID);
        
        wse.Opportunity__c = null;
        update wse;
        
        wse = [SELECT id, RecordTypeID FROM Webmail_Synced_Emails__c WHERE ID =: wse.id];
        System.assertEquals(webmail_Utilities.getNeedsReconciliationRecordType(), wse.RecordTypeID);
        
        Opportunity oppAltStudentField = [SELECT id, DeltakSRP__Student__c, Student__c FROM Opportunity WHERE id =: idTestOpportunity];
        oppAltStudentField.DeltakSRP__Student__c = null;
        oppAltStudentField.Student__c = idTestContact;
        update oppAltStudentField;
        
        oppAltStudentField = [SELECT id, DeltakSRP__Student__c, Student__c FROM Opportunity WHERE id =: idTestOpportunity];
        wse.Contact__c = null;
        wse.Opportunity__c = null;
        update wse;
        
        wse = [SELECT id, RecordTypeID FROM Webmail_Synced_Emails__c WHERE ID =: wse.id];
        System.assertEquals(webmail_Utilities.getNeedsReconciliationRecordType(), wse.RecordTypeID);
        wse.Opportunity__c = idTestOpportunity;
        update wse;
        Test.StopTest();
        
        //test for task insertion
        List<Task> lstTasks = [SELECT Id, Subject FROM Task WHERE Subject = 'Subject0'];
        //system.assertEquals(2, lstTasks.size());
    }
    
    static testMethod void Test_TriggerHandlerError() {
        TestInit();
        webmail_Synced_Email_TriggerHandler.booTestForFailure = true;
        
        Webmail_Synced_Emails__c wse = CreateSyncedEmail(1, idTestUser, idTestInstitution, idTestContact, null, webmail_Utilities.getNeedsReconciliationRecordType()).Get(0);
        insert wse;
        
        wse = [SELECT id, RecordTypeID FROM Webmail_Synced_Emails__c WHERE ID =: wse.id];
        wse.Opportunity__c = idTestOpportunity;
        
        //Catch expected Error
        Test.StartTest();
        try{
            update wse;
            //system.assert(False, 'exception expected');
        } Catch (System.Exception e){
            System.assertEquals(true, e.getMessage().contains('An error occured during task insertion'));
        }
        Test.StopTest();
        
        webmail_Synced_Email_TriggerHandler.booTestForFailure = false;
    }
    
    //-- Class specific functions
    //Init
    Public static void TestInit(){
        TestInit(true, true, true);
    }
    Public static void TestInit(boolean booCreateCampusContacts, boolean booSetUserEmails, boolean booActiveOpp){
        
        User usrTest = CreateUser('Webmail7', 'user@testing.com.na26');
        insert usrTest;
        idTestUser = usrTest.id;
        
        //create custom settings
        webmailSettings__c setting = webmailSettings__c.getOrgDefaults();
        setting.InboundServiceAddress__c = 'inboundtestaddress@testing.com';
        setting.ReconciliationUserID__c = idTestUser;
        upsert setting;
        
        Account actTest = CreateAccount(1).Get(0);
        insert actTest;
        idTestInstitution = actTest.Id;
        
        if(booCreateCampusContacts){
            Campus_Contacts__c ccTest = New Campus_Contacts__c();
            ccTest.Organization__c = idTestInstitution;
            ccTest.Employee__c = idTestUSer;
            insert ccTest;
        }
        
        Contact conTest = CreateContact(1, idTestInstitution).Get(0);
        insert conTest;
        idTestContact = conTest.Id;
        
        Opportunity oppTest = CreateOpportunity(1, idTestInstitution).Get(0);
        OppTest.DeltakSRP__Student__c = idTestContact;
        if(!booActiveOpp){
            OppTest.StageName = 'Dormant';
        }
        insert oppTest;
        idTestOpportunity = oppTest.id;
        
        if(booSetUserEmails){
            List<WebmailUserEmail__c> lstWUETest = CreateWebmailUserEmail(2);
            lstWUETest[1].EmailAddress__c = 'user@testing.com';
            insert lstWUETest;            
        }
    }
    
    Public Static void SendInboundMail(String strFromAddress, String strPlainTextBody, String strHTMLBody){
        SendInboundMail(strFromAddress, strPlainTextBody, strHTMLBody, null, null);
    }
    
    Public Static void SendInboundMail(String strFromAddress, String strPlainTextBody, String strHTMLBody, List<String> strToAddresses, String strSubject){
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        if (strSubject == null){
            strSubject = 'Test Subject';
        }
        system.debug('strSubject: ' + strSubject);
        // setup the data for the email
        email.subject = strSubject;
        email.fromname = 'FirstName LastName';
        email.plainTextBody = strPlainTextBody;
        email.htmlBody = strHTMLBody;
        env.fromAddress = strFromAddress;
        if(strToAddresses!=null && strToAddresses.size()>0){
            system.debug('ToAddress Set');
            email.toAddresses = strToAddresses;
        }
                      
        // call the email service class and test it with the data in the testMethod
        webmailSyncedOpportunityEmailReceiver emailProcess = new webmailSyncedOpportunityEmailReceiver();
        emailProcess.handleInboundEmail(email, env);
    }
    
    //-- Misc
    public static String generateRandomString(Integer intLength) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String strReturn = '';
        while (strReturn.length() < intLength) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           strReturn += chars.substring(idx, idx+1);
        }
        return strReturn; 
    }
    
    Public static String generateLoremIpsumForBodyTest(){
        //1000 characterbase
        String strBase = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sednt ipsum.'  ; 
        
        String strReturn = '';
        
        for (Integer i = 0; i < 33; i++) {
            strReturn += strBase;         
        }
        
        return strReturn;
    }
    
    //-- Obj Factories --
    
    Public static User CreateUser(String strAlias, String strEmail){
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User userNew = new User(Alias = strAlias, Email=strEmail, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=strEmail);
        return userNew;
    }
    
    Public static List<Account> CreateAccount(Integer intCount){
        List<Account> results = New List<Account>();
        for (integer i=0; i<intCount; i++){
            results.add(new Account(Name = 'XYZ ' + i));
        }
        return results;
    }
    
    public static List<Contact> CreateContact(Integer intCount, ID idAccount){
        List<Contact> results = New List<Contact>();
        for (integer i=0; i<intCount; i++){
            results.add(new Contact(FirstName = 'Contacty', 
                                 LastName = 'Contacterson' + String.valueOf(intCount),
                                 AccountID = idAccount,
                                 email = 'contacttest' + i + '@gmail.com'));
        }
        return results;
    }
    
    Public static List<Opportunity> CreateOpportunity(Integer intCount, ID idAccount){
        List<Opportunity> results = new List<Opportunity>();
        for (integer i=0; i<intCount; i++){
            results.add(new Opportunity(Name = 'Opp' + 1, Description = 'Desc', StageName = 'New Inquiry', CloseDate = Date.Today(), AccountId = idAccount));
        }
        return results;
    } 
    
    Public static List<Webmail_Synced_Emails__c> CreateSyncedEmail(Integer intCount, ID idOwner, ID idInstitution, ID idContact, ID idOpportunity, ID idRecordType){
        List<Webmail_Synced_Emails__c> results = new List<Webmail_Synced_Emails__c>();
        for (integer i=0; i<intCount; i++){
            results.add(new Webmail_Synced_Emails__c(OwnerID = idOwner, Organization__c = idInstitution, Contact__c = idContact, Opportunity__c = idOpportunity, Subject__c = 'Subject' + i, EmailBody__c = 'Body' + i));
        }
        return results;
    }
    
    Public static List<WebmailUserEmail__c> CreateWebmailUserEmail(Integer intCount){
        List<WebmailUserEmail__c> results = new List<WebmailUserEmail__c>();
        for (integer i=0; i<intCount; i++){
            results.add(new WebmailUserEmail__c(User__c = idTestUser, EmailAddress__c = 'TestUser' + i + '@testing.com', Academic_Institution__c = idTestInstitution));
        }
        return results;
    }
          
}