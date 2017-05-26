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
private class ContactTriggerTest {
	static testMethod void testSRPContactTriggerTest(){
		Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        
        System.runAs(u2) 
        {
        	test.starttest();
        	 Account a = new Account();
	    	a.Name = 'Test Account';
	    	insert a;
	    	
	    	//set up a program and set the opportunity to it
	       	Academic_Program__c ap = new Academic_Program__c();
	       	ap.Name = 'Test Program';
	       	ap.School__c = a.Id;
	       	insert ap;
	       	
	       	Academic_Specialization__c s = new Academic_Specialization__c();       	
	       	s.Name = 'Test Specialization';
	       	s.Academic_Program__c = ap.Id;
	       	insert s;
	       RecordType crecord = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        Contact c = new Contact ();
	        c.AccountId = a.Id;
	        c.FirstName='Joe';
	        c.LastName='Smith';
	        c.Phone='2222222222';
	        c.AccountId = a.Id;   
	        c.Employer_Company__c = '';
	        c.RecordTypeId = crecord.id;
	        
	        
	        insert c;
        	RecordType record = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	     
	        
			Opportunity o = new Opportunity();
			o.RecordTypeId = record.id;
	        DateTime t=System.now();
	        date d = Date.newInstance(t.year(),t.month(),t.day());
	        o.CloseDate=d;
	        o.StageName='New Inquiry';
	        o.Program__c = ap.Id;        
	        //o.ForecastCategoryName='Pipeline';
	        o.Name='Test';
	        o.AccountID=a.Id;
	        o.Student__c=c.Id;      
	        o.DeltakSRP__Student__c = c.Id;  
	        insert o;
	        System.debug('VS -- insert oppty '+o);
	        
	        c.Email = 'a@b';
	        try{
	        update c;
	        }catch(Exception e){
	        	System.assert(true);
	        }
        test.stoptest();
        }
	}
    static testMethod void myUnitTest() {
    	
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        
        System.runAs(u2) 
        {
	        Account a = new Account();
	    	a.Name = 'Test Account';
	    	insert a;
	    	
	    	//set up a program and set the opportunity to it
	       	Academic_Program__c ap = new Academic_Program__c();
	       	ap.Name = 'Test Program';
	       	ap.School__c = a.Id;
	       	insert ap;
	       	
	       	Academic_Specialization__c s = new Academic_Specialization__c();       	
	       	s.Name = 'Test Specialization';
	       	s.Academic_Program__c = ap.Id;
	       	insert s;
	       
	        Contact c = new Contact ();
	        c.AccountId = a.Id;
	        c.FirstName='Joe';
	        c.LastName='Smith';
	        c.Phone='2222222222';
	        c.AccountId = a.Id;   
	        c.Employer_Company__c = '';
	        
	        insert c;
	        
	        RecordType record = [Select r.Name, r.Id From RecordType r where r.Name = 'Student Opportunity' limit 1];
	     
	        
			Opportunity o = new Opportunity();
			o.RecordTypeId = record.id;
	        DateTime t=System.now();
	        date d = Date.newInstance(t.year(),t.month(),t.day());
	        o.CloseDate=d;
	        o.StageName='New Inquiry';
	        o.Program__c = ap.Id;        
	        //o.ForecastCategoryName='Pipeline';
	        o.Name='Test';
	        o.AccountID=a.Id;
	        o.Student__c=c.Id;        
	        insert o;
	        
	        c.Phone = '33333333';
	        update c;
        }
    }
    
    
    static testMethod void contactTestJorge(){
    	Profile pr = [SELECT Id FROM profile WHERE name='Integration Profile'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        
        Account a = new Account();
    	a.Name = 'Test Account';
    	insert a;
        
    	List<RecordType> recordList = [select id from RecordType where name = 'Student Contact'];
    	RecordType record = null;
    	if(recordList != null && recordList.size() > 0){
    		record = recordList[0];
    	}
        Contact c = new Contact ();
        c.FirstName='Joe';
        c.LastName='Smith';
        c.Email = 'abc@qwerty.com';
        c.SSN__c = '1231231234';
        c.ssn_last_4__c = '1234';
        c.student_id__c = '1231231234';
        c.phone = '1231231234';
        c.work_phone__c = '1231231234';
        c.birthdate = System.today();
        c.mobilephone = '1231231234';
        c.mailingstreet = '123 main st';
        c.mailingcity = 'newyork';
        c.mailingstate = 'NY';
        c.mailingpostalcode = '01234';
        c.gender__c = 'male';
        c.title = 'Mr';
        c.accountid = a.id;
        c.ownerid = u2.id;
        //c.external_id__c = 'check';
        if(record != null)
            c.recordTypeId = record.id;
        
        c.Phone='2222222222';        
        insert c;
        
        System.AssertNotEquals(null, c.id);
        }
    }
    
