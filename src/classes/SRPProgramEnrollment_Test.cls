@isTest(seealldata=true)
public class SRPProgramEnrollment_Test {
    
    private static Account institution = New Account();
    private static Contact student = New Contact();
    private static DeltakSRP__Academic_Program__c program = New DeltakSRP__Academic_Program__c();
    private static DeltakSRP__Academic_Start_Date__c termOld = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termCurrent = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termNext = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Program_Enrollment__c enrollment = New DeltakSRP__Program_Enrollment__c();
        
        
    
    
    static testMethod void Test_ProgramEnrollmentDropBatch() {
            
        TestInit();

        DeltakSRP__Enrollment_History__c historyCurrent = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termCurrent.id, enrollment.Id,student.id).Get(0);
        insert historyCurrent;
        
        Test.startTest();         
         
        SRPProgramEnrollmentDropBatch b = new SRPProgramEnrollmentDropBatch('SELECT id, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c FROM DeltakSRP__Program_Enrollment__c WHERE id = \'' + enrollment.id + '\'');
        database.executebatch(b);

        Test.stopTest();
        
        enrollment = [SELECT DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals('Drop', enrollment.DeltakSRP__Enrollment_Status__c);
                                                                            
     }
    
    static testMethod void Test_SDChange_Roll_Scenarios(){
         TestInit();
         Test.startTest();
            DeltakSRP__Enrollment_History__c historyOld = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termOld.id, enrollment.Id, student.id).Get(0);
            insert historyOld;
            enrollment = [SELECT DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
            enrollment.DeltakSRP__Enrollment_Status__c = 'Roll';
            update enrollment;
         
            enrollment.DeltakSRP__Enrollment_Status__c = 'New';
            enrollment.DeltakSRP__Enrollment_Start__c = termNext.id;
            update enrollment; 


         Test.stopTest();
    }
    

    static testMethod void Test_ProgramEnrollmentReturnAndReenter() {
        
        TestInit();

        Test.startTest();
        
        DeltakSRP__Enrollment_History__c historyOld = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termOld.id, enrollment.Id, student.id).Get(0);
        insert historyOld;
        
        enrollment = [SELECT DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        System.assertEquals('New', enrollment.DeltakSRP__Enrollment_Status__c);
        
        DeltakSRP__Enrollment_History__c historyNext = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termNext.id, enrollment.Id, student.id).Get(0);
        insert historyNext;
        
        enrollment = [SELECT DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        //System.assertEquals('Re-enter', enrollment.DeltakSRP__Enrollment_Status__c);
        
        DeltakSRP__Enrollment_History__c historyCurrent = TestObjectFactory.CreateEnrollmentHistory(1, program.Id, termCurrent.id, enrollment.Id, student.id).Get(0);
        insert historyCurrent;
        
        enrollment = [SELECT DeltakSRP__Enrollment_Status__c FROM DeltakSRP__Program_Enrollment__c WHERE Id = :enrollment.Id];
        //System.assertEquals('Return', enrollment.DeltakSRP__Enrollment_Status__c);
        
        Test.stopTest();
        
    }
    
    Public static void TestInit(){
        institution = TestObjectFactory.CreateAccount(1).Get(0);
        insert institution;
        
        student = TestObjectFactory.CreateContact(1,institution.id).Get(0);
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