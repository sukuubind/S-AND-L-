@IsTest
public class MMUtilsTest {
   public static testMethod void Test() {
     /* Fadi  
     Test.startTest();
      Contact c = createAffiliation('Test','Affiliation');
      Task t = createTask(c.Id, 'af', UserInfo.getUserId());
      Task t1 = createTask(c.Id, 'af', UserInfo.getUserId());      
      Task t2 = createTask(c.Id, 'af', UserInfo.getUserId());            
      MMSMSReceipt__c r = createReceipt(c.Id, 'af', t.Id, -200);
      
      System.assertEquals('+443453031719',MMUtils.fixPhoneNumber('03453031719','United Kingdom'));
      System.assertEquals('+443453031719',MMUtils.fixPhoneNumber('443453031719','United Kingdom'));
      System.assertEquals(0, MMUtils.getReceiptNumber());
      System.assertEquals(true, MMUtils.getReceiptNumbers(10, true).size() > 0);
      System.assertEquals(r.Id, MMUtils.getReceiptRecord(r.Id).Id);
      System.assertEquals('SMS Delivered',MMUtils.updateTask(t.Id, 'd', Datetime.now().format('MM/dd/yyyy HH:mm:ss')).MMSMSDeliveryStatus__c);
      System.assertEquals('SMS Sending Failed',MMUtils.updateTask(t.Id, 'f', Datetime.now().format('MM/dd/yyyy HH:mm:ss')).MMSMSDeliveryStatus__c);      
      System.assertEquals('SMS Pending',MMUtils.updateTask(t.Id, 'p', Datetime.now().format('MM/dd/yyyy HH:mm:ss')).MMSMSDeliveryStatus__c);      
      System.assertEquals('Status Received: x',MMUtils.updateTask(t.Id, 'x', Datetime.now().format('MM/dd/yyyy HH:mm:ss')).MMSMSDeliveryStatus__c);            
      
      MMUtils.createSMSReceipt('EE01', 'af', -301);
      System.assertEquals('EE01', [select c.EntityId__c from MMSMSReceipt__c c where c.ReceiptNumber__c = -301].EntityId__c);
      
      
      MMUtils.createSMSReceipt('EE02', 'af', -302, false, true, t1.Id, Datetime.now(), 'p', '0_a');
      System.assertEquals('EE02', [select c.EntityId__c from MMSMSReceipt__c c where c.ReceiptNumber__c = -302].EntityId__c);                                             

      MMUtils.createSMSReceipt('EE03', 'af', -303, false, true, t2.Id, Datetime.now(), 'p', '0_a',false);
      System.assertEquals('EE03', [select c.EntityId__c from MMSMSReceipt__c c where c.ReceiptNumber__c = -303].EntityId__c); 
      
      System.assertEquals(true, MMUtils.getTimeOptions().size() == 25);
      
      MMUtils.saveHeaderFooter('Head1','Foot1','group');
      System.assertEquals('Head1',[select Header__c, Footer__c from SMSHeaderFooter__c where type__c = 'group'  and User__c = : UserInfo.getUserId()].Header__c);
      
      System.assertNotEquals('',MMUtils.formatList());
      
      MMUtils.sendSingleEmail('fmoid@folio3.com', 'Test Recipienbt', 'Test Subject', 'text/html', 'Test Student');
      
      MMUtils.sendSingleEmail('fmoid@folio3.com', 'Test Recipienbt', 'Test Subject', 'Test Message');
      
      System.assertNotEquals('',MMUtils.getLimitTrace());
     
      Test.stopTest();       */
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