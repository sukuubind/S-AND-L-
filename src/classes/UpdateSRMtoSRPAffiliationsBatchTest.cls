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
@isTest(SeeAllData=false)
private class UpdateSRMtoSRPAffiliationsBatchTest {

    static testMethod void myUnitTest() {
        
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
        
        List<Contact> contactsToInsert = new List<Contact>();
        for(Integer i=0; i<200; i++){
            Contact c = new contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact ';
            c.AccountId = a.id;
            c.RecordTypeId = srmStudentRecordType;
            c.Country_of_Citizenship__c = 'USA';
            ContactsToInsert.add(c);
        }
        insert contactsToinsert;
        
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Opportunities');
            UpdateSrmToSrpAffliations testObj = new UpdateSrmToSrpAffliations(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
            Id BatchId = Database.executeBatch(testObj, 200); 
        test.stoptest();
        
        Id srpStudentRecordType = [Select Id from RecordType where name= 'SRP Student'].Id;
        
        List<contact> contactstoverify = [Select DeltakSRP__Citizenship__c, recordtypeid from contact where Id =: contactsToInsert[0].Id];
        system.assertequals(contactstoverify[0].recordtypeId, srpStudentRecordType);
		system.assertequals(contactstoverify[0].DeltakSRP__Citizenship__c, 'United States');
		        
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