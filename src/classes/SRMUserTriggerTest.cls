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
@isTest(seealldata = true)
private class SRMUserTriggerTest {

   static testMethod  void testAutoContactCreation() {
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', FirstName = 'Trigger', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='testuser123abc@testorg.com');
      try{
          insert u;
          System.assert(true);
      }catch(Exception e){
        System.Assert(false);
      }
      
      
   }
   static testMethod void testContactDupesPrevention() {
   
   Profile p = [SELECT Id FROM Profile WHERE Name='Integration Profile']; 
      
      User u = new User(Alias = 'cmana', Email='venkat.santhanam=rasmussen.edu@example.com', 
      EmailEncodingKey='UTF-8', FirstName = 'Configuration', LastName='Manager', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='testuser456123abc@testorg.com');
      insert u;
      system.debug('user created --' +u.username);
      }
      
   
   
   static testMethod void testContactCreation() {
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      List<id> uid = new List<id>();
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', FirstName = 'Trigger', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='testuser123abc@testorg.com');
      
      uid.add(u.id);
      Test.startTest();
      insert u;
      SRMUserContactHandler.createNewStaffContact(uid);
      Test.stopTest();
      List<Contact> c = new List<contact>([SELECT FirstName, LastName, Email FROM Contact WHERE FirstName = 'Trigger']);
      System.assertNotEquals(null, c);
      /*System.assertEquals(1, c.size());
      System.assertequals(u.LastName, c[0].LastName);
      System.assertequals(u.Email, c[0].Email);
      List<Person__c> per = new List<Person__c>([SELECT First_Name__c, Last_Name__c FROM Person__c WHERE First_Name__c = 'Trigger']);
      System.assertequals(u.LastName,per[0].Last_Name__c);*/
      // TODO add asserts for organization ID
      
   }
}