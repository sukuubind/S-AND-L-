global with sharing class SRPFEDataCreation implements  Database.Batchable<sObject>{
    global SRPFEDataCreation(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'Select d.Week_Start_Date__c, d.Future_Enrollment_External_iD_Group_By__c, d.FE_External_ID_Group_By__c, d.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c, d.DeltakSRP__Program__r.DeltakSRP__School__c, d.DeltakSRP__Program__r.Name, d.Terms_Label_Test__c,  d.Reporting_Term_Label__c, d.Name, d.Id, d.DeltakSRP__Term__c, d.DeltakSRP__Term_Start__c, d.DeltakSRP__Term_Label__c, d.DeltakSRP__Term_End__c, d.DeltakSRP__Sum_of_Enrollments__c, d.DeltakSRP__Student__c, d.DeltakSRP__Student_Name__c, d.DeltakSRP__Student_Email_from_Contact__c, d.DeltakSRP__Student_Email__c, d.DeltakSRP__Status__c, d.DeltakSRP__Program__c, d.DeltakSRP__Program_Start_Term__c, d.DeltakSRP__Program_Enrollment__c, d.DeltakSRP__Program_Enrollment_Start_Term__c, d.DeltakSRP__Num_of_Returns__c, d.DeltakSRP__Num_of_Re_Enters__c, d.DeltakSRP__Num_of_New__c, d.DeltakSRP__Num_of_Grads__c, d.DeltakSRP__Num_of_Drops__c, d.DeltakSRP__Halfway_Day__c, d.DeltakSRP__Enrollment_Id__c, d.DeltakSRP__Enrolled_Student__c, d.DeltakSRP__Email_Student_First_Name__c, d.DeltakSRP__Email_Advisor_Phone__c, d.DeltakSRP__Advisor__c, d.DeltakSRP__Advisor_Email_from_Contact__c, d.DeltakSRP__Advisor_Email__c, d.DeltakSRP__Academic_Term2__c, d.CreatedDate, d.CreatedById From DeltakSRP__Enrollment_History__c d'; 
        query = query + ' ORDER BY d.DeltakSRP__Program__c';
        if(Test.isRunningTest()){
        	query = query + ' limit 15 ';
        }
            
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        AggregateResult[] groupedResults  = [SELECT Future_Enrollment_External_iD_Group_By__c, SUM(DeltakSRP__Num_of_Drops__c)DropSum
                                                ,SUM(DeltakSRP__Num_of_Grads__c)GradSum
                                                ,SUM(DeltakSRP__Num_of_Re_Enters__c)ReEnterSum
                                                ,SUM(DeltakSRP__Num_of_Returns__c)ReturnSum
                                                ,SUM(DeltakSRP__Num_of_New__c)StartSum
                                                FROM DeltakSRP__Enrollment_History__c GROUP BY Future_Enrollment_External_iD_Group_By__c];
        
        Map<String, Double> DropSum = new Map<String, Double>();
        Map<String, Double> GradSum = new Map<String, Double>();
        Map<String, Double> ReEnterSum = new Map<String, Double>();
        Map<String, Double> ReturnSum = new Map<String, Double>();
        Map<String, Double> StartSum = new Map<String, Double>();
        
        for(AggregateResult thisAggRes : groupedResults){
            DropSum.put(String.valueOf(thisAggRes.get('Future_Enrollment_External_iD_Group_By__c')), Double.valueOf(thisAggRes.get('DropSum')));
            GradSum.put(String.valueOf(thisAggRes.get('Future_Enrollment_External_iD_Group_By__c')), Double.valueOf(thisAggRes.get('GradSum')));
            ReEnterSum.put(String.valueOf(thisAggRes.get('Future_Enrollment_External_iD_Group_By__c')), Double.valueOf(thisAggRes.get('ReEnterSum')));
            ReturnSum.put(String.valueOf(thisAggRes.get('Future_Enrollment_External_iD_Group_By__c')), Double.valueOf(thisAggRes.get('ReturnSum')));
            StartSum.put(String.valueOf(thisAggRes.get('Future_Enrollment_External_iD_Group_By__c')), Double.valueOf(thisAggRes.get('StartSum')));
            
        }
        
        Map<String, FE_Projection__c > progIdToFE = new Map<String, FE_Projection__c>();
        List<FE_Projection__c> futureEnrollmentToCreate = new List<FE_Projection__c>();
        List<Future_Enrollment_Goal__c> priorYearGoals = new List<Future_Enrollment_Goal__c>();
        priorYearGoals = [Select Id, Academic_Program__c, Academic_Term__c, Year__c, Academic_Term_Master__c, enrollments__c from Future_Enrollment_Goal__c];
        
        Map<String, Id> feGoalMap = new Map<String, Id>();
        for(Future_Enrollment_Goal__c feGoal : priorYearGoals) {
            String key = String.valueOf(feGoal.Academic_Program__c)+String.valueOf(feGoal.Academic_Term_Master__c);
            feGoalMap.put(key, feGoal.Id);
        }      
        
        Set<Date> dateList = new Set<Date>();
        List<Id> termIds = new List<Id>();
        for(Sobject s : scope){
            DeltakSRP__Enrollment_History__c eh = (DeltakSRP__Enrollment_History__c)s;
            dateList.add(eh.Week_Start_Date__c);
            termIds.add(eh.DeltakSRP__Academic_Term2__c);
        }
        /*List<DeltakSRP__Academic_Start_Date__c> startDateList = [Select Id, Academic_Term_Master__c from DeltakSRP__Academic_Start_Date__c where Id IN :termIds];
        Map<Id, Id> termIdToMasterId = new Map<Id, Id>();
        for(DeltakSRP__Academic_Start_Date__c thisDate : startDateList){
        	termIdToMasterId.put(thisDate.Id, thisDate.Academic_Term_Master__c);
        }*/
        Map<Date, Id> dateToMasterId = SRPEnrollmentHistoryTriggerHelper.findTermMasterForDates(dateList);
        
        
        
        Set<String> proglist = new Set<String>();
        for(sObject s: Scope){
            FE_Projection__c fe = null;
            DeltakSRP__Enrollment_History__c eh = (DeltakSRP__Enrollment_History__c)s;
            String externalId = eh.Future_Enrollment_External_iD_Group_By__c;
            if(Test.isRunningTest()){
            	externalId = externalId + Datetime.now();
            }
            if(progIdToFE.containsKey(externalId)){
                system.debug('program id found 1>>>>');
                 fe = progIdToFE.get(externalId);
                continue;
            }else{
                fe = new FE_Projection__c();
                fe.Number_of_Drops__c = (DropSum != null && DropSum.containsKey(externalId) ? DropSum.get(externalId) : 0);
                fe.Number_of_Grads__c =(GradSum != null && GradSum.containsKey(externalId) ? GradSum.get(externalId) : 0);
                fe.Number_of_Re_Enters__c = (ReEnterSum != null && ReEnterSum.containsKey(externalId) ? ReEnterSum.get(externalId) : 0);
                fe.Number_of_Returns__c = (ReturnSum != null && ReturnSum.containsKey(externalId) ? ReturnSum.get(externalId) : 0);
                fe.Number_of_Starts__c = (StartSum != null && StartSum.containsKey(externalId) ? StartSum.get(externalId) : 0);
                
            }
            fe.Week_Start_Date__c = eh.Week_Start_Date__c;
            fe.Academic_Program__c = eh.DeltakSRP__Program__c;
            //fe.Academic_Institution__c = eh.DeltakSRP__Program__r.DeltakSRP__School__c;
            //fe.Academic_Term__c = eh.DeltakSRP__Academic_Term2__c;
            fe.Academic_Term_Master__c = dateToMasterId.get(eh.Week_Start_Date__c);//termIdToMasterId.get(eh.DeltakSRP__Academic_Term2__c);
            fe.External_Id__c = externalId;
            //fe.Academic_Program_Name__c = eh.DeltakSRP__Program__r.Name;
            if(feGoalMap.containsKey(String.valueOf(eh.DeltakSRP__Program__c)+String.valueOf(dateToMasterId.get(eh.Week_Start_Date__c)))){
                fe.FE_Goal__c = feGoalMap.get(String.valueOf(eh.DeltakSRP__Program__c)+String.valueOf(dateToMasterId.get(eh.Week_Start_Date__c)));
            }
            futureEnrollmentToCreate.add(fe);
            
            proglist.add(externalId);
            progIdToFE.put(externalId, fe);
        }
        if(futureEnrollmentToCreate != null){
            Database.upsert(futureEnrollmentToCreate, FE_Projection__c.External_Id__c);
        }
        List<FE_Projection__c> feList = [Select Id, Academic_Term_Master__c, Number_Of_Drops__c, 
        										Week_Start_Date__c, Prior_Week_FE_Projection__c,
        										Number_Of_Starts__c, Number_Of_Re_Enters__c, Number_Of_Grads__c
        									 from FE_Projection__c where Week_Start_Date__c = :System.today()-7];
        Map<Id, FE_Projection__c> feMap = new Map<Id, FE_Projection__c>();
        Map<Date, FE_Projection__c> weekDateToFEP = new Map<Date, FE_Projection__c>();
        Map<Id, Decimal> thisWeekDrops = new Map<Id, Decimal>();
        Map<Id, Decimal> thisWeekStarts = new Map<Id, Decimal>();
        Map<Id, Decimal> thisWeekReEnters = new Map<Id, Decimal>();
        Map<Id, Decimal> thisWeekGrads = new Map<Id, Decimal>();
        
        for(FE_Projection__c thisProjection : feList){
        	weekDateToFEP.put(thisProjection.Week_Start_Date__c, thisProjection);
        	thisWeekDrops.put(thisProjection.Id, thisProjection.Number_Of_Drops__c);
        	thisWeekStarts.put(thisProjection.Id, thisProjection.Number_Of_Starts__c);
        	thisWeekReEnters.put(thisProjection.Id, thisProjection.Number_Of_Re_Enters__c);
        	thisWeekGrads.put(thisProjection.Id, thisProjection.Number_Of_Grads__c);
        	feMap.put(thisProjection.id, thisProjection);
        }
        List<FE_Projection__c> projectionsToUpdate = new List<FE_Projection__c>();
        for(FE_Projection__c thisProjection : feList){
        	Date thisWeekStartDate = thisProjection.Week_Start_Date__c;
        	Date priorWeekStartDate = thisWeekStartDate.addDays(-7);
        	if(weekDateToFEP != null && weekDateToFEP.containsKey(priorWeekStartDate)){
        		FE_Projection__c priorWeekProjection = weekDateToFEP.get(priorWeekStartDate);
        		thisProjection.Prior_Week_FE_Projection__c = priorWeekProjection.Id;
        		if(thisProjection.Academic_Term_Master__c == priorWeekProjection.Academic_Term_Master__c){
        			thisProjection.Number_Of_Drops__c = thisWeekDrops.get(thisProjection.Id) + thisWeekDrops.get(priorWeekProjection.Id);
        			thisWeekDrops.put(thisProjection.Id, thisWeekDrops.get(thisProjection.Id) + thisWeekDrops.get(priorWeekProjection.Id));
        			thisProjection.Number_Of_Starts__c = thisWeekStarts.get(thisProjection.Id) + thisWeekStarts.get(priorWeekProjection.Id);
        			thisWeekStarts.put(thisProjection.Id, thisWeekStarts.get(thisProjection.Id) + thisWeekStarts.get(priorWeekProjection.Id));
        			thisProjection.Number_Of_Re_Enters__c = thisWeekReEnters.get(thisProjection.Id) + thisWeekReEnters.get(priorWeekProjection.Id);
        			thisWeekReEnters.put(thisProjection.Id, thisWeekReEnters.get(thisProjection.Id) + thisWeekReEnters.get(priorWeekProjection.Id));
        			thisProjection.Number_Of_Grads__c = thisWeekGrads.get(thisProjection.Id) + thisWeekGrads.get(priorWeekProjection.Id);
        			thisWeekGrads.put(thisProjection.Id, thisWeekGrads.get(thisProjection.Id) + thisWeekGrads.get(priorWeekProjection.Id));
        		
        		}
        		
        		projectionsToUpdate.add(thisProjection);
        	}
        }
        
        if(projectionsToUpdate != null && projectionsToUpdate.size() > 0){
        	Database.update(projectionsToUpdate, false);
        }
        
        
        
        
        
    }
    
     global void finish(Database.BatchableContext BC){
     	DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
     	Integer BATCH_SIZE = 2000;
         Integer DAYS_FROM_NOW = Integer.valueOf(setting.FEP_Reporting_Schedule__c);
     	SRPFEDataCreation fed = new SRPFEDataCreation();
        if(!Test.isRunningTest()){
            String cronID = System.scheduleBatch(fed, 'SRPFEDataCreation'+System.now(), DAYS_FROM_NOW, BATCH_SIZE);
        }
        
     }
}