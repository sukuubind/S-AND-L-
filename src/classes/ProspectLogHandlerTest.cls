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
@isTest(seealldata=true)
private class ProspectLogHandlerTest {

    static testMethod void testFindNextRunTime() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        a.Prospect_Enabled__c = true;
	        a.PRO_Distribution_Start_Hours__c = '9';
	        a.PRO_Distribution_Hours_Start_Minutes__c = '0';
	        a.PRO_Distribution_End_Hours__c = '17';
	        a.PRO_Distribution_Hours_End_Minutes__c = '0';
	        a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
	        insert a;
	        Datetime currentTimeStamp = Datetime.newInstance(2015, 10, 12, 18, 0, 0);
	        ProspectLogHandler handler = new ProspectLogHandler();
	        Datetime nextRunTime = handler.findNextRunTime(handler.accountIdToDistrbutionHourSetting.get(a.id), currentTimeStamp);
	        System.AssertNotEquals(null, nextRunTime);
	        
    }
    static testMethod void testFindNewStatus(){
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        a.Prospect_Enabled__c = true;
	        a.PRO_Distribution_Start_Hours__c = '9';
	        a.PRO_Distribution_Hours_Start_Minutes__c = '0';
	        a.PRO_Distribution_End_Hours__c = '17';
	        a.PRO_Distribution_Hours_End_Minutes__c = '0';
	        a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
	        insert a;
	        
	        ProspectLogHandler handler = new ProspectLogHandler();
	        System.AssertEquals(ProspectConstants.LOG_STATUS_PROCD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, handler.accountIdToDistrbutionHourSetting.get(a.id)));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_CLOSD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, null));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_PROCD, null));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_ESCTD, null));
	        
	        
	        
	        
	        
	        
	        
    }
    
    
    
}