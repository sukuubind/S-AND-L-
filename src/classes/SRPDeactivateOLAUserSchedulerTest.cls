@isTest
public with sharing class SRPDeactivateOLAUserSchedulerTest {

public static String CRON_EXP = '0 0 0 15 3 ? 2022';

static testmethod void testDeactivateOLAUser() {

      Test.startTest();
      
      SRPDeactivateOLAUserScheduler srpdeactivate = new SRPDeactivateOLAUserScheduler();
      
      String jobId = System.schedule('testDeactivateOLAUser', CRON_EXP, srpdeactivate);
      
      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
						FROM CronTrigger WHERE id = :jobId];
      
      System.assertEquals(srpdeactivate.CRON_EXP, ct.CronExpression);
		
	  System.assertEquals(0, ct.TimesTriggered);
	
	  Test.stopTest();
 
	} 
}