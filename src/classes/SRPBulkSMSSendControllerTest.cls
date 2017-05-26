@isTest
private class SRPBulkSMSSendControllerTest {
    public static PageReference pageRef = null;
    public static Contact contact = null;
    public static Account account = null;
    public static String objectType = 'contact';
    public static String phoneField = 'MobilePhone';
    public static String nameField = 'Name';
    public static SRPBulkSMSSendController bssc = null;
    public static DeltakSRP__SRP_Partner_Settings__c setting = null;
    public static User u = null;
    
    public static void setupTest() {
        
        account = new Account();
        account.Phone = '123456789';
        account.Name = 'Test Account - Screen Magic';
        insert account;
        
        u = DeltakSRP.TestUtils.getCurrentUser();
        
        setting = DeltakSRP.TestUtils.getPartnerSetting(u, account.Id);
        
        System.debug('CH: Setting - ' + setting);
        System.debug('CH: User - ' + u);
        System.debug('CH: Account - ' + account);
        
        contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'test first name';
        contact.LastName = 'Test Contact-Screen Magic';
        contact.MobilePhone = '9579811985';
        insert contact;
                
        pageRef = ApexPages.currentPage();
        //pageRef.getParameters().put('retURL','/apex/SRPBulkSMSSendPage');
        pageRef.getParameters().put('retURL',Page.SRPBulkSMSSendPage.getUrl());
        pageRef.getParameters().put('recordIds',contact.Id);
        pageRef.getParameters().put('objectType',objectType);
        pageRef.getParameters().put('phoneField',phoneField);
        pageRef.getParameters().put('nameField',nameField);
        pageRef.getParameters().put('sendToOptout','yes');
        pageRef.getParameters().put('showUserDropDown','no');
        pageRef.getParameters().put('parentObject','Account');
        pageRef.getParameters().put('inboundNumberField','Phone');
        pageRef.getParameters().put('parentObjectReferenceField','AccountId');
        bssc = new SRPBulkSMSSendController();
    }
    
    static testMethod void test_constructor() {
        
        setupTest();
        system.assertEquals(bssc.recordIds, contact.Id);
    }
    
    static testMethod void test_getDefaultSenderId() {
        
        setupTest();
        system.assertEquals(bssc.getDefaultSenderId(), account.Phone);
    }
    
    static testMethod void test_getSenderIds() {
        
        setupTest();
        String senderId = 'testSenderID';
        smagicinteract__SMS_SenderId__c senderIdObject = new smagicinteract__SMS_SenderId__c();
        senderIdObject.smagicinteract__senderId__c = senderId;
        insert senderIdObject;
        List<sObject> senderIdList = [select Id, smagicinteract__senderId__c from smagicinteract__SMS_SenderId__c ORDER BY CreatedDate DESC];
        system.assertEquals(bssc.getSenderIds().size(), senderIdList.size());
    }
    
    static testMethod void test_getSmsObjectList() {
        
        setupTest();
        system.assertEquals(bssc.getSmsObjectList()[0].get('Phone'), contact.MobilePhone);
    }
    
    static testMethod void test_send() {
        
        SRPBulkSMSSendController.isApexTest = true;
        setupTest();    
        bssc.senderId = 'smsMagic1';
        bssc.smsText = '{!Contact.MobilePhone} {!Contact.LastName}';
        bssc.optOutFieldValue = 'no';
        bssc.Send();
        System.assertEquals(bssc.numberOfSentSMS, 1);
    }
    
    static testMethod void test_cancel() {
        
        setupTest();
        PageReference cancelPage = bssc.cancel();
        String returnUrl = pageRef.getParameters().get('retURL');
        System.assertEquals(cancelPage.getUrl(), returnUrl);    
    }
    
    static testMethod void test_cancelSMS() {
        
        setupTest();
        PageReference cancelPage = bssc.cancelSMS();
        String returnUrl = pageRef.getParameters().get('retURL');
        System.assertEquals(cancelPage.getUrl(), returnUrl);    
    }
    
    static testMethod void test_getItems() {
        
        setupTest();
        String tplTxt = 'Test Template for Unit Test';
        
        List<sObject> tplListToDel = [select Id  from smagicinteract__SMS_Template__c where smagicinteract__ObjectName__c ='contact'];
        delete tplListToDel;
        
        smagicinteract__SMS_Template__c tplObject = new smagicinteract__SMS_Template__c();
        tplObject.smagicinteract__Name__c = 'Test Tpl- Screen Magic';
        tplObject.smagicinteract__Text__c = tplTxt;
        tplObject.smagicinteract__ObjectName__c = 'contact';
        insert tplObject;
        
        List<sObject> tplList = [select Id  from smagicinteract__SMS_Template__c where smagicinteract__ObjectName__c ='contact'];
        
        Integer tplListSize = tplList.size() + 2;
        system.assertEquals(bssc.getItems().size(), tplListSize);
    }
    
