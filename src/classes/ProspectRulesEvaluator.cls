public without sharing class ProspectRulesEvaluator {
    
    
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
        Map<Id, PRO_Log__c> opptyIdToLogId = new Map<Id, PRO_Log__c>();
        List<Id> opptyIds = new List<id>();
        List<Id> opptyIdsToCloseLogs = new List<id>();
        List<PRO_Log__c> logRecordsToDelete = new List<PRO_Log__c>();
        List<PRO_Log__c> validLogRecords = new List<PRO_Log__c>();
        for(PRO_Log__c thisLog : prologList){
            opptyIds.add(thisLog.Opportunity__c);
            opptyIdToLogId.put(thisLog.Opportunity__c, thisLog);
        }
        List<Opportunity> opptyList = [Select id, ownerid from Opportunity where Id IN :opptyIds];
        for(Opportunity o : opptyList){
            if(o.ownerId == setting.PROspect_User_ID__c){
                validLogRecords.add(opptyIdToLogId.get(o.Id));
            }else{
              if(opptyIdToLogId.get(o.Id).Status__c == ProspectConstants.LOG_STATUS_RECVD){
                    opptyIdsToCloseLogs.add((o.Id));
                }else{
                    validLogRecords.add(opptyIdToLogId.get(o.Id));
                }
            }
        }
        if(opptyIdsToCloseLogs != null && opptyIdsToCloseLogs.size() > 0){
           logH.closeAllLogsForTheseOppty(opptyIdsToCloseLogs, 'Opportunity');
        }
        return validLogRecords;
    }
    public static Map<Opportunity, Team__c> findTeams(List<PRO_Log__c> prologList){
    System.Debug('prologList -- '+prologList);
        //Find all SRM and SRP fields supported by the lead router
        //Construct one global set of all supported fields. Add any additional fields that is needed for processing that is not supported by the lead router based fields.
        Set<String> srmFieldsForOpportunity = ProspectUtils.buildFieldSetList(ProspectUtils.getFields('Opportunity', false));
        Set<String> srpFieldForOpportunity = ProspectUtils.buildFieldSetList(ProspectUtils.getFields('Opportunity', true));
        Set<String> allOpptyFields = new Set<String>();
        for(String thisFieldSet : srmFieldsForOpportunity){
            System.Debug('thisFieldSet'+thisFieldSet);
            allOpptyFields.add(thisFieldSet);
        }
        for(String thisFieldSet : srpFieldForOpportunity){
            System.Debug('thisFieldSet'+thisFieldSet);
            allOpptyFields.add(thisFieldSet);
        }
        allOpptyFields.add('Accountid');
        allOpptyFields.add('Team__c');
        allOpptyFields.add('OwnerId');
        allOpptyFields.add('Program__c');
        allOpptyFields.add('DeltakSRP__Academic_Program__c');
        allOpptyFields.add('Specialization__c');
        allOpptyFields.add('DeltakSRP__Academic_Specialization__c');
        allOpptyFields.add('CampaignId');
        allOpptyFields.add('Campaign.ParentId');
        allOpptyFields.add('Student__c');
        allOpptyFields.add('DeltakSRP__Student__c');
        allOpptyFields.add('Academic_Start_Date__c');
        allOpptyFields.add('DeltakSRP__Academic_Start_Date__c');
        System.Debug('allOpptyFields -- '+allOpptyFields);
        List<Id> opptyIdList = new List<id>();
        List<Id> escalatedTeams = new List<id>();
        Set<Id> escalatedOpportunityList = new Set<Id>();
        //Constuct a list of escalated opportuntiy and escalated teams. Any log record that is being processed with status of processed or escalated is an oppoortunity considered for esclation
        for(PRO_Log__c thisProlog : prologList){
            opptyIdList.add(thisProlog.Opportunity__c);
            if(thisProlog.Status__c == ProspectConstants.LOG_STATUS_PROCD || thisProlog.Status__c == ProspectConstants.LOG_STATUS_ESCTD){
                escalatedOpportunityList.add(thisProlog.Opportunity__c);
                escalatedTeams.add(thisProlog.PRO_Team__c);
            }
        }
        Map<Opportunity, Team__c> escalatedOpportunity = new Map<Opportunity, Team__c>();
        //Query all the fields needed on the opportunity
        SObject[] opptyList = ProspectUtils.buildAndRunQuery(allOpptyFields, ProspectConstants.opportunityString, opptyIdList, null, ProspectConstants.id);
        //Query all the fields on the team object
        Map<Id, Team__c> teamsMap = new Map<Id, Team__c>([Select Allocation_Override__c, Team_Account__c, Escalation_Period__c, ESC_Exempt__c, Member_Count__c, Team_Order__c, Team_Name__c, Team_Rule__c, Active__c from Team__c where Id IN :escalatedTeams AND Active__c = true]);
        //Build a list of opportunities for the non-escalated opportunities. i.e., the opportunity is just now received. This is the opportunitiesinContext. Any escalated opportunity that belongs to a team BUT now inactive.
        List<Opportunity> opportunitiesInContext = new List<Opportunity>();
        for(SObject thisSobject : opptyList){
            Opportunity opp = (Opportunity)thisSObject;
            if(escalatedOpportunityList.contains((Id)thisSObject.get('Id')) && teamsMap.containsKey((Id)thisSobject.get('Team__c'))){
                //Building the map of escalated opportunities
                escalatedOpportunity.put(opp, teamsMap.get((Id)thisSobject.get('Team__c')));
            }else{
                //These are non-escalated opportuntiies
                opportunitiesInContext.add(opp);
            }
        }
        //Find the teams for the opportunities in context
        Map<Opportunity, Team__c> teamsForInContext = evaluateRulesForOpportunity(opportunitiesInContext);
        Map<Opportunity, Team__c> returnMap = new Map<Opportunity, Team__c>();
        //build on returnMap that contains opportunities and their teams for both escalated and non-escalated opportunties. This map will be forwarded to the next step for round robin
        returnMap = ProspectUtils.combineTwoMaps(escalatedOpportunity, returnMap);
        returnMap = ProspectUtils.combineTwoMaps(teamsForInContext, returnMap);
        
        
        
        return returnMap;
    }
    
    
    
    public static Map<Opportunity, Team__c> evaluateRulesForOpportunity(List<Opportunity> opportunitiesInContext){
        Map<Opportunity, Team__c> returnMap = new Map<Opportunity, Team__c>();
        
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
        for(Opportunity opp : opportunitiesInContext){
            accountIds.add(opp.AccountId);
            if(opp.Program__c != null){
                srmProgramids.add(opp.Program__c);
            }
            if(opp.DeltakSRP__Academic_Program__c != null){
                srpProgramids.add(opp.DeltakSRP__Academic_Program__c);
            }
            if(opp.Specialization__c != null){
                srmSpecids.add(opp.Specialization__c);
            }
            if(opp.DeltakSRP__Academic_Specialization__c != null){
                srpSpecids.add(opp.DeltakSRP__Academic_Specialization__c);
            }
            if(opp.CampaignId != null){
                campaignids.add(opp.CampaignId);
            }
            if(opp.Campaign.ParentId != null){
                parentCampaignId.add(opp.Campaign.ParentId);
            }
            if(opp.Student__c != null){
                srmcontactId.add(opp.Student__c);
            }
            if(opp.DeltakSRP__Student__c != null){
                srpcontactId.add(opp.DeltakSRP__Student__c);
            }
            if(opp.Academic_Start_Date__c != null){
                srmTermid.add(opp.Academic_Start_Date__c);
            }
            if(opp.DeltakSRP__Academic_Start_Date__c != null){
                srpTermId.add(opp.DeltakSRP__Academic_Start_Date__c);
            }
        }
        //Since Campaign and ParentCampaign map to the same camapign object, it can be grouped together into a single list of IDs.
        //Since SRM contact and SRP contact map to the same Contact object, it can be grouped together into a single list of IDs.
        List<id> campaignAllId = ProspectUtils.constructFinalListSObject(campaignids, parentCampaignId);
        List<id> contactAllid = ProspectUtils.constructFinalListSObject(srmcontactId, srpcontactId);
        
        SObject[] accountObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.accountString, true), ProspectConstants.accountString, accountIds, null, ProspectConstants.id);
        SObject[] apObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.programLabelString, false), ProspectConstants.programString, srmprogramids, null, ProspectConstants.id);
        SObject[] srpAPObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.srpprogramLabelString, true), ProspectConstants.srpprogramString, srpprogramids, null, ProspectConstants.id);
        SObject[] specObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.specializationLabelString, false), ProspectConstants.specializationString, srmSpecids, null, ProspectConstants.id);
        SObject[] srpSpecObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.srpspecializationLabelString, true), ProspectConstants.srpspecializationString, srpSpecids, null, ProspectConstants.id);
        SObject[] campaignObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.campaignLabelString, true), ProspectConstants.campaignString, campaignAllId, null, ProspectConstants.id);
        SObject[] contactObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.contactLabelString, true), ProspectConstants.contactString, contactAllid, null, ProspectConstants.id);
        SObject[] termObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.termLabelString, false), ProspectConstants.termString, srmTermId, null, ProspectConstants.id);
        SObject[] srpTermObjectList = ProspectUtils.buildAndRunQuery(ProspectUtils.findLeadRouterFieldSetForSObject(ProspectConstants.srptermLabelString, true), ProspectConstants.srptermString, srpTermId, null, ProspectConstants.id);
        
        
        //Query each object supported by lead router using the lead router fieldset in each of the respective objects
        idToAccounts = ProspectUtils.buildMapofRecords(accountObjectList);
        idToSRMPrograms = ProspectUtils.buildMapofRecords(apObjectList);
        idToSRPPrograms = ProspectUtils.buildMapofRecords(srpAPObjectList);
        idToSRMSpecs = ProspectUtils.buildMapofRecords(specObjectList);
        idToSRPSpecs = ProspectUtils.buildMapofRecords(srpSpecObjectList);
        idToCampaign = ProspectUtils.buildMapofRecords(campaignObjectList);
        idToContact = ProspectUtils.buildMapofRecords(contactObjectList);
        idToSRMTerm = ProspectUtils.buildMapofRecords(termObjectList);
        idToSRPTerm = ProspectUtils.buildMapofRecords(srpTermObjectList);
        
        /*
        idToAccounts = new Map<Id, Account>([Select id from Account where Id IN :accountIds]);
        idToSRMPrograms = new Map<Id, Academic_Program__c>([Select Id from Academic_Program__c where Id IN :srmprogramids]);
        idToSRPPrograms = new Map<Id, DeltakSRP__Academic_Program__c>([Select Id from DeltakSRP__Academic_Program__c where Id IN :srpprogramids]);
        idToSRMSpecs = new Map<Id, Academic_Specialization__c>([Select Id from Academic_Specialization__c where Id IN :srmSpecids]);
        idToSRPSpecs = new Map<Id, DeltakSRP__Academic_Specialization__c >( [Select Id from DeltakSRP__Academic_Specialization__c where Id IN : srpSpecids]);
        idToCampaign = new Map<Id, Campaign>([Select Id from Campaign where Id IN:campaignids OR Id in:parentCampaignId ]);
        idToContact = new Map<Id,Contact >([Select Id from Contact where Id IN:srmcontactId OR Id IN:srpcontactId]);
        */
        
        //Query all the rules associated with the accounts in the contect of the opportunity
        List<PRO_Rule__c> rulesList = [Select Id, Academic_Institution__c from PRO_Rule__c where Academic_Institution__c IN :accountIds];
        //Query all the teams associated with the accounts in the context of the opportunity
        List<Team__c> teamList = [Select Id, Team_Account__c, Escalation_Period__c, ESC_Exempt__c, Team_Rule__r.Formula__c,
                                         Team_Order__c, Team_Name__c, Team_Rule__c, Default_Team__c, Allocation_Override__c, Team_Rule__r.Number_of_Rule_Sets__c
                                      from Team__c 
                                    where Team_Account__c IN :accountIds and Active__c = true and Active_Member_Count__c > 0 order by Team_Order__c asc];
                                    
        // Build a list of Rules for each of the accounts in the context of the opportunity
        Map<id, List<PRO_Rule__c>> accountToRules = new Map<id, List<PRO_Rule__c>>();
        for(PRO_Rule__c thisRule : rulesList){
            List<PRO_Rule__c> proRuleListTemp = new List<PRO_Rule__c>();
            if(accountToRules != null && accountToRules.containsKey(thisRule.Academic_Institution__c)){
                proRuleListTemp = accountToRules.get(thisRule.Academic_Institution__c);
            }
            proRuleListTemp.add(thisRule);
            accountToRules.put(thisRule.Academic_Institution__c, proRuleListTemp);
        }
        //Build a list of Teams for each of the accounts in the context of the opportunity
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
        
        //Query for all conditions (rule sets) associated with the Rules that queried within the context of the account and opportunity
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
        
        //The main logic starts here. Until now, we did the preparation by having all the information needed to find the correct team for the opportunity.
        //Loop through each of the opportuntiy in the context. We need to find the correct team for this opportunity
        for(Opportunity opp : opportunitiesInContext){
            //Using the map above, fetch the list of teams for the account in the opportunity
            List<Team__c> teamForAccount = accountToTeams.get(opp.AccountId);
            Team__c defaultTeam = defaultTeamForAccount.get(opp.AccountId);
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
                   SObject record = null;
                    if(thisCondition.Object_API_Name__c == ProspectConstants.campaignLabelString){
                        record = findCorrectObjectForRuleSet(thisCondition.Object_Name__c, opp);
                    }else{
                        record = findCorrectObjectForRuleSet(thisCondition.Object_API_Name__c, opp);
                    }
                    
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
                    //Assign the team to opportunity and break from the Team loop and move on to the next opportunity.
                    //Else, continue and move on to the next team.
                    System.Debug(opp+'-'+thisTeam);
                    returnMap.put(opp, thisTeam);
                    break;
                }else{
                    if(counterVar == teamForAccount.size()-1){
                       System.Debug('Default Team Assignment --- '+ opp+'-'+defaultTeam);
                        returnMap.put(opp, defaultTeam);
                    }
                    //When Rule evaluates to false, it makes sense to evaluate the next team. BUT, if all teams for the account
                    //is echausted and no more team remains to be evaluated for the rule, we need to determine which team should
                    // ge the opportunity.
                    //1, The last team in the order sequence for the Account can get the opportunity
                    //2, One team can exist as the team for the Account that is considered as default. If none of the rule evaluates to true to determine the team, the default team can be the chosen one.
                    //We need to clarify the business and then implement the functionality
                }
                
            counterVar++;
            }
            
    }
        
        
        
        
        return returnMap;
    }
    private static SObject findCorrectObjectForRuleSet(String objectName, Opportunity opp){
        sObject record;
        //Depending on the object referenced in the RuleSet, bring the correct object record within the context to evaluate the individual line item of the rule
        if(objectName== ProspectConstants.accountString && idToAccounts.containsKey(opp.AccountId)){
            record = (sObject) idToAccounts.get(opp.AccountId);
        } else if(objectName== ProspectConstants.programString && idToSRMPrograms.containsKey(opp.Program__c)) {
            record = (sObject) idToSRMPrograms.get(opp.Program__c);
        } else if(objectName== ProspectConstants.srpprogramString && idToSRPPrograms.containsKey(opp.DeltakSRP__Academic_Program__c)) {
            record = (sObject) idToSRPPrograms.get(opp.DeltakSRP__Academic_Program__c);
        } else if(objectName== ProspectConstants.specializationString && idToSRMSpecs.containsKey(opp.Specialization__c)) {
            record = (sObject) idToSRMSpecs.get(opp.Specialization__c);
        } else if(objectName== ProspectConstants.srpspecializationString && idToSRPSpecs.containsKey(opp.DeltakSRP__Academic_Specialization__c)) {
            record = (sObject) idToSRPSpecs.get(opp.DeltakSRP__Academic_Specialization__c);
        }else if(objectName== ProspectConstants.campaignString && idToCampaign.containsKey(opp.Campaignid)) {
            record = (sObject) idToCampaign.get(opp.Campaignid);
        }else if(objectName== ProspectConstants.parentcampaignString && idToCampaign.containsKey(opp.Campaign.parentId)) {
            record = (sObject) idToCampaign.get(opp.Campaign.parentId);
        }else if(objectName== ProspectConstants.contactString) {
            if(opp.Student__c != null && idToContact.containsKey(opp.Student__c)){
                record = (sObject) idToContact.get(opp.Student__c);
            }else if(opp.DeltakSRP__Student__c != null && idToContact.containsKey(opp.DeltakSRP__Student__c)){
                record = (sObject) idToContact.get(opp.DeltakSRP__Student__c);
            }
        }else if(objectName== ProspectConstants.termString){
            record = (sObject) idToSRMTerm.get(opp.Academic_Start_Date__c);
        }else if(objectName== ProspectConstants.srptermString){
            record = (sObject) idToSRPTerm.get(opp.DeltakSRP__Academic_Start_Date__c);
        }else if(objectName== ProspectConstants.opportunityString) {
            record = (sObject)opp;
        }
    
    return record; 
    }
    
    
}