public without sharing class ProspectUtils {

    public static Map<Id, SObject> buildMapofRecords(List<Sobject> sobjectList){
        
        Map<Id, SObject> returnMap = new Map<id, SObject>();
        if(sObjectList != null){
            for(SObject thisSObject : sobjectList){
                returnMap.put((Id)thisSobject.get('Id'), thisSObject);
            }
        }
        return returnMap;
    }
    
    public static List<Id> constructFinalListSObject(List<Id> list1, List<Id> list2){
        List<Id> returnList = new List<Id>();
        returnList.addAll(list1);
        returnList.addAll(list2);
        return returnList;
    }
    
    public static Map<String,String> getFieldMap(String chosenObj, Boolean isSRP) {
    Map<String,String> fieldAPILabelMap = new Map<String,String>();
    
    List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
    fieldSetMembers = getFields(chosenObj, isSRP);
    
    for(Schema.FieldSetMember f : fieldSetMembers)
    {
        fieldAPILabelMap.put(f.getFieldPath(), f.getLabel());
    }
    
    return fieldAPILabelMap;
    }
    
    
    
    
    public static List<Schema.FieldSetMember> getFields(String chosenObj, Boolean isSRP) {
        if(chosenObj==ProspectConstants.programLabelString && !isSRP)
        {
            return SObjectType.Academic_Program__c.FieldSets.PRO_Programs.getFields();
        }
        else if(chosenObj==ProspectConstants.srpprogramLabelString && isSRP)
        {
            return SObjectType.DeltakSRP__Academic_Program__c.FieldSets.PRO_DeltakSRP_Program.getFields();
        }
        else if(chosenObj==ProspectConstants.srpspecializationLabelString && isSRP)
        {
            return SObjectType.DeltakSRP__Academic_Specialization__c.FieldSets.PRO_DeltakSRP_Specialization.getFields(); 
        }
        else if(chosenObj==ProspectConstants.specializationLabelString && !isSRP)
        {
            return SObjectType.Academic_Specialization__c.FieldSets.PRO_Specializations.getFields();
        }
        else if(chosenObj==ProspectConstants.accountString && !isSRP)
        {
            return SObjectType.Account.FieldSets.PRO_Accounts.getFields();
        }
        else if(chosenObj==ProspectConstants.contactLabelString && !isSRP)
        {
            return SObjectType.Contact.FieldSets.PRO_Affiliations.getFields();
        }
        else if(chosenObj==ProspectConstants.campaignLabelString && !isSRP)
        {
            return SObjectType.Campaign.FieldSets.PRO_Campaigns.getFields();
        }
        else if(chosenObj==ProspectConstants.opportunityString && !isSRP)
        {
            return SObjectType.Opportunity.FieldSets.PRO_Opportunities.getFields();
        }
        else if(chosenObj==ProspectConstants.termLabelString && !isSRP)
        {   
            return SObjectType.Academic_Start_Date__c.FieldSets.PRO_Terms.getFields();
        }
        else if(chosenObj==ProspectConstants.srptermLabelString && isSRP)
        {
            return SObjectType.DeltakSRP__Academic_Start_Date__c.FieldSets.PRO_DeltakSRP_Term.getFields();
        }
        else if(chosenObj==ProspectConstants.parentcampaignString && !isSRP)
        {
            return SObjectType.Campaign.FieldSets.PRO_Campaigns.getFields();
        }
        else if(chosenObj==ProspectConstants.accountString && isSRP)
        {
            return SObjectType.Account.FieldSets.PRO_DeltakSRP_Account.getFields();
        }
        else if(chosenObj==ProspectConstants.contactLabelString && isSRP)
        {
            return SObjectType.Contact.FieldSets.PRO_DeltakSRP_Affiliation.getFields();
        }
        else if(chosenObj==ProspectConstants.campaignLabelString && isSRP)
        {
            return SObjectType.Campaign.FieldSets.PRO_DeltakSRP_Campaign.getFields();
        }
        else if(chosenObj==ProspectConstants.opportunityString && isSRP)
        {
            return SObjectType.Opportunity.FieldSets.PRO_DeltakSRP_Opportunity.getFields(); 
        }
        else if(chosenObj==ProspectConstants.parentcampaignString && isSRP)
        {
            return SObjectType.Campaign.FieldSets.PRO_DeltakSRP_Campaign.getFields();
        }
        else if(chosenObj == ProspectConstants.caseString && isSRP)
        {
        	return SObjectType.Case.FieldSets.PRO_DeltakSRP_Case.getFields();
        }
        else if(chosenObj == ProspectConstants.caseString && !isSRP)
        {
        	return SObjectType.Case.FieldSets.PRO_DeltakSRP_Case.getFields();
        }
        
        
        return null;
    }
    
    public static Boolean isSRPObject(String chosenObj)
    {
        if(chosenObj==ProspectConstants.programLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.srpprogramLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.srpspecializationLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.specializationLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.accountString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.contactLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.campaignLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.opportunityString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.termLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.srptermLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.parentcampaignString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.caseString){
        	return true;
        }
        return null;
    }
    
    public static Boolean isSRMObject(String chosenObj)
    {
        if(chosenObj==ProspectConstants.programLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.srpprogramLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.srpspecializationLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.specializationLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.accountString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.contactLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.campaignLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.opportunityString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.termLabelString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.srptermLabelString)
        {
            return false;
        }
        else if(chosenObj==ProspectConstants.parentcampaignString)
        {
            return true;
        }
        else if(chosenObj==ProspectConstants.caseString){
        	return true;
        }
        return null;
    }
    
    public static String getObjectAPIName(String chosenObj)
    {
        if(chosenObj==ProspectConstants.programLabelString)
        {
            return ProspectConstants.programString;
        }
        else if(chosenObj==ProspectConstants.srpprogramLabelString)
        {
            return ProspectConstants.srpprogramString;
        }
        else if(chosenObj==ProspectConstants.srpspecializationLabelString)
        {
            return ProspectConstants.srpspecializationString;
        }
        else if(chosenObj==ProspectConstants.specializationLabelString)
        {
            return ProspectConstants.specializationString;
        }
        else if(chosenObj==ProspectConstants.accountString)
        {
            return ProspectConstants.accountString;
        }
        else if(chosenObj==ProspectConstants.contactLabelString)
        {
            return ProspectConstants.contactString;
        }
        else if(chosenObj==ProspectConstants.campaignLabelString)
        {
            return ProspectConstants.campaignString;
        }
        else if(chosenObj==ProspectConstants.opportunityString)
        {
            return ProspectConstants.opportunityString;
        }
        else if(chosenObj==ProspectConstants.termLabelString)
        {
            return ProspectConstants.termString;
        }
        else if(chosenObj==ProspectConstants.srptermLabelString)
        {
            return ProspectConstants.srptermString;
        }
        else if(chosenObj==ProspectConstants.parentcampaignString)
        {
            return ProspectConstants.campaignString;
        }
        else if(chosenObj==ProspectConstants.caseString){
        	return ProspectConstants.caseString;
        }
        return null;
    }
    
    public static Boolean getAccountType(Id accountId)
     {
        Boolean accSRP = false;
        
        for(Account acc: [SELECT Id, RecordType.DeveloperName From Account WHERE id = :accountId])
        {
            if(acc.RecordType.DeveloperName=='SRP_Account')
            {
                accSRP = true;
            }
        }

        return accSRP;
     }
     
     public static Id getAccountOwner(Id accountId)
     {
        Id accOwner = null;
        
        for(Account acc: [SELECT Id, OwnerId From Account WHERE id = :accountId])
        {
            accOwner = acc.OwnerId;
        }

        return accOwner;
     }
     
     
     public static List<Team__c> getTeamDetails(Id accountId)
     {
        List<Team__c> teamNames = new List<Team__c>([SELECT t.allocation_override__c, t.Team_Name__c, t.Team_Account__r.Name, t.Name, t.Id, t.Team_Order__c, Default_Team__c FROM Team__c t WHERE Team_Account__c = :accountId and t.Active__c = true ORDER BY t.Team_Order__c]);
        return teamNames;   
     }
    
    public static Set<String> findLeadRouterFieldSetForSObject(String chosenObj, boolean isSRP){
        List<Schema.FieldSetMember> fieldSets  = getFields(chosenObj, isSRP);
        Set<String> returnSet = buildFieldSetList(fieldSets);
        return returnSet;
    }
    
    public static Set<String> buildFieldSetList(List<Schema.FieldSetMember> fieldSets){
        Set<String> returnSet = new Set<String>();
        for(Schema.FieldSetMember thisFieldSetMember : fieldSets){
            returnSet.add(thisFieldSetMember.getFieldPath());
        }
        
        return returnSet;
    }
    
    public static SObject[] buildAndRunQuery(Set<String> fieldNames, String SObjectName, List<id> whereclauseIds, String whereClauseDate, String whereFieldName ){
       System.Debug('SObjectName -- '+SObjectName);
       System.Debug('fieldNames -- '+fieldNames);
       System.Debug('whereclauseIds -- '+whereclauseIds);
       System.Debug('whereClauseDate -- '+whereClauseDate);
       System.Debug('whereFieldName --'+whereFieldName);
        if(fieldNames == null || fieldNames.size() == 0 || whereClauseIds == null || whereClauseIds.size() == 0){
            return null;
        }
        Set<Id> whereClauseSet = null;
 
        if(whereClauseIds != null){
            whereClauseSet = new Set<Id>(whereclauseIds);
        }
            
        List<String> modifiedWhereClauseIds = new List<String>();
        List<String> thisFields = new List<String>(fieldNames);
        String query = '';
        query = query + 'Select ';
        for(Integer i = 0; i < thisFields.size(); i++){
            query = query + thisFields.get(i) + ' ';
            if(i != fieldNames.size()-1){
                query = query + ',';
            }
        }
        query = query + ' From ' + SobjectName + ' ';
        
        if(whereClauseSet != null && whereClauseSet.size() > 0){
            for(String str : whereClauseSet)
            {
             if(str != null && str != 'null' && str != '' && str instanceof ID){
                System.Debug('thisSTR -- '+str);
                modifiedWhereClauseIds.add( '\'' + str + '\'') ;
             }
             
            }
 
        System.Debug(modifiedWhereClauseIds);
            query = query + ' where ' + whereFieldName + ' IN '+ modifiedWhereClauseIds;
            //query = query + ' where ' + whereFieldName + ' IN  :modifiedWhereClauseIds';
        }else if(whereClauseDate != null){
            query = query + ' where '+ whereFieldName +' > '+whereClauseDate;
        }
        System.debug('query --> '+query); 
        SObject[] runQuery = Database.query(query);
        return runQuery;
    }
    public static Map<Opportunity, Team__c> combineTwoMaps(Map<Opportunity, Team__c> fromMap, Map<Opportunity, Team__c> returnMap){
        for(Opportunity thisOppty : fromMap.keySet()){
            returnMap.put(thisOppty, fromMap.get(thisOppty));
        }
        return returnMap;
    }
    public static Map<Case, Team__c> combineTwoMaps(Map<Case, Team__c> fromMap, Map<Case, Team__c> returnMap){
        for(Case thisOppty : fromMap.keySet()){
            returnMap.put(thisOppty, fromMap.get(thisOppty));
        }
        return returnMap;
    }

}