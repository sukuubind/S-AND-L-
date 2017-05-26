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

public with sharing class SRPOpportunityTriggerHandlerTestNotes {

	static testMethod void testNotesWorkExpGpa()
	{	        
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];	        
            
        Account a = [Select Id From Account where Name= 'JHU Advanced Academic Programs' limit 1];
        contact c = new Contact();
        c.FirstName = 'fname1';
        c.LastName = 'lname1';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890'; 
        c.AccountId = a.id;
        c.RecordTypeId = rt4.Id;
        insert c;        
        Opportunity o2 = new Opportunity();
        o2.RecordTypeId = rt3.Id;
        o2.Name = 'Test Opportunity';
        o2.StageName = 'New Inquiry';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c.Id;
        o2.Student__c = c.Id;
        o2.AccountId = a.Id;
        o2.LP_NOTES__c = 'workexp=5#gpa=3.99 – 3.50';
        
        Test.startTest();   
    	insert o2;
        Test.stopTest();		 
	        		
	}	
	
	static testMethod void testNotesEventsandTask()
	{
		RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];	        
            
        Account a = [Select Id From Account where Name= 'JHU Advanced Academic Programs' limit 1];        
        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        User u2 = [select id from User where name='Configuration Manager'];
        contact c = new Contact();
        c.FirstName = 'fname1';
        c.LastName = 'lname1';
        c.Email = 'testemail@salesforce.com';
        c.Phone = '1234567890'; 
        c.AccountId = a.id;
        c.RecordTypeId = rt4.Id;
        insert c;        
        Opportunity o2 = new Opportunity();
        o2.RecordTypeId = rt3.Id;
        o2.Name = 'Test Opportunity';
        o2.StageName = 'New Inquiry';
        o2.CloseDate = system.today()+100;
        o2.DeltakSRP__Student__c = c.Id;
        o2.Student__c = c.Id;
        o2.AccountId = a.Id;
        o2.LP_NOTES__c = 'Event Date:2016-25-02-11-15-00';
         o2.ownerid = setting.PROspect_User_ID__c;
        insert o2;
        
	    id uId = userinfo.getUserid();
        User u = [select id from User where id = :setting.PROspect_User_ID__c ];
       
        Opportunity o3 = new Opportunity(id=o2.id);
      	o3.ownerid = uId;   
      	system.runas(u) { 	
      	update o3;
      	}
	}

}