@IsTest (seeAlldata=true)
public class SendSMSControllerTest {
   public static testMethod void Test() {
     string PMProfile = 'Deltak: Program Managers';
        
        Profile pro = [SELECT Id FROM profile WHERE name=:PMProfile];
        if (pro != null) {
            User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Testing',
                        languagelocalekey='en_US',
                        localesidkey='en_US', profileid = pro.Id,
                        timezonesidkey='America/Los_Angeles',
                        username='newuser11@testorg.com');
                        
            System.runAs(u2) {
      Test.startTest();
      SendSMSController cntrl = new SendSMSController();
      Contact c = createAffiliation('Test','Affiliation','03453031716','United Kingdom','No');
      Contact c1 = createAffiliation('Test','Affiliation 1','03453031718','United Kingdom','Yes');
      Opportunity op = createOpportunity(c.Id, 'Test Opportunity', 'New Inquiry', System.now().addDays(10).date());
      PageReference pageRef = Page.sendsms;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      cntrl.getErrMessageText();
      cntrl.getErrPhoneNumber();
      cntrl.getClassPhoneNumber();
      cntrl.getClassMessageText();
      cntrl.resetPage();
      
      MMUtils.saveHeaderFooter('Head1','Foot1','single');
      
      ApexPages.currentPage().getParameters().put('oid',c.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      System.assertEquals(true, cntrl.getPhoneNumbers().size() == 1);
      
      ApexPages.currentPage().getParameters().put('oid',op.Id);
      ApexPages.currentPage().getParameters().put('src','op');
      cntrl.initPage();
      System.assertEquals(true, cntrl.getPhoneNumbers().size() == 1);
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      
      System.assertEquals(true,cntrl.getTimeoptions().size() == 25);
      System.assertEquals(true,cntrl.getYearOptions().size() == 5);
      System.assertEquals(true,cntrl.getMonthOptions().size() == 12);
      System.assertEquals(true,cntrl.getDayOptions().size() == 5);   
      System.assertEquals(true,cntrl.getTimeZone().size() > 0);   
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      System.assertEquals('/' + c1.Id, cntrl.cancel().getUrl());

      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.selectedPhoneNumber = '03153031716';
      cntrl.messageText = 'Test SMS';
      cntrl.delivery = 'true';
      cntrl.selectedTimeZone = '0_a';
      //System.assertEquals('/apex/sendsms?oid=' + c1.Id + '&src=af', cntrl.sendSMS(true).getUrl());
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.selectedPhoneNumber = '03153031716';
      cntrl.messageText = 'Test SMS';
      cntrl.delivery = 'true';
      cntrl.selectedTimeZone = '1_a';
      cntrl.dayLightSaving = false;
      cntrl.sendSMS(true);
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.selectedPhoneNumber = '03153031716';
      cntrl.messageText = 'Test SMS';
      cntrl.delivery = 'true';
      cntrl.schedule = 'true';
      cntrl.startDate = '12/12/2011';
      cntrl.startTime = '23';
      cntrl.selectedTimeZone = '1_a';
      cntrl.dayLightSaving = false;
      cntrl.sendSMS(true);

      Test.stopTest();   
      
            }    }
   }
   
      public static testMethod void Test1() {
     string PMProfile = 'Deltak: Program Managers';
        
        Profile pro = [SELECT Id FROM profile WHERE name=:PMProfile];
        if (pro != null) {
            User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Testing',
                        languagelocalekey='en_US',
                        localesidkey='en_US', profileid = pro.Id,
                        timezonesidkey='America/Los_Angeles',
                        username='newuser11@testorg.com');
                        
            System.runAs(u2) {
       Test.startTest();
      SendSMSController cntrl = new SendSMSController();
      Contact c = createAffiliation('Test','Affiliation','03453031716','United Kingdom','No');
      Contact c1 = createAffiliation('Test','Affiliation 1','03453031718','United Kingdom','Yes');
      Opportunity op = createOpportunity(c.Id, 'Test Opportunity', 'New Inquiry', System.now().addDays(10).date());
      PageReference pageRef = Page.sendsms;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      cntrl.getErrMessageText();
      cntrl.getErrPhoneNumber();
      cntrl.getClassPhoneNumber();
      cntrl.getClassMessageText();
      cntrl.resetPage();
      
      MMUtils.saveHeaderFooter('Head1','Foot1','single');
      
      ApexPages.currentPage().getParameters().put('oid',c.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      System.assertEquals(true, cntrl.getPhoneNumbers().size() == 1);
      
      ApexPages.currentPage().getParameters().put('oid',op.Id);
      ApexPages.currentPage().getParameters().put('src','op');
      cntrl.initPage();
      System.assertEquals(true, cntrl.getPhoneNumbers().size() == 1);
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.initPage();
      
      System.assertEquals(true,cntrl.getTimeoptions().size() == 25);
      System.assertEquals(true,cntrl.getYearOptions().size() == 5);
      System.assertEquals(true,cntrl.getMonthOptions().size() == 12);
      System.assertEquals(true,cntrl.getDayOptions().size() == 5);   
      System.assertEquals(true,cntrl.getTimeZone().size() > 0);   
      
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      System.assertEquals('/' + c1.Id, cntrl.cancel().getUrl());

      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      cntrl.selectedPhoneNumber = '03153031716';
      cntrl.messageText = 'Test SMS';
      cntrl.delivery = 'true';
      cntrl.selectedTimeZone = '0_a';
      //System.assertEquals('/apex/sendsms?oid=' + c1.Id + '&src=af', cntrl.sendSMS(true).getUrl());
      
 
      
      MMSMSTemplate__c tmpl1 = new MMSMSTemplate__c();
      tmpl1.TemplateName__c = 'template name';
      tmpl1.Template__c = 'template text';
      insert tmpl1;
      
     
      ApexPages.currentPage().getParameters().put('oid',c1.Id);
      ApexPages.currentPage().getParameters().put('src','af');
      ApexPages.currentPage().getParameters().put('templateId',tmpl1.Id);
      cntrl.selectedPhoneNumber = '03153031716';
      cntrl.messageText = 'Test SMS';
      cntrl.delivery = 'true';
      cntrl.schedule = 'false';
      cntrl.selectedTimeZone = '1_a';
      cntrl.dayLightSaving = false;
      cntrl.getTemplateContent();
      
      cntrl.sendSMS(true);
      Test.stopTest();       
            }}
   }
   
   
   public static Contact createAffiliation(string fname, string lname, string phone, string country, string oktotext) {
       Contact c = new Contact(FirstName = fname, LastName = lname, MobilePhone = phone, Country__c = country, Ok_To_Text__c = oktotext);
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
                                   false, 'Test SMS', null, '            +443453031719      ', 'Pakistan');
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