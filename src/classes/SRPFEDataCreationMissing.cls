global with sharing class SRPFEDataCreationMissing implements  Database.Batchable<sObject>{
    global SRPFEDataCreationMissing(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'Select Id, Name,  DeltakSRP__School__c from DeltakSRP__Academic_Program__c where DeltakSRP__School__r.RecordType.DeveloperName = \'SRP_Account\' '; 
        if(Test.isRunningTest()){
            query = query + ' limit 15 ';
        }    
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    
        List<id> programIds = new List<Id>();
        for(Sobject s : scope){
            DeltakSRP__Academic_Program__c ap = (DeltakSRP__Academic_Program__c)s;
            programIds.add(ap.Id);
                
        }
        List<DeltakSRP__Academic_Start_Date__c> startDateList = [Select Id, Academic_Term_Master__c, DeltakSRP__Academic_Program__c,
                                                                        DeltakSRP__Start_Date__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Academic_Program__c IN :programIds];
        Map<Id, Id> termIdToMasterId = new Map<Id, Id>();
        Map<Id, List<DeltakSRP__Academic_Start_Date__c>> programIdToTermList = new Map<Id, List<DeltakSRP__Academic_Start_Date__c>>();
        for(DeltakSRP__Academic_Start_Date__c thisDate : startDateList){
            termIdToMasterId.put(thisDate.Id, thisDate.Academic_Term_Master__c);
            List<DeltakSRP__Academic_Start_Date__c> thisTermList = new List<DeltakSRP__Academic_Start_Date__c>();
            if(programIdToTermList != null && programIdToTermList.containsKey(thisDate.DeltakSRP__Academic_Program__c)){
                thisTermList = programIdToTermList.get(thisDate.DeltakSRP__Academic_Program__c);
            }
            thisTermList.add(thisDate);
            programIdToTermList.put(thisDate.DeltakSRP__Academic_Program__c, thisTermList);
        }
        
        
        List<FE_Projection__c> projectionList = [Select Id, External_id__c from FE_Projection__c];
        Set<String> progList = new Set<String>();
        for(FE_Projection__c fep : projectionList){
            progList.add(fep.External_Id__c);
        }
        List<Future_Enrollment_Goal__c> priorYearGoals = new List<Future_Enrollment_Goal__c>();
        priorYearGoals = [Select Id, Academic_Program__c, Academic_Term__c, Year__c, Academic_Term_Master__c, enrollments__c from Future_Enrollment_Goal__c];
        
        Map<String, Id> feGoalMap = new Map<String, Id>();
        for(Future_Enrollment_Goal__c feGoal : priorYearGoals) {
            String key = String.valueOf(feGoal.Academic_Program__c)+String.valueOf(feGoal.Academic_Term_Master__c);
            feGoalMap.put(key, feGoal.Id);
        }      
    
        System.Debug('proglist -- '+proglist);
        
       List<FE_Projection__c> futureEnrollmentToCreate = new List<FE_Projection__c>();
        
        Map<Date,Id> termStartDateToMasterId = new Map<Date, Id>();
        Map<Id, List<Date>> programIdToTermStartDates = new Map<id, List<Date>>();
        for(Sobject s : scope){
            DeltakSRP__Academic_Program__c ap = (DeltakSRP__Academic_Program__c)s;
            List<DeltakSRP__Academic_Start_Date__c> termsList = programIdToTermList.get(ap.id);
            if(termsList != null && termsList.size() > 0){
                for(DeltakSRP__Academic_Start_Date__c thisTerm : termsList){
                    Date thisDate = thisTerm.DeltakSRP__Start_Date__c;
                    Id termmasterId = thisTerm.Academic_Term_Master__c;
                    termStartDateToMasterId.put(thisDate, termMasterId);
                    List<Date> dateList = new List<Date>();
                    if(programIdToTermStartDates != null && programIdToTermStartDates.containsKey(ap.Id)){
                        dateList = programIdToTermStartDates.get(ap.Id);
                    }
                    dateList.add(thisDate);
                    programIdToTermStartDates.put(ap.id, dateList);
                }
            }
        }
        Set<Date> datesList = new Set<Date>();
        Map<Id, List<Date>> programIdToAllStartDatesInTerm = new Map<id, List<Date>>();
        for(Sobject s : scope){
            DeltakSRP__Academic_Program__c ap = (DeltakSRP__Academic_Program__c)s;
            List<Date> termStartDates = programIdToTermStartDates.get(ap.id);
            System.Debug('termStartDates -- '+termStartDates);
            if(termStartDates != null){
                termStartDates.sort();
            }
            List<Date> datesForThisTerm = new List<Date>();
            if(programIdToAllStartDatesInTerm != null && programIdToAllStartDatesInTerm.containsKey(ap.Id)){
                datesForThisTerm = programIdToAllStartDatesInTerm.get(ap.id);
            }
            for(Integer i = 0; termStartDates != null && i< termStartDates.size(); i++){
                Date thisDate = termStartDates.get(i);
                thisDate = SRPEnrollmentHistoryTriggerHelper.findWeekStartDate(thisDate);
                Date nextTermDate = null;
                if(i<termStartDates.size() - 1){
                    nextTermDate = termStartDates.get(i+1);
                }
                System.Debug('thisDate -- '+thisDate);
                System.Debug('nextTermDate -- '+nextTermDate);
                while(true){
                    datesForThisTerm.add(thisDate);
                    datesList.add(thisDate);
                    thisDate = thisDate.addDays(7);
                    if(thisDate >= nextTermDate || nextTermDate == null){
                            break;
                    }
                }
                
            }
            programIdToAllStartDatesInTerm.put(ap.Id, datesForThisTerm);
        }
        Map<Date, Id> dateToTermMaster = SRPEnrollmentHistoryTriggerHelper.findTermMasterForDates(datesList);
        System.Debug('dateToTermMaster -- '+dateToTermMaster);
        Set<Date> allDates = new Set<Date>();
        Set<String> externalIdSet = new Set<String>();
        for(Sobject s : scope){
            DeltakSRP__Academic_Program__c ap = (DeltakSRP__Academic_Program__c)s;
            List<Date> termStartDates = programIdToAllStartDatesInTerm.get(ap.id);
            System.Debug('termStartDates -- '+termStartDates);
            termStartDates.sort();
            for(Integer i = 0; i< termStartDates.size(); i++){
                Date thisDate = termStartDates.get(i);
                
                     Id thisMasterId = dateToTermMaster.get(thisDate);
                      System.Debug('thisMasterId -- '+thisMasterId);
                    if(thisMasterId == null){
                        continue;
                    }
                    
                   
                    System.Debug('thisMasterId insider while(true) -- '+thisMasterId);
                    FE_Projection__c fe = new FE_Projection__c();
                    String externalId = String.valueOf(ap.Id).subString(0,15)+'$'+((thisMasterId != null) ? String.valueOf(thisMasterId).subString(0,15) : '')+'$'+thisDate;
                    System.Debug('externalId -- '+externalId);
                    if(proglist.contains(externalId)){
                        System.Debug('External Id Already Exist for -- '+thisDate);
                        thisDate = thisDate.addDays(7);
                        continue;
                    }
                    fe.Number_of_Drops__c = 0;
                    fe.Number_of_Grads__c = 0;
                    fe.Number_of_Re_Enters__c = 0;
                    fe.Number_of_Returns__c = 0;
                    fe.Number_of_Starts__c = 0;
                    fe.Week_Start_Date__c = thisDate;
                    fe.Academic_Program__c = ap.Id;
                    fe.Academic_Term_Master__c = thisMasterId;
                    fe.External_Id__c = externalId;
                    
                    if(feGoalMap.containsKey(String.valueOf(ap.id)+String.valueOf(thisMasterId))){
                        fe.FE_Goal__c = feGoalMap.get(String.valueOf(ap.id)+String.valueOf(thisMasterId));
                    }
                    System.Debug('Creating new FEP for external Id -- '+thisDate);
                    if(!externalIdSet.contains(externalId)){
                        futureEnrollmentToCreate.add(fe);
                        externalIdSet.add(externalId);
                    }
                    
                    
                
                
            }
        }
        if(futureEnrollmentToCreate != null && futureEnrollmentToCreate.size() > 0){
            Database.upsert(futureEnrollmentToCreate, FE_Projection__c.External_Id__c);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
     	Integer BATCH_SIZE = 2000;
         Integer DAYS_FROM_NOW = Integer.valueOf(setting.FEP_Reporting_Schedule__c);
     	SRPFEDataCreationMissing fed = new SRPFEDataCreationMissing();
        if(!Test.isRunningTest()){
        String cronID = System.scheduleBatch(fed, 'SRPFEDataCreationMissing'+System.now(), DAYS_FROM_NOW, BATCH_SIZE);
        }
     }
    
    
    
}