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
private class RasProgramBeforeDeleteTest {

    static testMethod void deleteShouldFail() {
    	Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	Account school = new Account();
        school.Name = 'School';
        insert school;
        
        Contact c = new Contact();       
        c.AccountID = school.Id;
        c.LastName = 'Test';
        c.FirstName = 'Test FNAME';
        insert c;
        
    	/**Program_Master__c pm = new Program_Master__c();
    	pm.Name = 'Test Name';
    	pm.Degree_Type__c = 'Certificate';
    	pm.Abbreviation__c = 'MS';
    	insert pm;**/
    	
        Academic_Program__c acad = new Academic_Program__c();
    	//acad.Program_Master__c = pm.id;
    	acad.School__c = school.id;
    	acad.Name = 'Test Acad Program';
    	/** VS Added to Match the filter criteria START **/
    	acad.Active__c = true;
    	acad.School__c = school.Id;
    	/** VS Added to Match the filter criteria END **/
    	insert acad;
    	
    	Academic_Start_Date__c startDate = new Academic_Start_Date__c();
    	startDate.Start_Date__c = System.today();
    	startDate.Program__c = acad.id;
    	insert startDate;
    	
    	
        Opportunity o = new Opportunity();
        o.CloseDate=System.today();
        o.StageName='New Inquiry';
        o.Name='Test';
        o.Academic_Start_Date__c = startDate.id;
        o.Program__c = acad.id;
        o.Student__c = c.Id;
        o.AccountID = school.id;
        insert o;
    	
    	List<Academic_Program__c> acadList = [Select id from Academic_Program__c where id = :acad.id or Name = 'Test Acad Program'];
   		System.AssertEquals(1, acadList.size());
   		
   		try{
   			delete acad;
   		}catch(Exception e){
   			
   		}
   		 acadList = [Select id from Academic_Program__c where id = :acad.id or Name = 'Test Acad Program'];
   		 System.AssertEquals(1, acadList.size());
        }
    }
    static testMethod void checkSucessDelete(){
    	Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    
    	Account school = new Account();
        school.Name = 'School';
        insert school;
        
    	/**Program_Master__c pm = new Program_Master__c();
    	pm.Name = 'Test Name';
    	pm.Degree_Type__c = 'Certificate';
    	pm.Abbreviation__c = 'MS';
    	insert pm;**/
    	
        Academic_Program__c acad = new Academic_Program__c();
    	//acad.Program_Master__c = pm.id;
    	acad.School__c = school.id;
    	acad.Name = 'Test Acad Program';
    	insert acad;
    	
    	List<Academic_Program__c> acadList = [Select id from Academic_Program__c where id = :acad.id or Name = 'Test Acad Program'];
   		System.AssertEquals(1, acadList.size());
   		
   		try{
   			delete acad;
   		}catch(Exception e){
   			
   		}
   		 acadList = [Select id from Academic_Program__c where id = :acad.id or Name = 'Test Acad Program'];
   		 System.AssertEquals(0, acadList.size());
   	 }
   		 
   		
    }
}