/*
    This populates the Admssions Goals used on the DOA Report 
*/
global class scheduledUpdateToAdmissionsGoals implements Schedulable {
    static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
            
         string query = 
            'SELECT Id, CreatedDate, GM_Migration__c, OwnerID, Academic_Start_Date__c, Date_Booked__c, ' +
            'Referred_By_Opportunity__c, Referred_By_Opportunity__r.OwnerId, Referred_By_Opportunity__r.Goldmine_CreateDate__c , ' +
            'Referred_By_Opportunity__r.GM_Migration__c, Referred_By_Opportunity__r.CreatedDate, StageName, ' +
            'Appointment_Completed__c, Last_Attempt__c, Last_Contact__c, Goldmine_CreateDate__c ' +
            'FROM Opportunity';
         
        BatchUpdateAdmissionsGoals updateAdmissionsGoalsJob = new BatchUpdateAdmissionsGoals (query, '', '', '');
        ID admissionsGoalsBatchJobID = Database.executeBatch(updateAdmissionsGoalsJob); 
        System.debug('Admissions Goals Batch Job executed - ID = '+admissionsGoalsBatchJobID);
    }
    static testmethod void testscheduledUpdateToAdmissionsGoals() {
    
    Test.startTest();

// Schedule the test job  
    
String jobId = System.schedule('testScheduledUpdareToAdmissionsGoals',
CRON_EXP, new scheduledUpdateToAdmissionsGoals());
// Get the information from the CronTrigger API object  
    
CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
FROM CronTrigger WHERE id = :jobId];
// Verify the expressions are the same  
    
System.assertEquals(scheduledUpdateToAdmissionsGoals.CRON_EXP, ct.CronExpression);
// Verify the job has not run  
    
System.assertEquals(0, ct.TimesTriggered);
// Verify the next time the job will run  
    
System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

Test.stopTest();

}
}