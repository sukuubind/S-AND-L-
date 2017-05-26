public class MMSchedulerStart {
    private string mmResponse;
    
    public MMSchedulerStart() {
        init();
    }
    
    public void init() {
        mmResponse = '';
    }
    
    public string getMmResponse() {
        return this.mmResponse;
    }
    
    public void autoRun() {
        try {
            PageReference pr = System.currentPageReference();
            string op = pr.getParameters().get('optype');
            if (op == 'schstart') {
                if (MMSMSUIPermission.isSystemAdministrator(null)) {
                    DateTime dtNow = DateTime.now().addSeconds(3);
                    String nextJobHH = String.valueOf(dtNow.hour());
                    String nextJobMM = '1';//String.valueOf(dtNow.minute());
                    String nextJobSS = String.valueOf(dtNow.second()); 
                    
                    String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
                    System.schedule('MM Job Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsScheduler());
                    mmResponse += 'New Job successfully started. [Note: if a similar process exists then you must delete the previous one, only one process must exists at a time.]';
                }
                else {
                    mmResponse += 'Error: you can not start the scheduler, only administrator role has the right';
                }
            }
            else if (op == 'resetimsch') {
                /*
                try {
                    MMBatchHelper__c bHelper = MMUtilSch.getPreviousBatchJobId();                        
                    if (bHelper != null && bHelper.PreviousJobId__c != '' && bHelper.PreviousJobId__c != null) {
                        System.abortJob(bHelper.PreviousJobId__c);
                    }
                }
                catch(Exception e) { }
                MMUtilSch.storePreviousBatchJobId('',false);
                mmResponse += 'Immediate Batch Job deleted, if found';
                */
                mmResponse += 'This option is deprecated as its being integrated with in the Schedulers';
            }
            else {
                mmResponse = 'Invalid Option';
            }
        }
        catch(Exception e) {
            mmResponse = 'Error: ' + e.getMessage();
        }
    }
}