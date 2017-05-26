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
private class RasReportLeadFailureTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        RasReportLeadFailure lead_failure = new RasReportLeadFailure();
        LeadProcessor.LeadRouter_AdditionalFields addedFields = new LeadProcessor.LeadRouter_AdditionalFields();
        addedFields.Company = 'Company';
        addedFields.filename = 'filename';
        addedFields.Key1 = 'Key1';
        addedFields.Key2 = 'Key2';
        addedFields.Key5 = 'Key5';
        addedFields.notes = 'notes';
        addedFields.Other_Colleges = 'Other_Colleges';
        addedFields.phone3 = 'phone3';
        addedFields.Program = 'Program';
        addedFields.Program2 = 'Program2';
        addedFields.R_Campaign = 'R_Campaign';
        addedFields.Referal = 'Referal';
        addedFields.Source = 'Source';
        addedFields.UADCAMPGN = 'UADCAMPGN';
        addedFields.UADGROUP = 'UADGROUP';
        addedFields.UCAMPGNTYP = 'ICAMPGNTYP';
        addedFields.ucampus = 'ucampus';
        addedFields.udescribe = 'udescribe';
        addedFields.uhowheard = 'uhowheard';
        addedFields.uhscode = 'uhscode';
        addedFields.UINTLEAD = 'UINTLEAD';
        addedFields.UOptOutCam = 'UOptoutCam';
        addedFields.UrefKeyWrd = 'URefKeyWrd';
        addedFields.urefrdby = 'ureferdby';
        addedFields.urefurl = 'urefurl';
        addedFields.utextperm = 'utextperm';
        Boolean duplicateOpportunity = true;
        Id failure = lead_failure.createFailureRecord( 'GMId','ContactName', 'Address1','Address2', 'City', 'State', 'Zip', 'Phone1', 
                                                      'Phone2', 'Email','Gender','BestTime',' Program', 'CourseInterest', 
                                                      'HSGradYear', 'newKey5','DateCreated', 'HighLevel', 'newKey4', 
                                                      'Company', 'Title', 'Source', 'UModality', 'UIMType', 'UMName', 
                                                      'RasId', 'OwnerId', 'referredByOpportunity', 'referredByPerson', 
                                                      'TransferredFromOpportunity', duplicateOpportunity, addedFields);
        System.AssertNotEquals(null, failure);
        //lead_failure.notifyFailure('message', failure);
        List<Case> caseList = [Select id from Case where Lead_Failure__c = :failure];
       // System.AssertEquals(1, caseList.size());
    }
}