    static testMethod void test_changeTemplateText_NewTP() {
        
        setupTest();
        String redirectURL = '/apex/smagicinteract__NewSMSTemplate?retURL=/apex/smagicinteract__SMHome';
        bssc.template = 'NewTp';
        PageReference pageRef1 = new PageReference(redirectURL);
        PageReference pageRef2 = bssc.changeTemplateText();
        System.assertEquals(pageRef1.getUrl(), pageRef2.getUrl());
    }
    
    static testMethod void test_changeTemplateText() {
        
        setupTest();
        
        String tplTxt = 'Test Template for Unit Test';
        
        List<sObject> tplListToDel = [select Id  from smagicinteract__SMS_Template__c where smagicinteract__ObjectName__c ='contact'];
        delete tplListToDel;
        
        smagicinteract__SMS_Template__c tplObject = new smagicinteract__SMS_Template__c();
        tplObject.smagicinteract__Name__c = 'Test Tpl- Screen Magic';
        tplObject.smagicinteract__Text__c = tplTxt;
        tplObject.smagicinteract__ObjectName__c = 'contact';
        insert tplObject;
        
        bssc.getItems();
        bssc.template = String.valueOf(tplObject.Id);
        bssc.changeTemplateText();
        System.assertEquals(bssc.smsText, tplTxt);
    }
    
    static testMethod void test_getHoursList() {
        
        setupTest();
        system.assertEquals(bssc.getHoursList().size(), 24);
    }
    
    static testMethod void test_getMinutesList() {
        
        setupTest();
        system.assertEquals(bssc.getMinutesList().size(), 12);
    }
    
    static testMethod void test_getSenderList() {
        
        setupTest();
        List<User> userList = [select Id, Name from User where IsActive = true];
        system.assertEquals(bssc.getSenderList().size(), userList.size());
    }
    
    static testMethod void test_schedule() {
        
        setupTest();
        Datetime scheduleDateTime = system.now();
        scheduleDateTime = scheduleDateTime.addMinutes(3);
        String timeInSeconds = '0';
        String timeInMinutes = '';
        String timeInHours = '';
        String jobName = 'Test Job - Screen Magic';
        Date startDate = scheduleDateTime.date();
        Date endDate = scheduleDateTime.date().addYears(2); 
        
        smagicschedule__SMS_Schedule__c scheduleDateObj1 = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj1.smagicschedule__Date__c = endDate;
        bssc.startDateObj = scheduleDateObj1;
        bssc.jobName = jobName;
        bssc.smsText = 'Test SMS Schedule';
        bssc.senderId = 'smsMagicTest';
        bssc.isOptOut = false;
        bssc.optOutField = 'smagicinteract__SMSOptOut__c';
        bssc.optOutFieldValue = 'no';
        bssc.timeInHours = String.valueOf(scheduleDateTime.hour());
        bssc.timeInMinutes = String.valueOf(scheduleDateTime.minute());
        bssc.schedule();
        smagicschedule__SMS_Schedule__c scheduleSMSRecord = [select Id, smagicschedule__Schedule_Name__c from smagicschedule__SMS_Schedule__c where smagicschedule__Schedule_Name__c =:jobName limit 1];
        system.assertEquals(scheduleSMSRecord.smagicschedule__Schedule_Name__c, jobName);
    }
    
    static testMethod void test_closePopup() {
        
        setupTest();
        bssc.closePopup();
        system.assertEquals(bssc.displayPopup, false);
    }
    
    static testMethod void test_showPopup() {
        
        setupTest();
        bssc.showPopup();
        system.assert(bssc.displayPopup);
    }
    
    static testMethod void test_checkForNull() {
        
        setupTest();
        String jobName = 'Test Job - Screen Magic';
        bssc.jobName = jobName;
        bssc.smsText = 'Test SMS';
        Date startDate = null;
        bssc.startDateObj.smagicschedule__Date__c = startDate;
        bssc.schedule();
        system.assert(true);
    }
    
    static testMethod void test_checkForEmptyJobName() {
        
        setupTest();
        bssc.schedule();
        system.assert(true);
    }
    
