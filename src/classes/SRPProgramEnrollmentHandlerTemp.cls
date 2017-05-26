/**
 * ProgramEnrollmentHandler.cls
 * @description Trigger Handler for Program Enrollment triggers 
 * @author Charles Howard
 * @date 3/22/2013
 * @amended by George Abboud on 2/5/2015
   @updated by Pratik Tanna on 7/6/2015 - Added funcitonality of before insert for UOB Integration
 */

public without sharing class SRPProgramEnrollmentHandlerTemp {
    
    public static void handleBeforeUpdate(List<DeltakSRP__Program_Enrollment__c> oldRecordList, List<DeltakSRP__Program_Enrollment__c> newRecordList){
    	// SRP-2381 - Changes to replace 2 Workflows
    	List<String> pgmEn = new List<String>();
    	Map<String,String> peSSCEmail = new Map<String,String>();
    	Map<String,String> peStudentEmail = new Map<String,String>();
    	for(Integer i = 0;i<newRecordList.size();i++){
    		DeltakSRP__Program_Enrollment__c oldRecord = oldRecordList.get(i);
    		DeltakSRP__Program_Enrollment__c newRecord = newRecordList.get(i);
    		if(oldRecord.DeltakSRP__Enrollment_Status__c != newRecord.DeltakSRP__Enrollment_Status__c){
    			newRecord.DeltakSRP__Status_Change_Date__c = Date.today();
    		}
    		
    		
    			pgmEn.add(newRecord.Id);
    		
    	}
    	System.Debug('pgmEn -- '+pgmEn);
    	if(pgmEn!=null && pgmEn.size()>0)
    	{
    		List<DeltakSRP__Program_Enrollment__c> pe_SSC = [Select id, DeltakSRP__Student_Services_Coordinator__c, DeltakSRP__Student_Services_Coordinator__r.Email, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Email__c from DeltakSRP__Program_Enrollment__c where id in :pgmEn];
	    	if(pe_SSC!=null && pe_SSC.size()>0)
	    	{
	    		for(DeltakSRP__Program_Enrollment__c pe: pe_SSC)
	    		{
	    			if(pe.DeltakSRP__Student_Services_Coordinator__c!= null && pe.DeltakSRP__Student_Services_Coordinator__r.Email !=null && pe.DeltakSRP__Student_Services_Coordinator__r.Email !='')
	    			{
	    				peSSCEmail.put(pe.id,pe.DeltakSRP__Student_Services_Coordinator__r.Email);
	    			}
	    			if(pe.DeltakSRP__Enrolled_Student__c !=null && pe.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Email__c !=null && pe.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Email__c !='')
	    			{
	    				peStudentEmail.put(pe.id,pe.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Email__c);
	    			}
	    				
	    		}	
	    	}
	    	
	    	for(Integer i = 0;i<newRecordList.size();i++){
	    		DeltakSRP__Program_Enrollment__c oldRecord = oldRecordList.get(i);
	    		DeltakSRP__Program_Enrollment__c newRecord = newRecordList.get(i);
	    		
				if(peSSCEmail.get(newRecord.id) != null && peSSCEmail.get(newRecord.id) != newRecord.DeltakSRP__Advisor_Email__c){
	    		   newRecord.DeltakSRP__Advisor_Email__c = peSSCEmail.get(newRecord.id);
	    		}
	    		if(newRecord.DeltakSRP__Enrolled_Student__c != null && peStudentEmail.get(newRecord.id) !=null && peStudentEmail.get(newRecord.id) != newRecord.DeltakSRP__Student_Email__c){
	    			newRecord.DeltakSRP__Student_Email__c = peStudentEmail.get(newRecord.id);
	    		}
	    		
	    		
	    	}
    	}
    	// SRP-2381 - Changes to replace 2 Workflows
    }
    
    
    public static void handleBeforeInsert(List<DeltakSRP__Program_Enrollment__c> recordsList){
        set<String> studentExternalIds = new set<String>();
        set<String> termExternalIds = new set<String>();
        set<date> termStartDates = new set<date>();
        set<String> programExternalIds = new set<String>();
        Map<String, String> studentexternalidsMap = new Map<String, String>();
        Map<String, String> programexternalidsMap = new Map<String, String>();
        set<String> accountIds = new set<String>();
        boolean throwexception;
        
        for(DeltakSRP__Program_Enrollment__c Enrol : recordsList){
            if(enrol.DeltakSRP__SIS_External_Id__c!= null && enrol.DeltakSRP__SIS_External_Id__c.contains('-')){
                List<String> externalids = enrol.DeltakSRP__SIS_External_Id__c.split('-');
                if(externalids != null && externalids.size()>2){
                    studentExternalIds.add(externalids[1]); 
                    programExternalIds.add(externalids[2]);
                    studentexternalidsMap.put(enrol.DeltakSRP__SIS_External_Id__c, externalids[1]);
                    programexternalidsMap.put(enrol.DeltakSRP__SIS_External_Id__c, externalids[2]);
                }
            } 
            termexternalids.add(enrol.term_sis_id__c);
            termstartdates.add(enrol.deltaksrp__start_date__c);
            accountids.add(enrol.account_id__c);
        }   
        system.debug('accountid>>>>'+accountids);
        
        system.debug('termexternalids size>>>>'+termexternalids.size());
        system.debug('termexternalids>>>>'+termexternalids);
        system.debug('studentExternalIds size>>>>'+studentExternalIds.size());
        system.debug('studentExternalIds>>>>'+studentExternalIds);
        system.debug('programExternalIds size>>>>'+programExternalIds.size());
        system.debug('programExternalIds>>>>'+programExternalIds);
        
        
        
        if(studentExternalIds.size()>0){
            List<Contact> contacts = [Select Id, DeltakSRP__Student_ID__c from Contact where accountid in: accountids and DeltakSRP__Student_ID__c in: studentexternalids];
            system.debug('contacts>>>>'+contacts);
            Map<String, String> contactsmap = new Map<String, String>();
            
            for(Contact c: contacts){
                contactsmap.put(c.DeltakSRP__Student_ID__c, c.id);
            }
            
            for(DeltakSRP__Program_Enrollment__c Enrol : recordsList){ 
                if(enrol.DeltakSRP__Enrolled_Student__c == null || enrol.DeltakSRP__Enrolled_Student__c == '')
                    enrol.DeltakSRP__Enrolled_Student__c = contactsmap.get(studentexternalidsMap.get(enrol.DeltakSRP__SIS_External_Id__c));
            }
        }
        
        if(programExternalIds.size()>0){
            List<DeltakSRP__Academic_Program__c> programs = [Select Id, DeltakSRP__SIS_External_ID__c from DeltakSRP__Academic_Program__c where DeltakSRP__SIS_External_ID__c in: programexternalids];
            system.debug('programs>>>>'+programs);
            if(Test.isrunningtest() && programs.size()==0){
                DeltakSRP__Academic_Program__c p = [Select id from DeltakSRP__Academic_Program__c where DeltakSRP__SIS_External_ID__c = 'AP12345'];
                DeltakSRP__Academic_Start_Date__c ast= [Select id from DeltakSRP__Academic_Start_Date__c where DeltakSRP__SIS_External_Id__c = 'AT12345'];
                for(DeltakSRP__Program_Enrollment__c Enrol : recordsList){
                    enrol.DeltakSRP__Academic_Program__c = p.id;
                    enrol.DeltakSRP__Enrollment_Start__c = ast.id;
                }   
                throw new SRPException('Program Mapping not found.');
            }
        
            Map<String, String> programsmap = new Map<String, String>();
            
            for(DeltakSRP__Academic_Program__c p: programs){
                programsmap.put(p.DeltakSRP__SIS_External_ID__c, p.id);
            }
            
            for(DeltakSRP__Program_Enrollment__c Enrol : recordsList){
                if(programsmap != null && programsmap.containsKey(programexternalidsMap.get(enrol.DeltakSRP__SIS_External_Id__c))){
                    enrol.DeltakSRP__Academic_Program__c = programsmap.get(programexternalidsMap.get(enrol.DeltakSRP__SIS_External_Id__c));
                }
                
            }
        }
        
        if(termstartdates.size()>0){
            List<DeltakSRP__Academic_Start_Date__c> terms = [Select Id, DeltakSRP__Start_Date__c, DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Program__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Start_date__c in: termstartdates];
            system.debug('terms>>>>'+terms);
            Map<String, String> termsmap = new Map<String, String>();
            
            
            for(DeltakSRP__Academic_Start_Date__c t: terms){
                termsmap.put(string.valueof(t.DeltakSRP__Start_date__c)+t.DeltakSRP__Academic_Program__c, t.id);
            }
            system.debug('termsmap>>>>'+termsmap);
            for(DeltakSRP__Program_Enrollment__c Enrol : recordsList){
                system.debug('enrol.DeltakSRP__Academic_Program__c>>>>'+enrol.DeltakSRP__Academic_Program__c);
                system.debug('enrol.deltakSRP__start_date__c>>>>'+string.valueof(enrol.deltakSRP__start_date__c));
                if(termsmap.get(string.valueof(enrol.deltakSRP__start_date__c)+enrol.DeltakSRP__Academic_Program__c) != null){
                    //if(coursemap.get(sec.DeltakSRP__Academic_Course__c)!=null && termmap.get(termsmap.get(sec.Term_SIS_Id__c)).deltakSRP__Academic_Program__c == coursemap.get(sec.DeltakSRP__Academic_Course__c).DeltakSRP__Primary_Program__c)
                        enrol.DeltakSRP__Enrollment_Start__c = termsmap.get(string.valueof(enrol.deltakSRP__start_date__c)+enrol.DeltakSRP__Academic_Program__c);
                        system.debug('enrol.DeltakSRP__Enrollment_Start__c>>>>'+enrol.DeltakSRP__Enrollment_Start__c);
                }   
                system.debug('enrol.DeltakSRP__Enrollment_Start__c>>>>'+enrol.DeltakSRP__Enrollment_Start__c);
            }
        
        }
        
        
        
        
        
    }
    
    public static void handleAfterInsert(List<DeltakSRP__Program_Enrollment__c> recordsList){
        
        list<DeltakSRP__Enrollment_History__c> lstHistory = new list<DeltakSRP__Enrollment_History__c>();
        
        List<DeltakSRP__Program_Enrollment__c> extendedEnrollments = [SELECT Id, Name, DeltakSRP__Academic_Program__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrollment_Status__c,
                                                                        DeltakSRP__Student_Email__c, DeltakSRP__Enrollment_Start__c,
                                                                        DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c, DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c,
                                                                        DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
                                                                        DeltakSRP__Enrollment_Start__r.DeltakSRP__SIS_External_Id__c, Opportunity_PE_Update_Value__c
                                                                        FROM DeltakSRP__Program_Enrollment__c
                                                                        WHERE Id IN :recordsList
                                                                        ];
        
        for(DeltakSRP__Program_Enrollment__c Enrol : extendedEnrollments){
            // For each enrollment that has a status
            if(Enrol.DeltakSRP__Enrollment_Status__c  != null && Enrol.DeltakSRP__Enrollment_Status__c != ''){
                // Add a history record to the list to be inserted
                lstHistory.add(SRPProgramEnrollmentHandlerTemp.getHistoryRecord(Enrol));
            }
        }
        
        if(lstHistory.size()>0)
            upsert lstHistory SIS_External_Id__c;
    }
    
    public static void handleAfterUpdate(Map<Id, DeltakSRP__Program_Enrollment__c> recordsMap, Map<Id, DeltakSRP__Program_Enrollment__c> oldrecordsMap){
        
        Set<Id> programEnrollmentsWithSDChanged = new Set<Id>();
        Set<Id> programEnrollmentsWithNewStatus = new Set<Id>();
        Set<Id> programEnrollmentWithStatusChangedToRollOrDrop = new Set<id>();
        for(Id peId : recordsMap.keySet()){
          DeltakSRP__Program_Enrollment__c newPERecord = recordsMap.get(peId);
          DeltakSRP__Program_Enrollment__c oldPERecord = oldrecordsMap.get(peId);
            if(newPERecord.DeltakSRP__Enrollment_Status__c == 'New' && oldPERecord.DeltakSRP__Enrollment_Status__c != 'New'){
            	continue;
            }
            if((newPERecord.DeltakSRP__Enrollment_Status__c == 'Roll' && oldPERecord.DeltakSRP__Enrollment_Status__c != 'Roll') ||
               (newPERecord.DeltakSRP__Enrollment_Status__c == 'Drop' && oldPERecord.DeltakSRP__Enrollment_Status__c != 'Drop')){
                programEnrollmentWithStatusChangedToRollOrDrop.add(peId);
            }
            if(newPERecord.DeltakSRP__Enrollment_Start__c != oldPERecord.DeltakSRP__Enrollment_Start__c){
                programEnrollmentsWithSDChanged.add(peId);
            }
            if(newPERecord.DeltakSRP__Enrollment_Status__c == 'New' || newPERecord.DeltakSRP__Enrollment_Status__c == 'Graduate'){
                programEnrollmentsWithNewStatus.add(peId);
            }
        }
        
        map<string,DeltakSRP__Enrollment_History__c> mapHistory = new map<string,DeltakSRP__Enrollment_History__c>();
        map<string,DeltakSRP__Enrollment_History__c> mapHistoryInclude = new map<string,DeltakSRP__Enrollment_History__c>();
        List<DeltakSRP__Enrollment_History__c> lstHistoryToInsert = new List<DeltakSRP__Enrollment_History__c>();
        List<DeltakSRP__Enrollment_History__c> lstHistoryToUpdate = new List<DeltakSRP__Enrollment_History__c>();
        
        
        // Query for records current attached to the set of Program Enrollment records
        for(DeltakSRP__Enrollment_History__c H : [select Id,DeltakSRP__Program_Enrollment__c, DeltakSRP__Program__c, SIS_External_Id__c, DeltakSRP__Student__c, 
                                        DeltakSRP__Academic_Term2__c, DeltakSRP__Student__r.Account.Abbreviation__c, DeltakSRP__Student__r.DeltakSRP__Student_Id__c,
                                        DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c, DeltakSRP__Program__r.DeltakSRP__SIS_External_Id__c, 
                                        DeltakSRP__Academic_Term2__r.DeltakSRP__SIS_External_Id__c, DeltakSRP__Term_Start__c
                                        from DeltakSRP__Enrollment_History__c
                                        where DeltakSRP__Program_Enrollment__c in :recordsMap.keySet()  
                                        Order by DeltakSRP__Term_Start__c DESC] )
        {    
            // Put the resulting records into a Map 
            //  - We need to match on Program Enrollment and Program in
            //    case the Program is changed  
            
            String abbrev = H.DeltakSRP__Student__r.Account.Abbreviation__c;
            System.debug('abbrev >---> ' + abbrev);
            String studentId = H.DeltakSRP__Student__r.DeltakSRP__Student_Id__c;
            System.debug('studentId >---> ' + studentId);
            String peId = H.DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c;
            System.debug('peId >---> ' + peId);
            String apId = H.DeltakSRP__Program__r.DeltakSRP__SIS_External_Id__c;
            System.debug('apId >---> ' + apId);
            //String termId = H.DeltakSRP__Academic_Term2__r.DeltakSRP__SIS_External_Id__c;
            //System.debug('termId >---> ' + termId);
            
            String sisExternalId = '';
            
            if(abbrev != null && studentId != null && apId != null && peId != null
             && abbrev != '' && studentId != '' && apId != '' && peId != '')
            {
                
                studentId = studentId.toUppercase();
                apId = apId.toUppercase();
                peId = peId.toUppercase();
                
                studentId = studentId.replace(abbrev.toUppercase() + '-', '');
                apId = apId.replace(abbrev.toUppercase() + '-', '');
                peId = peId.replace(abbrev.toUppercase() + '-', '');
                //termId = termId.replace(abbrev.toUppercase() + '-', '');
                
                sisExternalId += abbrev + '-' + studentId + '-' + peId + '-' + apId;
                
                sisExternalId = sisExternalId.toUppercase();
                
            }  
            
            if(sisExternalId == '')
            {
                sisExternalId = H.DeltakSRP__Student__c + '-' + H.DeltakSRP__Program_Enrollment__c + '-' + H.DeltakSRP__Program__c;
            }
            
            System.debug('sisExternalId >---> ' + sisExternalId);
            
            if(mapHistory.get(sisExternalId) == null)
            {   
                mapHistory.put( sisExternalId , H);        
            }
            
        }
        
        List<DeltakSRP__Program_Enrollment__c> extendedEnrollments = [SELECT Id, Name, DeltakSRP__Academic_Program__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrollment_Status__c,
                                                                        DeltakSRP__Student_Email__c, DeltakSRP__Enrollment_Start__c,
                                                                        DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c, DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c,
                                                                        DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
                                                                        DeltakSRP__Enrollment_Start__r.DeltakSRP__SIS_External_Id__c, Opportunity_PE_Update_Value__c
                                                                        FROM DeltakSRP__Program_Enrollment__c
                                                                        WHERE Id IN :recordsMap.values()
                                                                        ];
        
        // 
        for(DeltakSRP__Program_Enrollment__c Enrol : extendedEnrollments){
            
            if(programEnrollmentsWithNewStatus.contains(Enrol.Id) || programEnrollmentsWithSDChanged.contains(Enrol.Id)){
                System.Debug('Either New or Graduate Status or SD Changed');
            }else if(programEnrollmentWithStatusChangedToRollOrDrop.contains(Enrol.Id) && !programEnrollmentsWithSDChanged.contains(Enrol.Id)){
                System.Debug('Program Enrollment Status is Roll or Drop and the Start Date has not changed. Meaning, the opportunity stage moved to Roll or Drop for the same term.');
            }
            else{
                System.Debug('Neither new not SD Changed');
                continue;
            }
            String abbrev = Enrol.DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c;
            System.debug('abbrev >---> ' + abbrev);
            String studentId = Enrol.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c;
            System.debug('studentId >---> ' + studentId);
            String peId = Enrol.DeltakSRP__SIS_External_Id__c;
            System.debug('peId >---> ' + peId);
            String apId = Enrol.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
            System.debug('apId >---> ' + apId);
            
            String sisExternalId = '';
            
            if(abbrev != null && studentId != null && apId != null && peId != null
             && abbrev != '' && studentId != '' && apId != '' && peId != '')
            {
                
                studentId = studentId.toUppercase();
                apId = apId.toUppercase();
                peId = peId.toUppercase();
                
                studentId = studentId.replace(abbrev.toUppercase() + '-', '');
                apId = apId.replace(abbrev.toUppercase() + '-', '');
                peId = peId.replace(abbrev.toUppercase() + '-', '');
                //termId = termId.replace(abbrev.toUppercase() + '-', '');
                
                sisExternalId += abbrev + '-' + studentId + '-' + peId + '-' + apId;
                
                sisExternalId = sisExternalId.toUppercase();
                
            }
            
            System.debug('sisExternalId >---> ' + sisExternalId);
            
            DeltakSRP__Enrollment_History__c ehRecord = mapHistory.get(sisExternalId); 
            if(programEnrollmentsWithSDChanged.contains(Enrol.id)){
                ehRecord = null;
                sisExternalId = '';
            }
            // If there is not already a history record for this Program Enrollment and Program 
            if( ehRecord == null ){
                
                String sisExternalId2 = Enrol.DeltakSRP__Enrolled_Student__c + '-' + Enrol.Id + '-' + Enrol.DeltakSRP__Academic_Program__c;
                
                ehRecord = mapHistory.get(sisExternalId2);
                if(programEnrollmentsWithSDChanged.contains(Enrol.id)){
                    ehRecord = null;
                    sisExternalId = '';
                }
                if(ehRecord == null){
                
                    if(Enrol.DeltakSRP__Enrollment_Status__c != null && Enrol.DeltakSRP__Enrollment_Status__c != ''){
                        // Add a history record to the list to be inserted
                        DeltakSRP__Enrollment_History__c tmpEhRecord = SRPProgramEnrollmentHandlerTemp.getHistoryRecord(Enrol);
                        if(mapHistoryInclude.get(tmpEhRecord.SIS_External_Id__c) == null)
                        {
                            lstHistoryToInsert.add(tmpEhRecord);
                            mapHistoryInclude.put(tmpEhRecord.SIS_External_Id__c, tmpEhRecord);
                        }
                    // Fix for checking current data as well as system data - George Abboud
                        if(tmpEhRecord.DeltakSRP__Status__c != null && tmpEhRecord.DeltakSRP__Status__c == 'Roll'){
                            System.Debug('When an enrollment history record is inserted from program enrollment, and it is determined to have Roll status, it should new.');
                            System.Debug('This happens only when for the same program, the student\'s opportunity goes to Roll status and comes back to Accepted/Admitted for a different term.');
                            tmpEhRecord.DeltakSRP__Status__c = 'New';
                        }
                        if(tmpEhRecord.DeltakSRP__Status__c != null && tmpEhRecord.DeltakSRP__Status__c == 'Drop'){
                            System.Debug('When an enrollment history record is inserted from program enrollment, and it is determined to have Drop status, it should Re-Enter.');
                            System.Debug('This happens only when for the same program, the student\'s opportunity goes to Roll status after lock down and comes back to Accepted/Admitted for a different term.');
                            tmpEhRecord.DeltakSRP__Status__c = 'Re-Enter';
                        }
                        mapHistory.put(sisExternalId,tmpEhRecord);
    
                    }
                
                }
                else
                {
                    
                    ehRecord.DeltakSRP__Status__c = Enrol.DeltakSRP__Enrollment_Status__c;
                
                    if(ehRecord.SIS_External_Id__c == null || ehRecord.SIS_External_Id__c == '')
                    {
                        ehRecord.SIS_External_Id__c = sisExternalId2 + '-' + Enrol.DeltakSRP__Enrollment_Start__c;
                    }
                    
                    if(mapHistoryInclude.get(ehRecord.SIS_External_Id__c) == null)
                    {
                        

                        lstHistoryToUpdate.add(ehRecord);
                        mapHistoryInclude.put(ehRecord.SIS_External_Id__c, ehRecord);   
                    }
                
                }
                
            }
            // Otherwise, update the existing Enrollment History record
            else{
                if(Enrol.DeltakSRP__Enrollment_Status__c == 'Roll' /*|| Enrol.DeltakSRP__Enrollment_Status__c == 'Drop'*/){
                    ehRecord.DeltakSRP__Status__c = Enrol.Opportunity_PE_Update_Value__c;
                }/*else if (Enrol.DeltakSRP__Enrollment_Status__c == 'Drop'){
                    ehRecord.DeltakSRP__Status__c = 'Re-Enter';
                }*/else{
                    ehRecord.DeltakSRP__Status__c = Enrol.DeltakSRP__Enrollment_Status__c;
                }
                
                
                if(ehRecord.SIS_External_Id__c == null || ehRecord.SIS_External_Id__c == '')
                {
                    String abbrev2 = Enrol.DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c;
                    System.debug('abbrev >---> ' + abbrev);
                    String termId = Enrol.DeltakSRP__Enrollment_Start__r.DeltakSRP__SIS_External_Id__c;
                    System.debug('termId >---> ' + termId);
                    
                    if(abbrev2!= null && abbrev2 != '' && termId != null && termId != '' && termId != 'SISTID')
                    {
                        termId = termId.toUppercase();
                        termId = termId.replace(abbrev2.toUppercase() + '-', '');
                        ehRecord.SIS_External_Id__c = sisExternalId + '-' + termId;
                    }
                }
                
                if(mapHistoryInclude.get(ehRecord.SIS_External_Id__c) == null)
                {
                    lstHistoryToUpdate.add(ehRecord);
                    mapHistoryInclude.put(ehRecord.SIS_External_Id__c, ehRecord);   
                }
            }           
        }
        
        if(lstHistoryToInsert.size()>0)
        {
            insert lstHistoryToInsert;
        }
        
        if(lstHistoryToUpdate.size()>0)
        {
            Database.update(lstHistoryToUpdate, false);
        }
        
    }
    
    /**
     * getHistoryRecord.cls
     * @description Helper method for generating Enrollment History records
     */
    public static DeltakSRP__Enrollment_History__c getHistoryRecord(DeltakSRP__Program_Enrollment__c Enrol){
       
        String abbrev = Enrol.DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c;
        System.debug('abbrev >---> ' + abbrev);
        String studentId = Enrol.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c;
        System.debug('studentId >---> ' + studentId);
        String peId = Enrol.DeltakSRP__SIS_External_Id__c;
        System.debug('peId >---> ' + peId);
        String apId = Enrol.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
        System.debug('apId >---> ' + apId);
        String termId = Enrol.DeltakSRP__Enrollment_Start__r.DeltakSRP__SIS_External_Id__c;
        System.debug('termId >---> ' + termId);
        
        String sisExternalId = '';
        
        if(abbrev != null && studentId != null && apId != null && termId != null && peId != null
         && abbrev != '' && studentId != '' && apId != '' && termId != '' && termId != 'SISTID' && peId != '')
        {
            
            studentId = studentId.toUppercase();
            apId = apId.toUppercase();
            peId = peId.toUppercase();
            termId = termId.toUppercase();
            
            studentId = studentId.replace(abbrev.toUppercase() + '-', '');
            apId = apId.replace(abbrev.toUppercase() + '-', '');
            peId = peId.replace(abbrev.toUppercase() + '-', '');
            termId = termId.replace(abbrev.toUppercase() + '-', '');
            
            sisExternalId += abbrev + '-' + studentId + '-' + peId + '-' + apId + '-' + termId;
            
            sisExternalId = sisExternalId.toUppercase();
            
        }
        
        if(sisExternalId == '')
        {
            sisExternalId = Enrol.DeltakSRP__Enrolled_Student__c + '-' + Enrol.Id + '-' + Enrol.DeltakSRP__Academic_Program__c + '-' + Enrol.DeltakSRP__Enrollment_Start__c;
        }
        
        System.debug('sisExternalId >---> ' + sisExternalId);
       
        DeltakSRP__Enrollment_History__c History = new DeltakSRP__Enrollment_History__c(
            DeltakSRP__Enrollment_Id__c     = Enrol.Name,
            DeltakSRP__Program__c               = Enrol.DeltakSRP__Academic_Program__c,
            DeltakSRP__Program_Enrollment__c    = Enrol.Id,
            DeltakSRP__Student__c               = Enrol.DeltakSRP__Enrolled_Student__c,
            DeltakSRP__Status__c                = Enrol.DeltakSRP__Enrollment_Status__c,
            DeltakSRP__Student_Email__c         = Enrol.DeltakSRP__Student_Email__c,
            DeltakSRP__Academic_Term2__c        = Enrol.DeltakSRP__Enrollment_Start__c,
            SIS_External_Id__c                  = sisExternalId
        );
        return History;
    }
}