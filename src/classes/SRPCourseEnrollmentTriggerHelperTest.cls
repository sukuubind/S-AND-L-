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
private class SRPCourseEnrollmentTriggerHelperTest {

    static testMethod void myUnitTest() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            
            Account a1 = [Select id, name, Abbreviation__c from Account where Abbreviation__c = 'UOB' limit 1];
            Account a = a1;
           /* a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'UOB1';
            a.name = 'test account';
            insert a;*/
            
            contact c = new Contact();
            c.FirstName = 'fname';
            c.LastName = 'lname';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt4.Id;
            c.DeltakSRP__Student_ID__c = 'STU12345';
            insert c;
             
            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            ap.DeltakSRP__SIS_External_Id__c = 'AP12345';
            insert ap;
            
            ap.DeltakSRP__SIS_External_Id__c = 'AP12345';
            update ap;
            
            DeltakSRP__Academic_Start_Date__c ast = new DeltakSRP__Academic_Start_Date__c(
                DeltakSRP__Start_Date__c = Date.today(),
                DeltakSRP__End_Date__c = Date.today().addDays(120),
                DeltakSRP__Term_Label__c = '2014 Winter',
                DeltakSRP__SIS_External_Id__c = 'AT12345'+String.valueOf(Date.today())
            );
            Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{ast});
            
            DeltakSRP__Academic_Course__c ac = new DeltakSRP__Academic_Course__c(
                DeltakSRP__Academic_Institution__c =    a.Id,
                DeltakSRP__Active__c = true,
                DeltakSRP__Course_Units__c = 3,
                DeltakSRP__Primary_Program__c = ap.Id,
                Name = 'testCourseRecord'
            );
            Database.insert(new List<DeltakSRP__Academic_Course__c> {ac});
            
            
            DeltakSRP__Academic_Section__c asec = new DeltakSRP__Academic_Section__c( 
                DeltakSRP__Academic_Course__c = ac.Id,
                DeltakSRP__Academic_Term__c = ast.Id,
                DeltakSRP__Section_ID__c = 'ASEC12345',
                DeltakSRP__SIS_External_Id__c = 'ASEC12345'
            );
            Database.insert(New List<DeltakSRP__Academic_Section__c>{asec});
            
            asec.DeltakSRP__SIS_External_Id__c = 'ASEC12345';
            update asec;

            List<DeltakSRP__Program_Enrollment__c> pelist = TestObjectFactory.CreateProgramEnrollment(1, ap.Id, c.Id, ast.id, 'New');
            insert pelist;
            
            Test.starttest();
                DeltakSRP__Course_Enrollment__c testCE = new DeltakSRP__Course_Enrollment__c();
                testCE.Student_External_Id__c = c.DeltakSRP__Student_ID__c;
                testCE.DeltakSRP__SIS_External_Id__c = 'UOB1-ASEC12345-CE12345-AT12345';
                insert testce;
                
                DeltakSRP__Course_Enrollment__c testCE2 = new DeltakSRP__Course_Enrollment__c();
                testCE2.Student_External_Id__c = c.DeltakSRP__Student_ID__c;
                testCE2.DeltakSRP__SIS_External_Id__c = 'UOB1-ASEC1234567-CE12345-AT12345';
                insert testce2;
            test.stoptest();
            
    }
}