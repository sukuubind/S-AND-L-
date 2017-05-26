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
private class Post_Chat_Form_ControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        System.currentPageReference().getParameters().put('chatKey', 'livechatagentsessionkey');
        
        Post_Chat_Form_Controller pcfc = new Post_Chat_Form_Controller();
        
        pcfc.saveFeedback();
        
        pcfc.lcf.Overall_Chat_Experience__c = 'Excellent';
        pcfc.lcf.Experience_with_Chat_Agent__c = 'Excellent';
        pcfc.lcf.Alternate_Contact_Method__c = 'Phone';
        
        pcfc.saveFeedback();
        
        pcfc.lcf.Transcript_ChatKey__c = null;
        
        pcfc.saveFeedback();
        
    }
}