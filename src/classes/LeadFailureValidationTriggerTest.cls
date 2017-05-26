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
private class LeadFailureValidationTriggerTest {

    static testMethod void allValidScenario() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestName1 TestName2';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	        update insertFailureRecord;
	        
	        Lead_Failure__c thisFailureRecord = [Select Resend_Status__c from Lead_Failure__c where Id = :insertFailureRecord.Id];
	        System.AssertEquals(true, thisFailureRecord.Resend_Status__c);
	     }
        
    }
    
    static testMethod void nameIncorrectScenario() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestName1';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	        try{
	        update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('Contactname should have first name and last name'));
	        }
	     }
        
    }
    static testMethod void insufficientCharsInFirstName() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'Te TestLastName';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	        try{
	        update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('Firstname and Lastname should be atleast 3 characters long'));
	        }
	     }
        
    }
    
    static testMethod void insufficientCharsInlastName() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestFirstName Te';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	        try{
	        update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('Firstname and Lastname should be atleast 3 characters long'));
	        }
	     }
        
    }
    static testMethod void invalidEmail() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestFirstName TestLastName';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@edu';
	        try{
	        update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('Email is invalid. Please correct this email address.'));
	        }
	     }
        
    }
    
    static testMethod void noPIIAvailable() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestFirstName TestLastName';
	        insertFailureRecord.Phone1__c = '';
	        insertFailureRecord.Phone2__c = '';
	        insertFailureRecord.Email__c = '';
	         
	        try{
	       		update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('One of the following should be present: Phone1, Phone2, Email'));
	        }
	     }
        
    }
    
    static testMethod void alreadyResubmittedLead() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = 'TestName1 TestName2';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	        update insertFailureRecord;
	        
	        Lead_Failure__c thisFailureRecord = [Select ContactName__c, Resend_Status__c from Lead_Failure__c where Id = :insertFailureRecord.Id];
	        System.AssertEquals(true, thisFailureRecord.Resend_Status__c);
	     
	     	thisFailureRecord.ContactName__c = 'TestName2 TestName1';
	     	try{
	     		update thisFailureRecord;
	     	}catch(Exception e){
	     		System.AssertEquals(true, e.getMessage().contains('This failure record is already processed.'));
	     	}
	     
	     }
        
    }
    
    static testMethod void noContactNameAvailable() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.ContactName__c = '';
	        insertFailureRecord.Phone1__c = '1234567890';
	        insertFailureRecord.Phone2__c = '0987654321';
	        insertFailureRecord.Email__c = 'test@rasmussen.edu';
	         
	        try{
	       		update insertFailureRecord;
	        }catch(Exception e){
		        System.AssertEquals(true, e.getMessage().contains('There is no contactname present.'));
	        }
	     }
        
    }
    static testMethod void ignoreLeadScenario() {
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Data Management'];
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
                    
        System.runAs(u2) {
	        Lead_Failure__c insertFailureRecord = insertIncorrectLeadFailureRecord();
	        insertFailureRecord.Ignore_Lead__c = true;
	         update insertFailureRecord;
	        // There is no assert for this test. The lead should save succesfully.
	        // The test is assumed a failure if this lead cannot be saved.
	     }
        
    }
    private static Lead_Failure__c insertIncorrectLeadFailureRecord(){
    	Lead_Failure__c lead_fail = new Lead_Failure__c();
        lead_fail.Program__c = '';
        lead_fail.Program2__c = '';
        lead_fail.Key1__c = '';
        lead_fail.Key2__c = '';
        lead_fail.Key5__c = 'TCS';
        lead_fail.R_Campaign__c = '';
        lead_fail.Source__c = '';
        lead_fail.Company__c = '';
        lead_fail.Referal__c = '';
        lead_fail.UrefKeyWrd__c = '';
        lead_fail.UADCampgn__c = '';
        lead_fail.UINTLead__c = '';
        lead_fail.urefurl__c = '';
        lead_fail.errorMessage__c = '';
       // lead_fail.notes__c = addedFields.notes;        
        lead_fail.uhowheard__c = '';
        lead_fail.udescribe__c = '';
        lead_fail.filename__c = '';
        lead_fail.uhscode__c = '';
        lead_fail.UOptOutCam__c = '';
        lead_fail.UCAMPGNTYP__c = '';
        lead_fail.utextperm__c = '';
        lead_fail.phone3__c = '';
        lead_fail.ucampus__c = '';
        lead_fail.urefrdby__c = '';
        lead_fail.Other_Colleges__c = '';
        
        lead_fail.GMId__c ='12345';
        lead_fail.ContactName__c= '';
        lead_fail.Address1__c= '';
        lead_fail.Address2__c='';
        lead_fail.City__c= '';
        lead_fail.State__c= '';
        lead_fail.Zip__c= '';
        lead_fail.Phone1__c= '';
        lead_fail.Phone2__c= '';
        lead_fail.Email__c= '';
        lead_fail.Gender__c='';
        lead_fail.BestTime__c= '';
        lead_fail.Program__c= '';
        lead_fail.CourseInterest__c=''; 
        lead_fail.HSGradYear__c= '';
        lead_fail.newKey5__c='';
        lead_fail.DateCreated__c= '';
        lead_fail.HighLevel__c= '';
        lead_fail.newKey4__c= '';
        lead_fail.Company__c= '';
        lead_fail.Title__c='';
        lead_fail.Source__c= '';
        lead_fail.UModality__c= '';
        lead_fail.UIMType__c= '';
        lead_fail.UIMName__c= '';
        lead_fail.RasId__c= '';
        lead_fail.OwnerId__c= '';
        lead_fail.referredByOpportunity__c= '';
        lead_fail.referredByPerson__c= '';
        lead_fail.TransferredFromOpportunity__c='';
        lead_fail.Duplicate_Opportunity__c = false;
        insert lead_fail;
        
        return lead_fail;
    }
}