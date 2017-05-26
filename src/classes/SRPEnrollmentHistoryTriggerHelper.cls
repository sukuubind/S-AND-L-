public without sharing class SRPEnrollmentHistoryTriggerHelper {

    Private Static Map<ID, DeltakSRP__Program_Enrollment__c> lstProgramEnrollmentsToUpdate = new Map<ID, DeltakSRP__Program_Enrollment__c>();
    Private static boolean IsFindingOrSavingPEs = false;
    Private static Map<String, ID> mapHistoryCurrentAndNext = New Map<String, ID>(); //Key = "EnrollmentID:[next|previous]"
    Private static Set<ID> setHistoryProgramEnrollments = new Set<ID>();
    private static Set<Id> peWithCurrentEhInRoll = new Set<Id>();
    
    public static void handleBeforeUpdate(List<DeltakSRP__Enrollment_History__c> oldRecordList, List<DeltakSRP__Enrollment_History__c> newRecordList){
    	// SRP-2381 - Changes to replace 2 Workflows
    	List<Id> pgmEn = new List<Id>();
    	
    	Map<Id,String> peSSCEmail = new Map<Id,String>();
    	Map<Id,String> peStudentEmail = new Map<Id,String>();
    	for(Integer i = 0;i<newRecordList.size();i++){
    		DeltakSRP__Enrollment_History__c oldRecord = oldRecordList.get(i);
    		DeltakSRP__Enrollment_History__c newRecord = newRecordList.get(i);
    		
    			pgmEn.add(newRecord.DeltakSRP__Program_Enrollment__c);
    		
    	}
    	
    	if(pgmEn!=null && pgmEn.size()>0)
    	{
    		List<DeltakSRP__Program_Enrollment__c> pe_SSC = [Select id, DeltakSRP__Advisor_Email__c, DeltakSRP__Student_Email__c from DeltakSRP__Program_Enrollment__c where id in :pgmEn];
	    	if(pe_SSC!=null && pe_SSC.size()>0)
	    	{
	    		for(DeltakSRP__Program_Enrollment__c pe: pe_SSC)
	    		{
	    			if(pe.DeltakSRP__Advisor_Email__c != null && pe.DeltakSRP__Advisor_Email__c !='')
	    			{
	    				peSSCEmail.put(pe.id,pe.DeltakSRP__Advisor_Email__c);
	    			}
	    			if(pe.DeltakSRP__Student_Email__c != null && pe.DeltakSRP__Student_Email__c !='')
	    			{
	    				peStudentEmail.put(pe.id,pe.DeltakSRP__Student_Email__c);
	    			}
	    				
	    		}	
	    	}
	    	
	    	for(Integer i = 0;i<newRecordList.size();i++){
	    		DeltakSRP__Enrollment_History__c oldRecord = oldRecordList.get(i);
	    		DeltakSRP__Enrollment_History__c newRecord = newRecordList.get(i);
	    		
				if(peSSCEmail.get(newRecord.DeltakSRP__Program_Enrollment__c) != null && peSSCEmail.get(newRecord.DeltakSRP__Program_Enrollment__c) != newRecord.DeltakSRP__Advisor_Email__c){
	    		   newRecord.DeltakSRP__Advisor_Email__c = peSSCEmail.get(newRecord.DeltakSRP__Program_Enrollment__c);
	    		}
	    		if(newRecord.DeltakSRP__Student__c != null && peStudentEmail.get(newRecord.DeltakSRP__Program_Enrollment__c) !=null && peStudentEmail.get(newRecord.DeltakSRP__Program_Enrollment__c) != newRecord.DeltakSRP__Student_Email__c){
	    			newRecord.DeltakSRP__Student_Email__c = peStudentEmail.get(newRecord.DeltakSRP__Program_Enrollment__c);
	    		}
	    		
	    		
	    	}
    	}
    	
    	// SRP-2381 - Changes to replace 2 Workflows
    }
    
    Public Static void SaveAllUpdatedObjects(){
        
        System.debug('Save Entered');
        
        //Avoid unintended recursion
        if(IsFindingOrSavingPEs){
            return;
        } else {
            IsFindingOrSavingPEs = true;
        }
        
        System.debug('Save Engaged');
        System.Debug('lstProgramEnrollmentsToUpdate -- SaveAllUpdatedObjects'+lstProgramEnrollmentsToUpdate);
        if(lstProgramEnrollmentsToUpdate.Size() > 0){
            //try{
                Database.update(lstProgramEnrollmentsToUpdate.values(), true);
            //}catch(Exception e)
            /*{
                System.debug(e);
            }*/
        }
        
        IsFindingOrSavingPEs = false;
    }
    
    Public static void findDropProgramEnrollments(List<DeltakSRP__Program_Enrollment__c> lstProgramEnrollments){
        /* This function will seek to determine if any non-graduate program enrollments 
         * should be reclassified to "Drop" 
         * Developed by: Gabriel Chapman 1/24/16
         * 
         * populate with: [Select id, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c 
                FROM DeltakSRP__Program_Enrollment__c WHERE XXXXXX];
         */
        
        //Avoid unintended recursion
        if(IsFindingOrSavingPEs){
            return;
        } else {
            IsFindingOrSavingPEs = true;
        }
        
        /*List<DeltakSRP__Program_Enrollment__c> lstProgramEnrollments = [SELECT id, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c 
            FROM DeltakSRP__Program_Enrollment__c 
            WHERE ID IN :setProgramEnrollmentIDs];*/
        
        //get Academic Terms and Program Enrollment IDs
        Set<ID> setAcademicPrograms = new Set<ID>();
        Set<ID> setProgramEnrollments = new Set<ID>();

        //filter out all program enrollments with a status of graduate or drop
        for (DeltakSRP__Program_Enrollment__c pe : lstProgramEnrollments){
            if(pe.DeltakSRP__Enrollment_Status__c != 'Graduate' && pe.DeltakSRP__Enrollment_Status__c != 'Drop'){
                setAcademicPrograms.add(pe.DeltakSRP__Academic_Program__c);
                setProgramEnrollments.add(pe.id);
            }
        }
        
        AcademicTermUtility.getCurrentAndNextAcademicTerms(setAcademicPrograms);      
        
        system.debug(AcademicTermUtility.mapProgramsToNextTerm);
        system.debug(AcademicTermUtility.mapProgramsToCurrentTerm);
        
        populateCurrentAndNextHistoryMaps(setProgramEnrollments, AcademicTermUtility.mapProgramsToCurrentTerm, AcademicTermUtility.mapProgramsToNextTerm);
        
        //--
        //Loop through Program enrollments, check for current and next term in the history map and adjust program enrollment as necessary for return / re-enter
    
        for(DeltakSRP__Program_Enrollment__c pe : lstProgramEnrollments){
            if(mapHistoryCurrentAndNext.get(pe.id + ':next') == null){
                System.Debug('Found Drop: ' + pe.id);
                pe.DeltakSRP__Enrollment_Status__c = 'Drop';
                lstProgramEnrollmentsToUpdate.put(pe.id, pe);
            }
        }
        
        IsFindingOrSavingPEs = false; 

    }
    
    Public static void findReturnAndReenterProgramEnrollments(List<DeltakSRP__Enrollment_History__c> lstEHNew){
        /* This function will seek to determine if program enrollments associated with history elements
         * should be reclassified to "Return" or "Re-Enter" Status
         * Developed by: Gabriel Chapman 1/18/16
         */
        mapHistoryCurrentAndNext = new Map<String, ID>();
        //Avoid unintended recursion
        if(IsFindingOrSavingPEs){
            return;
        } else {
            IsFindingOrSavingPEs = true;
        }
        
        //get academic programs and Program enrollments from Enrollment history trigger elements
        Set<ID> setAcademicPrograms = new Set<ID>();
        Set<ID> setProgramEnrollments = new Set<ID>();
		Set<Id> ehWithRollStatus = new Set<Id>();
        Set<Id> setProgramEnrollmentsForDrop = new Set<Id>();
        System.Debug('lstEHNew -- '+lstEHNew);
        for (DeltakSRP__Enrollment_History__c eh : lstEHNew){
            if(eh.deltaksrp__Status__c != 'Drop' && eh.deltaksrp__Status__c != 'Graduate'){
                if(eh.deltaksrp__status__c == 'Roll'){
                	ehWithRollStatus.add(eh.DeltakSRP__Program_Enrollment__c);
                }
                setAcademicPrograms.add(eh.DeltakSRP__Program__c);
                setProgramEnrollments.add(eh.DeltakSRP__Program_Enrollment__c);
            }
            if(eh.deltaksrp__Status__c == 'Drop'){
                setProgramEnrollmentsForDrop.add(eh.DeltakSRP__Program_Enrollment__c);
            }
            
        }
        
        System.debug('setAcademicPrograms: ' + setAcademicPrograms);
        System.debug('setProgramEnrollments: ' + setProgramEnrollments);
        
        AcademicTermUtility.getCurrentAndNextAcademicTerms(setAcademicPrograms);  
        
        System.debug('AcademicTermUtility.mapProgramsToNextTerm: ' + AcademicTermUtility.mapProgramsToNextTerm);
        System.debug('AcademicTermUtility.mapProgramsToCurrentTerm: ' + AcademicTermUtility.mapProgramsToCurrentTerm);

        populateCurrentAndNextHistoryMaps(setProgramEnrollments, AcademicTermUtility.mapProgramsToCurrentTerm, AcademicTermUtility.mapProgramsToNextTerm);
        
        //--
        //Loop through Program enrollments, check for current and next term in the history map and adjust program enrollment as necessary for return / re-enter
        List<DeltakSRP__Program_Enrollment__c> lstProgramEnrollments = 
            [Select id, DeltakSRP__Enrollment_Status__c, Number_of_Enrollment_History__c
                FROM DeltakSRP__Program_Enrollment__c 
                WHERE ID IN :setHistoryProgramEnrollments];
        System.debug('lstProgramEnrollments -->>> '+lstProgramEnrollments);
        System.Debug('mapHistoryCurrentAndNext -- '+mapHistoryCurrentAndNext);
        for(DeltakSRP__Program_Enrollment__c pe : lstProgramEnrollments){
            System.Debug('pe -- '+pe);
            System.Debug('pe.id -- '+pe.id);
            System.Debug('pe.DeltakSRP__Enrollment_Status__c -- '+pe.DeltakSRP__Enrollment_Status__c);
            if(pe.DeltakSRP__Enrollment_Status__c == 'Drop'){
                System.Debug('Prior PE is Drop. The new one should be Re-enter Outside');
                pe.DeltakSRP__Enrollment_Status__c = 'Re-enter';
                lstProgramEnrollmentsToUpdate.put(pe.id, pe);
            }else if (pe.DeltakSRP__Enrollment_Status__c == 'Roll' && !ehWithRollStatus.contains(pe.id)){
                //SRP-1661 - Basically, a PE status can only go from Roll to New
                pe.DeltakSRP__Enrollment_Status__c = 'New';
                lstProgramEnrollmentsToUpdate.put(pe.id, pe);
            }else{


                System.Debug(mapHistoryCurrentAndNext.get(pe.id + ':current'));
                System.Debug(mapHistoryCurrentAndNext.get(pe.id + ':next')); 
                if(mapHistoryCurrentAndNext.get(pe.id + ':current') != null && mapHistoryCurrentAndNext.get(pe.id + ':next') != null){
                    if(pe.DeltakSRP__Enrollment_Status__c == 'Drop'){
                        System.Debug('Prior PE is Drop. The new one should be Re-enter Inside');
                        pe.DeltakSRP__Enrollment_Status__c = 'Re-enter';
                    }else if (pe.DeltakSRP__Enrollment_Status__c == 'Roll' && !ehWithRollStatus.contains(pe.id)){
                        //SRP-1661 - Basically, a PE status can only go from Roll to New
                        pe.DeltakSRP__Enrollment_Status__c = 'New';
                        }else{
                        System.Debug('Found Return');
                        pe.DeltakSRP__Enrollment_Status__c = 'Return';
                    }
                   
                    lstProgramEnrollmentsToUpdate.put(pe.id, pe);
                }
                if(mapHistoryCurrentAndNext.get(pe.id + ':current') == null && mapHistoryCurrentAndNext.get(pe.id + ':next') != null){
                    if( pe.Number_of_Enrollment_History__c <= 1){
                        // Purposefully left blank as the program enrollment status should be New and it is by default new.
                    }else if(peWithCurrentEhInRoll.contains(pe.id)){
                    	// Purposefully left blank as current term's enrollment history is roll. PE status should be New and it is by default new.
                    }else{
                       System.Debug('Found Re-enter');
                        pe.DeltakSRP__Enrollment_Status__c = 'Re-enter';
                        lstProgramEnrollmentsToUpdate.put(pe.id, pe); 
                    }
                    
                }
            }
        }
        System.Debug('lstProgramEnrollmentsToUpdate -- '+lstProgramEnrollmentsToUpdate);
        List<DeltakSRP__Program_Enrollment__c> lstProgramEnrollmentsDrop = 
            [Select id, DeltakSRP__Enrollment_Status__c, Number_of_Enrollment_History__c
                FROM DeltakSRP__Program_Enrollment__c 
                WHERE ID IN :setProgramEnrollmentsForDrop];
        for(DeltakSRP__Program_Enrollment__c pe : lstProgramEnrollmentsDrop){
            DeltakSRP__Program_Enrollment__c tempPe = null;
            if(mapHistoryCurrentAndNext != null && mapHistoryCurrentAndNext.get(pe.id+':next') != null){
                continue;
            }
            if(pe.DeltakSRP__Enrollment_Status__c == 'Roll'){
                continue;
            }
            if(lstProgramEnrollmentsToUpdate != null && lstProgramEnrollmentsToUpdate.containsKey(pe.id)){
                tempPe = lstProgramEnrollmentsToUpdate.get(pe.id);
            }else{
                tempPe = pe;
            }
            if(tempPe != null){
                tempPe.DeltakSRP__Enrollment_Status__c = 'Drop';
            lstProgramEnrollmentsToUpdate.put(pe.id, tempPe);
            }
            
        }



        //TODO: Error Handling and Object Caching
        //Database.Update(lstProgramEnrollments, false);
        
        IsFindingOrSavingPEs = false;
    
    }
    
    
    Private static void populateCurrentAndNextHistoryMaps(Set<ID> setProgramEnrollments, Map<ID, ID> mapProgramsToCurrentTerm, Map<ID, ID> mapProgramsToNextTerm){
        /* This function will get enrolmment history for given programs, based on terms for each program,
         * then populate a map with key programenrollmentid:current or programenrollmentid:next 
         * for easy determination if history exists for a given program and term.
         * INPUTS: 
         *      mapProgramsToCurrentTerm key = academic program id, value = current academic term
         *      mapProgramsToNextTerm key = academic program id, value = next academic term
         *      (These maps can be generated via AcademicTermUtility.getCurrentAndNextAcademicTerms)
         * Developed by: Gabriel Chapman 1/24/16
         */
        
        //Get ALL History for program enrollments for current term and next term 
        //filter out graduate status
        List<DeltakSRP__Enrollment_History__c> lstHistory = [Select id, DeltakSRP__Program_Enrollment__c, deltaksrp__status__c, DeltakSRP__Academic_Term2__c, DeltakSRP__Program__c 
             FROM DeltakSRP__Enrollment_History__c 
             WHERE DeltakSRP__Program_Enrollment__c IN :setProgramEnrollments  AND DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c != 'Graduate' AND deltaksrp__Status__c != 'Drop' 
             AND (DeltakSRP__Academic_Term2__c IN :mapProgramsToCurrentTerm.values() OR DeltakSRP__Academic_Term2__c IN :mapProgramsToNextTerm.values())];
        
        System.debug('lstHistory: ' + lstHistory);
        
        //Put into Map: Key = "EnrollmentID:[next|previous]". Value is irrelevant, simple element existence is what we will need
        for(DeltakSRP__Enrollment_History__c eh : lstHistory){
            System.Debug('Inside lstHistory ---->'+eh);
            setHistoryProgramEnrollments.add(eh.DeltakSRP__Program_Enrollment__c); 
            if(eh.DeltakSRP__Academic_Term2__c == AcademicTermUtility.mapProgramsToCurrentTerm.get(eh.DeltakSRP__Program__c)){
               if(eh.deltaksrp__status__c != 'Roll'){
               	 //mapHistoryCurrentAndNext.put(eh.id + ':current', eh.DeltakSRP__Program_Enrollment__c);
                 mapHistoryCurrentAndNext.put(eh.DeltakSRP__Program_Enrollment__c + ':current', eh.DeltakSRP__Program_Enrollment__c);
               }else{
               	peWithCurrentEhInRoll.add(eh.DeltakSRP__Program_Enrollment__c);
               }
            }
            if(eh.DeltakSRP__Academic_Term2__c == AcademicTermUtility.mapProgramsToNextTerm.get(eh.DeltakSRP__Program__c)){
                //mapHistoryCurrentAndNext.put(eh.id + ':next', eh.DeltakSRP__Program_Enrollment__c);
                mapHistoryCurrentAndNext.put(eh.DeltakSRP__Program_Enrollment__c + ':next', eh.DeltakSRP__Program_Enrollment__c);
            }
        }
        System.debug('mapHistoryCurrentAndNext: ' + mapHistoryCurrentAndNext);
        
    }
    
    
    
    public static List<DeltakSRP__Enrollment_History__c> updateEH_FE_ExternalID(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList, Boolean isInsert){
        List<Id> programids = new List<Id>();
        Set<Date> weekStartDateSet = new Set<Date>();
        for(DeltakSRP__Enrollment_History__c eh : enrollmentHistoryList){
            programids.add(eh.DeltakSRP__Program__c);
            Date weekStartDate = Date.today();
            if(isInsert){
                weekStartDate = findWeekStartDate(Date.today());
            }else{
                weekStartDate = findWeekStartDate(eh.createdDate.date()); 
            }
            weekStartDateSet.add(weekStartDate);
        }
        Map<Date, Id> WeekStartDateToTermMasterId = findTermMasterForDates(weekStartDateSet);
        List<DeltakSRP__Academic_Start_Date__c> atList = [Select Id, Academic_Term_Master__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Academic_Program__c IN :programids];
        Map<id, Id> termdIdToMasterId = new Map<id, Id>();
        for(DeltakSRP__Academic_Start_Date__c thisTerm : atList){
            termdIdToMasterId.put(thisTerm.id, thisTerm.Academic_Term_Master__c); 
        }
        
        List<DeltakSRP__Enrollment_History__c> ehToUpdate = new List<DeltakSRP__Enrollment_History__c>();
        for(DeltakSRP__Enrollment_History__c eh1:enrollmentHistoryList){
            DeltakSRP__Enrollment_History__c eh = eh1;
            Date weekStartDate = Date.today();
            if(isInsert){
                weekStartDate = findWeekStartDate(Date.today());
            }else{
                weekStartDate = findWeekStartDate(eh1.createdDate.date()); 
            } 
            eh.Week_Start_Date__c = weekStartDate;
            String programId = (eh1.DeltakSRP__Program__c != null ? String.valueOf(eh1.DeltakSRP__Program__c) : '');
            //String termMasterId = (termdIdToMasterId.containsKey(eh.DeltakSRP__Academic_Term2__c) ? String.valueOf(termdIdToMasterId.get(eh.DeltakSRP__Academic_Term2__c)) : '');//(eh.DeltakSRP__Academic_Term2__c != null && eh.DeltakSRP__Academic_Term2__r.Academic_Term_Master__c != null ? String.valueOf(eh.DeltakSRP__Academic_Term2__r.Academic_Term_Master__r.id) : '');
            String termMasterid = (WeekStartDateToTermMasterId.containsKey(weekStartDate) ? String.valueOf(WeekStartDateToTermMasterId.get(weekStartDate)) : '');
            eh.Future_Enrollment_External_iD_Group_By__c = String.valueOf(programId).subString(0,15)+'$'+(termMasterId != null && termMasterId != '' ?String.valueOf(termMasterId).subString(0,15) : '')+'$'+weekStartDate;
            eh.FE_External_ID_Group_By__c = String.valueOf(programId).subString(0,15)+'-'+(termMasterId != null &&  termMasterId != '' ?String.valueOf(termMasterId).subString(0,15) : '');
            ehToUpdate.add(eh);
        }
        return ehToUpdate;
    }
    public static Date findWeekStartDate(Date createdDate){
        Date weekstart = createdDate.toStartOfWeek();
        return weekstart;
    }
    public static Date parseExternalID(String externalId){
        String[] returnValue = externalId.split('$', -1);
        Date returnDate = null;
        if(returnValue != null && returnValue.size() > 2){
            returnDate = Date.valueOf(returnValue[2]);
        }
        return returnDate;
    }
    public static Map<Date, Id> findTermMasterForDates(Set<Date> inputDates){
        Map<Date, Id> returnMap = new Map<Date, Id>();
        List<Academic_Term_Master__c> termMasterList = [Select Id, Term_Start_Date__c from Academic_Term_Master__c order by Term_Start_Date__c asc];
        List<Date> termStartDates = new List<Date>();
        Map<Date, Id> termStartDateToMasterId = new Map<Date, Id>();
        for(Academic_Term_Master__c thisMaster : termMasterList){
            termStartDates.add(thisMaster.Term_Start_Date__c);
            termStartDateToMasterId.put(thisMaster.Term_Start_Date__c, thisMaster.Id);
        }
        termStartDates.sort();
        
        for(Date thisDate : inputDates){
            for(Integer i =0;i < termStartDates.size(); i++){
                if(thisDate <= termStartDates.get(i)){
                    if(i==0){
                        i=1;
                    }
                    if(thisDate.month() == 8){
                        returnMap.put(thisDate, termStartDateToMasterId.get(termStartDates.get(i)));
                    }else{
                        returnMap.put(thisDate, termStartDateToMasterId.get(termStartDates.get(i-1)));
                    }
                    break;
                }
            }
        }
        
     return returnMap;   
    }
    // AFTER INSERT
   /* public static void updateEarliest_Term_Start_Date(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList, Boolean isInsert){
        if(enrollmentHistoryList!=null && enrollmentHistoryList.size()>0)
        {
            
            Map<Id,Date> studentTermDateMap = new Map<Id, Date>();
            for(DeltakSRP__Enrollment_History__c eh:enrollmentHistoryList)
            {
                Date termStartDate = null;
                Id studentId = null;
                termStartDate = eh.DeltakSRP__Term_Start__c;
                studentId = eh.DeltakSRP__Student__c;
                studentTermDateMap.put(studentId,termStartDate);
            }
            Set<Id> students = studentTermDateMap.keySet();
            List<Id> studentList = new List<Id>();
            studentList.addAll(students);
            Map<Id, Date> studentEarlyTermStDate = new Map<Id, Date>();
            
            List<Contact> studentDates = [Select id, Earliest_Term_Start_Date__c from Contact where id in :students];
            
            for(Contact st1: studentDates)
            {
                studentEarlyTermStDate.put(st1.id,st1.Earliest_Term_Start_Date__c);
            }
            Map<Id,Date> studentNewETermStDate = new Map<Id,Date>();
            for(Id st2: studentList)
            {
                if(studentTermDateMap.get(st2)!=null)
                {
                    if(studentEarlyTermStDate.get(st2)==null )
                    {
                        studentNewETermStDate.put(st2,studentTermDateMap.get(st2)); 
                    }
                    else if(studentEarlyTermStDate.get(st2) > studentTermDateMap.get(st2))
                    {
                        studentNewETermStDate.put(st2,studentTermDateMap.get(st2)); 
                    }
                }
            
            }
            if(!studentNewETermStDate.isEmpty())
            {
                Set<Id> studentUpd = studentNewETermStDate.keySet();
                List<Id> studentUpdList = new List<Id>();
                studentUpdList.addAll(studentUpd);
                List<Contact> student = [Select id, Earliest_Term_Start_Date__c from Contact where id in :studentUpdList];
                List<Contact> studentUpdList1 = new List<Contact>();
                for(Contact st: student)
                {
                    Contact st2 = new Contact(id=st.id);
                    st2.Earliest_Term_Start_Date__c = studentNewETermStDate.get(st.id);
                    studentUpdList1.add(st2);
                }
                if(studentUpdList1!=null && studentUpdList1.size()>0)
                {
                    try{
                    Database.update(studentUpdList1);
                    }catch(Exception e)
                    {
                        System.debug(e);
                    }
                }
            }
            
        }
        
    
    }
    // AFTER DELETE
    public static void updateEarliest_Term_Start_Date(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList){
        if(enrollmentHistoryList!=null && enrollmentHistoryList.size()>0)
        {
            List<Id> studentIds = new List<Id>();
            
            for(DeltakSRP__Enrollment_History__c eh:enrollmentHistoryList)
            {
                studentIds.add(eh.DeltakSRP__Student__c);
                
            }
            // Get Earliest Term Start Date
            List<AggregateResult> eTermStDt = [select DeltakSRP__Student__r.Id st, MIN(DeltakSRP__Term_Start__c) estDt
                                                from DeltakSRP__Enrollment_History__c where DeltakSRP__Student__r.Id in: studentIds 
                                                group by DeltakSRP__Student__r.Id]; 
            Map<String, Date> studentNewETermStDate = new Map<String, Date>();
            Date newEarlyTermStDt = null;
            for(AggregateResult ar:eTermStDt)
            {
                studentNewETermStDate.put(String.valueOf(ar.get('st')),Date.valueOf(ar.get('estdt')));
                newEarlyTermStDt = Date.valueOf(ar.get('expr0'));
            }
            
            Map<String, Date> studentETermStDate = new Map<String, Date>();
            Date earlyTermStDt = null;
            Date earlyTermStDtUpd = null;
            List<Contact> student = [Select id, Earliest_Term_Start_Date__c from Contact where id = :studentIds];
            for(Contact st: student)
            {
                studentETermStDate.put(st.id, st.Earliest_Term_Start_Date__c);
            }
            
            Map<Id,Date> studentFinalETermStDate = new Map<Id,Date>();
            for(Id stu: studentIds)
            {
                if(studentETermStDate.get(stu)==null)
                {
                    studentFinalETermStDate.put(stu,studentNewETermStDate.get(stu));
                }
                else if(studentETermStDate.get(stu) > studentNewETermStDate.get(stu))
                {
                    studentFinalETermStDate.put(stu,studentNewETermStDate.get(stu));
                }
            }
            if(!studentFinalETermStDate.isEmpty())
            {
                Set<Id> studentUpd = studentFinalETermStDate.keySet();
                List<Id> studentUpdList = new List<Id>();
                studentUpdList.addAll(studentUpd);
                List<Contact> student1 = [Select id, Earliest_Term_Start_Date__c from Contact where id in :studentUpdList];
                List<Contact> studentUpdList1 = new List<Contact>();
                for(Contact st: student1)
                {
                    Contact st2 = new Contact(id=st.id);
                    st2.Earliest_Term_Start_Date__c = studentFinalETermStDate.get(st.id);
                    studentUpdList1.add(st2);
                }
                if(studentUpdList1!=null && studentUpdList1.size()>0)
                {
                    try{
                    Database.update(studentUpdList1);
                    }catch(Exception e)
                    {
                        System.debug(e);
                    }
                }
            }
        }
        
    
    }
    // AFTER UPDATE
    public static void updateEarliest_Term_Start_Date(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList, Map<Id, DeltakSRP__Enrollment_History__c> oldMap, Boolean isInsert){
        if(enrollmentHistoryList!=null && enrollmentHistoryList.size()>0)
        {
            Map<Id,Date> studentTermDateMap = new Map<Id, Date>();
            Map<Id,Id> studentEnrollHistMap = new Map<Id,Id>();
            Map<Id,Id> studentTermMap = new Map<Id,Id>();
            for(DeltakSRP__Enrollment_History__c eh:enrollmentHistoryList)
            {
                Date termStartDate = null;
                Id studentId = null;
                termStartDate = eh.DeltakSRP__Term_Start__c;
                studentId = eh.DeltakSRP__Student__c;
                studentTermDateMap.put(studentId,termStartDate);
                studentEnrollHistMap.put(studentId,eh.id);
                studentTermMap.put(studentId,eh.DeltakSRP__Academic_Term2__r.id);
            }
            
            Set<Id> students = studentTermDateMap.keySet();
            List<Id> studentList = new List<Id>();
            studentList.addAll(students);
            Map<Id, Date> studentEarlyTermStDate = new Map<Id, Date>();
            
            List<Contact> studentDates = [Select id, Earliest_Term_Start_Date__c from Contact where id in :students];
            
            for(Contact st1: studentDates)
            {
                studentEarlyTermStDate.put(st1.id,st1.Earliest_Term_Start_Date__c);
            }
            
            Map<Id,Date> studentNewETermStDate = new Map<Id,Date>();
            for(Id st2: studentList)
            {
                if(studentTermDateMap.get(st2)!=null)
                {
                    if(studentEarlyTermStDate.get(st2)==null )
                    {
                        studentNewETermStDate.put(st2,studentTermDateMap.get(st2)); 
                    }
                    else 
                    {
                        //String.valueOf(((studentEnrollHistMap.get(st2)).DeltakSRP__Academic_Term2__c))
                        String termId = '';
                        termId = String.valueOf([select DeltakSRP__Academic_Term2__r.Id from DeltakSRP__Enrollment_History__c d  where DeltakSRP__Student__r.Id =: st2]);
                        System.debug('termId-->'+termId);
                        if(String.valueOf(studentTermMap.get(st2)) != termId)
                        {
                            if(studentEarlyTermStDate.get(st2) > studentTermDateMap.get(st2))
                            {
                                studentNewETermStDate.put(st2,studentTermDateMap.get(st2)); 
                            }
                        }

                    }
                }
            
            }
            
            if(!studentNewETermStDate.isEmpty())
            {
                Set<Id> studentUpd = studentNewETermStDate.keySet();
                List<Id> studentUpdList = new List<Id>();
                studentUpdList.addAll(studentUpd);
                List<Contact> student = [Select id, Earliest_Term_Start_Date__c from Contact where id in :studentUpdList];
                List<Contact> studentUpdList1 = new List<Contact>();
                for(Contact st: student)
                {
                    Contact st2 = new Contact(id=st.id);
                    st2.Earliest_Term_Start_Date__c = studentNewETermStDate.get(st.id);
                    studentUpdList1.add(st2);
                }
                if(studentUpdList1!=null && studentUpdList1.size()>0)
                {
                    try{
                    Database.update(studentUpdList1);
                    }catch(Exception e)
                    {
                        System.debug(e);
                    }
                }
            }   
        }
    
    }*/
    
    /*public static void handleBeforeInsert(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList){
        updateEH_FE_ExternalID(enrollmentHistoryList, true);
    }
    public static void handleBeforeUpdate(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList){
        updateEH_FE_ExternalID(enrollmentHistoryList, false);
    }*/
    //VIGNESH R - UPDATING EARLIEST TERM START DATE ON CONTACT AFTER INSERT AND AFTER UPDATE - CONDITIONALLY
  /*  public static void handleAfterInsert(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList){
        updateEarliest_Term_Start_Date(enrollmentHistoryList, true);
    }
    public static void handleAfterUpdate(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList, Map<Id, DeltakSRP__Enrollment_History__c> oldMap){
        updateEarliest_Term_Start_Date(enrollmentHistoryList, oldMap, false);
    }
    public static void handleAfterDelete(List<DeltakSRP__Enrollment_History__c> enrollmentHistoryList){
        updateEarliest_Term_Start_Date(enrollmentHistoryList);
    }*/
}