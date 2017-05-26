@isTest
public class OpportunityUtilitiesTest {

    static testmethod void test_getSRPOppRecordType(){
        Test_Init();
        OpportunityUtilities.getSRPOppRecordType();
        OpportunityUtilities.getStudentOppRecordType();
        OpportunityUtilities.cacheOppSettings();
    }
    
    static testmethod void test_getStudentOppRecordType(){
        Test_Init();
        OpportunityUtilities.getStudentOppRecordType();
        OpportunityUtilities.getNurtureUserID();
    }
    
    static testmethod void test_getNurtureUserID(){
        Test_Init();          
        OpportunityUtilities.getNurtureUserID();
        OpportunityUtilities.getSRPOppRecordType();
    }
	
    static testmethod void test_CustomSettingException(){
        try{
            Test.startTest();
            OpportunityUtilities.getSRPOppRecordType();
            Test.stopTest();
        } Catch (exception e){
            System.assertEquals(true, e.getMessage().contains('Opportunity_Settings__c.NurtureUserID__c" is not set.'));
        }
    }
    
    static testmethod void test_StudentOppRecordTypeException(){
        try{
            Test.startTest();
            OpportunityUtilities.IsStudentOppRecordTypeErrorTest = true;
            OpportunityUtilities.getSRPOppRecordType();
            Test.stopTest();
        } Catch (exception e){
            System.assertEquals(true, e.getMessage().contains('Opportunity: Student_Opportunity Record Type could not be found'));
        }
    }
    
    static testmethod void test_SRPOppRecordTypeException(){
        try{
            Test.startTest();
            OpportunityUtilities.IsSRPOppRecordTypeErrorTest = true;
            OpportunityUtilities.getSRPOppRecordType();
            Test.stopTest();
        } Catch (exception e){
            System.assertEquals(true, e.getMessage().contains('Opportunity: SRP_Opportunity Record Type could not be found'));
        }
    }
	    
    public static void Test_Init(){
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User uNurture;
        
        uNurture = new User(alias = 'nurtUser', email='nurtureuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Nurture',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='nurtureuser11@testorg.com');
        insert uNurture;
        
        Opportunity_Settings__c mcs = new Opportunity_Settings__c();
        mcs.NurtureUserID__c = uNurture.Id;
        insert mcs;
    }
    
}