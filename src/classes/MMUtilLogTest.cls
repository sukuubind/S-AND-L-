@IsTest
public class MMUtilLogTest {
   public static testMethod void Test() {
      Test.startTest();
      Contact c = createAffiliation();
      Id taskId = createTask(c.Id, 'af', UserInfo.getUserId());
      MM_SMS_Log__c log =  MMUtilLog.createSMSLog('S001', 'Standard', 'R001','af','443453031719','0_a',false,System.now(),
                                                  'Outbound','Test SMS','XX', taskId);
      insert log;
      Id logId = log.Id;
      
      log = MMUtilLog.updateSMSLog(logId, 'S001', 'Standard', 'R001', 'af', '443453031719','0_a',false,System.now(),
                                                  'Outbound','Test SMS 1','XX',taskId);
      
      log = MMUtilLog.getSMSLog(logId);
      System.assertEquals('Test SMS 1',log.Message__c);
      
      log = MMUtilLog.getSMSLogByTaskId(taskId);
      System.assertEquals(logId, log.Id);
      
      Test.stopTest();       
   }
   public static Contact createAffiliation() {
       Contact c = new Contact(FirstName = 'Test', LastName = 'Affiliation');
       insert c;
       return c;
   }
   public static Id createTask(Id entityId, string entityType, Id userId) {
       Task t = MMUtils.createTask(entityId, entityType, 'Test SMS', 'Pending', true, false); 
       insert t;
       return t.Id;
   }
}