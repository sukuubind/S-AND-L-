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
private class LiveChatTranscriptTriggerHandlerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        DateTime dtStartTime = DateTime.now();
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        
        insert lcv;
        
        System.debug('>--->lcv.SessionKey: '+lcv.SessionKey);
        
        Live_Chat_Feedback__c lcf = new Live_Chat_Feedback__c();
        lcf.Transcript_ChatKey__c = 'testliveagentsessionkey';
        
        insert lcf;
        
        
        Opportunity o = new Opportunity();        
			o.CloseDate=system.today()+100;
	        o.StageName='New Inquiry';
	        o.Name='Test';
	        o.Chat_Start_Time__c = DateTime.newInstance(DateTime.now().year(),DateTime.now().month(),DateTime.now().day(),
	        DateTime.now().hour(),1,DateTime.now().second());
	        //o.AccountID=a.Id;
        insert o;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.Opportunity__c = o.id;
        lct.starttime = dtStartTime;
        lct.endtime = DateTime.now();
        lct.body = 'test body of chat transcript';
        insert lct;
        
        Opportunity o2 = new Opportunity();        
		o2.CloseDate=system.today()+100;
        o2.StageName='New Inquiry';
        o2.Name='Test';
	        //o.AccountID=a.Id;
        insert o2;
        
        lct.Opportunity__c = o2.id;
        update lct;
        
        
    }
    
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        
        insert lcv;
        
        System.debug('>--->lcv.SessionKey: '+lcv.SessionKey);
        
        Live_Chat_Feedback__c lcf = new Live_Chat_Feedback__c();
        lcf.Transcript_ChatKey__c = 'testliveagentsessionkey';
        
        insert lcf;
        
        Contact c = new Contact();
        c.firstName = 'test';
        c.lastName = 'test';
        c.Email = 'test@lct.com';
        
        insert c;
        
        Opportunity o = new Opportunity();        
			o.CloseDate=system.today()+100;
	        o.StageName='New Inquiry';
	        o.Name='Test';
	        o.DeltakSRP__Student__c = c.Id;
	        //o.AccountID=a.Id;
        insert o;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.ContactId = c.Id;
        lct.Opportunity__c = null;
        insert lct;
                
        LiveChatTranscript lctUpd = [SELECT Id, Opportunity__c FROM LiveChatTranscript WHERE Id = :lct.Id];
        
        System.assertEquals(o.Id, lctUpd.Opportunity__c);
        
        
    }
    
    
    static testMethod void myUnitTest3() {
        // TO DO: implement unit test
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        
        insert lcv;
        
        System.debug('>--->lcv.SessionKey: '+lcv.SessionKey);
        
        Live_Chat_Feedback__c lcf = new Live_Chat_Feedback__c();
        lcf.Transcript_ChatKey__c = 'testliveagentsessionkey';
        
        insert lcf;
        
        Contact c = new Contact();
        c.firstName = 'test';
        c.lastName = 'test';
        c.Email = 'test@lct.com';
        
        insert c;
        
        Opportunity o = new Opportunity();        
			o.CloseDate=system.today()+100;
	        o.StageName='Dormant';
	        o.Name='Test';
	        o.Student__c = c.Id;
	        //o.AccountID=a.Id;
        insert o;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.ContactId = c.Id;
        lct.Opportunity__c = null;
        insert lct;
                
        LiveChatTranscript lctUpd = [SELECT Id, Opportunity__c FROM LiveChatTranscript WHERE Id = :lct.Id];
        
        System.assertEquals(o.Id, lctUpd.Opportunity__c);
        
        
    }
    
}