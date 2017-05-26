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
private class SRPLeadTriggerHandlerTest2 {
	
	static testmethod void testConvertLeadAfterLogin(){
		
		User u = [Select Id from user where profile.name = 'System Administrator' and isactive = true LIMIT 1];
       		
	        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        system.runas(u){
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname3';
	        c.LastName = 'lname3';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        // Test Case for Brand New Lead
	        Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        
	        Lead l2 = new Lead();
	        l2.Status = 'Open';
	        l2.Company = 'Deltak';
	        l2.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l2.FirstName = 'test firstname2';
	        l2.LastName = 'test lastname2';
	        l2.RecordTypeId = rt2.Id;
	        l2.Phone = '1234567890';
	        l2.MobilePhone = '1234567890';
	        l2.DeltakSRP__Work_Phone__c = '1234567890';
	        l2.DeltakSRP__Home_Phone__c = '1234567890';
	        List<Lead> leadlist = new List<Lead>();
	        leadlist.add(l);
	        leadlist.add(l2);
	        
	        Test.starttest();
		         insert leadlist;
		         Map<Id,String> lsmap = new Map<Id, String>();
		         Map<Id,String> lsmap2 = new Map<Id, String>();
		         lsmap.put(l.id, 'New Inquiry');
		         lsmap2.put(l.id, userinfo.getuserid());
		         //Map<Id, Id> lompa = new Map<ID, Id>();
		         Test.setMock(WebServiceMock.class, new ConvertLeadRequestMock());
		         SRPLeadConvertHelperBulk.convertleadafterlogin('00DJ0000001Mcdw!ARIAQIDzv6mmEkgNn1ZPAQM7YkzqaPxy5YPBCeal8RwT_88g1mKKyd_TdQdP2cuEf1ZFr4tnjzFzUGRzxNS4WpI6TrV86rq2','https://login.salesforce.com/services/Soap/u/32.0/00D60000000JELK',lsmap,lsmap2);
	        Test.StopTest();
	        }  
	}
	
	static testmethod void testConvertLeadcallout(){
		
		User u = [Select Id from user where profile.name = 'System Administrator' and isactive = true LIMIT 1];
       		
	        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        system.runas(u){
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname2';
	        c.LastName = 'lname2';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        // Test Case for Brand New Lead
	        Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        
	        Lead l2 = new Lead();
	        l2.Status = 'Open';
	        l2.Company = 'Deltak';
	        l2.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l2.FirstName = 'test firstname2';
	        l2.LastName = 'test lastname2';
	        l2.RecordTypeId = rt2.Id;
	        l2.Phone = '1234567890';
	        l2.MobilePhone = '1234567890';
	        l2.DeltakSRP__Work_Phone__c = '1234567890';
	        l2.DeltakSRP__Home_Phone__c = '1234567890';
	        List<Lead> leadlist = new List<Lead>();
	        leadlist.add(l);
	        leadlist.add(l2);
	        
	        Test.starttest();
		         insert leadlist;
		         Map<Id,String> lsmap = new Map<Id, String>();
		         Map<Id,String> lsmap2 = new Map<Id, String>();
		         for(Lead le: leadlist){
			         lsmap.put(le.id, 'New Inquiry');
			         lsmap2.put(le.id, userinfo.getuserid());
		         }
		         Test.setMock(WebServiceMock.class, new loginRequestMock());
		         SRPLeadConvertHelperBulk.convertleadcallout(lsmap,lsmap2);
	        Test.StopTest();
	        }  
	}
	
   static testMethod void myUnitTest() {
       		
       		User u = [Select Id from user where profile.name = 'System Administrator' and isactive = true LIMIT 1];
       		
	        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        system.runas(u){
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        Campaign cm = new Campaign();
	        cm.name = 'testcampaign';
	        cm.campaign_code__c = '12345qwert';
	        insert cm;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname1';
	        c.LastName = 'lname1';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
	        // Test Case for Brand New Lead
	        Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.rfi_campaign_code__c = '12345qwert';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
	        
	        Lead l2 = new Lead();
	        l2.Status = 'Open';
	        l2.Company = 'Deltak';
	        l2.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l2.FirstName = 'test firstname2';
	        l2.LastName = 'test lastname2';
	        l2.RecordTypeId = rt2.Id;
	        l2.Phone = '1234567890';
	        l2.MobilePhone = '1234567890';
	        l2.DeltakSRP__Work_Phone__c = '1234567890';
	        l2.DeltakSRP__Home_Phone__c = '1234567890';
	        List<Lead> leadlist = new List<Lead>();
	        leadlist.add(l);
	        leadlist.add(l2);
	        
	        test.starttest();
	        	insert leadlist;
	        Test.stopTest(); 
	        }
        }
}