public class MMUtilBatchJob {
    public static MMJobRecordCount__c upsertBatchCount (long recordCount) {
        MMJobRecordCount__c rec = null;
        try {
            rec = [select JobUser__c, RecordCount__c, JobInProcess__c from MMJobRecordCount__c where JobUser__c = :UserInfo.getUserId() limit 1];
            if (rec == null) {
                rec = new MMJobRecordCount__c();
                rec.JobUser__c = UserInfo.getUserId();
                rec.JobInProcess__c = true;
                rec.RecordCount__c = 0;
            }
        }
        catch(Exception exp) {
            rec = new MMJobRecordCount__c();
            rec.JobUser__c = UserInfo.getUserId();
            rec.JobInProcess__c = true;
            rec.RecordCount__c = 0;
        }
        if (rec.JobInProcess__c) {
            rec.RecordCount__c = rec.RecordCount__c + recordCount;
        }
        else {
            rec.RecordCount__c = recordCount;
            rec.JobInProcess__c = true;
        }
        upsert rec;
        return rec;
    }
    public static void stopBatchCount() {
        MMJobRecordCount__c rec = null;
        try {
            rec = [select JobUser__c, RecordCount__c, JobInProcess__c from MMJobRecordCount__c where JobUser__c = :UserInfo.getUserId() limit 1];
            if (rec != null) {
                rec.JobInProcess__c = false;
                update rec;
            }
        }
        catch(Exception exp) {
            
        }
    }
    public static void resetBatchCount() {
        MMJobRecordCount__c rec = null;
        try {
            rec = [select JobUser__c, RecordCount__c, JobInProcess__c from MMJobRecordCount__c where JobUser__c = :UserInfo.getUserId() limit 1];
            if (rec != null) {
                rec.RecordCount__c = 0;
                update rec;
            }
        }
        catch(Exception exp) {
            
        }
    }
    public static MMJobRecordCount__c getBatchCount() {
        MMJobRecordCount__c rec = null;
        try {
            rec = [select JobUser__c, RecordCount__c, JobInProcess__c from MMJobRecordCount__c where JobUser__c = :UserInfo.getUserId() limit 1];
        }
        catch(Exception exp) {
        }
        return rec;
    }
    public static boolean deleteBatchCount() {
        boolean status = false;
        MMJobRecordCount__c rec = null;
        try {
            rec = [select JobUser__c, RecordCount__c, JobInProcess__c from MMJobRecordCount__c where JobUser__c = :UserInfo.getUserId() limit 1];
            delete rec;
            status = true;
        }
        catch(Exception exp) {
        }
        return status;
    }
}