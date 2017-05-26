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
@isTest (seeAllData=true)
private class WarningBarControllerTest {

    static testMethod void myUnitTest() {
         string PMProfile = 'Deltak: Program Managers';
        
        Profile pro = [SELECT Id FROM profile WHERE name=:PMProfile];
        if (pro != null) {
            User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Testing',
                        languagelocalekey='en_US',
                        localesidkey='en_US', profileid = pro.Id,
                        timezonesidkey='America/Los_Angeles',
                        username='newuser11@testorg.com');
                        
            System.runAs(u2) {
          
            Date sDate = Date.newInstance(2012, 03, 29);//start date               
        	Date eDate = Date.newInstance(2012, 07, 21);//end date        	
            	 
        Account organization = new Account();
        organization.Name = 'Test Organization';
        organization.Active__c = TRUE;
        
        insert organization;
        //organization added
        
        Academic_Program__c academicProgram1 = new Academic_Program__c();
        academicProgram1.Name = 'Sample Academic Program';
        academicProgram1.School__c = organization.Id;
        academicProgram1.Program_Title__c = 'Sample Program Title';
        academicProgram1.DegreeType__c = 'Certificate';
        academicProgram1.Abbrev__c = 'SAPrg';
        academicProgram1.Active__c = TRUE;
        
        insert academicProgram1;
        //academicprogram1 added
               
        Fiscal_Calendar__c fCalendar = new  Fiscal_Calendar__c();
        fCalendar.End_Date__c = eDate;
        fCalendar.Name = 'Sample Fiscal Calendar';
        fCalendar.Start_Date__c = sDate;
        fCalendar.Period__c = '1';
        
        insert fCalendar;
        //fiscal calendar added
        
        Academic_Start_Date__c startdate1 = new Academic_Start_Date__c();
        startdate1.Start_Date__c = sDate;
        startdate1.Fiscal_Calendar__c = fCalendar.Id;
        startdate1.Program__c = academicProgram1.Id;
        
        insert startdate1;
        //startdate1 added
        
        Academic_Specialization__c academicSpec = new Academic_Specialization__c();
        academicSpec.Name = 'Sample Academic Specialization';
        academicSpec.Academic_Program__c = academicProgram1.Id;
        academicSpec.Spec_Title__c = 'Sample Specialization Title';
        academicSpec.Specialization_Abbrev__c = 'SASpec';
        
        insert academicSpec;
        //specialization added
            	
            	
    	Contact affiliation = new Contact();
        affiliation.LastName = 'Johnson';
        affiliation.FirstName = 'Amy';
        affiliation.Email = 'amyJ@gmail.com';
        affiliation.Phone = '3157894521';
        affiliation.DoNotCall = true;
        affiliation.OK_to_Text__c = 'Yes';
        affiliation.HasOptedOutOfEmail = true;
        affiliation.AccountId= organization.Id;
       
        
        insert affiliation;
         		
         		
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Opportunity;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('Student Opportunity');
        Id recTypeId = rt.getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.Academic_Start_Date__c = startdate1.Id;
        testOpp.Program__c = academicProgram1.Id;
        testOpp.Specialization__c = academicSpec.Id;
        testOpp.Name = 'Test Opporunity for Amy Johnson';
        testOpp.CloseDate = eDate;
        testOpp.StageName = 'New Inquiry';
        testOpp.AccountId = organization.Id;
        testOpp.RecordTypeId = recTypeId;
        testOpp.Student__c = affiliation.Id;
   
        insert testOpp;
        //opportunity added
        
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);
        warningBarController cont = new warningBarController(sc);
        
        affiliation.DoNotCall = false;
        affiliation.OK_to_Text__c = 'No';
        affiliation.HasOptedOutOfEmail = false;
        upsert affiliation;
        
        cont = new warningBarController(sc);
         
            }
        }
            
            
        }
            
    }