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
@isTest(SeeAllData=true)
private class SRPUserTriggerHandlerTest {

    static testMethod void testPortalUserAfterInsert() {
        // TO DO: implement unit test
        UserLicense ul = [SELECT Id FROM UserLicense WHERE Name LIKE 'Customer Portal%' LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE UserLicenseId = :ul.Id LIMIT 1];
        
        Account a = new Account(name = 'TEST ACCOUNT');
        insert a;
        Contact c = new Contact(AccountId = a.id, firstname = 'firstname', lastname = 'lastname');
        insert c;
        
        System.Test.startTest();
        
        DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
        Id leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
        
        User pu = new User(profileId = p.id, username = 'someusername@test123456.com', email = 'someusername@test123456.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);

        insert pu;
        
        System.Test.stopTest();
        
        User pu2 = [Select Id, ContactId FROM User WHERE Id = :pu.Id LIMIT 1];
        
        Contact pc = [Select Id, OwnerId FROM Contact WHERE Id = :pu2.ContactId LIMIT 1];
        
        System.assertEquals(leadEngineUserid, pc.OwnerId);
        
        
        
        
    }
}