@isTest(seealldata=true)
private  class SRPProgramEnrollmentHandlerTempTest {
	static testMethod void myUnitTest() {
			RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
			
			Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TES';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname';
	        c.LastName = 'lname';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        c.DeltakSRP__Student_ID__c = 'STU12345';
	        insert c;
	         
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
			
			DeltakSRP__Academic_Start_Date__c ast = new DeltakSRP__Academic_Start_Date__c(
		    	DeltakSRP__Start_Date__c = Date.today(),
		    	DeltakSRP__End_Date__c = Date.today().addDays(120),
		    	DeltakSRP__Term_Label__c = '2014 Winter',
		    	DeltakSRP__SIS_External_Id__c = 'AT12345',
		    	DeltakSRP__Academic_Program__c = ap.id
	    	);
	    Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{ast});
	    system.debug('ast.DeltakSRP__SIS_External_Id__c>>>>'+ast.id+'>>>>'+ast.DeltakSRP__SIS_External_Id__c);
			
			DeltakSRP__Program_Enrollment__c testPE = new DeltakSRP__Program_Enrollment__c();
			//testPE.DeltakSRP__Enrolled_Student__c = c.id;
			//testPE.DeltakSRP__Academic_Program__c = ap.id;
			testPE.deltaksrp__start_date__c = system.today();
			testPE.DeltakSRP__SIS_External_Id__c = 'UOB-STU12345-AP12345';
			insert testpe;
			
			DeltakSRP__Program_Enrollment__c testPE2 = new DeltakSRP__Program_Enrollment__c();
			testPE2.deltaksrp__start_date__c = system.today();
			testPE2.DeltakSRP__SIS_External_Id__c = 'UOB-STU12345-AP1234567';
			insert testpe2;
	}
}