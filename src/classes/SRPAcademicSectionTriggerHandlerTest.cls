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
private class SRPAcademicSectionTriggerHandlerTest {

    static testMethod void myUnitTest() {
    	
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
		
		Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'UOB';
        a.name = 'test account';
        insert a;
    	
    	DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        ap.DeltakSRP__SIS_External_Id__c = 'AP12345';
        insert ap;
    	
        DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
	    		DeltakSRP__Academic_Institution__c = 	a.Id,
	    		DeltakSRP__Active__c = true,
	    		DeltakSRP__Course_Units__c = 3,
	    		DeltakSRP__Course_Id__c = 'AC12345',
	    		DeltakSRP__SIS_External_Id__c = 'UOB - AP12345 - AC12345',
	    		DeltakSRP__Primary_Program__c = ap.id,
	    		Name = 'testCourseRecord'
	    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse});	
		system.debug('testcourse.DeltakSRP__SIS_External_Id__c>>>>'+testcourse.id+'>>>>'+testcourse.DeltakSRP__SIS_External_Id__c);
		
		
		
		DeltakSRP__Academic_Start_Date__c ast = new DeltakSRP__Academic_Start_Date__c(
		    	DeltakSRP__Start_Date__c = system.today(),
		    	DeltakSRP__End_Date__c = Date.today().addDays(120),
		    	DeltakSRP__Term_Label__c = '2014 Winter',
		    	DeltakSRP__Academic_Program__c = ap.id
	    	);
	    Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{ast});
	    system.debug('ast.DeltakSRP__SIS_External_Id__c>>>>'+ast.id+'>>>>'+ast.DeltakSRP__SIS_External_Id__c);
		
		test.starttest();
		DeltakSRP__Academic_Section__c asec = new DeltakSRP__Academic_Section__c(
		    	DeltakSRP__Section_ID__c = 'ASEC12345', 
		    	DeltakSRP__SIS_External_Id__c = 'UOB-ASEC12345-AC12345-'+system.today().year()+'-'+ system.today().month()+'-'+ system.today().day()+'-AP12345',
		    	start_date__c = system.today(),
		    	program_SIS_Id__c = 'AP12345',
		    	Term_SIS_ID__c = 'AT12345'
	    	);
	    system.debug('asec.DeltakSRP__SIS_External_Id__c>>>>'+asec.DeltakSRP__SIS_External_Id__c);	
	    Database.insert(New List<DeltakSRP__Academic_Section__c>{asec});
	    
	    
	    DeltakSRP__Academic_Section__c asec2 = new DeltakSRP__Academic_Section__c(
		    	DeltakSRP__Section_ID__c = 'ASEC12345',
		    	DeltakSRP__SIS_External_Id__c = 'UOB-ASEC12345-AC12345-'+system.today().year()+'-'+ system.today().month()+'-'+ system.today().day()+'-AP12345',
		    	start_date__c = system.today(),
		    	program_SIS_Id__c = 'AP12345',
		    	Term_SIS_ID__c = 'AT123456'
	    	);
	    system.debug('asec.DeltakSRP__SIS_External_Id__c>>>>'+asec.DeltakSRP__SIS_External_Id__c);	
	    Database.insert(New List<DeltakSRP__Academic_Section__c>{asec2});
	    
	    SRPAcademicSectionTriggerHandler.inserterrorlog('testErrorMessage','testErrorObject','SRPAcademicSectionTriggerHandlerTest');
	    
	    test.stoptest();
    }
}