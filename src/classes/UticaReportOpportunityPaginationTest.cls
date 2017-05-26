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
private class UticaReportOpportunityPaginationTest {

    static testMethod void myUnitTest() {
        
        
         Account a = new Account();
            a.Name = 'Test Account Utica';
            insert a;
            
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.Employer_Company__c = 'Disney'; 
            insert c;
            
            List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
            Opportunity o = new Opportunity();
                o.CloseDate=System.today();
                o.StageName='New Inquiry';
                o.AccountID=a.Id;
                o.Student__c=c.Id;   
                o.Name='Test Utica Opp '; 
                o.RecordTypeId = recList[0].Id;
                insert o;
                
                List<Opportunity> opps = [Select Id, name from Opportunity where Id = :o.Id];
       UticaReportOpportunityPagination oCEE = new UticaReportOpportunityPagination(new ApexPages.StandardSetController( opps ));
       oCEE.getOpportunityAppPagination(); 
       oCEE.getOpportunityInqPagination();
       oCEE.previousInq();
       oCEE.nextInq();
       oCEE.previousApp();
       oCEE.nextApp();
    }
}