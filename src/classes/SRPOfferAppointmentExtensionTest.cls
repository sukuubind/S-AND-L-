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
private class SRPOfferAppointmentExtensionTest {

    static testMethod void myUnitTest() {
    	
        
        Account a = new Account();
	    a.Name = 'Test Account';
	    insert a;
        
        contact c = TestobjectFactory.CreateContact(1,a.id).get(0);
        insert c;
        
        DeltakSRP__Academic_Program__c ap = testobjectfactory.CreateAcademicProgram(1, a.id).get(0);
        insert ap;
        
        Opportunity o = TestObjectFactory.CreateOpportunity(1, a.id).Get(0);
		 o.DeltakSRP__Student__c = c.id;
		 o.AccountId = a.id;
		 o.DeltakSRP__Academic_Program__c = ap.id;
		 insert o;
		
    	c.opportunity_in_start_stage__c = o.id;
    	update c;
    	
    	 ApexPages.StandardController newController = new ApexPages.StandardController(o);
		SRPOfferAppointmentExtension testobj = new SRPOfferAppointmentExtension(newController);
		ApexPages.currentPage().getParameters().put('id',o.id); 
		testobj.updateWebSchedulerStatus(); 
		
		ApexPages.currentPage().getParameters().put('pmid',o.id); 
		testobj.updateWebSchedulerStatus(); 
		
		ApexPages.currentPage().getParameters().put('cid',c.id); 
		testobj.updateWebSchedulerStatus(); 
		
    }
}