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
private class SRPContactTriggerHandlerTest {

    static testMethod void myUnitTest() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        DeltakSRP__SRP_Partner_Settings__c psetting = new DeltakSRP__SRP_Partner_Settings__c();
	        psetting.DeltakSRP__Contact_Record_Type_Id__c = rt4.id;
	        insert psetting;
	         
	        SRP_Phone_Codes__c phonecode = new SRP_Phone_Codes__c();
	        phonecode.name = 'united states';
	        phonecode.phone_code__c = '1';
	        phonecode.Is_Country__c = true;
	        insert phonecode;
	        
	        phonecode = new SRP_Phone_Codes__c();
	        phonecode.name = 'new york';
	        phonecode.phone_code__c = '1';
	        phonecode.Is_Country__c = false;
	        insert phonecode;
	        
	        phonecode = new SRP_Phone_Codes__c();
	        phonecode.name = 'DE';
	        phonecode.phone_code__c = '1';
	        phonecode.Is_Country__c = false;
	        insert phonecode;
	        
	        phonecode = new SRP_Phone_Codes__c();
	        phonecode.name = 'IN';
	        phonecode.phone_code__c = '91';
	        phonecode.Is_Country__c = true;
	        insert phonecode;
	        
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
	        
	        contact c2 = [select id, homephone,deltakSRP__work_phone__c,phone, mobilephone, mailingcountry, mailingstate from contact where id =:c.id];
	        
	        c2.mobilephone = '1234567890'; 
	        c2.homephone = '1234567890';
	        c2.deltakSRP__work_phone__c = '1234567890';
	        c2.Phone = '1234567890';
	        update c2;
	        
	        c2.mailingcountry = '';
	        c2.mailingstate = 'new york';
	        c2.mobilephone = '2354169870';
	        c2.homephone = '2354169870';
	        c2.deltakSRP__work_phone__c = '2354169870';
	        c2.Phone = '2354169870';
	        update c2;
	        
	        
	        c2.mobilephone = '0001234567890';
	        c2.homephone = '1234567890';
	        c2.deltakSRP__work_phone__c = '1234567890';
	        c2.Phone = '1234567890';
	        update c2;
	        
	        c2.mobilephone = ''; 
	        c2.homephone = '+12345678901';
	        c2.deltakSRP__work_phone__c = '+12345678901';
	        c2.Phone = '+12345678901';
	        update c2;
	        
	        c2.mobilephone = '+12345678901';
	        c2.homephone = '+12345678901';
	        c2.deltakSRP__work_phone__c = '+12345678901';
	        c2.Phone = '+12345678901';
	        update c2;
	        
	        c2.mobilephone = '0001234567890';
	        c2.homephone = '1234567890';
	        c2.deltakSRP__work_phone__c = '1234567890';
	        c2.Phone = '1234567890';
	        c2.mailingcountry = 'IN';
	        update c2;
	        
	        c2.mobilephone = '+12345678901';
	        c2.homephone = '1234567890';
	        c2.deltakSRP__work_phone__c = '1234567890';
	        c2.Phone = '1234567890';
	        c2.mailingcountry = '';
	        c2.mailingstate = 'DE';
	        update c2;
	        
	       system.assertequals(true, c2.mobilephone.startswith('+1'));
	        Test.stoptest();
	        
    }



	static testMethod void formattedPhone() {
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
		c.mobilephone = '5432109876';
		c.homephone = '5432109876';
		c.deltakSRP__work_phone__c = '1234567890';
		c.mailingcountry = 'United States';
		c.AccountId = a.Id;
		c.RecordTypeId = rt4.Id;


		insert c;

		contact c2 = [select id, homephone,deltakSRP__work_phone__c,phone,DeltakSRP_Formatted_Phone__c ,mobilephone, mailingcountry, mailingstate from contact where id =:c.id];



		c2.mobilephone = '1234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mailingcountry = '';
		c2.mailingstate = 'new york';
		c2.mobilephone = '2354169870';
		c2.homephone = '2354169870';
		c2.deltakSRP__work_phone__c = '2354169870';
		c2.Phone = '2354169870';
		update c2;


		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mobilephone = '';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '+12345678901';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		c2.mailingcountry = 'IN';
		update c2;


		Test.startTest();
		c2.HomePhone = '2345678901';

		c2.Phone = '12345678901';
		c2.mobilephone = '2345678901';
		c2.DeltakSRP__Preferred_Phone__c = 'Home';


		update c2;
		List<Contact> contacts = [SELECT Id,DeltakSRP_Formatted_Phone__c,Phone FROM Contact WHERE DeltakSRP_Formatted_Phone__c != null];
		system.assertequals(contacts.size(), 1);
		System.assertEquals('NA',contacts[0].DeltakSRP_Formatted_Phone__c);
		Test.stoptest();



	}




	static testMethod void formattedPhoneBulk() {
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
		RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
		RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
		RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];

