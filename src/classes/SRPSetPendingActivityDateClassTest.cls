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
@isTest(seealldata=true)
private class SRPSetPendingActivityDateClassTest {

    static testMethod void myUnitTest() {
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
        insert o2;
        
        Task t = new Task();
        t.ActivityDate = system.today() + 100;
        //t.DeltakSRP__Completed_Date__c = system.today() - 50;
        t.DeltakSRP__Type__c = 'Call';
        t.WhatId = o2.Id;
        t.Asked_for_Referral__c = 'Yes';
        insert t;
        
        
        SRPSetPendingActivityDateClass testobj = new SRPSetPendingActivityDateClass();
        test.startTest();
        testobj.resetPendingActivityDate(o2.id);
        
        Date tdate = system.today();
        
        List<Date> tdatelist = new List<Date>();
        tdatelist.add(tdate);
        tdate = testobj.getEarliestDate(tdateList);
        //Date tdate = testobj.getPendingActivityDate(o2.id);
        
        testobj.setPendingActivityDate(o2.Id);
        Test.stopTest();
    }
}