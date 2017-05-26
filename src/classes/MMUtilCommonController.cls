public class MMUtilCommonController {
    private string mmResponse;
    public MMUtilCommonController() {
        init();
    }
    public void init() {
        this.mmResponse = '';   
    }
    public string getMmResponse() {
        return this.mmResponse;
    }
    public void autoRun() {
        long receiptNo = 0;
        long tempReceiptNo = 0;
        string json = null;
        string response = '';
        try {
           PageReference pageRef = ApexPages.currentPage();
           string params = '';
           if (pageRef != null) {
               string rq = pageRef.getParameters().get('rq');
               if (rq == 'getreceiptno') {
                   String sizeParam = pageRef.getParameters().get('size');
                   Integer size = (sizeParam == null)?0:Integer.valueOf(sizeParam);
                   if(size > 0){
                       response = getReceiptNo(size); 
                       
                   } else {
                       response = getReceiptNo(); 
                   }
                   this.mmResponse = response;
                   //this.mmResponse += '\n' + MMUtils.getLimitTrace();
                   /*
                   do {
                       receiptNo = MMUtils.generateReceiptNumber();
                       receiptNo++;
                       MMUtils.updateReceiptNumber(receiptNo);
                       tempReceiptNo = MMUtils.generateReceiptNumber();
                       this.mmResponse = String.valueOf(receiptNo);
                   }
                   while (receiptNo != tempReceiptNo);
                   */
               }
               else if (rq == 'setjobinprocess') {
                   string jid = pageRef.getParameters().get('jid');
                   MMGroupSMSJob__c job = MMUtilSch.getJobById(jid);
                   if (job != null) {
                       job.InProcess__c = true;
                       update job;
                       this.mmResponse = 'OK';
                   }
                   else {
                       this.mmResponse = 'JOB NULL';
                   }
               }
               else {
                   this.mmResponse = 'ERROR: PLEASE PROVIDE RQ PARAMETER';
               }
           }
        }
        catch(Exception exp) {
        }
    }
    
    public String getReceiptNo(){
        try {
           long receiptNo = MMUtils.generateReceiptNumber();
           //MMUtilSch.logMessage('No: ' + receiptNo);
           return String.valueOf(receiptNo);
       }
       catch(Exception exp) {
           //MMUtilSch.logMessage('Exception: ' + exp.getMessage());
           return '-100';
       }
    }
    
    public String getReceiptNo(integer size){
       string response = '';
       try {
           long receiptNo = -1;
           for (integer x = 0; x < size; x++) {
               receiptNo = MMUtils.generateReceiptNumber();
               response += String.valueOf(receiptNo) + ',';
           }
       }
       catch(Exception exp) {
           //MMUtilSch.logMessage('Exception: ' + exp.getMessage());
           response = '-100';
       }
       //MMUtilSch.logMessage(response);
       return response;
    }

 }