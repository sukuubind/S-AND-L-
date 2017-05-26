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
private class EloquaUtilsTest {

    static testMethod void testIsActivityAcceptable() {
        Test.startTest();
        ELQA_Marketing_Activity__c elqa = new ELQA_Marketing_Activity__c();
        boolean isAcceptable = EloquaUtils.isActivityAcceptable(elqa);
        System.AssertEquals(true, isAcceptable);
        
        Contact c = insertContact(null);
        elqa = new ELQA_Marketing_Activity__c();
        elqa.Contact__c = c.Id;
        isAcceptable = EloquaUtils.isActivityAcceptable(elqa);
        System.AssertEquals(false, isAcceptable);
        
        Person__c person = insertPerson();
        elqa = new ELQA_Marketing_Activity__c();
        elqa.Person__c = person.Id;
        isAcceptable = EloquaUtils.isActivityAcceptable(elqa);
        System.AssertEquals(true, isAcceptable);
        Test.stopTest();
        
        
    }
    
    static testMethod void testgetFederalSchoolCode(){
        String subject = 'EmailSent: 123098-anytext can go here';
        String schoolCode = EloquaUtils.getFederalSchoolCode(subject);
        System.AssertEquals('123098', schoolCode);
        
        subject = 'Unsubscribe: 123098-anytext can go here';
        schoolCode = EloquaUtils.getFederalSchoolCode(subject);
        Boolean uns = EloquaUtils.isUnsubscribe(subject);
        System.AssertEquals('123098', schoolCode);
        
        subject = 'EmailSent: anyte can go here. We are breaking it';
        schoolCode = EloquaUtils.getFederalSchoolCode(subject);
        System.AssertEquals('', schoolCode);
        
        subject = 't: anyte can go here. We are breaking it';
        schoolCode = EloquaUtils.getFederalSchoolCode(subject);
        System.AssertEquals('', schoolCode);
    }
    
    static testmethod void testmapCodeToSchool(){
        Test.startTest();
        List<Account> accountList = insertAccount(false, 5);
        List<Account> schoolList = [Select Id, Federal_School_Code_No__c from Account where Id IN :accountList ];
        Map<String, Id> schoolCodeToSchool  =EloquaUtils.mapCodeToSchool(schoolList);
        
        System.AssertEquals(5, schoolCodeToSchool.size());
        System.AssertEquals(schoolList.get(0).Id, schoolCodeToSchool.get(schoolList.get(0).Federal_School_Code_No__c) );
        Test.stopTest();
        
        
    
    }
    static testmethod void testmapCodeToSchool1(){
        Test.StartTest();
        List<Account> accountList = insertAccount(true, 5);
        List<Account> schoolList = [Select Id, Federal_School_Code_No__c from Account where Id IN :accountList ];
        Map<String, Id> schoolCodeToSchool  =EloquaUtils.mapCodeToSchool(schoolList);
        
        System.AssertEquals(4, schoolCodeToSchool.size());
        System.AssertEquals(schoolList.get(0).Id, schoolCodeToSchool.get(schoolList.get(0).Federal_School_Code_No__c) );
        test.stopTest();
    }
    
   static testmethod void testfindSchoolswithSchoolCode(){
    test.startTest();
    List<Account> accountList = insertAccount(false, 5);
    List<String> federalSchoolCode = new List<String>();
    for(Integer i=0;i<5;i++){
        federalSchoolCode.add('65432'+Integer.valueOf(i));
    }
    List<Account> returnSchools = EloquaUtils.findSchoolswithSchoolCode(federalSchoolCode);
    
    System.AssertEquals(accountList.size(), returnSchools.size());
    
    
    
    test.stopTest();
   }
   static testmethod void testfindRecordType(){
        List<String> recordTypeNames = new List<String>();
      //  recordTypeNames.add('Rasmussen Student');
        recordTypeNames.add('Deltak Student');
        
        List<RecordType> recordTypeList = EloquaUtils.findRecordTypes(recordTypeNames);
        
        System.AssertEquals(1, recordTypeList.size());
        
        
        
   }
  /* static testmethod void testfindContact(){
        
        List<Account> accountList = insertAccount(false, 1);
        Contact c = insertContact(accountList.get(0).Id);
        ELQA_Marketing_Activity__c activity = new ELQA_Marketing_Activity__c();
        Map<ELQA_Marketing_Activity__c, String> activityToSchoolCode = new Map<ELQA_Marketing_Activity__c, String>();
        activityToSchoolCode.put(activity, '654321');
        
        List<Account> schoolList = [Select Id, Federal_School_Code_No__c from Account where Id IN :accountList ];
        Map<String, Id> schoolCodeToSchool  =EloquaUtils.mapCodeToSchool(schoolList);
        
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('Rasmussen Student');
        recordTypeNames.add('Deltak Student');
        List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordTypeNames ];
        
        Map<ELQA_Marketing_Activity__c, Id> activityToContact = EloquaUtils.findContacts(activityToSchoolCode, schoolCodeToSchool, recordTypes);
        
        System.AssertEquals(c.Id, activityToContact.values().get(0));
        
        
        
         
   }*/
   
   
    
    public static List<Account> insertAccount(boolean failfew, Integer count){
        List<Account> accountList = new List<Account>();
        List<Federal_College_Lists__c> college_List = new List<Federal_College_Lists__c>();
        
        for(Integer i=0;i<count; i++){
            Federal_College_Lists__c college = new Federal_College_Lists__c();
            college.Name = 'School'+String.valueOf(i);
            college.Federal_School_Code__c = '65432'+Integer.valueOf(i);
            college_List.add(college);
        }
        insert college_List;
        
        for(Integer i=0;i<count;i++){
        
        Account a = new Account();
            a.Goldmine_key5__c = 'SHU11'+Integer.valueOf(i);
            a.Name = 'Test'+Integer.valueOf(i);
            a.Type = 'Deltak Partner';
            if(!(failfew && i == 2)){
                a.Federal_College_List__c = college_List.get(i).Id;
            }
            
            accountList.add(a);
        }
        insert accountList;
        
        return accountList;
    }
    
    public static Contact insertContact(String accountId){
        Contact c = new Contact();
        c.LastName= 'Last Name';
        c.FirstName = 'FirstName';
        List<RecordType> rec = [Select Id from RecordType where Name = 'Deltak Student'];
        c.RecordTypeId = rec[0].Id;
        if(accountId != null)
            c.AccountId = accountId;
        
        insert c;
        
        return c;
    }
    public static Person__c insertPerson(){
        Person__c person = new Person__c();
        person.Last_Name__c = 'Last Name';
        person.First_Name__c = 'First Name';
        person.RasId__c = 'Ras Id';
        insert person;
        return person;
     }
    
}