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
private class updateSrmToSrpProgAdmissionTemplateTest {

    static testMethod void myUnitTest() {
        Account a = new Account();
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
    	ap2.DeltakSRP__school__c = a.Id;
    	insert ap2;
    	
    	Academic_Program__c ap = new Academic_Program__c();
    	ap.school__c = a.Id;
    	ap.Academic_Program__c = ap2.Id;
    	insert ap;
    	
    	List<Program_Admission_Template__c> ProgramTemplatesToInsert = new List<Program_Admission_Template__c>();
        for(Integer i=0; i<200; i++){
        	Program_Admission_Template__c pat = new Program_Admission_Template__c();
        	pat.program__c = ap.Id;
        	ProgramTemplatesToInsert.add(pat);
        }
        insert ProgramTemplatesToInsert;
        
        integer srppatcount = [Select count() from DeltakSRP__Program_Admission_Template__c];
        integer srppatcount3 = [Select count() from DeltakSRP__Program_Admission_Template_Selection__c];
        
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Program Admissions Templates');
	        updateSrmToSrpProgAdmissionTemplate testObj = new updateSrmToSrpProgAdmissionTemplate(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
	        Id BatchId = Database.executeBatch(testObj, 200); 
        test.stoptest();
        integer srppatcount2 = [Select count() from DeltakSRP__Program_Admission_Template__c];
        integer srppatcount4 = [Select count() from DeltakSRP__Program_Admission_Template_Selection__c];
        
        system.assertequals(srppatcount + 200, srppatcount2);
        system.assertequals(srppatcount3 + 200, srppatcount4);
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