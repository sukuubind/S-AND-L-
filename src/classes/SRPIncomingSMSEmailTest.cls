@isTest
public class SRPIncomingSMSEmailTest {
	
	@isTest public static void test_emailSMS() {
		User u = [Select Id from user where id =:userinfo.getuserid()];
		
		system.runas(u){
        list <DeltakSRP_SMSStopWords__c> lstStopWords = new   list<DeltakSRP_SMSStopWords__c>();//bulk List of custom setting object for bulk insert

 		DeltakSRP_SMSStopWords__c stopWords=new DeltakSRP_SMSStopWords__c(); //Custom Setting for Contact Fields
		stopWords.Name='STOP';//Static record 1 of custom setting
		lstStopWords.add(stopWords);

		insert lstStopWords;

        list <DeltakSRP_SMSStartWords__c> lstStartWords = new   list<DeltakSRP_SMSStartWords__c>();//bulk List of custom setting object for bulk insert

 		DeltakSRP_SMSStartWords__c startWords=new DeltakSRP_SMSStartWords__c(); //Custom Setting for Contact Fields
		startWords.Name='START';//Static record 1 of custom setting
		lstStartWords.add(startWords);

		insert lstStartWords;


        ID acctid = findAccountRecordType();
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
        
        //insert test objects
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact newcontact = new Contact();
		newcontact.recordtypeid = findContactRecordType();
	    newcontact.firstname = 'Jane';
	    newcontact.lastname = 'Doe';
	    newcontact.Employer_Company__c = 'Test Company';
	    newcontact.accountid = a.id;
	    insert newcontact;


        /*Lead l = new Lead();
	        l.Status = 'Open';
	        l.Company = 'Deltak';
	        l.DeltakSRP__Academic_Institution_Lookup__c = a.Id;
	        l.FirstName = 'test firstname';
	        l.LastName = 'test lastname';
	        l.RecordTypeId = rt2.Id;
	        l.Phone = '1234567890';
	        l.MobilePhone = '1234567890';
	        l.DeltakSRP__Work_Phone__c = '1234567890';
	        l.DeltakSRP__Home_Phone__c = '1234567890';
        insert l;
        System.debug(LoggingLevel.INFO, 'Lead' +l);*/

		Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
	    
	    User upm = new User();
	    upm.alias = 'UserSMS';
	    upm.email='tarun.ohri@edlconsulting.com';
	    upm.emailencodingkey='UTF-8';
	    upm.lastname = 'TestSMS';
	    upm.languagelocalekey = 'en_US';
	    upm.localesidkey='en_US'; 
	    upm.profileid = pr.Id;
	    upm.timezonesidkey='America/New_York';
	    upm.username='thisusersms@test.com';
	    upm.Admissions_Extension__c = '0777';        
    	insert upm;

		Test.startTest();
    	//Contact
	    smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c();
	    sms.OwnerId = upm.id;
	    sms.smagicinteract__SMSText__c = 'This is a test message';
	    sms.smagicinteract__PhoneNumber__c = '111-222-3344';
	    sms.smagicinteract__SenderId__c = userinfo.getUserId();
	    sms.smagicinteract__Contact__c = newcontact.id;
	    sms.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
	    sms.smagicinteract__disableSMSOnTrigger__c = 1;

	    insert sms;

	    smagicinteract__Incoming_SMS__c incomingSMS = new smagicinteract__Incoming_SMS__c();	  
	    incomingSMS.DeltakSRPSMS__Contact__c = newcontact.Id;
	    incomingSMS.DeltakSRPSMS__SMS_History__c = sms.Id;
	    incomingSMS.smagicinteract__Mobile_Number__c = '111-222-3344';
        incomingSMS.smagicinteract__SMS_Text__c = 'Test Response';
        incomingSMS.smagicinteract__Inbound_Number__c = '888-123-4567';
	    incomingSMS.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();

	    insert incomingSMS;	

	    // Check the results of the Incoming Message Trigger
        smagicinteract__Incoming_SMS__c smsCheck = [select Id, DeltakSRPSMS__Contact__c,DeltakSRPSMS__SMS_History__c,smagicinteract__SMS_Text__c,smagicinteract__Mobile_Number__c,smagicinteract__Inbound_Number__c  
                                                        from smagicinteract__Incoming_SMS__c
                                                        where Id = :incomingSMS.Id][0];

	    // Check that all fields were linked up correctly
        System.assertEquals(sms.id, smsCheck.DeltakSRPSMS__SMS_History__c);
        System.assertEquals(newcontact.Id, smsCheck.DeltakSRPSMS__Contact__c); 
        System.assertEquals('Test Response', smsCheck.smagicinteract__SMS_Text__c);
        System.assertEquals('111-222-3344', smsCheck.smagicinteract__Mobile_Number__c);
        System.assertEquals('888-123-4567', smsCheck.smagicinteract__Inbound_Number__c);


	    sms = new smagicinteract__smsMagic__c();
	    sms.OwnerId = upm.id;
	    sms.smagicinteract__SMSText__c = 'STOP';
	    sms.smagicinteract__PhoneNumber__c = '111-222-3344';
	    sms.smagicinteract__SenderId__c = userinfo.getuserid();
	    sms.smagicinteract__Contact__c = newcontact.id;
	    sms.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
	    sms.smagicinteract__disableSMSOnTrigger__c = 1;

	    insert sms;

	    incomingSMS = new smagicinteract__Incoming_SMS__c();	  
	    incomingSMS.DeltakSRPSMS__Contact__c = newcontact.Id;
	    incomingSMS.DeltakSRPSMS__SMS_History__c = sms.Id;
	    incomingSMS.smagicinteract__Mobile_Number__c = '111-222-3344';
        incomingSMS.smagicinteract__SMS_Text__c = 'STOP';
        incomingSMS.smagicinteract__Inbound_Number__c = '888-123-4567';
	    incomingSMS.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();

	    insert incomingSMS;	


	    sms = new smagicinteract__smsMagic__c();
	    sms.OwnerId = upm.id;
	    sms.smagicinteract__SMSText__c = 'START';
	    sms.smagicinteract__PhoneNumber__c = '111-222-3344';
	    sms.smagicinteract__SenderId__c = userinfo.getuserid();
	    sms.smagicinteract__Contact__c = newcontact.id;
	    sms.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
	    sms.smagicinteract__disableSMSOnTrigger__c = 1;

	    insert sms;

	    incomingSMS = new smagicinteract__Incoming_SMS__c();	  
	    incomingSMS.DeltakSRPSMS__Contact__c = newcontact.Id;
	    incomingSMS.DeltakSRPSMS__SMS_History__c = sms.Id;
	    incomingSMS.smagicinteract__Mobile_Number__c = '111-222-3344';
        incomingSMS.smagicinteract__SMS_Text__c = 'START';
        incomingSMS.smagicinteract__Inbound_Number__c = '888-123-4567';
	    incomingSMS.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();

	    insert incomingSMS;	

/*
	    //Lead
	    smagicinteract__smsMagic__c sms1 = new smagicinteract__smsMagic__c();
	    sms1.OwnerId = upm.id;
	    sms1.smagicinteract__SMSText__c = 'This is a test message';
	    sms1.smagicinteract__PhoneNumber__c = '111-222-3344';
	    sms1.smagicinteract__SenderId__c = sms1.Name;
	    sms1.smagicinteract__Lead__c = l.id;
	    sms1.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
	    sms1.smagicinteract__disableSMSOnTrigger__c = 1;

	    insert sms1;

	    smagicinteract__Incoming_SMS__c incomingSMS1 = new smagicinteract__Incoming_SMS__c();	  
	    incomingSMS1.DeltakSRPSMS__Contact__c = newcontact.id;
	    incomingSMS1.DeltakSRPSMS__SMS_History__c = sms1.Id;
	    incomingSMS1.smagicinteract__Mobile_Number__c = '111-222-3344';
        incomingSMS1.smagicinteract__SMS_Text__c = 'Test Response';
        incomingSMS1.smagicinteract__Inbound_Number__c = '888-123-4567';
	    incomingSMS1.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();

	    insert incomingSMS1;		    

	    // Check the results of the Incoming Message Trigger
        smagicinteract__Incoming_SMS__c smsCheck1 = [select Id, DeltakSRPSMS__Contact__c,DeltakSRPSMS__SMS_History__c,smagicinteract__SMS_Text__c,smagicinteract__Mobile_Number__c,smagicinteract__Inbound_Number__c  
                                                        from smagicinteract__Incoming_SMS__c
                                                        where Id = :incomingSMS1.Id][0];

	    // Check that all fields were linked up correctly
        System.assertEquals(sms1.id, smsCheck1.DeltakSRPSMS__SMS_History__c);
        System.assertEquals(newcontact.Id, smsCheck.DeltakSRPSMS__Contact__c); 
        System.assertEquals('Test Response', smsCheck1.smagicinteract__SMS_Text__c);
        System.assertEquals('111-222-3344', smsCheck1.smagicinteract__Mobile_Number__c);
        System.assertEquals('888-123-4567', smsCheck1.smagicinteract__Inbound_Number__c);
*/
	    Test.stopTest();
		}

	}
	

    private static ID findContactRecordType() {
  
	    Schema.DescribeSObjectResult describeST = Schema.SObjectType.Contact;
	    List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
	    for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	        if(rtInfo.getName() == 'Deltak Student') {
	            
	            System.debug(LoggingLevel.INFO,'The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
	            return rtInfo.getRecordTypeId();
	        }
	    }
    
    return null;
    }

    private static ID findAccountRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Account;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Campus/Partner') {
                
                System.debug(LoggingLevel.INFO,'The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }  
	
}