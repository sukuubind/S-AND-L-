@isTest
private class DuplicateNotiferTest {

    static testMethod void Test1() {
        
Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        System.debug('---------- BEGIN Test 1 ----------');
        //In this use case, the Program Responsibility is associated with the desired program and is associated with a DOA
        Test.startTest(); 
        Account a = new Account();
        a.Name = 'Test Account';    
        a.Goldmine_Key5__c = 'testact';    
        insert a;
        
        /**Program_Master__c pm = new Program_Master__c();
        pm.Abbreviation__c = 'TestPrgm';
        pm.Name = 'TestMaster';
        insert pm;**/
        
        //set up a program and set the opportunity to it
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'Test Program';       
        ap.School__c = a.Id;
        //ap.Program_Master__c = pm.Id;
        insert ap;  
        
        Profile [] p = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce'];
        
        User u = new User();
        //u.Name = 'Test Name';
        u.Email = 'testname@test.com';
        u.Username = 'testname0@test.com';
        u.FirstName = 'TestFirstName';
        u.LastName = 'TestLastName';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Indiana/Indianapolis';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'test';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p[0].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Organization__c = a.Id;
        cc1.Employee__c = u.Id;
        cc1.Title__c = 'Director of Admission';
        insert cc1;
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Organization__c = a.Id;
        cc2.Employee__c = u.Id;
        cc2.Title__c = 'Director of Admission';
        insert cc2; 
        
        Program_Responsibility__c pr = new Program_Responsibility__c();
        pr.Academic_Program__c = ap.Id;
        pr.Campus_Contacts__c = cc1.Id;
        insert pr;
        
        boolean result = DuplicateNotifier.createCaseBySchoolProgram('testact', 
                                                 'TestPrgm',
                                                 'Technical', 
                                                 'Goldmine', 
                                                 'Test Subject', 
                                                 'Test Description',
                                                 null,
                                                 null
                                                 );
        System.assertEquals(true, result);
        List<Case> cList = [SELECT OwnerId FROM Case WHERE Subject = 'Test Subject' LIMIT 1];       
        if(cList != null && cList.size() > 0){
            for(Case c : cList)
               System.assertEquals(c.OwnerID, u.Id);        
        }
        Test.stopTest();
        System.debug('----------END Test 1 ----------');
        }
    }
    
    
    static testMethod void Test2() {
        
Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        System.debug('---------- BEGIN Test 2 ----------');
        //In this use case, the Program Responsibility is associated with the desired program but the Contact is not right Title (DOA)
        
        Test.startTest();
        Account a = new Account();
        a.Name = 'Test Account';        
        a.Goldmine_Key5__c = 'testact';
        insert a;
        
        /**Program_Master__c pm = new Program_Master__c();
        pm.Abbreviation__c = 'TestPrgm';
        pm.Name = 'TestMaster';
        insert pm;**/
        
        //set up a program and set the opportunity to it
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'Test Program';
        ap.School__c = a.Id;
        //ap.Program_Master__c = pm.Id;
        insert ap;  
        
        Profile [] p = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce'];
        
        User u = new User();
        //u.Name = 'Test Name';
        u.Email = 'testname@test.com';
        u.Username = 'testname2@test.com';
        u.FirstName = 'TestFirstName';
        u.LastName = 'TestLastName';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Indiana/Indianapolis';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'test';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p[0].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Organization__c = a.Id;
        cc1.Employee__c = u.Id;
        cc1.Title__c = 'Program Manager / Admissions Representative';        
        insert cc1;
        
        Program_Responsibility__c pr = new Program_Responsibility__c();
        pr.Academic_Program__c = ap.Id;        
        pr.Campus_Contacts__c = cc1.Id; 
        insert pr;
        
        boolean result = DuplicateNotifier.createCaseBySchoolProgram('testact', 
                                                 'TestPrgm',
                                                 'Technical', 
                                                 'Goldmine', 
                                                 'Test Subject', 
                                                 'Test Description',
                                                 null,
                                                 null);
        /** Changing the following assert to true assert as we 
        will find a Owner for the case which will be the ownerid of the school
        System.assertEquals(false, result);     **/
        System.assertEquals(true, result);   
        Test.stopTest();
        System.debug('---------- END Test 2 ----------');
        }
    }
    
    
     static testMethod void Test3() {
        
Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        System.debug('---------- BEGIN Test 3 ----------');
        //In this use case, the Program Responsibility is not associated with the desired program but the Contact is the right Title (DOA)
        
        Test.startTest();
        Account a = new Account();
        a.Name = 'Test Account';        
        a.Goldmine_Key5__c = 'testact';
        insert a;
        
        /**Program_Master__c pm = new Program_Master__c();
        pm.Abbreviation__c = 'TestPrgm';
        pm.Name = 'TestMaster';
        insert pm;**/
        
        //set up a program and set the opportunity to it
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'Test Program';
        ap.School__c = a.Id;
        //ap.Program_Master__c = pm.Id;
        insert ap;  
        
        Profile [] p = [SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce'];
        
        User u = new User();
        //u.Name = 'Test Name';
        u.Email = 'testname@test.com';
        u.Username = 'testname3@test.com';
        u.FirstName = 'TestFirstName';
        u.LastName = 'TestLastName';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Indiana/Indianapolis';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'test';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = p[0].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Organization__c = a.Id;
        cc1.Employee__c = u.Id;
        cc1.Title__c = 'Director of Admission';        
        insert cc1;
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Organization__c = a.Id;
        cc2.Employee__c = u.Id;
        cc2.Title__c = 'Director of Admission';        
        insert cc2;        
       
        
       /* Program_Responsibility__c pr = new Program_Responsibility__c();
        pr.Academic_Program__c = ap.Id;        
        pr.Campus_Contacts__c = cc1.Id; 
        insert pr;*/
        
        boolean result = DuplicateNotifier.createCaseBySchoolProgram('testact', 
                                                 'TestPrgm',
                                                 'Technical', 
                                                 'Goldmine', 
                                                 'Test Subject', 
                                                 'Test Description',
                                                 null,
                                                 null);
                                                 
        System.assertEquals(true, result);
        List<Case> cList = [SELECT OwnerId FROM Case WHERE Subject = 'Test Subject' LIMIT 1];       
        if(cList != null && cList.size() > 0){
            for(Case c : cList)
               System.assertEquals(c.OwnerID, u.Id);        
        }
        Test.stopTest();
        System.debug('---------- END Test 3 ----------');
        }
    }
}