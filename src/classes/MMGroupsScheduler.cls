global with sharing class MMGroupsScheduler implements Schedulable{
  
   global void execute(SchedulableContext SC) {
    string sContextId = null;
    MMBatchHelper__c bHelper = null;
    boolean isBatchAborted = false;
    try {
      MMSchedulerHelper__c c = MMUtilSch.getPreviousJobId();
      if (c != null && c.PreviousJobId__c != '' && c.PreviousJobId__c != null) {
          System.abortJob(c.PreviousJobId__c);
      }
    } catch(Exception e) { }
    try {
      bHelper = MMUtilSch.getPreviousBatchJobId();
      if (bHelper != null && bHelper.PreviousJobId__c != '' && bHelper.PreviousJobId__c != null && !bHelper.InProcess__c) {
          System.abortJob(bHelper.PreviousJobId__c);
          isBatchAborted = true;
      }
     }
     catch(Exception e) { }
     sContextId = SC.getTriggerId();
     sendScheduledSMSNew(sContextId, isBatchAborted, false);
   }
  
   @future(callout=true)
   public static void sendScheduledSMSNew(string sContextId, Boolean isBatchAborted, Boolean isTest){
       List<String> lastGroupIds = new List<String>();
       try {
        DateTime now = DateTime.now();
        //now = DateTime.newInstance(now.yearGMT(), now.monthGMT(), now.dayGMT(), now.hourGMT(), now.minuteGMT(), now.secondGMT());        
        
        String cmpDate = String.valueOf(now.date());
        List<MMUtilSMSObject> recipientListGroup = new List<MMUtilSMSObject>();
        
        List<List<List<String>>> selectedIds = new List<List<List<String>>>();
        boolean hasGroupSMS = true;
        boolean hasSingleSMS = true;
        
        List<MMGroupSMS__c> groups = MMUtilSch.getAvailableGroupSMS(now);
        List<MMGroupSMSJob__c> groupJobs = new List<MMGroupSMSJob__c>();
        MMGroupSMSJob__c groupJob = null;
        boolean reschedule = false;
        if(groups == null || groups.size() == 0){
            hasGroupSMS = false;
        }
                                
        Integer rcSize = 0;
        String sendStatus;    
        Integer rcIndex = 0; 
        List<Long> rcNumGroup;
        String[] pNums = new List<String>();
        List<List<List<SObject>>> contactsGroup  = new List<List<List<SObject>>>(); 
        if(hasGroupSMS){
            for (Integer i = 0; i < groups.size(); i++){                    
                lastGroupIds.add(groups[i].Id);
                groupJob = MMUtilSch.getJob(groups[i].Id);
                if (groupJob != null) {
                    selectedIds.add(new List<List<String>>());
                    List<String> groupsAllIds = (groupJob.Ids__c == null || groupJob.Ids__c == '')? new List<String>() : groupJob.Ids__c.split(',');
                    List<String> groupAfIds = new List<String>();
                    List<String> groupOpIds = new List<String>();                
                    for(String gId : groupsAllIds){
                        List<String> idDetail = gId.split('###');
                        if(idDetail[1] == 'af') groupAfIds.add(idDetail[0]);
                            else groupOpIds.add(idDetail[0]);
                    }
                    selectedIds[i].add(groupAfIds);
                    selectedIds[i].add(groupOpIds);
                    rcSize += selectedIds[i][0].size() + selectedIds[i][1].size();
                    
                    groupJob.IsScheduled__c = false;
                    groupJobs.add(groupJob);
                }
            }
            rcNumGroup = MMUtils.getReceiptNumbers(rcSize, isTest);
            
            for (Integer i = 0; i < groups.size(); i++){
                for(Integer typeIndex = 0; typeIndex < 2; typeIndex ++) {                                         
                    contactsGroup.add(new List<List<SObject>>());
                    Opportunity[] ops = new List<Opportunity>();            
                    if(typeIndex == 0){
                    
                        string query = 'SELECT Id, FirstName, LastName, Phone, HomePhone , MobilePhone, Work_Phone__c, Preferred_Phone__c, Country__c, OK_to_Text__c, OwnerId  from contact where id in (';            
                        for(integer j = 0 ; j < selectedIds[i][typeIndex].size(); j++){
                            query += (j>0)?',':'';
                            query += '\'' + selectedIds[i][typeIndex][j] + '\'';
                        }
                        query += ')';
                        contactsGroup[i].add(selectedIds[i][typeIndex].size() == 0 ? new List<Contact>() : Database.query(query));
                    } else {
                        ops = new List<Opportunity>();
                        String query = 'Select Id, Student__r.Id, Student__r.FirstName, Student__r.LastName, Student__r.Phone, Student__r.HomePhone , Student__r.MobilePhone, Student__r.Work_Phone__c, Student__r.Preferred_Phone__c, Student__r.Country__c, Student__r.OK_to_Text__c, Student__r.OwnerId from opportunity where id in (';    
                        for(integer j = 0 ; j < selectedIds[i][typeIndex].size(); j++){
                            query += (j>0)?',':'';
                            query += '\'' + selectedIds[i][typeIndex][j] + '\'';
                        }
                        query += ')';                         
                        ops = selectedIds[i][typeIndex].size() == 0 ? ops : Database.query(query);
                        contactsGroup[i].add(ops);
                    }  
                    
                    String[] extractedFields = new List<String>();
                    SObject[] tObjects;
                                
                    String query = MMSMSTemplates.getTemplateQuery(MMUtils.filterNull(groups[i].message__c), extractedFields, selectedIds[i][typeIndex], typeIndex == 0 ? 'af' : 'op');                
                   
                    if(query != null){
                        try{
                            tObjects = Database.Query(query);
                        }Catch(Exception e){
                            // In case user edits field name by hand
                            tObjects = null;
                        }
                    }
                    
                    for(integer j = 0 ; j < contactsGroup[i][typeIndex].size(); j++){
                        string key = '';
                        Contact c = (typeIndex == 0) ? (contact)contactsGroup[i][typeIndex][j] : ((opportunity)contactsGroup[i][typeIndex][j]).Student__r;
                        
                        if(c.Phone != null && c.Phone != '') {
                            key = c.Phone;                
                        } else if( c.Preferred_Phone__c != ''){
                            key = (c.Preferred_Phone__c == 'Mobile')? c.MobilePhone : ((c.Preferred_Phone__c == 'Home')? c.HomePhone : c.Work_Phone__c);
                            key = (key == null)?'None':key;
                        } else if(c.MobilePhone != null && c.MobilePhone != ''){
                            key = c.MobilePhone;
                        } else if(c.HomePhone != null && c.HomePhone != ''){
                            key = c.HomePhone;
                        } else if(c.Work_Phone__c != null && c.Work_Phone__c != ''){
                            key = c.Work_Phone__c;
                        } else {
                            key = 'None';
                        }  
    
                        String tMessage = MMSMSTemplates.getTemplateMessage(String.valueOf(contactsGroup[i][typeIndex][j].get('Id')), MMUtils.filterNull(groups[i].Header__c, groups[i].message__c, groups[i].Footer__c), 
                                            tObjects, extractedFields, typeIndex == 0 ? 'af' : 'op');                 
                        tMessage = MMUtilSch.clearMergedFields(tMessage);
                        tMessage = tMessage.replace('\r\n', '\n');
                        recipientListGroup.add(new MMUtilSMSObject((string)contactsGroup[i][typeIndex][j].get('Id'), key, rcNumGroup[rcIndex], groups[i].isTrackDelivery__c, c.country__c, tMessage, (typeIndex == 0 ? 'af' : 'op'), groups[i].TimeZone__c));         
                        pNums.add(key);
                        rcIndex++;
                    }
                }
            }  
            
        }        
        //DateTime nowSingle = DateTime.now();
        MMSMSReceipt__c[] receiptsSingle = new List<MMSMSReceipt__c>();
        try{    
            // Populating recipient list For Single SMS
            receiptsSingle = [select schPhoneNumber__c, schDateTime__c, TrackDeliveryTimeZone__c, TrackDeliveryStatus__c, TrackDeliveryDateTime__c, TaskId__c, SystemModstamp, ReceiptNumber__c, OwnerId, Name, Message__c, LastModifiedDate, LastModifiedById, IsTrackDelivery__c, IsScheduled__c, IsDeleted, IsDayLightSaving__c, Id, EntityType__c, EntityId__c, CreatedDate, CreatedById, Country__c from MMSMSReceipt__c where isScheduled__c = true and schDateTime__c < :now limit 1];
            //return String.valueOf(receipts);
        }
        Catch(Exception e){
            hasSingleSMS = false;
        }
        String retVal;
        List<Task> tasksSingle = new List<Task>();
        List<MM_SMS_Log__c> logsSingle = new List<MM_SMS_Log__c>(); 
        if(hasSingleSMS && receiptsSingle != null && receiptsSingle.size() > 0){
            
            List<MMUtilSMSObject> recipientListSingle = new List<MMUtilSMSObject>();        
            integer sizeSingle = receiptsSingle.size();
            User logUser = null;
    
    
            for(integer i = 0; i < sizeSingle; i++){
                MMSMSReceipt__c rc = receiptsSingle[i];
                recipientListSingle.add(new MMUtilSMSObject(rc.EntityId__c, rc.schPhoneNumber__c, rc.ReceiptNumber__c.longValue(), rc.isTrackDelivery__c , rc.Country__c, rc.Message__c, rc.OwnerId));            
            }
                        
            for(integer i = 0; i < sizeSingle; i++){
                MMSMSReceipt__c rc = receiptsSingle[i];
                logUser = [select Id, UserType from User where Id = :rc.OwnerId];
                Task t = [select MMSMSDeliveryStatus__c from Task where Id = : rc.TaskId__c];
                t.MMSMSDeliveryStatus__c = (rc.isTrackDelivery__c)? 'SMS Pending' : 'Not Required';
                tasksSingle.add(t);
                receiptsSingle[i].isScheduled__c = false;
    
                MM_SMS_Log__c log = MMUtilLog.createSMSLog(logUser.Id, logUser.UserType, rc.EntityId__c, rc.EntityType__c, rc.schPhoneNumber__c,
                            rc.trackDeliveryTimeZone__c, false, null, 'Outbound', 
                           rc.Message__c, String.valueOf(rc.ReceiptNumber__c), rc.TaskId__c);
    
                logsSingle.add(log);
            }
            if(!isTest)
                MMUtilSoap.sendSMS(recipientListSingle, null, null);
            
            update tasksSingle;
            update receiptsSingle;
            insert logsSingle;
            
            if (!isTest) {
                MMUtilSch.storePreviousJobId(sContextId);
                DateTime dtNow = DateTime.now().addSeconds(2);
                String nextJobHH = String.valueOf(dtNow.hour());
                String nextJobMM = String.valueOf(dtNow.minute());
                String nextJobSS = String.valueOf(dtNow.second()); 
                
                String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
                System.schedule('MM Job Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsScheduler());
                
                return;
            }
        }
        
        if(hasGroupSMS){
            sendStatus = (isTest)? 'Successfull' : MMUtilSoap.sendSMS(recipientListGroup, null, UserInfo.getUserId());     
            List<Task> tasksGroup = new List<Task>();
            MMUtilSch.logMessage('Records: ' + recipientListGroup.size());

            if (isBatchAborted) MMUtilSch.storePreviousBatchJobId('', false);
            update groupJobs;
            
            for(MMUtilSMSObject smsObj : recipientListGroup) {
                Task t = MMUtils.createTask(smsObj.getEntityId(), smsObj.getEntityType(),
                                            smsObj.getMessage(), sendStatus, 
                                            smsObj.getIsTrack(), false);
                tasksGroup.add(t); 
            }
            insert tasksGroup;
            rcIndex = 0;
            
            List<MMSMSReceipt__C> receiptsGroup = new List<MMSMSReceipt__c>();
            MM_SMS_Log__c[] logsGroup = new List<MM_SMS_Log__c>();
            
            for(MMUtilSMSObject smsObj : recipientListGroup) {
                Task t = tasksGroup[rcIndex];        
                MMSMSReceipt__c rc = MMUtils.createSMSReceipt(smsObj.getEntityId(), smsObj.getEntityType(), rcNumGroup[rcIndex], false, 
                                                              smsObj.getIsTrack(), String.valueOf(t.Id), null, '', 
                                                              smsObj.getTimeZone(),
                                                //groups[i].isDaylightSaving__c
                                                true , 
                                                smsObj.getMessage(),
                                                null, pNums[rcIndex], smsObj.getCountry());
                receiptsGroup.add(rc);
            
                MM_SMS_Log__c log = MMUtilLog.createSMSLog(UserInfo.getUserId(), UserInfo.getUserType(), smsObj.getEntityId(), 
                                                           smsObj.getEntityType(), pNums[rcIndex],
                                                           smsObj.getTimeZone(), 
                                                           //groups[i].isDaylightSaving__c
                                                           true, null, 'Outbound', 
                                                           smsObj.getMessage(),
                                                           String.valueOf(rcNumGroup[rcIndex]), t.Id);
            
                logsGroup.add(log);
                rcIndex ++;
            }
            for (integer i=0; i < groups.size(); i++) {
                if (MMUtilSch.getJob(groups[i].Id) == null) {
                    groups[i].isScheduled__c = false;
                    groups[i].StartDate__c = '';
                    groups[i].IsImmediate__c = false;
                    groups[i].startTime__c = null;
                    groups[i].InProcess__c = false;
                }
                else {
                    groups[i].InProcess__c = true;
                }
            }
    
            insert receiptsGroup;
            insert logsGroup;
            update groups;
        }
        
        //checking for available jobs
        groups = MMUtilSch.getAvailableGroupSMS(now);
        reschedule = (groups != null && groups.size() > 0);

        //Storing jobId
        if (reschedule) {
            MMUtilSch.storePreviousJobId(sContextId);
            DateTime dtNow = DateTime.now().addSeconds(10);
            String nextJobHH = String.valueOf(dtNow.hour());
            String nextJobMM = String.valueOf(dtNow.minute());
            String nextJobSS = String.valueOf(dtNow.second()); 
            
            String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
            System.schedule('MM Job Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsScheduler());
        }
        else {
            MMUtilSch.storePreviousJobId('');
        }
        
        // Single SMS 
        /*    
        MMUtilSch.logMessage('from scheduler \n' +
                         + 'Single Size = ' + (hasGroupSMS?receiptsSingle.size():0) 
                         + '\nGroups Size =' + (hasSingleSMS?groups.size():0) 
                         + '\n' + MMUtils.getLimitTrace());
        */
        
       }
       catch(Exception e) {
           MMUtilSch.logMessage('Line:' + e.getLineNumber() + ':' + e.getStackTraceString() + ', ' + e.getMessage());

           List<String> grpIds = new List<String>();
           List<String> uIds = new List<String>();
           DateTime now = DateTime.now();
           now = DateTime.newInstance(now.yearGMT(), now.monthGMT(), now.dayGMT(), now.hourGMT(), now.minuteGMT(), now.secondGMT());
           if (lastGroupIds != null && lastGroupIds.size() > 0) {
                for (integer i=0;i<lastGroupIds.size();i++) {
                   List<MMGroupSMSJob__c> jobs = null;
                   MMGroupSMS__c grp = [Select m.isScheduled__c, m.ids__c, m.TimeZone__c, m.StartTime__c, m.StartDate__c, 
                                            m.SelectedIds__c, m.Message__c, m.IsTrackDelivery__c, m.Header__c, m.Footer__c,
                                            m.EntityType__c, m.InProcess__c, m.IsImmediate__c, m.ownerId
                                            From MMGroupSMS__c m where m.Id = :lastGroupIds[i] limit 1];
                   if (grp != null) {
                       grpIds.add(grp.Id + ' Scheduled for: ' + grp.StartDate__c + ' ' + grp.StartTime__c + '<br/>');
                       uIds.add(grp.ownerId);
                       grp.isScheduled__c = false;
                       grp.StartDate__c = '';
                       grp.IsImmediate__c = false;
                       grp.startTime__c = null;
                       grp.InProcess__c = false;
                       update grp;
                       
                       jobs = MMUtilSch.getJobs(grp.Id);
                       if (jobs != null && jobs.size() > 0) {
                           for (integer x=0;x<jobs.size();x++) {
                               jobs[x].IsScheduled__c = false;
                           }
                           update jobs;
                       }
                   }
               }
           }
                              
            List<MMGroupSMS__c> groups = MMUtilSch.getAvailableGroupSMS(now);
            boolean reschedule = (groups != null && groups.size() > 0);
    
            //Storing jobId
            if (reschedule) {
                MMUtilSch.storePreviousJobId(sContextId);
                DateTime dtNow = DateTime.now().addSeconds(10);
                String nextJobHH = String.valueOf(dtNow.hour());
                String nextJobMM = String.valueOf(dtNow.minute());
                String nextJobSS = String.valueOf(dtNow.second()); 
                
                String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
                System.schedule('MM Job Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsScheduler());
            }
            else {
                MMUtilSch.storePreviousJobId('');
            }
           
           if (grpIds.size() > 0) {
               for (integer i=0;i<grpIds.size();i++) {
                   Id defaultId = null;
                   Id mailId = uIds[i];
                   User usr = [SELECT FirstName, LastName, Email FROM User where Id = :mailId]; 
                   MMUtils.sendSingleEmail(usr.email, usr.FirstName + ' ' + usr.LastName, 'Group SMS Sending Failed', 
                       ('<br/>Scheduled group message failed: <br/><br/> ' + grpIds[i] + 
                       '<br/>Please check the contacts/opportunities phone numbers, selected in the group..'),
                       mailId);
                    MMUtils.sendSingleEmail(isTest ? 'fmoid@folio3.com' : MMUtilConstants.getDefaultEmail(), isTest ? 'fmoid@folio3.com' : MMUtilConstants.getDefaultName(),
                                       'Group SMS Sending Failed', 
                               ('<br/>Your group message with id: ' + grpIds[i] + ' failed to process!<br/><br/>' +
                               'Please check the contacts/opportunities phone numbers, selected in the group..'),
                               defaultId);
               }
           }
       }
   }
}