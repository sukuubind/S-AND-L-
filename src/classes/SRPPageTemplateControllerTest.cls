@isTest
public with sharing class SRPPageTemplateControllerTest {
	static testMethod void testTemplateController(){
		
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
		c.FirstName = 'fname8';
		c.LastName = 'lname8';
		c.Email = 'testemail@salesforce.com';
		c.Phone = '1234567890';
		c.AccountId = a.Id;
		c.RecordTypeId = rt4.Id;
		insert c;	
		  
		  Profile p = null;
	      try{
	          p = [select id from profile where name = 'Online Application Portal User'];
	      }catch(QueryException e){
	        System.assert(false,'Failed to find Online Application Portal Profile.  Please create.');  
	      }
	      
	        User u = new User(alias = 'standt', email='portaluser@testorg.com',
	            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
	            localesidkey='en_US', profileid = p.Id,  ContactId = c.Id,
	            timezonesidkey='America/Los_Angeles', username='portaluser@testorg.com');
	
	        
	        System.debug('Profile id: ' + p.Id + ' Account ID: ' + a.Id);
	        
	        String userId = Site.createPortalUser(u, a.Id, '111111', true);
	        
	        system.runas(u){
	        	SRPPAgeTemplateController ptc = new SRPPAgeTemplateController();
	        	
	        }
	}
}