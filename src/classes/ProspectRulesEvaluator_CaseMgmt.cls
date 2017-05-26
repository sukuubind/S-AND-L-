public without sharing class ProspectRulesEvaluator_CaseMgmt {
    
     public static  Map<Id, SObject> idToAccounts = null;
        public static  Map<id, SObject> idToSRMPrograms = null;
        public static   Map<id, SObject> idToSRPPrograms = null;
        public static  Map<Id, SObject> idToSRMSpecs = null;
        public static  Map<Id, SObject> idToSRPSpecs = null;
        public static  Map<Id, SObject> idToCampaign = null;
        public static  Map<Id, SObject> idToContact = null;
        public static Map<Id, SObject> idToSRMTerm = null;
        public static Map<Id, SObject> idToSRPTerm = null;
     public static List<PRO_Log__c> refineTheScope(List<PRO_Log__c> prologList){
        ProspectLogHandler logH = new ProspectLogHandler();
        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
        Map<Id, PRO_Log__c> caseIdToLogId = new Map<Id, PRO_Log__c>();
        List<Id> caseIds = new List<id>();
        List<Id> caseIdsToCloseLogs = new List<id>();
        List<PRO_Log__c> logRecordsToDelete = new List<PRO_Log__c>();
        List<PRO_Log__c> validLogRecords = new List<PRO_Log__c>();
        for(PRO_Log__c thisLog : prologList){
            caseIds.add(thisLog.Case__c);
            caseIdToLogId.put(thisLog.Case__c, thisLog);
        }
        List<Case> caseList = [Select id, ownerid from Case where Id IN :caseIds]; 
        for(Case o : caseList){ 
            if(o.ownerId == setting.PROspect_User_ID__c){
                validLogRecords.add(caseIdToLogId.get(o.Id));
            }else{
              if(caseIdToLogId.get(o.Id).Status__c == ProspectConstants.LOG_STATUS_RECVD){
                    caseIdsToCloseLogs.add((o.Id));
                }else{
                    validLogRecords.add(caseIdToLogId.get(o.Id));
                }
            }
        }
        if(caseIdsToCloseLogs != null && caseIdsToCloseLogs.size() > 0){
           logH.closeAllLogsForTheseOppty(caseIdsToCloseLogs, 'Case');
        }
        return validLogRecords;
    }
    public static Map<Case, Team__c> findTeams(List<PRO_Log__c> prologList){
    System.Debug('prologList -- '+prologList);
        //Find all SRM and SRP fields supported by the lead router
        //Construct one global set of all supported fields. Add any additional fields that is needed for processing that is not supported by the lead router based fields.
        Set<String> srpFieldForCase = ProspectUtils.buildFieldSetList(ProspectUtils.getFields('Case', true));
        Set<String> allCaseFields = new Set<String>();
        for(String thisFieldSet : srpFieldForCase){
            System.Debug('thisFieldSet'+thisFieldSet);
            allCaseFields.add(thisFieldSet);
        }
       
        allCaseFields.add('Accountid');
        allCaseFields.add('Team__c');
        allCaseFields.add('OwnerId');
        allCaseFields.add('Type');
       
        System.Debug('allCaseFields -- '+allCaseFields);
        List<Id> opptyIdList = new List<id>();
        List<Id> escalatedTeams = new List<id>();
        Set<Id> escalatedCaseList = new Set<Id>();
        //Constuct a list of escalated case and escalated teams. Any log record that is being processed with status of processed or escalated is an oppoortunity considered for esclation
        for(PRO_Log__c thisProlog : prologList){
            opptyIdList.add(thisProlog.Case__c);
            if(thisProlog.Status__c == ProspectConstants.LOG_STATUS_PROCD || thisProlog.Status__c == ProspectConstants.LOG_STATUS_ESCTD){
                escalatedCaseList.add(thisProlog.Case__c);
                escalatedTeams.add(thisProlog.PRO_Team__c);
            }
        }
        Map<Case, Team__c> escalatedcase = new Map<Case, Team__c>();
        //Query all the fields needed on the case
        SObject[] opptyList = ProspectUtils.buildAndRunQuery(allCaseFields, ProspectConstants.caseString, opptyIdList, null, ProspectConstants.id);
        //Query all the fields on the team object
        Map<Id, Team__c> teamsMap = new Map<Id, Team__c>([Select Allocation_Override__c, Team_Account__c, Escalation_Period__c, ESC_Exempt__c, Member_Count__c, Team_Order__c, Team_Name__c, Team_Rule__c, Active__c from Team__c where Id IN :escalatedTeams AND Active__c = true]);
        //Build a list of cases for the non-escalated cases. i.e., the case is just now received. This is the opportunitiesinContext. Any escalated case that belongs to a team BUT now inactive.
        List<Case> casesInContext = new List<Case>();
        for(SObject thisSobject : opptyList){
            Case cas = (Case)thisSObject;
            if(escalatedCaseList.contains((Id)thisSObject.get('Id')) && teamsMap.containsKey((Id)thisSobject.get('Team__c'))){
                //Building the map of escalated cases
                escalatedcase.put(cas, teamsMap.get((Id)thisSobject.get('Team__c')));
            }else{
                //These are non-escalated opportuntiies
                casesInContext.add(cas);
            }
        }
        //Find the teams for the cases in context
        Map<Case, Team__c> teamsForInContext = evaluateRulesForCase(casesInContext);
        Map<Case, Team__c> returnMap = new Map<Case, Team__c>();
        //build on returnMap that contains cases and their teams for both escalated and non-escalated cases. This map will be forwarded to the next step for round robin
        returnMap = ProspectUtils.combineTwoMaps(escalatedcase, returnMap);
        returnMap = ProspectUtils.combineTwoMaps(teamsForInContext, returnMap);
        
        
        
        return returnMap;
    }
    
    
    
    public static Map<Case, Team__c> evaluateRulesForCase(List<Case> casesInContext){ 
        Map<Case, Team__c> returnMap = new Map<Case, Team__c>();
        
        // We need a list of Ids. One for each object supported by the lead router
        List<Id> accountIds = new List<Id>();
        List<id> srmProgramids = new List<id>();
        List<id> srpProgramIds = new List<id>();
        List<Id> srmSpecids = new List<id>();
        List<id> srpSpecIds = new List<id>();
        List<id> campaignids = new List<Id>();
        List<id> parentCampaignId = new List<id>(); 
        List<Id> srmcontactId = new List<id>();
        List<Id> srpcontactId = new List<id>();
        List<id> srmTermid = new List<id>();
        List<id> srpTermId = new List<id>();
        
        //Loop through the opportunties in context and populate a list of Ids for each object supported by the lead router
        for(Case cas : casesInContext){
            accountIds.add(cas.AccountId);
            
        }
        
        
        SObject[] accountObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.accountString, true), ProspectConstants.accountString, accountIds, null, ProspectConstants.id);
        
        
        //Query each object supported by lead router using the lead router fieldset in each of the respective objects
        idToAccounts = ProspectUtils.buildMapofRecords(accountObjectList);
        
        //Query all the rules associated with the accounts in the contect of the case
        List<PRO_Rule__c> rulesList = [Select Id, Academic_Institution__c from PRO_Rule__c where Academic_Institution__c IN :accountIds];
        //Query all the teams associated with the accounts in the context of the case
        List<Team__c> teamList = [Select Id, Team_Account__c, Escalation_Period__c, ESC_Exempt__c, Team_Rule__r.Formula__c,
                                         Team_Order__c, Team_Name__c, Team_Rule__c, Default_Team__c, Allocation_Override__c, Team_Rule__r.Number_of_Rule_Sets__c
                                      from Team__c 
                                    where Team_Account__c IN :accountIds and Active__c = true and Active_Member_Count__c > 0 order by Team_Order__c asc];
                                    
        // Build a list of Rules for each of the accounts in the context of the case
        Map<id, List<PRO_Rule__c>> accountToRules = new Map<id, List<PRO_Rule__c>>();
        for(PRO_Rule__c thisRule : rulesList){
            List<PRO_Rule__c> proRuleListTemp = new List<PRO_Rule__c>();
            if(accountToRules != null && accountToRules.containsKey(thisRule.Academic_Institution__c)){
                proRuleListTemp = accountToRules.get(thisRule.Academic_Institution__c);
            }
            proRuleListTemp.add(thisRule);
            accountToRules.put(thisRule.Academic_Institution__c, proRuleListTemp);
        }
        //Build a list of Teams for each of the accounts in the context of the case
        Map<Id, List<Team__c>> accountToTeams = new Map<Id, List<Team__c>>();
        Map<Id, Team__c> defaultTeamForAccount = new Map<Id, Team__c>();
        for(Team__c thisTeam : teamList){
            if(thisTeam.Default_Team__c == false){
                if(thisTeam.Team_Rule__c != NULL && thisTeam.Team_Rule__r.Formula__c != '' && thisTeam.Team_Rule__r.Number_of_Rule_Sets__c > 1){
                    List<Team__c> teamListTemp = new List<Team__c>();
                    if(accountToTeams != null && accountToTeams.containsKey(thisTeam.Team_Account__c)){
                        teamListTemp = accountToTeams.get(thisTeam.Team_Account__c);
                    }
                    teamListTemp.add(thisTeam);
                    accountToTeams.put(thisTeam.Team_Account__c, teamListTemp);
                }
            }else{
                defaultTeamForAccount.put(thisTeam.Team_Account__c, thisTeam);
            }
        }
        
        //Query for all conditions (rule sets) associated with the Rules that queried within the context of the account and case
        List<PRO_Rule_Set__c> conditionList = [Select id, Rule__c, Field_Name__c, Rule__r.Formula__c,
                                                                    Object_Name__c, Operator__c, Object_API_Name__c,
                                                                    Sequence__c, Value__c from PRO_Rule_Set__c 
                                                            where Rule__c IN :rulesList];
        
        Map<Id, List<PRO_Rule_Set__c>> formulaToConditions = new Map<id, List<PRO_Rule_Set__c>>();
        Map<Integer, Boolean> sequenceToBoolean = new Map<Integer, Boolean>();
        Map<Id, String> formulaToType = new Map<id, String>();
        Map<Id, Boolean> formulaToRender = new Map<Id, Boolean>();
        String formula = '';
        Map<id, String> ruleIdToFormula = new Map<Id, String>();
        
       //Build a list of conditions for each of the rule
        for(PRO_Rule_Set__c thisCondition : conditionList) {
            formula = thisCondition.Rule__r.Formula__c;
            if(ruleIdToFormula != null && !ruleIdToFormula.containsKey(thisCondition.Rule__c)){
                ruleIdToFormula.put(thisCondition.Rule__c, formula);
            }
            List<PRO_Rule_Set__c> tmp_conditionList = new List<PRO_Rule_Set__c>();
            if(formulaToConditions != null && formulaToConditions.containsKey(thisCondition.Rule__c)){
                tmp_conditionList = formulaToConditions.get(thisCondition.Rule__c);
            }
            tmp_conditionList.add(thisCondition);
            formulaToConditions.put(thisCondition.Rule__c, tmp_conditionList);
        }
        
        //The main logic starts here. Until now, we did the preparation by having all the information needed to find the correct team for the case.
        //Loop through each of the case in the context. We need to find the correct team for this case
        for(Case cas : casesInContext){
            //Using the map above, fetch the list of teams for the account in the case
            List<Team__c> teamForAccount = accountToTeams.get(cas.AccountId);
            Team__c defaultTeam = defaultTeamForAccount.get(cas.AccountId);
            Integer counterVar = 0;
            if(teamForAccount == null){
                continue;
            }
            for(Team__c thisTeam : teamForAccount){
                System.Debug('team Name -- '+thisTeam.Team_Name__c);
                //For each of the team, identify the corresponding rule. Although a look up relationship, there will always be a Rule associated with the team
                //because, the query for the team has been done where Rule is not null in the team.
                Id thisFormula = thisTeam.Team_Rule__c;
                formula = ruleIdToFormula.get(thisFormula);
                //Once the Rule is identified, using a map from above, loop through the list of all rule sets
                for(PRO_Rule_Set__c thisCondition : formulaToConditions.get(thisFormula)){
                    System.Debug('thisCondition -- '+thisCondition);
                   SObject record = null;//(SObject)cas;
                    record = findCorrectObjectForRuleSet(thisCondition.Object_API_Name__c, cas);
                    System.debug('--- for: ' + thisCondition.object_name__c + ' got a record: ' + record);
                    
                    //Based on the object and the field referenced in the rule set, fetch the field type. The field type is needed in the evaluation of the rule set itself.
                    String namespace = '';
                    Schema.DisplayType thisFieldType = ProspectRuleEvaluationUtils.findFieldType(namespace, thisCondition.Object_API_Name__c, thisCondition.Field_Name__c);
    
                    Boolean formulaEval;
                    if(record == null) { 
                        System.debug('--- the record in question was null, returning false');
                        formulaEval = false;
                    }
                    else{
                        //comparison evalueates if the rule set is true or false
                         formulaEval = ProspectRuleEvaluationUtils.comparison(record.get(thisCondition.Field_Name__c), thisCondition.Value__c, thisCondition.Operator__c, thisFieldType);
                    }
                    sequenceToBoolean.put(Integer.valueOf(thisCondition.Sequence__c), formulaEval);
                } // END OF RULE SET LOOP
                System.Debug('sequenceToBoolean -- '+sequenceToBoolean);
                List<Integer> sequenceIntegerList = new List<Integer>(sequenceToBoolean.keySet());
                // Just a plain replace will cause issue. it will replace 11 as truetrue when replacing 1 with true.
                // Sorting the sequence and going backwards will replace 11 with true and will replace 1 with true correctly.
                sequenceIntegerList.sort();
                for(Integer i=sequenceIntegerList.size()-1; i>= 0 ;i--){
                    Integer thisSeq = sequenceIntegerList.get(i);
                    formula = formula.replace(String.valueOf(thisSeq), String.valueOf(sequenceToBoolean.get(thisSeq)));
                }
                //The line below performs the recursion logic of evaluating a rule to a global true of false.
                String stringresult = ProspectRuleEvaluationUtils.evaluateLogicalExpression(formula);
                System.Debug('stringresult -- '+stringresult);
                if(Boolean.valueOf(stringresult) == true){
                    //if the entire rule evaluates to true, then, the team that has this rule should be the chosen one.
                    //Assign the team to case and break from the Team loop and move on to the next case.
                    //Else, continue and move on to the next team.
                    System.Debug(cas+'-'+thisTeam);
                    returnMap.put(cas, thisTeam);
                    break;
                }else{
                    if(counterVar == teamForAccount.size()-1){
                       System.Debug('Default Team Assignment --- '+ cas+'-'+defaultTeam);
                        returnMap.put(cas, defaultTeam);
                    }
                    //When Rule evaluates to false, it makes sense to evaluate the next team. BUT, if all teams for the account
                    //is echausted and no more team remains to be evaluated for the rule, we need to determine which team should
                    // ge the case.
                    //1, The last team in the order sequence for the Account can get the case
                    //2, One team can exist as the team for the Account that is considered as default. If none of the rule evaluates to true to determine the team, the default team can be the chosen one.
                    //We need to clarify the business and then implement the functionality
                }
                
            counterVar++;
            }
            
    }
        
        
        
        
        return returnMap;
    }
    private static SObject findCorrectObjectForRuleSet(String objectName, Case cas){ 
        sObject record;
        //Depending on the object referenced in the RuleSet, bring the correct object record within the context to evaluate the individual line item of the rule
        if(objectName== ProspectConstants.accountString && idToAccounts.containsKey(cas.AccountId)){
            record = (sObject) idToAccounts.get(cas.AccountId);
        } else if(objectName== ProspectConstants.caseString) {
            record = (sObject)cas;
        }
    
    return record;
    }
}