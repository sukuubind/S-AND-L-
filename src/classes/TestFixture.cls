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
@isTest public with sharing class TestFixture {
 
    // All fields in this class are used only in unit tests.
    // No need to change, but make sure to change the unit tests respectively if you change these values.
    public static String baseUrl = 'https://tracker.engagelms.com';
    public static String systemId = '2';
    public static String username = 'SFSync';
    public static String password = 'simpli5_SR';
 
    public static String objectType = 'Case';
    public static String objectId = '1';
    public static String projectKey = 'salesforce';
    public static String issueType = 'bug';
    public static String caseId = '1';
 
    public static String jiraIssueResponseBody = '[{"summary": "Project One", "project": "project one", ' +
        '"reporter": "admin@gmail.com", "key": "PO-1", "status": "open", ' +
        '"resolution": "yes", "url": "www.google.com", "type": "bug", "assignee": "admin", ' +
        '"description": "issue 1", "priority": "high", "due_date": "12-12-2015" },' +
        '{"summary": "Project Two", "project": "project two"}]';
     
}