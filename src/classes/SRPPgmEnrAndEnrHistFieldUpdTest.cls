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
private class SRPPgmEnrAndEnrHistFieldUpdTest {


    
    private static Account institution = New Account();
    private static Contact student = New Contact();
    private static DeltakSRP__Academic_Program__c program = New DeltakSRP__Academic_Program__c();
    private static DeltakSRP__Academic_Start_Date__c termOld = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termCurrent = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termNext = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Program_Enrollment__c enrollment = New DeltakSRP__Program_Enrollment__c();
    

    static testMethod void Test_ProgramEnrollmentReturnAndReenter() {
        
        TestInit();

        Test.startTest();
        
        DeltakSRP__Program_Enrollment__c peBefore = [SELECT id, DeltakSRP__Student_Email__c, DeltakSRP__Student_Services_Coordinator__c, DeltakSRP__Advisor_Email__c, DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        DeltakSRP__Program_Enrollment__c peUpd1 = new DeltakSRP__Program_Enrollment__c(id=enrollment.id);
        peUpd1.DeltakSRP__Student_Services_Coordinator__c = '00532000004zkDE';
        
        Database.update(peUpd1,false);
        
        DeltakSRP__Enrollment_History__c historyOld = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termOld.id, enrollment.Id, student.id).Get(0);
        insert historyOld;
        
        enrollment = [SELECT id, DeltakSRP__Student_Email__c, DeltakSRP__Student_Services_Coordinator__c, DeltakSRP__Advisor_Email__c, DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals('New', enrollment.DeltakSRP__Enrollment_Status__c);
        
        DeltakSRP__Program_Enrollment__c peUpd = new DeltakSRP__Program_Enrollment__c(id=enrollment.id);
        peUpd.DeltakSRP__Student_Email__c = null;
        peUpd.DeltakSRP__Advisor_Email__c = null;
        Database.update(peUpd,false);
        
        DeltakSRP__Enrollment_History__c ehUpd = new DeltakSRP__Enrollment_History__c(id = historyOld.id);
        ehUpd.DeltakSRP__Student_Email__c = null;
        ehUpd.DeltakSRP__Advisor_Email__c = null;
        Database.update(ehUpd,false);
        
        Test.stopTest();
        
    }
    
    public static void TestInit(){
        institution = TestObjectFactory.CreateAccount(1).Get(0);
        insert institution;
        
        student = TestObjectFactory.CreateContact(1,institution.id).Get(0);
        student.DeltakSRP__Student_Email__c = 'testPE@nomail.com';
        insert Student;
        
        program = TestObjectFactory.CreateAcademicProgram(1, institution.id).Get(0);
        insert program;
        
        termOld = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() - 60).Get(0);
        insert termOld;
        
        termCurrent = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() - 10).Get(0);
        insert termCurrent;
        
        termNext = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() + 10).Get(0);
        insert termNext;
        
        enrollment = TestObjectFactory.CreateProgramEnrollment(1, program.Id, student.Id, termOld.id, 'New').Get(0);
        insert enrollment; 
    }
      

}