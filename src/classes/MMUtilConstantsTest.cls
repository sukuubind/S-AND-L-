@IsTest
public class MMUtilConstantsTest {
   public static testMethod void Test() {
      Test.startTest();
      
      System.assertEquals('',MMUtilConstants.mm_userid);
      System.assertEquals('',MMUtilConstants.mm_password);
      System.assertNotEquals('',MMUtilConstants.smsURL);            
      MMUtilConstants.getPublicUrl();
      MMUtilConstants.getReplyUrl();  
      System.assertNotEquals('',MMUtilConstants.xmlContentType);  
      MMUtilConstants.getPageSize(); 
      MMUtilConstants.getDefaultEmail();
      MMUtilConstants.getDefaultName();       
      
      Test.stopTest();       
   }
}