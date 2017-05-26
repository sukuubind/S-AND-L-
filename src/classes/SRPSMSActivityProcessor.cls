public without sharing class SRPSMSActivityProcessor {
  public Static String createSMSHistoryActivity(String recordId, Boolean isTest)
 {
 	List<smagicinteract__smsMagic__c> smsHistoryList = new List<smagicinteract__smsMagic__c>();
 	smsHistoryList = [Select s.smagicinteract__sentStatus__c, s.smagicinteract__external_field__c, s.smagicinteract__deliveryStatus__c, s.smagicinteract__SenderId__c,
 								s.smagicinteract__SMSText__c, s.smagicinteract__PhoneNumber__c, s.CreatedDate, s.OwnerId, s.Name, s.DeltakSRPSMS__Opportunity__c, s.smagicinteract__Contact__c
 								From smagicinteract__smsMagic__c s where s.Id =: recordId limit 1];
	 if(smsHistoryList.size() > 0){ 	
	 	Task smsTask = new Task();
	 	
	 	smsTask.OwnerId = smsHistoryList[0].OwnerId;
	 	smsTask.WhoId = smsHistoryList[0].smagicinteract__Contact__c;
	 	system.debug('OwnerId>>>>'+smsHistoryList[0].OwnerId);
	 	smsTask.Description = smsHistoryList[0].Name + '\r\n'+ 'From:' + smsHistoryList[0].smagicinteract__SenderId__c 
	 												+ '\r\n'+ 'To:' + smsHistoryList[0].smagicinteract__PhoneNumber__c 
	 												+ '\r\n'+ 'SMS Text:' + smsHistoryList[0].smagicinteract__SMSText__c
	 												+ '\r\n'+ 'Sent Status:' + smsHistoryList[0].smagicinteract__sentStatus__c
	 												+ '\r\n'+ 'Delivery Status:' + (smsHistoryList[0].smagicinteract__deliveryStatus__c != null? smsHistoryList[0].smagicinteract__deliveryStatus__c : 'NA');
	 	/*system.debug('Description>>>>'+smsHistoryList[0].Name + '\r\n'+ 'From:' + smsHistoryList[0].smagicinteract__SenderId__c 
	 												+ '\r\n'+ 'To:' + smsHistoryList[0].smagicinteract__PhoneNumber__c 
	 												+ '\r\n'+ 'SMS Text:' + smsHistoryList[0].smagicinteract__SMSText__c
	 												+ '\r\n'+ 'Sent Status:' + smsHistoryList[0].smagicinteract__sentStatus__c
	 												+ '\r\n'+ 'Delivery Status:' + (smsHistoryList[0].smagicinteract__deliveryStatus__c != null? smsHistoryList[0].smagicinteract__deliveryStatus__c : 'NA'));*/
	 												 
	 	if(smsHistoryList[0].DeltakSRPSMS__Opportunity__c!=null)
	 	{
	 		smsTask.WhatId = smsHistoryList[0].DeltakSRPSMS__Opportunity__c;
	 	}
	 	
	 	system.debug('What>>>>'+smsHistoryList[0].DeltakSRPSMS__Opportunity__c);
	 	smsTask.Subject = 'Outgoing SMS';
	 	
	 	smsTask.Status = 'Completed';
	 	
	 	smsTask.Type = 'Text Outgoing';
	 	
	 	smsTask.ActivityDate = (smsHistoryList[0].CreatedDate).date();
	 	smsTask.DeltakSRP__Completed_Date__c = smsHistoryList[0].CreatedDate;
	 	smsTask.Completed_Date__c = smsHistoryList[0].CreatedDate;
	 	
	 	
	 	if(isTest)
	 	{
	 		smsTask.external_id__c = generateRandomString(256);
	 	}else
	 	{
	 		smsTask.external_id__c = smsHistoryList[0].smagicinteract__external_field__c;
	 	}
	 	
	 	system.debug('Subject>>>>'+smsHistoryList[0].smagicinteract__external_field__c);
	 	
	 	smsTask.Result__c = 'Successful';
	 	try{
	 		
	 		database.upsert (smsTask,Task.external_id__c);
	 		return Label.Create_SMS_Activity_Success;
	 	}catch(DMLException dmlE)
	 	{
	 		System.debug('DML Exception: '+dmlE.getMessage());
	 		return (Label.Create_SMS_Activity_Failure+' - '+dmlE.getMessage());
	 	}
	 	
	 }	else
	 {
	 	return Label.Create_SMS_Activity_Empty;
	 }														 
 	
 }
   public Static String createIncomingSMSActivity(String recordId, Boolean isTest)
 {
 	List<smagicinteract__Incoming_SMS__c> incomingSMSList = new List<smagicinteract__Incoming_SMS__c>();
 	incomingSMSList = [Select s.smagicinteract__external_field__c, s.smagicinteract__SMS_Text__c, s.smagicinteract__Mobile_Number__c, s.smagicinteract__Inbound_Number__c,
 							 s.OwnerId, s.Name, s.DeltakSRPSMS__SMS_History__c, s.DeltakSRPSMS__Opportunity__c, s.CreatedDate, s.DeltakSRPSMS__Contact__c
 							 From smagicinteract__Incoming_SMS__c s where s.Id =: recordId limit 1];
	 if(incomingSMSList.size() > 0){ 	
	 	Task smsTask = new Task();
	 	
	 	List<smagicinteract__smsMagic__c> assocSmsHist = new List<smagicinteract__smsMagic__c>();
 		assocSmsHist = [Select s.OwnerId
 								From smagicinteract__smsMagic__c s where s.Id =: incomingSMSList[0].DeltakSRPSMS__SMS_History__c limit 1];
	 	if(assocSmsHist.size() > 0 && assocSmsHist[0].OwnerId!=null)
	 	{
	 		smsTask.OwnerId = assocSmsHist[0].OwnerId;
	 	}else
	 	{
	 		smsTask.OwnerId = UserInfo.getUserId();
	 	}
	 	
	 	smsTask.WhoId = incomingSMSList[0].DeltakSRPSMS__Contact__c;
	 	smsTask.Description = incomingSMSList[0].Name + '\r\n'+ 'From:' + incomingSMSList[0].smagicinteract__Mobile_Number__c 
	 												+ '\r\n'+ 'To:' + incomingSMSList[0].smagicinteract__Inbound_Number__c 
	 												+ '\r\n'+ 'In Reply To Outgoing SMS:' + incomingSMSList[0].DeltakSRPSMS__SMS_History__c
	 												+ '\r\n'+ 'SMS Text:' + incomingSMSList[0].smagicinteract__SMS_Text__c;
	 	if(incomingSMSList[0].DeltakSRPSMS__Opportunity__c!=null)
	 	{
	 		smsTask.WhatId = incomingSMSList[0].DeltakSRPSMS__Opportunity__c;
	 	}
	 	smsTask.Subject = 'Incoming SMS';
	 	smsTask.Status = 'Completed';
	 	smsTask.Type = 'Text Incoming';
	 	smsTask.ActivityDate = (incomingSMSList[0].CreatedDate).date();
	 	smsTask.DeltakSRP__Completed_Date__c = incomingSMSList[0].CreatedDate;
	 	smsTask.Completed_Date__c = incomingSMSList[0].CreatedDate;
	 	if(isTest)
	 	{
	 		smsTask.external_id__c = generateRandomString(256);
	 	}else
	 	{
	 		smsTask.external_id__c = incomingSMSList[0].smagicinteract__external_field__c;
	 	}
	 	
	 	smsTask.Result__c = 'Successful';
	 	try{
	 		database.upsert (smsTask,Task.external_id__c);
	 		return Label.Create_SMS_Activity_Success;
	 	}catch(DMLException dmlE)
	 	{
	 		System.debug('DML Exception: '+dmlE.getMessage());
	 		return (Label.Create_SMS_Activity_Failure+' - '+dmlE.getMessage());
	 	}
	 }else
	 {
	 	return Label.Create_SMS_Activity_Empty;
	 }
 }
   public Static String createAllSMSActivity(String recordId, Boolean isTest, String whatRec)
 {
 	List<Task> smsTaskList = new List<Task>();
 	
 		List<smagicinteract__smsMagic__c> smsHistoryList = new List<smagicinteract__smsMagic__c>();
 		if(whatRec =='Oppty')
 		{
 			smsHistoryList = [Select s.smagicinteract__sentStatus__c, s.smagicinteract__external_field__c, s.smagicinteract__deliveryStatus__c, s.smagicinteract__SenderId__c,
 								s.smagicinteract__SMSText__c, s.smagicinteract__PhoneNumber__c, s.CreatedDate, s.OwnerId, s.Name, s.DeltakSRPSMS__Opportunity__c,  s.smagicinteract__Contact__c
 								From smagicinteract__smsMagic__c s where s.DeltakSRPSMS__Opportunity__c =: recordId];
 		}else if(whatRec == 'Affl')
 		{
 			smsHistoryList = [Select s.smagicinteract__sentStatus__c, s.smagicinteract__external_field__c, s.smagicinteract__deliveryStatus__c, s.smagicinteract__SenderId__c,
 								s.smagicinteract__SMSText__c, s.smagicinteract__PhoneNumber__c, s.CreatedDate, s.OwnerId, s.Name, s.DeltakSRPSMS__Opportunity__c,  s.smagicinteract__Contact__c 
 								From smagicinteract__smsMagic__c s where  s.smagicinteract__Contact__c =: recordId];
 		}
 		

	 if(smsHistoryList.size() > 0){ 
	 	for(Integer i=0;i<smsHistoryList.size();i++)
	 	{	
	 	Task smsTask = new Task();
	 	
	 	smsTask.OwnerId = smsHistoryList[i].OwnerId;
	 	smsTask.WhoId = smsHistoryList[i].smagicinteract__Contact__c;
	 	smsTask.Description = smsHistoryList[i].Name + '\r\n'+ 'From:' + smsHistoryList[i].smagicinteract__SenderId__c 
	 												+ '\r\n'+ 'To:' + smsHistoryList[i].smagicinteract__PhoneNumber__c 
	 												+ '\r\n'+ 'SMS Text:' + smsHistoryList[i].smagicinteract__SMSText__c
	 												+ '\r\n'+ 'Sent Status:' + smsHistoryList[i].smagicinteract__sentStatus__c
	 												+ '\r\n'+ 'Delivery Status:' + (smsHistoryList[i].smagicinteract__deliveryStatus__c != null? smsHistoryList[i].smagicinteract__deliveryStatus__c : 'NA');
	 	if(smsHistoryList[i].DeltakSRPSMS__Opportunity__c!=null)
	 	{
	 		smsTask.WhatId = smsHistoryList[i].DeltakSRPSMS__Opportunity__c;
	 	}
	 	smsTask.Subject = 'Outgoing SMS';
	 	smsTask.Status = 'Completed';
	 	smsTask.Type = 'Text Outgoing';
	 	smsTask.ActivityDate = (smsHistoryList[i].CreatedDate).date();
	 	smsTask.DeltakSRP__Completed_Date__c = smsHistoryList[i].CreatedDate;
	 	smsTask.Completed_Date__c = smsHistoryList[i].CreatedDate;
	 	smsTask.external_id__c = smsHistoryList[i].smagicinteract__external_field__c;
	 	smsTask.Result__c = 'Successful';
	 	smsTaskList.add(smsTask);
	 	}
	 	
	 }
 	
 	List<smagicinteract__Incoming_SMS__c> incomingSMSList = new List<smagicinteract__Incoming_SMS__c>();
 	if(whatRec =='Oppty')
 		{
 			incomingSMSList = [Select s.smagicinteract__external_field__c, s.smagicinteract__SMS_Text__c, s.smagicinteract__Mobile_Number__c, s.smagicinteract__Inbound_Number__c,
 							 s.OwnerId, s.Name, s.DeltakSRPSMS__SMS_History__c, s.DeltakSRPSMS__Opportunity__c, s.CreatedDate, s.DeltakSRPSMS__Contact__c
 							 From smagicinteract__Incoming_SMS__c s where s.DeltakSRPSMS__Opportunity__c =: recordId];
 		}else if(whatRec == 'Affl')
 		{
 			incomingSMSList = [Select s.smagicinteract__external_field__c, s.smagicinteract__SMS_Text__c, s.smagicinteract__Mobile_Number__c, s.smagicinteract__Inbound_Number__c,
 							 s.OwnerId, s.Name, s.DeltakSRPSMS__SMS_History__c, s.DeltakSRPSMS__Opportunity__c, s.CreatedDate, s.DeltakSRPSMS__Contact__c
 							 From smagicinteract__Incoming_SMS__c s where s.DeltakSRPSMS__Contact__c =: recordId];
 		}

	 if(incomingSMSList.size() > 0){ 
	 	List<Id> smsHistoryIds = new List<Id>();
	 	for(smagicinteract__Incoming_SMS__c incSMS: incomingSMSList)
	 	{
	 		smsHistoryIds.add(incSMS.DeltakSRPSMS__SMS_History__c);
	 	}
	 	
	 	//Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([Select Id, chat_start_time__c, student__c from Opportunity where Id in: opptyIds]);
	 	
	 	List<smagicinteract__smsMagic__c> assocSmsHist = new List<smagicinteract__smsMagic__c>();
 			assocSmsHist = [Select s.Id, s.OwnerId From smagicinteract__smsMagic__c s where s.Id in: smsHistoryIds ];
 		Map<Id,smagicinteract__smsMagic__c> smsHistOwners = new Map<Id,smagicinteract__smsMagic__c>(assocSmsHist);
 		
	 	for(Integer i=0;i<incomingSMSList.size();i++)
	 	{
		 	Task smsTask = new Task();
		 	
	 		if(assocSmsHist.size() > 0)
	 		{
	 			if(smsHistOwners.containsKey(incomingSMSList[i].DeltakSRPSMS__SMS_History__c))
	 			{
	 				smsTask.OwnerId = smsHistOwners.get(incomingSMSList[i].DeltakSRPSMS__SMS_History__c).OwnerId;
	 			}else
	 			{
	 				smsTask.OwnerId = UserInfo.getUserId();
	 			}
	 		}else
	 		{
	 			smsTask.OwnerId = UserInfo.getUserId();
	 		}
		 	
		 	smsTask.WhoId = incomingSMSList[i].DeltakSRPSMS__Contact__c;
		 	smsTask.Description = incomingSMSList[i].Name + '\r\n'+ 'From:' + incomingSMSList[i].smagicinteract__Mobile_Number__c 
		 												+ '\r\n'+ 'To:' + incomingSMSList[i].smagicinteract__Inbound_Number__c 
		 												+ '\r\n'+ 'In Reply To Outgoing SMS:' + incomingSMSList[i].DeltakSRPSMS__SMS_History__c
		 												+ '\r\n'+ 'SMS Text:' + incomingSMSList[i].smagicinteract__SMS_Text__c;
		 	if(incomingSMSList[i].DeltakSRPSMS__Opportunity__c!=null)
		 	{
		 		smsTask.WhatId = incomingSMSList[i].DeltakSRPSMS__Opportunity__c;
		 	}
		 	smsTask.Subject = 'Incoming SMS';
		 	smsTask.Status = 'Completed';
		 	smsTask.Type = 'Text Incoming';
		 	smsTask.ActivityDate = (incomingSMSList[i].CreatedDate).date();
		 	smsTask.DeltakSRP__Completed_Date__c = incomingSMSList[i].CreatedDate;
	 		smsTask.Completed_Date__c = incomingSMSList[i].CreatedDate;
		 	if(isTest)
	 		{
	 			smsTask.external_id__c = generateRandomString(256);
	 		}else
	 		{
		 		smsTask.external_id__c = incomingSMSList[i].smagicinteract__external_field__c;
	 		}
		 	smsTask.Result__c = 'Successful';
		 	smsTaskList.add(smsTask);
	 	}
	 	
	 }
	
	 if(smsTaskList.size() > 0)
	 {
	 try{
	 		system.debug('smsTaskList-->'+smsTaskList);
	 		database.upsert (smsTaskList,Task.external_id__c);
	 		return Label.Create_SMS_Activity_Success;
	 	}catch(DMLException dmlE)
	 	{
	 		System.debug('DML Exception: '+dmlE.getStackTraceString());
	 		return (Label.Create_SMS_Activity_Failure+' - '+dmlE.getMessage());
	 	}
	 }else
	 {
	 	return Label.Create_SMS_Activity_Empty;
	 }

 }
 
 public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
}
}