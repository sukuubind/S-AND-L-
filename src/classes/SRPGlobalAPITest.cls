/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class SRPGlobalAPITest {

    static testMethod void myUnitTest() {
       
     	Account a = new Account();
        a.recordTypeid = findAccountRecordType();
        a.name = 'test acc';
        
        insert a;
        
        User uAdmin = new User();
        
        
        //Select g.Which_Partner__c, g.What_Field__c, g.SF_Value__c, g.Partner_Value__c, g.Name From Global_API_Translation__c g
        List<Global_API_Translation__c> transList = new List<Global_API_Translation__c>();	
        	Global_API_Translation__c trans = new Global_API_Translation__c();
        	trans.Which_Partner__c = a.id;
        	trans.What_Field__c = 'Status';
        	trans.SF_Value__c = 'Enrolled';
        	trans.Partner_Value__c = 'RE';
        	transList.add(trans);
        	
        	Global_API_Translation__c trans2 = new Global_API_Translation__c();
        	trans2.Which_Partner__c = a.id;
        	trans2.What_Field__c = 'EnrollmentStatus';
        	trans2.SF_Value__c = 'Enrolled';
        	trans2.Partner_Value__c = 'AS-Active';
        	transList.add(trans2);
        insert transList;
        
        List<DeltakSRP__Academic_Program__c> programsToInsert = new List<DeltakSRP__Academic_Program__c>();
        
        	DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        	ap.DeltakSRP__School__c = a.Id;
        	ap.DeltakSRP__SIS_External_Id__c = 'pgm - 1';
        	ap.DeltakSRP__Program_Title__c = a.name + ' - pgm - 1';
        	programsToInsert.add(ap);
        	
        	/*DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
        	ap2.DeltakSRP__School__c = a.Id;
        	ap2.DeltakSRP__SIS_External_Id__c = 'pgm - 2';
        	ap2.DeltakSRP__Program_Title__c = a.name + ' - pgm - 2';
        	programsToInsert.add(ap2);*/
        	
        insert programsToinsert;
        
     	Date today_date = system.now().date();
     	List<DeltakSRP__Academic_Start_Date__c> termsToInsert = new List<DeltakSRP__Academic_Start_Date__c>();
     	
        	DeltakSRP__Academic_Start_Date__c atrm = new DeltakSRP__Academic_Start_Date__c();
        	atrm.DeltakSRP__Academic_Program__c = ap.id;
        	atrm.DeltakSRP__Start_Date__c = today_date;
        	atrm.DeltakSRP__End_Date__c = today_date + 90;
        	atrm.DeltakSRP__Online_Application_Label__c = 'Test Term 1';
        	atrm.DeltakSRP__Term_Label__c = String.valueOf(system.now().date());
        	termsToInsert.add(atrm);
        	
        	/*DeltakSRP__Academic_Start_Date__c atrm2 = new DeltakSRP__Academic_Start_Date__c();
        	atrm.DeltakSRP__Academic_Program__c = ap2.id;
        	atrm2.DeltakSRP__Start_Date__c = today_date;
        	atrm2.DeltakSRP__End_Date__c = today_date + 90;
        	atrm2.DeltakSRP__Online_Application_Label__c = 'Test Term 2';
        	atrm2.DeltakSRP__Term_Label__c = String.valueOf(today_date);
        	termsToInsert.add(atrm2);*/
        	System.debug('termsToInsert-->'+termsToInsert);
        insert termsToInsert;
     	
     	List<Contact> contactsToInsert = new List<Contact>();
     	
	     	Contact affl = new Contact();
	     	affl.RecordTypeId = '01260000000Q6Jh';
			affl.LastName = 'Student1';
			affl.FirstName = 'Test';
			affl.AccountId = a.id;
			affl.DeltakSRP__Student_ID__c = '4444444';
			contactsToInsert.add(affl);
			
			Contact affl2 = new Contact();
	    	affl2.RecordTypeId = '01260000000Q6Jh';
			affl2.LastName = 'Student2';
			affl2.FirstName = 'Test';
			affl2.AccountId = a.id;
			affl2.DeltakSRP__Student_ID__c = '5555555';
     		contactsToInsert.add(affl2);
     	
     	insert contactsToInsert;
     	
     	List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
	     	Opportunity oppty = new Opportunity();
	        //Select o.StageName, o.SRP_Student_Name__c, o.SRP_Student_Last_Name__c, o.SRP_Student_Id__c, o.RecordTypeId, o.OwnerId, o.Name, o.Mobile_Phone__c, o.Date_Transferred__c, o.AccountId From Opportunity o;
	        //'New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1
	        oppty.StageName = 'New Inquiry';
			oppty.RecordTypeId = '01260000000Q6Ju';
			oppty.DeltakSRP__External_Id__c = 'TAV-Test';
			oppty.Name = 'TAV-Test';
			oppty.AccountId = a.id;
			oppty.closeDate = today_date + 9;
			oppty.DeltakSRP__Student__c = affl.id;
			oppty.DeltakSRP__Academic_Program__c = ap.id;
			opportunitiesToInsert.add(oppty);
			
			/*Opportunity oppty2 = new Opportunity();
	        //Select o.StageName, o.SRP_Student_Name__c, o.SRP_Student_Last_Name__c, o.SRP_Student_Id__c, o.RecordTypeId, o.OwnerId, o.Name, o.Mobile_Phone__c, o.Date_Transferred__c, o.AccountId From Opportunity o;
	        //'New Inquiry','01260000000Q6Ju','TAV-Test','00655000102Ler9',a.id,System.today()+1
	        oppty2.StageName = 'New Inquiry';
			oppty2.RecordTypeId = '01260000000Q6Ju';
			oppty2.DeltakSRP__External_Id__c = 'TAV-Test2';
			oppty2.Name = 'TAV-Test2';
			oppty2.AccountId = a.id;
			oppty2.closeDate = today_date + 10;
			oppty2.DeltakSRP__Student__c = affl2.id;
			oppty2.DeltakSRP__Academic_Program__c = ap2.id;
			opportunitiesToInsert.add(oppty2);*/
     	
     	insert opportunitiesToInsert;
     	
     	List<DeltakSRP__Program_Enrollment__c> peToInsert = new List<DeltakSRP__Program_Enrollment__c>();
     	
     		DeltakSRP__Program_Enrollment__c pe = new DeltakSRP__Program_Enrollment__c();
     		pe.Account_Id__c = a.id;
     		pe.DeltakSRP__Enrolled_Student__c = affl.id;
     		pe.DeltakSRP__Academic_Program__c = ap.id;
     		pe.DeltakSRP__Opportunity__c = oppty.id;
     		pe.DeltakSRP__Start_Date__c = today_date;
     		pe.DeltakSRP__Enrollment_Start__c = atrm.id;
     		pe.DeltakSRP__SIS_External_Id__c = 'TST-4444444-pgm - 1';
     		peToInsert.add(pe);
     		
     	/*	DeltakSRP__Program_Enrollment__c pe2 = new DeltakSRP__Program_Enrollment__c();
     		pe2.Account_Id__c = a.id;
     		pe.DeltakSRP__Enrolled_Student__c = affl2.id;
     		pe2.DeltakSRP__Opportunity__c = oppty2.id;
     		pe2.DeltakSRP__Start_Date__c = today_date;
     		pe2.DeltakSRP__Enrollment_Start__c = atrm2.id;
     		pe2.DeltakSRP__SIS_External_Id__c = 'TST-5555555-pgm - 2';
     		peToInsert.add(pe2);*/
     	insert peToInsert;
        Test.startTest();
         
       List<SRPGlobalAPIService.GA_CourseSection> ga_Cousec = setCourseFields();
       List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl = setAfflFields();
        SRPGLobalAPIService.GA_Partner gPartner = new SRPGLobalAPIService.GA_Partner();
        gPartner.organizationId = a.id;
        SRPGlobalAPIService.ga_CS_run(ga_Cousec, gPartner);
        SRPGlobalAPIService.ga_PE_run(ga_Affl, gPartner); 
        SRPGlobalAPIService.ga_CE_run(ga_Affl, gPartner);
        
        List<DeltakSRP__Course_Enrollment__c> ceUpd = [select id, Name, DeltakSRP__Status__c from DeltakSRP__Course_Enrollment__c where DeltakSRP__Enrolled_Student__c =: affl.id];
        DeltakSRP__Course_Enrollment__c ce = new DeltakSRP__Course_Enrollment__c(id=ceUpd[0].id);
        ce.DeltakSRP__Status__c = 'Drop';
        update ce;
        
        Test.stopTest();
    }
    private static List<SRPGlobalAPIService.GA_CourseSection> setCourseFields(){
        //insertCampaign();
        List<SRPGlobalAPIService.GA_CourseSection> ga_Cousec = new List<SRPGlobalAPIService.GA_CourseSection>();
        SRPGlobalAPIService.GA_CourseSection couSec = new SRPGlobalAPIService.GA_CourseSection();
        couSec.AcademicSection='01O';
		couSec.Capacity='21';
		couSec.CatalogNumber=null;
		couSec.ClassType='Online';
		couSec.CourseAbbreviation='Fund of Orgnztl Leadership';
		couSec.CourseCreditType='Standard Letter';
		couSec.CourseDescription='This survey course will provide an overview of the topic.';
		couSec.CourseFee=null;
		couSec.CourseID='MSOL601';
		couSec.CourseSISId='MHC-MSOL601-pgm - 1';
		couSec.CourseTitle='Fundamentals of Organizational Leadership';
		couSec.CourseUnits='3';
		couSec.Days=null;
		couSec.EndDate=system.now().date()+90;
		couSec.Instructor1=null;
		couSec.Instructor1Email=null;
		couSec.Instructor1Phone=null;
		couSec.Instructor2=null;
		couSec.Instructor2Email=null;
		couSec.Instructor2Phone=null;
		couSec.OrganizationId=null;
		couSec.ProgramSISId='pgm - 1';
		couSec.SectionEndDate=null;
		couSec.SectionID='MSOL60101OTst';
		couSec.SectionSISId='MHC-01O-MSOL601-2015-10-26-pgm - 1';
		couSec.SectionStartDate=null;
		couSec.SpecializationSISId=null;
		couSec.StartDate=system.now().date();
		couSec.termSISId='201608';
		
		ga_Cousec.add(couSec);
        return ga_Cousec;
    }
    
    private static List<SRPGLobalAPIService.GA_StudentEnrollment> setAfflFields(){
        //insertCampaign();
        List<SRPGLobalAPIService.GA_StudentEnrollment> ga_Affl = new List<SRPGLobalAPIService.GA_StudentEnrollment>();
        SRPGlobalAPIService.GA_StudentEnrollment affl = new SRPGlobalAPIService.GA_StudentEnrollment();
        affl.AdditionalInfo=null;
		affl.AdvisorEmail=null;
		affl.AdvisorName=null;
		affl.AdvisorPhoneNumber=null;
		affl.CE_LastSISUpdate=null;
		affl.CE_SISExternalId='TST-4444444-pgm - 1-4444444';
		affl.CE_termSISId='201618';
		affl.Conditional=null;
		affl.CourseID='605';
		affl.CourseSectionStartDate=system.now().date();
		affl.CourseType='ONL';
		affl.CreditsReceived='3';
		affl.DoNotRegister=null;
		affl.DropDate=null;
		affl.DropReason=null;
		affl.EnrollmentStatus='AS';
		affl.FinalGrade=null;
		affl.FinalPercentage=null;
		affl.GPA=null;
		affl.GradePoint=null;
		affl.GraduationDate=null;
		affl.Matriculated='G';
		affl.Modality='Online';
		affl.PE_LastSISUpdate=null;
		affl.PE_SISExternalId='TST-4444444-pgm - 1';
		affl.PE_termSISId='201618';
		affl.PgmStartDate=system.now().date();
		affl.Provisional=null;
		affl.SectionID='MSOL60101OTst';
		affl.Status='RE';
		affl.StatusReasonCodes=null;
		affl.StudentID='4444444';
		affl.TotalTransferredCredits=null;
		affl.TransferCourseName=null;
		affl.TransferCourseType=null;
		affl.TransferCredit=null;
		affl.TransferDetails=null;
		affl.programSISId='pgm - 1';
		affl.specializationSISId=null;
		
		ga_Affl.add(affl);
        return ga_Affl;
    }
    
    private static ID findAccountRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Account;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'SRP Account') {
                
                System.debug(LoggingLevel.INFO,'The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    } 
}