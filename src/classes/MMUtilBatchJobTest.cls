@IsTest
public class MMUtilBatchJobTest {
   public static testMethod void Test() {
      Test.startTest();
      
      MMJobRecordCount__c cnt = null;
      
      MMUtilBatchJob.deleteBatchCount();
      cnt = MMUtilBatchJob.upsertBatchCount(10);
      System.assertEquals(true, cnt.RecordCount__c == 10);
      
      cnt = MMUtilBatchJob.upsertBatchCount(10);
      System.assertEquals(true, cnt.RecordCount__c == 20);
      
      MMUtilBatchJob.resetBatchCount();
      MMUtilBatchJob.stopBatchCount();
      cnt = MMUtilBatchJob.getBatchCount();
      
      //System.assertEquals(true, cnt.RecordCount__c == 0);
      //System.assertEquals(false, cnt.JobInProcess__c);
      
      Test.stopTest();
   }
}