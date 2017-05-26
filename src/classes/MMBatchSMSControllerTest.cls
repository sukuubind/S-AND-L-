@IsTest (SeeAllData=true)
public class MMBatchSMSControllerTest {
   public static testMethod void Test() {
      Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        String currentProfileId = ((String) (pro.Id)).substring(0, 15);
		
		upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
			
      
      Test.startTest();
      
      Contact c1 = createAffiliation('Test','Affliation 1','03453031719','United Kingdom','yes','Mobile');
      Contact c2 = createAffiliation('Test','Affliation 2','03453031720','United Kingdom','yes','Mobile');      
      Contact c3 = createAffiliation('Test','Affliation 2','03453031720','United Kingdom','no','');  
      Contact[] cArr = null;
      List<integer> selIds = new List<integer>();
      Opportunity op1 = createOpportunity(c1.Id, 'Test Contact 1', 'New Inquiry', System.now().addDays(10).date());
      Opportunity op2 = createOpportunity(c2.Id, 'Test Contact 2', 'New Inquiry', System.now().addDays(10).date());      
      MMUtils.saveHeaderFooter('Head1','Foot1','group');
      MMGroupSMS__c group1 = createGroup('Group1', true, (c1.Id + '###af,' + c2.Id+ '###af,'), '1_a', 23, '2011-12-12',false,'Test Group SMS',
                                    true, 'Head g', 'Foot g', 'af', 'Subject 1', 'Notes 1', (c1.Id + ',' + c2.Id));
      BatchSMSController cntrl = new BatchSMSController();
      PageReference pageRef = Page.batchsms;
      Test.setCurrentPage(pageRef);
      
      System.assertEquals('/apex/groupsmslist',cntrl.onCancel().getUrl());

      ApexPages.currentPage().getParameters().put('id',c1.Id + '###af,' + c2.Id + '###af,');
      ApexPages.currentPage().getParameters().put('src','af');      
      cntrl.init();
            
      ApexPages.currentPage().getParameters().put('id',op1.Id + '###op,' + op2.Id + '###op,');
      ApexPages.currentPage().getParameters().put('src','op');      
      cntrl.init();
      
      cntrl.ids = group1.ids__c;
      ApexPages.currentPage().getParameters().put('id',group1.Id);
      ApexPages.currentPage().getParameters().put('src','groupsms');      
      cntrl.init();

      ApexPages.currentPage().getParameters().put('id',group1.Id);
      cntrl.messageText = '';
      cntrl.selectedCandidates = new string[] { };
      cntrl.deliveryTrack = 'true';
      cntrl.selectedTimeZone = '0_a';
      cntrl.sendSMS(true);
      System.assertEquals('error',cntrl.messageClass);
      System.assertEquals('error',cntrl.pNumClass);
      System.assertEquals('error',cntrl.tzClass);

      try {
      MMSMSTemplate__c tmpl1 = createTemplate('Hi [!Contact.FirstName]', 'tmpl1');
      ApexPages.currentPage().getParameters().put('id',c1.Id + '###af,' + c2.Id + '###af,');
      ApexPages.currentPage().getParameters().put('src','af');
      ApexPages.currentPage().getParameters().put('templateId',tmpl1.Id);
      cntrl.init();
      cntrl.entityContactMap = getEntityContactMap(new SOBject[] { c1, c2 }, 'af');
      cntrl.selectedCandidates = new string[] {'0','1'};      
      cntrl.messageText = 'Test Group';
      cntrl.headerText = 'Test Header';
      cntrl.footerText = 'Test Footer';
      cntrl.deliveryTrack = 'true';
      cntrl.scheduled = 'false';
      cntrl.saveHF = 'false';
      cntrl.selectedTimeZone = '1_a';
      cntrl.templateText = 'Hi [!Contact.FirstName]';
      selIds.add(0);selIds.add(1);
      cntrl.allSelected = selIds;
    
      cntrl.getTemplateContent();
      cntrl.sendSMS(true);

      System.assertEquals(true, cntrl.getNumSelectedCandidates() > 0);
      
      ApexPages.currentPage().getParameters().put('keyword','free');      
      cntrl.getKeylinkCandidates();
      
      cntrl.listSource = 'kk';
      cntrl.getListSourceOptions();      
      
      cntrl.listSource = 'ss';
      cntrl.getListSourceOptions();      
      } catch (Exception e) { }

      try {
          cntrl.currentPage = 1;
          cntrl.pageSize = 1;
          cntrl.onSelectionChange();
      
          ApexPages.currentPage().getParameters().put('viewId','');    
          cntrl.getSavedSearchCandidates();
      }
      catch(Exception e) {
      }

 //FS     System.assertEquals(false, cntrl.getIsCandidateInfoVisible());
      
      ApexPages.currentPage().getParameters().put('id',c1.Id + '###af,' + c2.Id + '###af,' + c3.Id + '###af,' );
      ApexPages.currentPage().getParameters().put('src','af');      
      cntrl.init();
      System.assertEquals(true, cntrl.getListOptions().size() == 2);
      System.assertEquals(true, cntrl.getTimeZone().size() > 0);
      System.assertEquals(true, cntrl.getTimeoptions().size() > 0);
      //cArr =  cntrl.getContactsById(new string[] { c1.Id, c2.Id }, 'af');
      //System.assertEquals(true, cArr.size() == 2);
      cntrl.scheduled = group1.isScheduled__c ? 'true' : 'false';
      cntrl.ids = group1.ids__c;
      cntrl.selectedTimeZone = group1.TimeZone__c; 
      cntrl.StartTime = string.valueOf(group1.StartTime__c);
      cntrl.startDate = group1.StartDate__c;
      cntrl.multipart = group1.Multipart__c ? 'true' : 'false';
      cntrl.messageText = group1.Message__c;
      cntrl.DeliveryTrack = group1.IsTrackDelivery__c ? 'true' : 'false';
      cntrl.headerText = group1.Header__c + ' try';
      cntrl.footerText = group1.Footer__c;
      cntrl.src = group1.EntityType__c;
      cntrl.selectedCandidates = new string[] {'0','1'};
      cntrl.txtSubject = group1.Subject__c;
      cntrl.txtNotes = group1.Notes__c;
//FS      cntrl.saveSMS(true);
//FS      System.assertEquals('Head g try',[select Header__c from MMGroupSMS__c where Id = :group1.Id].Header__c);

      ApexPages.currentPage().getParameters().put('id',group1.Id);
      ApexPages.currentPage().getParameters().put('src','groupsms');
 //FS     System.assertEquals('/apex/groupsmslist',cntrl.groupSMSDel().getUrl());
      
      cntrl.groupSMSId = '';
      cntrl.selectedTimeZone = group1.TimeZone__c; 
      cntrl.StartTime = '22';
      cntrl.startDate = '2011-12-12';
      cntrl.multipart = 'true';
      cntrl.messageText = '__Group Test ABC123__';
      cntrl.DeliveryTrack = 'true';
      cntrl.headerText = 'Head a try';
      cntrl.footerText = 'Foot';
      cntrl.src = 'af';
      cntrl.selectedCandidates = new string[] {'0','1'};
      cntrl.txtSubject = 'Subject';
      cntrl.txtNotes = 'Notes';
      cntrl.entityContactMap = getEntityContactMap(new SOBject[] { c1, c2 }, 'af');
      cntrl.allSelected = new integer[] {0,1};
      cntrl.setFirstEntryMergeFieldText();
      cntrl.getTemplateContentPreview();
//FS      cntrl.saveSMS(true);
      
//FS      System.assertEquals('hello Test',cntrl.getMergedTemplateText('hello [!Contact.FirstName]',c1.Id,'af'));
      cntrl.selectAllOnChange();
      try { cntrl.getPrevCandidates(); } catch(Exception exp) { }
      try { cntrl.getNextCandidates(); } catch(Exception exp) { }
      
      cntrl.resetPage();
      
      Test.stopTest(); 
        }      
   }
   public static Contact createAffiliation(string fname, string lname, string phone, string country, string oktotext, string prefPhone) {
       Contact c = new Contact(DeltakSRP__Preferred_Phone__c = phone,FirstName = 'Test', LastName = 'Affiliation', MobilePhone = phone, Country__c = country, OK_to_Text__c = oktotext);
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
                                   false, 'Test SMS', null, '                        +443453031719            ', 'Pakistan');
       insert r;
       return r.Id;
   }
   public static Opportunity createOpportunity(Id contactId, string name, string stageName, Date closeDate) {
       List<RecordType> recTypeList = [Select Id from RecordType where Name = 'Student Opportunity'];
       Opportunity o = new Opportunity(RecordTypeId = recTypeList[0].Id, ownerId = UserInfo.getUserId(),
                                   Name = name, StageName = stageName, CloseDate = closeDate, College_or_School_at_Institution__c = 'Business');
       insert o;
       return o;
   }
   public static MMGroupSMS__c createGroup(string name, boolean schedule, string ids, string timezone, integer starttime, string startdate,
                                    boolean multipart, string message, boolean delivery, string header, string footer, string entitytype, string subject, string notes, string sids) {
       MMGroupSMS__c groupMsg = new MMGroupSMS__c(Name = name, isScheduled__c = schedule, ids__c = ids,
                                    TimeZone__c = timezone, StartTime__c = starttime, StartDate__c = startdate,
                                    Multipart__c = multipart, Message__c = message, IsTrackDelivery__c = delivery,
                                    Header__c = header, Footer__c = footer, EntityType__c = entitytype,
                                    Subject__c = subject, Notes__c = notes, SelectedIds__c = sids);
       insert groupMsg;
       return groupMsg;
   }
   public static List<List<string>> getEntityContactMap(SObject[] entity, string eType) {
       List<List<string>> maps = new List<List<string>>();
       List<string> m = null;
       if (eType == 'af') {
           for (SObject obj : entity) {
               Contact c = (Contact)obj;
               m = new List<string>();
               m.add(c.Id);
               m.add(c.MobilePhone);
               m.add(c.Country__c);
               m.add(eType);
               m.add('value');               
               maps.add(m);
           }
       }
       return maps;
   }
   public static MMSMSTemplate__c createTemplate(string templateField, string templateName) {
         MMSMSTemplate__c currRec = new MMSMSTemplate__c();
         currRec.Template__c = templateField;
         currRec.TemplateName__c = templateName;
         insert currRec;
         return currRec;
    }
}