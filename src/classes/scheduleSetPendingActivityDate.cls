global class scheduleSetPendingActivityDate implements Schedulable  {
    static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
            
        string query = 
            'SELECT Id FROM Opportunity WHERE RecordType.Name = \'Student Opportunity\'';
         
        batchSetPendingActivityDate updatePendingActivityDate = new batchSetPendingActivityDate (query, '', '', '');
        ID batchSetPendingActivityDateId = Database.executeBatch(updatePendingActivityDate); 
        System.debug('Pending ActivityDate Batch Job executed - ID = '+batchSetPendingActivityDateId);
    }
    
    
    static testmethod void testscheduleSetPendingActivityDate() {
        
        Test.startTest();
    
        // Schedule the test job  
            
        String jobId = System.schedule('testscheduleSetPendingActivityDate',
        CRON_EXP, new scheduleSetPendingActivityDate());
        // Get the information from the CronTrigger API object  
            
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same  
            
        System.assertEquals(scheduleSetPendingActivityDate.CRON_EXP, ct.CronExpression);
        // Verify the job has not run  
            
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run  
            
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    
    }
}