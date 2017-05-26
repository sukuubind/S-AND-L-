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
@isTest (seeAllData = true)
private class WarningBarContactControllerTest {

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
         		
         		
       
        
        ApexPages.StandardController sc = new ApexPages.standardController(affiliation);
        warningBarContactController cont = new warningBarContactController(sc);
        
        affiliation.DoNotCall = false;
        affiliation.OK_to_Text__c = 'No';
        affiliation.HasOptedOutOfEmail = false;
        upsert affiliation;
        
        cont = new warningBarContactController(sc);
         
            }
        }
    }
}