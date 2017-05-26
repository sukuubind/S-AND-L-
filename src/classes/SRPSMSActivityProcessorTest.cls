/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SRPSMSActivityProcessorTest {

   private static smagicinteract__smsMagic__c populateSMSHistory(String opportunityId, String smsText, String name,
																 String fromNumber, String toNumber, String sendStatus, String deliveryStatus, String affl)
	{
		smagicinteract__smsMagic__c smsHistRecord = new smagicinteract__smsMagic__c();
		
		smsHistRecord.smagicinteract__sentStatus__c = sendStatus;
		smsHistRecord.smagicinteract__Name__c = name;
		smsHistRecord.smagicinteract__disableSMSOnTrigger__c = 1;
		smsHistRecord.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
		smsHistRecord.smagicinteract__deliveryStatus__c = deliveryStatus;
		smsHistRecord.smagicinteract__SenderId__c = fromNumber;
		smsHistRecord.smagicinteract__SMSText__c = smsText;
		smsHistRecord.smagicinteract__PhoneNumber__c = toNumber;
		smsHistRecord.smagicinteract__Contact__c = affl;
		smsHistRecord.OwnerId = UserInfo.getUserId();
		smsHistRecord.DeltakSRPSMS__Opportunity__c = opportunityId;
		smsHistRecord.SMAGICINTERACT__OBJECTTYPE__C = 'Opportunity';

		return smsHistRecord;
	}
	
	private static smagicinteract__Incoming_SMS__c populateIncomingSMS(Id opportunityId,  String smsText,
																	 String fromNumber, String toNumber, String affl)
	{
		smagicinteract__Incoming_SMS__c incomingSMSRecord = new smagicinteract__Incoming_SMS__c();
		

		incomingSMSRecord.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
		incomingSMSRecord.smagicinteract__Mobile_Number__c = fromNumber;
		incomingSMSRecord.smagicinteract__SMS_Text__c = smsText;
		incomingSMSRecord.SMAGICINTERACT__INBOUND_NUMBER__C = toNumber;
		incomingSMSRecord.DeltakSRPSMS__Contact__c = affl;
		
		incomingSMSRecord.DeltakSRPSMS__Opportunity__c = opportunityId;
		
		return incomingSMSRecord;
	}
	
	 private static Opportunity populateOpportunityFields(String stageName, String recordTypeId, String name, 
	 														String externalId, String accountId, Date closeDate){
        Opportunity oppty = new Opportunity();
        //Select o.StageName, o.SRP_Student_Name__c, o.SRP_Student_Last_Name__c, o.SRP_Student_Id__c, o.RecordTypeId, o.OwnerId, o.Name, o.Mobile_Phone__c, o.Date_Transferred__c, o.AccountId From Opportunity o;
        oppty.StageName = stageName;
		oppty.RecordTypeId = recordTypeId;
		oppty.DeltakSRP__External_Id__c = externalId;
		//oppty.SRP_Person__c = person;
		oppty.Name = name;
		oppty.AccountId = accountId;
		oppty.closeDate = closeDate;

        return oppty;
    }
    
    private static Contact populateAffiliationFields(String firstName, String lastName, String email, String accountId, 
    													String mobileNumber, String okToText, String gender)
    {
    	Contact affl = new Contact();
    	affl.MobilePhone = mobileNumber;
		
		affl.OK_to_Text__c = okToText;
		affl.RecordTypeId = '01260000000Pz6D';
		affl.LastName = lastName;
		affl.HasOptedOutOfEmail = false;
		affl.Gender__c = gender;
		affl.FirstName = firstName;
		affl.Email = email;
		affl.AccountId = accountId;
    	
    	return affl;
    	
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
 
    
    static testMethod void smsHistoryToActivityTest() {
        
        ID acctid = findAccountRecordType();
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact per = new Contact();
		per.recordtypeid = findContactRecordType();
	    per.firstname = 'Jane';
	    per.lastname = 'Doe';
	    per.Employer_Company__c = 'Test Company';
	    per.accountid = a.id;
	    insert per;
        

        
        Opportunity opp = populateOpportunityFields('New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1);
        insert opp;
        
        
        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(opp.id, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered',per.id);
        
        insert smsHist1;

        
        Test.startTest();
        
        String status1 = SRPSMSActivityProcessor.createSMSHistoryActivity(smsHist1.id, false); 
        System.assertEquals(Label.Create_SMS_Activity_Success,status1);
        
        List<Task> smsActivityHist = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, external_id__c from Task where WhatId =: opp.id and external_id__c =: smsHist1.smagicinteract__external_field__c];
        system.debug('smsActivityHist-->***'+smsActivityHist);
        for(Task t: smsActivityHist)
        {
	      	System.assertEquals(smsHist1.smagicinteract__external_field__c,t.external_id__c);
	        System.assertEquals('Successful', t.Result__c); 
	        System.assertEquals('Outgoing SMS', t.subject); 
        }
        
        
        String status5 = SRPSMSActivityProcessor.createSMSHistoryActivity(smsHist1.id, true); 
        //System.assertEquals(Label.Create_SMS_Activity_Failure,status5);
		Test.stopTest();
        
     }
    
    static testMethod void incomingSMSWithSMSHistTest() { 
        // TO DO: implement unit test
        
        ID acctid = findAccountRecordType();
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact per = new Contact();
		per.recordtypeid = findContactRecordType();
	    per.firstname = 'Jane';
	    per.lastname = 'Doe';
	    per.Employer_Company__c = 'Test Company';
	    per.accountid = a.id;
	    insert per;
        
        Opportunity opp = populateOpportunityFields('New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1);
        insert opp;
        
        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(opp.id, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered',per.id);
        insert smsHist1;
        
        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(opp.id, 'Test Message 1', '2246003446', '16302063156', per.id);
        incomingSMS1.DeltakSRPSMS__SMS_History__c = smsHist1.id;
        insert incomingSMS1;

        
        Test.startTest();
        
        String status2 = SRPSMSActivityProcessor.createIncomingSMSActivity(incomingSMS1.id, false);
        System.assertEquals(Label.Create_SMS_Activity_Success,status2);
        
        List<Task> incomingSMSHist = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, external_id__c from Task where WhatId = :opp.id and external_id__c =: incomingSMS1.smagicinteract__external_field__c];
        system.debug('incomingSMSHist-->***'+incomingSMSHist);
        for(Task t: incomingSMSHist)
        {
        	System.assertEquals(incomingSMS1.smagicinteract__external_field__c,t.external_id__c);
        	System.assertEquals('Successful', t.Result__c); 
        	System.assertEquals('Incoming SMS', t.subject); 
        }
        
        String status6 = SRPSMSActivityProcessor.createIncomingSMSActivity(incomingSMS1.id, true);
        //System.assertEquals(Label.Create_SMS_Activity_Failure,status6);
		Test.stopTest();
        
     }
    
     static testMethod void incomingSMSToActivityTest() {
        // TO DO: implement unit test
        
        ID acctid = findAccountRecordType();
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact per = new Contact();
		per.recordtypeid = findContactRecordType();
	    per.firstname = 'Jane';
	    per.lastname = 'Doe';
	    per.Employer_Company__c = 'Test Company';
	    per.accountid = a.id;
	    insert per;
        
        Opportunity opp = populateOpportunityFields('New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1);
        insert opp;
        
        
        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(opp.id, 'Test Message 1', '2246003446', '16302063156', per.id);
        insert incomingSMS1;

        
        Test.startTest();
        
        String status2 = SRPSMSActivityProcessor.createIncomingSMSActivity(incomingSMS1.id, false);
        System.assertEquals(Label.Create_SMS_Activity_Success,status2);
        
        List<Task> incomingSMSHist = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, external_id__c from Task where WhatId = :opp.id and external_id__c =: incomingSMS1.smagicinteract__external_field__c];
        system.debug('incomingSMSHist-->***'+incomingSMSHist);
        for(Task t: incomingSMSHist)
        {
        	System.assertEquals(incomingSMS1.smagicinteract__external_field__c,t.external_id__c);
        	System.assertEquals('Successful', t.Result__c); 
        	System.assertEquals('Incoming SMS', t.subject); 
        }
        
        
        String status6 = SRPSMSActivityProcessor.createIncomingSMSActivity(incomingSMS1.id, true);
       // System.assertEquals(Label.Create_SMS_Activity_Failure,status6);
		Test.stopTest();
        
     }
     
     static testMethod void allOpptySMSActivityTest() {
        
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        system.debug('profDOA--> '+profDOA);
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        
        
        
        SrpTriggerOverrideInSrm__c ovr = new SrpTriggerOverrideInSrm__c(SetupOwnerId = doa.Id,Override_All__c=true);
		insert ovr;
        
        System.RunAs(doa)
        {
        	ID acctid = findAccountRecordType();
	        Account a = new Account();
	        a.Name = 'Test Account';
	        a.recordTypeID = acctid;
	        a.Admissions_Phone__c = '888-888-8888';
	        insert a;
			
			RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
			
			Contact per = new Contact();
			per.recordtypeid = rt4.id;
		    per.firstname = 'Jane';
		    per.lastname = 'Doe';
		    per.Employer_Company__c = 'Test Company';
		    per.accountid = a.id;
		    insert per;
		    
		    
	        
	        Opportunity opp = populateOpportunityFields('New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1);
	        insert opp;
	        
	        List<smagicinteract__smsMagic__c> smsHistList = new List<smagicinteract__smsMagic__c>();
	        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(opp.id, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
	        smsHistList.add(smsHist1);
	        smagicinteract__smsMagic__c smsHist2 = populateSMSHistory(opp.id, 'Test Message 2', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
	        smsHistList.add(smsHist2);
	        smagicinteract__smsMagic__c smsHist3 = populateSMSHistory(opp.id, 'Test Message 3', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
			smsHistList.add(smsHist3);
	        System.debug('Number of SMS Hist = ***='+smsHistList.size());
	        database.insert (smsHistList);
	        
	        Test.startTest();
	        
	        String status3 = SRPSMSActivityProcessor.createAllSMSActivity(opp.id, false,'Oppty'); 
	        System.assertEquals(Label.Create_SMS_Activity_Success,status3);
	        
	        List<Task> allSMSActivity = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhatId =:opp.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
	        System.debug('Number of activities = ***='+allSMSActivity.size());
	        System.assertEquals(3, allSMSActivity.size()); 
	        
	        Map<Id,Task> activityMap = new Map<Id,Task>(allSMSActivity);
	        Map<String,String> messageMap = new Map<String,String>();
	        Map<String,String> resultMap = new Map<String,String>();
	        for(Task t: allSMSActivity)
	        {
	        	messageMap.put(t.external_id__c,t.description);
	        	resultMap.put(t.external_id__c,t.Result__c);
	        }
	        
	       	System.assert(messageMap.containsKey(smsHist1.smagicinteract__external_field__c));
	       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
	       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
	       	
			System.assertEquals((messageMap.get(smsHist1.smagicinteract__external_field__c).contains('Test Message 1')), true);
			System.assertEquals((messageMap.get(smsHist2.smagicinteract__external_field__c).contains('Test Message 2')), true);
			System.assertEquals((messageMap.get(smsHist3.smagicinteract__external_field__c).contains('Test Message 3')), true);
			
			System.assertEquals((resultMap.get(smsHist1.smagicinteract__external_field__c).containsOnly('Successful')), true);
	       	System.assertEquals((resultMap.get(smsHist2.smagicinteract__external_field__c).containsOnly('Successful')), true);
	        System.assertEquals((resultMap.get(smsHist3.smagicinteract__external_field__c).containsOnly('Successful')), true);
			
		
			
	     
	        
	        List<smagicinteract__Incoming_SMS__c> incSMSList = new List<smagicinteract__Incoming_SMS__c>();
	        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(opp.id, 'Test Message 1', '2246003446', '16302063156', per.id);
	      //  incomingSMS1.DeltakSRPSMS__SMS_History__c = smsHist1.id;
	        incSMSList.add(incomingSMS1);
	        smagicinteract__Incoming_SMS__c incomingSMS2 = populateIncomingSMS(opp.id, 'Test Message 2', '2246003446', '16302063156', per.id);
	        incSMSList.add(incomingSMS2);
	        smagicinteract__Incoming_SMS__c incomingSMS3 = populateIncomingSMS(opp.id, 'Test Message 3', '2246003446', '16302063156', per.id);
	        incSMSList.add(incomingSMS3);
	        System.debug('Number of Incoming SMS = ***='+incSMSList.size());
	        database.insert (incSMSList,false);
	        
	   		String status3a = SRPSMSActivityProcessor.createAllSMSActivity(opp.id, false,'Oppty'); 
	        System.assertEquals(Label.Create_SMS_Activity_Success,status3a);
	        
	        String status3b = SRPSMSActivityProcessor.createAllSMSActivity(opp.id, true,'Oppty'); 
	       // System.assertEquals(Label.Create_SMS_Activity_Failure,status3b); 
	        
	        List<Task> allSMSActivity1 = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhatId =:opp.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
	        System.debug('Number of activities = ***='+allSMSActivity1.size());
	        System.assertEquals(6, allSMSActivity1.size()); 
	        
	        Map<Id,Task> activityMap1 = new Map<Id,Task>(allSMSActivity1);
	        Map<String,String> messageMap1 = new Map<String,String>();
	        Map<String,String> resultMap1 = new Map<String,String>();
	        for(Task t: allSMSActivity1)
	        {
	        	messageMap1.put(t.external_id__c,t.description);
	        	resultMap1.put(t.external_id__c,t.Result__c);
	        }
	        
	       	System.assert(messageMap1.containsKey(incomingSMS1.smagicinteract__external_field__c));
	       	System.assert(messageMap1.containsKey(incomingSMS2.smagicinteract__external_field__c));
	       	System.assert(messageMap1.containsKey(incomingSMS3.smagicinteract__external_field__c));
	        
	        System.assertEquals((messageMap1.get(incomingSMS1.smagicinteract__external_field__c).contains('Test Message 1')), true);
			System.assertEquals((messageMap1.get(incomingSMS2.smagicinteract__external_field__c).contains('Test Message 2')), true);
			System.assertEquals((messageMap1.get(incomingSMS3.smagicinteract__external_field__c).contains('Test Message 3')), true);
			
			System.assertEquals((resultMap1.get(incomingSMS1.smagicinteract__external_field__c).containsOnly('Successful')), true);
	       	System.assertEquals((resultMap1.get(incomingSMS2.smagicinteract__external_field__c).containsOnly('Successful')), true);
	        System.assertEquals((resultMap1.get(incomingSMS3.smagicinteract__external_field__c).containsOnly('Successful')), true);
			
			
	        Test.stopTest();
        }
        
     }
     
    static testMethod void allAfflSMSActivityTest() {
        
        
        ID acctid = findAccountRecordType();
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact per = new Contact();
		per.recordtypeid = findContactRecordType();
	    per.firstname = 'Jane';
	    per.lastname = 'Doe';
	    per.Employer_Company__c = 'Test Company';
	    per.accountid = a.id;
	    insert per;
        
        
        List<smagicinteract__smsMagic__c> smsHistList = new List<smagicinteract__smsMagic__c>();
        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(null, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
        smsHistList.add(smsHist1);
        smagicinteract__smsMagic__c smsHist2 = populateSMSHistory(null, 'Test Message 2', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
        smsHistList.add(smsHist2);
        smagicinteract__smsMagic__c smsHist3 = populateSMSHistory(null, 'Test Message 3', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
		smsHistList.add(smsHist3);
        
        database.insert (smsHistList);
        
        List<smagicinteract__Incoming_SMS__c> incSMSList = new List<smagicinteract__Incoming_SMS__c>();
        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(null, 'Test Message 1', '2246003446', '16302063156', per.id);
        incomingSMS1.DeltakSRPSMS__SMS_History__c = smsHist1.id;
        incSMSList.add(incomingSMS1);
        smagicinteract__Incoming_SMS__c incomingSMS2 = populateIncomingSMS(null, 'Test Message 2', '2246003446', '16302063156', per.id);
        incSMSList.add(incomingSMS2);
        smagicinteract__Incoming_SMS__c incomingSMS3 = populateIncomingSMS(null, 'Test Message 3', '2246003446', '16302063156', per.id);
        incSMSList.add(incomingSMS3);
        
        database.insert (incSMSList);
        
        Test.startTest();
        
        String status3 = SRPSMSActivityProcessor.createAllSMSActivity(per.id, false,'Affl'); 
        System.assertEquals(Label.Create_SMS_Activity_Success,status3);
        
        String status3b = SRPSMSActivityProcessor.createAllSMSActivity(per.id, true,'Affl'); 
//        System.assertEquals(Label.Create_SMS_Activity_Failure,status3b);
        
        List<Task> allSMSActivity = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhoId =:per.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
        System.debug('Number of activities = ***='+allSMSActivity.size());
        System.assertEquals(6, allSMSActivity.size()); 
        
        Map<Id,Task> activityMap = new Map<Id,Task>(allSMSActivity);
        Map<String,String> messageMap = new Map<String,String>();
        Map<String,String> resultMap = new Map<String,String>();
        for(Task t: allSMSActivity)
        {
        	messageMap.put(t.external_id__c,t.description);
        	resultMap.put(t.external_id__c,t.Result__c);
        }
        
       	System.assert(messageMap.containsKey(smsHist1.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS1.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS3.smagicinteract__external_field__c));
       	
		System.assertEquals((messageMap.get(smsHist1.smagicinteract__external_field__c).contains('Test Message 1')), true);
		System.assertEquals((messageMap.get(smsHist2.smagicinteract__external_field__c).contains('Test Message 2')), true);
		System.assertEquals((messageMap.get(smsHist3.smagicinteract__external_field__c).contains('Test Message 3')), true);
		
		System.assertEquals((resultMap.get(smsHist1.smagicinteract__external_field__c).containsOnly('Successful')), true);
       	System.assertEquals((resultMap.get(smsHist2.smagicinteract__external_field__c).containsOnly('Successful')), true);
        System.assertEquals((resultMap.get(smsHist3.smagicinteract__external_field__c).containsOnly('Successful')), true);
        
        System.assertEquals((messageMap.get(incomingSMS1.smagicinteract__external_field__c).contains('Test Message 1')), true);
		System.assertEquals((messageMap.get(incomingSMS2.smagicinteract__external_field__c).contains('Test Message 2')), true);
		System.assertEquals((messageMap.get(incomingSMS3.smagicinteract__external_field__c).contains('Test Message 3')), true);
		
		System.assertEquals((resultMap.get(incomingSMS1.smagicinteract__external_field__c).containsOnly('Successful')), true);
       	System.assertEquals((resultMap.get(incomingSMS2.smagicinteract__external_field__c).containsOnly('Successful')), true);
        System.assertEquals((resultMap.get(incomingSMS3.smagicinteract__external_field__c).containsOnly('Successful')), true); 
		
		
		
        Test.stopTest();
     } 
    
 
        static testMethod void emptyDataset() {
    	
        
       
        	//Send in invalid recordIds and verify "Empty" status.
        	String status1 = SRPSMSActivityProcessor.createSMSHistoryActivity('ABCD', false); 
        	System.assertEquals(Label.Create_SMS_Activity_Empty,status1);
        	
        	String status2 = SRPSMSActivityProcessor.createIncomingSMSActivity('XYZ', false);
        	System.assertEquals(Label.Create_SMS_Activity_Empty,status2);
        	
        	String status3 = SRPSMSActivityProcessor.createAllSMSActivity('LMNO', false,'Oppty'); 
        	System.assertEquals(Label.Create_SMS_Activity_Empty,status3);
    	
    }
    
    static testMethod void allOpptySMSActivity_SchedulerTest() {
        
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        system.debug('profDOA--> '+profDOA);
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        
        
        
        SrpTriggerOverrideInSrm__c ovr = new SrpTriggerOverrideInSrm__c(SetupOwnerId = doa.Id,Override_All__c=true);
		insert ovr;
        
        System.RunAs(doa)
        {
        	ID acctid = findAccountRecordType();
	        Account a = new Account();
	        a.Name = 'Test Account';
	        a.recordTypeID = acctid;
	        a.Admissions_Phone__c = '888-888-8888';
	        insert a;
			
			RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
			
			Contact per = new Contact();
			per.recordtypeid = rt4.id;
		    per.firstname = 'Jane';
		    per.lastname = 'Doe';
		    per.Employer_Company__c = 'Test Company';
		    per.accountid = a.id;
		    insert per;
		    
		    
	        
	        Opportunity opp = populateOpportunityFields('New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1);
	        insert opp;
	        
	        List<smagicinteract__smsMagic__c> smsHistList = new List<smagicinteract__smsMagic__c>();
	        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(opp.id, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
	        smsHistList.add(smsHist1);
	        smagicinteract__smsMagic__c smsHist2 = populateSMSHistory(opp.id, 'Test Message 2', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
	        smsHistList.add(smsHist2);
	        smagicinteract__smsMagic__c smsHist3 = populateSMSHistory(opp.id, 'Test Message 3', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
			smsHistList.add(smsHist3);
	        System.debug('Number of SMS Hist = ***='+smsHistList.size());
	        database.insert (smsHistList);
	        
	        Test.startTest();
	        
	        String status3 = SRPSMSActivityProcessor.createAllSMSActivity(opp.id, false,'Oppty'); 
	        System.assertEquals(Label.Create_SMS_Activity_Success,status3);
	        
	        List<Task> allSMSActivity = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhatId =:opp.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
	        System.debug('Number of activities = ***='+allSMSActivity.size());
	        System.assertEquals(3, allSMSActivity.size()); 
	        
	        Map<Id,Task> activityMap = new Map<Id,Task>(allSMSActivity);
	        Map<String,String> messageMap = new Map<String,String>();
	        Map<String,String> resultMap = new Map<String,String>();
	        for(Task t: allSMSActivity)
	        {
	        	messageMap.put(t.external_id__c,t.description);
	        	resultMap.put(t.external_id__c,t.Result__c);
	        }
	        
	       	System.assert(messageMap.containsKey(smsHist1.smagicinteract__external_field__c));
	       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
	       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
	       	
			System.assertEquals((messageMap.get(smsHist1.smagicinteract__external_field__c).contains('Test Message 1')), true);
			System.assertEquals((messageMap.get(smsHist2.smagicinteract__external_field__c).contains('Test Message 2')), true);
			System.assertEquals((messageMap.get(smsHist3.smagicinteract__external_field__c).contains('Test Message 3')), true);
			
			System.assertEquals((resultMap.get(smsHist1.smagicinteract__external_field__c).containsOnly('Successful')), true);
	       	System.assertEquals((resultMap.get(smsHist2.smagicinteract__external_field__c).containsOnly('Successful')), true);
	        System.assertEquals((resultMap.get(smsHist3.smagicinteract__external_field__c).containsOnly('Successful')), true);
			
		
			
	     
	        
	        List<smagicinteract__Incoming_SMS__c> incSMSList = new List<smagicinteract__Incoming_SMS__c>();
	        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(opp.id, 'Test Message 1', '2246003446', '16302063156', per.id);
	      //  incomingSMS1.DeltakSRPSMS__SMS_History__c = smsHist1.id;
	        incSMSList.add(incomingSMS1);
	        smagicinteract__Incoming_SMS__c incomingSMS2 = populateIncomingSMS(opp.id, 'Test Message 2', '2246003446', '16302063156', per.id);
	        incSMSList.add(incomingSMS2);
	        smagicinteract__Incoming_SMS__c incomingSMS3 = populateIncomingSMS(opp.id, 'Test Message 3', '2246003446', '16302063156', per.id);
	        incSMSList.add(incomingSMS3);
	        System.debug('Number of Incoming SMS = ***='+incSMSList.size());
	        database.insert (incSMSList,false);
	        
	   		//Execute the job once
	        SRPSMSActivityScheduler sas = new SRPSMSActivityScheduler();
	        String cron_exp = '0 0 21 * * ?';
	        String jobId = System.schedule('SRPSMSActivity',cron_exp,sas);
	        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
	        
	        // Verify the expressions are the same
			System.assertEquals(cron_exp, ct.CronExpression);
			// Verify the job has not run
			System.assertEquals(0, ct.TimesTriggered);
			
			System.assertNotEquals('SRPSMSActivityScheduler',[SELECT id, name FROM account WHERE id = :a.id].name);
			
			Test.stopTest();
	   		
	        
	        List<Task> allSMSActivity1 = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhatId =:opp.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
	        System.debug('Number of activities = ***='+allSMSActivity1.size());
	        System.assertEquals(6, allSMSActivity1.size()); 
	        
	        Map<Id,Task> activityMap1 = new Map<Id,Task>(allSMSActivity1);
	        Map<String,String> messageMap1 = new Map<String,String>();
	        Map<String,String> resultMap1 = new Map<String,String>();
	        for(Task t: allSMSActivity1)
	        {
	        	messageMap1.put(t.external_id__c,t.description);
	        	resultMap1.put(t.external_id__c,t.Result__c);
	        }
	        
	       	System.assert(messageMap1.containsKey(incomingSMS1.smagicinteract__external_field__c));
	       	System.assert(messageMap1.containsKey(incomingSMS2.smagicinteract__external_field__c));
	       	System.assert(messageMap1.containsKey(incomingSMS3.smagicinteract__external_field__c));
	        
	        System.assertEquals((messageMap1.get(incomingSMS1.smagicinteract__external_field__c).contains('Test Message 1')), true);
			System.assertEquals((messageMap1.get(incomingSMS2.smagicinteract__external_field__c).contains('Test Message 2')), true);
			System.assertEquals((messageMap1.get(incomingSMS3.smagicinteract__external_field__c).contains('Test Message 3')), true);
			
			System.assertEquals((resultMap1.get(incomingSMS1.smagicinteract__external_field__c).containsOnly('Successful')), true);
	       	System.assertEquals((resultMap1.get(incomingSMS2.smagicinteract__external_field__c).containsOnly('Successful')), true);
	        System.assertEquals((resultMap1.get(incomingSMS3.smagicinteract__external_field__c).containsOnly('Successful')), true);
			
	
        }
        
     }
     
    static testMethod void allAfflSMSActivity_SchedulerTest() {
        
        
        ID acctid = findAccountRecordType();
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a;

		Contact per = new Contact();
		per.recordtypeid = findContactRecordType();
	    per.firstname = 'Jane';
	    per.lastname = 'Doe';
	    per.Employer_Company__c = 'Test Company';
	    per.accountid = a.id;
	    insert per;
        
        
        List<smagicinteract__smsMagic__c> smsHistList = new List<smagicinteract__smsMagic__c>();
        smagicinteract__smsMagic__c smsHist1 = populateSMSHistory(null, 'Test Message 1', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
        smsHistList.add(smsHist1);
        smagicinteract__smsMagic__c smsHist2 = populateSMSHistory(null, 'Test Message 2', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
        smsHistList.add(smsHist2);
        smagicinteract__smsMagic__c smsHist3 = populateSMSHistory(null, 'Test Message 3', per.Name, '16302063156', '2246003446', 'sent', 'delivered', per.id);
		smsHistList.add(smsHist3);
        
        database.insert (smsHistList);
        
        List<smagicinteract__Incoming_SMS__c> incSMSList = new List<smagicinteract__Incoming_SMS__c>();
        smagicinteract__Incoming_SMS__c incomingSMS1 = populateIncomingSMS(null, 'Test Message 1', '2246003446', '16302063156', per.id);
        incomingSMS1.DeltakSRPSMS__SMS_History__c = smsHist1.id;
        incSMSList.add(incomingSMS1);
        smagicinteract__Incoming_SMS__c incomingSMS2 = populateIncomingSMS(null, 'Test Message 2', '2246003446', '16302063156', per.id);
        incSMSList.add(incomingSMS2);
        smagicinteract__Incoming_SMS__c incomingSMS3 = populateIncomingSMS(null, 'Test Message 3', '2246003446', '16302063156', per.id);
        incSMSList.add(incomingSMS3);
        
        database.insert (incSMSList);
        
        Test.startTest();
        
        //Execute the job once
        SRPSMSActivityScheduler sas = new SRPSMSActivityScheduler();
        String cron_exp = '0 0 21 * * ?';
        String jobId = System.schedule('SRPSMSActivity',cron_exp,sas);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
		System.assertEquals(cron_exp, ct.CronExpression);
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		
		System.assertNotEquals('SRPSMSActivityScheduler',[SELECT id, name FROM account WHERE id = :a.id].name);
		
		Test.stopTest();
        
        
        
        List<Task> allSMSActivity = [Select Result__c, id, OwnerId, description, WhatId, subject, status, ActivityDate, Type, external_id__c from Task where WhoId =:per.id and Type in ('Text Incoming','Text Outgoing') order by CreatedDate];
        System.debug('Number of activities = ***='+allSMSActivity.size());
        System.assertEquals(6, allSMSActivity.size()); 
        
        Map<Id,Task> activityMap = new Map<Id,Task>(allSMSActivity);
        Map<String,String> messageMap = new Map<String,String>();
        Map<String,String> resultMap = new Map<String,String>();
        for(Task t: allSMSActivity)
        {
        	messageMap.put(t.external_id__c,t.description);
        	resultMap.put(t.external_id__c,t.Result__c);
        }
        
       	System.assert(messageMap.containsKey(smsHist1.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(smsHist2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS1.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS2.smagicinteract__external_field__c));
       	System.assert(messageMap.containsKey(incomingSMS3.smagicinteract__external_field__c));
       	
		System.assertEquals((messageMap.get(smsHist1.smagicinteract__external_field__c).contains('Test Message 1')), true);
		System.assertEquals((messageMap.get(smsHist2.smagicinteract__external_field__c).contains('Test Message 2')), true);
		System.assertEquals((messageMap.get(smsHist3.smagicinteract__external_field__c).contains('Test Message 3')), true);
		
		System.assertEquals((resultMap.get(smsHist1.smagicinteract__external_field__c).containsOnly('Successful')), true);
       	System.assertEquals((resultMap.get(smsHist2.smagicinteract__external_field__c).containsOnly('Successful')), true);
        System.assertEquals((resultMap.get(smsHist3.smagicinteract__external_field__c).containsOnly('Successful')), true);
        
        System.assertEquals((messageMap.get(incomingSMS1.smagicinteract__external_field__c).contains('Test Message 1')), true);
		System.assertEquals((messageMap.get(incomingSMS2.smagicinteract__external_field__c).contains('Test Message 2')), true);
		System.assertEquals((messageMap.get(incomingSMS3.smagicinteract__external_field__c).contains('Test Message 3')), true);
		
		System.assertEquals((resultMap.get(incomingSMS1.smagicinteract__external_field__c).containsOnly('Successful')), true);
       	System.assertEquals((resultMap.get(incomingSMS2.smagicinteract__external_field__c).containsOnly('Successful')), true);
        System.assertEquals((resultMap.get(incomingSMS3.smagicinteract__external_field__c).containsOnly('Successful')), true); 
		

     } 
    
}