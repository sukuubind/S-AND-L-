global class SRPSMSActivityScheduler implements Schedulable{
	static String CRON_EXP = '0 0 1 ? * * 2022';
    
    global void execute(SchedulableContext ctx) {
        System.debug ('(DateTime.now()-24)'+(DateTime.now()-24));
        System.debug ('DateTime.now()'+DateTime.now());
        List<smagicinteract__smsMagic__c> smsHistoryList = [Select s.smagicinteract__sentStatus__c, s.smagicinteract__external_field__c, s.smagicinteract__deliveryStatus__c, s.smagicinteract__SenderId__c,
 								s.smagicinteract__SMSText__c, s.smagicinteract__PhoneNumber__c, s.CreatedDate, s.OwnerId, s.Name, s.DeltakSRPSMS__Opportunity__c,  s.smagicinteract__Contact__c
 								From smagicinteract__smsMagic__c s where (s.createdDate >=: (DateTime.now()-1) OR s.LastModifiedDate >=:  (DateTime.now()-1))];
        System.debug ('smsHistoryList'+smsHistoryList);
        SRPSMSActivityHelper.createAllSMSHistoryActivity(smsHistoryList,false);
        
        List<smagicinteract__Incoming_SMS__c> incomingSMSList = [Select s.smagicinteract__external_field__c, s.smagicinteract__SMS_Text__c, s.smagicinteract__Mobile_Number__c, s.smagicinteract__Inbound_Number__c,
 							 s.OwnerId, s.Name, s.DeltakSRPSMS__SMS_History__c, s.DeltakSRPSMS__Opportunity__c, s.CreatedDate, s.DeltakSRPSMS__Contact__c
 							 From smagicinteract__Incoming_SMS__c s where (s.createdDate >=: (DateTime.now()-1) OR s.LastModifiedDate >=:  (DateTime.now()-1))];
        
        SRPSMSActivityHelper.createAllIncomingSMSActivity(incomingSMSList,false);
   
    } 
	
}