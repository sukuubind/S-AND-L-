public class ReplySMSController {
    private string smsResponse;
    public ReplySMSController() {
        init();
    }
    public void init() {
        this.smsResponse = 'OK';   
    }
    public string getSmsResponse() {
        return this.smsResponse;
    }
    public PageReference autoRun() {
        PageReference pageRef = ApexPages.currentPage();
        try {
           string params = '';
           if (pageRef != null) {
               string id = pageRef.getParameters().get('id');
               string phone = pageRef.getParameters().get('phone');
               string message =pageRef.getParameters().get('message');
               string status =pageRef.getParameters().get('status');
               string keylink = pageRef.getParameters().get('keylink');
               MMSMSReceipt__c receiptRow = null;
               Task t;
               string smsDeliveryTime = null;
               DateTime serverDt = null;
               
               if(!MMUtils.stringEmptyNull(status)) {
                   status = status.toLowerCase();
                   serverDt = MMUtilTimeZone.getServerGMTDateTime();
                   receiptRow = MMUtils.getReceiptRecord(id);
                                      
                   smsDeliveryTime = MMUtilTimeZone.getCurrentDateTimeTz(serverDt, receiptRow.TrackDeliveryTimeZone__c, receiptRow.IsDayLightSaving__c);
                   receiptRow.TrackDeliveryDateTime__c = MMUtilTimeZone.getGMTDateTime(serverDt, receiptRow.TrackDeliveryTimeZone__c);
                   update receiptRow;
                   
                   //Not working by calling the MMUtils.updateTask
                   t = [select Id from Task where Id = :receiptRow.TaskId__c];
                   if (status== 'd') t.MMSMSDeliveryStatus__c = 'SMS Delivered';
                   else if(status== 'f') t.MMSMSDeliveryStatus__c = 'SMS Sending Failed';
                   else if(status== 'p') t.MMSMSDeliveryStatus__c = 'SMS Pending';
                   else t.MMSMSDeliveryStatus__c = 'Status Received: ' + status;
                   t.MMSMSDeliveryDateTime__c = smsDeliveryTime;
                   update t;
               }
               else if (keylink != null) {
                   //MMDebug__c deb = new MMDebug__c();
                   //deb.message__c = 'keylink,phone=' + phone + ',message=' + message;
                   //insert deb;
                   MMSMSKeylink__c existingKeyword = null;
                   string keyword = message;
                   string emlMsg = '';
                   Contact cRec = null;
                   List<Contact> cRecs = null;
                   MM_SMS_Log__c lg = null;
                   List<MM_SMS_Log__c> lgs = new List<MM_SMS_Log__c>();
                   List<Id> ids = MMSMSKeylinkUtil.getContactByPhone(phone);
                   User usr = MMSMSKeylinkUtil.getUserByEmail(MMSMSKeylinkUtil.getDefaultKeylinkEmail());
                   if (message.indexOf(' ') > 0) {
                       keyword = message.split(' ')[0];
                   }
                   existingKeyword = MMSMSKeylinkUtil.getMMSMSKeylink(keyword);
                   if (existingKeyword != null) {
                       MMSMSKeylinkUtil.storeExistentKeylink(ids, message, phone, usr, this, existingKeyword);
                   }
                   else {
                       MMSMSKeylinkUtil.storeNonExistentKeylink(ids, message, phone, usr, this);
                   }
               }
               else {
                   string stdFName;
                   string stdLName;
                   string emlMsg = '';
                   boolean isStopMessage = isStopMessage(message);
        
                   MMSMSReceipt__c rc = MMUtils.getReceiptRecord(id);
                   Id mailId = rc.ownerId;
                   User usr = [SELECT FirstName, LastName, Email FROM User where Id = :rc.ownerId]; 
                   if (rc.EntityType__c == 'op') {
                       Contact cRec = null;
                       Opportunity opRec = [select c.Id, c.Student_First_Name__c, c.Student_Last_Name__c, c.Student_Record_Id__c from Opportunity c where c.Id = :rc.EntityId__c limit 1];
                       t = this.createTask(opRec.Id, 'op', rc.ownerId, message, 'REPLY: ');
                       emlMsg = this.getEmailMessage(opRec.Student_Last_Name__c, opRec.Student_First_Name__c, 
                                                       usr.LastName, usr.FirstName, opRec.Id, 'op', message, 'Reply');
                       insert MMUtilLog.createSMSLog(opRec.Id, 'op', null, null, phone, '0_a', false, null, 'Inbound', message, null, t.Id);
                       if(isStopMessage){
                           cRec = [select Ok_To_Text__c, Id from Contact where id = :opRec.Student_Record_Id__c];
                           cRec.Ok_To_text__c = 'No';
                           update cRec;
                       }
                   }
                   else if(rc.EntityType__c == 'af') {
                       Contact cRec = [select c.Id, c.LastName, c.FirstName from Contact c where c.Id = :rc.EntityId__c limit 1];
                       t = this.createTask(cRec.Id, 'af', rc.ownerId, message, 'REPLY: ');
                       emlMsg = this.getEmailMessage(cRec.LastName, cRec.FirstName, 
                                                       usr.LastName, usr.FirstName, cRec.Id, 'af', message, 'Reply');
                       insert MMUtilLog.createSMSLog(cRec.Id, 'af', null, null, phone, '0_a', false, null, 'Inbound', message, null, t.Id);
                       if(isStopMessage){
                           cRec.Ok_To_text__c = 'No';
                           update cRec;
                       }
                   }
                   if(isStopMessage){
                       MMUtils.sendSingleEmail(usr.email, usr.FirstName + ' ' + usr.LastName, 'SMS STOP Reply Received', emlMsg); //mailId);
                   } else {
                       MMUtils.sendSingleEmail(usr.email, usr.FirstName + ' ' + usr.LastName, 'SMS Reply Received', emlMsg); //mailId);
                   }
               }              
           }
           this.smsResponse = 'OK';
        }
        catch(DmlException e) {
           this.smsResponse = 'OK';
        }
        catch(QueryException e){
            this.smsResponse = 'OK';
        }
        catch(Exception e){
            this.smsResponse = 'OK';
        }
        return pageRef;
    }
    
    public boolean isStopMessage(string content){
        if(content.toLowerCase() == 'stop' || content.toLowerCase().startsWith('stop ')){
            return true;
        }
        return false;
    }
    
    public Task createTask(string entityId, string entityType, string ownerId, string message, string messageType) {
       Task t = new Task();       
       message = messageType + message;
       t.Subject = message.substring(0, (message.length() > 20 ? 20 : message.length()));
       t.WhoId = (entityType == 'af') ? entityId : null;
       t.WhatId = (entityType == 'op') ? entityId : null;
       t.Type = 'SMS';
       t.status = 'Completed';
       t.OwnerId = ownerId;  
       t.Result__c = 'Successful';
       t.MMSMSDeliveryStatus__c = 'Not Required';
       t.ActivityDate = System.today();
       insert t;
       return t;
    }
    
    public string getEmailMessage(string entitylname, string entityfname, string ulname, string ufname,
                                    string entityId, string entityType, string smsMessage, string messageType) {
        string message = '';
        message += 'Dear ' + ulname + ', ' + ufname + ',<br><br>' +
                        'A new SMS ' + messageType + ' has been received for ' + this.getEntityTypeText(entityType) + ': ' + 
                        entitylname + ', ' + entityfname +
                        '<br><br>' + smsMessage + '<br><br>' +
                        'Full details of this message are at: <a href="' + MMUtilConstants.getReplyUrl() + '/' + entityId + '">' + 
                        MMUtilConstants.getReplyUrl() + '/' + entityId + '</a><br><br>' +
                        'AUTO GENERATED EMAIL, PLEASE DO NOT REPLY';
        return message;
    }
    
    public string getEntityTypeText(string entityType) {
        string txt = '';
        if (entityType == 'op') txt = 'Opportunity';
        else if (entityType == 'af') txt = 'Affiliation';
        else txt = '';
        return txt;
    }
}