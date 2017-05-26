@isTest (SeeAllData=true)
private class RASOppStudEnrollmentTriggerTest {

    static testMethod void myUnitTest() {
        
		Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        String currentProfileId = ((String) (pro.Id)).substring(0, 15);
		
	/*	upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);
        */
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        //insert a contact
        Contact c1 = new Contact();        
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.Id;
        c1.Employer_Company__c = 'Disney';
        insert c1;
        
        List <RecordType>  oppRecType = [Select Id from RecordType WHERE Name = 'Student Opportunity'];
        System.assertEquals(oppRecType.size(), 1);
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        o.Student__c = c1.Id;
        o.RecordTypeId = oppRecType[0].Id;
        insert o;
        
        //set up a program and set the opportunity to it
        Academic_Program__c ap = new Academic_Program__c();
        ap.Name = 'Test Program';
        ap.School__c = a.Id;
        insert ap;
        
        Academic_Start_Date__c startDate = new Academic_Start_Date__c();
        startDate.Start_Date__c = d;
        startDate.Program__c = ap.id;
        insert startDate;
        
        o.StageName = 'Start';
        o.Date_Submitted__c = d;
        o.Date_Accepted__c = d;
        o.Acceptance_Status__c = 'Fully Admitted';
        o.Program__c = ap.id;
        o.Start_Date__c = d;
        o.Academic_Start_Date__c = startDate.id;
        update o;
        
        List<Student_Enrollment__c> studList = [Select Id from Student_Enrollment__c s where s.Opportunity__c = :o.id];
        System.AssertEquals(1, studList.size());
        
        Opportunity opp = [Select Student_Enrollment__c from Opportunity where Id = :o.id limit 1];
        System.AssertEquals(studList[0].id , opp.Student_Enrollment__c );
        
       // o.StageName = 'Booked Qualified Application';
        //update o;
        }
    }
}