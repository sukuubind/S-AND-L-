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
@isTest private class JIRAConnectorWebserviceCalloutSyncTest {
 
    // Tests synchronizeWithJIRAIssue method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void synchronizeWithJIRAIssueTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(TestFixture.baseUrl, TestFixture.systemId, TestFixture.objectType, TestFixture.caseId);
        Test.stopTest();
    }
 
    // Tests buildRequest method in JIRAConnectorWebserviceCalloutSync.
    static testMethod void buildRequestTest() {
        HttpRequest req = JIRAConnectorWebserviceCalloutSync.buildRequest(TestFixture.baseUrl, TestFixture.username,
                TestFixture.password, TestFixture.systemId, TestFixture.objectType, TestFixture.caseId);
        System.assertEquals(req.getMethod(), 'PUT');
        System.assertEquals(req.getEndpoint(), 'https://tracker.engagelms.com/rest/customware/connector/1.0/3/Case/1/issue/synchronize.json');
    }
 
    // Tests SynchronizeWithJIRAIssue trigger.
    static testMethod void synchronizeWithJIRAIssueTriggerTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        // insert case
        Case case1 = new Case();
        insert case1;
 
        //update case
        case1.Description = 'updated case description';
        update case1;
    }
 
    // Tests caseCommentSync trigger.
    static testMethod void caseCommentSyncTriggerTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseJIRAConnector());
        // insert case
        Case case1 = new Case();
        insert case1;
 
        // insert casecomment
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = case1.id;
        insert caseComment;   
    }
     
}