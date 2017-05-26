global without sharing class ProspectScheduleCaseBatch implements Database.Batchable<SObject> {
    global String query = '';
    public ProspectScheduleCaseBatch(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        Datetime currentStamp = System.now();
        Time t = currentStamp.timeGMT();
        String month = (String.valueOf(currentStamp.monthGmt()).length()==1 ? '0'+String.valueOf(currentStamp.monthGmt()) : String.valueOf(currentStamp.monthGmt()));
        String thisDate = ((String.valueOf(currentStamp.dayGmt())).length() == 1 ? '0'+String.valueOf(currentStamp.dayGmt()) : String.valueOf(currentStamp.dayGmt()));
        String hour = (String.valueOf(currentStamp.hourGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.hourGmt()) : String.valueOf(currentStamp.hourGmt()));
        String minute = (String.valueOf(currentStamp.minuteGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.minuteGmt()) : String.valueOf(currentStamp.minuteGmt()));
        String second = (String.valueOf(currentStamp.secondGmt()).length() == 1 ? '0'+String.valueOf(currentStamp.secondGmt()) : String.valueOf(currentStamp.secondGmt()));
        String timeStamp = String.valueOf(currentStamp.yearGmt())+'-'+month+'-'+thisDate+'T'+hour+':'+minute+':'+second+'.000Z'; 
        System.Debug(query+timestamp);
        this.query = this.query + timeStamp;
        this.query = this.query + ' and Case__c != null';
        System.Debug('query -- '+query);
        System.Debug('query result -- '+Database.query(query));
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope){ 
        List<PRO_Log__c> scopeList = (List<PRO_Log__c>)scope;
        scopeList = ProspectRulesEvaluator_CaseMgmt.refineTheScope(scopeList);
        if(scopeList != null && scopeList.size() > 0){
            Map<Case, Team__c> teamsForcases = ProspectRulesEvaluator_CaseMgmt.findTeams(scopeList); 
            Map<Id, Id> caseIdToMemberId = ProspectOpportunityAssignment_CaseMgmt.performCaseAssignment(teamsForcases);  
            ProspectLogHandler logHandler = new ProspectLogHandler();
            logHandler.createLogRecords_case(null, scopeList, caseIdToMemberId, null);
        }
        
    }
     global void finish(Database.BatchableContext BC){
         Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
         Integer BATCH_SIZE = Integer.valueOf(setting.Prospect_Batch_Size__c);
         Integer MINUTES_FROM_NOW = Integer.valueOf(setting.PROspect_Case_Schedule__c);
         String query = ProspectConstants.PROLOG_SCHEDULE_QUERY;
         ProspectScheduleCaseBatch proBatch = new ProspectScheduleCaseBatch(query); 
        if(!Test.isRunningTest()){
         String cronID = System.scheduleBatch(proBatch, 'ProspectScheduleCaseBatch'+System.now(), MINUTES_FROM_NOW, BATCH_SIZE);
        }
       // ID batchId = Database.executeBatch(proBatch, BATCH_SIZE); 
        //System.debug('Batch Job executed - ID = ' + batchId); 
        
    }
}