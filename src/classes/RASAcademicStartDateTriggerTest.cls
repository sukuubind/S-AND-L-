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
private class RASAcademicStartDateTriggerTest {

    static testMethod void myUnitTest() {
    	
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        Account school = new Account();
        school.Name = 'School';
        insert school;
        
         Person__c p = new Person__c();
        insert p;
        
       List<Contact> contactList = new List<Contact>();
       Contact student = new Contact();
    	student.FirstName = 'test';
    	student.LastName = 'test';
    	student.Person__c = p.id;
    	student.Time_Zone__c = 'TimeZone';
    	student.AccountId = a.Id;
    	insert student;
    	
    	
    	/**Program_Master__c pm = new Program_Master__c();
    	pm.Name = 'Test Name';
    	pm.Degree_Type__c = 'Certificate';
    	pm.Abbreviation__c = 'MS';
    	insert pm;**/
    	
    	Academic_Program__c acad = new Academic_Program__c();
    	//acad.Program_Master__c = pm.id;
    	acad.School__c = a.id;
    	acad.Name = 'Test Acad Program';
    	insert acad;
    	
    	Academic_Start_Date__c startDate = new Academic_Start_Date__c();
    	startDate.Start_Date__c = d;
    	startDate.Program__c = acad.id;
    	insert startDate;
    	
    	
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        o.Student__c = student.Id;
        o.Program__c = acad.Id;
        o.Academic_Start_Date__c = startDate.id;        
        insert o;
        
        d = d.addDays(5);
        startDate.Start_Date__c = d;
        update startDate;
        
        Opportunity opp = [Select id, Academic_Start_Date__c, Start_Date__c from Opportunity where Id = :o.id limit 1];
        System.AssertEquals(startDate.id, opp.Academic_Start_Date__c);
       
        
        }
    }
}