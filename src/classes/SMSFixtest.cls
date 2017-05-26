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
private class SMSFixtest { 

    static testMethod void testupdateContactsToNO() {
      /*  List<Contact> contactList = new List<Contact>();
        Account insertAccount = new Account();
        insertAccount.Goldmine_Key5__c = 'TestAccount';
        insertAccount.Name = 'Test Account';
        insert insertAccount;
        
        Integer count = 0;
        while(count < 10){
            Contact c = new Contact();
            c.FirstName = 'test'+String.valueOf(count);
            c.LastName= 'test'+String.valueOf(count);
            contactList.add(c);
            count++;
        }
        insert contactList;
        List<Id> tempList = new List<Id>();
        Integer countThis = 0;
        for(Contact c : contactList ){
            if(countThis < 5){
                tempList.add(c.Id);
            }
        countThis++; 
        }
       String query = PHASE2_SMS_FIX.constructQuery(tempList, 'TestAccount', insertAccount.id, null);
       System.Debug('VS -- QUERY = '+query);*/
    }
}