List<Contact> contactListToInsert = new List<Contact>();

		Account a = new Account();
		a.recordTypeid = rt1.Id;
		a.Abbreviation__c = 'TAC';
		a.name = 'test account';
		insert a;

		for(Integer i = 0;i<=200; i++) {


			contact c = new Contact();
			c.FirstName = 'fname8'+ String.valueOf(i);
			c.LastName = 'lname8'+ String.valueOf(i);
			c.Email = 'testemail@salesforce.com';
			c.Phone = '123456789'+ i;
			c.mobilephone = '543210987'+i;
			c.homephone = '543210987'+i;
			c.deltakSRP__work_phone__c = '123456789' + i;
			c.mailingcountry = 'United States';
			c.AccountId = a.Id;
			c.RecordTypeId = rt4.Id;
			contactListToInsert.add(c);
		}

		insert contactListToInsert;


		List<Contact> contactListToUpdate = new List<Contact>();
		Integer y = 0;
		for(Contact c2 : contactListToInsert) {

				c2.HomePhone = '234567890' + y;

				c2.Phone = '1234567890' + y;
				c2.mobilephone = '234567890' + y;
				c2.DeltakSRP__Preferred_Phone__c = 'Home';

				contactListToUpdate.add(c2);
			y++;
			}
		update contactListToUpdate;

		List<Contact> contacts = [SELECT Id,DeltakSRP_Formatted_Phone__c,Phone FROM Contact WHERE DeltakSRP_Formatted_Phone__c Like'%-%'];
		System.debug('Formatted phone is @@@@@@@@@@@@@@@@@@@@@@ ' + contacts[20].DeltakSRP_Formatted_Phone__c);
		system.assertequals(contacts.size(), 90);


	}

	static testMethod void formattedPhoneLessThanTen() {
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
		c.mobilephone = '5432109876';
		c.homephone = '5432109876';
		c.deltakSRP__work_phone__c = '1234567890';
		c.mailingcountry = 'United States';
		c.AccountId = a.Id;
		c.RecordTypeId = rt4.Id;


		insert c;

		contact c2 = [select id, homephone,deltakSRP__work_phone__c,phone,DeltakSRP_Formatted_Phone__c ,mobilephone, mailingcountry, mailingstate from contact where id =:c.id];



		c2.mobilephone = '1234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mailingcountry = '';
		c2.mailingstate = 'new york';
		c2.mobilephone = '2354169870';
		c2.homephone = '2354169870';
		c2.deltakSRP__work_phone__c = '2354169870';
		c2.Phone = '2354169870';
		update c2;


		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mobilephone = '';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '+12345678901';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		c2.mailingcountry = 'IN';
		update c2;


		Test.startTest();
		c2.HomePhone = '2345';

		c2.Phone = '123456';
		c2.mobilephone = '2345678901';
		c2.DeltakSRP__Preferred_Phone__c = 'Home';


		update c2;
		List<Contact> contacts = [SELECT Id,DeltakSRP_Formatted_Phone__c,Phone FROM Contact WHERE DeltakSRP_Formatted_Phone__c LIKE '%NA%'];
		system.assertequals(contacts.size(), 1);
		Test.stoptest();



	}


	static testMethod void formattedPhoneStringOnly() {
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
		c.mobilephone = '5432109876';
		c.homephone = '5432109876';
		c.deltakSRP__work_phone__c = '1234567890';
		c.mailingcountry = 'United States';
		c.AccountId = a.Id;
		c.RecordTypeId = rt4.Id;


		insert c;

		contact c2 = [select id, homephone,deltakSRP__work_phone__c,phone,DeltakSRP_Formatted_Phone__c ,mobilephone, mailingcountry, mailingstate from contact where id =:c.id];



		c2.mobilephone = '1234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mailingcountry = '';
		c2.mailingstate = 'new york';
		c2.mobilephone = '2354169870';
		c2.homephone = '2354169870';
		c2.deltakSRP__work_phone__c = '2354169870';
		c2.Phone = '2354169870';
		update c2;


		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mobilephone = '';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '+12345678901';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		c2.mailingcountry = 'United States';
		update c2;


		Test.startTest();
		c2.HomePhone = '1aaaaaABCD_s';

		c2.Phone = '123456';
		c2.mobilephone = '2345678901';
		c2.DeltakSRP__Preferred_Phone__c = 'Home';


		update c2;
		List<Contact> contacts = [SELECT Id,DeltakSRP_Formatted_Phone__c,Phone FROM Contact WHERE DeltakSRP_Formatted_Phone__c LIKE '%NA%'];
		system.assertequals(contacts.size(), 1);
		Test.stoptest();



	}


	static testMethod void formattedPhoneNull() {
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
		c.mobilephone = '5432109876';
		c.homephone = '5432109876';
		c.deltakSRP__work_phone__c = '1234567890';
		c.mailingcountry = 'United States';
		c.AccountId = a.Id;
		c.RecordTypeId = rt4.Id;


		insert c;

		contact c2 = [select id, homephone,deltakSRP__work_phone__c,phone,DeltakSRP_Formatted_Phone__c ,mobilephone, mailingcountry, mailingstate from contact where id =:c.id];



		c2.mobilephone = '1234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mailingcountry = '';
		c2.mailingstate = 'new york';
		c2.mobilephone = '2354169870';
		c2.homephone = '2354169870';
		c2.deltakSRP__work_phone__c = '2354169870';
		c2.Phone = '2354169870';
		update c2;


		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		update c2;

		c2.mobilephone = '';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '+12345678901';
		c2.homephone = '+12345678901';
		c2.deltakSRP__work_phone__c = '+12345678901';
		c2.Phone = '+12345678901';
		update c2;

		c2.mobilephone = '0001234567890';
		c2.homephone = '1234567890';
		c2.deltakSRP__work_phone__c = '1234567890';
		c2.Phone = '1234567890';
		c2.mailingcountry = 'United States';
		update c2;
       String nothing = 'NA';

		Test.startTest();
		c2.HomePhone = 'Null';

		c2.Phone = '1Testingall';
		c2.mobilephone = '1Testingall';
		c2.DeltakSRP__Preferred_Phone__c = 'Home';


		update c2;
		List<Contact> contacts = [SELECT Id,DeltakSRP_Formatted_Phone__c,Phone FROM Contact WHERE DeltakSRP_Formatted_Phone__c =: nothing];
		system.assertequals(contacts.size(), 1);
		Test.stoptest();



	}


}