public class MMTaskSMSControllerExtension {
    private final Task t;
    private MM_SMS_Log__c smsLog;
    public MMTaskSMSControllerExtension(ApexPages.StandardController stdController) {
        this.t = (Task)stdController.getRecord();
        try {
            smsLog = MMUtilLog.getSMSLogByTaskId(t.Id);
        }
        catch(Exception exp) {
            
        }
    }
    public string getSmsType() {
        try {
            if (this.smsLog.SMSType__c != null)
                return this.smsLog.SMSType__c;
            else
                return 'N/A';
        }
        catch(Exception exp) {
            return 'N/A';
        }
    }
    public string getSmsPhone() {
        try {
            if (this.smsLog.ReceipientPhone__c != null)
                return this.smsLog.ReceipientPhone__c;
            else
                return 'N/A';
        }
        catch(Exception exp) {
            return 'N/A';
        }
    }
    public string getSmsMessage() {
        try {       
            string msg = this.smsLog.Message__c;
            if (MMUtils.stringEmptyNull(msg)) {
                msg = 'BLANK';
            }
            return msg;
        }
        catch(Exception exp) {
            return 'N/A';
        }
    }
}