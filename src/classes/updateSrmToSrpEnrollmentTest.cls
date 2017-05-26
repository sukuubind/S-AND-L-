/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class updateSrmToSrpEnrollmentTest {
	
    @isTest static void myUnitTest() {
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        Contact c = new contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact ';
        c.AccountId = a.id;
        c.RecordTypeId = srmStudentRecordType;
        insert c;
    	
    	Id srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
    	
    	Opportunity o = new Opportunity();
    	o.name = 'test Oppty';
    	o.CloseDate = system.today() + 100;
    	o.StageName = 'New Inquiry';
    	o.AccountId = a.id;
    	o.RecordTypeId = srmOppRecordType;
    	insert o;
    	
    	Academic_Program__c ap = new Academic_Program__c();
    	ap.Name = 'Test';
    	ap.School__c = a.Id;
    	insert ap;
    	
    	Academic_Start_Date__c  asd = new Academic_Start_Date__c ();
        asd.Start_Date__c = system.today();
        asd.end_date__c = system.today() + 365;
        asd.program__c = ap.Id;
        insert asd;
    	
    	List<Student_Enrollment__c> sEnrollments = new List<Student_Enrollment__c>();
    	
    	for(Integer i=0; i<200; i++){
    		Student_Enrollment__c se = new Student_Enrollment__c();
    		se.Name = 'Test ' + i;
    		se.Student_Affiliation__c = c.Id;
    		se.Opportunity__c = o.Id;
    		se.Program__c = ap.Id;
    		se.Start_Date__c = system.today();
    		sEnrollments.add(se);
    	}
    	
    	insert sEnrollments;

      Test.StartTest();
      		String chatterFeedItemId = postChatterGroupFeedItem('Enrollments');
           updateSrmToSrpEnrollment testObj = new updateSrmToSrpEnrollment(a.Id,chatterFeedItemId,new List<String>{'test@email.com'});
            Id BatchId = Database.executeBatch(testObj,2000); 
       Test.stopTest();
    }
    

private static String postChatterGroupFeedItem(String targetUpdate)
	{
		String chatterFeedItemId;
		
		 
		CollaborationGroup cg = new CollaborationGroup();
		cg.Name = 'SRM To SRP Migration Status Test';
		cg.CollaborationType='Private';
		insert cg;
		
		String chatterFeedId = cg.Id + '';
		
		if(chatterFeedId != null && chatterFeedId != '')
		{
		
			FeedItem fi = new FeedItem();
	      	fi.Body = 'Update ' + targetUpdate + ' batch process queued by [' + UserInfo.getUserEmail() +']';
	      	fi.ParentId = chatterFeedId;
	      	insert fi;
	      
	      	chatterFeedItemId = fi.Id + '';
		
		}
		
		return chatterFeedItemId;
		
	}
    
}