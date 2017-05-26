global class scheduleToUpdateTPSInfo implements Schedulable {
	static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
        string query = 
            'SELECT Id, updateTPSFlag__c, SRP_Update_TPS_Flag__c, DeltakSRP__File_Complete__c, File_Complete__c, X1_Day__c, X2_Day__c, X3_Day__c, X4_Day__c, ' +
            'X5_Day__c, X6_Day__c, X7_Day__c, X8_Day__c, X9_Day__c, X10_Day__c, '       +
            'X11_Day__c, X12_Day__c,X13_Day__c, X14_Day__c FROM Opportunity '+
            'WHERE (updateTPSFlag__c = \'True\' or SRP_Update_TPS_Flag__c = true)';
            
        System.Debug('Query = '+query);
        batchUpdateTPSInfo updateTPSJob = new batchUpdateTPSInfo (query, '', '', '');
        ID TPSBatchJobID = Database.executeBatch(updateTPSJob); 
        System.debug('TPS Batch Job executed - ID = '+TPSBatchJobID);
   
    } 
    
 
static testmethod void testscheduleToUpdateTPSInfo() {
	
	Test.startTest();

// Schedule the test job  
    
String jobId = System.schedule('testBasicScheduledApex',
CRON_EXP, new scheduleToUpdateTPSInfo());
// Get the information from the CronTrigger API object  
    
CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
FROM CronTrigger WHERE id = :jobId];
// Verify the expressions are the same  
    
System.assertEquals(scheduleToUpdateTPSInfo.CRON_EXP, ct.CronExpression);
// Verify the job has not run  
    
System.assertEquals(0, ct.TimesTriggered);
// Verify the next time the job will run  
    
System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

Test.stopTest();

}

}