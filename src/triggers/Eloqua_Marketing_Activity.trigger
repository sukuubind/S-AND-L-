/**
Venkat Santhanam - 11/17/2010 Adding Version Header
Venkat Santhanam - 11/19/2010 Found bug during bulk testing and fixed
**/
trigger Eloqua_Marketing_Activity on ELQA_Marketing_Activity__c (before insert, before update) {
    
    String Integration_Eloqua_Name = 'Eloqua Marketing';
     String loggedinUserName = Userinfo.getName();
     
    if(!Test.isRunningTest()){
         String currentProfileId = userinfo.getProfileId();
        currentProfileId = currentProfileId.substring(0, 15);
        List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
        Set<String> srpProfiles = new Set<String>();
        SRPProfilesList = SRP_Profiles_List__c.getall().values();
        for(SRP_Profiles_List__c spl: SRPProfilesList){
            srpProfiles.add(spl.ProfileId__c);
        }
        if(srpProfiles.contains(currentProfileId) && loggedinUserName != Integration_Eloqua_Name)
        return;
    }   
    
     List<ELQA_Marketing_Activity__c> listToProcess = new List<ELQA_Marketing_Activity__c>();
     List<String> federalSchoolCode = new List<String>();
     Map<ELQA_Marketing_Activity__c, String> activityToSchoolCode = new Map<ELQA_Marketing_Activity__c, String>();
     Map<ELQA_Marketing_Activity__c, Id> activityToPerson = new Map<ELQA_Marketing_Activity__c, Id>();
     System.Debug('Size of the trigger = '+Trigger.size);
     List<String> personList = new List<String>();
     system.debug('Trigger.New>>>>'+trigger.new);
     for(ELQA_Marketing_Activity__c elqa : Trigger.new){
        if(elqa.SRP_Person__c == null && elqa.Contact__c == null){
            elqa.addError('Orphan record received');
        }
        
        else if(EloquaUtils.isActivityAcceptable(elqa)){
            listToProcess.add(elqa);
            String schoolCode = EloquaUtils.getFederalSchoolCode(elqa.Name);
            personList.add(elqa.SRP_Person__c);
            System.Debug('VS -- SchoolCode = '+schoolCode);
            if(schoolCode != null && schoolCode != ''){
                federalSchoolCode.add(schoolCode);
                activityToSchoolCode.put(elqa, schoolCode);
                activityToPerson.put(elqa, elqa.SRP_Person__c);
                System.Debug('VS -- Activity to School Code in beginning--'+activityToSchoolCode); 
            }
            
        }
     }
     
     List<Account> accountListWithFederalSchool = EloquaUtils.findSchoolswithSchoolCode(federalSchoolCode);
     Map<String, Id> schoolCodeToSchool = EloquaUtils.mapCodeToSchool(accountListWithFederalSchool);
     
     List<String> recordType = new List<String>();
     recordType.add('Rasmussen Student');
     recordType.add('Deltak Student');
     recordType.add('SRP Student');
     List<RecordType> recordTypes = EloquaUtils.findRecordTypes(recordType);
     
    
    /** FIND CONTACTS START **/
    
     Map<ELQA_Marketing_Activity__c, Id> activityToContact = new Map<ELQA_Marketing_Activity__c, Id>();
        
        List<Id> accountIdList = new List<Id>();
        
        if(schoolCodeToSchool != null && schoolCodeToSchool.size() > 0){
            accountIdList = schoolCodeToSchool.values();
        }                               
        System.Debug('personlist --'+personList);
    	System.Debug('accountIdList -- '+accountIdList);
    	System.Debug('recordTypes -- '+recordTypes);
        
        List<Contact> contactSearch = [Select id, 
                                              AccountId,
                                              DeltakSRP__Person__c
                                        From Contact c
                                        Where c.AccountId IN :accountIdList
                                        AND c.RecordTypeId IN  :recordTypes
                                        And c.DeltakSRP__Person__c IN :personList
                                        Order by LastModifiedDate desc
                                      ];
        
        Map<String, Contact> personToContact = new Map<String, Contact>();
        for(Contact c : contactSearch){
            String personId = c.DeltakSRP__Person__c;
            if(!(personToContact != null && personToContact.containsKey(personId))){
                personToContact.put(personId, c);
            }
        }
        
        
        Map<String, Contact> accountToContact = new Map<String, Contact>();
        for(Contact c : contactSearch){
            String accountId = c.AccountId;
            if(!(accountToContact != null && accountToContact.containsKey(accountId))){
                accountToContact.put(accountId, c);
            }
        }
        System.Debug('VS -- PersonToContact -- '+personToContact);
        System.Debug('VS -- AccountToContact -- '+accountToContact);
        System.Debug('VS -- listToProcess --'+listToProcess);
        System.Debug('VS -- schoolCodeToSchool --'+schoolCodeToSchool);
        Set<id> unsubscribeContactiD = new Set<id>();
        Set<id> lossSurveyResultsContactId = new Set<Id>();
        Map<String, String> lossSurveyMap1 = new Map<String, String>();
        Map<String, String> lossSurveyMap2 = new Map<String, String>();
        Map<String, String> lossSurveyMap3 = new Map<String, String>();
        Map<String, String> lossSurveyMap4 = new Map<String, String>();
    
        if(listToProcess != null && listToProcess.size() > 0){
            for(ELQA_Marketing_Activity__c thisActivity : listToProcess){
                String personId = thisActivity.SRP_Person__c;
                if(personToContact != null && personToContact.containsKey(personId)){
                    thisActivity.Contact__c = personToContact.get(personId).Id;
                    if(EloquaUtils.isUnsubscribe(thisActivity.Name)){
                        unsubscribeContactiD.add(personToContact.get(personId).Id);
                    }
                    if(EloquaUtils.isLossSurveyResults(thisActivity.Name)){
                        lossSurveyResultsContactId.add(personToContact.get(personId).Id);
                        if(thisActivity.Activity_Detail__c != null && thisActivity.Activity_Detail__c != ''){
                            String[] lossSurvey = thisActivity.Activity_Detail__c.split(';',-1);
                            if(lossSurvey != null && lossSurvey.size() == 4){
                                lossSurveyMap1.put(personToContact.get(personId).Id, lossSurvey[0]);
                                lossSurveyMap2.put(personToContact.get(personId).Id, lossSurvey[1]);
                                lossSurveyMap3.put(personToContact.get(personId).Id, lossSurvey[2]);
                                lossSurveyMap4.put(personToContact.get(personId).Id, lossSurvey[3]);
                            }
                        }
                        
                    }
                    thisActivity.SRP_Person__c = null;
                }
                
            }
        }
        
        List<Contact> contactListToUpdate = new List<Contact>();
        Map<Id, Contact> contactIdToContact = new Map<Id, Contact>();
        for(Id thisContactid : unsubscribeContactiD){
            Contact c = new Contact(id = thisContactid);
            c.HasOptedOutOfEmail = true;
            contactIdToContact.put(c.id, c);
            contactListToUpdate.add(c);
        }
        for(Id thisContactid : lossSurveyResultsContactId){
            Contact c = null;
            if(contactIdToContact != null && contactIdToContact.containsKey(thiscontactId)){
                 c = contactIdToContact.get(thiscontactId);
                
            }else{
                 c = new Contact(id=thiscontactid);
            }
            c.Chose_Another_School__c = lossSurveyMap1.get(thisContactId);
                c.If_Yes_Which_One__c = lossSurveyMap2.get(thisContactId);
                c.Why_did_you_choose_another_school__c = lossSurveyMap3.get(thisContactId);
                c.Why_are_you_not_pursuing_your_education__c = lossSurveyMap4.get(thisContactId);
                contactIdToContact.put(c.id, c);
            
        }
        
        try{
            Database.update(contactIdToContact.values(), false);
        }catch(Exception e){
            System.Debug(e);
        }
        
        /**if(listToProcess != null && listToProcess.size() > 0){
            Set<ELQA_Marketing_Activity__c> activitySet = activityToSchoolCode.keySet();
            for(ELQA_Marketing_Activity__c thisActivity : listToProcess){
                //String schoolCode = activityToSchoolCode.get(thisActivity);
                String schoolCode = EloquaUtils.getFederalSchoolCode(thisActivity.Name);
                System.Debug('VS - SchoolCode -- '+schoolCode);
                if(schoolCodeToSchool != null && schoolCodeToSchool.containsKey(schoolCode)){
                    Id AccountId = schoolCodeToSchool.get(schoolCode);
                    if(accountToContact != null && accountToContact.containsKey(AccountId)){
                        //activityToContact.put(thisActivity, accountToContact.get(AccountId).Id);
                        thisActivity.Contact__c = accountToContact.get(AccountId).Id;
                    }
                    thisActivity.SRP_Person__c = null;
                }
            }
        }**/
        System.Debug('VS -- Activity To Contact -- '+activityToContact);
        
    
    
    /** FIND CONTACTS END **/
    
    
    /**List<ELQA_Marketing_Activity__c> listElquaUpdate = new List<ELQA_Marketing_Activity__c>();
     for(ELQA_Marketing_Activity__c elqa : Trigger.new){
        if(EloquaUtils.isActivityAcceptable(elqa)){
            if(activityToContact != null && activityToContact.containsKey(elqa)){
                elqa.Contact__c = activityToContact.get(elqa);
            }
            elqa.SRP_Person__c = null;
            listElquaUpdate.add(elqa);
        }
     }**/
     
     
     
}