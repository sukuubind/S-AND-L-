@IsTest
public class MMTaskSMSControllerExtensionTest {
   public static testMethod void Test() {
      Test.startTest();
      Contact c = createAffiliation();
      Task t = createTask(c.Id, 'af', UserInfo.getUserId());
      MM_SMS_Log__c log =  MMUtilLog.createSMSLog('S001', 'Standard', c.Id, 'af','443453031719','0_a',false,System.now(),
                                                  'Outbound','Test SMS','XX', t.Id);
      insert log;
      ApexPages.StandardController sc = new ApexPages.StandardController(t);
      MMTaskSMSControllerExtension cntrl = new MMTaskSMSControllerExtension(sc);
      sc.view();
      System.assertEquals('Outbound',cntrl.getSmsType());
      System.assertEquals('443453031719',cntrl.getSmsPhone());
      System.assertEquals('Test SMS',cntrl.getSmsMessage());      
      
      t = createTask(c.Id, 'af', UserInfo.getUserId());
      log =  MMUtilLog.createSMSLog('S001', 'Standard', c.Id, 'af','443453031719','0_a',false,System.now(),
                                                  'Outbound','','XX', t.Id);
      insert log;
      sc = new ApexPages.StandardController(t);
      cntrl = new MMTaskSMSControllerExtension(sc);
      sc.view();
      System.assertEquals('Outbound',cntrl.getSmsType());
      System.assertEquals('443453031719',cntrl.getSmsPhone());
      System.assertEquals('BLANK',cntrl.getSmsMessage());
      
      t = createTask(c.Id, 'af', UserInfo.getUserId());
      sc = new ApexPages.StandardController(t);
      cntrl = new MMTaskSMSControllerExtension(sc);
      sc.view();
      System.assertEquals('N/A',cntrl.getSmsType());
      System.assertEquals('N/A',cntrl.getSmsPhone());
      System.assertEquals('BLANK',cntrl.getSmsMessage());
      
      Test.stopTest();       
   }
   public static Contact createAffiliation() {
       Contact c = new Contact(FirstName = 'Test', LastName = 'Affiliation');
       insert c;
       return c;
   }
   public static Task createTask(Id entityId, string entityType, Id userId) {
       Task t = MMUtils.createTask(entityId, entityType, 'Test SMS', 'Pending', true, false); 
       insert t;
       return t;
   }
}