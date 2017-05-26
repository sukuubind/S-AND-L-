public without sharing class ProspectLogHandler {
    public static Map<Id, Boolean> prospectSupportedAccount = new Map<Id, Boolean>();
     public static Map<Id, Id> accountidToDOAQueueId = new Map<id, Id>();
    public class DistributionHours{
        //A wrapper class to store all the distribution metrics for a given account
        public Id AccountId;
        public Id TeamId;
        public Integer Distribution_Start_Hour;
        public Integer Distribution_Start_Minutes;
        public Integer Distribution_End_Hour;
        public Integer Distribution_End_Minutes;
        public Decimal EscalationMinutes;
        public DistributionHours(Id AccountId, Id TeamId, Integer StartHour, Integer StartMinutes, Integer EndHour, Integer EndMinutes, Decimal EscalationMinutes){
            this.AccountId = AccountId;
            this.TeamId = Teamid;
            this.Distribution_Start_Hour = StartHour;
            this.Distribution_Start_Minutes = StartMinutes;
            this.Distribution_End_Hour = EndHour;
            this.Distribution_End_Minutes = EndMinutes;
            this.EscalationMinutes = EscalationMinutes;
        }
    }
    public Map<Id, ProspectLogHandler.DistributionHours> buildDistributionHours(){
        //Query the Account record and build a map of account id to its associated distribution metrics.
        Map<Id, ProspectLogHandler.DistributionHours> returnMap = new Map<Id, ProspectLogHandler.DistributionHours>();
        List<String> supportedAccountRecordTypes = new List<String>();
        supportedAccountRecordTypes.add(ProspectConstants.SRP_ACCOUNT_RECORDTYPE);
        supportedAccountRecordTypes.add(ProspectConstants.SRM_ACCOUNT_RECORDTYPE);
        List<Account> accountList = [Select Id, PRO_Distribution_End_Hours__c, PRO_Distribution_Hours_End_Minutes__c, 
                                            PRO_Distribution_Hours_Escalation_Minute__c, PRO_Distribution_Hours_Start_Minutes__c,
                                            PRO_Distribution_Start_Hours__c, PROspect_Enabled__c from Account
                                            Where Account.RecordType.DeveloperName IN :supportedAccountRecordTypes];
        for(Account thisAccount : accountList){
            try{
                prospectSupportedAccount.put(thisAccount.Id, thisAccount.PROspect_Enabled__c);
                Integer startHour = Integer.valueOf(thisAccount.PRO_Distribution_Start_Hours__c);
                Integer startMinute = Integer.valueOf(thisAccount.PRO_Distribution_Hours_Start_Minutes__c);
                Integer endHour = Integer.valueOf(thisAccount.PRO_Distribution_End_Hours__c);
                Integer endMinute = Integer.valueOf(thisAccount.PRO_Distribution_Hours_End_Minutes__c);
                Decimal escalationMinutes = thisAccount.PRO_Distribution_Hours_Escalation_Minute__c;
                ProspectLogHandler.DistributionHours thisDist = new ProspectLogHandler.DistributionHours(thisAccount.Id, null,
                                                                                                            startHour, startMinute,
                                                                                                            endHour, endMinute,
                                                                                                            escalationMinutes);
                returnMap.put(thisAccount.Id, thisDist);
            }catch(Exception e){
                System.Debug(e);
                continue;
            }
        }
        return returnMap;
    }
    public DateTime findNextRunTime(ProspectLogHandler.DistributionHours thisDist, DateTime currentTimeStamp  ){
        //Find the escalation minutes for the account.
        //find the distribution hours start time and distribution hours end time for the account
        //Find the current time stamp
        //Find the difference between the distribution hours end time and the current time stamp
        //If the current time stamp is after the distribution hours end time, next run time is tomorrow's start time for the opportuntiy + escalation minutes
        //if current time stamp is inside the distribution hours end time,
              //Scenario #1: if the difference in distribution hours end time and current time stamp is less than the escalation minutes, next run tie is tomorrow's start time + difference in the escalation minutes from yesterday.
              //Scenario #2: if the difference in distribution hours end time and current time stamp is greated than the escalation minutes, next run time is current time stamp + escalation mintues
        Datetime nextRunTime = null;
       System.Debug('thisDist -- '+thisDist);
       if(thisDist != null){
        Decimal DistributionMinutes = ((thisDist != null && thisDist.EscalationMinutes != null) ? thisDist.EscalationMinutes : 0);
        Date today_Date = Date.today();
        Time startTime = Time.newInstance(thisDist.Distribution_Start_Hour, thisDist.Distribution_Start_Minutes, 0, 0);
        Time endTime = Time.newInstance(thisDist.Distribution_End_Hour, thisDist.Distribution_End_Minutes, 0, 0);
        Time nowTime = Time.newInstance(currentTimeStamp.hour(), currentTimeStamp.minute(), 0, 0);
        DateTime today_endTime = DateTime.newInstance(today_Date, endTime);
        DateTime today_startTime = DateTime.newInstance(today_Date, startTime);
        Date tomorrow_Date = Date.today().addDays(1);
        Date yesterday_Date = Date.today().addDays(-1);
        DateTime yesterday_endTime = DateTime.newInstance(yesterday_Date, endTime);
        
        Long milliseconds_difference = today_endTime.getTime()-currentTimeStamp.getTime();
        Long seconds_difference = milliseconds_difference / 1000;
        Long minutes_difference = seconds_difference / 60;
        System.Debug('currentTimeStamp -- '+currentTimeStamp);
        System.Debug('today_endTime -- '+today_endTime);
        System.Debug('minutes_difference -- '+minutes_difference);
        System.Debug('DistributionMinutes -- '+DistributionMinutes);
        System.Debug('minutes_difference <= DistributionMinutes -- '+Boolean.valueOf(minutes_difference <= DistributionMinutes));
        if(currentTimeStamp > today_endTime){
            nextRunTime = DateTime.newInstance(tomorrow_Date, startTime.addMinutes(Integer.valueOf(DistributionMinutes)));
        }else{
            if(minutes_difference <= DistributionMinutes){
                System.Debug('Adding difference to tomorrows date');
                Integer difference = Integer.valueOf(DistributionMinutes - minutes_difference);
                nextRunTime = DateTime.newInstance(tomorrow_Date, startTime.addMinutes(difference));
            }else{
                System.Debug('Adding distribution minutes to todays date');
                if(currentTimeStamp < today_startTime){
                    nextRunTime = DateTime.newInstance(today_Date, startTime.addMinutes(Integer.valueOf(DistributionMinutes)));
                }else{
                    nextRunTime = DateTime.newInstance(today_Date, nowTime.addMinutes(Integer.valueof(DistributionMinutes)));
                }
            }
        }
       }else{
        System.Debug('thisDist is NULL');
        nextRunTime = currentTimeStamp;
       }
       System.Debug('nextRunTime -- '+nextRunTime);
        return nextRunTime;
    }
    public String findNewStatus(String oldStatus, ProspectLogHandler.DistributionHours thisDist){
        //If old status is Received, and there is no distribution hours set on the account record, we can close the opportunity after the first assignment.
        if(oldStatus == ProspectConstants.LOG_STATUS_RECVD && thisDist == null){
            return ProspectConstants.LOG_STATUS_CLOSD;
        }
        //If old status is Received, and there is distribution hours set on the account record, the new status has to be processed. This will let the lead router
        //know that this opportunity has to be picked the next time for processing.
        else if(oldStatus == ProspectConstants.LOG_STATUS_RECVD && thisDist != null){
            return ProspectConstants.LOG_STATUS_PROCD;
        }
        //If old status is Processed or Escalated, the new status should be Escalated. This will let the lead router
        //know that this opportunity has to be picked the next time for processing.
        else if(oldStatus == ProspectConstants.LOG_STATUS_PROCD || oldStatus == ProspectConstants.LOG_STATUS_ESCTD){
            return ProspectConstants.LOG_STATUS_ESCTD;
        }
        return '';
    }
    public Map<Id, ProspectLogHandler.DistributionHours> accountIdToDistrbutionHourSetting = null;
    public ProspectLogHandler(){
        //In the constructor, build the distribution hours for each of the account
        accountIdToDistrbutionHourSetting = new Map<Id, ProspectLogHandler.DistributionHours>();
        accountIdToDistrbutionHourSetting = buildDistributionHours();
        List<PROspect_Queues__c> queueIds = PROspect_Queues__c.getall().values();
        for(PROspect_Queues__c thisQueue : queueIds){ 
            accountidToDOAQueueId.put(thisQueue.Name, thisQueue.QueueId__c);
        }
    }
    public void createLogRecords_case(List<Case> caseList, List<PRO_Log__c> proLogList, Map<id, id> caseIdIdTomemberId, boolean escalatedOnCase){ 
    	Set<String> supportedRecordTypes = new Set<String>(); 
	    Schema.DescribeSObjectResult d = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
	   
	    Schema.RecordTypeInfo rtByName =  rtMapByName.get('SRP Help');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
		
		rtByName =  rtMapByName.get('SRP Customer');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
	    
	    
	    
	   
	    
        //Create log records. Handled differently for when opportunity list is populated. caseList will contain value when
        // a new opportunity is created and the trigger on the opportunity object invokes this method. The values for the
        // log object will be populated by the values on the incoming opportunity. The prologlist will be null this time.
        List<PRO_Log__c> prologListToInsert = new List<PRO_Log__c>();
        List<PRO_Log__c> prologListToUpdate = new List<PRO_Log__c>();
        if(caseList != null && caseList.size() > 0){
            for(Case thisC : caseList){
            	
            	
				String recordTypeId = thisC.RecordTypeId;
            	if(!supportedRecordTypes.contains(recordTypeId)){
	    			continue;
	    		} 
            	
            	
            	
                /*ProspectLogHandler.DistributionHours thisDist = accountIdToDistrbutionHourSetting.get(thisC.Accountid);
                Datetime currentTimeStamp = Datetime.newInstance(Date.today(), Datetime.now().time());*/
                PRO_Log__c log = new PRO_Log__c();
                log.Process_This_Log__c = true;
                //log.Assigned_Owner__c = thisC.OwnerId;
                log.Account__c = thisC.AccountId;
                
                //DateTime nextRunTime = findNextRunTime(thisDist, currentTimeStamp);
                Datetime nextRunTime = Datetime.newInstance(System.now().date(), System.now().time());
                log.Next_Run_Time__c = nextRunTime;
                log.Case__c = thisC.Id;
                log.Regular_Not_Escalated__c = true;
                
                if(escalatedOnCase == false){
                    log.Status__c = ProspectConstants.LOG_STATUS_RECVD;
                }
                if(escalatedOnCase == true){
                     log.Status__c = ProspectConstants.LOG_STATUS_ESCTD;
                }
                prologListToInsert.add(log);
            }
        }
        //Prologlist will have value when the lead router picks up the opportunity for rotation and assigns to an owner.
        // The prolog list passed to the method is the old log record. based on the old log record, the new log record
        //is created. The same information as was in the old log record will be used this time except for the status will be
        //different on the new log record based on the operation that happens on the opportuntiy. The caseList will be null when prolog list
        // contains value.
        if(proLogList != null && proLogList.size() > 0){
 
            
            Map<Id, Team_Member__c> teamMembermap = new Map<Id, Team_Member__c>([Select Id, Which_Team__c, Which_Team__r.ESC_Exempt__c, Which_Team__r.Team_Account__r.ESC_Exempt__c from Team_Member__c where Id in :caseIdIdTomemberId.values()]);
            
                     
            for(PRO_Log__c thisLog : proLogList){
                ProspectLogHandler.DistributionHours thisDist = accountIdToDistrbutionHourSetting.get(thisLog.Account__c);
                Datetime currentTimeStamp = Datetime.newInstance(Date.today(), Datetime.now().time());
                
                DateTime nextRunTime = findNextRunTime(thisDist, currentTimeStamp);
                
                PRO_Log__c log = new PRO_Log__c();
                if(caseIdIdTomemberId != null && caseIdIdTomemberId.containsKey(thisLog.Opportunity__c)){
                    log.Team_Member__c = caseIdIdTomemberId.get(thisLog.Opportunity__c);
                }else{
                    continue;
                }
                Team_Member__c thisTeamMember = teamMembermap.get(caseIdIdTomemberId.get(thisLog.Opportunity__c));
                boolean escExempt = false;
                if(thisTeamMember != null){
                    if(thisTeamMember.Which_Team__r.ESC_Exempt__c || thisTeamMember.Which_Team__r.Team_Account__r.ESC_Exempt__c){
                        escExempt = true;
                    }
                }
                log.OwnerId = (accountidToDOAQueueId.get(thisLog.Account__c) != null ? accountidToDOAQueueId.get(thisLog.Account__c) : UserInfo.getUserId());
                log.Previous_Pro_Log__c = thisLog.Id;
                log.Next_Run_Time__c = nextRunTime;
                log.Case__c = thisLog.Case__c;
                log.PRO_Team__c = thisTeamMember.Which_Team__c;
                String newStatus = findNewStatus(thisLog.Status__c, thisDist);
                log.Status__c = newStatus;
               
                if(escExempt == true){
                    log.Status__c = ProspectConstants.LOG_STATUS_CLOSD;
                     log.Process_This_Log__c = false;
                }
                if(newStatus == ProspectConstants.LOG_STATUS_ESCTD || newStatus == ProspectConstants.LOG_STATUS_PROCD){
                    if(thisDist != null){
                        //Distribution setting without null is a true scenarion of user missing to take action and escalation.
                        //we do not want to process the log if there is no distribution setting on the account record.
                        // if the new status is escalated and the distribution setting is null, that would mean, some one
                        // changed the owner of opportunity to PROspect Engine user and hence it was escalated.
                        // If process this log set to true in such scenarios, the same opportunity will get reassigned again and again
                        // after every one minute interval which is not desirable.
                        log.Regular_Not_Escalated__c = false;
                         log.Process_This_Log__c = true;
                    }
                }
                prologListToInsert.add(log);
                thisLog.Process_This_Log__c = false;
                prologListToUpdate.add(thisLog);
            }
        }
        if(prologListToInsert != null && prologListToInsert.size() > 0){
            insert prologListToInsert;
            System.Debug('prologListToInsert - '+prologListToInsert);
        }
        if(prologListToUpdate != null && prologListToUpdate.size() > 0){
            update prologListToUpdate;
        }
    
    }
    
    
    
    public void createLogRecords(List<Opportunity> oppList, List<PRO_Log__c> proLogList, Map<id, Id> opptyIdTomemberId, boolean escalatedOnOppty){
        //Create log records. Handled differently for when opportunity list is populated. Opplist will contain value when
        // a new opportunity is created and the trigger on the opportunity object invokes this method. The values for the
        // log object will be populated by the values on the incoming opportunity. The prologlist will be null this time.
        List<PRO_Log__c> prologListToInsert = new List<PRO_Log__c>();
        List<PRO_Log__c> prologListToUpdate = new List<PRO_Log__c>();
        if(oppList != null && oppList.size() > 0){
            for(Opportunity opp : oppList){
                /*ProspectLogHandler.DistributionHours thisDist = accountIdToDistrbutionHourSetting.get(opp.Accountid);
                Datetime currentTimeStamp = Datetime.newInstance(Date.today(), Datetime.now().time());*/
                PRO_Log__c log = new PRO_Log__c();
                log.Process_This_Log__c = true;
                //log.Assigned_Owner__c = opp.OwnerId;
                log.Account__c = opp.AccountId;
                log.Campaign__c = opp.CampaignId;
                if(opp.Student__c != null){
                    log.Contact__c = opp.Student__c;
                }else if(opp.DeltakSRP__Student__c != null){
                    log.Contact__c = opp.DeltakSRP__Student__c;
                }
                //DateTime nextRunTime = findNextRunTime(thisDist, currentTimeStamp);
                Datetime nextRunTime = Datetime.newInstance(System.now().date(), System.now().time());
                log.Next_Run_Time__c = nextRunTime;
                log.Opportunity__c = opp.Id;
                log.Regular_Not_Escalated__c = true;
                if(opp.Program__c != null){
                    log.SRM_Program__c = opp.Program__c;
                }
                if(opp.Specialization__c != null){
                    log.SRM_Specialization__c = opp.Specialization__c;
                }
                if(opp.Academic_Start_Date__c != null){
                    log.SRM_Term__c = opp.Academic_Start_Date__c;
                }
                if(opp.DeltakSRP__Academic_Program__c != null){
                    log.SRP_Program__c = opp.DeltakSRP__Academic_Program__c;
                }
                if(opp.DeltakSRP__Academic_Specialization__c  != null){
                    log.SRP_Specialization__c = opp.DeltakSRP__Academic_Specialization__c;
                }
                if(opp.DeltakSRP__Academic_Start_Date__c != null){
                    log.SRP_Term__c = opp.DeltakSRP__Academic_Start_Date__c;
                }
                if(escalatedOnOppty == false){
                    log.Status__c = ProspectConstants.LOG_STATUS_RECVD;
                }
                if(escalatedOnOppty == true){
                     log.Status__c = ProspectConstants.LOG_STATUS_ESCTD;
                }
                prologListToInsert.add(log);
            }
        }
        //Prologlist will have value when the lead router picks up the opportunity for rotation and assigns to an owner.
        // The prolog list passed to the method is the old log record. based on the old log record, the new log record
        //is created. The same information as was in the old log record will be used this time except for the status will be
        //different on the new log record based on the operation that happens on the opportuntiy. The opplist will be null when prolog list
        // contains value.
        if(proLogList != null && proLogList.size() > 0){
 
            
            Map<Id, Team_Member__c> teamMembermap = new Map<Id, Team_Member__c>([Select Id, Which_Team__c, Which_Team__r.ESC_Exempt__c, Which_Team__r.Team_Account__r.ESC_Exempt__c from Team_Member__c where Id in :opptyIdTomemberId.values()]);
            
                     
            for(PRO_Log__c thisLog : proLogList){
                ProspectLogHandler.DistributionHours thisDist = accountIdToDistrbutionHourSetting.get(thisLog.Account__c);
                Datetime currentTimeStamp = Datetime.newInstance(Date.today(), Datetime.now().time());
                
                DateTime nextRunTime = findNextRunTime(thisDist, currentTimeStamp);
                
                PRO_Log__c log = new PRO_Log__c();
                if(opptyIdTomemberId != null && opptyIdTomemberId.containsKey(thisLog.Opportunity__c)){
                    log.Team_Member__c = opptyIdTomemberId.get(thisLog.Opportunity__c);
                }else{
                    continue;
                }
                Team_Member__c thisTeamMember = teamMembermap.get(opptyIdTomemberId.get(thisLog.Opportunity__c));
                boolean escExempt = false;
                if(thisTeamMember != null){
                    if(thisTeamMember.Which_Team__r.ESC_Exempt__c || thisTeamMember.Which_Team__r.Team_Account__r.ESC_Exempt__c){
                        escExempt = true;
                    }
                }
                log.OwnerId = (accountidToDOAQueueId.get(thisLog.Account__c) != null ? accountidToDOAQueueId.get(thisLog.Account__c) : UserInfo.getUserId());
                log.Previous_Pro_Log__c = thisLog.Id;
                log.Account__c = thisLog.Account__c;
                log.Campaign__c = thisLog.Campaign__c;
                log.Contact__c = thisLog.Contact__c;
                log.Next_Run_Time__c = nextRunTime;
                log.Opportunity__c = thisLog.Opportunity__c;
                log.PRO_Team__c = thisTeamMember.Which_Team__c;
                log.SRM_Program__c = thisLog.SRM_Program__c;
                log.SRM_Specialization__c = thisLog.SRM_Specialization__c;
                log.SRM_Term__c = thisLog.SRM_Term__c;
                log.SRP_Program__c = thisLog.SRP_Program__c;
                log.SRP_Specialization__c = thisLog.SRP_Specialization__c;
                log.SRP_Term__c = thisLog.SRP_Term__c;
                String newStatus = findNewStatus(thisLog.Status__c, thisDist);
                log.Status__c = newStatus;
               
                if(escExempt == true){
                    log.Status__c = ProspectConstants.LOG_STATUS_CLOSD;
                     log.Process_This_Log__c = false;
                }
                if(newStatus == ProspectConstants.LOG_STATUS_ESCTD || newStatus == ProspectConstants.LOG_STATUS_PROCD){
                    if(thisDist != null){
                        //Distribution setting without null is a true scenarion of user missing to take action and escalation.
                        //we do not want to process the log if there is no distribution setting on the account record.
                        // if the new status is escalated and the distribution setting is null, that would mean, some one
                        // changed the owner of opportunity to PROspect Engine user and hence it was escalated.
                        // If process this log set to true in such scenarios, the same opportunity will get reassigned again and again
                        // after every one minute interval which is not desirable.
                        log.Regular_Not_Escalated__c = false;
                         log.Process_This_Log__c = true;
                    }
                }
                prologListToInsert.add(log);
                thisLog.Process_This_Log__c = false;
                prologListToUpdate.add(thisLog);
            }
        }
        if(prologListToInsert != null && prologListToInsert.size() > 0){
            insert prologListToInsert;
        }
        if(prologListToUpdate != null && prologListToUpdate.size() > 0){
            update prologListToUpdate;
        }
    }
    public void createProspectLogRecordForOpportunity(List<Opportunity> oldList, List<Opportunity> newList){
        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        List<Opportunity> opptyToProcess = new List<Opportunity>();
        List<id> closeTheseOppty = new List<id>();
        for(Integer i=0;i<newList.size(); i++){
            Opportunity oldO = oldList.get(i);
            Opportunity newO = newList.get(i);
            if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(newO.AccountId) && prospectSupportedAccount.get(newO.AccountId)){
                if(oldO.OwnerId != newO.OwnerId && newO.OwnerId == setting.PROspect_User_ID__c){
                    opptyToProcess.add(newO);
                }else if(oldO.StageName == 'New Inquiry' && oldO.StageName != newO.stageName){
                    closeTheseOppty.add(newO.id);
                }
            }
        }
        if(opptyToProcess != null && opptyToProcess.size() > 0){
            createProspectLogRecordForOpportunity(opptyToProcess, false);
        }
        if(closeTheseOppty != null && closeTheseOppty.size() > 0){
            closeAllLogsForTheseOppty(closeTheseOppty, 'Opportunity');
        }
    }
    public void createProspectLogRecordForCase(List<Case> oldList, List<Case> newList){
    	Set<String> supportedRecordTypes = new Set<String>(); 
	    Schema.DescribeSObjectResult d = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
	   
	    Schema.RecordTypeInfo rtByName =  rtMapByName.get('SRP Help');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
		
		rtByName =  rtMapByName.get('SRP Customer');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
    	
    	Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        List<Case> caseToProcess = new List<Case>();
        List<id> closeTheseCase = new List<id>();
        for(Integer i=0;i<newList.size(); i++){
            Case oldO = oldList.get(i);
            Case newO = newList.get(i);
            String recordTypeId = newO.RecordTypeId;
            	if(!supportedRecordTypes.contains(recordTypeId)){
	    			continue;
	    		} 
            
            
            if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(newO.AccountId) && prospectSupportedAccount.get(newO.AccountId)){
                if(oldO.OwnerId != newO.OwnerId && newO.OwnerId == setting.PROspect_User_ID__c){
                    caseToProcess.add(newO);
                }else if(oldO.Status == 'New' && oldO.Status != newO.Status){
                    closeTheseCase.add(newO.id);
                }
            }
        }
        if(caseToProcess != null && caseToProcess.size() > 0){
            
            this.createLogRecords_case(caseToProcess, null, null, false); 
        
        }
        if(closeTheseCase != null && closeTheseCase.size() > 0){
            closeAllLogsForTheseOppty(closeTheseCase, 'Case');
        }
    }
    public void closeAllLogsForTheseOppty(List<id> newOpportunityList, String objectName){
       List<PRO_Log__c> proLogList = null;
       if(objectName == 'Opportunity'){
       	   proLogList = [Select id, Status__c, Opportunity__c, Process_This_Log__c from PRO_Log__c where Opportunity__c IN :newOpportunityList];
       }
       if(objectName == 'Case'){
       	proLogList = [Select id, Status__c, Case__c, Process_This_Log__c from PRO_Log__c where Case__c IN :newOpportunityList]; 
       }
       
        List<PRO_Log__c> proLogListToNotProcess = new List<PRO_Log__c>();
        for(PRO_Log__c thisLog : proLogList){
            thisLog.Process_This_Log__c = false;
            proLogListToNotProcess.add(thisLog);
        }
        if(proLogListToNotProcess != null && proLogListToNotProcess.size() > 0){
            Database.update(proLogListToNotProcess, false);
        }
    } 
    public void createProspectLogRecordForOpportunity(List<Opportunity> opptyList, boolean escalatedFromOppty){


        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        List<Opportunity> actualOpportunityList = new List<Opportunity>();
        String testEmail = '@test.com';
        String mailinatorEmail = '@mailinator.com';
        for(Opportunity o : opptyList){
            if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(o.AccountId) && prospectSupportedAccount.get(o.AccountId)){
                String srmEmail = (o.Email__c != null ? o.Email__c : '');
                String srpEmail = (o.DeltakSRP__Email__c != null ? o.DeltakSRP__Email__c : '');
                if(o.stageName == 'Dormant' || o.OwnerId != setting.PROspect_User_ID__c || (srmEmail != null && srmEmail.contains(testEmail) || srmEmail.contains(mailinatorEmail) ) || (srpEmail != null && srpEmail.contains(testEmail)   || srpEmail.contains(mailinatorEmail))){
                    continue;
                }else{
                    actualOpportunityList.add(o);
                }
            }
        }
        if(actualOpportunityList!=null && actualOpportunityList.size() > 0){
            this.createLogRecords(actualOpportunityList, null, null, escalatedFromOppty);
        }
    }
    // SRP-1482 - VR - START
    public void updateOpportunityOwner(List<Opportunity> oldList, List<Opportunity> newList)
    {
        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        List<Opportunity> opptyToUpdate = new List<Opportunity>();
        List<id> updateOwnersForTheseOpptys = new List<id>();
         System.debug('Before Before Update For Loop-->'+prospectSupportedAccount);
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        Set<Id> profileIds = new Set<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        if(profList != null && profList.size() > 0)
        {
            for(Prospect_Profiles__c pid : profList)
            {
                profileIds.add(pid.ProfileId__c);
            }       
        }
        system.debug('Profile List'+profileIds);
        for(Integer i=0;i<newList.size(); i++){
            Opportunity oldO = oldList.get(i);
            Opportunity newO = newList.get(i);
            System.debug('In Before Update For Loop-->'+prospectSupportedAccount.containsKey(newO.AccountId));
            System.debug('In Before Update For Loop-->'+prospectSupportedAccount.get(newO.AccountId));
            if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(newO.AccountId) && prospectSupportedAccount.get(newO.AccountId)){
                if(oldO.StageName == 'New Inquiry' && oldO.StageName != newO.stageName){
                    Id userId = UserInfo.getUserId();
                    Id profileId = UserInfo.getProfileId();
                    if(profileIds.contains(profileId))
                    {
                        newO.OwnerId = UserInfo.getUserId();
                    }  
                }
            }
        }
    
    }
    // SRP-1482 - VR - END
}