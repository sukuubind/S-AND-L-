public with sharing class EloquaUtils {
    public static boolean isActivityAcceptable(ELQA_Marketing_Activity__c elqa){
        if(elqa != null){
            if(elqa.Contact__c != null){
                return false;
            }else if(elqa.Person__c == null){
                return true;
            }else{
                return true;
            }
        }
        return false;
    }
    public static Boolean isUnsubscribe(String subject){
    	Boolean returnValue = false;
    	String unsubscribe = 'Unsubscribe: '; 
    	 if(subject != null && subject != '' && subject.startsWith(unsubscribe)){
    	 	returnValue = true;
    	 }  
    	return returnValue;
    }
     public static Boolean isLossSurveyResults(String subject){
    	Boolean returnValue = false;
    	String lossSurveyResults = 'LossSurvey: ';
    	 if(subject != null && subject != '' && subject.startsWith(lossSurveyResults)){
    	 	returnValue = true;
    	 }  
    	return returnValue;
    }
    public static String getFederalSchoolCode(String subject){
        String emailSent = 'EmailSent: ';
        String unsubscribe = 'Unsubscribe: '; 
        String lossSurveyResults = 'LossSurvey: '; 
        String fed_SchoolCode = '';
        try{
            if(subject != null && subject != '' && (subject.startsWith(emailSent) || subject.startsWith(unsubscribe) || subject.startsWith(lossSurveyResults))){
                String[] parsedString = subject.split(' ');
                if(parsedString != null){
                    String needed = parsedString[1];
                    fed_SchoolCode = needed.substring(0, 6);
                }
            }/*else if(subject != null && subject != '' && subject.startsWith(unsubscribe)){
                String[] parsedString = subject.split(' ');
                if(parsedString != null){
                    String needed = parsedString[1];
                    fed_SchoolCode = needed.substring(0, 6);
                }
            }*/
        }catch(StringException s){
            
        }
        
        return fed_SchoolCode;
    }
    public static Map<String, Id> mapCodeToSchool(List<Account> schoolList){
        Map<String, Id> schoolCodeToSchool = new Map<String, id>();
        if(schoolList != null && schoolList.size() > 0){
            for(Account thisSchool : schoolList){
                if(thisSchool.Federal_School_Code_No__c != null && thisSchool.Federal_School_Code_No__c != '')
                    schoolCodeToSchool.put(thisSchool.Federal_School_Code_No__c, thisSchool.id);
            }
        }
        return schoolCodeToSchool;
    } 
    public static List<Account> findSchoolswithSchoolCode(List<String> federalSchoolCode){
        List<Account> schools = new List<Account>();
        if(federalSchoolCode != null && federalSchoolCode.size() > 0){
            schools = [Select id,
                              Federal_School_Code_No__c
                        From Account
                        where Federal_School_Code_No__c IN :federalSchoolCode
                      ];
        }
        return schools;
    }
    public static List<RecordType> findRecordTypes(List<String> recordType){
        
        List<RecordType> recordTypes = new List<RecordType>();
        if(recordType != null && recordType.size() > 0){
            recordTypes = [select id, Name from RecordType where Name IN :recordType ];
        }
        
        return recordTypes;
    }
    
    /*public static Map<ELQA_Marketing_Activity__c, Id> findContacts(Map<ELQA_Marketing_Activity__c, String> activityToSchoolCode,
                                            Map<String, Id> schoolCodeToSchool,
                                            List<RecordType> recordTypes){
        Map<ELQA_Marketing_Activity__c, Id> activityToContact = new Map<ELQA_Marketing_Activity__c, Id>();
        
        List<Id> accountIdList = new List<Id>();
        
        if(schoolCodeToSchool != null && schoolCodeToSchool.size() > 0){
            accountIdList = schoolCodeToSchool.values();
        }                               
        
        
        List<Contact> contactSearch = [Select id, 
                                              AccountId 
                                        From Contact c
                                        Where c.AccountId IN :accountIdList
                                        AND c.RecordTypeId IN  :recordTypes
                                        Order by LastModifiedDate desc
                                      ];
        
        Map<String, Contact> accountToContact = new Map<String, Contact>();
        for(Contact c : contactSearch){
            String accountId = c.AccountId;
            if(!(accountToContact != null && accountToContact.containsKey(accountId))){
                accountToContact.put(accountId, c);
            }
        }
        
        
        if(activityToSchoolCode != null && activityToSchoolCode.size() > 0){
            Set<ELQA_Marketing_Activity__c> activitySet = activityToSchoolCode.keySet();
            for(ELQA_Marketing_Activity__c thisActivity : activitySet){
                String schoolCode = activityToSchoolCode.get(thisActivity);
                if(schoolCodeToSchool != null && schoolCodeToSchool.containsKey(schoolCode)){
                    Id AccountId = schoolCodeToSchool.get(schoolCode);
                    if(accountToContact != null && accountToContact.containsKey(AccountId)){
                        activityToContact.put(thisActivity, accountToContact.get(AccountId).Id);
                    }
                }
            }
        }
        
        
        
        
        return activityToContact;
    }*/
    
    
}