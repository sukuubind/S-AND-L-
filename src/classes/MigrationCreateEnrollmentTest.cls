@isTest
private class MigrationCreateEnrollmentTest {

    static testMethod void myUnitTest() {
    	Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	
    	
    	
    	
    	List<Account> accountList = new List<Account>();
    	Account school = new Account();
    	school.Name = 'Schhol';
    	accountList.add(school);
    	
    	Account lineOfBusiness = new Account();
    	lineOfBusiness.Name = 'LOB';
    	accountList.add(lineOfBusiness);
    	
    	insert accountList;
    	
    	Contact student = new Contact();
    	student.FirstName = 'test';
    	student.LastName = 'test';
    	student.AccountID = accountList.get(0).id;
    	insert student;
    	
    	/**Program_Master__c programMaster = new Program_Master__c();
    	programMaster.Name = 'Test Program';
    	programMaster.Degree_Type__c = 'Certificate';
    	programMaster.Abbreviation__c = 'MS';
    	programMaster.Line_of_Business__c = accountList.get(1).id;
    	insert programMaster;**/
    	
    	Academic_Program__c acad = new Academic_Program__c();
    	acad.School__c = accountList.get(0).id;
    	//acad.Program_Master__c = programMaster.id;
    	acad.Name = 'Test Acadmic Name';
    	insert acad;
    	
    	//CB
    	 Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = System.today();
             startDate.Program__c = acad.Id;
             insert startDate;

    	
        Opportunity opp = new Opportunity();
        opp.StageName = 'Start';
        opp.Student__c = student.id;
        opp.Program__c = acad.id;
        opp.Name = 'Opp Name';
        opp.Start_Date__c = System.today();
        opp.CloseDate = System.today();
        opp.AccountID = accountList.get(0).id;
        insert opp;
        
        MigrationCreateEnrollment.run();
        List<Opportunity> startOpps = [select Id, Student__c, Program__c, Start_Date__c, Student_Enrollment__c
			from Opportunity where StageName = 'Start' And id = :opp.id];
			for(Opportunity thisOpp : startOpps){
				System.assertNotEquals(null, thisOpp.Student_Enrollment__c);
			}
        }
    }
}