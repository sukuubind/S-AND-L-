@IsTest
public class MMUtilsTestA {
   public static testMethod void Test() {
      Test.startTest();
      Contact c = createAffiliation('Test','Affiliation');
      MMUtils.saveHeaderFooter('head','foot','single','0_a');
      MMUtils.createTask(c.Id, 'af', 'Test message', 'Successful', false, false, UserInfo.getUserId());
      MMAccountStatus status =  MMUtils.getUserAccountStatus(UserInfo.getUserId(), true);
      
      System.assertEquals('', status.getError());
      System.assertNotEquals('', status.getOriginalResponse());
      System.assertEquals('500', status.getSmsLimit());
      System.assertEquals('450', status.getSmsRemaining());
      System.assertEquals('daily', status.getResponseType());
      
      status =  MMUtils.getUserAccountStatus(UserInfo.getUserId(), false);     
      
      System.assertEquals('Pakistan',MMUtils.getCountryByDialCode('92')); 
      
      MMUtils.sendSingleEmail('test@test.com','Test Display Name', 'Test Subject', 'Test Message', (Id)UserInfo.getUserId());
      
      //System.assertEquals(true, MMUtils.generateReceiptNumber() > 0);
      
      Task t = createTask(c.Id, 'af', UserInfo.getUserId());
      MMSMSReceipt__c r = createReceipt(c.Id, 'af', t.Id, -200);
      System.assertEquals(r.Id, MMUtils.getReceiptRecord((Id)r.Id).Id);
      System.assertEquals(r.Id, MMUtils.getReceiptRecord('-200').Id);      
      System.assertEquals('923451234567',MMUtils.fixPhoneNumber('092-345-(123)-456.7'));
      System.assertEquals('Pakistan',MMUtils.getCountryByPhone('923451234567'));
      System.assertEquals('a\nbc',MMUtils.filterNull('a_-_b','c',null));
      try { System.assertEquals(true,MMUtils.getContactsByView('').size() == 0); } catch(Exception exp) { }
      try { System.assertEquals(true,MMUtils.getOpportunitiesByView('').size() == 0); } catch(Exception exp) { }
      
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
                                   false, 'Test SMS', null, '+443453031719', 'United Kingdom');
       insert r;
       return r;
   }
}