/**
The class handles the biz logic when a rule or rule set is inserted or updated
**/
public without sharing class ProspectRulesHandler {
    
    public static void doBeforeInsertRule(List<PRO_Rule__c> conditionalTabFormulaList){
        validateRules(conditionalTabFormulaList);
    }
    
    public static void doBeforeUpdateRule(List<PRO_Rule__c> conditionalTabFormulaList){
        validateRules(conditionalTabFormulaList);
    }
    
    public static void doBeforeInsertRuleSet(List<PRO_Rule_Set__c> conditionalTabConditionList){
        validateRuleSets(conditionalTabConditionList);
        validateRuleSetSequence(conditionalTabConditionList);
    }
    
    public static void doBeforeUpdateRuleSet(List<PRO_Rule_Set__c> conditionalTabConditionList){
        validateRuleSets(conditionalTabConditionList);
        validateRuleSetSequence(conditionalTabConditionList);
    }
    
    private static void validateRuleSetSequence(List<PRO_Rule_Set__c> conditionalTabConditionList){
        List<Id> rulesList = new List<Id>();
        List<Id> thisRuleSetIDList = new List<Id>();
        for(PRO_Rule_Set__c thisRuleset : conditionalTabConditionList ){
            rulesList.add(thisRuleset.Rule__c);
            thisRuleSetIDList.add(thisRuleset.id);
        }
        List<PRO_Rule_Set__c> siblingSets = [Select Id, Sequence__c, Rule__c from PRO_Rule_Set__c where Rule__c IN :rulesList and Id Not IN :thisRuleSetIDList];
        Map<Id, Set<Decimal>> formulaToSequenceSet = new Map<Id, Set<Decimal>>();
        for(PRO_Rule_Set__c thisSibling : siblingSets){
            Set<Decimal> sequenceSet = new Set<Decimal>();
            if(formulaToSequenceSet.containsKey(thisSibling.Rule__c)){
                sequenceSet = formulaToSequenceSet.get(thisSibling.Rule__c);
            }
            sequenceSet.add(thisSibling.Sequence__c);
            formulaToSequenceSet.put(thisSibling.Rule__c, sequenceSet);
        }
        for(PRO_Rule_Set__c thisRuleset : conditionalTabConditionList ){
            Set<Decimal> sequenceSetForThisFormula = formulaToSequenceSet.get(thisRuleset.Rule__c);
            List<Decimal> sequenceList = new List<Decimal>(sequenceSetForThisFormula);
            sequenceList.sort();
            if(sequenceSetForThisFormula != null){
                if(sequenceSetForThisFormula.contains(thisRuleset.Sequence__c)){
                    thisRuleset.addError('Next available Sequence No is: ' +(sequenceList[sequenceList.size()-1]+1));
                }
            }
        }
        
    }
    
    /**
     * Purpose - Ensures valid rule set when the user inserts?
     */
    private static void validateRuleSets(List<PRO_Rule_Set__c> conditionalTabConditionList){
        String namespace = '';
        Map<String, Schema.SObjectType> sObjectsByType = new Map<String,Schema.SobjectType>();
        Map<String,Schema.SObjectType> sObjectsByLocalName = Schema.getGlobalDescribe();
        System.Debug('sObjectsByLocalName -- '+sObjectsByLocalName);
        
        if(namespace != null){
            for(String k : sObjectsByLocalName.keySet()){
                 String nKey = '';
                nkey = k;
               sObjectsByType.put(nKey,sObjectsByLocalName.get(k));
              
            }
        }else{
            sObjectsByType = sObjectsByLocalName;
        }
        Set<Schema.DisplayType> supportedTypes = ProspectRuleEvaluationUtils.supportedFieldTypeForRules();
        
        for(PRO_Rule_Set__c condition : conditionalTabConditionList){
            String apiNameOfObject = namespace + condition.Object_API_Name__c.tolowercase();
            System.debug('apiNameOfObject-->'+apiNameOfObject);
            Schema.SObjectType sObjectType = sObjectsByType.get(apiNameOfObject); 
            Map<String, Schema.SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap();
            System.debug('Map sObjectFields--'+sObjectFields);
        	
            System.Debug('condition.Field_Name__c -- '+condition.Field_Name__c);
            Schema.SObjectField thisField = sObjectFields.get(condition.Field_Name__c);
            if(thisField != null){
                if(!supportedTypes.contains(thisField.getDescribe().getType())){
                    condition.addError('Unsupported field type');//
                }else{
                    if(thisField.getDescribe().getType() == Schema.DisplayType.Boolean){
                        if(!(condition.Value__c.equalsIgnoreCase('true') || condition.Value__c.equalsIgnoreCase('false'))){
                            condition.addError('The value entered is not boolean value');//Not_Boolean_Error
                        }
                    }
                    if(thisField.getDescribe().getType() == Schema.DisplayType.Date){
                        try{
                            Date d = Date.valueOf(condition.Value__c);
                        }catch(Exception e){
                            condition.addError('The value entered is not a date; Please add date in yyyy-mm-dd format.');//Not_Date_Error
                        }
                    }
                    if(thisField.getDescribe().getType() == Schema.DisplayType.DateTime){
                        try{
                            DateTime d = DateTime.valueOf(condition.Value__c);
                        }catch(Exception e){
                            condition.addError('The value entered is not date time; Please add date in yyyy-mm-dd hh:mm:ss format.');//Not_DateTime_Error
                        }
                    }
                    if(thisField.getDescribe().getType() == Schema.DisplayType.Double){
                        try{
                            Double d = Double.valueOf(condition.Value__c);
                        }catch(Exception e){
                            condition.addError('The value entered is not a valid number');//Not_Decimal_Error
                        }
                    }
                    if(thisField.getDescribe().getType() == Schema.DisplayType.Integer){
                        try{
                            Integer d = Integer.valueOf(condition.Value__c);
                        }catch(Exception e){
                            condition.addError('The value entered is not a valid number');//Not_Number_Error
                        }
                    }
                    if(thisField.getDescribe().getType() == Schema.DisplayType.Email ||
                      thisField.getDescribe().getType() == Schema.DisplayType.String ||
                      thisField.getDescribe().getType() == Schema.DisplayType.TextArea ||
                      thisField.getDescribe().getType() == Schema.DisplayType.URL ||
                      thisField.getDescribe().getType() == Schema.DisplayType.Phone ||
                      thisField.getDescribe().getType() == Schema.DisplayType.PickList
                      ){
                        try{
                            String s = String.valueOf(condition.Value__c);
                        }catch(Exception e){
                            condition.addError('The value enteres is not a vald text');//Not_Text_Error
                        }
                      }
                   if(thisField.getDescribe().getType() == Schema.DisplayType.ID ||
                      thisField.getDescribe().getType() == Schema.DisplayType.Reference){
                        if(!(condition.Value__c instanceof ID)){
                            condition.addError('The value entered is not a valid ID');  //Not_ID_Error
                        }
                      }
                }
            }else{
                condition.addError('The field entered does not exist');
            }
        }
       
    }
    

    
    /**
     * Purpose - Ensures valid rule when the user creates rule
     */
    private static void validateRules(List<PRO_Rule__c> conditionalTabFormulaList){
        Map<Id, PRO_Rule__c> idToFormula = new Map<id, PRO_Rule__c>();
        for(PRO_Rule__c thisFormula : conditionalTabFormulaList){
            if(thisFormula.Formula__c != null && thisFormula.Formula__c != ''){
                idToFormula.put(thisFormula.Id, thisFormula);
            }
        }
        List<PRO_Rule_Set__c> conditionsList = [Select Id, Sequence__c, Rule__c from PRO_Rule_Set__c where Rule__c IN :idToFormula.keySet()];
        
        Map<Id, List<Integer>> formulaToSequence = new Map<Id, List<Integer>>(); 
        for(PRO_Rule_Set__c thisCondition : conditionsList){
            List<Integer> sequenceList = new List<Integer>();
            if(formulaToSequence.containsKey(thisCondition.Rule__c)){
                sequenceList = formulaToSequence.get(thisCondition.Rule__c);
            }
            sequenceList.add(Integer.valueOf(thisCondition.Sequence__c));
            formulaToSequence.put(thisCondition.Rule__c, sequenceList);
        }
        for(PRO_Rule__c thisFormula : conditionalTabFormulaList){
            if(idToFormula != null && idToFormula.containsKey(thisFormula.id)){
            	String thisFormulaString = thisFormula.Formula__c;
                List<Integer> sequenceList = formulaToSequence.get(thisFormula.Id);
                sequenceList.sort();
                /*if(sequenceList == null){
                    thisFormula.addError(System.Label.Condition_Required_First); //Condition_Required_First
                }else{*/
                    if(sequenceList != null){
	                    for(Integer i=sequenceList.size()-1; i>=0; i--){
	                       Integer thisNumber = sequenceList[i];  
	                        thisFormulaString = thisFormulaString.replace(String.valueOf(thisNumber), String.valueOf('true'));
	                    }
	                    String evaluatedString = 'true';
	                    if(thisFormulaString.containsAny('0123456789'))
	                    {
	                    	evaluatedString = 'false';
	                    }else
	                    {
	                    	evaluatedString = ProspectRuleEvaluationUtils.evaluateLogicalExpression(thisFormulaString);
	                    }
	                    if(!('true'.equals(evaluatedString))){
	                        thisFormula.addError('The formula entered is not valid'); //Not_Valid_Formula
	                    }
                    }
                //}
            }
        }
    }
}