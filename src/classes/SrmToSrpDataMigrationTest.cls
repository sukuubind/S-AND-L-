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
private class SrmToSrpDataMigrationTest {

    static testMethod void myGMProgramsTest() {
        SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
        
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = true;
        
        testobj.runBatchUpdate();
    }  
    
    static testMethod void myEnrollmentDataTest() {
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = true;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void myPAdmTemplateTest() {  
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = true;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void AdmisiionDocsTest() {   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = true;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }  
    
    static testMethod void myPersonsTest() { 
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = true;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void fiscalCalendarTest() {   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	 
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = true;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void termsTest() {  
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = true;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void specializationTest() {   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
         testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = true;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void programsTest() {   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = true;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void OpportunityTest() { 
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	  
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = true;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void studentsTest() {  
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = true;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate(); 
    }
    
    
    static testMethod void TasksTest(){   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = false;
        testobj.updateTasks = true;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate();
    }
    
    static testMethod void EventsTest() {   
    	
    	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
    	
        testobj.updateusers = false;
        testobj.updatecampaigns = false;
        testobj.updateActivities = true;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate(); 
    }
    
     
     static testMethod void mycampaignsTest() {
     	
     	SrmToSrpDataMigration testobj = new SrmToSrpDataMigration();
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
        
        testobj.dummyContact = c;
     	
        testobj.updateusers = false;
        testobj.updatecampaigns = true;
        testobj.updateActivities = false;
        testobj.updateTasks = false;
        testobj.updateAffliations = false;
        testobj.updateOpportunities = false;
        testobj.updateAcademicPrograms = false;
        testobj.updateAcademicSpecialization = false;
        testobj.updateAcademicStartDate = false;
        testobj.updateFiscalCalendar = false;
        testobj.updatePerson = false;
        testobj.updateProgramAdmissionDocs = false;
        testobj.updateProgramAdmissionsTemplate = false;
        testobj.updateEnrollementData = false;
        testobj.updateGMTOSFPrograms = false;
        
        testobj.runBatchUpdate(); 
    }
}