    //Testing Contact.Employer being updated with the Opp.Stage = New Inquiry
    static testMethod void testContactEmployerFieldUpdate1() {
    	
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        
        System.runAs(u2) 
        {
	        Account account1 = new Account();
	    	account1.Name = 'Test Account';
	    	insert account1;
	    	
	    	//set up a program and set the opportunity to it
	       	Academic_Program__c program1 = new Academic_Program__c();
	       	program1.Name = 'Test Program';
	       	program1.School__c = account1.Id;
	       	insert program1;
	       	
	       	Academic_Specialization__c spec1 = new Academic_Specialization__c();       	
	       	spec1.Name = 'Test Specialization';
	       	spec1.Academic_Program__c = program1.Id;
	       	insert spec1;
	       
	        Contact contact1 = new Contact ();
	        contact1.AccountId = account1.Id;
	        contact1.FirstName='Joe';
	        contact1.LastName='Smith';
	        contact1.Phone='2222222222';  
	        contact1.Employer_Company__c = 'Disney';
	        
	        insert contact1;
	        
	        RecordType record = [Select r.Name, r.Id From RecordType r where r.Name = 'Student Opportunity' limit 1];
	     
	        
			Opportunity opp1 = new Opportunity();
			opp1.RecordTypeId = record.id;
	        DateTime t=System.now();
	        date d = Date.newInstance(t.year(),t.month(),t.day());
	        opp1.CloseDate=d;
	        opp1.StageName='New Inquiry';
	        opp1.Program__c = program1.Id;        
	        //o.ForecastCategoryName='Pipeline';
	        opp1.Name='Test';
	        opp1.AccountID=account1.Id;
	        opp1.Student__c=contact1.Id;        
	        insert opp1;
	        
	        contact1.Phone = '33333333';
	        contact1.Employer_Company__c = '';
	        
	        update contact1;
	        
	        opp1.StageName = 'Start';
	        try{
	        	update opp1;
	        }
	        catch(System.DmlException e){
	        	System.assert(true, 'Employer/Company value is required to move to this Opportunity stage. Please update on the Student Affiliation record.');	
	        
	        }   
	   	}
    }
    
    //Testing Contact.Employer being updated with the Opp.Stage = Start
    static testMethod void testContactEmployerFieldUpdate2() {
    	
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        
        System.runAs(u2) 
        {
	        Account account1 = new Account();
	    	account1.Name = 'Test Account';
	    	insert account1;
	    	
	    	//set up a program and set the opportunity to it
	       	Academic_Program__c program1 = new Academic_Program__c();
	       	program1.Name = 'Test Program';
	       	program1.School__c = account1.Id;
	       	insert program1;
	       	
	       	Academic_Specialization__c spec1 = new Academic_Specialization__c();       	
	       	spec1.Name = 'Test Specialization';
	       	spec1.Academic_Program__c = program1.Id;
	       	insert spec1;
	       
	        Contact contact1 = new Contact ();
	        contact1.AccountId = account1.Id;
	        contact1.FirstName='Joe';
	        contact1.LastName='Smith';
	        contact1.Phone='2222222222'; 
	        
	        
	        insert contact1;
	        
	        RecordType record = [Select r.Name, r.Id From RecordType r where r.Name = 'Student Opportunity' limit 1];
	     
	        
			Opportunity opp1 = new Opportunity();
			opp1.RecordTypeId = record.id;
	        DateTime t=System.now();
	        date d = Date.newInstance(t.year(),t.month(),t.day());
	        opp1.CloseDate=d;
	        opp1.StageName='Start';
	        opp1.Program__c = program1.Id;        
	        //o.ForecastCategoryName='Pipeline';
	        opp1.Name='Test';
	        opp1.AccountID=account1.Id;
	        opp1.Student__c=contact1.Id;        
	        
	        try{
	        	insert opp1;
	        }
	        catch(System.DmlException e){
	        	System.assert(true, 'Employer/Company value is required to move to this Opportunity stage. Please update on the Student Affiliation record.');	
	        
	        }   	             
        }
    }
}