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
public with sharing class SRPOpportunityTriggerHandlerTest {
	
	
	static testMethod void parentCampaignTest() { 
	
		// Create parent Campaign first
		Campaign parentCamp = new Campaign();
		parentCamp.Name = 'TestParentCampaign';
		parentCamp.campaign_code__c = '135';
	    insert parentCamp;
	
		// Create child campaign
		Campaign childCamp = new Campaign();
		childCamp.Name = 'TestChildCampaign';
		childCamp.campaign_code__c = '135';
		childCamp.ParentId = parentCamp.Id;
		childCamp.Lowest_Level_in_Hierarchy__c = true;
		insert childCamp;
		
		// Create new opportunity
		Opportunity o = new Opportunity();
	    o.Name = 'Test Opportunity';
	    o.CampaignId = childCamp.Id;
		o.StageName = 'New Inquiry';
		o.CloseDate = system.today()+100;
		o.LP_NOTES__c = 'Country_Of_Citizenship:USA\\|Type_Of_Law_Degree:TestType';
		
		// Start test before inserting opportunity as trigger is designed for running before inserting
		Test.startTest();
		insert o;
		Test.stopTest();
		
		// store value of parent name in list before checking it , as trigger might have changed the value after running !
		Opportunity l = [SELECT o.Parent_Name__c FROM Opportunity o WHERE Id = :o.Id];
			
		system.assertEquals(parentCamp.Name,l.Parent_Name__c);
	
	}
	static testMethod void testHandleRestrictedStates(){
		TestInit();
		Opportunity o = TestObjectFactory.CreateOpportunity(1, institution.id).Get(0);
		 o.DeltakSRP__Student__c = Student.id;
		 o.AccountId = institution.id;
		 o.DeltakSRP__Academic_Program__c = program.id;
		 o.DeltakSRP__Academic_Start_Date__c = termOld.id;
		 insert o;
		 List<Opportunity> oppAfterUpdate = [Select Id, StageName, DeltakSRP__Sub_Stage__c, ownerId from Opportunity where Id = :o.id];
		 System.Assert(oppAfterUpdate.size() > 0);
		
		 
		 o.StageName = 'New Inquiry';
		 update o;
		 oppAfterUpdate = [Select Id, StageName, DeltakSRP__Sub_Stage__c, ownerId from Opportunity where Id = :o.id];
		 System.Assert(oppAfterUpdate.size() > 0);		 
		 
	} 
	
	private static Account institution = New Account();
    private static Contact student = New Contact();
    private static DeltakSRP__Academic_Program__c program = New DeltakSRP__Academic_Program__c();
    private static DeltakSRP__Academic_Start_Date__c termOld = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termCurrent = New DeltakSRP__Academic_Start_Date__c();
    private static DeltakSRP__Academic_Start_Date__c termNext = New DeltakSRP__Academic_Start_Date__c();
   
	Public static void TestInit(){
        institution = TestObjectFactory.CreateAccount(1).Get(0);
        insert institution;
        
        student = TestObjectFactory.CreateContact(1,institution.id).Get(0);
        student.MailingState = 'IL';
        insert Student;
        
        program = TestObjectFactory.CreateAcademicProgram(1, institution.id).Get(0);
        program.Restricted_States__c = 'IL;Illinois';
        insert program;
        
        termOld = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() - 60).Get(0);
        insert termOld;
        
        termCurrent = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() - 10).Get(0);
        insert termCurrent;
        
        termNext = TestObjectFactory.CreateAcademicTerm(1, program.Id, Date.today() + 10).Get(0);
        insert termNext;
        
        
    }

}