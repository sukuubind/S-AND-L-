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
private class updateSrmToSrpFiscalCalendarTest {

    static testMethod void myUnitTest() {
    	
    	List<Fiscal_Calendar__c> fctoinsert = new List<Fiscal_Calendar__c>();
    	
    	for(Integer i=0; i<200; i++){
	        Fiscal_Calendar__c fc = new Fiscal_Calendar__c();
	        fc.name = 'test'+i;
	        fc.period__c = '1';
	        fc.start_date__c = system.today();
	        fc.end_date__c = system.today() +365;
	        fctoinsert.add(fc);
    	}
        
        insert fctoinsert;
        
        integer srpfccount = [Select count() from Deltaksrp__Fiscal_Calendar__c];
        
        system.debug('srpfccount>>>>'+srpfccount);
        
        System.Test.startTest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Fiscal Calendars');
	        updateSrmToSrpFiscalCalendar testObj = new updateSrmToSrpFiscalCalendar(chatterFeedItemId,new List<String>{'test@email.com'});
	        Id BatchId = Database.executeBatch(testObj, 200);
        system.test.stoptest();
        
        integer srpfccount2 = [Select count() from DeltakSRP__Fiscal_Calendar__c];
        system.debug('srpfccount2 >>>>'+srpfccount2);
        
        system.assertequals(srpfccount + 200, srpfccount2);
      
        
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