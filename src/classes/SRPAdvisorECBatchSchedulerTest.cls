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
public with sharing class SRPAdvisorECBatchSchedulerTest {

public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	static testmethod void testScheduler() {

      Test.startTest();
       
      SRPAdvisorECBatchScheduler obj = new SRPAdvisorECBatchScheduler();
      
      String jobId = System.schedule('testScheduler', CRON_EXP, obj);
      
      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
						FROM CronTrigger WHERE id = :jobId];
      
      System.assertEquals(obj.CRON_EXP, ct.CronExpression);
		
	  System.assertEquals(0, ct.TimesTriggered);
	
	  Test.stopTest();
 
	} 
}