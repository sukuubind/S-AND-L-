/*
 * Chris Baker - 11/29/2010 Changing query to group by school as well as email and create date
 */

global class scheduleDuplicateVendor implements Schedulable {
	static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
        string query = 
            'SELECT Duplicate_Number__c, Original_Opportunity__c, Original_Campaign__c, Id, ' + 
            'LP_Email__c, AccountId, Campaign.Name, CreatedDate, Original_Created_Date__c ' +
            'FROM Opportunity ' + 
            'WHERE RecordType.Name = \'Student Opportunity\' ' +
            'Order By AccountId, LP_Email__c, CreatedDate ASC';
            		         
        batchDuplicateVendor updateDuplicateVendor = new batchDuplicateVendor (query, '', '', '');
        ID batchDuplicateVendorID = Database.executeBatch(updateDuplicateVendor); 
        System.debug('Batch Job executed - ID = ' + batchDuplicateVendorID);
   
    } 
    
    static testmethod void testscheduleDuplicateVendor() {
		    
		Test.startTest();
		
		// Schedule the test job  
		    
		String jobId = System.schedule('testscheduleDuplicateVendor',
		CRON_EXP, new scheduleDuplicateVendor());
		// Get the information from the CronTrigger API object  
		    
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
		FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same  
		    
		System.assertEquals(scheduleDuplicateVendor.CRON_EXP, ct.CronExpression);
		// Verify the job has not run  
		    
		System.assertEquals(0, ct.TimesTriggered);
		// Verify the next time the job will run  
		    
		System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		
		Test.stopTest();
	}
}