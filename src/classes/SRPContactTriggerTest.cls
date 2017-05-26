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
private class SRPContactTriggerTest {

    static testMethod void myUnitTest() {
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        DeltakSRP__SRP_Partner_Settings__c psetting = new DeltakSRP__SRP_Partner_Settings__c();
	        psetting.DeltakSRP__Contact_Record_Type_Id__c = rt4.id;
	        insert psetting;
	        
	        SrpTriggerOverrideInSrm__c tover = new SrpTriggerOverrideInSrm__c();
	        tover.SRPContactTrigger__c = false;
	        insert tover;
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname8';
	        c.LastName = 'lname8';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.mobilephone = '5432109876';
	        c.homephone = '5432109876';
	        c.deltakSRP__work_phone__c = '1234567890';
	        c.mailingcountry = 'United States';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        
	        Test.starttest();
	        insert c; 
	        
	        // Create new opportunity
			Opportunity o = new Opportunity();
		    o.Name = 'Test Opportunity';
			o.StageName = 'New Inquiry';
			o.CloseDate = system.today()+100;
			o.recordtypeid = rt3.id;
			o.DeltakSRP__Student__c = c.id;
			insert o;
	        
	        c.email = 'testemail2@salesforce.com';
	        update c;  
    }
}