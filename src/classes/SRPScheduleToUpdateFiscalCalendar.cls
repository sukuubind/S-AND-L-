global class SRPScheduleToUpdateFiscalCalendar implements Schedulable {
	static String CRON_EXP = '0 0 0 3 9 ? 2022';
    global void execute(SchedulableContext ctx) {
        string query = 
            'SELECT CreatedDate, DeltakSRP__fiscal_calendar__c, DeltakSRP__Academic_Program__c FROM Opportunity';         
        SRPbatchUpdateFiscalCalendar updateFiscalJob = new SRPbatchUpdateFiscalCalendar (query, '', '', '');
        ID batchUpdateFiscalCalendarID = Database.executeBatch(updateFiscalJob); 
        System.debug('Batch Job executed - ID = '+batchUpdateFiscalCalendarID);
   
    } 
    
    
    static testmethod void testscheduleToUpdateFiscalCalendar() {
		
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
  
        Account a = new Account();
    	a.recordTypeid = rt1.Id;
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
        
    	DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
		
		//insert a contact
        Contact c1 = new Contact();        
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.id;
        insert c1;
		
		Opportunity o = new Opportunity();
        o.CloseDate=system.today() + 365;
        o.StageName='dormant';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        insert o;
		
		DeltakSRP__Fiscal_Calendar__c fc = new DeltakSRP__Fiscal_Calendar__c ();
		fc.deltaksrp__Start_Date__c  = system.today() - 10;
		fc.DeltakSRP__End_Date__c = system.today() + 10;
		insert fc;
		
		Test.startTest();
		
		// Schedule the test job  
		    
		String jobId = System.schedule('testscheduleToUpdateFiscalCalendar',
		CRON_EXP, new SRPscheduleToUpdateFiscalCalendar());
		// Get the information from the CronTrigger API object  
		    
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
		FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same  
		    
		System.assertEquals(SRPScheduleToUpdateFiscalCalendar.CRON_EXP, ct.CronExpression);
		// Verify the job has not run  
		    
		System.assertEquals(0, ct.TimesTriggered);
		// Verify the next time the job will run  
		    
		System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
		
		Test.stopTest();
	}
}