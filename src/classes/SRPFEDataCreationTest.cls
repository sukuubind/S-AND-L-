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
private class SRPFEDataCreationTest {

    static testMethod void testFEDataCreationTest() {
        Test.startTest();
        SRPFEDataCreation fed = new SRPFEDataCreation();
        Database.executeBatch(fed);
        Test.stopTest();
    }
    static testMethod void testFEDataCreationMissingTest(){
    	Test.startTest();
    	SRPFEDataCreationMissing missingFed = new SRPFEDataCreationMissing();
    	Database.executeBatch(missingFed);
    	Test.stopTest();
    }
    static testMethod void testHistoricalRollForwardCreationTest(){
    	Test.startTest();
    	SRPFutureEnrollmentDataCreation futEnrDatCre = new SRPFutureEnrollmentDataCreation();
    	Database.executeBatch(futEnrDatCre);
    	Test.stopTest();
    }
    static testMethod void testHistoricalRollForwardCreationMissingTest(){
    	Test.starttest();
		SRPFutureEnrollmentDataCreationMissing futEnrDatCre_missing = new SRPFutureEnrollmentDataCreationMissing();
		Database.executeBatch(futEnrDatCre_missing);
		Test.stopTest();
    }
    static testMethod void testEHUpdate(){
    	Test.starttest();
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
      
      
      
      
		
		
		SRPEHUpdateForReporting ehUpdateTest = new SRPEHUpdateForReporting();
		Database.executeBatch(ehUpdateTest);
		Test.stopTest();
    }
}