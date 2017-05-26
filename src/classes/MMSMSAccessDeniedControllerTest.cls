@IsTest
public class MMSMSAccessDeniedControllerTest {
    public static testMethod void Test() {
        Test.startTest();
        
        MMSMSAccessDeniedController cntrl = new MMSMSAccessDeniedController();
        PageReference pageRef = Page.mmsmsaccessdenied;
        Test.setCurrentPage(pageRef);
        
        cntrl.initPage();
        
        Test.stopTest();
    }
}