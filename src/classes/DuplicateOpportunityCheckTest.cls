@isTest  
private class DuplicateOpportunityCheckTest {

    static testMethod void myUnitTest() {
   /** 
Test.StartTest();        
Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
        RecordType rtStudent = [SELECT Id FROM RecordType WHERE Name = 'Student Opportunity' LIMIT 1];
        RecordType rtCorporate = [SELECT Id FROM RecordType WHERE Name = 'Student Opportunity' LIMIT 1];
        
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Academic_Program__c> acadProgList = new List<Academic_Program__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        
        
        Account a = new Account();
        a.Name = 'Test Account';        
        a.Goldmine_Key5__c =  'Test Account';
        accountList.add(a);
       // insert a;
        
        Account a2 = new Account();
        a2.Name = 'Test Account 2';
        a2.Goldmine_Key5__c =  'Test Account 2';  
        accountList.add(a2);      
        insert accountList;
        
        //set up a program and set the opportunity to it
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'Test Program';
        ap.School__c = a.Id;
        ap.Active__c = true;
        acadProgList.add(ap);
             
        
        Academic_Program__c ap2 = new Academic_Program__c();
        ap2.Name = 'Test Program';
        ap2.School__c = a2.Id;
        ap2.Active__c = true;
        acadProgList.add(ap2);
        insert acadProgList;
        
        Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
        startDate.Start_Date__c = d;
        startDate.Program__c = ap.Id;
        insert startDate;
        
        Contact c = new Contact ();
        c.FirstName='Joe';
        c.LastName='Smith';
        c.Phone='2222222222';    
        c.AccountID = a.Id;  
        contactList.add(c);  
        
        
        Contact c2 = new Contact ();
        c2.FirstName='Chris';
        c2.LastName='Baker';
        c2.Phone='2222222222';   
        c2.AccountID = a.Id;  
        contactList.add(c2);   
        
        
        Contact c3 = new Contact();
        c3.FirstName = 'Venkat';
        c3.LastName = 'Santhanam';
        c3.Phone = '1231231234';
        c3.AccountID = a2.Id;
        contactList.add(c3);
        insert contactList;
        //Associated with 1st contact
        //Associated with 1st Account
        //Stagename is not Start or Closed Duplicate
        Opportunity o = new Opportunity();
        o.Program__c = ap.Id;
        o.Start_Date__c = d;  
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='O';
        o.Student__c = c.Id;
        o.AccountID=a.Id;
        o.RecordTypeId = rtStudent.Id;
        oppList.add(o);
        
        
        //Associated with 1st contact
        //Associated with 1st Account
        //Stagename is Start 
        Opportunity o2 = new Opportunity();
        o2.Program__c = ap.Id;
        o2.Start_Date__c = d;  
        o2.CloseDate=d;
        o2.StageName='Start';
        o2.Name='O2';
        o2.Student__c = c.Id;
        o2.AccountID=a.Id;
        o2.RecordTypeId = rtStudent.Id;
        oppList.add(o2);
       
        
        //Associated with 1st contact
        //Associated with 1st Account
        //Stagename is  not Start or Closed Duplicate 
        Opportunity o3 = new Opportunity();
        o3.Program__c = ap.Id;
        o3.Start_Date__c = d;  
        o3.CloseDate=d;
        o3.StageName='New Inquiry';
        o3.Name='O3';
        o3.Student__c = c.Id;
        o3.AccountID=a.Id;
        o3.RecordTypeId = rtStudent.Id;
        oppList.add(o3);
        
        
        //Associated with 1st contact
        //Associated with 2nd Account
        //Stagename is  not Start or Closed Duplicate 
        Opportunity o4 = new Opportunity();
        o4.Program__c = ap2.Id;
        o4.Start_Date__c = d;
        o4.CloseDate=d;
        o4.StageName='New Inquiry';
        o4.Name='O4';
        o4.Student__c = c3.Id;
        o4.AccountID=a2.Id;
        o4.RecordTypeId = rtStudent.Id;
        oppList.add(o4);
        
        
        //Associated with 2nd contact
        //Associated with 1st Account
        //Stagename is  not Start or Closed Duplicate 
        Opportunity o5 = new Opportunity();
        o5.Program__c = ap.Id;
        o5.Start_Date__c = d;
        o5.CloseDate=d;
        o5.StageName='New Inquiry';
        o5.Name='O5';
        o5.Student__c = c2.Id;
        o5.AccountID=a.Id;
        o5.RecordTypeId = rtStudent.Id;
       
        
        //Associated with 2nd contact
        //Associated with 1st Account
        //Stagename is  Closed Duplicate 
        Opportunity o6 = new Opportunity();
        o6.Program__c = ap.Id;
        o6.Start_Date__c = d;
        o6.CloseDate=d;
        o6.StageName='Closed - Duplicate';
        o6.Name='O6';
        o6.Student__c = c2.Id;
        o6.AccountID=a.Id;
        o6.RecordTypeId = rtStudent.Id;
        oppList.add(o6);
        
        
        //Associated with 1st contact
        //Associated with 2nd Account
        //Stagename is  not Start or Closed Duplicate 
        //RecordType is Corproate RecordType
        Opportunity o7 = new Opportunity();
        o7.Program__c = ap2.Id;
        o7.Start_Date__c = d;
        o7.CloseDate=d;
        o7.StageName='New Inquiry';
        o7.Name='O7';
        o7.Student__c = c3.Id;
        o7.AccountID=a2.Id;
        o7.RecordTypeId = rtCorporate.Id;
        oppList.add(o7);
        insert oppList;
        
        System.assertEquals( 2, DuplicateOpportunityCheck.check(c.Id, 'Test Account').size() );
        System.assertEquals( 2, DuplicateOpportunityCheck.check(c3.Id, 'Test Account 2').size() );
        System.assertEquals( 1, DuplicateOpportunityCheck.check(c2.Id, 'Test Account').size() );
        System.assertEquals( 0, DuplicateOpportunityCheck.check(c2.Id, 'Test Account 2').size() );
        }
Test.StopTest();
**/
    }
}