public without sharing class SRPGlobalAPIController {
   /*  public static List<Id> createStudentEnrollment(List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl, String orgId)
    {
        List<Id> studentId = new List<Id>();
        
        Map<String, String> fieldTranslationMap = new Map<String, String>();
        List<String> translationFieldList = new List<String>();
        translationFieldList = getAllFieldsWithTranslations(orgId);
        if(translationFieldList.size()>0)
        {
            fieldTranslationMap = loadAllTranslationsForPartner(orgId);
        }
        
        List<String> programSISIds = new List<String>();
        List<String> studentIds = new List<String>();
        List<String> sectionIds = new List<String>();
        System.debug('ga_Affl-->'+ga_Affl);
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                if(affl.programSISId!=null)
                programSISIds.add(affl.programSISId);
                
                if(affl.StudentID!=null)
                studentIds.add(affl.StudentID);
                
                if(affl.SectionId!=null)
                sectionIds.add(affl.SectionId);
                
            }
            
            //Failure Case - no Student Id found
            Map<String,Id> studentIdtoSFIdMap = new Map<String,Id>();
            Map<String,String> studentIdTrimtoStudentIdMap = new Map<String,String>();
            
            List<Contact> studentsList = new List<Contact>();
            if(studentIds!=null && studentIds.size()>0)
            {
                studentsList = [Select id, DeltakSRP__Student_ID__c, Student_Id_Trim__c from Contact where (Student_Id_Trim__c in : studentIds or DeltakSRP__Student_ID__c in: studentIds) and accountId = :orgId]; 
            }
            if(studentsList!=null && studentsList.size()>0) 
            {
                for(Contact st: studentsList)
                {
                    studentIdtoSFIdMap.put(st.Student_Id_Trim__c, st.id);
                    studentIdTrimtoStudentIdMap.put(st.Student_Id_Trim__c, st.DeltakSRP__Student_ID__c);
                }
            }else
            {
                // FAILURE - No Student Found
                return null;
            }
            List<Account> orgDetails = new List<Account>([select id, Name, Abbreviation__c from Account where id = :orgId limit 1]) ;
            String orgAbbr = orgDetails[0].Abbreviation__c;
           
            Map<String, String> studentIdToPgmEnrollSFId = processProgramEnrollment(orgId, orgAbbr, studentIdTrimtoStudentIdMap, studentIdtoSFIdMap, programSISIds, translationFieldList, fieldTranslationMap, ga_Affl);
           // List<Id> ceId = processCourseEnrollment(sectionIds, translationFieldList, fieldTranslationMap, ga_Affl, studentIdToPgmEnrollSFId, studentIdtoSFIdMap, orgId);
            return studentId; 
        }
        else
        {
            return null; 
            //Error Message
        }
    }*/
    public static List<Id> createProgramEnrollment(List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl, String orgId)
    {
        List<Id> studentId = new List<Id>();
        
        Map<String, String> fieldTranslationMap = new Map<String, String>();
        List<String> translationFieldList = new List<String>();
        translationFieldList = getAllFieldsWithTranslations(orgId);
        if(translationFieldList.size()>0)
        {
            fieldTranslationMap = loadAllTranslationsForPartner(orgId);
        }
        
        List<String> programSISIds = new List<String>();
        List<String> studentIds = new List<String>();
        List<String> sectionIds = new List<String>();
        System.debug('ga_Affl-->'+ga_Affl);
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                if(affl.programSISId!=null)
                programSISIds.add(affl.programSISId);
                
                if(affl.StudentID!=null)
                studentIds.add(affl.StudentID);
                
                if(affl.SectionId!=null)
                sectionIds.add(affl.SectionId);
                
            }
            
            //Failure Case - no Student Id found
            Map<String,Id> studentIdtoSFIdMap = new Map<String,Id>();
            Map<String,String> studentIdTrimtoStudentIdMap = new Map<String,String>();
            
            List<Contact> studentsList = new List<Contact>();
            if(studentIds!=null && studentIds.size()>0)
            {
                studentsList = [Select id, DeltakSRP__Student_ID__c, Student_Id_Trim__c from Contact where (Student_Id_Trim__c in : studentIds or DeltakSRP__Student_ID__c in: studentIds) and accountId = :orgId]; 
            }
            if(studentsList!=null && studentsList.size()>0) 
            {
                for(Contact st: studentsList)
                {
                    studentIdtoSFIdMap.put(st.Student_Id_Trim__c, st.id);
                    studentIdTrimtoStudentIdMap.put(st.Student_Id_Trim__c, st.DeltakSRP__Student_ID__c);
                }
            }else
            {
                // FAILURE - No Student Found
                return null;
            }
            List<Account> orgDetails = new List<Account>([select id, Name, Abbreviation__c from Account where id = :orgId limit 1]) ;
            String orgAbbr = orgDetails[0].Abbreviation__c;
           
            Map<String, String> studentIdToPgmEnrollSFId = processProgramEnrollment(orgId, orgAbbr, studentIdTrimtoStudentIdMap, studentIdtoSFIdMap, programSISIds, translationFieldList, fieldTranslationMap, ga_Affl);
           // List<Id> ceId = processCourseEnrollment(sectionIds, translationFieldList, fieldTranslationMap, ga_Affl, studentIdToPgmEnrollSFId, studentIdtoSFIdMap, orgId);
            return studentId; 
        }
        else
        {
            return null; 
            //Error Message
        }
    }
    
     public static List<Id> createCourseEnrollment(List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl, String orgId)
    {
        List<Id> studentId = new List<Id>();
        
        Map<String, String> fieldTranslationMap = new Map<String, String>();
        List<String> translationFieldList = new List<String>();
        translationFieldList = getAllFieldsWithTranslations(orgId);
        if(translationFieldList.size()>0)
        {
            fieldTranslationMap = loadAllTranslationsForPartner(orgId);
        }
        
        List<String> programSISIds = new List<String>();
        List<String> studentIds = new List<String>();
        List<String> sectionIds = new List<String>();
        System.debug('ga_Affl-->'+ga_Affl);
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                if(affl.programSISId!=null)
                programSISIds.add(affl.programSISId);
                
                if(affl.StudentID!=null)
                studentIds.add(affl.StudentID);
                
                if(affl.SectionId!=null)
                sectionIds.add(affl.SectionId);
                
            }
            
            //Failure Case - no Student Id found
            Map<String,Id> studentIdtoSFIdMap = new Map<String,Id>();
            Map<String,String> studentIdTrimtoStudentIdMap = new Map<String,String>();
            
            List<Contact> studentsList = new List<Contact>();
            if(studentIds!=null && studentIds.size()>0)
            {
                studentsList = [Select id, DeltakSRP__Student_ID__c, Student_Id_Trim__c from Contact where (Student_Id_Trim__c in : studentIds or DeltakSRP__Student_ID__c in: studentIds) and accountId = :orgId]; 
            }
            if(studentsList!=null && studentsList.size()>0) 
            {
                for(Contact st: studentsList)
                {
                    studentIdtoSFIdMap.put(st.Student_Id_Trim__c, st.id);
                    studentIdTrimtoStudentIdMap.put(st.Student_Id_Trim__c, st.DeltakSRP__Student_ID__c);
                }
            }else
            {
                // FAILURE - No Student Found
                return null;
            }
            List<Account> orgDetails = new List<Account>([select id, Name, Abbreviation__c from Account where id = :orgId limit 1]) ;
            String orgAbbr = orgDetails[0].Abbreviation__c;
           
            //Map<String, String> studentIdToPgmEnrollSFId = processProgramEnrollment(orgId, orgAbbr, studentIdTrimtoStudentIdMap, studentIdtoSFIdMap, programSISIds, translationFieldList, fieldTranslationMap, ga_Affl);
            Map<String, String> studentIdToPgmEnrollSFId  = new Map<String, String>();
            List<Id> ceId = processCourseEnrollment(orgAbbr, studentIdTrimtoStudentIdMap, sectionIds, translationFieldList, fieldTranslationMap, ga_Affl, studentIdToPgmEnrollSFId, studentIdtoSFIdMap, orgId);
            return studentId; 
        }
        else
        {
            return null; 
            //Error Message
        }
    }
    
    public static List<Id> createCourseSection(List<SRPGLobalAPIService.GA_CourseSection> ga_CorsSec, String orgId)
    {
        List<Id> enrollmentHistId = null;// WRONG - SEND BACK SECTION ID LIST
        //System.debug('ga_CorsSec: '+ga_CorsSec); 
        List<String> programSISIds = new List<String>();
        List<String> sectionIds = new List<String>();
        List<Date> startDateList = new List<Date>();
        Map<String,Date> sectionIdStartDateMap = new Map<String,Date>();
        Map<String,String> sectionIdprogramSISIdMap = new Map<String,String>();
        Map<String,String> pgmSISStartDateSecMap = new Map<String,String>();
        
        Map<String,String> programSISProgramSFIdMap = new Map<String,String>();
        Map<String, String> fieldTranslationMap = new Map<String, String>();
        List<String> translationFieldList = new List<String>();
        translationFieldList = getAllFieldsWithTranslations(orgId);
        if(translationFieldList.size()>0)
        {
            fieldTranslationMap = loadAllTranslationsForPartner(orgId);
        }
        
        
            if(ga_CorsSec!=null && ga_CorsSec.size()>0)
            {  
                for(SRPGLobalAPIService.GA_CourseSection coSec: ga_CorsSec)
                {
                    if(coSec.programSISId!=null)
                    programSISIds.add(coSec.programSISId);
                    sectionIds.add(coSec.sectionId);
                    startDateList.add(coSec.StartDate);
                    sectionIdStartDateMap.put(coSec.sectionId,coSec.StartDate);
                    sectionIdprogramSISIdMap.put(coSec.sectionId,coSec.programSISId);
                    pgmSISStartDateSecMap.put(coSec.programSISId+'-'+coSec.StartDate, coSec.sectionId);
                }
                if(programSISIds!=null && programSISIds.size()>0)
                {
                    List<DeltakSRP__Academic_Program__c> programs = new List<DeltakSRP__Academic_Program__c>([Select id, DeltakSRP__SIS_External_Id__c from DeltakSRP__Academic_Program__c where DeltakSRP__SIS_External_Id__c in : programSISIds]);
                    if(programs!=null && programs.size()>0)
                    {
                        for(DeltakSRP__Academic_Program__c pgm: programs)
                        {
                            programSISProgramSFIdMap.put(pgm.DeltakSRP__SIS_External_Id__c, pgm.id);
                        }
                    }
                }
                System.debug('programSISProgramSFIdMap-->'+programSISProgramSFIdMap);
                Map<String, String> PgmSISStartDtTermIdMap = new Map<String,String>();
                PgmSISStartDtTermIdMap = getAllTermsForPartner(orgId, pgmSISStartDateSecMap, programSISIds, startDateList);
                 
                Map<String,String> sectionCourseSFIdMap = processCourse(translationFieldList, fieldTranslationMap, ga_CorsSec, orgId, programSISProgramSFIdMap);
                enrollmentHistId = processSection(translationFieldList, fieldTranslationMap, ga_CorsSec, sectionCourseSFIdMap, PgmSISStartDtTermIdMap, orgId);
                
                return enrollmentHistId;
            }else
            {
                return null;
                //Error Message
            }
        
        
        
    }
    
     public static Map<String, String> loadAllTranslationsForPartner(String orgId)
    {
        Map<String,String> tSS = new Map<String,String>();
        
        List<Global_API_Translation__c> orgTranslationsList = new List<Global_API_Translation__c>();
        orgTranslationsList = [Select g.What_Field__c, g.Partner_Value__c, g.SF_Value__c From Global_API_Translation__c g where g.Which_Partner__c = : orgId];
        
        
        for(Global_API_Translation__c glAT: orgTranslationsList)
        {
            tSS.put(glAT.What_Field__c+'-'+glAt.Partner_Value__c, glAT.SF_Value__c);
        }
        
        return tSS;
    }
    
    public static List<String> getAllFieldsWithTranslations(String orgId)
    {
        List<Global_API_Translation__c> orgTranslationsList = new List<Global_API_Translation__c>();
        orgTranslationsList = [Select g.What_Field__c, g.Partner_Value__c, g.SF_Value__c From Global_API_Translation__c g where g.Which_Partner__c = : orgId];
        
        List<String> fieldList = new List<String>();
        
        for(Global_API_Translation__c glAT: orgTranslationsList)
        {
            fieldList.add(glAT.What_Field__c);
        }
        
        return fieldList;
    }
    
    public static Map<String,String> getAllTermsForPartner(String orgId, Map<String, String> pgmSISStartDateSecMap, List<String> programSISIds, List<Date> startDateList)
    {
        Map<String, String> PgmSISStartDtTermIdMap = new Map<String, String>();
        // Map to return
        Map<String, String> PgmSISStartDtSecToTermMap = new Map<String, String>();
        System.debug('orgId-->'+orgId);
        System.debug('programSISIds-->'+programSISIds);
        System.debug('startDateList-->'+startDateList);
        List<DeltakSRP__Academic_Start_Date__c> termsList = new List<DeltakSRP__Academic_Start_Date__c>();
        termsList = [Select id, DeltakSRP__Start_Date__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Program__c 
                    from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Academic_Program__r.DeltakSRP__School__r.id = :orgId 
                    and DeltakSRP__Start_Date__c in : startDateList];
        if(termsList!=null && termsList.size()>0)
        {
            for(DeltakSRP__Academic_Start_Date__c term: termsList)
            {
                String programSISId = term.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
                PgmSISStartDtTermIdMap.put(programSISId+'-'+term.DeltakSRP__Start_Date__c, term.id);
            }
        }
        System.debug('PgmSISStartDtTermIdMap-->'+PgmSISStartDtTermIdMap);
        return PgmSISStartDtTermIdMap;
    }
    
    
    public static Map<String,String> processProgramEnrollment(String orgId, String orgAbbr, Map<String,String> studentIdTrimtoStudentIdMap, Map<String,String> studentIdtoSFIdMap, List<String> programSISIds , List<String> translationFieldList, Map<String, String> fieldTranslationMap, List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl)
    {

        
        Map<String, String> studentIdToPESISId = new Map<String, String>(); 
        Map<String, String> PESISIdToPgmEnrollSFId = new Map<String, String>();
        Map<String, String> studentIdToPgmEnrollSFId = new Map<String, String>();
        
        //Failure case - no programs found
        Map<String, Id> PgmSISIdToPgmId = new Map<String, Id>();
        List<DeltakSRP__Academic_Program__c> pgmList = new List<DeltakSRP__Academic_Program__c>([select DeltakSRP__SIS_External_Id__c, id from DeltakSRP__Academic_Program__c where DeltakSRP__SIS_External_Id__c in :programSISIds]);
        if(pgmList!=null && pgmList.size()>0)
        {
            for(DeltakSRP__Academic_Program__c pgm: pgmList)
            {
                PgmSISIdToPgmId.put(pgm.DeltakSRP__SIS_External_Id__c, pgm.id);
            }
        }else
        {
            // FAILURE - No Programs Found
            return null;
        }
        
        Map<String,DeltakSRP__Program_Enrollment__c> programEnrollmentsToProcess = new Map<String,DeltakSRP__Program_Enrollment__c>();
        List<DeltakSRP__Program_Enrollment__c> programEnrollmentIds = new List<DeltakSRP__Program_Enrollment__c>();
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                //Variables
                String programSISId= '';
                String specializationSISId= '';
                String PE_termSISId= '';
                String AdditionalInfo= '';
                String Conditional= '';
                String DoNotRegister= '';
                String DropReason= '';
                Date DropDate= null;
                String EnrollmentStatus= '';
                String GPA= '';
                Date GraduationDate= null;
                Date PE_LastSISUpdate= null;
                String Provisional= '';
                Date PgmStartDate= null;
                String TotalTransferredCredits= '';
                String AdvisorName= '';
                String AdvisorPhoneNumber= '';
                String AdvisorEmail= '';
                String Matriculated= '';
                String Modality= '';
                String PE_SISExternalId= '';
                String StudentID='';
                
                //Null / Empty Check 
                programSISId        = (affl.programSISId != null ? affl.programSISId : '');
                specializationSISId = (affl.specializationSISId != null ? affl.specializationSISId : '');
                PE_termSISId    = (affl.PE_termSISId != null ? affl.PE_termSISId : '');
                AdditionalInfo  = (affl.AdditionalInfo != null ? affl.AdditionalInfo : '');
                Conditional     = (affl.Conditional != null ? affl.Conditional : '');
                DoNotRegister   = (affl.DoNotRegister != null ? affl.DoNotRegister : '');
                DropReason      = (affl.DropReason != null ? affl.DropReason : '');
                DropDate        = (affl.DropDate != null ? affl.DropDate : null);
                EnrollmentStatus= (affl.EnrollmentStatus != null ? affl.EnrollmentStatus : '');
                GPA             = (affl.GPA != null ? affl.GPA : '');
                GraduationDate  = (affl.GraduationDate != null ? affl.GraduationDate : null);
                PE_LastSISUpdate= (affl.PE_LastSISUpdate != null ? affl.PE_LastSISUpdate : null);
                Provisional     = (affl.Provisional != null ? affl.Provisional : '');
                PgmStartDate    = (affl.PgmStartDate != null ? affl.PgmStartDate : null);
                TotalTransferredCredits  = (affl.TotalTransferredCredits != null ? affl.TotalTransferredCredits : '');
                AdvisorName     = (affl.AdvisorName != null ? affl.AdvisorName : '');
                AdvisorPhoneNumber  = (affl.AdvisorPhoneNumber != null ? affl.AdvisorPhoneNumber : '');
                AdvisorEmail    = (affl.AdvisorEmail != null ? affl.AdvisorEmail : '');
                Matriculated    = (affl.Matriculated != null ? affl.Matriculated : '');
                Modality        = (affl.Modality != null ? affl.Modality : '');
                PE_SISExternalId    = (affl.PE_SISExternalId != null ? affl.PE_SISExternalId : '');
                StudentID       = (affl.StudentID != null ? affl.StudentID : '');
                
                // Translation
                Boolean translate = false;
                Set<String> fldList = new Set<String>();
                
                if(translationFieldList!=null && translationFieldList.size()>0)
                {
                    translate = true;
                    fldList.addAll(translationFieldList);
                }
                if(translate)
                {
                    programSISId        = (programSISId!='' && fldList.contains('programSISId')? fieldTranslationMap.get('programSISId-'+programSISId) : programSISId);
                    specializationSISId = (specializationSISId!='' && fldList.contains('specializationSISId')? fieldTranslationMap.get('specializationSISId-'+specializationSISId) : specializationSISId);
                    PE_termSISId        = (PE_termSISId!='' && fldList.contains('PE_termSISId')? fieldTranslationMap.get('PE_termSISId-'+PE_termSISId) : PE_termSISId);
                    AdditionalInfo      = (AdditionalInfo!='' && fldList.contains('AdditionalInfo')? fieldTranslationMap.get('AdditionalInfo-'+AdditionalInfo) : AdditionalInfo);
                    Conditional         = (Conditional!='' && fldList.contains('Conditional')? fieldTranslationMap.get('AdditionalInfo-'+Conditional) : Conditional);
                    DoNotRegister       = (DoNotRegister!='' && fldList.contains('DoNotRegister')? fieldTranslationMap.get('DoNotRegister-'+DoNotRegister) : DoNotRegister);
                    DropReason          = (DropReason!='' && fldList.contains('DropReason')? fieldTranslationMap.get('DropReason-'+DropReason) : DropReason);
                    EnrollmentStatus    = (EnrollmentStatus!='' && fldList.contains('EnrollmentStatus')? fieldTranslationMap.get('EnrollmentStatus-'+EnrollmentStatus) : EnrollmentStatus);
                    GPA                 = (GPA!='' && fldList.contains('GPA')? fieldTranslationMap.get('GPA-'+GPA) : GPA);
                    Provisional         = (Provisional!='' && fldList.contains('Provisional')? fieldTranslationMap.get('Provisional-'+Provisional) : Provisional);
                    TotalTransferredCredits     = (TotalTransferredCredits!='' && fldList.contains('TotalTransferredCredits')? fieldTranslationMap.get('TotalTransferredCredits-'+TotalTransferredCredits) : TotalTransferredCredits);
                    AdvisorName         = (AdvisorName!='' && fldList.contains('AdvisorName')? fieldTranslationMap.get('AdvisorName-'+AdvisorName) : AdvisorName);
                    AdvisorPhoneNumber  = (AdvisorPhoneNumber!='' && fldList.contains('AdvisorPhoneNumber')? fieldTranslationMap.get('AdvisorPhoneNumber-'+AdvisorPhoneNumber) : AdvisorPhoneNumber);
                    AdvisorEmail        = (AdvisorEmail!='' && fldList.contains('AdvisorEmail')? fieldTranslationMap.get('AdvisorEmail-'+AdvisorEmail) : AdvisorEmail);
                    Matriculated        = (Matriculated!='' && fldList.contains('Matriculated')? fieldTranslationMap.get('Matriculated-'+Matriculated) : Matriculated);
                    Modality            = (Modality!='' && fldList.contains('Modality')? fieldTranslationMap.get('Modality-'+Modality) : Modality);
                    PE_SISExternalId    = (PE_SISExternalId!='' && fldList.contains('PE_SISExternalId')? fieldTranslationMap.get('PE_SISExternalId-'+PE_SISExternalId) : PE_SISExternalId);
                    StudentID           = (StudentID !='' && fldList.contains('StudentID')? fieldTranslationMap.get('StudentID-'+StudentID) : StudentID);
                }
                
                // Insert
                if(programSISId!='')
                {
                        SchemaMapObject pgmEnrollSchema = new SchemaMapObject(Schema.SObjectType.DeltakSRP__Program_Enrollment__c.Fields.getMap());
                        DeltakSRP__Program_Enrollment__c pe = new DeltakSRP__Program_Enrollment__c();
                        if(studentIdtoSFIdMap!=null && studentIdtoSFIdMap.get(String.valueOf(Integer.valueOf(StudentID)))!=null)
                        {
                            pe.DeltakSRP__Enrolled_Student__c = pgmEnrollSchema.gsbfl('DeltakSRP__Enrolled_Student__c',studentIdtoSFIdMap.get(String.valueOf(Integer.valueOf(StudentID))));
                        }
                        else
                        {
                            continue;
                        }
                        if(PgmSISIdToPgmId!=null && PgmSISIdToPgmId.get(programSISId)!=null)
                        {
                            pe.DeltakSRP__Academic_Program__c = pgmEnrollSchema.gsbfl('DeltakSRP__Academic_Program__c',PgmSISIdToPgmId.get(programSISId));// WHAT IF NOT FOUND?
                        }
                        else
                        {
                            continue;
                        }
                        String PESISExternalIdNew = orgAbbr+'-'+studentIdTrimtoStudentIdMap.get(StudentID)+'-'+programSISId;
                        pe.DeltakSRP__SIS_External_Id__c = pgmEnrollSchema.gsbfl('DeltakSRP__SIS_External_Id__c',PESISExternalIdNew);
                        //pe.DeltakSRP__Enrollment_Start__c = pgmEnrollSchema.gsbfl('DeltakSRP__Enrollment_Start__c',getTermId(PE_termSISId));
                        //pe.DeltakSRP__Academic_Specialization__c = pgmEnrollSchema.gsbfl('DeltakSRP__Academic_Specialization__c',getSpecializationId(specializationSISId));
                        pe.DeltakSRP__Additional_Info__c = pgmEnrollSchema.gsbfl('DeltakSRP__Additional_Info__c',AdditionalInfo);
                        pe.DeltakSRP__Conditional__c = false;
                        if(Conditional == 'true')
                        {
                            pe.DeltakSRP__Conditional__c = true;
                        }
                        pe.DeltakSRP__Do_Not_Register__c = false; 
                        if(DoNotRegister == 'true')
                        {
                            pe.DeltakSRP__Do_Not_Register__c = true;
                        }
                        pe.DeltakSRP__Drop_Reason__c = pgmEnrollSchema.gsbfl('DeltakSRP__Drop_Reason__c',DropReason); // picklist - needs translation?
                        try{
                            pe.DeltakSRP__Drop_Date__c = DropDate;
                            pe.DeltakSRP__Start_Date__c = PgmStartDate;
                            pe.DeltakSRP__Graduation_Date__c = GraduationDate;
                            pe.DeltakSRP__Last_SIS_Update__c = PE_LastSISUpdate;
                        }catch(Exception exc)
                        {
                            //Add Failure record
                        }
                        pe.Partner_Status__c = pgmEnrollSchema.gsbfl('Partner_Status__c',EnrollmentStatus); // picklist - needs translation?
                        System.debug('GPA, Partner Status, AdvisorName-->'+GPA+', '+EnrollmentStatus+', '+AdvisorName);
                        pe.DeltakSRP__GPA__c = (GPA!=''? Decimal.valueOf(GPA): 0.0);
                       
                        pe.DeltakSRP__Provisional__c = false;
                        if (Provisional== 'true')
                        {
                            pe.DeltakSRP__Provisional__c = true;
                        }
                        
                        pe.DeltakSRP__Total_Units__c = (TotalTransferredCredits!='' ? Decimal.valueOf(TotalTransferredCredits): 0.0);
                       
                        pe.Campus_Advisor__c = pgmEnrollSchema.gsbfl('Campus_Advisor__c',AdvisorName);
                        
                        pe.DeltakSRP__Advisor_Email__c = pgmEnrollSchema.gsbfl('DeltakSRP__Advisor_Email__c',AdvisorEmail);
                        
                        pe.Modality__c = pgmEnrollSchema.gsbfl('Modality__c',Modality); 
                        studentIdToPESISId.put(StudentID,PESISExternalIdNew);
                        programEnrollmentsToProcess.put(PESISExternalIdNew,pe);
                        System.debug('programEnrollmentsToProcess-->'+programEnrollmentsToProcess);
                        programEnrollmentIds.add(pe);
                        
                    }
                }
            
        }
        if(programEnrollmentIds!=null && programEnrollmentIds.size()>0)
        {
            try{
                database.upsert (programEnrollmentsToProcess.values(),DeltakSRP__Program_Enrollment__c.DeltakSRP__SIS_External_Id__c);
                
            }catch(Exception exc)
            {
                System.debug('DML Exception: '+exc.getStackTraceString());
                System.debug('DML Exception: '+exc);
                return null;
            }
           /* List<DeltakSRP__Program_Enrollment__c> insertedPgmEnrollments = new List<DeltakSRP__Program_Enrollment__c>();
            insertedPgmEnrollments = [Select id, DeltakSRP__SIS_External_Id__c from DeltakSRP__Program_Enrollment__c where DeltakSRP__SIS_External_Id__c in :studentIdToPESISId.values()];
            if(insertedPgmEnrollments!=null && insertedPgmEnrollments.size()>0)
            {
                for(DeltakSRP__Program_Enrollment__c pEnroll: insertedPgmEnrollments)
                {
                    PESISIdToPgmEnrollSFId.put(pEnroll.DeltakSRP__SIS_External_Id__c, pEnroll.id);
                }
            }
            for(String studentId: studentIdToPESISId.keySet())
            {
                String PESISId = studentIdToPESISId.get(studentId);
                String PESFId = PESISIdToPgmEnrollSFId.get(PESISId);
                studentIdToPgmEnrollSFId.put(studentId,PESFId);
            }*/
            
        }
        /*if(studentIdToPgmEnrollSFId!=null && studentIdToPgmEnrollSFId.size()>0)
        {
            return studentIdToPgmEnrollSFId;
        }else
        {*/
            return null;
        /*}*/

        
    }
    
  
    
    /*public static Id getTermId(String PE_termSISId)
    {
        Id termId = null;
        List<DeltakSRP__Academic_Start_Date__c> terms = new List<DeltakSRP__Academic_Start_Date__c>([Select d.Id From DeltakSRP__Academic_Start_Date__c d where d.DeltakSRP__SIS_External_Id__c = : PE_termSISId]);
        if(terms!=null && terms.size() > 0)
        {
            for(DeltakSRP__Academic_Start_Date__c t: terms)
            {
                termId = t.id;
            }
        }
        
        return termId;
    }*/
    
   /* public static Id getSpecializationId(String specializationSISId)
    {
        Id specializationId = null;
        List<DeltakSRP__Academic_Specialization__c> specs = new List<DeltakSRP__Academic_Specialization__c>([Select d.Id From DeltakSRP__Academic_Specialization__c d where d.DeltakSRP__External_Id__c = : specializationSISId]);
        if(specs!=null && specs.size() > 0)
        {
            for(DeltakSRP__Academic_Specialization__c s: specs)
            {
                specializationId = s.id;
            }
        }
        
        return specializationId;
    }*/
    
    public static String getSSCUserId(String AdvisorName, String AdvisorPhoneNumber)
    {
        String sscUserId = '';
        List<User> advUsrs = new List<User>();
        if(AdvisorPhoneNumber!=null && AdvisorPhoneNumber !='')
        {
            advUsrs = [select id from User where Name = :AdvisorName and phone = :AdvisorPhoneNumber limit 1];
        }else
        {
            advUsrs= [select id from User where Name = :AdvisorName limit 1];
        }
        
        for(User u: advUsrs)
        {
            sscUserId = String.valueOf(u.id);
        }
        return sscUserId;
    }
    
    public static List<id> processCourseEnrollment(String orgAbbr, Map<String,String> studentIdTrimtoStudentIdMap, List<String> sectionIds, List<String> translationFieldList, Map<String, String> fieldTranslationMap, List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl, Map<String,String> studentIdToPgmEnrollSFId, Map<String, String> studentIdtoSFIdMap, String orgId)
    {
        Map<String, Id> SectionIdToSectionSFId = new Map<String, Id>();
        List<DeltakSRP__Academic_Section__c> sectionList = new List<DeltakSRP__Academic_Section__c>([select DeltakSRP__SIS_External_Id__c, id, DeltakSRP__Section_ID__c, DeltakSRP__Start_Date__c from DeltakSRP__Academic_Section__c where DeltakSRP__Section_ID__c in : sectionIds]);
        if(sectionList!=null && sectionList.size()>0)
        {
            for(DeltakSRP__Academic_Section__c c: sectionList)
            {
                SectionIdToSectionSFId.put(c.DeltakSRP__Section_ID__c+'-'+c.DeltakSRP__Start_Date__c, c.id);
            }
        }else
        {
            // RETURN FAILURE
            return null;    
        }
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            List<String> peSISExtIds = new List<String>();
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                String programSISId = '';
                String StudentID    ='';
                
                programSISId        = (affl.programSISId != null ? affl.programSISId : '');
                StudentID           =   (affl.StudentID != null ? affl.StudentID : '');
                
                // Translation
                Boolean translate = false;
                Set<String> fldList = new Set<String>();
                
                if(translationFieldList!=null && translationFieldList.size()>0)
                {
                    translate = true;
                    fldList.addAll(translationFieldList);
                }
                if(translate)
                {
                    programSISId        = (programSISId!='' && fldList.contains('programSISId')? fieldTranslationMap.get('programSISId-'+programSISId) : programSISId);
                    StudentID           = (StudentID !='' && fldList.contains('StudentID')? fieldTranslationMap.get('StudentID-'+StudentID) : StudentID);
                } 
                            
                String PESISExternalIdNew = orgAbbr+'-'+studentIdTrimtoStudentIdMap.get(StudentID)+'-'+programSISId;
                if(PESISExternalIdNew!='')
                {
                    peSISExtIds.add(PESISExternalIdNew);
                    PESISExternalIdNew = '';
                }
            }
        
            if(peSISExtIds!=null && peSISExtIds.size()>0)
            {
                List<DeltakSRP__Program_Enrollment__c> insertedPgmEnrollments = new List<DeltakSRP__Program_Enrollment__c>();
                insertedPgmEnrollments = [Select id, DeltakSRP__SIS_External_Id__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_ID__c from DeltakSRP__Program_Enrollment__c where DeltakSRP__SIS_External_Id__c in :peSISExtIds];
                if(insertedPgmEnrollments!=null && insertedPgmEnrollments.size()>0)
                {
                    for(DeltakSRP__Program_Enrollment__c peS: insertedPgmEnrollments)
                    {
                        studentIdToPgmEnrollSFId.put(peS.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_ID__c,peS.id);
                    }
                    
                }
            }
         
        }
        
        System.debug('SectionIdToSectionSFId-->'+SectionIdToSectionSFId);
        List<DeltakSRP__Course_Enrollment__c> courseEnrollmentIds = new List<DeltakSRP__Course_Enrollment__c>();
        if(ga_Affl!=null && ga_Affl.size()>0)
        {
            for(SRPGLobalAPIService.GA_StudentEnrollment affl: ga_Affl)
            {
                // Variables
                String SectionID='';
                String CourseType='';
                String Status='';
                String CE_termSISId='';
                String CourseID='';
                Date CourseSectionStartDate=null;
                String CreditsReceived='';
                String FinalGrade='';
                String GradePoint='';
                String FinalPercentage='';
                Date CE_LastSISUpdate=null;
                String StatusReasonCodes='';
                String TransferCourseName='';
                String TransferCourseType='';
                String TransferCredit='';
                String TransferDetails='';
                String CE_SISExternalId='';
                String StudentID='';
                String PartnerStatus='';
                String Pass_Fail='';
                
                
                //Null / Empty Check 
                SectionID               =   (affl.SectionID!= null ? affl.SectionID : '');
                CourseType              =   (affl.CourseType!= null ? affl.CourseType : '');
                Status                  =   (affl.Status!= null ? affl.Status : '');
                CE_termSISId            =   (affl.CE_termSISId!= null ? affl.CE_termSISId : '');
                CourseID                =   (affl.CourseID!= null ? affl.CourseID : '');
                CourseSectionStartDate  =   (affl.CourseSectionStartDate!= null ? affl.CourseSectionStartDate : null);
                CreditsReceived         =   (affl.CreditsReceived!= null ? affl.CreditsReceived : '');
                FinalGrade              =   (affl.FinalGrade!= null ? affl.FinalGrade : '');
                GradePoint              =   (affl.GradePoint!= null ? affl.GradePoint : '');
                FinalPercentage         =   (affl.FinalPercentage!= null ? affl.FinalPercentage : '');
                CE_LastSISUpdate        =   (affl.CE_LastSISUpdate!= null ? affl.CE_LastSISUpdate : null);
                StatusReasonCodes       =   (affl.StatusReasonCodes!= null ? affl.StatusReasonCodes : '');
                TransferCourseName      =   (affl.TransferCourseName!= null ? affl.TransferCourseName : '');
                TransferCourseType      =   (affl.TransferCourseType!= null ? affl.TransferCourseType : '');
                TransferCredit          =   (affl.TransferCredit!= null ? affl.TransferCredit : '');
                TransferDetails         =   (affl.TransferDetails!= null ? affl.TransferDetails : '');
                CE_SISExternalId        =   (affl.CE_SISExternalId!= null ? affl.CE_SISExternalId : '');
                StudentID               =   (affl.StudentID != null ? affl.StudentID : '');
                PartnerStatus           =   (affl.Status!= null ? affl.Status : '');
                Pass_Fail               =   (affl.Pass_Fail!= null ? affl.Pass_Fail : '');
                  
                // Translation
                Boolean translate = false;
                Set<String> fldList = new Set<String>();
                
                if(translationFieldList!=null && translationFieldList.size()>0)
                {
                    translate = true;
                    fldList.addAll(translationFieldList);
                }
                if(translate)
                {
                    SectionID           =(SectionID!='' && fldList.contains('SectionID')? fieldTranslationMap.get('SectionID-'+SectionID) : SectionID);
                    CourseType          =(CourseType!='' && fldList.contains('CourseType')? fieldTranslationMap.get('CourseType-'+CourseType) : CourseType);
                    Status              =(Status!='' && fldList.contains('Status')? fieldTranslationMap.get('Status-'+Status) : Status);
                    CE_termSISId        =(CE_termSISId!='' && fldList.contains('CE_termSISId')? fieldTranslationMap.get('CE_termSISId-'+CE_termSISId) : CE_termSISId);
                    CourseID            =(CourseID!='' && fldList.contains('CourseID')? fieldTranslationMap.get('CourseID-'+CourseID) : CourseID);
                    CreditsReceived     =(CreditsReceived!='' && fldList.contains('CreditsReceived')? fieldTranslationMap.get('CreditsReceived-'+CreditsReceived) : CreditsReceived);
                    FinalGrade          =(FinalGrade!='' && fldList.contains('FinalGrade')? fieldTranslationMap.get('FinalGrade-'+FinalGrade) : FinalGrade);
                    GradePoint          =(GradePoint!='' && fldList.contains('GradePoint')? fieldTranslationMap.get('GradePoint-'+GradePoint) : GradePoint);
                    FinalPercentage     =(FinalPercentage!='' && fldList.contains('FinalPercentage')? fieldTranslationMap.get('FinalPercentage-'+FinalPercentage) : FinalPercentage);
                    StatusReasonCodes   =(StatusReasonCodes!='' && fldList.contains('StatusReasonCodes')? fieldTranslationMap.get('StatusReasonCodes-'+StatusReasonCodes) : StatusReasonCodes);
                    TransferCourseName  =(TransferCourseName!='' && fldList.contains('TransferCourseName')? fieldTranslationMap.get('TransferCourseName-'+TransferCourseName) : TransferCourseName);
                    TransferCourseType  =(TransferCourseType!='' && fldList.contains('TransferCourseType')? fieldTranslationMap.get('TransferCourseType-'+TransferCourseType) : TransferCourseType);
                    TransferCredit      =(TransferCredit!='' && fldList.contains('TransferCredit')? fieldTranslationMap.get('TransferCredit-'+TransferCredit) : TransferCredit);
                    TransferDetails     =(TransferDetails!='' && fldList.contains('TransferDetails')? fieldTranslationMap.get('TransferDetails-'+TransferDetails) : TransferDetails);
                    CE_SISExternalId    =(CE_SISExternalId!='' && fldList.contains('CE_SISExternalId')? fieldTranslationMap.get('CE_SISExternalId-'+CE_SISExternalId) : CE_SISExternalId);   
                    StudentID           =(StudentID !='' && fldList.contains('StudentID')? fieldTranslationMap.get('StudentID-'+StudentID) : StudentID);
                    Pass_Fail           =(Pass_Fail !='' && fldList.contains('Pass_Fail')? fieldTranslationMap.get('Pass_Fail-'+Pass_Fail) : Pass_Fail);
                           
                }
                if(SectionID!='')
                {
                        DeltakSRP__Course_Enrollment__c ce =  new DeltakSRP__Course_Enrollment__c();

                        SchemaMapObject courseEnrollSchema = new SchemaMapObject(Schema.SObjectType.DeltakSRP__Course_Enrollment__c.Fields.getMap());
                        system.debug('SectionID-CourseSectionStartDate-->'+SectionID+'-'+CourseSectionStartDate);
                        if(SectionIdToSectionSFId.get(SectionID+'-'+CourseSectionStartDate)!=null)
                        {
                            ce.DeltakSRP__Academic_Section__c = courseEnrollSchema.gsbfl('DeltakSRP__Academic_Section__c',SectionIdToSectionSFId.get(SectionID+'-'+CourseSectionStartDate));
                            if(studentIdtoSFIdMap!=null && studentIdtoSFIdMap.get(StudentID)!=null)
                            {
                                ce.DeltakSRP__Enrolled_Student__c = courseEnrollSchema.gsbfl('DeltakSRP__Enrolled_Student__c',studentIdtoSFIdMap.get(StudentID));
                            }
                            else
                            {
                                continue;
                            }
                            ce.DeltakSRP__Course_Type__c = courseEnrollSchema.gsbfl('DeltakSRP__Course_Type__c',CourseType);
                            ce.DeltakSRP__Status__c = courseEnrollSchema.gsbfl('DeltakSRP__Status__c',Status);
                            ce.Partner_Status__c = PartnerStatus;
                            ce.Term_SIS_ID__c = courseEnrollSchema.gsbfl('Term_SIS_ID__c',CE_termSISId); 
                            ce.DeltakSRP__SIS_External_Id__c  = courseEnrollSchema.gsbfl('DeltakSRP__SIS_External_Id__c',CE_SISExternalId);
                            if(studentIdToPgmEnrollSFId!=null && studentIdToPgmEnrollSFId.get(StudentId)!=null)
                            ce.DeltakSRP__Program_Enrollment__c = studentIdToPgmEnrollSFId.get(StudentId);
                            
                            ce.DeltakSRP__Credits_Received__c = Decimal.valueOf(CreditsReceived);
                            ce.DeltakSRP__Final_Grade__c = courseEnrollSchema.gsbfl('DeltakSRP__Final_Grade__c',FinalGrade);
                            ce.DeltakSRP__Grade_Point__c = (GradePoint!='' ? Decimal.valueOf(GradePoint): 0.0);
                            ce.DeltakSRP__Final_Percentage__c = (FinalPercentage!='' ? Decimal.valueOf(FinalPercentage): 0.0);
                            try{
                                ce.DeltakSRP__Last_SIS_Update__c = CE_LastSISUpdate;
                            }catch(Exception exc)
                            {
                                //Add Failure record
                            }
                            ce.DeltakSRP__Status_Reason_Code__c = courseEnrollSchema.gsbfl('DeltakSRP__Status_Reason_Code__c',StatusReasonCodes);
                            ce.DeltakSRP__Transfer_Course_Name__c = courseEnrollSchema.gsbfl('DeltakSRP__Transfer_Course_Name__c',TransferCourseName);
                            ce.DeltakSRP__Transfer_Course_Type__c = courseEnrollSchema.gsbfl('DeltakSRP__Transfer_Course_Type__c',TransferCourseType);
                            ce.DeltakSRP__Transfer_Credit__c = false;
                            if(TransferCredit=='true')
                            {
                                ce.DeltakSRP__Transfer_Credit__c = true;
                            }
                            ce.Pass_Fail__c = courseEnrollSchema.gsbfl('Pass_Fail__c',Pass_Fail);
                            ce.DeltakSRP__Transfer_Details__c = courseEnrollSchema.gsbfl('DeltakSRP__Transfer_Details__c',TransferDetails);
                            courseEnrollmentIds.add(ce);
                            logErrorRecord(getFailedRecord(affl,null, orgId));
                        }else
                        {
                            logErrorRecord(getFailedRecord(affl,null, orgId));
                            continue;
                        }
                        
                    }

            }
            
        }
        if(courseEnrollmentIds!=null && courseEnrollmentIds.size()>0)
        {
            try{
                database.upsert (courseEnrollmentIds,DeltakSRP__Course_Enrollment__c.DeltakSRP__SIS_External_Id__c);
                
            }catch(Exception exc)
            {
                System.debug('DML Exception: '+exc.getStackTraceString());
                return null;
            }
            
        }
        return null;
        
    }
    
    public static Map<String,String> processCourse(List<String> translationFieldList, Map<String, String> fieldTranslationMap, List<SRPGLobalAPIService.GA_CourseSection> ga_CorsSec, String orgId, Map<String, String> programSISProgramSFIdMap)
    {
        
        List<DeltakSRP__Academic_Course__c> coursesList = new List<DeltakSRP__Academic_Course__c>();
        Map<String,DeltakSRP__Academic_Course__c> courseUpsertMap = new  Map<String,DeltakSRP__Academic_Course__c>();
        List<id> courList = new List<Id>();
        Map<String,String> sectionCourseIdMap = new Map<String,String>();
        Map<String,String> courseIdCourseSFIdMap = new Map<String,String>();
        Map<String,String> sectionCourseSFIdMap = new Map<String,String>();
        system.debug('ga_CorsSec:--> '+ga_CorsSec);
        system.debug('ga_CorsSec.size:--> '+ga_CorsSec.size());
        if(ga_CorsSec!=null && ga_CorsSec.size()>0)
        {
            for(SRPGLobalAPIService.GA_CourseSection couSec: ga_CorsSec)
            {
                // Variables
               // system.debug('Inside For Loop--> '+couSec);
                String CourseTitle='';
                String CourseUnits='';
                String CourseFee='';
                String CourseCreditType='';
                String CourseAbbreviation='';
                String CatalogNumber='';
                String CourseDescription='';
                String ClassType='';
                String CourseID='';
                String SectionID='';
                String SectionSISId='';
                String CourseSISId='';
                String ProgramSISId='';
                
                // Null Check
                CourseTitle         = (couSec.CourseTitle != null ? couSec.CourseTitle : '');
                CourseUnits         = (couSec.CourseUnits != null ? couSec.CourseUnits : '');
                CourseFee           = (couSec.CourseFee != null ? couSec.CourseFee : '');
                CourseCreditType    = (couSec.CourseCreditType != null ? couSec.CourseCreditType : '');
                CourseAbbreviation  = (couSec.CourseAbbreviation != null ? couSec.CourseAbbreviation : '');
                CatalogNumber       = (couSec.CatalogNumber != null ? couSec.CatalogNumber : '');
                CourseDescription   = (couSec.CourseDescription != null ? couSec.CourseDescription : '');
                ClassType           = (couSec.ClassType != null ? couSec.ClassType : '');
                CourseID            = (couSec.CourseID != null ? couSec.CourseID : '');
                SectionID       = (couSec.SectionID != null ? couSec.SectionID : '');
                SectionSISId    = (couSec.SectionSISId != null ? couSec.SectionSISId : '');
                if(CourseSISId!=null)
                {
                    CourseSISId = CourseSISId.replaceAll('\r\n','');
                    CourseSISId = CourseSISId.replaceAll('\n','');
                    CourseSISId = CourseSISId.replaceAll('\r','');
                }
                System.debug('CourseSISId-->'+CourseSISId);
                CourseSISId     = (couSec.CourseSISId != null ? couSec.CourseSISId : '');
                ProgramSISId    = (couSec.ProgramSISId != null ? couSec.ProgramSISId : '');
                        
                // Translation
                Boolean translate = false;
                Set<String> fldList = new Set<String>(); 
                
                if(translationFieldList!=null && translationFieldList.size()>0)
                {
                    translate = true;
                    fldList.addAll(translationFieldList);
                }
                
                if(translate)
                {
                    CourseTitle         = (CourseTitle!='' && fldList.contains('CourseTitle')? fieldTranslationMap.get('CourseTitle-'+CourseTitle) : CourseTitle);
                    CourseUnits         = (CourseUnits!='' && fldList.contains('CourseUnits')? fieldTranslationMap.get('CourseUnits-'+CourseUnits) : CourseUnits);
                    CourseFee           = (CourseFee!='' && fldList.contains('CourseFee')? fieldTranslationMap.get('CourseFee-'+CourseFee) : CourseFee);
                    CourseCreditType    = (CourseCreditType!='' && fldList.contains('CourseCreditType')? fieldTranslationMap.get('CourseCreditType-'+CourseCreditType) : CourseCreditType);
                    CourseAbbreviation  = (CourseAbbreviation!='' && fldList.contains('CourseAbbreviation')? fieldTranslationMap.get('CourseAbbreviation-'+CourseAbbreviation) : CourseAbbreviation);
                    CatalogNumber       = (CatalogNumber!='' && fldList.contains('CatalogNumber')? fieldTranslationMap.get('CatalogNumber-'+CatalogNumber) : CatalogNumber);
                    CourseDescription   = (CourseDescription!='' && fldList.contains('CourseDescription')? fieldTranslationMap.get('CourseDescription-'+CourseDescription) : CourseDescription);
                    ClassType           = (ClassType!='' && fldList.contains('ClassType')? fieldTranslationMap.get('ClassType-'+ClassType) : ClassType);
                    CourseID            = (CourseID!='' && fldList.contains('CourseID')? fieldTranslationMap.get('CourseID-'+CourseID) : CourseID);
                    SectionID           = (SectionID!='' && fldList.contains('SectionID')? fieldTranslationMap.get('SectionID-'+SectionID) : SectionID);
                    SectionSISId        = (SectionSISId!='' && fldList.contains('SectionSISId')? fieldTranslationMap.get('SectionSISId-'+SectionSISId) : SectionSISId);
                    CourseSISId         = (CourseSISId!='' && fldList.contains('CourseSISId')? fieldTranslationMap.get('CourseSISId-'+CourseSISId) : CourseSISId);
                    ProgramSISId        = (ProgramSISId!='' && fldList.contains('ProgramSISId')? fieldTranslationMap.get('ProgramSISId-'+ProgramSISId) : ProgramSISId);
                    
                }
                
                if(CourseID!='')
                {
                    
                    DeltakSRP__Academic_Course__c ac = new DeltakSRP__Academic_Course__c();
                        
                    SchemaMapObject courseSchema = new SchemaMapObject(Schema.SObjectType.DeltakSRP__Academic_Course__c.Fields.getMap());
                    ac.Name = CourseTitle;
                    
                    ac.DeltakSRP__Course_Units__c = (CourseUnits!=''? Decimal.valueOf(CourseUnits) : 0.0);
                    if(programSISProgramSFIdMap!=null && programSISProgramSFIdMap.get(ProgramSISId)!=null)
                        ac.DeltakSRP__Primary_Program__c =  programSISProgramSFIdMap.get(ProgramSISId);                   
                    
                    ac.DeltakSRP__Course_Credit_Type__c = courseSchema.gsbfl('DeltakSRP__Course_Credit_Type__c',CourseCreditType);
                    ac.DeltakSRP__Course_Abbreviation__c = courseSchema.gsbfl('DeltakSRP__Course_Abbreviation__c',CourseAbbreviation);
                    ac.DeltakSRP__Catalog_Number__c = courseSchema.gsbfl('DeltakSRP__Catalog_Number__c',CatalogNumber);
                    ac.DeltakSRP__Course_Description__c = courseSchema.gsbfl('DeltakSRP__Course_Description__c',CourseDescription);
                    ac.DeltakSRP__Class_Type__c = courseSchema.gsbfl('DeltakSRP__Class_Type__c',ClassType);
                    ac.DeltakSRP__SIS_External_Id__c = courseSchema.gsbfl('DeltakSRP__SIS_External_Id__c',CourseSISId);
                    ac.DeltakSRP__Course_ID__c = courseSchema.gsbfl('DeltakSRP__Course_ID__c',CourseId);
                    ac.DeltakSRP__Academic_Institution__c = orgId;
                    
                    coursesList.add(ac);
                    if(courseUpsertMap.get(CourseSISId)==null)
                    {
                        courseUpsertMap.put(CourseSISId,ac);
                    }
                    sectionCourseIdMap.put(SectionSISId,CourseSISId);
                    
                }
                
            }
            
        }
        system.debug('coursesList--> '+coursesList);
        system.debug('sectionCourseIdMap--> '+sectionCourseIdMap);
        system.debug('courseUpsertMap--1>'+courseUpsertMap);
        if(coursesList!=null && coursesList.size()>0)
        {
            system.debug('Inside Database Upsert If Loop--> '+coursesList);
            try{
                database.upsert(courseUpsertMap.values(),DeltakSRP__Academic_Course__c.DeltakSRP__SIS_External_Id__c, true);
                system.debug('After Database Upsert--> '+courseUpsertMap.values());
            }catch(Exception exc)
            {
                System.debug('DML Exception: '+exc.getStackTraceString());
                return null;
            }
            List<DeltakSRP__Academic_Course__c> insertedCoursesList = new List<DeltakSRP__Academic_Course__c>();
            insertedCoursesList = [Select Id, DeltakSRP__SIS_External_Id__c from DeltakSRP__Academic_Course__c where DeltakSRP__SIS_External_Id__c in: sectionCourseIdMap.values()];
            system.debug('sectionCourseIdMap.values()--> '+sectionCourseIdMap.values());
            system.debug('insertedCoursesList--> '+insertedCoursesList);
            for(DeltakSRP__Academic_Course__c cou: insertedCoursesList)
            {
                courList.add(cou.id);
                if(cou.DeltakSRP__SIS_External_Id__c!=null)
                {
                    courseIdCourseSFIdMap.put(cou.DeltakSRP__SIS_External_Id__c,String.valueOf(cou.Id));
                }
                
            }
            for(String secSISId:sectionCourseIdMap.keySet())
            {
                String courseSIS = sectionCourseIdMap.get(secSISId);
                String courseSFId = courseIdCourseSFIdMap.get(courseSIS);
                sectionCourseSFIdMap.put(secSISId,courseSFId);
            }
        }
        if(sectionCourseSFIdMap!=null && sectionCourseSFIdMap.size()>0)
        {
            return sectionCourseSFIdMap;
        }else
        {
            return null;
        }
    }
    
    public static List<id> processSection(List<String> translationFieldList, Map<String, String> fieldTranslationMap, List<SRPGLobalAPIService.GA_CourseSection> ga_CorsSec, Map<String,String> sectionCourseSFIdMap, Map<String, String> PgmSISStartDtTermIdMap, String orgId)
    {   
        List<DeltakSRP__Academic_Section__c> sectionList = new List<DeltakSRP__Academic_Section__c>();
        List<id> secList = new List<Id>();
        if(ga_CorsSec!=null && ga_CorsSec.size()>0)
        {
            for(SRPGLobalAPIService.GA_CourseSection couSec: ga_CorsSec)
            {
                // Variables
                String OrganizationId='';
                String AcademicSection='';
                String SectionID='';
                String termSISId='';
                Date StartDate=null;
                Date EndDate=null;
                String Capacity='';
                String Days='';
                String SectionSISId='';
                String CourseSISId='';
                String Instructor1='';
                String Instructor1Phone='';
                String Instructor1Email='';
                String Instructor2='';
                String Instructor2Phone='';
                String Instructor2Email='';
                String ProgramSISId=''; 
                
                // Null Check
                OrganizationId      = (couSec.OrganizationId != null ? couSec.OrganizationId : '');
                AcademicSection     = (couSec.AcademicSection != null ? couSec.AcademicSection : '');
                SectionID           = (couSec.SectionID != null ? couSec.SectionID : '');
                termSISId           = (couSec.termSISId != null ? couSec.termSISId : '');
                StartDate           = (couSec.StartDate != null ? couSec.StartDate : null);
                EndDate             = (couSec.EndDate != null ? couSec.EndDate : null);
                Capacity            = (couSec.Capacity != null ? couSec.Capacity : '');
                Days                = (couSec.Days != null ? couSec.Days : '');
                SectionSISId        = (couSec.SectionSISId != null ? couSec.SectionSISId : '');
                CourseSISId         = (couSec.CourseSISId != null ? couSec.CourseSISId : '');
                Instructor1         = (couSec.Instructor1 != null ? couSec.Instructor1 : '');
                Instructor1Phone    = (couSec.Instructor1Phone != null ? couSec.Instructor1Phone : '');
                Instructor1Email    = (couSec.Instructor1Email != null ? couSec.Instructor1Email : '');
                Instructor2         = (couSec.Instructor2 != null ? couSec.Instructor2 : '');
                Instructor2Phone    = (couSec.Instructor2Phone != null ? couSec.Instructor2Phone : '');
                Instructor2Email    = (couSec.Instructor2Email != null ? couSec.Instructor2Email : '');
                ProgramSISId        = (couSec.ProgramSISId != null ? couSec.ProgramSISId : '');
                
                // Translation
                Boolean translate = false;
                Set<String> fldList = new Set<String>();
                
                if(translationFieldList!=null && translationFieldList.size()>0)
                {
                    translate = true;
                    fldList.addAll(translationFieldList);
                }
                if(translate)
                {
                    OrganizationId  = (OrganizationId!='' && fldList.contains('OrganizationId')? fieldTranslationMap.get('OrganizationId-'+OrganizationId) : OrganizationId);
                    AcademicSection = (AcademicSection!='' && fldList.contains('AcademicSection')? fieldTranslationMap.get('AcademicSection-'+AcademicSection) : AcademicSection);
                    SectionID       = (SectionID!='' && fldList.contains('SectionID')? fieldTranslationMap.get('SectionID-'+SectionID) : SectionID);
                    termSISId       = (termSISId!='' && fldList.contains('termSISId')? fieldTranslationMap.get('termSISId-'+termSISId) : termSISId);
                    Capacity        = (Capacity!='' && fldList.contains('Capacity')? fieldTranslationMap.get('Capacity-'+Capacity) : Capacity);
                    Days            = (Days!='' && fldList.contains('Days')? fieldTranslationMap.get('Days-'+Days) : Days);
                    SectionSISId    = (SectionSISId!='' && fldList.contains('SectionSISId')? fieldTranslationMap.get('SectionSISId-'+SectionSISId) : SectionSISId);
                    CourseSISId     = (CourseSISId!='' && fldList.contains('CourseSISId')? fieldTranslationMap.get('CourseSISId-'+CourseSISId) : CourseSISId);
                    Instructor1     = (Instructor1!='' && fldList.contains('Instructor1')? fieldTranslationMap.get('Instructor1-'+Instructor1) : Instructor1);
                    Instructor1Phone    = (Instructor1Phone!='' && fldList.contains('Instructor1Phone')? fieldTranslationMap.get('Instructor1Phone-'+Instructor1Phone) : Instructor1Phone);
                    Instructor1Email    = (Instructor1Email!='' && fldList.contains('Instructor1Email')? fieldTranslationMap.get('Instructor1Email-'+Instructor1Email) : Instructor1Email);
                    Instructor2         = (Instructor2!='' && fldList.contains('Instructor2')? fieldTranslationMap.get('Instructor2-'+Instructor2) : Instructor2);
                    Instructor2Phone    = (Instructor2Phone!='' && fldList.contains('Instructor2Phone')? fieldTranslationMap.get('Instructor2Phone-'+Instructor2Phone) : Instructor2Phone);
                    Instructor2Email    = (Instructor2Email!='' && fldList.contains('Instructor2Email')? fieldTranslationMap.get('Instructor2Email-'+Instructor2Email) : Instructor2Email);
                    ProgramSISId        = (ProgramSISId!='' && fldList.contains('ProgramSISId')? fieldTranslationMap.get('ProgramSISId-'+ProgramSISId) : ProgramSISId);
                }
                if(SectionID!='')
                {
                    DeltakSRP__Academic_Section__c ase = new DeltakSRP__Academic_Section__c();
                        
                    SchemaMapObject sectionSchema = new SchemaMapObject(Schema.SObjectType.DeltakSRP__Academic_Section__c.Fields.getMap());         
                    //webservice String AcademicSection;
                    ase.DeltakSRP__SIS_External_Id__c = sectionSchema.gsbfl('DeltakSRP__SIS_External_Id__c',SectionSISId);
                    ase.DeltakSRP__Section_ID__c = sectionSchema.gsbfl('DeltakSRP__Section_ID__c',SectionID);
                    ase.Term_SIS_ID__c = sectionSchema.gsbfl('Term_SIS_ID__c',termSISId);
                    try{
                        ase.DeltakSRP__Start_Date__c = StartDate;
                        ase.Start_Date__c = StartDate;
                        ase.DeltakSRP__End_Date__c = EndDate;
                        ase.End_Date__c = EndDate;
                    }catch(Exception exc)
                    {
                                //Add Failure record
                    }
                    
                    ase.DeltakSRP__Capacity__c = (Capacity!='' ? Decimal.valueOf(Capacity): 0.0);
                    ase.DeltakSRP__Days__c = sectionSchema.gsbfl('DeltakSRP__Days__c',Days);
                    ase.DeltakSRP__External_Id__c = sectionSchema.gsbfl('DeltakSRP__External_Id__c',SectionID);
                    //webservice String CourseSISId;
                    system.debug('sectionCourseSFIdMap-->'+sectionCourseSFIdMap);
                    system.debug('SectionSISId-->'+SectionSISId);
                    system.debug('ProgramSISId-StartDate-->'+ProgramSISId+'-'+StartDate);
//                    system.debug('SectionId-->'+sectionCourseSFIdMap.get(SectionSISId));
                    if(sectionCourseSFIdMap!=null)
                    ase.DeltakSRP__Academic_Course__c = sectionSchema.gsbfl('DeltakSRP__Academic_Course__c',sectionCourseSFIdMap.get(SectionSISId));
                    ase.DeltakSRP__Academic_Term__c = sectionSchema.gsbfl('DeltakSRP__Academic_Term__c',PgmSISStartDtTermIdMap.get(ProgramSISId+'-'+StartDate));
                    //ase.DeltakSRP__Instructor__c = sectionSchema.gsbfl('DeltakSRP__Instructor__c',Instructor1);
                    //webservice String Instructor1Phone;
                    //webservice String Instructor1Email;
                    //ase.DeltakSRP__Instructor_2__c = sectionSchema.gsbfl('DeltakSRP__Instructor_2__c',Instructor2);
                    //webservice String Instructor2Phone;
                    //webservice String Instructor2Email;
                    logErrorRecord(getFailedRecord(null,couSec, orgId));
                    
                    sectionList.add(ase);
                }
                
            }
            
        }
        
        if(sectionList!=null && sectionList.size()>0)
        {
            system.debug('sectionList-->'+sectionList);
            try{
                database.upsert (sectionList,DeltakSRP__Academic_Section__c.DeltakSRP__SIS_External_Id__c);
                
            }catch(Exception exc)
            {
                System.debug('DML Exception: '+exc.getStackTraceString());
                return null;
            }
            for(DeltakSRP__Academic_Section__c acs: sectionList)
            {
                secList.add(acs.id);
            }
        }
        if(secList!=null && secList.size()>0)
        {
            
            return secList;
        }else
        {
            return null;
        }

    }
    
    /*public static Id getCourseId(String CourseSISId)
    {
        Id courseId = null;
        List<DeltakSRP__Academic_Course__c> accList = new List<DeltakSRP__Academic_Course__c>();
        accList = [select id from DeltakSRP__Academic_Course__c where DeltakSRP__SIS_External_Id__c = : CourseSISId];
        if(accList!=null && accList.size() > 0)
        {
            for(DeltakSRP__Academic_Course__c acc: accList)
            {
                courseId = acc.id;
            }
        }
        return courseId;
    }*/
    
    
    public static Map<String,String> getFailedRecord(SRPGLobalAPIService.GA_StudentEnrollment afflRec, SRPGLobalAPIService.GA_CourseSection couSecRec, String orgId)
    {
        String integrationType='Student-Enrollment';
        if(couSecRec!=null && afflRec==null)
        {
            integrationType = 'Course-Section';
        }
        Map<String,String> failedRec = new Map<String,String>();
        if(integrationType=='Student-Enrollment')
        {
            failedRec.put('StudentID',afflRec.StudentID);
            failedRec.put('org', orgId);
            failedRec.put('SectionID',afflRec.SectionID);
            failedRec.put('CourseType',afflRec.CourseType);
            failedRec.put('Status',afflRec.Status);
            failedRec.put('CE_termSISId',afflRec.CE_termSISId);
            failedRec.put('CourseID',afflRec.CourseID);
            failedRec.put('CourseSectionStartDate',String.valueOf(afflRec.CourseSectionStartDate));
            failedRec.put('CreditsReceived',afflRec.CreditsReceived);
            failedRec.put('FinalGrade',afflRec.FinalGrade);
            failedRec.put('GradePoint',afflRec.GradePoint);
            failedRec.put('FinalPercentage',afflRec.FinalPercentage);
            failedRec.put('CE_LastSISUpdate',String.valueOf(afflRec.CE_LastSISUpdate));
            failedRec.put('StatusReasonCodes',afflRec.StatusReasonCodes);
            failedRec.put('TransferCourseName',afflRec.TransferCourseName);
            failedRec.put('TransferCourseType',afflRec.TransferCourseType);
            failedRec.put('TransferCredit',afflRec.TransferCredit);
            failedRec.put('TransferDetails',afflRec.TransferDetails);
            failedRec.put('CE_SISExternalId',afflRec.CE_SISExternalId);
            failedRec.put('programSISId',afflRec.programSISId);
            failedRec.put('specializationSISId',afflRec.specializationSISId);
            failedRec.put('PE_termSISId',afflRec.PE_termSISId);
            failedRec.put('AdditionalInfo',afflRec.AdditionalInfo);
            failedRec.put('Conditional',afflRec.Conditional);
            failedRec.put('DoNotRegister',afflRec.DoNotRegister);
            failedRec.put('DropReason',afflRec.DropReason);
            failedRec.put('DropDate',String.valueOf(afflRec.DropDate));
            failedRec.put('EnrollmentStatus',afflRec.EnrollmentStatus);
            failedRec.put('GPA',afflRec.GPA);
            failedRec.put('GraduationDate',String.valueOf(afflRec.GraduationDate));
            failedRec.put('PE_LastSISUpdate',String.valueOf(afflRec.PE_LastSISUpdate));
            failedRec.put('Provisional',afflRec.Provisional);
            failedRec.put('PgmStartDate',String.valueOf(afflRec.PgmStartDate));
            failedRec.put('TotalTransferredCredits',afflRec.TotalTransferredCredits);
            failedRec.put('AdvisorName',afflRec.AdvisorName);
            failedRec.put('AdvisorPhoneNumber',afflRec.AdvisorPhoneNumber);
            failedRec.put('AdvisorEmail',afflRec.AdvisorEmail);
            failedRec.put('Matriculated',afflRec.Matriculated);
            failedRec.put('Modality',afflRec.Modality);
            failedRec.put('PE_SISExternalId',afflRec.PE_SISExternalId);
        }
        else if(integrationType == 'Course-Section')
        {

            failedRec.put('ProgramSISId',couSecRec.ProgramSISId);
            failedRec.put('org', orgId);
            failedRec.put('SpecializationSISId',couSecRec.SpecializationSISId);
            failedRec.put('CourseTitle',couSecRec.CourseTitle);
            failedRec.put('CourseUnits',couSecRec.CourseUnits);
            failedRec.put('CourseFee',couSecRec.CourseFee);
            failedRec.put('CourseCreditType',couSecRec.CourseCreditType);
            failedRec.put('CourseAbbreviation',couSecRec.CourseAbbreviation);
            failedRec.put('CatalogNumber',couSecRec.CatalogNumber);
            failedRec.put('CourseDescription',couSecRec.CourseDescription);
            failedRec.put('ClassType',couSecRec.ClassType);
            failedRec.put('CourseID',couSecRec.CourseID);
            failedRec.put('OrganizationId',couSecRec.OrganizationId);
            failedRec.put('AcademicSection',couSecRec.AcademicSection);
            failedRec.put('SectionID',couSecRec.SectionID);
            failedRec.put('termSISId',couSecRec.termSISId);
            failedRec.put('StartDate',String.valueOf(couSecRec.StartDate));
            failedRec.put('EndDate',String.valueOf(couSecRec.EndDate));
            failedRec.put('Capacity',couSecRec.Capacity);
            failedRec.put('Days',couSecRec.Days);
            failedRec.put('SectionSISId',couSecRec.SectionSISId);
            failedRec.put('CourseSISId',couSecRec.CourseSISId);
            failedRec.put('Instructor1',couSecRec.Instructor1);
            failedRec.put('Instructor1Phone',couSecRec.Instructor1Phone);
            failedRec.put('Instructor1Email',couSecRec.Instructor1Email);
            failedRec.put('Instructor2',couSecRec.Instructor2);
            failedRec.put('Instructor2Phone',couSecRec.Instructor2Phone);
            failedRec.put('Instructor2Email',couSecRec.Instructor2Email);
        }

        return failedRec;
    }
       
    public static void logErrorRecord(Map<String,String> failedRec)
    {
        Global_API_Failure__c glAF = new Global_API_Failure__c();
        glAF.Which_Run__c= datetime.now();
        glAF.OrganizationId__c= failedRec.containsKey('OrganizationId')?failedRec.get('OrganizationId') : '';
        glAF.Integration_Type__c= failedRec.containsKey('integrationType')?failedRec.get('integrationType') : '';
        glAF.From_Partner__c= failedRec.containsKey('org')?failedRec.get('org') : '';
        glAF.Failure_Type__c= failedRec.containsKey('FailureType')?failedRec.get('FailureType') : '';
        glAF.Failure_Detail__c= failedRec.containsKey('FailureDetail')?failedRec.get('FailureDetail') : '';
        //String integrationType, String errorMessage, String org_Abbr - add to Map
        //SIMILAR TO THIS - ADD CONTAINS LOGIC
        //Instructor2Email  = (Instructor2Email!='' && fldList.contains('Instructor2Email')? fieldTranslationMap.get(Instructor2Email) : Instructor2Email);
        glAF.AcademicSection__c= failedRec.containsKey('AcademicSection')?failedRec.get('AcademicSection') : '';
        glAF.AdditionalInfo__c= failedRec.containsKey('AdditionalInfo')?failedRec.get('AdditionalInfo') : '';
        glAF.AdvisorEmail__c= failedRec.containsKey('AdvisorEmail')?failedRec.get('AdvisorEmail') : '';
        glAF.AdvisorName__c= failedRec.containsKey('AdvisorName')?failedRec.get('AdvisorName') : '';
        glAF.AdvisorPhoneNumber__c= failedRec.containsKey('AdvisorPhoneNumber')?failedRec.get('AdvisorPhoneNumber') : '';
        glAF.Capacity__c= failedRec.containsKey('Capacity')?failedRec.get('Capacity') : '';
        glAF.CatalogNumber__c= failedRec.containsKey('CatalogNumber')?failedRec.get('CatalogNumber') : '';
        glAF.CE_LastSISUpdate__c= failedRec.containsKey('CE_LastSISUpdate')?failedRec.get('CE_LastSISUpdate') : '';
        glAF.CE_SISExternalId__c= failedRec.containsKey('CE_SISExternalId')?failedRec.get('CE_SISExternalId') : '';
        glAF.CE_termSISId__c= failedRec.containsKey('CE_termSISId')?failedRec.get('CE_termSISId') : '';
        glAF.ClassType__c= failedRec.containsKey('ClassType')?failedRec.get('ClassType') : '';
        glAF.Conditional__c= failedRec.containsKey('Conditional')?failedRec.get('Conditional') : '';
        glAF.CourseAbbreviation__c= failedRec.containsKey('CourseAbbreviation')?failedRec.get('CourseAbbreviation') : '';
        glAF.CourseCreditType__c= failedRec.containsKey('CourseCreditType')?failedRec.get('CourseCreditType') : '';
        glAF.CourseDescription__c= failedRec.containsKey('CourseDescription')?failedRec.get('CourseDescription') : '';
        glAF.CourseFee__c= failedRec.containsKey('CourseFee')?failedRec.get('CourseFee') : '';
        glAF.CourseID__c= failedRec.containsKey('CourseID')?failedRec.get('CourseID') : '';
        glAF.CourseSectionStartDate__c= failedRec.containsKey('CourseSectionStartDate')?failedRec.get('CourseSectionStartDate') : '';
        glAF.CourseSISId__c= failedRec.containsKey('CourseSISId')?failedRec.get('CourseSISId') : '';
        glAF.CourseTitle__c= failedRec.containsKey('CourseTitle')?failedRec.get('CourseTitle') : '';
        glAF.CourseType__c= failedRec.containsKey('CourseType')?failedRec.get('CourseType') : '';
        glAF.CourseUnits__c= failedRec.containsKey('CourseUnits')?failedRec.get('CourseUnits') : '';
        glAF.CreditsReceived__c= failedRec.containsKey('CreditsReceived')?failedRec.get('CreditsReceived') : '';
        glAF.Days__c= failedRec.containsKey('Days')?failedRec.get('Days') : '';
        glAF.DegreeType__c= failedRec.containsKey('DegreeType')?failedRec.get('DegreeType') : '';
        glAF.DoNotRegister__c= failedRec.containsKey('DoNotRegister')?failedRec.get('DoNotRegister') : '';
        glAF.DropDate__c= failedRec.containsKey('DropDate')?failedRec.get('DropDate') : '';
        glAF.DropReason__c= failedRec.containsKey('DropReason')?failedRec.get('DropReason') : '';
        glAF.Email__c= failedRec.containsKey('Email')?failedRec.get('Email') : '';
        glAF.Employer__c= failedRec.containsKey('Employer')?failedRec.get('Employer') : '';
        glAF.EndDate__c= failedRec.containsKey('EndDate')?failedRec.get('EndDate') : '';
        glAF.EnrollmentStatus__c= failedRec.containsKey('EnrollmentStatus')?failedRec.get('EnrollmentStatus') : '';
        glAF.FinalGrade__c= failedRec.containsKey('FinalGrade')?failedRec.get('FinalGrade') : '';
        glAF.FinalPercentage__c= failedRec.containsKey('FinalPercentage')?failedRec.get('FinalPercentage') : '';
        glAF.FirstName__c= failedRec.containsKey('FirstName')?failedRec.get('FirstName') : '';
        glAF.GPA__c= failedRec.containsKey('GPA')?failedRec.get('GPA') : '';
        glAF.GradePoint__c= failedRec.containsKey('GradePoint')?failedRec.get('GradePoint') : '';
        glAF.GraduationDate__c= failedRec.containsKey('GraduationDate')?failedRec.get('GraduationDate') : '';
        glAF.HomePhone__c= failedRec.containsKey('HomePhone')?failedRec.get('HomePhone') : '';
        glAF.Instructor1__c= failedRec.containsKey('Instructor1')?failedRec.get('Instructor1') : '';
        glAF.Instructor1Email__c= failedRec.containsKey('Instructor1Email')?failedRec.get('Instructor1Email') : '';
        glAF.Instructor1Phone__c= failedRec.containsKey('Instructor1Phone')?failedRec.get('Instructor1Phone') : '';
        glAF.Instructor2__c= failedRec.containsKey('Instructor2')?failedRec.get('Instructor2') : '';
        glAF.Instructor2Email__c= failedRec.containsKey('Instructor2Email')?failedRec.get('Instructor2Email') : '';
        glAF.Instructor2Phone__c= failedRec.containsKey('Instructor2Phone')?failedRec.get('Instructor2Phone') : '';
        glAF.LastName__c        = failedRec.containsKey('LastName')?failedRec.get('LastName') : '';
        glAF.MailingCity__c     = failedRec.containsKey('MailingCity')?failedRec.get('MailingCity') : '';
        glAF.MailingCountry__c  = failedRec.containsKey('MailingCountry')?failedRec.get('MailingCountry') : '';
        glAF.MailingPostalCode__c= failedRec.containsKey('MailingPostalCode')?failedRec.get('MailingPostalCode') : '';
        glAF.MailingState__c    = failedRec.containsKey('MailingState')?failedRec.get('MailingState') : '';
        glAF.MailingStreet__c   = failedRec.containsKey('MailingStreet')?failedRec.get('MailingStreet') : '';
        glAF.Matriculated__c    = failedRec.containsKey('Matriculated')?failedRec.get('Matriculated') : '';
        glAF.MiddleName__c      = failedRec.containsKey('MiddleName')?failedRec.get('MiddleName') : '';
        glAF.MobilePhone__c     = failedRec.containsKey('MobilePhone')?failedRec.get('MobilePhone') : '';
        glAF.Modality__c        = failedRec.containsKey('Modality')?failedRec.get('Modality') : '';
        glAF.NumberofRequiredCredits__c= failedRec.containsKey('NumberofRequiredCredits')?failedRec.get('NumberofRequiredCredits') : '';
        glAF.OrganizationId__c  = failedRec.containsKey('OrganizationId')?failedRec.get('OrganizationId') : '';
        glAF.OtherEmail__c      = failedRec.containsKey('OtherEmail')?failedRec.get('OtherEmail') : '';
        glAF.PE_LastSISUpdate__c= failedRec.containsKey('PE_LastSISUpdate')?failedRec.get('PE_LastSISUpdate') : '';
        glAF.PE_SISExternalId__c= failedRec.containsKey('PE_SISExternalId')?failedRec.get('PE_SISExternalId') : '';
        
        glAF.PE_termSISId__c    = failedRec.containsKey('PE_termSISId')?failedRec.get('PE_termSISId') : '';
        glAF.Pgm_Abbreviation__c= failedRec.containsKey('Pgm_Abbreviation')?failedRec.get('Pgm_Abbreviation') : '';
        glAF.PgmStartDate__c    = failedRec.containsKey('PgmStartDate')?failedRec.get('PgmStartDate') : '';
        glAF.ProgramDescription__c= failedRec.containsKey('ProgramDescription')?failedRec.get('ProgramDescription') : '';
        glAF.programSISId__c    = failedRec.containsKey('programSISId')?failedRec.get('programSISId') : '';
        glAF.ProgramTitle__c    = failedRec.containsKey('ProgramTitle')?failedRec.get('ProgramTitle') : '';
        glAF.Provisional__c     = failedRec.containsKey('Provisional')?failedRec.get('Provisional') : '';
        glAF.SectionID__c       = failedRec.containsKey('SectionID')?failedRec.get('SectionID') : '';
        glAF.SectionSISId__c    = failedRec.containsKey('SectionSISId')?failedRec.get('SectionSISId') : '';
        glAF.Spec_Abbreviation__c= failedRec.containsKey('Spec_Abbreviation')?failedRec.get('Spec_Abbreviation') : '';
        glAF.SpecializationDescription__c= failedRec.containsKey('SpecializationDescription')?failedRec.get('SpecializationDescription') : '';
        glAF.specializationSISId__c= failedRec.containsKey('specializationSISId')?failedRec.get('specializationSISId') : '';
        glAF.SpecializationTitle__c= failedRec.containsKey('SpecializationTitle')?failedRec.get('SpecializationTitle') : '';
        glAF.StartDate__c       = failedRec.containsKey('StartDate')?failedRec.get('StartDate') : '';
        glAF.Status__c          = failedRec.containsKey('Status')?failedRec.get('Status') : '';
        glAF.StatusReasonCodes__c= failedRec.containsKey('StatusReasonCodes')?failedRec.get('StatusReasonCodes') : '';
        glAF.StudentID__c       = failedRec.containsKey('StudentID')?failedRec.get('StudentID') : '';
        glAF.Suffix__c= failedRec.containsKey('Suffix')?failedRec.get('Suffix') : '';
        glAF.termSISId__c= failedRec.containsKey('termSISId')?failedRec.get('termSISId') : '';
        glAF.TotalTransferredCredits__c= failedRec.containsKey('TotalTransferredCredits')?failedRec.get('TotalTransferredCredits') : '';
        glAF.TransferCourseName__c= failedRec.containsKey('TransferCourseName')?failedRec.get('TransferCourseName') : '';
        glAF.TransferCourseType__c= failedRec.containsKey('TransferCourseType')?failedRec.get('TransferCourseType') : '';
        glAF.TransferCredit__c= failedRec.containsKey('TransferCredit')?failedRec.get('TransferCredit') : '';
        glAF.TransferDetails__c= failedRec.containsKey('TransferDetails')?failedRec.get('TransferDetails') : '';
        glAF.WorkPhone__c= failedRec.containsKey('WorkPhone')?failedRec.get('WorkPhone') : '';
        insert glAF;
    }
    
    public class SchemaMapObject 
    {
            Map<String, Schema.sObjectField>schemamap;
           
            public SchemaMapObject() {
                schemamap = null;
            }
     
            public SchemaMapObject(Map<String, Schema.sObjectField>smap) {
                schemamap = smap;
            }
           
            public String gsbfl(String fieldname, String str) {
                return this.getStringByFieldLength(fieldname, str);
            }
           
            public String getStringByFieldLength(String fieldname, String str)
            {
                if(this.schemamap == null) {
                    throw new UserException('getStringByFieldLength called without valid schemamap.');
                }
               
                String newstr = '';
                Schema.sObjectField field = this.schemamap.get(fieldname);
     
                if(str == null)
                    return newstr;
                           
                if(field != null)
                    newstr = str.substring(0,  Math.min(str.length(), field.getDescribe().getLength()));
                else
                    System.Debug('getStringByFieldLength() could not locate field named ' + fieldname);
                //System.Debug('Max length ' + field.getDescribe().getLength() + 'String length ' + newstr.length() + ' - string: ' + newstr);
                return newstr;
            }
    }

    
}