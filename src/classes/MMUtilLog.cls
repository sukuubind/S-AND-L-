public class MMUtilLog {
    public static MM_SMS_Log__c createSMSLog(string senderId, string senderType, string receipientId,
                                                string receipientType, string receipientPhone,
                                                string receipientTimezone, boolean receipientDayLight,
                                                DateTime sendReceiveDateTime, string smsType,
                                                string message, string receiptId, string taskId) {
        MM_SMS_Log__c c = new MM_SMS_Log__c();
        c.SenderId__c = MMUtils.stringEmptyNull(senderId) ? null : senderId;
        c.SenderType__c = MMUtils.stringEmptyNull(senderType) ? null : senderType; 
        c.ReceipientId__c = MMUtils.stringEmptyNull(receipientId) ? null : receipientId;
        c.ReceipientType__c = MMUtils.stringEmptyNull(receipientType) ? null : receipientType;
        c.ReceipientPhone__c = MMUtils.stringEmptyNull(receipientPhone) ? null : receipientPhone;
        c.ReceipientTimezone__c = MMUtils.stringEmptyNull(receipientTimezone) ? null : receipientTimezone;
        c.ReceipientDayLightSaving__c = receipientDayLight;
        c.SendReceiveDateTime__c = sendReceiveDateTime == null ? DateTime.now() : sendReceiveDateTime;
        c.SMSType__c = MMUtils.stringEmptyNull(smsType) ? null : smsType;
        c.Message__c = MMUtils.stringEmptyNull(message) ? null : message;
        c.ReceiptId__c = MMUtils.stringEmptyNull(receiptId) ? null : receiptId;
        c.TaskId__c = MMUtils.stringEmptyNull(taskId) ? null : taskId;
        if(c.SMSType__c == 'keylink'){
            c.KeylinkKeyword__c = MMSMSKeylinkUtil.getAdjustedKeyword(c.Message__c.contains(' ')? c.Message__c.split(' ')[0] : c.Message__c);
        }
        //insert c;
        return c;
    }
    
    public static MM_SMS_Log__c updateSMSLog(Id id, string senderId, string senderType, string receipientId,
                                                 string receipientType, string receipientPhone,
                                                string receipientTimezone, boolean receipientDayLight,
                                                DateTime sendReceiveDateTime, string smsType,
                                                string message, string receiptId, string taskId) {
        MM_SMS_Log__c c = getSMSLog(id);
        if (c != null) {
            c.SenderId__c = MMUtils.stringEmptyNull(senderId) ? null : senderId;
            c.SenderType__c = MMUtils.stringEmptyNull(senderType) ? null : senderType;
            c.ReceipientId__c = MMUtils.stringEmptyNull(receipientId) ? null : receipientId;
            c.ReceipientType__c = MMUtils.stringEmptyNull(receipientType) ? null : receipientType;
            c.ReceipientPhone__c = MMUtils.stringEmptyNull(receipientPhone) ? null : receipientPhone;
            c.ReceipientTimezone__c = MMUtils.stringEmptyNull(receipientTimezone) ? null : receipientTimezone;
            c.ReceipientDayLightSaving__c = receipientDayLight;
            c.SendReceiveDateTime__c = sendReceiveDateTime == null ? DateTime.now() : sendReceiveDateTime;
            c.SMSType__c = MMUtils.stringEmptyNull(smsType) ? null : smsType;
            c.Message__c = MMUtils.stringEmptyNull(message) ? null : message;
            c.ReceiptId__c = MMUtils.stringEmptyNull(receiptId) ? null : receiptId;
            c.TaskId__c = MMUtils.stringEmptyNull(taskId) ? null : taskId;
            update c;
        }
        return c;
    }
    
    public static MM_SMS_Log__c getSMSLog(Id id) {
        MM_SMS_Log__c c = [select c.Id, c.SenderId__c, c.SenderType__c, c.ReceipientId__c, c.ReceipientType__c, c.ReceipientPhone__c,
                            c.ReceipientTimezone__c, c.ReceipientDayLightSaving__c, c.SendReceiveDateTime__c,
                            c.SMSType__c, c.Message__c, c.ReceiptId__c, c.TaskId__c 
                            from MM_SMS_Log__c c
                            where c.Id = :id limit 1];
        return c;
    }
    public static MM_SMS_Log__c getSMSLogByTaskId(Id id) {
        MM_SMS_Log__c c = [select c.Id, c.SenderId__c, c.SenderType__c, c.ReceipientId__c, c.ReceipientType__c, c.ReceipientPhone__c,
                            c.ReceipientTimezone__c, c.ReceipientDayLightSaving__c, c.SendReceiveDateTime__c,
                            c.SMSType__c, c.Message__c, c.ReceiptId__c, c.TaskId__c 
                            from MM_SMS_Log__c c
                            where c.TaskId__c = :id limit 1];
        return c;
    }
}