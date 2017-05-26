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
private class Log_An_Activity_Controller_Test {

    static testMethod void normalFlowTest() {
        // TO DO: implement unit test
        Test.startTest();
        Account a = new Account();
        a.Name = 'test srp458';
        
        insert a;
        
        Contact c = new contact();
        c.firstName = 'test srp458';
        c.lastName = 'test srp458';
        c.Email = 'testsrp458@test.com';
        c.Phone = '1234567890';
        c.accountId = a.Id;
        
        insert c;
        
        Opportunity o = new Opportunity();
        o.Student__c = c.Id;
        o.Name = 'test srp458';
        o.CloseDate = DateTime.now().date();
        o.AccountId = a.Id;
        o.stageName = 'New Inquiry';
        
        insert o;
        
        Task t1 = new Task();
        t1.Subject = 'testsrp458';
        t1.Type = 'Chat';
        t1.ActivityDate = DateTime.now().date();
        t1.Priority = 'Normal';
        t1.Asked_for_Referral__c = 'Yes';
        insert t1;
        
        PageReference pageRef = Page.Log_An_Activity;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('pageTitle', 'Log a Chat');
        ApexPages.currentPage().getParameters().put('pageSubtitle', 'Edit Task');
        ApexPages.currentPage().getParameters().put('title', 'Log a Chat');
        ApexPages.currentPage().getParameters().put('who_id', c.Id);
        ApexPages.currentPage().getParameters().put('what_id', o.Id);
        ApexPages.currentPage().getParameters().put('followup', '1');
        ApexPages.currentPage().getParameters().put('tsk5', 'Chat');
        ApexPages.currentPage().getParameters().put('tsk10', 'Chat');
        ApexPages.currentPage().getParameters().put('retURL', '/'+o.Id);
        
        Log_An_Activity_Controller laac = new Log_An_Activity_Controller();
        System.Test.stopTest();
        
    }
    
    static testMethod void noPageTitleTest() {
        // TO DO: implement unit test
        
        Test.startTest();
        Account a = new Account();
        a.Name = 'test srp458';
        
        insert a;
        
        Contact c = new contact();
        c.firstName = 'test srp458';
        c.lastName = 'test srp458';
        c.Email = 'testsrp458@test.com';
        c.Phone = '1234567890';
        c.accountId = a.Id;
        
        insert c;
        
        Opportunity o = new Opportunity();
        o.Student__c = c.Id;
        o.Name = 'test srp458';
        o.CloseDate = DateTime.now().date();
        o.AccountId = a.Id;
        o.stageName = 'New Inquiry';
        
        insert o;
        
        Task t1 = new Task();
        t1.Subject = 'testsrp458';
        t1.Type = 'Chat';
        t1.ActivityDate = DateTime.now().date();
        t1.Priority = 'Normal';
        
        insert t1;
        
        PageReference pageRef = Page.Log_An_Activity;
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('pageSubtitle', 'Edit Task');
        ApexPages.currentPage().getParameters().put('title', 'Log a Chat');
        ApexPages.currentPage().getParameters().put('who_id', c.Id);
        ApexPages.currentPage().getParameters().put('what_id', o.Id);
        ApexPages.currentPage().getParameters().put('followup', '1');
        ApexPages.currentPage().getParameters().put('tsk5', 'Chat');
        ApexPages.currentPage().getParameters().put('tsk10', 'Chat');
        ApexPages.currentPage().getParameters().put('retURL', '/'+o.Id);
        ApexPages.currentPage().getParameters().put('save_new_url', EncodingUtil.urlEncode('pageTitle=Log a Chat','UTF-8'));
        
        Log_An_Activity_Controller laac = new Log_An_Activity_Controller();
        laac.refreshTabInConsole('test');
        System.Test.stopTest();
        
    }
}