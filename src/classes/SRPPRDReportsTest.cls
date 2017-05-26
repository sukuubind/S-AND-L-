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
@isTest(SeeAllData=true)
private class SRPPRDReportsTest {

     static testMethod void PRDReportsCompControllerTestSRM() {
     	
     	SRPPRDReportsCompController controller = new SRPPRDReportsCompController();
     	
        Test.startTest();
       
     	List<Email_Partner_Reports__c> emailPgmList = new List<Email_Partner_Reports__c>();
     	emailPgmList = Email_Partner_Reports__c.getAll().values();
     	
     	if(emailPgmList!=null && emailPgmList.size()>0) 
     	{
     		for(Email_Partner_Reports__c ePL: emailPgmList)
			{
				controller.emailAddress = ePL.Email_Address__c;
			}
     	}else
     	{
     		controller.emailAddress = 'vigneshhere@yahoo.com';
     	}
     	
		controller.getOppList();
		Test.stopTest();
    }
    
    static testMethod void PRDReportsCompControllerTestSRP() {
     	
     	SRPPRDReportsCompController controller = new SRPPRDReportsCompController();
     	
     	Account srpAcc = [SELECT Id, Name, RecordType.DeveloperName From Account WHERE RecordType.DeveloperName = 'SRP_Account' limit 1];
     	
     	DeltakSRP__Academic_Program__c pgm = [Select id, DeltakSRP__Program_Title__c, DeltakSRP__School__r.Id From DeltakSRP__Academic_Program__c where DeltakSRP__School__r.Id =: srpAcc.id limit 1];
     	 
     	Email_Partner_Reports__c ppc = new Email_Partner_Reports__c(Name='Test Rec', Account_Name__c = srpAcc.Name, Email_Address__c = 'srptest@nomail.com', Partner_Id__c = srpAcc.id, Program_Id__c=pgm.id, Program_Title__c=pgm.DeltakSRP__Program_Title__c);
		insert ppc;
        Test.startTest();
       
     	controller.emailAddress = 'srptest@nomail.com';
     	
		controller.getOppList();
		Test.stopTest();
    }
    
	static testMethod void PRDReportsCompControllerTestSRPNullPartner() {
     	
     	SRPPRDReportsCompController controller = new SRPPRDReportsCompController();
     	
     	Account srpAcc = [SELECT Id, Name, RecordType.DeveloperName From Account WHERE RecordType.DeveloperName = 'SRP_Account' limit 1];
     	
     	DeltakSRP__Academic_Program__c pgm = [Select id, DeltakSRP__Program_Title__c, DeltakSRP__School__r.Id From DeltakSRP__Academic_Program__c where DeltakSRP__School__r.Id =: srpAcc.id limit 1];
     	 
     	Email_Partner_Reports__c ppc = new Email_Partner_Reports__c(Name='Test Rec', Account_Name__c = '', Email_Address__c = 'srptest2@nomail.com', Partner_Id__c = '', Program_Id__c=pgm.id, Program_Title__c=pgm.DeltakSRP__Program_Title__c);
		insert ppc;
        Test.startTest();
       
     	controller.emailAddress = 'srptest2@nomail.com';
     	
		controller.getOppList();
		Test.stopTest();
    }
    
    static testMethod void PRDReportsCompControllerTestNullEmailAddress() {
      SRPPRDReportsCompController controller = new SRPPRDReportsCompController();
     	
        Test.startTest();
      	controller.emailAddress = null;
		controller.getOppList();
		Test.stopTest();
    }
    
    static testMethod void reportsSchedulerTest() {
       SRPPRDReportsScheduler sch = new SRPPRDReportsScheduler();
       sch.execute(null);
    }
}