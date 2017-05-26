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
private class EloquaShareCountPersisterTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Map<Id, Integer> idToInteger = new Map<Id, Integer>();
        Contact c = new Contact();
        c.LastName = 'Last Name';
        c.FirstName = 'First Name';
        insert c;
        
        idToInteger.put(c.Id, 2);
        List<Contact> contactResponse = EloquaShareCountPersister.fetchContactForId(idToInteger);
        
        System.AssertEquals(1, contactResponse.size());
        System.AssertEquals(c.Id, contactResponse[0].id);
    }
    static testMethod void testEloquaContactUpdateWithEmail(){
    	Map<String, Integer> idToInteger = new Map<String, Integer>();
        Contact c = new Contact();
        c.LastName = 'Last Name';
        c.FirstName = 'First Name';
        c.Email = 'Dummy@Dummy.com';
        insert c;
        
        idToInteger.put(c.Email, 2);
        List<Contact> contactResponse = EloquaShareCountPersister.fetchContactForEmail(idToInteger);
        
        System.AssertEquals(1, contactResponse.size());
        System.AssertEquals(c.Id, contactResponse[0].id);
    }
}