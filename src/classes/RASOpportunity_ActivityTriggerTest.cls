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
@isTest
private class RASOpportunity_ActivityTriggerTest {
/**
    static testMethod void myUnitTest() {
         
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
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        Person__c p = new Person__c();
        insert p;
        
       List<Contact> contactList = new List<Contact>();
       Contact student = new Contact();
        student.FirstName = 'test';
        student.LastName = 'test';
        student.Person__c = p.id;
        student.Time_Zone__c = 'TimeZone';
        student.AccountID = a.Id;
        insert student;
        
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        o.Student__c = student.Id;
        insert o;
        
        
        
        System.Debug('Student --> '+student);
        
        Task tsk2 = new Task();
        tsk2.Subject='Call - Inbound';
        tsk2.Status = 'Complete';
        tsk2.WhatId = o.Id;
        tsk2.WhoId = student.Id;
        tsk2.Successful__c = false;
        //e.ActivityDateTime = tsk;         
        insert tsk2;
        
        student = new Contact();
        student.FirstName = 'test1';
        student.LastName = 'test1';
        student.Person__c = p.id;
        student.Time_Zone__c = 'TimeZones';
        student.AccountID = a.Id;
        insert student;
       
       
        o.AccountID=a.Id;
        o.Student__c = student.id;
        update o;
        
        Task thisTask = [Select WhoId from Task where Id = :tsk2.Id limit 1];
        System.assertEquals(student.Id, thisTask.WhoId);
        }
    }**/
}