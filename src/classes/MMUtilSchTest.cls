@IsTest
public class MMUtilSchTest {
   public static testMethod void Test() {
      Test.startTest();
     
      MMGroupSMS__c grp = createGroupSMS('12,34,56,78,90');
      MMGroupSMSJob__c job = null;
      string ids = '';
      
      System.assertEquals(0,MMUtilSch.getNextJobIndex(grp.Id));
      System.assertEquals(true,MMUtilSch.getJobs(grp.Id).size() == 0);
      System.assertEquals(null,MMUtilSch.getJob(grp.Id, 1));
      ids = '12,34';
      job = MMUtilSch.insertJob(grp.Id, ids.split(','),false);
      ids = '56,78';
      job = MMUtilSch.insertJob(grp.Id, ids.split(','),false);

      System.assertEquals(2,MMUtilSch.getNextJobIndex(grp.Id));
      System.assertEquals(true,MMUtilSch.getJobs(grp.Id).size() == 2);
      System.assertEquals('56,78',MMUtilSch.getJob(grp.Id, 2).Ids__c);
      
      MMUtilSch.deleteJobs(grp.Id);
      System.assertEquals(true,MMUtilSch.getJobs(grp.Id).size() == 0);
      
      MMUtilSch.storePreviousJobId(null);
      System.assertEquals(true,MMUtilSch.getPreviousJobId().PreviousJobId__c == null);
      MMUtilSch.storePreviousJobId('123');
      System.assertEquals(true,MMUtilSch.getPreviousJobId() != null);
      MMUtilSch.storePreviousJobId('231');
      System.assertEquals('231',MMUtilSch.getPreviousJobId().PreviousJobId__c);
      
      job = MMUtilSch.insertJob(grp.Id, ids.split(','),true);
      System.assertEquals(true, MMUtilSch.getJob(grp.Id).IsScheduled__c);
      
      MMUtilSch.storePreviousBatchJobId('ij001', true);
      System.assertEquals(true, MMUtilSch.getPreviousBatchJobId().PreviousJobId__c == 'ij001');
      
      System.assertEquals(true, MMUtilSch.getAvailableGroupSMS(datetime.now()).size() == 0);
      System.assertEquals(true, MMUtilSch.getAvailableGroupImmediateSMS(Datetime.now()).size() == 0);
      
      MMUtilSch.logMessage('test');
 
      grp = createGroupSMS('12,34,56,78,90');
      ids = '12,34,56,78,90';     
      job = MMUtilSch.insertJob(grp.Id, ids.split(','),true,1);
      job.InProcess__c = true;
      insert job;
      System.assertEquals(true, MMUtilSch.getJobById(job.Id).JobIndex__c == 1);
      
      MMUtilSch.setJobInProcess(job.Id, true);
      System.assertEquals(true, MMUtilSch.IsAnyJobInProcess(grp.Id));
      System.assertEquals(true, MMUtilSch.getGroupById(grp.Id).SelectedIds__c == '12,34,56,78,90');
      System.assertEquals('12,34,56,78,90,', MMUtilSch.getSelectedIdsForGroup(grp.Id));
      
      Test.stopTest();
   }
   public static MMGroupSMS__c createGroupSMS(string selectedIds) {
       MMGroupSMS__c grp = new MMGroupSMS__c();
       grp.SelectedIds__c = selectedIds;
       grp.IsScheduled__c = true;
       insert grp;
       return grp;
   }
}