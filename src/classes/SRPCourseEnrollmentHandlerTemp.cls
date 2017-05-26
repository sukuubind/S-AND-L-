/**
 * CourseEnrollmentHandler.cls
 * @description Trigger Handler for Course Enrollment triggers 
 * @author Charles Howard
 * @date 3/3/2013
 * @amended by George Abboud on 2/5/2015    
 */

public without sharing class SRPCourseEnrollmentHandlerTemp {

    /**
     * handleBeforeUpsert
     * @description handles Before Insert and Before Update actions
     */
    public static void handleBeforeUpsert(List<DeltakSRP__Course_Enrollment__c> newList)
    {
        
        // Do logic to link Course Enrollment with the correct Program Enrollment
        Set<Id> studentIds = new Set<Id>{};
        Set<Id> academicSectionIds = new Set<Id>{};
        
        // Gather the list of Academic Sections for records where the
        //  Program enrollment field is blank
        for (DeltakSRP__Course_Enrollment__c ceRecord : newList){
            academicSectionIds.add(ceRecord.DeltakSRP__Academic_Section__c);
            if(ceRecord.DeltakSRP__Program_Enrollment__c == null){
                studentIds.add(ceRecord.DeltakSRP__Enrolled_Student__c);
            }
        }
        
        // Create a Matrix of Program Enrollment records belonging to 
        //  the group of referenced students for matching up to Course Enrollments
        Map<Id,List<DeltakSRP__Program_Enrollment__c>> programEnrollmentMap = new Map<Id,List<DeltakSRP__Program_Enrollment__c>>{};
        for(DeltakSRP__Program_Enrollment__c peRecord : [
            select Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c 
            from DeltakSRP__Program_Enrollment__c
            where DeltakSRP__Enrolled_Student__c in :StudentIds])
        {
            List<DeltakSRP__Program_Enrollment__c> tempEnrollmentList = programEnrollmentMap.get(peRecord.DeltakSRP__Enrolled_Student__c);
            // If the Map already has a listing for this student
            if(tempEnrollmentList != null){
                tempEnrollmentList.add(peRecord);
                programEnrollmentMap.put(peRecord.DeltakSRP__Enrolled_Student__c, tempEnrollmentList);
            }
            else{
                programEnrollmentMap.put(peRecord.DeltakSRP__Enrolled_Student__c, new List<DeltakSRP__Program_Enrollment__c>{peRecord});
            }
        }
        
        // Query for Academic Section records referenced by Course Enrollment records
        Map<Id, DeltakSRP__Academic_Section__c> extendedRecords = new Map<Id, DeltakSRP__Academic_Section__c>(
            [select Id, DeltakSRP__Academic_Course__r.DeltakSRP__Primary_Program__c, DeltakSRP__Academic_Term__c 
                from DeltakSRP__Academic_Section__c
                where Id in :academicSectionIds]);
        
        // Iterate through the list of Course Enrollments to process
        //  and try to match them up to records from the matrix
        for(DeltakSRP__Course_Enrollment__c ceRecord : newList)
        {
            if(extendedRecords.get(ceRecord.DeltakSRP__Academic_Section__c) != null)
                ceRecord.DeltakSRP__Academic_Start_Date__c = extendedRecords.get(ceRecord.DeltakSRP__Academic_Section__c).DeltakSRP__Academic_Term__c;
            
            if(ceRecord.DeltakSRP__Program_Enrollment__c == null)
            {
                // See if there are any Program Enrollment records for the 
                //  Course Enrollment's student
                List<DeltakSRP__Program_Enrollment__c> peRecords = programEnrollmentMap.get(ceRecord.DeltakSRP__Enrolled_Student__c);
                if(peRecords != null)
                {
                    // See what the primary Program is for the referenced course 
                    DeltakSRP__Academic_Section__c tempSection = extendedRecords.get(ceRecord.DeltakSRP__Academic_Section__c);
                    if(tempSection != null && tempSection.DeltakSRP__Academic_Course__r.DeltakSRP__Primary_Program__c != null)
                    {
                        // See if there's a Program Enrollment that matches the course's primary program
                        for(DeltakSRP__Program_Enrollment__c peRecord : peRecords)
                        {
                            if(peRecord.DeltakSRP__Academic_Program__c == tempSection.DeltakSRP__Academic_Course__r.DeltakSRP__Primary_Program__c)
                            {
                                ceRecord.DeltakSRP__Program_Enrollment__c = peRecord.Id;
                            }
                        }
                    }
                    
                    // If the course enrollment still doesn't have a Program Enrollment
                    //  See if there's an 'active' Program Enrollment for the student
                    if(ceRecord.DeltakSRP__Program_Enrollment__c == null){
                        for(DeltakSRP__Program_Enrollment__c peRecord : peRecords){
                            // If the Program Enrollment is active
                            if(peRecord.DeltakSRP__Enrollment_Status__c != 'Drop' && peRecord.DeltakSRP__Enrollment_Status__c != 'Graduate'){
                                ceRecord.DeltakSRP__Program_Enrollment__c = peRecord.Id;
                            }
                        }
                    }
                    
                    // If the course enrollment still doesn't have a Program Enrollment
                    // Assign it to the first available Program Enrollment              
                    if(ceRecord.DeltakSRP__Program_Enrollment__c == null){
                        ceRecord.DeltakSRP__Program_Enrollment__c = peRecords[0].Id;
                    }
                }
            }
        }
    }
    
    public static Map<String, Boolean> dropMatchMap = new Map<String, Boolean>();
    public static Set<Id> recentlyDroppedCE = new Set<Id>();
    /**
     * handleAfterTrigger
     * @description handles After Insert, After Update, 
     *  After Delete and After Undelete actions
     */
    public static void handleAfterTrigger(Map<Id, DeltakSRP__Course_Enrollment__c> newMap, Map<Id, DeltakSRP__Course_Enrollment__c> oldMap, String mode)
    {
        Set<Id> newProgramEnrollmentIds = new Set<Id>{};
        Set<Id> oldProgramEnrollmentIds = new Set<Id>{};
        Set<Id> fullProgramEnrollmentIds = new Set<Id>{};
        Set<Id> newStudentIds = new Set<Id>{};
        Set<Id> newTermIds = new Set<Id>{};
        Set<Id> courseIds = new Set<Id>{};
        
        List<DeltakSRP__Program_Enrollment__c> peRecordsToUpdate = new List<DeltakSRP__Program_Enrollment__c>{};
        List<DeltakSRP__Enrollment_History__c> historyRecordsToInsert = new List<DeltakSRP__Enrollment_History__c>{};
        List<DeltakSRP__Curriculum_Plan_Entry__c> cpeRecordsToUpsert = new List<DeltakSRP__Curriculum_Plan_Entry__c>{};
        List<DeltakSRP__Course_Enrollment__c> otherCERecordsForSameTerm = new List<DeltakSRP__Course_Enrollment__c>{};
        Set<id> recentlyDroppedCEIdSet = new Set<Id>();
        List<id> ceIdList = new List<Id>();
        
        // Collect Id Sets for processing functions later-on
        if(mode=='Insert' || mode=='Update' || mode=='UnDelete'){
            
            if(mode == 'Update'){
                for(Id ceid : newMap.keySet()){
                    DeltakSRP__Course_Enrollment__c newCE = newMap.get(ceid);
                    DeltakSRP__Course_Enrollment__c oldCE = oldMap.get(ceid);
                    if(newCE.DeltakSRP__Status__c != oldCE.DeltakSRP__Status__c && newCE.DeltakSRP__Status__c == 'Drop'){
                        recentlyDroppedCE.add(ceid);
                        recentlyDroppedCEIdSet.add(ceid);
                    }
                }
            }

            // Collect the set of referenced Program Enrollment ids
            newProgramEnrollmentIds.addAll(SRPCourseEnrollmentHandlerTemp.collectProgramEnrollmentIds(newMap.values()));
            fullProgramEnrollmentIds.addAll(newProgramEnrollmentIds);
            
            // Pull back extended records for all new Course_Enrollment__c records
            List<DeltakSRP__Course_Enrollment__c> extendedRecords = [
                select Id, DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c, DeltakSRP__Academic_Start_Date__c, DeltakSRP__Final_Grade__c, DeltakSRP__Student_Email__c,   
                DeltakSRP__Program_Enrollment__c, DeltakSRP__Program_Enrollment__r.Name, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c,
                DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Start__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c,
                DeltakSRP__Enrolled_Student__c, DeltakSRP__Term_Start__c, DeltakSRP__Course_Units__c
                from DeltakSRP__Course_Enrollment__c 
                where id in :newMap.keySet() Order by CreatedDate DESC
            ];
            
            // For each record, grab the student and term id
            for(DeltakSRP__Course_Enrollment__c ceRecord : extendedRecords){
                ceIdList.add(ceRecord.Id);
                if(mode == 'Insert' || (mode == 'Update' && recentlyDroppedCEIdSet.contains(ceRecord.id))){
                    newStudentIds.add(ceRecord.DeltakSRP__Enrolled_Student__c);
                }
                newTermIds.add(ceRecord.DeltakSRP__Academic_Start_Date__c);
                courseIds.add(ceRecord.DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c);
            }
            
           dropMatchMap = SRPCourseEnrollmentHandlerTemp.buildSISExternalIDToDropMatch(newTermIds, newStudentIds);
            // Get the list of history records to be created for this batch
            SRPCourseEnrollmentHandlerTemp.processEnrollmentHistory(newProgramEnrollmentIds, newStudentIds, newTermIds, ceIdList, recentlyDroppedCEIdSet);
            
            // Get the list of Curriculum Plan Entry records to be upserted
            cpeRecordsToUpsert = SRPCourseEnrollmentHandlerTemp.processCurriculumPlanEntries(newStudentIds, courseIds, extendedRecords); 
        }
        if(mode=='Update' || mode=='Delete'){
            // Collect the set of referenced Program Enrollment ids
            oldProgramEnrollmentIds.addAll(SRPCourseEnrollmentHandlerTemp.collectProgramEnrollmentIds(oldMap.values()));
            fullProgramEnrollmentIds.addAll(oldProgramEnrollmentIds);
        }
        
        // If there are Program Enrollment records to be processed
        if(newProgramEnrollmentIds.size() > 0 || oldProgramEnrollmentIds.size() > 0){
            // Collect the list of Program Enrollment records to have their
            //  grade fields rolled up
            peRecordsToUpdate = SRPCourseEnrollmentHandlerTemp.rollUpPEGradeFields(fullProgramEnrollmentIds);
        }
        
        System.debug('historyRecordsToInsert >---> ' + historyRecordsToInsert);
        
        // Insert and update records as needed
        
        
        if(cpeRecordsToUpsert.size() > 0)
            Database.upsert(cpeRecordsToUpsert);
        if(peRecordsToUpdate.size() > 0)
            Database.update(peRecordsToUpdate);
    }   
    
    public static Map<String, Boolean> buildSISExternalIDToDropMatch(Set<Id> newTermIds, Set<Id> studentIds){
        Map<String, Boolean> returnMap = new Map<String, Boolean>();
        List<DeltakSRP__Course_Enrollment__c> otherCERecordsForSameTerm = [SELECT Id,DeltakSRP__Program_Enrollment__r.Name, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c,
                                    DeltakSRP__Student_Email__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c,
                                    DeltakSRP__Academic_Start_Date__c, DeltakSRP__Program_Enrollment__c,
                                    DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c, DeltakSRP__Status__c,
                                    DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c,
                                    DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
                                    DeltakSRP__Academic_Start_Date__r.DeltakSRP__SIS_External_Id__c
                                    FROM DeltakSRP__Course_Enrollment__c
                                    where DeltakSRP__Academic_Start_Date__c IN :newTermIds and DeltakSRP__Enrolled_Student__c IN :studentids];
        Map<String, Integer> countOfCEForStudentId = new Map<String, Integer>();
        Map<String, Integer> countOfDropCEForStudentId = new Map<String, Integer>();
        for(DeltakSRP__Course_Enrollment__c thisCE : otherCERecordsForSameTerm){
            String sisExternalId = buildExternalIDFromCoureseEnrollment(thisCE);
            System.Debug('sisExternalId -- drop match'+sisExternalId);
            Integer tempCountForSisExternalId = 0;
            if(countOfCEForStudentId != null && countOfCEForStudentId.containsKey(sisExternalId)){
                tempCountForSisExternalId = countOfCEForStudentId.get(sisExternalId);
            }
            tempCountForSisExternalId++;
            countOfCEForStudentId.put(sisExternalId, tempCountForSisExternalId );
            
            Integer tempDropCountForSisExternalId = 0;
            System.Debug('thisCE -- Status '+thisCE.DeltakSRP__Status__c);
            if(thisCE.DeltakSRP__Status__c == 'Drop'){
              if(countOfDropCEForStudentId != null && countOfDropCEForStudentId.containsKey(sisExternalId)){
                tempDropCountForSisExternalId = countOfDropCEForStudentId.get(sisExternalId);
                }
            tempDropCountForSisExternalId++;  
            }
            
            countOfDropCEForStudentId.put(sisExternalId, tempDropCountForSisExternalId);
            System.Debug(' countOfCEForStudentId -- '+countOfCEForStudentId);
            System.Debug('countOfDropCEForStudentId -- '+countOfDropCEForStudentId);
        }
        for(String thisSISExternalId : countOfCEForStudentId.keySet()){
            Integer totalCount = countOfCEForStudentId.get(thisSISExternalId);
            Integer totalDropCount = countOfDropCEForStudentId.get(thisSISExternalId);
            if(totalCount == totalDropCount){
                returnMap.put(thisSISExternalId, true);
            }else{
                returnMap.put(thisSISExternalId, false);
            }
        }


        System.Debug('returnMap -- '+returnMap);
        return returnMap;
    }



    /**
     * collectProgramEnrollmentIds
     * @description helper method to collect the list of id
     *  values of referenced program enrollment records
     */
    public static Set<Id> collectProgramEnrollmentIds(List<DeltakSRP__Course_Enrollment__c> courseEnrollments){
        Set<Id> idset = new Set<Id>{};
        for(DeltakSRP__Course_Enrollment__c ceRecord : courseEnrollments){
            if(ceRecord.DeltakSRP__Program_Enrollment__c != null)
                idset.add(ceRecord.DeltakSRP__Program_Enrollment__c);
        }
        return idset;
    }
    
    public static String buildExternalIDFromCoureseEnrollment(DeltakSRP__Course_Enrollment__c course){
        String abbrev = course.DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c;
        System.debug('abbrev >---> ' + abbrev);
        String studentId = course.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c;
        System.debug('studentId >---> ' + studentId);
        String peId = course.DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c;
        System.debug('peId >---> ' + peId);
        String apId = course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
        System.debug('apId >---> ' + apId);
        String termId = course.DeltakSRP__Academic_Start_Date__r.DeltakSRP__SIS_External_Id__c;
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
            sisExternalId = course.DeltakSRP__Enrolled_Student__c + '-' + course.DeltakSRP__Program_Enrollment__c + '-' + course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c + '-' + course.DeltakSRP__Academic_Start_Date__c;
        }
        
        System.debug('sisExternalId >---> ' + sisExternalId);
        return sisExternalId;
    }


    /**
     * collectProgramEnrollmentIds
     * @description helper method that generates an Enrollment_History__c record
     *  from a Course_Enrollment__c
     */ 
    public static DeltakSRP__Enrollment_History__c createEnrollmentHistory(DeltakSRP__Course_Enrollment__c course){
        
        System.debug('eh for ' + course.Id);
        String sisExternalId = buildExternalIDFromCoureseEnrollment(course);
        Boolean dropStatus = false; 
        if(dropMatchMap != null && dropMatchMap.containsKey(sisExternalId)){
            dropStatus = dropMatchMap.get(sisExternalId);
        }
        String statusForEH = course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c;
        if(dropStatus == true){
            if(statusForEH == 'Roll'){
                    statusForEH = 'Roll';
                }else{
                    statusForEH = 'Drop';
                }
        }else{
            if(course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c == 'Drop'){
                statusForEH = 'New';
            }else{
                statusForEH = course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c;
            }
        }
        
        return new DeltakSRP__Enrollment_History__c(
            DeltakSRP__Enrollment_Id__c        = course.DeltakSRP__Program_Enrollment__r.Name,
            DeltakSRP__Program__c              = course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c, 
            DeltakSRP__Student_Email__c        = course.DeltakSRP__Student_Email__c, 
            DeltakSRP__Program_Enrollment__c   = course.DeltakSRP__Program_Enrollment__c,
            DeltakSRP__Student__c              = course.DeltakSRP__Enrolled_Student__c,
            DeltakSRP__Status__c               = statusForEH,
            //DeltakSRP__Status__c               = (dropStatus==true ? 'Drop' : course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c == 'Drop' ? 'New' : course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c) ,
            //DeltakSRP__Status__c               = (course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c == 'Drop' ? 'New' : course.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c) ,
            DeltakSRP__Academic_Term2__c       = course.DeltakSRP__Academic_Start_Date__c,
            SIS_External_Id__c                 = sisExternalId
        );
    }
    
    /**
     * collectProgramEnrollmentIds
     * @description processing method that handles creating Enrollment_History__c records
     *  if they are needed
     */ 
    @future 
    public static void processEnrollmentHistory(set<Id> programIdSet, set<Id> studentIdSet, set<Id> terms, List<Id> ceRecordsList, Set<id> recentlyDroppedCEIdSet){ 
        List<DeltakSRP__Course_Enrollment__c> ceRecords = [select Id, DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c, DeltakSRP__Academic_Start_Date__c, DeltakSRP__Final_Grade__c, DeltakSRP__Student_Email__c,   
                DeltakSRP__Program_Enrollment__c, DeltakSRP__Program_Enrollment__r.Name, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c,
                DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Start__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c,
                DeltakSRP__Enrolled_Student__c, DeltakSRP__Term_Start__c, DeltakSRP__Course_Units__c
                from DeltakSRP__Course_Enrollment__c 
                where id in :ceRecordsList Order by CreatedDate DESC];
        
        List<DeltakSRP__Enrollment_History__c> ehList = [ select Id,DeltakSRP__Program_Enrollment__c,DeltakSRP__Student__c,DeltakSRP__Academic_Term2__c, SIS_External_Id__c,
                                        DeltakSRP__Program__c, CreatedDate,  DeltakSRP__Student__r.Account.Abbreviation__c, DeltakSRP__Student__r.DeltakSRP__Student_Id__c,
                                        DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
                                        DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Term2__r.DeltakSRP__SIS_External_Id__c
                                        from DeltakSRP__Enrollment_History__c
                                        where DeltakSRP__Student__c in :studentIdSet
                                        ORDER BY CreatedDate ASC
                                        ];
        
        Map<String,DeltakSRP__Enrollment_History__c> ehListToUpd = new Map<String,DeltakSRP__Enrollment_History__c>();
                                        
        for(DeltakSRP__Enrollment_History__c eh : ehList)
        {
            
            String abbrev = eh.DeltakSRP__Student__r.Account.Abbreviation__c;
            System.debug('abbrev >---> ' + abbrev);
            String studentId = eh.DeltakSRP__Student__r.DeltakSRP__Student_Id__c;
            System.debug('studentId >---> ' + studentId);
            String peId = eh.DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c;
            System.debug('peId >---> ' + peId);
            String apId = eh.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
            System.debug('apId >---> ' + apId);
            String termId = eh.DeltakSRP__Academic_Term2__r.DeltakSRP__SIS_External_Id__c;
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
                sisExternalId = eh.DeltakSRP__Student__c + '-' + eh.DeltakSRP__Program_Enrollment__c + '-' + eh.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c + '-' + eh.DeltakSRP__Academic_Term2__c;
            }
            
            System.debug('sisExternalId >---> ' + sisExternalId);
            
            if((eh.SIS_External_Id__c == null || eh.SIS_External_Id__c == '') && sisExternalId != '' && ehListToUpd.get(sisExternalId) == null)
            {
                eh.SIS_External_Id__c = sisExternalId;
                ehListToUpd.put(sisExternalId,eh);
            }
            
        } 
        
        
        Database.update(ehListToUpd.values(),false);                          
        
        
        // Query for the list of existing History records
        map<string,DeltakSRP__Enrollment_History__c> historyMap = new map<string,DeltakSRP__Enrollment_History__c>();         
        for(DeltakSRP__Enrollment_History__c historyRecord:[ select Id,DeltakSRP__Program_Enrollment__c,DeltakSRP__Student__c,DeltakSRP__Academic_Term2__c, SIS_External_Id__c 
                                        from DeltakSRP__Enrollment_History__c
                                        where DeltakSRP__Student__c in :studentIdSet 
                                        and DeltakSRP__Program_Enrollment__c in :programIdSet 
                                        and DeltakSRP__Academic_Term2__c in :terms
                                        ] )
        {
            
            historyMap.put(historyRecord.SIS_External_Id__c, historyRecord);
        }
        
        List<DeltakSRP__Course_Enrollment__c> ceRecordsExtended = [SELECT Id,DeltakSRP__Program_Enrollment__r.Name, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c,
                                    DeltakSRP__Student_Email__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrollment_Status__c,
                                    DeltakSRP__Academic_Start_Date__c, DeltakSRP__Program_Enrollment__c,
                                    DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c,
                                    DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c, DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c,
                                    DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c,
                                    DeltakSRP__Academic_Start_Date__r.DeltakSRP__SIS_External_Id__c , DeltakSRP__Status__c
                                    FROM DeltakSRP__Course_Enrollment__c
                                    WHERE Id IN :ceRecords and
                                          DeltakSRP__Enrolled_Student__c IN :studentIdSet];
        
        // Iterate over the list of Course Enrollment records and create the 
        //  list of history records to be inserted
        List<DeltakSRP__Enrollment_History__c> ehReturnList = new List<DeltakSRP__Enrollment_History__c>{};
        for(DeltakSRP__Course_Enrollment__c ceRecord : ceRecordsExtended){     
            // If there is not existing History record for the Program, Student and Term
            System.debug('historyMap Before '+ historyMap.values().size() + '  >---> ' + historyMap);
            
            String abbrev = ceRecord.DeltakSRP__Enrolled_Student__r.Account.Abbreviation__c;
            System.debug('abbrev >---> ' + abbrev);
            String studentId = ceRecord.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Id__c;
            System.debug('studentId >---> ' + studentId);
            String peId = ceRecord.DeltakSRP__Program_Enrollment__r.DeltakSRP__SIS_External_Id__c;
            System.debug('peId >---> ' + peId);
            String apId = ceRecord.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
            System.debug('apId >---> ' + apId);
            String termId = ceRecord.DeltakSRP__Academic_Start_Date__r.DeltakSRP__SIS_External_Id__c;
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
                sisExternalId = ceRecord.DeltakSRP__Enrolled_Student__c + '-' + ceRecord.DeltakSRP__Program_Enrollment__c + '-' + ceRecord.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__c + '-' + ceRecord.DeltakSRP__Academic_Start_Date__c;
            }
            
            System.debug('Checking EH sisExternalId >---> ' + sisExternalId);
            System.Debug('recentlyDroppedCE -- '+recentlyDroppedCE);
            System.Debug('ceRecord.id -- '+ceRecord.id);
            System.Debug('ceRecord -- '+ceRecord);                   
            if(historyMap.get(sisExternalId) == null ||  recentlyDroppedCE.contains(ceRecord.id))
            {
                DeltakSRP__Enrollment_History__c tempHistory = createEnrollmentHistory(ceRecord);
                if(tempHistory.DeltakSRP__Program_Enrollment__c != null){
                    ehReturnList.add(tempHistory);  
           
                //Fix for checking current data in addition to what's in the system - by George Abboud
                historyMap.put(sisExternalId, tempHistory);

                } 
            }
            
            System.debug('historyMap After '+ historyMap.values().size() + ' >---> ' + historyMap);
            
        }
        
        if(ehReturnList.size() > 0)
            upsert ehReturnList SIS_External_Id__c;
        
    }
    
    /**
     * collectProgramEnrollmentIds
     * @description processing method that handles the logic to roll up grade values
     *  for the C, D and F grade fields on related Program Enrollment records
     */     
    public static List<DeltakSRP__Program_Enrollment__c> rollUpPEGradeFields(Set<Id> peRecordIds)
    {
        // Create a map to hold unique versions of the records to be updated
        Map<Id, DeltakSRP__Program_Enrollment__c> updatedPERecords = new Map<Id, DeltakSRP__Program_Enrollment__c>{};
        
        // Get the entire set of Course Enrollment records attached to the group of referenced
        //  Program Enrollment records
        for(DeltakSRP__Course_Enrollment__c ceRecord : 
            [select Id, DeltakSRP__Final_Grade__c, DeltakSRP__Course_Units__c, DeltakSRP__Program_Enrollment__c
                from DeltakSRP__Course_Enrollment__c 
                where DeltakSRP__Program_Enrollment__c in :peRecordIds])
        {
            // Declare a dummy PE record
            DeltakSRP__Program_Enrollment__c tempPE;
            
            // If there's already a program enrollment record in our map
            if(updatedPERecords.get(ceRecord.DeltakSRP__Program_Enrollment__c) != null){
                // Update the existing program enrollment record
                tempPE = updatedPERecords.get(ceRecord.DeltakSRP__Program_Enrollment__c);
            }
            else{
                // Create a new Program Enrollment record
                tempPE = new DeltakSRP__Program_Enrollment__c(
                    Id = ceRecord.DeltakSRP__Program_Enrollment__c,
                    DeltakSRP__Total_Units__c = 0,
                    DeltakSRP__Grade_C_Count__c = 0,
                    DeltakSRP__Grade_D_Count__c = 0,
                    DeltakSRP__Grade_F_Count__c = 0
                );
            }
            
            if(ceRecord.DeltakSRP__Course_Units__c != null)
                tempPE.DeltakSRP__Total_Units__c = (tempPE.DeltakSRP__Total_Units__c == null) ? ceRecord.DeltakSRP__Course_Units__c : tempPE.DeltakSRP__Total_Units__c + ceRecord.DeltakSRP__Course_Units__c;
            else
                tempPE.DeltakSRP__Total_Units__c = null;

            //tempPE.Total_Units__c += ceRecord.Course_Units__c;
    
            // Add the grade into the correct field if one applies      
            if(SRPCourseEnrollmentHandlerTemp.getCGradeValues().contains(ceRecord.DeltakSRP__Final_Grade__c))
                tempPE.DeltakSRP__Grade_C_Count__c += 1;
            else if (SRPCourseEnrollmentHandlerTemp.getDGradeValues().contains(ceRecord.DeltakSRP__Final_Grade__c))
                tempPE.DeltakSRP__Grade_D_Count__c += 1;
            else if (SRPCourseEnrollmentHandlerTemp.getFGradeValues().contains(ceRecord.DeltakSRP__Final_Grade__c))
                tempPE.DeltakSRP__Grade_F_Count__c += 1;
            
            updatedPERecords.put(tempPE.Id, tempPE);
        }
        return updatedPERecords.values();
    }
    
    /**
     * collectProgramEnrollmentIds
     * @description processing method that handles the logic to automatically link
     *  Course Enrollment records to existing Curriculum Plan entry records
     */         
    public static List<DeltakSRP__Curriculum_Plan_Entry__c> processCurriculumPlanEntries (Set<Id> studentIdSet, Set<Id> courseIdSet, List<DeltakSRP__Course_Enrollment__c> fullRecordsList)
    {   
        Map<String, DeltakSRP__Curriculum_Plan_Entry__c> cPlanEntryMap = new Map<String, DeltakSRP__Curriculum_Plan_Entry__c>{};
        Map<String, String> activePlanMap = new Map<String, String>{};       
        
        // Create a Map of ALL Course Entries that exist for the set of students and courses
        Map<String, DeltakSRP__Course_Enrollment__c> mostRecentMap = new Map<String, DeltakSRP__Course_Enrollment__c>{};
        for(DeltakSRP__Course_Enrollment__c ceRecord : 
            [select Id, DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c, DeltakSRP__Term_Start__c, DeltakSRP__Enrolled_Student__c 
                from DeltakSRP__Course_Enrollment__c
                where DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c in :courseIdSet
                and DeltakSRP__Enrolled_Student__c in :studentIdSet])
        {
            // If the map does not contain an entry for the student and course, or the map's entry is
            //  less recent than the current Course enrollment record, put an entry into the map for the 
            //  current record
            DeltakSRP__Course_Enrollment__c mostRecent = mostRecentMap.get(ceRecord.DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c + '-' + ceRecord.DeltakSRP__Enrolled_Student__c); 
            if( mostRecent == null || mostRecent.DeltakSRP__Term_Start__c < ceRecord.DeltakSRP__Term_Start__c){
                mostRecentMap.put(ceRecord.DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c + '-' + ceRecord.DeltakSRP__Enrolled_Student__c, ceRecord);
            }
        }
        
        // Get the List of Curriculum Plan Entries that currently exist for the 
        //  given Student and Course.  Put them into a map that can be looked up
        //  later.
        for (DeltakSRP__Curriculum_Plan_Entry__c cpe : [
            select Id, DeltakSRP__Course_Enrollment__c, DeltakSRP__Academic_Course__c, DeltakSRP__Student_Curriculum_Plan__r.DeltakSRP__Student__c     
                from DeltakSRP__Curriculum_Plan_Entry__c
                where DeltakSRP__Academic_Course__c in :courseIdSet
                and DeltakSRP__Student_Curriculum_Plan__r.DeltakSRP__Student__c in :studentIdSet
                and DeltakSRP__Student_Curriculum_Plan__r.DeltakSRP__Active__c = :true])
        {
            // Put the current entry into a map
            cPlanEntryMap.put(cpe.DeltakSRP__Academic_Course__c + '-' + cpe.DeltakSRP__Student_Curriculum_Plan__r.DeltakSRP__Student__c, cpe);
        }
        
        // Construct a map of active curriculum plans for this student
        for(DeltakSRP__Curriculum_Plan__c cpRecord : 
            [select Id, DeltakSRP__Student__c 
                from DeltakSRP__Curriculum_Plan__c 
                where DeltakSRP__Student__c in :studentIdSet 
                and DeltakSRP__Active__c = :true])
        {
            // Create a map of Student to Active Curriculum Plan
            activePlanMap.put(cpRecord.DeltakSRP__Student__c, cpRecord.Id);
        }
        
        // Create a new list of Curriculum Plan Entry records to be upserted
        List<DeltakSRP__Curriculum_Plan_Entry__c> cpeRecordsToUpsert = new List<DeltakSRP__Curriculum_Plan_Entry__c>{}; 
        
        // Match up the most recent course enrollment records with Curriculum Plan Entries
        for(DeltakSRP__Course_Enrollment__c ceRecord : mostRecentMap.values()){
            DeltakSRP__Curriculum_Plan_Entry__c cpeRecord = cPlanEntryMap.get(ceRecord.DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c + '-' + ceRecord.DeltakSRP__Enrolled_Student__c);
            // If there is a matching Curriculum Plan Entry and its Course Enrollment record
            //  is not the most recent record, add it to the CPE upsert list 
            if(cpeRecord != null){
                if(cpeRecord.DeltakSRP__Course_Enrollment__c != ceRecord.Id){
                    cpeRecord.DeltakSRP__Course_Enrollment__c = ceRecord.Id;
                    cpeRecordsToUpsert.add(cpeRecord);
                }
            }
            // If there is no Curriculum Plan Entry for the given course, but there
            //  is an active plan for the student
            else if(activePlanMap.get(ceRecord.DeltakSRP__Enrolled_Student__c) != null){
                // Create a new Curriculum Plan Entry
                DeltakSRP__Curriculum_Plan_Entry__c newEntry = new DeltakSRP__Curriculum_Plan_Entry__c(
                    DeltakSRP__Academic_Course__c = ceRecord.DeltakSRP__Academic_Section__r.DeltakSRP__Academic_Course__c,
                    DeltakSRP__Course_Enrollment__c = ceRecord.Id,
                    DeltakSRP__Student_Curriculum_Plan__c = activePlanMap.get(ceRecord.DeltakSRP__Enrolled_Student__c)
                );
                
                cpeRecordsToUpsert.add(newEntry);
            }
        }
        
        return cpeRecordsToUpsert;
    }
    
    
    /**
     * getCourseEnrollmentEnrolledValues
     * @description gets the set of grade values to be considered a C 
     */
    public static Set<String> getCGradeValues()
    {
        Set<String> returnSet = new Set<String>{};
        if(DeltakSRP__GradeCategories__c.getInstance('CGrades') != null){
            for(String tempString : DeltakSRP__GradeCategories__c.getInstance('CGrades').DeltakSRP__Grade_Value__c.split(',')){
                returnSet.add(tempString);
            }           
        }
        else{
            returnSet = new Set<String>{'C'};
        }
        
        return returnSet;
    }
    
    /**
     * getCourseEnrollmentEnrolledValues
     * @description gets the set of grade values to be considered a D 
     */
    public static Set<String> getDGradeValues()
    {
        Set<String> returnSet = new Set<String>{};
        if(DeltakSRP__GradeCategories__c.getInstance('DGrades') != null){
            for(String tempString : DeltakSRP__GradeCategories__c.getInstance('DGrades').DeltakSRP__Grade_Value__c.split(',')){
                returnSet.add(tempString);
            }           
        }
        else{
            returnSet = new Set<String>{'D'};
        }
        
        return returnSet;
    }
    
    /**
     * getCourseEnrollmentEnrolledValues
     * @description gets the set of grade values to be considered an F 
     */
    public static Set<String> getFGradeValues()
    {
        Set<String> returnSet = new Set<String>{};
        if(DeltakSRP__GradeCategories__c.getInstance('FGrades') != null){
            for(String tempString : DeltakSRP__GradeCategories__c.getInstance('FGrades').DeltakSRP__Grade_Value__c.split(',')){
                returnSet.add(tempString);
            }           
        }
        else{
            returnSet = new Set<String>{'F', 'Fail'};
        }
        
        return returnSet;
    }
     
}