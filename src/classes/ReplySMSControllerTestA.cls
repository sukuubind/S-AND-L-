@IsTest
public class ReplySMSControllerTestA {
   public static testMethod void Test() {
      Test.startTest();
      ReplySMSController obj = new ReplySMSController();
      System.AssertEquals('OK',obj.getSmsResponse());
      
      PageReference pageRef = Page.replysms;
      Test.setCurrentPage(pageRef);

      Contact c1 = createAffiliation('test','a','443453031719');
      pageRef.getParameters().put('message','key1');
      pageRef.getParameters().put('status','');
      pageRef.getParameters().put('keylink','');
      ApexPages.currentPage().getParameters().put('phone','443453031719');
      ApexPages.currentPage().getParameters().put('id','');
      string nextPage = obj.autoRun().getUrl();

      Test.stopTest();       
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
                                   Name = name, StageName = stageName, CloseDate = closeDate);
       insert o;
       return o;
   }
}