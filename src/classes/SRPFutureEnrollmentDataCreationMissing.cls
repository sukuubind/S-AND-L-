global with sharing class SRPFutureEnrollmentDataCreationMissing implements  Database.Batchable<sObject> {
    
    global SRPFutureEnrollmentDataCreationMissing(){
        
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
        List<DeltakSRP__Academic_Program__c> apList = (List<DeltakSRP__Academic_Program__c>)scope;
        List<Academic_Term_Master__c> termMasterList = [Select Id, Name, Previous_Term__c, Term_Start_Date__c from Academic_Term_Master__c order by Term_Start_Date__c asc];
        List<String> externalIdsToQuery = new List<String>();
        Map<String, Double> externalIdToNumberOfEnrollments = new Map<String, Double>();
        for(DeltakSRP__Academic_Program__c ap : apList){
            for(Academic_Term_Master__c atm : termMasterList){
                externalIdsToQuery.add(String.valueOf(ap.Id).subString(0,15)+'-'+String.valueOf(atm.id).subString(0,15));
            }
        }
        List<Future_Enrollment__c> felist = [Select id, External_id__c, Number_of_Enrollments__c, Number_of_Enrollments_Formula__c from Future_Enrollment__c where External_id__c in :externalIdsToQuery ];
        for(Future_Enrollment__c fe : felist){
            System.Debug(fe.External_id__c +' = '+fe.Number_of_Enrollments_Formula__c);
            externalIdToNumberOfEnrollments.put(fe.External_id__c, fe.Number_of_Enrollments_Formula__c);
        }
        List<Future_Enrollment__c> feListUpsert = new List<Future_Enrollment__c>();
        for(DeltakSRP__Academic_Program__c ap : apList){
            for(Academic_Term_Master__c atm : termMasterList){
                String externalId = String.valueOf(ap.Id).subString(0,15)+'-'+String.valueOf(atm.id).subString(0,15);
                String prevTermExternalId = String.valueOf(ap.Id).subString(0,15)+'-'+(atm.Previous_Term__c != null ? String.valueOf(atm.Previous_Term__c).subString(0,15) : '');
                if(!externalIdToNumberOfEnrollments.containsKey(externalId) || 
                    externalIdToNumberOfEnrollments.get(externalId) == null || 
                    externalIdToNumberOfEnrollments.get(externalId) == 0){
                        
                        Future_Enrollment__c fe = new Future_Enrollment__c();
                        fe.External_id__c = externalId;
                        fe.Academic_Institution__c = ap.DeltakSRP__School__c;
                        fe.Academic_Program__c = ap.Id;
                        fe.Academic_Program_Name__c = ap.Name;
                        fe.Academic_Term_Master__c = atm.id;
                        if(externalIdToNumberOfEnrollments != null && externalIdToNumberOfEnrollments.containsKey(prevTermExternalId)){
                            System.Debug(atm.Term_Start_Date__c+'='+externalIdToNumberOfEnrollments.get(prevTermExternalId));
                            fe.Previous_Week_Enrollments__c = externalIdToNumberOfEnrollments.get(prevTermExternalId);
                        }
                    feListUpsert.add(fe);
                }
            }
        }
        if(feListUpsert != null && feListUpsert.size() > 0){
            Database.upsert(feListUpsert, Future_Enrollment__c.External_id__c);
        }
        
        

        for(DeltakSRP__Academic_Program__c ap : apList){
            for(Academic_Term_Master__c atm : termMasterList){
                externalIdsToQuery.add(String.valueOf(ap.Id).subString(0,15)+'-'+String.valueOf(atm.id).subString(0,15));
            }
        }
      felist = [Select id, Previous_Week_Enrollments__c, Number_of_Drops__c, 
                       Number_of_Grads__c, Number_of_Starts__c, Number_of_Re_Enters__c, 
                       Academic_Program__c , External_id__c, Academic_Term_Master__c, 
                       Academic_Term_Master__r.Previous_Term__c, Number_of_Enrollments__c, 
                       Number_of_Enrollments_Formula__c, Future_Enrollment_Goal__c, Number_of_Returns__c
                from Future_Enrollment__c where External_id__c in :externalIdsToQuery 
                order by Academic_Term_Master__r.Term_Start_Date__c ASC ];
                
      externalIdToNumberOfEnrollments = new Map<String, Double>();
        for(Future_Enrollment__c fe : felist){
            System.Debug(fe.External_id__c +' = '+fe.Number_of_Enrollments_Formula__c);
            externalIdToNumberOfEnrollments.put(fe.External_id__c, (fe.Previous_Week_Enrollments__c != null ? fe.Previous_Week_Enrollments__c : 0) 
                                                                - ( (fe.Number_of_Drops__c != null ? fe.Number_of_Drops__c : 0)+ (fe.Number_of_Grads__c != null ? fe.Number_of_Grads__c : 0) ) 
                                                                +(( fe.Number_of_Starts__c != null ? fe.Number_of_Starts__c : 0) + (fe.Number_of_Re_Enters__c != null ? fe.Number_of_Re_Enters__c : 0) ));
        }
        
        feListUpsert = new List<Future_Enrollment__c>();
        List<Future_Enrollment_Goal__c> priorYearGoals = new List<Future_Enrollment_Goal__c>();
            priorYearGoals = [Select Id, Academic_Term__c, Year__c, Academic_Term_Master__c, enrollments__c from Future_Enrollment_Goal__c];
            for(Future_Enrollment__c fe : felist){
                String externalId = fe.External_id__c;
                String prevTermExternalId = String.valueOf(fe.Academic_Program__c).subString(0,15)+'-'+(fe.Academic_Term_Master__r.Previous_Term__c != null ? String.valueOf(fe.Academic_Term_Master__r.Previous_Term__c).subString(0,15) : '');
                System.Debug('externalId -- '+externalId);
                System.Debug('prevTermExternalId --'+prevTermExternalId);
                
                if(externalIdToNumberOfEnrollments != null && externalIdToNumberOfEnrollments.containsKey(prevTermExternalId) && fe.Future_Enrollment_Goal__c == null){
                    System.Debug('atm.Name inside the IF BLOCK ');
                    System.Debug(fe.External_id__c +' = '+fe.Number_of_Enrollments_Formula__c);
                    fe.Previous_Week_Enrollments__c = externalIdToNumberOfEnrollments.get(prevTermExternalId); 
                    externalIdToNumberOfEnrollments.put(externalId, (fe.Previous_Week_Enrollments__c != null ? fe.Previous_Week_Enrollments__c : 0) 
                                                                - ( (fe.Number_of_Drops__c != null ? fe.Number_of_Drops__c : 0)+ (fe.Number_of_Grads__c != null ? fe.Number_of_Grads__c : 0) ) 
                                                                +(( fe.Number_of_Starts__c != null ? fe.Number_of_Starts__c : 0) + (fe.Number_of_Re_Enters__c != null ? fe.Number_of_Re_Enters__c : 0)  ));
                }
                    
                
                feListUpsert.add(fe);
            }
            
        if(feListUpsert != null && feListUpsert.size() > 0){
            Database.upsert(feListUpsert, Future_Enrollment__c.External_id__c);
        }

        
        
        
     }
     
     global void finish(Database.BatchableContext BC){
        system.debug('batch process scheduled is complete>>>>');
       DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
     	Integer BATCH_SIZE = 2000;
         Integer DAYS_FROM_NOW = Integer.valueOf(setting.HRF_Reporting_Schedule__c);
     	SRPFutureEnrollmentDataCreationMissing fed = new SRPFutureEnrollmentDataCreationMissing();
        if(!Test.isRunningTest()){
        String cronID = System.scheduleBatch(fed, 'HistoricalRollForwardReportMissing'+System.now(), DAYS_FROM_NOW, BATCH_SIZE);
        }
    }
}