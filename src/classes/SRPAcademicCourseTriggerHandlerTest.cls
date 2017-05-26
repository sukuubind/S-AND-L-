@istest
private class SRPAcademicCourseTriggerHandlerTest {
	static testMethod void myUnitTest() {
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
        ap.DeltakSRP__SIS_External_Id__c = 'AP12345';
        insert ap;
        
        ap.DeltakSRP__SIS_External_Id__c = 'AP12345';
        update ap;
		
		DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
	    		DeltakSRP__Academic_Institution__c = 	a.Id,
	    		DeltakSRP__Active__c = true,
	    		DeltakSRP__Course_Units__c = 3,
	    		DeltakSRP__SIS_External_Id__c = 'UOB-AP12345-AC12345',
	    		Name = 'testCourseRecord'
	    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse});	
		
		DeltakSRP__Academic_Course__c testCourse2 = new DeltakSRP__Academic_Course__c(
	    		DeltakSRP__Academic_Institution__c = 	a.Id,
	    		DeltakSRP__Active__c = true,
	    		DeltakSRP__Course_Units__c = 3,
	    		DeltakSRP__SIS_External_Id__c = 'UOB-AP1234567-AC12345',
	    		Name = 'testCourseRecord2'
	    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse2});	
	}
}