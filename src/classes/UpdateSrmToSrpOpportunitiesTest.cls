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
private class UpdateSrmToSrpOpportunitiesTest {

    static testMethod void myUnitTest() {
        Account a = new Account();
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	Id srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
    	
    	List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        for(Integer i=0; i<200; i++){
        	Opportunity o = new Opportunity();
        	o.name = 'test Oppty';
        	o.CloseDate = system.today() + 100;
        	o.StageName = 'New Inquiry';
        	o.AccountId = a.id;
        	o.RecordTypeId = srmOppRecordType;
        	OpportunitiesToInsert.add(o);
        }
        insert opportunitiesToinsert;
        
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Opportunities');
	        UpdateSrmToSrpOpportunities testObj = new UpdateSrmToSrpOpportunities(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
	        Id BatchId = Database.executeBatch(testObj, 200); 
        test.stopTest();
        
        Id srpOppRecordType = [Select id from RecordType where name = 'SRP Opportunity'].Id;
        
        List<Opportunity> opptytoverify = [Select recordtypeid from Opportunity where Id =: opportunitiesToinsert[0].Id];
        system.assertequals(opptytoverify[0].recordtypeId, srpOppRecordType);
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