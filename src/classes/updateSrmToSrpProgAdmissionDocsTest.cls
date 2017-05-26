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
private class updateSrmToSrpProgAdmissionDocsTest {

    static testMethod void myUnitTest() {
    	
    	Account a = new Account();
        a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	Academic_Program__c ap = new Academic_Program__c();
        ap.School__c = a.Id;
        insert ap;
    	
    	Program_Admission_Template__c pat = new Program_Admission_Template__c();
        pat.program__c = ap.Id;
        insert pat;
    	
    	Id srmOppRecordType = [Select id from RecordType where name = 'Student Opportunity'].Id;
    	
    	
    	Opportunity o = new Opportunity();
    	o.name = 'test Oppty';
    	o.CloseDate = system.today() + 100;
    	o.StageName = 'New Inquiry';
    	o.AccountId = a.id;
    	o.RecordTypeId = srmOppRecordType;
    	o.Program__c = ap.Id;
        insert o;
    	
    	
    	List<Program_Admission_Document__c> ProgramAdmDocsToInsert = new List<Program_Admission_Document__c>();
        for(Integer i=0; i<200; i++){
        	Program_Admission_Document__c pad = new Program_Admission_Document__c();
        	pad.opportunity__c = o.Id;
        	ProgramAdmDocsToInsert.add(pad);
        }
        insert ProgramAdmDocsToInsert;
        
        integer srppadcount = [Select count() from DeltakSRP__Program_Admission_Document__c];
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Program Admission Documents');
	        updateSrmToSrpProgAdmissionDocs testObj = new updateSrmToSrpProgAdmissionDocs(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
	        Id BatchId = Database.executeBatch(testObj, 200); 
        test.stoptest();
        integer srppadcount2 = [Select count() from DeltakSRP__Program_Admission_Document__c];
        
        //system.assertequals(srppadcount + 200, srppadcount2);
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