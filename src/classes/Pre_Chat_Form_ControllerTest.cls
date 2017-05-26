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
private class Pre_Chat_Form_ControllerTest {

    static testMethod void testGetAcademicPrograms(){
        Pre_Chat_Form_Controller pcfc = new Pre_Chat_Form_Controller();
        System.AssertNotEquals(null, pcfc.getAcademicPrograms());
        
        pcfc.modality = 'Modality';
        pcfc.checkInputs();
        
        pcfc.academicProgram = 'Program of Interest';
        pcfc.checkInputs();
        
        pcfc.modality = 'On-Ground';
        pcfc.checkInputs();
        
        List<SelectOption> programsList = pcfc.getAcademicPrograms();
        if(programsList != null && programsList.size() > 0){
            String programId = programsList[0].getValue();
            pcfc.academicProgram = programid;
            pcfc.refreshModalityList();
        }
        
    }
    
     static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Student Opportunity' LIMIT 1];
        
        RecordType rt1 = [SELECT Id, Name FROM RecordType WHERE NAme = 'Deltak Student' LIMIT 1];
        
        Account a = new Account();
        a.Name = 'Test University';
        a.Abbreviation__c = 'TST';
        insert a;
        
        Contact c = new Contact();
        c.RecordTypeId = rt1.Id;
        c.firstName = 'TestFirstName';
        c.lastName = 'TestLastName';
        c.Email = 'prechat@nomail.com';
    //    c.Email = 'email@email.com';
        c.AccountId = a.Id;
        
        insert c;
        
        Opportunity o = new Opportunity();
        o.RecordTypeId = rt.Id;
        o.Name = 'LiveAgentTest';
        o.AccountId = a.Id;
        o.Student__c = c.Id;
        o.stageName = 'New Inquiry';
        o.closeDate = DateTime.now().addDays(5).date();
        
        insert o;
        
        System.currentPageReference().getParameters().put('endpoint', 'livechatagentendpoint');
        
        Pre_Chat_Form_Controller pcfc = new Pre_Chat_Form_Controller();
        
        pcfc.checkInputs();
        
        pcfc.firstName = 'TestFirstName';
        pcfc.checkInputs();
        
        pcfc.lastName = 'TestLastName';
        pcfc.checkInputs();
        
        pcfc.email = 'emaildfdsfs';
        pcfc.checkInputs();
        
        pcfc.email = 'prechat@nomail.com';
    //    pcfc.email = 'email@email.com';
        pcfc.checkInputs();
        
        pcfc.organization = 'TST';
        pcfc.checkInputs();
        
        System.AssertEquals(o.Id,pcfc.opportunityId);
        
        pcfc.opportunityId = '';
        
        Opportunity o2 = new Opportunity();
        o2.RecordTypeId = rt.Id;
        o2.Name = 'LiveAgentTest2';
        o2.AccountId = a.Id;
        o2.Student__c = c.Id;
        o2.stageName = 'New Inquiry';
        o2.closeDate = DateTime.now().addDays(5).date();
        
        insert o2;
        
        pcfc.checkInputs();
        
        pcfc.opportunityId = '';
        
        o.stageName = 'Dormant';
        o.Sub_Stage__c = 'Not Interested';
        
        update o;
        
        o2.stageName = 'Dormant';
        o2.Sub_Stage__c = 'Not Interested';
        update o2;
        
        pcfc.checkInputs();
        
    }
}