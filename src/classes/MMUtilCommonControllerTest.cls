@IsTest
public class MMUtilCommonControllerTest {
   public static testMethod void Test() {
      Test.startTest();
      MMUtilCommonController cntrl = new MMUtilCommonController();
      PageReference pageRef = Page.mmutilcommon;
      Test.setCurrentPage(pageRef);

      cntrl.autoRun();
      System.assertEquals('ERROR: PLEASE PROVIDE RQ PARAMETER',cntrl.getMmResponse());
      
      ApexPages.currentPage().getParameters().put('rq','getreceiptno');
      cntrl.autoRun();
      System.assertNotEquals('',cntrl.getMmResponse());
      
      ApexPages.currentPage().getParameters().put('rq','getreceiptno');
      ApexPages.currentPage().getParameters().put('size','10');      
      cntrl.autoRun();      
      System.assertNotEquals('',cntrl.getMmResponse());
      
      Test.stopTest();       
   }
}