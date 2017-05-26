global without sharing class SRPGlobalAPIService {
    
    global class GA_Partner{
        webservice String organizationId;
    }
    global class GA_StudentEnrollment{ 
        //StudentId is the only needed field
        webservice String StudentID;
        
        //All fields from Course Enrollment
        webservice String SectionID;
        webservice String CourseType;
        webservice String Status;
        webservice String CE_termSISId;
        webservice String CourseID;
        webservice Date CourseSectionStartDate;
        webservice String CreditsReceived;
        webservice String FinalGrade;
        webservice String GradePoint;
        webservice String FinalPercentage;
        webservice Date CE_LastSISUpdate;
        webservice String StatusReasonCodes;
        webservice String TransferCourseName;
        webservice String TransferCourseType;
        webservice String TransferCredit;
        webservice String TransferDetails;
        webservice String CE_SISExternalId; 
        webservice String Pass_Fail;
        //All fields from Program Enrollment 
        webservice String programSISId;
        webservice String specializationSISId;
        webservice String PE_termSISId;
        webservice String AdditionalInfo;
        webservice String Conditional;
        webservice String DoNotRegister;
        webservice String DropReason;
        webservice Date DropDate;
        webservice String EnrollmentStatus;
        webservice String GPA;
        webservice Date GraduationDate;
        webservice Date PE_LastSISUpdate;
        webservice String Provisional;
        webservice Date PgmStartDate;
        webservice String TotalTransferredCredits;
        webservice String AdvisorName;
        webservice String AdvisorPhoneNumber;
        webservice String AdvisorEmail;
        webservice String Matriculated;
        webservice String Modality;
        webservice String PE_SISExternalId;
    }
    
    global class GA_CourseSection{
        //All Academic Programs fields
        webservice String ProgramSISId;

        //All Academic Specialization Fields
        webservice String SpecializationSISId;
        //All Academic Course Fields
        webservice String CourseTitle;
        webservice String CourseUnits;
        webservice String CourseFee;
        webservice String CourseCreditType;
        webservice String CourseAbbreviation;
        webservice String CatalogNumber;
        webservice String CourseDescription;
        webservice String ClassType;
        webservice String CourseID;
        //All Academic Section Fields
        webservice String OrganizationId;
        webservice String AcademicSection;
        webservice String SectionID;
        webservice String termSISId;
        webservice Date StartDate;
        webservice Date EndDate;
        webservice String SectionStartDate;
        webservice String SectionEndDate;
        webservice String Capacity;
        webservice String Days;
        webservice String SectionSISId;
        webservice String CourseSISId;
        webservice String Instructor1;
        webservice String Instructor1Phone;
        webservice String Instructor1Email;
        webservice String Instructor2;
        webservice String Instructor2Phone;
        webservice String Instructor2Email;
    }
    
    webservice static List<Id>  ga_PE_run(List<GA_StudentEnrollment> ga_Affl, GA_Partner orgDet)
    {
        system.debug('ga_Affl-->In APIService--> '+ga_Affl);
        List<Id> studentIdList = SRPGlobalAPIController.createProgramEnrollment(ga_Affl, orgDet.organizationId);   
        //List<Id> studentIdList = ga_CE_run(ga_Affl, orgDet);
        return studentIdList; 
        
    }
    
    webservice static List<String>  ga_CS_run(List<GA_CourseSection> ga_CorsSec, GA_Partner orgDet) 
    {
        system.debug('ga_CorsSec-->In APIService--> '+ga_CorsSec);
        system.debug('ga_CorsSec size>>>>'+ga_CorsSec.size());
        List<Id> sectionIdList = SRPGlobalAPIController.createCourseSection(ga_CorsSec, orgDet.organizationId);
        return sectionIdList; 
    
    }
    
    webservice static List<Id>  ga_CE_Run(List<GA_StudentEnrollment> ga_Affl, GA_Partner orgDet)
    {
        system.debug('ga_Affl-->In APIService--> '+ga_Affl);
        List<Id> studentIdList = SRPGlobalAPIController.createCourseEnrollment(ga_Affl, orgDet.organizationId);   
        return studentIdList; 
        
    }

}