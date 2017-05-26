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
private class Live_Agent_After_Hours_Scheduled_Test {

    static testMethod void TestScheduled()
   {
   	
   	User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
   	After_Hours_Profile_Id__c, Is_After_Hours_Enabled__c
   	FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
    u.Is_After_Hours_User__c = true;
    u.After_Hours_Cluster__c = 'TEST';
    u.Normal_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);
    u.After_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);  
    u.Is_After_Hours_Enabled__c = true;
   	
   	update u;
   	
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new Live_Agent_After_Hours_Scheduled());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
}