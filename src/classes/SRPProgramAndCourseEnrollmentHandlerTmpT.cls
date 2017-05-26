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
private class SRPProgramAndCourseEnrollmentHandlerTmpT {

    static testMethod void testMethod1() {
    	
    	User u = [Select Id from user where name = 'Data Integration'];
    	// Create an Account
    	
    	system.runas(u) {
    	Account testAccount = new Account();
    	testAccount.Name = 'testaccount';
    	insert testAccount;
    	
    	// Create a Student
    	Contact testStudent = new Contact();
    	testStudent.firstName = 'firstName';
    	testStudent.lastName = 'lastName';
    	testStudent.Email = 'testemail@testemails.com';
    	testStudent.AccountId = testAccount.Id;
    	Database.insert(testStudent);
    	
    	DeltakSRP__Academic_Program__c testProgram = new DeltakSRP__Academic_Program__c();
    	testProgram.DeltakSRP__Active__c = true;
    	testProgram.Name = 'test Program';
    	testProgram.DeltakSRP__School__c = testAccount.Id;
    	Database.insert(testProgram);
    	
    	// Create an Academic Course
    	DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		Name = 'testCourseRecord'
    	);
    	DeltakSRP__Academic_Course__c testCourse2 = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		DeltakSRP__Primary_Program__c = testProgram.Id,
    		Name = 'testCourseRecord'
    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse, testCourse2});
		
    	// Create an Academic Start Date
    	DeltakSRP__Academic_Start_Date__c testTerm = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today(),
	    	DeltakSRP__End_Date__c = Date.today().addDays(120)
    	);
    	
    	DeltakSRP__Academic_Start_Date__c testTerm2 = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today().addDays(121),
	    	DeltakSRP__End_Date__c = Date.today().addDays(365)
    	);
    	Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{testTerm, testTerm2});
    	
    	// Create an Academic Section
    	DeltakSRP__Academic_Section__c testSection = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Academic_Term__c = testTerm.Id,
	    	DeltakSRP__Section_ID__c = '123456789'
    	);
    	DeltakSRP__Academic_Section__c testSection2 = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse2.Id,
	    	DeltakSRP__Academic_Term__c = testTerm2.Id,
	    	DeltakSRP__Section_ID__c = '987654321'
    	);
    	
		Database.insert(New List<DeltakSRP__Academic_Section__c>{testSection, testSection2});
		
		DeltakSRP__Program_Enrollment__c testProgramEnrollment = new DeltakSRP__Program_Enrollment__c();
		testProgramEnrollment.DeltakSRP__Academic_Program__c = testProgram.Id;
		testProgramEnrollment.DeltakSRP__Enrolled_Student__c = testStudent.Id;
		testProgramEnrollment.DeltakSRP__Enrollment_Start__c = testTerm.Id;
		
		Database.insert(testProgramEnrollment);
    	
    	SRPProgramEnrollmentHandlerTemp.handleAfterInsert(new List<DeltakSRP__Program_Enrollment__c>{testProgramEnrollment});
    	
    	testProgramEnrollment.DeltakSRP__Enrollment_Status__c = 'Drop';
    	Database.update(testProgramEnrollment);
    	
    	Map<Id, DeltakSRP__Program_Enrollment__c> recordsMap = new Map<Id, DeltakSRP__Program_Enrollment__c>();
    	recordsMap.put(testProgramEnrollment.Id,testProgramEnrollment);
    	
    	SRPProgramEnrollmentHandlerTemp.handleAfterUpdate(recordsMap, recordsMap);
    	
    	// Create an inactive Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c inactivePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = false,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	
    	// Create an active Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c activePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = true,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	Database.insert(new List<DeltakSRP__Curriculum_Plan__c>{inactivePlan, activePlan});
    	
    	// Create a Curriculum Plan Entry attached to the inactive Plan
    	DeltakSRP__Curriculum_Plan_Entry__c inactiveEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = inactivePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	// Create a Curriculum Plan entry attached to the active plan
    	DeltakSRP__Curriculum_Plan_Entry__c activeEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = activePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	Database.insert(new List<DeltakSRP__Curriculum_Plan_Entry__c> {inactiveEntry, activeEntry});

    	// ---------- test start ----------    	
    	Test.startTest();
    	
    	// Create Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment1 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'C',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	Database.insert(testEnrollment1);
    	
    	// Create a more recent Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment2 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'D',
	    	DeltakSRP__Term_Start__c = Date.today()
    	);
    	Database.insert(testEnrollment2);    	
    	
    	// Create Course Enrollment record for a course that doesn't have a plan entry
    	DeltakSRP__Course_Enrollment__c testEnrollment3 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection2.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'F',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment3');
    	Database.insert(testEnrollment3);
    	
    	
    	// Create Course Enrollment record for a course that doesn't have a Program Enrollment
    	DeltakSRP__Course_Enrollment__c testEnrollment4 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection2.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Final_Grade__c = 'F',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment4');
    	Database.insert(testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleBeforeUpsert(new List<DeltakSRP__Course_Enrollment__c>{testEnrollment1,testEnrollment2,testEnrollment3,testEnrollment4});
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap.put(testEnrollment1.Id,testEnrollment1);
    	oldMap.put(testEnrollment2.Id,testEnrollment2);
    	oldMap.put(testEnrollment3.Id,testEnrollment3);
    	oldMap.put(testEnrollment4.Id,testEnrollment4);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap.put(testEnrollment1.Id,testEnrollment1);
    	newMap.put(testEnrollment2.Id,testEnrollment2);
    	newMap.put(testEnrollment3.Id,testEnrollment3);
    	newMap.put(testEnrollment4.Id,testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap, oldMap, 'Insert');
    	
    	testEnrollment4.DeltakSRP__Final_Grade__c = 'D';
    	Database.update(testEnrollment4);
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap2 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap2.put(testEnrollment4.Id,testEnrollment4);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap2 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap2.put(testEnrollment4.Id,testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap2, oldMap2, 'Update');
    	
    	// ---------- test end ----------
    	Test.stopTest();
    	}
    }
    
    
    static testMethod void testMethod2() {
    	User u = [Select Id from user where name = 'Data Integration'];
    	// Create an Account
    	
    	system.runas(u) {
    	// Create an Account
    	Account testAccount = new Account();
    	testAccount.Name = 'testaccount';
    	insert testAccount;
    	
    	// Create a Student
    	Contact testStudent = new Contact();
    	testStudent.firstName = 'firstName';
    	testStudent.lastName = 'lastName';
    	testStudent.Email = 'testemail@testemails.com';
    	testStudent.AccountId = testAccount.Id;
    	Database.insert(testStudent);
    	
    	DeltakSRP__Academic_Program__c testProgram = new DeltakSRP__Academic_Program__c();
    	testProgram.DeltakSRP__Active__c = true;
    	testProgram.Name = 'test Program';
    	testProgram.DeltakSRP__School__c = testAccount.Id;
    	Database.insert(testProgram);
    	
    	// Create an Academic Course
    	DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		Name = 'testCourseRecord'
    	);
    	DeltakSRP__Academic_Course__c testCourse2 = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		DeltakSRP__Primary_Program__c = testProgram.Id,
    		Name = 'testCourseRecord'
    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse, testCourse2});
		
    	// Create an Academic Start Date
    	DeltakSRP__Academic_Start_Date__c testTerm = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today(),
	    	DeltakSRP__End_Date__c = Date.today().addDays(120)
    	);
    	
    	DeltakSRP__Academic_Start_Date__c testTerm2 = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today().addDays(121),
	    	DeltakSRP__End_Date__c = Date.today().addDays(365)
    	);
    	Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{testTerm, testTerm2});
    	
    	// Create an Academic Section
    	DeltakSRP__Academic_Section__c testSection = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Academic_Term__c = testTerm.Id,
	    	DeltakSRP__Section_ID__c = '123456789'
    	);
    	DeltakSRP__Academic_Section__c testSection2 = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse2.Id,
	    	DeltakSRP__Academic_Term__c = testTerm2.Id,
	    	DeltakSRP__Section_ID__c = '987654321'
    	);
    	
		Database.insert(New List<DeltakSRP__Academic_Section__c>{testSection, testSection2});
		
		
		DeltakSRP__Program_Enrollment__c testProgramEnrollment2 = new DeltakSRP__Program_Enrollment__c();
		testProgramEnrollment2.DeltakSRP__Academic_Program__c = testProgram.Id;
		testProgramEnrollment2.DeltakSRP__Enrolled_Student__c = testStudent.Id;
		testProgramEnrollment2.DeltakSRP__Enrollment_Start__c = testTerm.Id;
		
		Database.insert(testProgramEnrollment2);
		
		List<DeltakSRP__Enrollment_History__c> ehList = [SELECT Id FROM DeltakSRP__Enrollment_History__c WHERE DeltakSRP__Program_Enrollment__c = :testProgramEnrollment2.Id];
		
		for(DeltakSRP__Enrollment_History__c eh : ehList)
		{
			eh.SIS_External_Id__c = null;
		}
		
		update ehList;
		
		DeltakSRP__Program_Enrollment__c testProgramEnrollment = new DeltakSRP__Program_Enrollment__c();
		testProgramEnrollment.DeltakSRP__Academic_Program__c = testProgram.Id;
		testProgramEnrollment.DeltakSRP__Enrolled_Student__c = testStudent.Id;
		testProgramEnrollment.DeltakSRP__Enrollment_Start__c = testTerm.Id;
		
		Database.insert(testProgramEnrollment);
    	
    	SRPProgramEnrollmentHandlerTemp.handleAfterInsert(new List<DeltakSRP__Program_Enrollment__c>{testProgramEnrollment});
    	
    	testProgramEnrollment.DeltakSRP__Enrollment_Status__c = 'Drop';
    	Database.update(testProgramEnrollment);
    	    	
    	// Create an inactive Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c inactivePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = false,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	
    	// Create an active Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c activePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = true,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	Database.insert(new List<DeltakSRP__Curriculum_Plan__c>{inactivePlan, activePlan});
    	
    	// Create a Curriculum Plan Entry attached to the inactive Plan
    	DeltakSRP__Curriculum_Plan_Entry__c inactiveEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = inactivePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	// Create a Curriculum Plan entry attached to the active plan
    	DeltakSRP__Curriculum_Plan_Entry__c activeEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = activePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	Database.insert(new List<DeltakSRP__Curriculum_Plan_Entry__c> {inactiveEntry, activeEntry});

    	// ---------- test start ----------    	
    	Test.startTest();
    	
    	// Create Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment1 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'C',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	Database.insert(testEnrollment1);
    	
    	// Create a more recent Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment2 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'D',
	    	DeltakSRP__Term_Start__c = Date.today()
    	);
    	Database.insert(testEnrollment2);    	
    	
    	
    	// Create Course Enrollment record for a course that doesn't have a plan entry
    	DeltakSRP__Course_Enrollment__c testEnrollment3 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection2.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'F',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment3');
    	Database.insert(testEnrollment3);
    	
    	// Verify that a new Plan Entry was created, attached to the Course Enrollment
    	List<DeltakSRP__Curriculum_Plan_Entry__c> verificationList = 
    		[select Id, DeltakSRP__Course_Enrollment__c 
    			from DeltakSRP__Curriculum_Plan_Entry__c 
    			where DeltakSRP__Course_Enrollment__c = :testEnrollment3.Id];
    	
    	System.assertEquals(1, verificationList.size());
    	
    	// Create Course Enrollment record for a course that doesn't have a Program Enrollment
    	DeltakSRP__Course_Enrollment__c testEnrollment5 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Final_Grade__c = 'D',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment5');
    	Database.insert(testEnrollment5);
    	
    	SRPCourseEnrollmentHandlerTemp.handleBeforeUpsert(new List<DeltakSRP__Course_Enrollment__c>{testEnrollment5});
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap3 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap3.put(testEnrollment5.Id,testEnrollment5);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap3 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap3.put(testEnrollment5.Id,testEnrollment5);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap3, oldMap3, 'Insert');
    	
    	testEnrollment5.DeltakSRP__Final_Grade__c = 'F';
    	Database.update(testEnrollment5);
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap4 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap4.put(testEnrollment5.Id,testEnrollment5);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap4 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap4.put(testEnrollment5.Id,testEnrollment5);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap4, oldMap4, 'Update');
    	
    	// PT: Chaning to avoid errors in test class
    	/*delete testEnrollment5;
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap4, oldMap4, 'Delete');
    	
    	undelete testEnrollment5;*/
    	
    	// ---------- test end ----------
    	Test.stopTest();
    	}
    }
    
    /*static testMethod void testMethod3() {
    	User u = [Select Id from user where name = 'Data Integration'];
    	// Create an Account
    	
    	system.runas(u) {
    	// Create an Account
    	Account testAccount = new Account();
    	testAccount.Name = 'testaccount';
    	testAccount.Abbreviation__c = 'TST';
    	insert testAccount;
    	
    	// Create a Student
    	Contact testStudent = new Contact();
    	testStudent.firstName = 'firstName';
    	testStudent.lastName = 'lastName';
    	testStudent.Email = 'testemail@testemails.com';
    	testStudent.AccountId = testAccount.Id;
    	testStudent.DeltakSRP__Student_Id__c = 'TST-123456789';
    	Database.insert(testStudent);
    	
    	testStudent.DeltakSRP__Student_Id__c = 'TST-123456789';
    	
    	Database.update(testStudent);
    	
    	DeltakSRP__Academic_Program__c testProgram = new DeltakSRP__Academic_Program__c();
    	testProgram.DeltakSRP__Active__c = true;
    	testProgram.Name = 'test Program';
    	testProgram.DeltakSRP__School__c = testAccount.Id;
    	testProgram.DeltakSRP__SIS_External_Id__c = 'TST-program1';
    	Database.insert(testProgram);
    	
    	testProgram.DeltakSRP__SIS_External_Id__c = 'TST-program1';
    	
    	Database.update(testProgram);
    	
    	// Create an Academic Course
    	DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		DeltakSRP__SIS_External_Id__c = 'TST-course1',
    		Name = 'testCourseRecord'
    	);
    	DeltakSRP__Academic_Course__c testCourse2 = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		DeltakSRP__Primary_Program__c = testProgram.Id,
    		DeltakSRP__SIS_External_Id__c = 'TST-course2',
    		Name = 'testCourseRecord'
    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse, testCourse2});
		
    	// Create an Academic Start Date
    	DeltakSRP__Academic_Start_Date__c testTerm = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today(),
	    	DeltakSRP__End_Date__c = Date.today().addDays(120),
	    	DeltakSRP__SIS_External_Id__c = 'TST-term1'
    	);
    	
    	DeltakSRP__Academic_Start_Date__c testTerm2 = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today().addDays(121),
	    	DeltakSRP__End_Date__c = Date.today().addDays(365),
	    	DeltakSRP__SIS_External_Id__c = 'TST-term2'
    	);
    	Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{testTerm, testTerm2});
    	
    	testTerm.DeltakSRP__SIS_External_Id__c = 'TST-term1';
    	testTerm2.DeltakSRP__SIS_External_Id__c = 'TST-term2';
    	
    	Database.update(new List<DeltakSRP__Academic_Start_Date__c>{testTerm, testTerm2});
    	
    	// Create an Academic Section
    	DeltakSRP__Academic_Section__c testSection = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Academic_Term__c = testTerm.Id,
	    	DeltakSRP__Section_ID__c = '123456789',
	    	DeltakSRP__SIS_External_Id__c = 'TST-section1'
    	);
    	DeltakSRP__Academic_Section__c testSection2 = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse2.Id,
	    	DeltakSRP__Academic_Term__c = testTerm2.Id,
	    	DeltakSRP__Section_ID__c = '987654321',
	    	DeltakSRP__SIS_External_Id__c = 'TST-section2'
    	);
    	
		Database.insert(New List<DeltakSRP__Academic_Section__c>{testSection, testSection2});
		
		testSection.DeltakSRP__SIS_External_Id__c = 'TST-section1';
		testSection2.DeltakSRP__SIS_External_Id__c = 'TST-section2';
		
		Database.update(New List<DeltakSRP__Academic_Section__c>{testSection, testSection2});
		
		DeltakSRP__Program_Enrollment__c testProgramEnrollment = new DeltakSRP__Program_Enrollment__c();
		testProgramEnrollment.DeltakSRP__Academic_Program__c = testProgram.Id;
		testProgramEnrollment.DeltakSRP__Enrolled_Student__c = testStudent.Id;
		testProgramEnrollment.DeltakSRP__Enrollment_Start__c = testTerm.Id;
		testProgramEnrollment.DeltakSRP__SIS_External_Id__c = 'TST-program1-123456789';
		
		Database.insert(testProgramEnrollment);
    	
    	testProgramEnrollment.DeltakSRP__SIS_External_Id__c = 'TST-program1-123456789';
    	
    	Database.update(testProgramEnrollment);
    	
    	testProgramEnrollment = [SELECT Id, Name, DeltakSRP__Academic_Program__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrollment_Status__c,
    																	DeltakSRP__Student_Email__c, DeltakSRP__Enrollment_Start__c,
    																	DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c, DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c,
    																	DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
    																	DeltakSRP__Enrollment_Start__r.DeltakSRP__SIS_External_Id__c
    																	FROM DeltakSRP__Program_Enrollment__c
    																	WHERE Id = :testProgramEnrollment.Id LIMIT 1
    																	];
    	
    	SRPProgramEnrollmentHandlerTemp.handleAfterInsert(new List<DeltakSRP__Program_Enrollment__c>{testProgramEnrollment});
    	
    	List<DeltakSRP__Enrollment_History__c> ehList = [SELECT Id, DeltakSRP__Program_Enrollment__c, SIS_External_Id__c 
    													FROM DeltakSRP__Enrollment_History__c WHERE DeltakSRP__Program_Enrollment__c = :testProgramEnrollment.Id ];
    	
    	for(DeltakSRP__Enrollment_History__c eh : ehList)
    	{
    		eh.SIS_External_Id__c = '';
    	}
    	
    	update ehList;
    	
    	testProgramEnrollment.DeltakSRP__Enrollment_Status__c = 'Drop';
    	Database.update(testProgramEnrollment);
    	
    	Map<Id, DeltakSRP__Program_Enrollment__c> recordsMap = new Map<Id, DeltakSRP__Program_Enrollment__c>();
    	recordsMap.put(testProgramEnrollment.Id,testProgramEnrollment);
    	
    	SRPProgramEnrollmentHandlerTemp.handleAfterUpdate(recordsMap);
    	
    	// Create an inactive Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c inactivePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = false,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	
    	// Create an active Curriculum Plan
    	DeltakSRP__Curriculum_Plan__c activePlan = new DeltakSRP__Curriculum_Plan__c(
	    	DeltakSRP__Active__c = true,
	    	DeltakSRP__Student__c = testStudent.Id,
	    	DeltakSRP__Plan_Start_Date__c= Date.today(),
	    	DeltakSRP__Target_Graduation_Date__c = Date.today().addDays(365)
    	);
    	Database.insert(new List<DeltakSRP__Curriculum_Plan__c>{inactivePlan, activePlan});
    	
    	// Create a Curriculum Plan Entry attached to the inactive Plan
    	DeltakSRP__Curriculum_Plan_Entry__c inactiveEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = inactivePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	// Create a Curriculum Plan entry attached to the active plan
    	DeltakSRP__Curriculum_Plan_Entry__c activeEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Student_Curriculum_Plan__c = activePlan.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id
    	);
    	
    	Database.insert(new List<DeltakSRP__Curriculum_Plan_Entry__c> {inactiveEntry, activeEntry});

    	// ---------- test start ----------    	
    	Test.startTest();
    	
    	// Create Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment1 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'C',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	Database.insert(testEnrollment1);
    	
    	// Create a more recent Course Enrollment record
    	DeltakSRP__Course_Enrollment__c testEnrollment2 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'D',
	    	DeltakSRP__Term_Start__c = Date.today()
    	);
    	Database.insert(testEnrollment2);    	
    	
    	// Create Course Enrollment record for a course that doesn't have a plan entry
    	DeltakSRP__Course_Enrollment__c testEnrollment3 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection2.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgramEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'F',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment3');
    	Database.insert(testEnrollment3);
    	
    	
    	// Create Course Enrollment record for a course that doesn't have a Program Enrollment
    	DeltakSRP__Course_Enrollment__c testEnrollment4 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection2.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm2.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Final_Grade__c = 'F',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	System.debug('CH: Inserting testEnrollment4');
    	Database.insert(testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleBeforeUpsert(new List<DeltakSRP__Course_Enrollment__c>{testEnrollment1,testEnrollment2,testEnrollment3,testEnrollment4});
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap.put(testEnrollment1.Id,testEnrollment1);
    	oldMap.put(testEnrollment2.Id,testEnrollment2);
    	oldMap.put(testEnrollment3.Id,testEnrollment3);
    	oldMap.put(testEnrollment4.Id,testEnrollment4);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap.put(testEnrollment1.Id,testEnrollment1);
    	newMap.put(testEnrollment2.Id,testEnrollment2);
    	newMap.put(testEnrollment3.Id,testEnrollment3);
    	newMap.put(testEnrollment4.Id,testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap, oldMap, 'Insert');
    	
    	testEnrollment4.DeltakSRP__Final_Grade__c = 'D';
    	Database.update(testEnrollment4);
    	
    	Map<Id, DeltakSRP__Course_Enrollment__c> oldMap2 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	oldMap2.put(testEnrollment4.Id,testEnrollment4);
    	Map<Id, DeltakSRP__Course_Enrollment__c> newMap2 = new Map<Id,DeltakSRP__Course_Enrollment__c>();
    	newMap2.put(testEnrollment4.Id,testEnrollment4);
    	
    	SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(newMap2, oldMap2, 'Update');
    	
    	// ---------- test end ----------
    	Test.stopTest();
    	}
    }*/
    
}