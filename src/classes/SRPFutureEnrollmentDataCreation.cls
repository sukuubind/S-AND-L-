global class SRPFutureEnrollmentDataCreation implements  Database.Batchable<sObject>{
    global SRPFutureEnrollmentDataCreation(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        
        query = 'Select d.Week_Start_Date__c , d.FE_External_ID_Group_By__c, d.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c, d.DeltakSRP__Program__r.DeltakSRP__School__c, d.DeltakSRP__Program__r.Name, d.Terms_Label_Test__c,  d.Reporting_Term_Label__c, d.Name, d.Id, d.DeltakSRP__Term__c, d.DeltakSRP__Term_Start__c, d.DeltakSRP__Term_Label__c, d.DeltakSRP__Term_End__c, d.DeltakSRP__Sum_of_Enrollments__c, d.DeltakSRP__Student__c, d.DeltakSRP__Student_Name__c, d.DeltakSRP__Student_Email_from_Contact__c, d.DeltakSRP__Student_Email__c, d.DeltakSRP__Status__c, d.DeltakSRP__Program__c, d.DeltakSRP__Program_Start_Term__c, d.DeltakSRP__Program_Enrollment__c, d.DeltakSRP__Program_Enrollment_Start_Term__c, d.DeltakSRP__Num_of_Returns__c, d.DeltakSRP__Num_of_Re_Enters__c, d.DeltakSRP__Num_of_New__c, d.DeltakSRP__Num_of_Grads__c, d.DeltakSRP__Num_of_Drops__c, d.DeltakSRP__Halfway_Day__c, d.DeltakSRP__Enrollment_Id__c, d.DeltakSRP__Enrolled_Student__c, d.DeltakSRP__Email_Student_First_Name__c, d.DeltakSRP__Email_Advisor_Phone__c, d.DeltakSRP__Advisor__c, d.DeltakSRP__Advisor_Email_from_Contact__c, d.DeltakSRP__Advisor_Email__c, d.DeltakSRP__Academic_Term2__c, d.CreatedDate, d.CreatedById From DeltakSRP__Enrollment_History__c d '; 
         query = query +  ' ORDER BY d.DeltakSRP__Program__c';   
         if(Test.isRunningTest()){
        	query = query + ' limit 15 ';
        } 
           
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        AggregateResult[] groupedResults  = [SELECT FE_External_ID_Group_By__c, SUM(DeltakSRP__Num_of_Drops__c)DropSum
                                                ,SUM(DeltakSRP__Num_of_Grads__c)GradSum
                                                ,SUM(DeltakSRP__Num_of_Re_Enters__c)ReEnterSum
                                                ,SUM(DeltakSRP__Num_of_Returns__c)ReturnSum
                                                ,SUM(DeltakSRP__Num_of_New__c)StartSum
                                                FROM DeltakSRP__Enrollment_History__c GROUP BY FE_External_ID_Group_By__c];
        
        Map<String, Double> DropSum = new Map<String, Double>();
        Map<String, Double> GradSum = new Map<String, Double>();
        Map<String, Double> ReEnterSum = new Map<String, Double>();
        Map<String, Double> ReturnSum = new Map<String, Double>();
        Map<String, Double> StartSum = new Map<String, Double>();
        
        for(AggregateResult thisAggRes : groupedResults){
            DropSum.put(String.valueOf(thisAggRes.get('FE_External_ID_Group_By__c')), Double.valueOf(thisAggRes.get('DropSum')));
            GradSum.put(String.valueOf(thisAggRes.get('FE_External_ID_Group_By__c')), Double.valueOf(thisAggRes.get('GradSum')));
            ReEnterSum.put(String.valueOf(thisAggRes.get('FE_External_ID_Group_By__c')), Double.valueOf(thisAggRes.get('ReEnterSum')));
            ReturnSum.put(String.valueOf(thisAggRes.get('FE_External_ID_Group_By__c')), Double.valueOf(thisAggRes.get('ReturnSum')));
            StartSum.put(String.valueOf(thisAggRes.get('FE_External_ID_Group_By__c')), Double.valueOf(thisAggRes.get('StartSum')));
            
        }
        
        
        List<Academic_Term_Master__c> termMasterList = [Select Id from Academic_Term_Master__c order by Term_Start_Date__c asc];
        
        system.debug('scope>>>>'+scope.size());
        List<Future_Enrollment__c> futureEnrollmentToCreate = new List<Future_Enrollment__c>();
        Set<Id> programids = new Set<Id>();
        for(sObject s: Scope){
            DeltakSRP__Enrollment_History__c eh = (DeltakSRP__Enrollment_History__c)s;
            programids.add(eh.deltaksrp__program__c);
        }
        system.debug('programIds>>>>'+programids);
        List<DeltakSRP__Academic_Program__c> programs = [Select Id from DeltakSRP__Academic_Program__c];
        Set<String> proglist = new Set<String>();
        Map<String, Future_Enrollment__c > progIdToFE = new Map<String, Future_Enrollment__c>();
        
        	 Set<Date> dateList = new Set<Date>();
	        List<Id> termIds = new List<Id>();
	        for(Sobject s : scope){
	            DeltakSRP__Enrollment_History__c eh = (DeltakSRP__Enrollment_History__c)s;
	            dateList.add(eh.Week_Start_Date__c);
	            termIds.add(eh.DeltakSRP__Academic_Term2__c);
	        }
        	 Map<Date, Id> dateToMasterId = SRPEnrollmentHistoryTriggerHelper.findTermMasterForDates(dateList);
            
            for(sObject s: Scope){ 
                Future_Enrollment__c fe = null;
                DeltakSRP__Enrollment_History__c eh = (DeltakSRP__Enrollment_History__c)s;
                String externalId = eh.FE_External_ID_Group_By__c;//eh.DeltakSRP__Program__c+'-'+eh.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c;
                if(Test.isRunningTest()){
                	externalId = externalId + Datetime.now();
                }
                //if(pid == eh.DeltakSRP__Program__c){
                    if(progIdToFE.containsKey(externalId)){
                        system.debug('program id found 1>>>>');
                         fe = progIdToFE.get(externalId);
                        continue;
                    }else{
                        fe = new Future_Enrollment__c();
                        fe.Number_of_Drops__c = (DropSum != null && DropSum.containsKey(externalId) ? DropSum.get(externalId) : 0);
                        fe.Number_of_Grads__c =(GradSum != null && GradSum.containsKey(externalId) ? GradSum.get(externalId) : 0);
                        fe.Number_of_Re_Enters__c = (ReEnterSum != null && ReEnterSum.containsKey(externalId) ? ReEnterSum.get(externalId) : 0);
                        fe.Number_of_Returns__c = (ReturnSum != null && ReturnSum.containsKey(externalId) ? ReturnSum.get(externalId) : 0);
                        fe.Number_of_Starts__c = (StartSum != null && StartSum.containsKey(externalId) ? StartSum.get(externalId) : 0);
                    }   
                    
                    
                    /*fe.Number_of_Drops__c = (fe.Number_of_Drops__c != null ? fe.Number_of_Drops__c : 0) + (eh.DeltakSRP__Num_of_Drops__c != null ? eh.DeltakSRP__Num_of_Drops__c : 0);
                    fe.Number_of_Grads__c = (fe.Number_of_Grads__c != null ? fe.Number_of_Grads__c : 0) + (eh.DeltakSRP__Num_of_Grads__c != null ? eh.DeltakSRP__Num_of_Grads__c : 0) ;
                    fe.Number_of_Re_Enters__c = (fe.Number_of_Re_Enters__c != null ? fe.Number_of_Re_Enters__c : 0) + (eh.DeltakSRP__Num_of_Re_Enters__c != null ? eh.DeltakSRP__Num_of_Re_Enters__c : 0);
                    fe.Number_of_Returns__c = (fe.Number_of_Returns__c != null ? fe.Number_of_Returns__c : 0) + (eh.DeltakSRP__Num_of_Returns__c != null ?eh.DeltakSRP__Num_of_Returns__c : 0);
                    fe.Number_of_Starts__c = (fe.Number_of_Starts__c != null ? fe.Number_of_Starts__c : 0) + (eh.DeltakSRP__Num_of_New__c != null ? eh.DeltakSRP__Num_of_New__c : 0) ;
                    */
                    
                    
                    fe.Week_Date__c = system.today() - 7;
                    fe.Academic_Program__c = eh.DeltakSRP__Program__c;
                    fe.Academic_Institution__c = eh.DeltakSRP__Program__r.DeltakSRP__School__c;
                    fe.Academic_Term__c = eh.DeltakSRP__Academic_Term2__c;
                    fe.Academic_Term_Master__c = dateToMasterId.get(eh.Week_Start_Date__c);//eh.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c;
                    fe.External_Id__c = externalId;
                    fe.Academic_Program_Name__c = eh.DeltakSRP__Program__r.Name;
                    /*for(Integer i = 0;i < termMasterList.size(); i++){
                        Academic_Term_Master__c thisTerm = termMasterList.get(i);
                        if(thisTerm.Id == eh.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c){
                            try{
                                fe.Previous_Term__c = termMasterList.get(i-1).Id;
                                fe.This_Term_Last_Year__c = termMasterList.get(i-6).Id;
                                break;
                            }catch(Exception e){
                                
                            }
                        }
                    }*/
                proglist.add(externalId);
                progIdToFE.put(externalId, fe);
                //}
                
                system.debug('proglist>>>>'+proglist);
                   
            
            if(progIdToFE != null && progIdToFE.size() > 0){
                futureEnrollmentToCreate = progIdToFE.values();
            }
            
            /*if(fe!=null)
                futureEnrollmentToCreate.add(fe);*/
        }
        system.debug('futureEnrollmentToCreate>>>>'+futureEnrollmentToCreate);
        system.debug('futureEnrollmentToCreate.size>>>>'+futureEnrollmentToCreate.size());
        if(futureEnrollmentToCreate.size()>0){
            system.debug('futureEnrollmentToCreate[0].week_number__c>>>>'+futureEnrollmentToCreate[0].week_number__c);
            insert futureEnrollmentToCreate;
            
            List<Future_Enrollment__c> futureEnrollmentToUpdate = new List<Future_Enrollment__c>();
            List<Future_Enrollment_Goal__c> priorYearGoals = new List<Future_Enrollment_Goal__c>();
            priorYearGoals = [Select Id, Academic_Term__c, Year__c, Academic_Term_Master__c, enrollments__c from Future_Enrollment_Goal__c];
        
            List<Future_Enrollment__c> AllEnrollmentSnapshots = [Select Id, Week_Date__c, Number_of_Enrollments__c, Academic_Term_Master__c, 
                                                                        Academic_Term_Master__r.Term_Start_Date__c, Academic_Term__c, week_Number__c,
                                                                        Previous_Week_Enrollments__c, Number_of_Drops__c, Number_of_Grads__c, 
                                                                        Number_of_Starts__c, Number_of_Re_Enters__c
                                                                     from Future_Enrollment__c ORDER BY Academic_Term_Master__r.Term_Start_Date__c Asc];
            
            for(Future_Enrollment__c fe: AllEnrollmentSnapshots){ 
                if(fe.Week_Date__c == null)
                    fe.Week_Date__c = system.today();
                
                
               /* for(Future_Enrollment_Goal__c prioryeargoal: prioryeargoals){
                    
                    
                    if(fe.Academic_Term_Master__c == prioryearGoal.Academic_Term_Master__c){
                        System.Debug('fe.Previous_Week_Enrollments__c  -- '+fe.Previous_Week_Enrollments__c );
                        System.Debug('priorYearGoal.Enrollments__c -- '+priorYearGoal.Enrollments__c);
                        fe.Future_Enrollment_Goal__c = priorYearGoal.id; 
                        fe.Previous_Week_Enrollments__c = (fe.Previous_Week_Enrollments__c == null ?priorYearGoal.Enrollments__c : fe.Previous_Week_Enrollments__c) ;
                        fe.Number_of_Enrollments__c = (fe.Previous_Week_Enrollments__c != null ? fe.Previous_Week_Enrollments__c : 0) - ( (fe.Number_of_Drops__c != null ? fe.Number_of_Drops__c : 0 )+ (fe.Number_of_Grads__c != null ? fe.Number_of_Grads__c : 0) ) +( fe.Number_of_Starts__c != null ? fe.Number_of_Starts__c : 0) + (fe.Number_of_Re_Enters__c  != null ? fe.Number_of_Re_Enters__c : 0);// (fe.Continuing_Students__c != null ? fe.Continuing_Students__c : 0)  + (fe.Number_of_Starts__c != null ? fe.Number_of_Starts__c : 0) + (fe.Number_of_Re_Enters__c != null ?fe.Number_of_Re_Enters__c:0);
                        futureEnrollmentToUpdate.add(fe);
                        break;
                        system.debug('goal found>>>>'); 
                    }
                }    */   
                    
                    
            }
        
        if(futureEnrollmentToUpdate.size()>0)
            update futureEnrollmentToUpdate;
            
        }   
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('batch process scheduled is complete>>>>');
       DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
     	Integer BATCH_SIZE = 2000;
         Integer DAYS_FROM_NOW = Integer.valueOf(setting.HRF_Reporting_Schedule__c);
     	SRPFutureEnrollmentDataCreation fed = new SRPFutureEnrollmentDataCreation();
       if(!Test.isRunningTest()){
        String cronID = System.scheduleBatch(fed, 'HistoricalRollForwardReport'+System.now(), DAYS_FROM_NOW, BATCH_SIZE);
       }
    }
    
}