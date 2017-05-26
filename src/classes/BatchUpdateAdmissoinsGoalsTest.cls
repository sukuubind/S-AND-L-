@isTest
private class BatchUpdateAdmissoinsGoalsTest {

    static testMethod void myUnitTest() {
    	
        //Create the Admissions Rep user to associate the Opportunities and the Admissions Goals with
        Profile repProfile = [SELECT Id FROM Profile WHERE Name = 'Deltak: Program Managers' LIMIT 1];
        User AdmissionsRepUser = new User(alias = 'repUser', email='repUser@testorg.com',
                    emailencodingkey='UTF-8', lastname='repUser',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = repProfile.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='repUser@testorg.com');
        insert AdmissionsRepUser;
                 
        
        
		Test.startTest(); 	
		
		DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
                    
		Account a = new Account();
    	a.Name = 'Test Account';
    	insert a;    	
    	
        //set up a program and set the opportunity to it
       	Academic_Program__c ap = new Academic_Program__c();
       	ap.Name = 'Test Program';
       	ap.School__c = a.Id;
       	insert ap;
       	
       	Academic_Start_Date__c s = new Academic_Start_Date__c();       	
       	s.Start_Date__c = d;
       	s.Program__c = ap.Id;
       	insert s;
       	/*
		Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        //o.ForecastCategoryName='Pipeline';
        o.Name='Test';
        o.AccountID=a.Id;  
        o.Program__c = ap.Id;
        o.OwnerID=AdmissionsRepUser.Id;        
        insert o;
        
        Opportunity o2 = new Opportunity();
        o2.CloseDate=d;
        o2.StageName='New Inquiry';        
        o2.Name='Test2';
        o2.AccountID=a.Id;  
        o2.Program__c = ap.Id;
        o2.OwnerID=AdmissionsRepUser.Id;   
        o2.GM_Migration__c = true;
        o2.Goldmine_CreateDate__c = null;     
        insert o2;
        */
		Admissions_Goal__c ag = new Admissions_Goal__c();
		ag.Academic_Start_Date__c = s.Id;
		ag.Admissions_User__c = AdmissionsRepUser.Id;
		insert ag;
		
		string query = 
              'SELECT Id, CreatedDate, GM_Migration__c, OwnerID, Academic_Start_Date__c, Date_Booked__c, ' +
            'Referred_By_Opportunity__c, Referred_By_Opportunity__r.OwnerId, Referred_By_Opportunity__r.Goldmine_CreateDate__c , ' +
            'Referred_By_Opportunity__r.GM_Migration__c, Referred_By_Opportunity__r.CreatedDate, StageName, ' +
            'Appointment_Completed__c, Last_Attempt__c, Last_Contact__c, Goldmine_CreateDate__c ' +
            'FROM Opportunity '+
            'LIMIT 100'; 
             
         
        BatchUpdateAdmissionsGoals updateAdmissionsGoalsJob = new BatchUpdateAdmissionsGoals (query, '', '', '');
        ID admissionsGoalsBatchJobID = Database.executeBatch(updateAdmissionsGoalsJob);
        Test.stopTest();
        
    }  
}