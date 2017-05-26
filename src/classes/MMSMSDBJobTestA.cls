@IsTest
public class MMSMSDBJobTestA {
   public static testMethod void Test() {
       Test.startTest();
       Contact c1 = createAffiliation('test','a');
       Task t1 = createTask(c1.Id, 'af', UserInfo.getUserId());
       MMSMSReceipt__c r1 = createReceipt(c1.Id, 'af', t1.Id, -100);
       MM_SMS_Log__c log1 = createLog(t1.Id);
       Task t2 = createTask(c1.Id, 'af', UserInfo.getUserId());
       MMSMSReceipt__c r2 = createReceipt(c1.Id, 'af', t2.Id, -101);       
       MM_SMS_Log__c log2 = createLog(t2.Id);
       Task t3 = createTask(c1.Id, 'af', UserInfo.getUserId());
       MMSMSReceipt__c r3 = createReceipt(c1.Id, 'af', t3.Id, -102);       
       MM_SMS_Log__c log3 = createLog(t3.Id);
       
       string now = DateTime.now().format('MM/dd/yyyy');       
       string now1 = DateTime.now().addDays(1).format('MM/dd/yyyy');

       //ID batchId = Database.executeBatch(new MMSMSDbJob('select Id from Task', now + ' 12:00 AM', now + ' 11:59 PM', 's'));
       
       MMSMSDeleteHistoryController delHistory = new MMSMSDeleteHistoryController();
       PageReference pageRef = Page.mmsmsdeletehistory;
       Test.setCurrentPage(pageRef);
       
       delHistory.autoRun();
       
       delHistory.init();
       
       pageRef.getParameters().put('qry','3');
       delHistory.batchStatus();

       pageRef.getParameters().put('qry','3');
       pageRef.getParameters().put('sdt', now);
       pageRef.getParameters().put('edt', now1);
       delHistory.batchExecute(true);
       
       pageRef.getParameters().put('qry','3');
       delHistory.batchStatus();
       
       pageRef.getParameters().put('qry','4');
       delHistory.batchStatus();
       
       pageRef.getParameters().put('qry','3');
       pageRef.getParameters().put('sdt', now);
       pageRef.getParameters().put('edt', now1);
       delHistory.deleteHistory(true);

       delHistory.cancel();

       Test.stopTest();
   }
   public static Contact createAffiliation(string fname, string lname) {
       Contact c = new Contact(FirstName = fname, LastName = lname);
       insert c;
       return c;
   }
   public static Task createTask(Id entityId, string entityType, Id userId) {
       Task t = MMUtils.createTask(entityId, entityType, 'Test SMS', 'Pending', true, false); 
       insert t;
       return t;
   }
   public static MMSMSReceipt__c createReceipt(Id entityId, string entityType, Id taskId, long receiptId) {
       MMSMSReceipt__c r = MMUtils.createSMSReceipt(entityId, entityType,receiptId, false, true, taskId, null, null, '0_a', 
                                   false, 'Test SMS', null, '            +443453031719      ', 'United Kingdom');
       insert r;
       return r;
   }
   public static MM_SMS_Log__c createLog(string taskId) {
       MM_SMS_Log__c log =  MMUtilLog.createSMSLog('S001', 'Standard', 'R001','af','443453031719','0_a',false,System.now(),
                                                  'Outbound','Test SMS','XX', taskId);
       insert log;
       return log;
   }
}