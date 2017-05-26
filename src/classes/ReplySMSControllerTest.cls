@IsTest
public class ReplySMSControllerTest {
   public static testMethod void Test() {
    /* Fadi
      Test.startTest();
      ReplySMSController obj = new ReplySMSController();
      System.AssertEquals('OK',obj.getSmsResponse());
      
      Contact contact = createAffiliation();
      Opportunity op = createOpportunity(contact.Id, 'Test Affiliation', 'New Inquiry', System.now().addDays(10).date());
      Id userId = UserInfo.getUserId();
      Id taskId = createTask(contact.Id, 'af', userId);
      Id taskIdOp = createTask(op.Id, 'op', userId);
      Id receiptId = createReceipt(contact.Id, 'af', taskId, -100);
      Id receiptIdOp = createReceipt(op.Id, 'op', taskIdOp, -200);

      PageReference pageRef = Page.replysms;
      Test.setCurrentPage(pageRef);
      pageRef.getParameters().put('message','STOP');
      ApexPages.currentPage().getParameters().put('phone','443453031719');
      ApexPages.currentPage().getParameters().put('id','-100');
      String nextPage = obj.autoRun().getUrl();
      
      System.assertEquals('/apex/replysms?id=-100&message=STOP&phone=443453031719',nextPage);

      pageRef.getParameters().put('message','STOP');
      ApexPages.currentPage().getParameters().put('phone','443453031719');
      ApexPages.currentPage().getParameters().put('id','-200');
      nextPage = obj.autoRun().getUrl();
      
      System.assertEquals('/apex/replysms?id=-200&message=STOP&phone=443453031719',nextPage);

      pageRef.getParameters().put('message','Hello');
      ApexPages.currentPage().getParameters().put('phone','443453031719');
      ApexPages.currentPage().getParameters().put('id','-100');
      nextPage = obj.autoRun().getUrl();
      
      System.assertEquals('/apex/replysms?id=-100&message=Hello&phone=443453031719',nextPage);
      
      pageRef.getParameters().put('message','');
      pageRef.getParameters().put('status','D');
      ApexPages.currentPage().getParameters().put('phone','443453031719');
      ApexPages.currentPage().getParameters().put('id','-100');
      nextPage = obj.autoRun().getUrl();
      
      System.assertEquals('/apex/replysms?id=-100&message=&phone=443453031719&status=D',nextPage);

      Test.stopTest();       
      
      */
   }
   public static Contact createAffiliation() {
       Contact c = new Contact(FirstName = 'Test', LastName = 'Affiliation');
       insert c;
       return c;
   }
   public static Contact createAffiliation(string fname, string lname, string mphone) {
       Contact c = new Contact(FirstName = fname, LastName = lname, MobilePhone = mphone);
       insert c;
       return c;
   }
   public static Id createTask(Id entityId, string entityType, Id userId) {
       Task t = MMUtils.createTask(entityId, entityType, 'Test SMS', 'Pending', true, false); 
       insert t;
       return t.Id;
   }
   public static Id createReceipt(Id entityId, string entityType, Id taskId, long receiptId) {
       MMSMSReceipt__c r = MMUtils.createSMSReceipt(entityId, entityType,receiptId, false, true, taskId, null, null, '0_a', 
                                   false, 'Test SMS', null, '+443453031719', 'Pakistan');
       insert r;
       return r.Id;
   }
   public static Opportunity createOpportunity(Id contactId, string name, string stageName, Date closeDate) {
       List<RecordType> recTypeList = [Select Id from RecordType where Name = 'Student Opportunity'];
       Opportunity o = new Opportunity(RecordTypeId = recTypeList[0].Id, Student__c = contactId, ownerId = UserInfo.getUserId(),
                                   Name = name, StageName = stageName, CloseDate = closeDate, College_or_School_at_Institution__c = 'Business', Curriculum_Structure__c = 'Fixed - No flexibility');
       insert o;
       return o;
   }
}