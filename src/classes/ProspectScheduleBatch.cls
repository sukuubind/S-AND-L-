global without sharing class ProspectScheduleBatch implements Database.Batchable<SObject> {
    global String query = '';
    public ProspectScheduleBatch(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        Datetime currentStamp = System.now();
        Time t = currentStamp.timeGMT();
        String month = (String.valueOf(currentStamp.monthGmt()).length()==1 ? '0'+String.valueOf(currentStamp.monthGmt()) : String.valueOf(currentStamp.monthGmt()));
        String thisDate = ((String.valueOf(currentStamp.dayGmt())).length() == 1 ? '0'+String.valueOf(currentStamp.dayGmt()) : String.valueOf(currentStamp.dayGmt()));
        String hour = (String.valueOf(currentStamp.hourGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.hourGmt()) : String.valueOf(currentStamp.hourGmt()));
        String minute = (String.valueOf(currentStamp.minuteGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.minuteGmt()) : String.valueOf(currentStamp.minuteGmt()));
        String timeStamp = String.valueOf(currentStamp.yearGmt())+'-'+month+'-'+thisDate+'T'+hour+':'+minute+':00.000Z';
        System.Debug(query+timestamp);
        this.query = this.query + timeStamp;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<PRO_Log__c> scopeList = (List<PRO_Log__c>)scope;
        scopeList = ProspectRulesEvaluator.refineTheScope(scopeList);
        if(scopeList != null && scopeList.size() > 0){
            Map<Opportunity, Team__c> teamsForOpportunities = ProspectRulesEvaluator.findTeams(scopeList);
            Map<Id, Id> opptyIdToMemberId = ProspectOpportunityAssignment.performOpportunityAssignment(teamsForOpportunities);
            ProspectLogHandler logHandler = new ProspectLogHandler();
            logHandler.createLogRecords(null, scopeList, opptyIdToMemberId, null);
        }
        
    }
     global void finish(Database.BatchableContext BC){
         Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
         Integer BATCH_SIZE = Integer.valueOf(setting.Prospect_Batch_Size__c);
         Integer MINUTES_FROM_NOW = Integer.valueOf(setting.PROspect_Schedule__c);
         String query = ProspectConstants.PROLOG_SCHEDULE_QUERY;
         ProspectScheduleBatch proBatch = new ProspectScheduleBatch(query);
         String cronID = System.scheduleBatch(proBatch, 'ProspectScheduleBatch'+System.now(), MINUTES_FROM_NOW, BATCH_SIZE);
                    
       // ID batchId = Database.executeBatch(proBatch, BATCH_SIZE); 
        //System.debug('Batch Job executed - ID = ' + batchId); 
        
    }
}