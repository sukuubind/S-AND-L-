global class scheduleToUpdateFiscalCalendar implements Schedulable {
	static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
        string query = 
            'SELECT CreatedDate, fiscal_calendar__c, Program__c FROM Opportunity';         
        batchUpdateFiscalCalendar updateFiscalJob = new batchUpdateFiscalCalendar (query, '', '', '');
        ID batchUpdateFiscalCalendarID = Database.executeBatch(updateFiscalJob); 
        System.debug('Batch Job executed - ID = '+batchUpdateFiscalCalendarID);
   
    } 
    
    
    static testmethod void testscheduleToUpdateFiscalCalendar() {
		    
		Test.startTest();
		
		// Schedule the test job  
		    
		String jobId = System.schedule('testscheduleToUpdateFiscalCalendar',
		CRON_EXP, new scheduleToUpdateFiscalCalendar());
		// Get the information from the CronTrigger API object  
		    
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
		FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same  
		    
		System.assertEquals(scheduleToUpdateFiscalCalendar.CRON_EXP, ct.CronExpression);
		// Verify the job has not run  
		    
		System.assertEquals(0, ct.TimesTriggered);
		// Verify the next time the job will run  
		    
		System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		
		Test.stopTest();
	}
}