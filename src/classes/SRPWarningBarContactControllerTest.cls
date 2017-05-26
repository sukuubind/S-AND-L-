@isTest
private class SRPWarningBarContactControllerTest {

    static testMethod void myUnitTest() {
    	Id srpStudentRecordType = [Select Id from RecordType where name= 'SRP Student'].Id;
    	
    	Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
    	
    	Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srpStudentRecordType;
        
        insert c;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
        SRPwarningBarContactController testObj = new SRPwarningBarContactController(stdController);
        
        c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srpStudentRecordType;
        c.DoNotCall = true;
        insert c;
        
        stdController = new ApexPages.StandardController(c);
        testObj = new SRPwarningBarContactController(stdController);
        
        c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srpStudentRecordType;
        c.DoNotCall = true;
        c.DeltakSRPSMS__Ok_To_Text__c = true;
        insert c;
        
        stdController = new ApexPages.StandardController(c);
        testObj = new SRPwarningBarContactController(stdController);
        
        c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srpStudentRecordType;
        c.DoNotCall = true;
        c.DeltakSRPSMS__Ok_To_Text__c = true;
        c.HasOptedOutOfEmail = true;
        insert c;
        
        stdController = new ApexPages.StandardController(c);
        testObj = new SRPwarningBarContactController(stdController);
        
        c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srpStudentRecordType;
        c.DoNotCall = true;
        c.DeltakSRPSMS__Ok_To_Text__c = true;
        c.HasOptedOutOfEmail = true;
        c.Do_Not_Register__c = true;
        insert c;
        
        stdController = new ApexPages.StandardController(c);
        testObj = new SRPwarningBarContactController(stdController);
    }
}