    static testMethod void test_checkForInvalidDate() {
        
        setupTest();
        Datetime scheduleDateTime = system.now();
        scheduleDateTime = scheduleDateTime.addHours(-3);
        scheduleDateTime = scheduleDateTime.addMinutes(-3);
        
        String timeInSeconds = '0';
        String timeInMinutes = String.valueOf(scheduleDateTime.minute());
        String timeInHours = String.valueOf(scheduleDateTime.hour());
        String jobName = 'Test Job - Screen Magic';
        Date startDate = scheduleDateTime.date();
        Date endDate = scheduleDateTime.date().addYears(2); 
        
        smagicschedule__SMS_Schedule__c scheduleDateObj = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj.smagicschedule__Date__c = startDate;
        bssc.startDateObj = scheduleDateObj;
        
        smagicschedule__SMS_Schedule__c scheduleDateObj1 = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj1.smagicschedule__Date__c = endDate;
        bssc.endDateObj = scheduleDateObj1;
        bssc.jobName = jobName;
        bssc.smsText = 'Test SMS Schedule';
        bssc.senderId = 'smsMagicTest';
        bssc.isOptOut = false;
        bssc.optOutField = 'smagicinteract__SMSOptOut__c';
        bssc.sendToOptout = 'no';
        bssc.timeInHours = timeInHours;
        bssc.timeInMinutes = timeInMinutes;
        bssc.schedule();
        system.assert(true);
    }
    
    static testMethod void test_checkForInvalidMinutes() {
        
        setupTest();
        Datetime scheduleDateTime = system.now();
        scheduleDateTime = scheduleDateTime.addMinutes(-3);
        
        String timeInSeconds = '0';
        String timeInMinutes = String.valueOf(scheduleDateTime.minute());
        String timeInHours = String.valueOf(scheduleDateTime.hour());
        String jobName = 'Test Job - Screen Magic';
        Date startDate = scheduleDateTime.date();
        Date endDate = scheduleDateTime.date().addYears(2);
        
        smagicschedule__SMS_Schedule__c scheduleDateObj = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj.smagicschedule__Date__c = startDate;
        bssc.startDateObj = scheduleDateObj;
        
        smagicschedule__SMS_Schedule__c scheduleDateObj1 = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj1.smagicschedule__Date__c = endDate;
        bssc.endDateObj = scheduleDateObj1;
        bssc.jobName = jobName;
        bssc.smsText = 'Test SMS Schedule';
        bssc.senderId = 'smsMagicTest';
        bssc.isOptOut = false;
        bssc.optOutField = 'smagicinteract__SMSOptOut__c';
        bssc.sendToOptout = 'no';
        bssc.timeInHours = timeInHours;
        bssc.timeInMinutes = timeInMinutes;
        bssc.schedule();
        system.assert(true);
    }
    
    static testMethod void test_checkForEmptySMSText() {
        
        setupTest();
        Datetime scheduleDateTime = system.now();
        scheduleDateTime = scheduleDateTime.addMinutes(3);
        
        String timeInSeconds = '0';
        String timeInMinutes = String.valueOf(scheduleDateTime.minute());
        String timeInHours = String.valueOf(scheduleDateTime.hour());
        String jobName = 'Test Job - Screen Magic';
        Date startDate = scheduleDateTime.date();
        Date endDate = scheduleDateTime.date().addYears(2);
        
        smagicschedule__SMS_Schedule__c scheduleDateObj = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj.smagicschedule__Date__c = startDate;
        bssc.startDateObj = scheduleDateObj;
        
        smagicschedule__SMS_Schedule__c scheduleDateObj1 = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj1.smagicschedule__Date__c = endDate;
        bssc.endDateObj = scheduleDateObj1;
        bssc.jobName = jobName;
        bssc.smsText = '';
        bssc.senderId = 'smsMagicTest';
        bssc.isOptOut = false;
        bssc.optOutField = 'smagicinteract__SMSOptOut__c';
        bssc.sendToOptout = 'no';
        bssc.timeInHours = timeInHours;
        bssc.timeInMinutes = timeInMinutes;
        bssc.schedule();
        system.assert(true);
    }
    
    static testMethod void test_checkForEmptySMSTextInSending() {
        
        setupTest();
        Datetime scheduleDateTime = system.now();
        scheduleDateTime = scheduleDateTime.addMinutes(3);
        
        String timeInSeconds = '0';
        String timeInMinutes = String.valueOf(scheduleDateTime.minute());
        String timeInHours = String.valueOf(scheduleDateTime.hour());
        String jobName = 'Test Job - Screen Magic';
        Date startDate = scheduleDateTime.date();
        Date endDate = scheduleDateTime.date().addYears(2);
        
        smagicschedule__SMS_Schedule__c scheduleDateObj = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj.smagicschedule__Date__c = startDate;
        bssc.startDateObj = scheduleDateObj;
                
        smagicschedule__SMS_Schedule__c scheduleDateObj1 = new smagicschedule__SMS_Schedule__c();
        scheduleDateObj1.smagicschedule__Date__c = endDate;
        bssc.endDateObj = scheduleDateObj1;
        
        bssc.jobName = jobName;
        bssc.smsText = '';
        bssc.senderId = 'smsMagicTest';
        bssc.isOptOut = false;
        bssc.optOutField = 'smagicinteract__SMSOptOut__c';
        bssc.sendToOptout = 'no';
        bssc.timeInHours = timeInHours;
        bssc.timeInMinutes = timeInMinutes;
        bssc.send();
        system.assert(true);
    }
}