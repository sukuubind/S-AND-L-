public class MMUtilSch {
    public static void logMessage(string msg) {
        MMDebug__c dbg = new MMDebug__c();
        dbg.Message__c = msg;
        insert dbg;
    }
    public static string clearMergedFields(string str) {
        integer index1 = -1;
        integer index2 = -1;
        integer index3 = -1;
        string str1 = '';
        string str2 = '';
        do {
            index1 = str.indexOf('[!');
            index2 = str.indexOf('.');
            index3 = str.indexOf(']');
            if (index1 != -1 && index2 != -1 && index3 != -1 && index3 > index2 && index2 > index1) {
                str = str.substring(0,index1) + str.substring(index3 + 1);
            }
            else {
                break;
            }
        }
        while(true);
        return str;
    }

    public static MMGroupSMSJob__c insertJob(Id groupId, List<string> ids, boolean isSch) {
        MMGroupSMSJob__c job = new MMGroupSMSJob__c();
        integer maxJobIndex = getNextJobIndex(groupId);
        
        job.JobIndex__c = maxJobIndex + 1;
        job.MMGroupSMS__c = groupId;
        job.Ids__c = listToString(ids, ',');
        job.IsScheduled__c = isSch;
        job.InProcess__c = false;
        insert job;
        
        return job;
    }
    public static MMGroupSMSJob__c insertJob(Id groupId, List<string> ids, boolean isSch, integer index) {
        MMGroupSMSJob__c job = new MMGroupSMSJob__c();
        
        job.JobIndex__c = index;
        job.MMGroupSMS__c = groupId;
        job.Ids__c = listToString(ids, ',');
        job.IsScheduled__c = isSch;
        job.InProcess__c = false;
        
        return job;
    }
    public static void deleteJobs(Id groupId) {
        List<MMGroupSMSJob__c> jobs = [select Id from MMGroupSMSJob__c where MMGroupSMS__c = :groupId];
        delete jobs;    
    }
    public static List<MMGroupSMSJob__c> getJobs(Id groupId) {
        List<MMGroupSMSJob__c> jobs = [select Id, JobIndex__c, MMGroupSMS__c, Ids__c, IsScheduled__c, InProcess__c
                                     from MMGroupSMSJob__c where MMGroupSMS__c = :groupId order by JobIndex__c];
        return jobs;
    }
    public static MMGroupSMSJob__c getJobById(Id jid) {
        try {
            MMGroupSMSJob__c job = [select Id, JobIndex__c, MMGroupSMS__c, Ids__c, IsScheduled__c, InProcess__c
                                     from MMGroupSMSJob__c where Id = :jid];
            return job;
        }
        catch(Exception e) {
            return null;
        }
    }
    public static MMGroupSMSJob__c getJob(Id groupId) {
        MMGroupSMSJob__c job = null;
        List<MMGroupSMSJob__c> jobs = getJobs(groupId);
        for(MMGroupSMSJob__c j : jobs) {
            if (j.IsScheduled__c && !j.InProcess__c) {
                job = j;
                break;
            }
        }
        return job;
    }
    public static boolean isAnyJobInProcess(Id groupId) {
        MMGroupSMSJob__c job = null;
        List<MMGroupSMSJob__c> jobs = getJobs(groupId);
        for(MMGroupSMSJob__c j : jobs) {
            if (j.InProcess__c) {
                return true;
            }
        }
        return false;
    }
    public static boolean setJobInProcess(Id jobId, Boolean isTest) {
        if(isTest){
            return true;
        }
        long receiptNo = 0;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(MMUtilConstants.getPublicUrl() + '/mmutilcommon?rq=setjobinprocess&jid='+ jobId);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res != null && res.getBody() != null && res.getBody().indexOf('OK') >= 0) {
                return true;
            }
            else {
                return false;
            }
        }
        catch(Exception exp) {
            MMUtilSch.logMessage('Line:' + exp.getLineNumber() + ':' + exp.getMessage());   
        }
        return false;
    }
    public static MMGroupSMSJob__c getJob(Id groupId, integer jobIndex) {
        try {
            MMGroupSMSJob__c job = [select Id, JobIndex__c, MMGroupSMS__c, Ids__c, InProcess__c
                                 from MMGroupSMSJob__c
                                 where MMGroupSMS__c = :groupId and JobIndex__c = :jobIndex limit 1];
            return job;
        }
        catch(QueryException e) {
            return null;
        }
    }
    public static integer getNextJobIndex(Id groupId) {
        List<AggregateResult> aggr = [select MAX(JobIndex__c) mji from MMGroupSMSJob__c where MMGroupSMS__c = :groupId];
        integer maxJobIndex = 0;
        if (aggr != null && aggr.size() > 0) {
            maxJobIndex = Integer.valueOf(aggr[0].get('mji'));
            if (maxJobIndex == null) {
                maxJobIndex = 0;
            }
        }
        return maxJobIndex;
    }
    public static string listToString(List<string> strs, string sep) {
        string str = '';
        
        if (strs != null && strs.size() > 0) {
            for(string s : strs) {
                if (str.length() > 0) str = str + sep;
                str = str + s;
            }
        }
        
        return str;
    } 
    public static void storePreviousJobId(string jobId) {
        MMSchedulerHelper__c helper = null;
        try {
            helper = [select Id, PreviousJobId__c from MMSchedulerHelper__c limit 1];
        }
        catch(QueryException e) {
            helper = new MMSchedulerHelper__c();
        }
        helper.PreviousJobId__c = jobId;
        upsert helper;
    }
    public static MMSchedulerHelper__c getPreviousJobId() {
        MMSchedulerHelper__c helper = null;
        try {
            helper = [select Id, PreviousJobId__c from MMSchedulerHelper__c limit 1];
            return helper;
        }
        catch(QueryException e) {
            return null;
        }
    }
    public static void storePreviousBatchJobId(string jobId, boolean inProcess) {
        MMBatchHelper__c helper = null;
        try {
            helper = [select Id, PreviousJobId__c, InProcess__c from MMBatchHelper__c limit 1];
        }
        catch(QueryException e) {
            helper = new MMBatchHelper__c ();
        }
        if (jobId != null) helper.PreviousJobId__c = jobId;
        helper.InProcess__c = inProcess;
        upsert helper;
    }
    public static MMBatchHelper__c getPreviousBatchJobId() {
        MMBatchHelper__c helper = null;
        try {
            helper = [select Id, PreviousJobId__c, InProcess__c from MMBatchHelper__c limit 1];
            return helper;
        }
        catch(QueryException e) {
            return null;
        }
    }
    public static List<MMGroupSMS__c> getAvailableGroupSMS(DateTime dt) {
        List<MMGroupSMS__c> groups = new List<MMGroupSMS__c>();
        List<MMGroupSMS__c> groups1 = null;
        integer cnt = 0;
        try {
            groups1 = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c, 
                        m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                        m.EntityType__c, m.InProcess__c, m.IsImmediate__c, m.SMSBatchSize__c, m.isDaylightSaving__c
                                    From MMGroupSMS__c m
                                    where isScheduled__c = true and InProcess__c = true and
                                    IsImmediate__c = false and
                                    (m.schDateTime__c < :dt)];
            if (groups1 == null || groups1.size() == 0) {
                try {
                    groups1 = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c,
                                 m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                                 m.EntityType__c, m.InProcess__c, m.IsImmediate__c, m.SMSBatchSize__c, m.isDaylightSaving__c 
                                        From MMGroupSMS__c m 
                                        where isScheduled__c = true and 
                                        IsImmediate__c = false and
                                        (m.schDateTime__c < :dt)];
                }
                catch(QueryException e1) {
                    groups1 = null;
                }
            }
        }
        catch(QueryException e) {
            try {
                groups1 = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c,
                             m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                             m.EntityType__c, m.InProcess__c, m.IsImmediate__c, m.SMSBatchSize__c , m.isDaylightSaving__c 
                                    From MMGroupSMS__c m 
                                    where isScheduled__c = true and 
                                    IsImmediate__c = false and
                                    (m.schDateTime__c < :dt)];
            }
            catch(QueryException e1) {
                groups1 = null;
            }
        }
        if (groups1 != null && groups1.size() > 0) {
            for(MMGroupSMS__c grp : groups1) {
                cnt += (grp.SMSBatchSize__c != null ? Integer.valueOf(grp.SMSBatchSize__c)  : 0);
                if (cnt <= MMUtilConstants.batchSize) {
                    groups.add(grp);
                }
                else {
                    break;
                }
            }
        }
        return groups;
    }
    public static MMGroupSMS__c getGroupById(string gid) {
        MMGroupSMS__c grp = null;
        try {
            grp = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c, 
                        m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                        m.EntityType__c, m.InProcess__c, m.IsImmediate__c
                                    From MMGroupSMS__c m 
                                    where Id = :gid limit 1];
            return grp;
        }
        catch(Exception e) {
            return null;
        }
    }
    public static List<MMGroupSMS__c> getAvailableGroupImmediateSMS(DateTime dt) {
        List<MMGroupSMS__c> groups = new List<MMGroupSMS__c>();
        MMGroupSMS__c grp = null;
        try {
            grp = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c, 
                        m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                        m.EntityType__c, m.InProcess__c, m.IsImmediate__c
                                    From MMGroupSMS__c m 
                                    where isScheduled__c = false and InProcess__c = true and
                                    IsImmediate__c = true limit 1];
        }
        catch(QueryException e) {
            try {
                grp = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c,
                             m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                             m.EntityType__c, m.InProcess__c, m.IsImmediate__c
                                    From MMGroupSMS__c m 
                                    where isScheduled__c = false and 
                                    IsImmediate__c = true limit 1];
            }
            catch(QueryException e1) {
                grp = null;
            }
        }
        if (grp != null) groups.add(grp);
        return groups;
    }
    
    public static String getSelectedIdsforGroup(String groupId){
        String idString = '';
        List<MMGroupSMSJob__c> jobs = getJobs(groupId);
        for(MMGroupSMSJob__c job : jobs){
            idString += job.Ids__c + ',';
        }
        return idString;
    }
}