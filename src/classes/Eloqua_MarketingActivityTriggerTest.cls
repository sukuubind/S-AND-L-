/**
Venkat Santhanam - 11/17/2010 Adding Version Header
**/
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
@isTest(seealldata=true)
private class Eloqua_MarketingActivityTriggerTest {

    static testMethod void testLossSurveyResults(){
        Test.starttest();
        
        
        List<Account> accountList = insertAccount(false, 1);
        DeltakSRP__Person__c p = insertPerson();
        Contact c = insertContact(accountList.get(0).Id, p);
        
       
        List<ELQA_Marketing_Activity__c> elqaList = new List<ELQA_Marketing_Activity__c>();
        ELQA_Marketing_Activity__c elqa = new ELQA_Marketing_Activity__c();
        elqa.Name = 'LossSurvey: 654320-Test it';
        elqa.Activity_Type__c = 'LossSurvey:';
        elqa.SRP_Person__c = p.Id;
        elqa.Activity_Detail__c = '1234;2345;3456;4567';
        elqaList.add(elqa);

        elqa = new ELQA_Marketing_Activity__c();
        elqa.Name = 'Unsubscribe: 654320-Test it';
        elqa.Activity_Type__c = 'Unsubscribe: :';
        elqa.SRP_Person__c = p.Id;
        elqa.Activity_Detail__c = '1234;2345;3456;4567';
        elqaList.add(elqa); 
        insert(elqaList);
        
        
        Test.stopTest();
    }
    static testMethod void myUnitTest() {
        
        Test.StartTest();
        List<Account> accountList = insertAccount(false, 1);
        DeltakSRP__Person__c p = insertPerson();
        Contact c = insertContact(accountList.get(0).Id, p);
        
        
        List<ELQA_Marketing_Activity__c> elqaList = new List<ELQA_Marketing_Activity__c>();
        ELQA_Marketing_Activity__c elqa = new ELQA_Marketing_Activity__c();
        elqa.Name = 'EmailSent: 654320-Test it';
        elqa.Activity_Type__c = 'Email Sent';
        elqa.SRP_Person__c = p.Id;
        elqaList.add(elqa);

        elqa = new ELQA_Marketing_Activity__c();
        elqa.Name = 'EmailSent: 654320-Test it';
        elqa.Activity_Type__c = 'Email Sent';
        elqa.SRP_Person__c = p.Id;
        elqaList.add(elqa); 
        insert(elqaList);
        
        List<Id> eloquaIdList = new List<Id>();
        for(ELQA_Marketing_Activity__c thisact : elqaList){
        eloquaIdList .add(thisact.id);
        }

        List<ELQA_Marketing_Activity__c> activityList = [Select Id, Contact__c, SRP_Person__c from ELQA_Marketing_Activity__c where Id IN :eloquaIdList ];
        System.AssertEquals(2, activityList.size());
        
        /*System.AssertEquals(c.Id, activityList.get(0).Contact__c);
        System.AssertEquals(null, activityList.get(0).Person__c);
  
        System.AssertEquals(null, activityList.get(1).Contact__c);
        System.AssertEquals(null, activityList.get(1).Person__c); */
    
        
        
        Test.Stoptest();
    }
    
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
        List<RecordType> rec = [Select Id from RecordType where Name = 'SRP Academic Institution'];
        
        for(Integer i=0;i<count;i++){
        
        Account a = new Account();
            a.Goldmine_key5__c = 'SHU11'+Integer.valueOf(i);
            a.Name = 'Test'+Integer.valueOf(i);
            a.Type = 'Deltak Partner';
            a.RecordTypeId = rec[0].ID; 
            if(!(failfew && i == 2)){
                a.Federal_College_List__c = college_List.get(i).Id;
            }
            
            accountList.add(a);
        }
        insert accountList;
        
        return accountList;
    }
    
    public static Contact insertContact(String accountId, DeltakSRP__Person__c p){
        Contact c = new Contact(); 
        c.LastName= 'Last Name';
        c.FirstName = 'FirstName';
        List<RecordType> rec = [Select Id from RecordType where Name = 'SRP Student'];
        c.RecordTypeId = rec[0].Id;
        if(accountId != null)
            c.AccountId = accountId;
        if(p != null)
            c.DeltakSRP__Person__c = p.Id;
        insert c;
        System.Debug('inserted contact -- '+c);
        return c;
    }
    public static DeltakSRP__Person__c insertPerson(){
        DeltakSRP__Person__c person = new DeltakSRP__Person__c();
        person.DeltakSRP__Last_Name__c = 'Last Name';
        person.DeltakSRP__First_Name__c = 'First Name';
        //person.RasId__c = 'Ras Id';
        insert person;
        return person;
     }
}