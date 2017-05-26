//Girija: SRP-2232

global without sharing class batchJobAdvisorEC implements  Database.Batchable<Sobject>{
    global String Query = 'Select id, RecordID__c, Custom_Property_1__c, Custom_Property_2__c, Custom_Property_3__c, Custom_Property_4__c, Custom_Property_5__c, Custom_Property_6__c, Custom_Property_7__c, Custom_Property_8__c, Custom_Property_9__c, Custom_Property_10__c from Batch_Job__c where RecordType.Name = \'ECSSC\'';
    public Map<String, List<Field_Mapping__c>> objTypeToFields = null;
    Set<String> srcSObjectSet = new Set<String>();
    global Map<String, Integer> targetObjectNameToCount = new Map<String, Integer>();
    global batchJobAdvisorEC(){
        
    }
    global batchJobAdvisorEC(String query)
    {
    	this.Query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        
        if(scope != null && scope.size() > 0){
	        List<Field_Mapping__c> fm = Field_Mapping__c.getall().values();
	        system.debug('fld mapping -->>'+fm);
	        objTypeToFields = new Map<String, List<Field_Mapping__c>>();
	        for(Field_Mapping__c fieldMapping : fm){
	            List<Field_Mapping__c> thisObjFmList = new List<Field_Mapping__c>();
	            if(objTypeToFields.containsKey(fieldMapping.Target_Object__c)){
	                thisObjFmList = objTypeToFields.get(fieldMapping.Target_Object__c);
	            }
	            thisObjFmList.add(fieldMapping);
	            objTypeToFields.put(fieldMapping.Target_Object__c, thisObjFmList);
	        }
	        system.debug('objTypeToFields-->>'+objTypeToFields);
	        
	        List<SObject> objectListToUpdate = new List<SObject>();
	        for(SObject thisSObject : scope){
	             Id thisObjId = (Id)thisSObject.get('RecordID__c');
	             String sobjectAPIName = (thisObjId).getSObjectType().getDescribe().getName(); // Get the API object name of the ID
	             if(targetObjectNameToCount != null && targetObjectNameToCount.containsKey(sobjectAPIName)){
	                targetObjectNameToCount.put(sobjectAPIName, targetObjectNameToCount.get(sobjectAPIName)+1);
	             }else{
	                targetObjectNameToCount.put(sobjectAPIName,1);
	             }
	             
	             Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectAPIName); // Get the SObjectType for the object
	             system.debug('targetType-->>'+targetType);
	             SObject targetObj = targetType.newSObject();  // Get the SObject
	             if(objTypeToFields  != null && objTypeToFields.containsKey(sobjectAPIName)){
	                 List<Field_Mapping__c> fieldsList = objTypeToFields.get(sobjectAPIName);
	                 for(Field_Mapping__c thisField : fieldsList){
	                    srcSObjectSet.add(thisField.Source_Object__c);
	                    system.debug('srcSObjectSet-->>'+srcSObjectSet);
	                    String srcValue = (String)thisSObject.get(thisField.Source_Field__c);
	                    system.debug('srcValue-->>'+srcValue);
	                   
	                    if(srcValue == null || srcValue == '' && thisField.blank_update__c == false)
	                        continue;
	                        targetObj.put(thisField.Target_Field__c, constructValue(srcValue, thisField.Target_Field_Type__c ));
	                 }
	                objectListToUpdate.add(targetObj); 
	             }else{
	                continue;
	             }
	        }
	        System.debug('targetObjectNameToCount ---'+targetObjectNameToCount);
	        System.Debug('objectListToUpdate -- '+objectListToUpdate);
	        if(objectListToUpdate != null && objectListToUpdate.size() > 0){
	            Database.update( objectListToUpdate, false);
	        }
	        
	        List<RecordType> recordTypeList = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Batch_Job__c' and r.Name = 'Log' limit 1];
	        Batch_Job__c bj = new Batch_Job__c();
	        String comments = '';
	        for(String objName : targetObjectNameToCount.keySet()){
	            comments = comments + objName + ':' + ' ' + String.valueOf(targetObjectNameToCount.get(objName));
	            comments = comments + '\n';
	        }
	        bj.comments__c = comments;
	        bj.RecordTypeId = recordTypeList[0].Id;
	        
	        insert bj;
	        
	        delete scope;
	        
	    }
        
    }
    private Object constructValue(String fieldValue, String fieldType){
        if(fieldValue == 'null')
        	return null;
        if(fieldType == 'Date'){
            return  (fieldvalue != null ? Date.valueOf(fieldValue + ' 00:00:00') : null);
        }else if(fieldType == 'Datetime'){
            return  (fieldValue != null ? Datetime.valueOf(fieldvalue) : null);
        }
        return fieldvalue;
    }
    global void finish(Database.BatchableContext BC){
        
        
        
    }
    
    
}