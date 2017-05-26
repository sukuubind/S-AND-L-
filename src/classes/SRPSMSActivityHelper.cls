public without sharing class SRPSMSActivityHelper {
    public Static String createAllSMSHistoryActivity(List<smagicinteract__smsMagic__c> smsHistoryList, Boolean isTest)
    {
        List<Task> smsTaskList = new List<Task>();
    	Map<Id, String> activityStatusSuccess = new Map<Id,String>();
    	Map<Id, String> activityStatusFailure = new Map<Id,String>();
    	Map<String, String> extId = new Map<String,String>();
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
            activityStatusSuccess.put(smsHistoryList[i].id,'Created');
            activityStatusFailure.put(smsHistoryList[i].id,'Failed');
            }
            
         }
    
     if(smsTaskList.size() > 0)
     {
     	List<Database.UpsertResult>  uResults = new List<Database.UpsertResult>();
     	   try{
     	   uResults = database.upsert (smsTaskList,Task.external_id__c,true);
     	   System.debug('Upsert Results: '+uResults);
     	   //updateActivityCreationStatus('smagicinteract__smsMagic__c', activityStatusSuccess);
     	   }catch(DMLException dmlE)
	 	{
	 		System.debug('Upsert Results: '+uResults);
	 		System.debug('DML Exception: '+dmlE.getMessage());
	 		//updateActivityCreationStatus('smagicinteract__smsMagic__c', activityStatusFailure);
	 		return (Label.Create_SMS_Activity_Failure+' - '+dmlE.getMessage());
	 	}
     	   Map<String, String> results = new Map<String, String>();
     	   System.debug('Upsert Results: '+uResults);
     	   for(Integer i=0; i<smsTaskList.size(); i++)
     	   {
     	   		Task sTask = smsTaskList[i];
     	   		Database.upsertResult uR = uResults[i];
     	   		
     	   		if(uR.getId()!=null)
     	   		{
     	   			if(uR.isCreated())
     	   			{
     	   				results.put(sTask.external_id__c,'Created');
     	   			}else
     	   			{
         				results.put(sTask.external_id__c,'Updated');
         			}
     	   		}else
     	   		{
     	   			results.put(sTask.external_id__c,'Failed');
     	   		}
     	   }
     	   /*for(Database.upsertResult result:uResults) {
         		if (result.isSuccess())
         		{
         			if(result.isCreated())
         			{
         				results.put(result.getId(),'Created');
         			}else
         			{
         				results.put(result.getId(),'Updated');
         			}
         		}else{
         			results.put(result.getId(),'Failed');
         		}
     	   }*/
     	   System.debug('results --->'+results);
     	   updateActivityCreationStatus('smagicinteract__smsMagic__c',results);
     	   
           return Label.Create_SMS_Activity_Success;
        
     }else
	 {
	 	return Label.Create_SMS_Activity_Empty;
	 }
	
 }
 
 
    public Static String createAllIncomingSMSActivity(List<smagicinteract__Incoming_SMS__c> incomingSMSList, Boolean isTest)
    {
        List<Task> smsTaskList = new List<Task>();

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
            
            if(assocSmsHist.size() > 0 && assocSmsHist[0].OwnerId!=null)
            {
                if(smsHistOwners.containsKey(incomingSMSList[i].DeltakSRPSMS__SMS_History__c))
                {
                    smsTask.OwnerId = smsHistOwners.get(incomingSMSList[i].DeltakSRPSMS__SMS_History__c).OwnerId;
                }
            }else
            {
                smsTask.OwnerId = incomingSMSList[i].OwnerId;
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
                smsTask.external_id__c = SRPSMSActivityProcessor.generateRandomString(256);
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
     	List<Database.upsertResult> uResults  = database.upsert (smsTaskList,Task.external_id__c,false);
     	Map<String, String> results = new Map<String, String>();
     	   for(Database.upsertResult result:uResults) {
         		if (result.isSuccess())
         		{
         			if(result.isCreated())
         			{
         				results.put(result.getId(),'Created');
         			}else
         			{
         				results.put(result.getId(),'Updated');
         			}
         		}else{
         			results.put(result.getId(),'Failed');
         		}
     	   }
     	updateActivityCreationStatus('smagicinteract__Incoming_SMS__c', results);
        return Label.Create_SMS_Activity_Success;
        
     }else
	 {
	 	return Label.Create_SMS_Activity_Empty;
	 }

 }
 

@future
public static void updateActivityCreationStatus(String objName, Map<String,String> results)
{
	if(objName=='smagicinteract__smsMagic__c')
	{
		List<smagicinteract__smsMagic__c> smsHist = [Select id, SMS_History_Activity__c, smagicinteract__external_field__c from smagicinteract__smsMagic__c where smagicinteract__external_field__c in: results.keyset()];
		List<smagicinteract__smsMagic__c> smsHistUpd = new List<smagicinteract__smsMagic__c>();
		if(smsHist!=null && smsHist.size()>0)
		{
			for (smagicinteract__smsMagic__c sh:smsHist)
			{
				smagicinteract__smsMagic__c shupd = new smagicinteract__smsMagic__c(id=sh.id);
				shupd.SMS_History_Activity__c = results.get(sh.smagicinteract__external_field__c);
				smsHistUpd.add(shupd);
			}
			if(smsHistUpd!=null && smsHistUpd.size()>0)
			{
				Database.update(smsHistUpd, false);
			}
		}
	}else if(objName=='smagicinteract__Incoming_SMS__c')
	{
		List<smagicinteract__Incoming_SMS__c> incSmsHist = [Select id, Incoming_SMS_Activity__c from smagicinteract__Incoming_SMS__c where id in: results.keyset()];
		List<smagicinteract__Incoming_SMS__c> incSmsHistUpd = new List<smagicinteract__Incoming_SMS__c>();
		if(incSmsHist!=null && incSmsHist.size()>0)
		{
			for (smagicinteract__Incoming_SMS__c inc:incSmsHist)
			{
				smagicinteract__Incoming_SMS__c incUpd = new smagicinteract__Incoming_SMS__c(id=inc.id);
				incUpd.Incoming_SMS_Activity__c = results.get(inc.id);
				incSmsHistUpd.add(incUpd);
			}
			if(incSmsHistUpd!=null && incSmsHistUpd.size()>0)
			{
				Database.update(incSmsHistUpd, false);
			}
		}
	}
}

}