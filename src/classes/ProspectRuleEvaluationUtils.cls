/**
 *  This class a utility clsss to deal with all dynamic tab related utils.
 */
public without sharing class ProspectRuleEvaluationUtils {
    /**
     * Determines the list of supported data types the rules can accomodate
     */
    public static Set<Schema.DisplayType> supportedFieldTypeForRules(){
        /* Supported Field Types START 
            1. Boolean
            2. Date
            3. DateTime
            4. Double
            5. Email
            6. ID
            7. Integer
            8. Reference (Lookup / MD)
            9. String
            10. TextArea
            11. URL
        /* Supported Field Types END **/
        Set<Schema.DisplayType> supportedTypes = new Set<Schema.DisplayType>();
        supportedTypes.add(Schema.DisplayType.Boolean);
        supportedTypes.add(Schema.DisplayType.Date);
        supportedTypes.add(Schema.DisplayType.DateTime);
        supportedTypes.add(Schema.DisplayType.Double);
        supportedTypes.add(Schema.DisplayType.Email);
        supportedTypes.add(Schema.DisplayType.ID);
        supportedTypes.add(Schema.DisplayType.Integer);
        supportedTypes.add(Schema.DisplayType.Reference);
        supportedTypes.add(Schema.DisplayType.String);
        supportedTypes.add(Schema.DisplayType.TextArea);
        supportedTypes.add(Schema.DisplayType.URL);
        supportedTypes.add(Schema.DisplayType.Phone);
        supportedTypes.add(Schema.DisplayType.PickList);
        return supportedTypes;
    }
    
    /**
     * From the list of rule sets and the Sobject record from the parameters, the method computes the logic based on the associated formula
     * and returns a map that determines which formula record evaluates to true versus false.
     */
    public static Map<Id, Boolean> findFormulaToRender(List<PRO_Rule_Set__c> conditionList, Sobject record){
        String namespace = '';
        
        Map<Id, Boolean> formulaToRender = new Map<Id, Boolean>();
        Map<Id, List<PRO_Rule_Set__c>> formulaToConditions = new Map<id, List<PRO_Rule_Set__c>>();
        Map<Integer, Boolean> sequenceToBoolean = new Map<Integer, Boolean>();
        Map<Id, String> formulaToType = new Map<id, String>();
        Map<Id, String> idToFormula = new Map<Id, String>();
        String formula = '';
        System.Debug('conditionList -- '+conditionList);
        
        for(PRO_Rule_Set__c thisCondition : conditionList) {
            formula = thisCondition.Rule__r.Formula__c;
            List<PRO_Rule_Set__c> tmp_conditionList = new List<PRO_Rule_Set__c>();
            if(formulaToConditions != null && formulaToConditions.containsKey(thisCondition.Rule__c)){
                tmp_conditionList = formulaToConditions.get(thisCondition.Rule__c);
            }
            tmp_conditionList.add(thisCondition);
            formulaToConditions.put(thisCondition.Rule__c, tmp_conditionList);
            idToFormula.put(thisCondition.Rule__c, thisCondition.Rule__r.Formula__c);
        }
        
        System.Debug('formulaToConditions -- '+formulaToConditions);
        
        for(Id thisFormula : formulaToConditions.keyset()) {
            formula = idToFormula.get(thisFormula);
            for(PRO_Rule_Set__c thisCondition : formulaToConditions.get(thisFormula)){
                Schema.DisplayType thisFieldType = findFieldType(namespace, thisCondition.Object_API_Name__c, thisCondition.Field_Name__c);
                Boolean formulaEval  = (ProspectRuleEvaluationUtils.comparison(record.get(thisCondition.Field_Name__c), thisCondition.Value__c, thisCondition.Operator__c, thisFieldType));
                sequenceToBoolean.put(Integer.valueOf(thisCondition.Sequence__c), formulaEval);
            }
            
            /** THE FOLLOWING APPLIES FOR COMPLEX IMPLEMENTATION START **/
            System.Debug('formula -- '+formula);
            System.Debug('sequenceToBoolean -- '+sequenceToBoolean);
            List<Integer> sequenceIntegerList = new List<Integer>(sequenceToBoolean.keySet());
            // Just a plain replace will cause issue. it will replace 11 as truetrue when replacing 1 with true.
            // Sorting the sequence and going backwards will replace 11 with true and will replace 1 with true correctly.
            sequenceIntegerList.sort();
            for(Integer i=sequenceIntegerList.size()-1; i>= 0 ;i--){
                Integer thisSeq = sequenceIntegerList.get(i);
                System.Debug('thisSeq -- '+thisSeq);
                System.Debug('String.valueOf(sequenceToBoolean.get(thisSeq)) -- '+String.valueOf(sequenceToBoolean.get(thisSeq)));
                System.Debug('formula -- '+formula);
                formula = formula.replace(String.valueOf(thisSeq), String.valueOf(sequenceToBoolean.get(thisSeq)));
            }
            /*for(Integer thisSeq : sequenceToBoolean.keySet()){
                formula = formula.replace(String.valueOf(thisSeq), String.valueOf(sequenceToBoolean.get(thisSeq)));
            }*/
            String stringresult = ProspectRuleEvaluationUtils.evaluateLogicalExpression(formula);
            System.Debug('stringresult -- '+stringresult);
            formulaToRender.put(thisFormula,Boolean.valueOf(stringresult));
            /** THE FOLLOWING APPLIES FOR COMPLEX IMPLEMENTATION END**/ 
        }
        
        return formulaToRender;
    }
    
    /*
    Based on the value from the parameter, the method find the type of the field associated with the Object in the input parameter
    */
    public static Schema.DisplayType findFieldType(String namespace, String objectName, String fieldName){
        String apiNameOfObject = ((namespace != null && namespace != '')?namespace:'')+objectName.tolowercase();
        Map<String, Schema.SObjectType> sObjectsByType = new Map<String,Schema.SobjectType>();
        
        Map<String,Schema.SObjectType> sObjectsByLocalName = Schema.getGlobalDescribe();
        System.Debug('### sObjectsByLocalName: ' + sObjectsByLocalName);
        System.Debug('### namespace: ' + namespace);
        
        if(namespace != null){
            for(String k : sObjectsByLocalName.keySet()){
                 String nKey = '';
                nkey = k;
               sObjectsByType.put(nKey,sObjectsByLocalName.get(k));
            }
        }else{
            sObjectsByType = sObjectsByLocalName;
        }
            Schema.SObjectType sObjectType = sObjectsByType.get(apiNameOfObject.trim()); 
            //Schema.SObjectType sObjectType = sObjectsByType.get(objectName.tolowercase()); 
            System.Debug('### apiNameOfObject: ' + apiNameOfObject);
            System.Debug('### sObjectsByType: ' + sObjectsByType);
            System.Debug('### sObjectType: ' +  sObjectType);
            Map<String, Schema.SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap();
        
            System.Debug('condition.Field_Name__c -- '+fieldName);
            Schema.SObjectField thisField = sObjectFields.get(fieldName);
            if(thisField != null){
                return thisField.getDescribe().getType();
            }
        return null;
    }
    
    /* CONDITIONAL TABS START */
    /*
    The method compares lhs with rhs based on the comparison operator for the field type. It identifies text, number, date and datetime and handles
    the comparison accordingly.
    */
    public static Boolean comparison(Object lhs, String rhs , String comparison, Schema.DisplayType fieldType){
        System.Debug(' fieldType -- '+ fieldType);
        System.Debug('lhs -- '+lhs);
        System.Debug('rhs -- '+rhs);
        System.Debug('comparison -- '+comparison);
        
        if(lhs == null && rhs == ''){
            return true;
        }
        if(lhs == null && rhs != null){
            return false;
        }
        Boolean returnValue = false;
        
        Date d = null;
        Datetime t = null;
        if(fieldType == Schema.DisplayType.Date){
            d = Date.valueOf(lhs);
        }
        if(fieldType == Schema.DisplayType.DateTime){
            t = DateTime.valueOf(lhs);
        }
        
        // String Comparison START
        if(comparison == ProspectConstants.COMPARISON_TYPE_EQUAL){
            
            if(fieldType == Schema.DisplayType.Double){
                if((Decimal)lhs == Decimal.valueOf(rhs) ){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d == Date.valueOf(rhs)){
                    returnValue = true;
                }
            }
            else if(fieldType == Schema.DisplayType.DateTime){
                if(t == Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }
            else{
                if(String.valueOf(lhs) == rhs){
                    returnValue = true;
                }
            }
        }
        
        if(comparison == ProspectConstants.COMPARISON_TYPE_CONTAINS){
            System.Debug(ProspectConstants.COMPARISON_TYPE_CONTAINS);
            if((((String)lhs).tolowercase()).contains(rhs.tolowercase())){
                returnValue = true;
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_DNC){
            System.Debug(ProspectConstants.COMPARISON_TYPE_DNC);
            if(!((String)lhs).contains(rhs)){
                returnValue = true;
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_NOT_EQUAL){
            System.Debug(ProspectConstants.COMPARISON_TYPE_NOT_EQUAL);
            if(fieldType == Schema.DisplayType.Double){
                if((Decimal)lhs != Decimal.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d != Date.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.DateTime){
                if(t != Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }else{
                if(String.valueOf(lhs) != rhs){
                    returnValue = true;
                }
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_SW){
            System.Debug(ProspectConstants.COMPARISON_TYPE_SW);
            if((((String)lhs).tolowercase()).startsWith(rhs.tolowercase())){
                returnValue = true;
            }
        }
        // String Comparison END
        // Number Comparison START
        if(comparison == ProspectConstants.COMPARISON_TYPE_GT){
            System.Debug(ProspectConstants.COMPARISON_TYPE_GT);
            if(fieldType == Schema.DisplayType.Double){
                if((Decimal)lhs > Decimal.valueOf(rhs)){
                    returnValue = true; 
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d > Date.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.DateTime){
                if(t > Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_GTE){
            System.Debug(ProspectConstants.COMPARISON_TYPE_GTE);
            if(fieldType == Schema.DisplayType.Double){
                if((Decimal)lhs >= Decimal.valueOf(rhs) ){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d >= Date.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.DateTime){
                if(t >= Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_LT){
            System.Debug(ProspectConstants.COMPARISON_TYPE_LT);
            if(fieldType == Schema.DisplayType.Double){
                if( (Decimal)lhs < Decimal.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d < Date.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.DateTime){
                if(t < Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }
        }
        if(comparison == ProspectConstants.COMPARISON_TYPE_LTE){
            System.Debug(ProspectConstants.COMPARISON_TYPE_LTE);
            if(fieldType == Schema.DisplayType.Double){
                if((Decimal)lhs <= Decimal.valueOf(rhs) ){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.Date){
                if(d <= Date.valueOf(rhs)){
                    returnValue = true;
                }
            }else if(fieldType == Schema.DisplayType.DateTime){
                if(t <= Datetime.valueOf(rhs)){
                    returnValue = true;
                }
            }
        }
        
        // Number Comparison END
        return returnValue;
    }
    
    /* CONDITIONAL TABS END */
    /*
    A recursive method that evaluates an expression to true or false. The method accepts the input in the following format:
    (AND, true, false, (OR, TRUE, FALSE, (AND, false, true))). It is recursive and hence you can provide any number of logics within.
    */
    public static String evaluateLogicalExpression(String input) {
        String regex = '^.*(\\(([^\\)]+)\\)).*$';
        input = input.trim().replaceAll('(\\s+)', '').trim();
        
        Matcher m = Pattern.compile(regex).matcher(input);
        if(m.matches() && m.groupCount() > 1) 
        {
           String orig = m.group(m.groupCount()-1);
           List<String> ls = orig.trim().replace('(','').replace(')','').trim().replaceAll('(\\s+)', '').split(',');
           if(ls != null && ls.size() > 2){   
               String lastresult = ls[1];
               if(ls[0].trim() == 'OR'){
                   for(Integer i=2; i<ls.size();i++){
                       if(lastresult == 'false' && ls[i].trim().toLowerCase() == 'false'){
                           lastresult = 'false';
                       }
                       else{
                           lastresult = 'true';
                           break;
                       }
                   }
                   return evaluateLogicalExpression(input.replace(orig,lastresult));
               }
               else if (ls[0].trim() == 'AND'){
                   for(Integer i=2; i<ls.size();i++){
                      if(lastresult == 'true' && ls[i].trim().toLowerCase() == 'true'){
                           lastresult = 'true';
                       }
                       else{
                           lastresult = 'false';
                           break;
                       }
                    }
                   return evaluateLogicalExpression(input.replace(orig,lastresult));
                  }
               else if (ls[0].trim() == 'IF'){
                   if(evaluateLogicalExpression(ls[1].trim()) == 'true'){
                       return evaluateLogicalExpression(ls[2]);
                   }
                   else{
                       return evaluateLogicalExpression(ls[3]);
                   }
               }
               else{
                   return input;
               }
              }
           else{
               return input;
           }
        }
        else{
            return input;
        }
    }
}