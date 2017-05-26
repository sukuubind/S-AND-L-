@isTest
private class OpportunitySwitchOwnerForNurtureSchTest {
 
   	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
           
    static testmethod void test() {
        
        OppSwitchOwnerforNurtureBatchTests.Test_Init();
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('OpportunitySwitchOwnerForNurtureSch',
                                       CRON_EXP,
                                       new OpportunitySwitchOwnerForNurtureSch());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00',
                            String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
   }
}