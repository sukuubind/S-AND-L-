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
private class ProspectUtilsTest {

    static testMethod void testBuildMapOfRecords() {
        List<Account> aList = new List<Account>();
        Account a = new Account();
        a.name = 'ProspectTestAccount';
       aList.add(a);
       a = new Account();
        a.name = 'ProspectTestAccount-1';
       aList.add(a);
       insert aList;
       
       Map<Id, SObject> returnMap = ProspectUtils.buildMapofRecords(aList);
       System.AssertEquals(aList.size(), returnMap.size());
       
    }
    static testMethod void testconstructFinalListSObject(){
        List<Account> aList = new List<Account>();
        
        for(Integer i =0;i<4;i++){
            Account a = new Account();
                a.name = 'ProspectTestAccount'+String.valueOf(i);
               aList.add(a);
        }
        insert aList;
        List<Id> list1 = new List<Id>();
        list1.add(aList[0].Id);
        list1.add(aList[1].Id);
        
        List<Id> list2 = new List<Id>();
        list2.add(aList[2].id);
        list2.add(aList[3].id);
        
        List<Id> combinedList = ProspectUtils.constructFinalListSObject(list1, list2);
        System.AssertEquals(list1.size()+list2.size(), combinedList.size());
        
    }
    
    static testMethod void testGetFieldsAndGetFieldMap(){
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.programLabelString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.srpprogramLabelString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.srpspecializationLabelString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.specializationLabelString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.accountString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.contactLabelString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.campaignLabelString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.opportunityString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.termLabelString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.srptermLabelString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.parentcampaignString, false));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.accountString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.contactLabelString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.campaignLabelString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.opportunityString, true));
        System.AssertNotEquals(null, ProspectUtils.getFieldMap(ProspectConstants.parentcampaignString, true));
        //System.AssertNotEquals(null, ProspectUtils.getFieldMap('', true));
    }
    static testMethod void testIsSRPObjectAnd(){
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.srpprogramLabelString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.srpspecializationLabelString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.srptermLabelString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.accountString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.contactLabelString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.campaignLabelString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.opportunityString));
        System.AssertEquals(true, ProspectUtils.isSRPObject(ProspectConstants.parentcampaignString));
        
        System.AssertEquals(false, ProspectUtils.isSRPObject(ProspectConstants.programLabelString));
        System.AssertEquals(false, ProspectUtils.isSRPObject(ProspectConstants.specializationLabelString));
        System.AssertEquals(false, ProspectUtils.isSRPObject(ProspectConstants.termLabelString));
        System.AssertEquals(null, ProspectUtils.isSRPObject(''));
        
        System.AssertEquals(false, ProspectUtils.isSRMObject(ProspectConstants.srpprogramLabelString));
        System.AssertEquals(false, ProspectUtils.isSRMObject(ProspectConstants.srpspecializationLabelString));
        System.AssertEquals(false, ProspectUtils.isSRMObject(ProspectConstants.srptermLabelString));
        
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.programLabelString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.specializationLabelString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.accountString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.contactLabelString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.campaignLabelString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.opportunityString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.termLabelString));
        System.AssertEquals(true, ProspectUtils.isSRMObject(ProspectConstants.parentcampaignString));
        System.AssertEquals(null, ProspectUtils.isSRMObject(''));
    }
    static testMethod void testgetObjectAPIName(){
        System.AssertEquals(ProspectConstants.programString, ProspectUtils.getObjectAPIName(ProspectConstants.programLabelString));
        System.AssertEquals(ProspectConstants.srpprogramString, ProspectUtils.getObjectAPIName(ProspectConstants.srpprogramLabelString));
        System.AssertEquals(ProspectConstants.srpspecializationString, ProspectUtils.getObjectAPIName(ProspectConstants.srpspecializationLabelString));
        System.AssertEquals(ProspectConstants.specializationString, ProspectUtils.getObjectAPIName(ProspectConstants.specializationLabelString));
        System.AssertEquals(ProspectConstants.accountString, ProspectUtils.getObjectAPIName(ProspectConstants.accountString));
        System.AssertEquals(ProspectConstants.contactString, ProspectUtils.getObjectAPIName(ProspectConstants.contactLabelString));
        System.AssertEquals(ProspectConstants.campaignString, ProspectUtils.getObjectAPIName(ProspectConstants.campaignLabelString));
        System.AssertEquals(ProspectConstants.opportunityString, ProspectUtils.getObjectAPIName(ProspectConstants.opportunityString));
        System.AssertEquals(ProspectConstants.termString, ProspectUtils.getObjectAPIName(ProspectConstants.termLabelString));
        System.AssertEquals(ProspectConstants.srptermString, ProspectUtils.getObjectAPIName(ProspectConstants.srptermLabelString));
        System.AssertEquals(ProspectConstants.campaignString, ProspectUtils.getObjectAPIName(ProspectConstants.campaignString));
        System.AssertEquals(null, ProspectUtils.getObjectAPIName(''));  
    }
    static testMethod void testGetAccountTypeAndGetAccountOwnerID(){
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Account;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('SRP Account');
        Id recTypeId = rt.getRecordTypeId();
        Account a = new Account();
        a.name = 'TestProspectAccount';
        a.RecordTypeId = recTypeId;
        insert a;
        Boolean result = ProspectUtils.getAccountType(a.Id);
        System.AssertEquals(true, result);
        Id ownerId = ProspectUtils.getAccountOwner(a.Id);
        System.AssertEquals(UserInfo.getUserId(), ownerId);
    
    }
    static testMethod void testGetTeamDetails(){
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Account;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('SRP Account');
        Id recTypeId = rt.getRecordTypeId();
        Account a = new Account();
        a.name = 'TestProspectAccount';
        a.RecordTypeId = recTypeId;
        insert a;
        Team__c team = new Team__c();
        team.Team_Name__c = 'TestTeam'; 
        insert team;
        List<Team__c> teamList = ProspectUtils.getTeamDetails(a.Id);
        System.AssertEquals(1,teamList.size());
        
    }
    static testMethod void testfindLeadRouterFieldSetForSObject(){
        System.AssertNotEquals(null, ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.programLabelString, false));
    }
    static testMethod void testbuildAndRunQuery(){
        Set<String> fieldNames = new Set<String>();
        fieldNames.add('Id');
        fieldNames.add('Name');
        String sObjectName = 'Account';
        List<Account> aList = new List<Account>();
        
        for(Integer i =0;i<4;i++){
            Account a = new Account();
                a.name = 'ProspectTestAccount'+String.valueOf(i);
               aList.add(a);
        }
        insert aList;
        List<id> whereclauseIds = new List<Id>();
        for(Account a : aList){
            whereclauseIds.add(a.id);
        }
        String whereFieldName = 'Id';
        System.AssertNotEquals(null, ProspectUtils.buildAndRunQuery(fieldNames, SObjectName, whereclauseIds, null, whereFieldName));
    }
}