public class MMSMSDeleteHistoryController {
    public string startDate { get; set; }
    public string endDate { get; set; }
    public boolean isTask { get; set; }
    public string isTaskText { get; set; }
    public boolean isReceipt { get; set; }
    public string isReceiptText { get; set; }
    public boolean isSMSLog { get; set; }
    public string isSMSLogText { get; set; }
    public Id batchId { get; set; }
    public string operation { get; set; }
    public MMSMSDeleteHistoryController() {
        init();
    }
    public void init() {
        this.isTask = true;
        this.isReceipt = true;
        this.isSMSLog = true;
        this.startDate = Datetime.now().format('MM/dd/yyyy');
        this.endDate = Datetime.now().format('MM/dd/yyyy');
        this.operation = '';
    }
    public PageReference autoRun() {
        if (!MMSMSUIPermission.isSystemAdministrator(null)) {
            PageReference pageRef = new PageReference('/apex/mmsmsaccessdenied');
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    public void deleteHistory() {
        deleteHistory(false);
    }
    public void deleteHistory(boolean isTest) {
        PageReference pr = System.currentPageReference();
        string qry = pr.getParameters().get('qry');
        string sdt = pr.getParameters().get('sdt');
        string edt = pr.getParameters().get('edt');
        this.operation = 'deleted';
        if (qry == '1') {
            this.isTaskText = '';
            this.isReceiptText = '';
            this.isSMSLogText = '';
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from Task', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), isTest ? 's' : 'd'));
            }
        }
        else if (qry == '2') {
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from MMSMSReceipt__c', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), isTest ? 's' : 'd'));
            }                
        }
        else if (qry == '3') {
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from MM_SMS_Log__c', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), isTest ? 's' : 'd'));
            }               
        }
    }
    public void batchExecute() {
        batchExecute(false);
    }
    public void batchExecute(boolean isTest) {
        PageReference pr = System.currentPageReference();
        string qry = pr.getParameters().get('qry');
        string sdt = pr.getParameters().get('sdt');
        string edt = pr.getParameters().get('edt');                
        this.operation = 'selected';
        if (qry == '1') {
            this.isTaskText = '';
            this.isReceiptText = '';
            this.isSMSLogText = '';
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from Task', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), 's'));
            }                
        }
        else if (qry == '2') {
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from MMSMSReceipt__c', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), 's'));
            }                
        }
        else if (qry == '3') {
            if (!isTest) {
                this.batchId = Database.executeBatch(new MMSMSDbJob('select Id from MM_SMS_Log__c', (sdt + ' 00:00 AM'), (edt + ' 00:00 AM'), 's'));
            }                
        }
    }
    public void batchStatus() {
        string qry = '';
        try {
            PageReference pr = System.currentPageReference();
            qry = pr.getParameters().get('qry');
            AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                  FROM AsyncApexJob WHERE ID = :this.batchId];
            MMJobRecordCount__c cnt = MMUtilBatchJob.getBatchCount();
            if (qry == '1') {
                this.isTaskText = cnt.RecordCount__c + ' ' + this.operation + ' - ' + aaj.Status;
            }
            else if (qry == '2') {
                this.isReceiptText = cnt.RecordCount__c + ' ' + this.operation + ' - ' + aaj.Status;
            }
            else if (qry == '3') {
                this.isSMSLogText = cnt.RecordCount__c + ' ' + this.operation + ' - ' + aaj.Status;
            }
            else if (qry == '4') {
                MMUtilBatchJob.resetBatchCount();
            }
        }
        catch(Exception exp) {
            if (qry == '1')
                this.isTaskText = exp.getMessage();
            else if (qry == '2')
                this.isReceiptText = exp.getMessage();            
            else if (qry == '3')
                this.isSMSLogText = exp.getMessage();
        }
    }
    public void cancel() {
    }
}