@IsTest
public class MMSettingsTest {
   public static testMethod void Test() {
      Test.startTest();
      
      MMSettings m = new MMSettings();
      m.setUserId('u');
      m.setPassword('p');
      m.setDialCode('1');
      m.setNotifyTo('f@msn.com');
      System.assertEquals('u',m.getUserId());
      System.assertEquals('p',m.getPassword());
      System.assertEquals('1',m.getDialCode());
      System.assertEquals('f@msn.com',m.getNotifyTo());
      
      m = new MMSettings('u1','p1','2');
      System.assertEquals('u1',m.getUserId());
      System.assertEquals('p1',m.getPassword());
      System.assertEquals('2',m.getDialCode());

      m = new MMSettings('u1','p1','2','f@msn.com');
      
      Test.stopTest();       
   }
}