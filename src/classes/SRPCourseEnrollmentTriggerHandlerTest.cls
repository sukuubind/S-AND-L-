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
private class SRPCourseEnrollmentTriggerHandlerTest {

    static testMethod void testScheduleCourseEnrollmentJob(){
    	Test.starttest();
		SRPCourseEnrollmentUpdateBatch courseEnrollmentBatch = new SRPCourseEnrollmentUpdateBatch();
		Database.executeBatch(courseEnrollmentBatch);
		Test.stopTest();
    }

    static testMethod void myUnitTest() {
         Account a = new Account();
	    	a.Name = 'Test Account';
	    	insert a;
	    	
	    	DeltakSRP__Academic_Program__c testProgram = new DeltakSRP__Academic_Program__c(
	    	DeltakSRP__Active__c = true,
	    	Name = 'test Program',
	    	DeltakSRP__School__c = a.Id
	    	);
	    	Database.insert(testProgram);
    	
    	 	
    	
    	// Create an Academic Course with the Academic Program set as primary
	    	DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
	    		DeltakSRP__Academic_Institution__c = 	a.Id,
	    		DeltakSRP__Active__c = true,
	    		DeltakSRP__Course_Units__c = 3,
	    		DeltakSRP__Primary_Program__c = testProgram.Id,
	    		Name = 'testCourseRecord'
	    	);
			Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse});
		
	    	// Create an Academic Start Date
	    	DeltakSRP__Academic_Start_Date__c testTerm = new DeltakSRP__Academic_Start_Date__c(
		    	DeltakSRP__Start_Date__c = Date.today(),
		    	DeltakSRP__End_Date__c = Date.today().addDays(120),
		    	DeltakSRP__Term_Label__c = '2014 Winter'
	    	);
	    	Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{testTerm});
    	
	    	// Create an Academic Section
	    	DeltakSRP__Academic_Section__c testSection = new DeltakSRP__Academic_Section__c(
		    	DeltakSRP__Academic_Course__c = testCourse.Id,
		    	DeltakSRP__Academic_Term__c = testTerm.Id,
		    	Start_Date__c = Date.valueOf('2015-10-10'),
		    	DeltakSRP__Section_ID__c = '123456789'
	    	);
	    	Database.insert(New List<DeltakSRP__Academic_Section__c>{testSection});
	    	
	    	RecordType crecord = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        Contact c = new Contact ();
	        c.AccountId = a.Id;
	        c.FirstName='Joe';
	        c.LastName='Smith';
	        c.Phone='2222222222';
	        c.AccountId = a.Id;   
	        c.Employer_Company__c = '';
	        c.RecordTypeId = crecord.id;
	        c.DeltakSRP__Student_ID__c = 'STU12345';
	        c.Earliest_Term_Start_Date__c = Date.valueOf('2015-10-27');
	    	insert c;
	    	
	    	Opportunity o = new Opportunity();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
            o.CloseDate=d;
            o.DeltakSRP__Student__c = c.id;
            o.AccountId = a.id;
            o.StageName='New Inquiry';
	    	
	    	DeltakSRP__Program_Enrollment__c testProgEnrollment = new DeltakSRP__Program_Enrollment__c(
		    	DeltakSRP__Academic_Program__c = testProgram.Id,
		    	DeltakSRP__Enrolled_Student__c = c.Id,
		    	DeltakSRP__Enrollment_Status__c = 'Graduate',
		    	DeltakSRP__Enrollment_Start__c = testTerm.Id,
		    	DeltakSRP__Opportunity__c = o.id,
		    	DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId()
	    	);
	    	Database.insert(testProgEnrollment);
	        
	        DeltakSRP__Curriculum_Plan__c testcplan = new DeltakSRP__Curriculum_Plan__c();
	        testcplan.deltakSRP__Student__c = c.id;
	        testcplan.DeltakSRP__active__c = true;
	        insert testcplan;
	        
	        DeltakSRP__Curriculum_Plan_Entry__c testcplanentry = new DeltakSRP__Curriculum_Plan_Entry__c();
	        //testcplanentry.DeltakSRP__Enrollment_Status__c = 'Complete';
	        testcplanentry.DeltakSRP__Student_Curriculum_Plan__c = testcplan.id;
	        testcplanentry.DeltakSRP__Academic_Program__c = testProgram.Id;
	        testcplanentry.DeltakSRP__Academic_Course__c = testcourse.id;
	        //testcplan.DeltakSRP__Course_Enrollment__c = testenrollment1.id;
	        insert testcplanentry;
	        
	    	DeltakSRP__Course_Enrollment__c testEnrollment1 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = c.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'C',
	    	DeltakSRP__Status__c = 'Enrolled',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
			);
    		Database.insert(testEnrollment1);
    		    
    		List<DeltakSRP__Course_Enrollment__c> insCE = [Select Id, DeltakSRP__Academic_Section__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Section__r.Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c from DeltakSRP__Course_Enrollment__c where id = : testEnrollment1.id limit 1];
    		Id updCEId = null;
    		for(DeltakSRP__Course_Enrollment__c iCE: insCE)
    		{
    			updCEId = iCE.id;
    		}
    		
    		DeltakSRP__Course_Enrollment__c testEnrollmentUpd = new DeltakSRP__Course_Enrollment__c(id=updCEId);
    		testEnrollmentUpd.DeltakSRP__Status__c = 'Complete';
    		Database.update(testEnrollmentUpd); 

    		SRPCourseEnrollmentTriggerHandler.updateNumberOfTermsOutOnContact_Schedule(insCE);
    		
    		/*List<DeltakSRP__Course_Enrollment__c> updatedCE = [select id, DeltakSRP__Student_ID__c from DeltakSRP__Course_Enrollment__c limit 1];
    		system.debug('updatedCE-->'+updatedCE.size());
    		Database.delete(updatedCE, false);*/
    		
    		//SRPCourseEnrollmentTriggerHandler.handleAfterDelete(updatedCE);
    		//Database.delete(testEnrollmentDel);
    		
    }
}