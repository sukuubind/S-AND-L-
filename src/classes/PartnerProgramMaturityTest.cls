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
private class PartnerProgramMaturityTest {

    static testMethod void myUnitTest() {
       Test.startTest();
       String jobId = System.schedule('PartnerProgramMaturityTest',
      PartnerProgamMaturity.CRON_EXP, 
         new PartnerProgamMaturity());
       
       // Get the information from the CronTrigger API object  
    

      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

   // Verify the expressions are the same  
    
      System.assertEquals(PartnerProgamMaturity.CRON_EXP, 
         ct.CronExpression);

   // Verify the job has not run  
    
      System.assertEquals(0, ct.TimesTriggered);

   // Verify the next time the job will run  
    
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
       
       Test.stopTest();
    }
}