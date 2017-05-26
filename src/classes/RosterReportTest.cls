/**
 v 1.0 Pratik Tanna - Test Class for RosterReport
 */
@isTest (SeeAllData=true)
private class RosterReportTest {

    static testMethod void myUnitTest() {
    	
    	 
    	// Create an Account
    	Account testAccount = DeltakSRP.TestUtils.createAccount();
    	
    	// Create a Student
    	Contact testStudent = DeltakSRP.TestUtils.createContact('firstName', 'lastName', 'testemail@testemails.com', testAccount.Id, false);
    	testStudent.DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId();
    	Database.insert(testStudent);
    	
    	DeltakSRP__Academic_Program__c testProgram = new DeltakSRP__Academic_Program__c(
	    	DeltakSRP__Active__c = true,
	    	Name = 'test Program',
	    	DeltakSRP__School__c = testAccount.Id
    	);
    	Database.insert(testProgram);
    	
    	// Create an Academic Course with the Academic Program set as primary
    	DeltakSRP__Academic_Course__c testCourse = new DeltakSRP__Academic_Course__c(
    		DeltakSRP__Academic_Institution__c = testAccount.Id,
    		DeltakSRP__Active__c = true,
    		DeltakSRP__Course_Units__c = 3,
    		DeltakSRP__Primary_Program__c = testProgram.Id,
    		Name = 'testCourseRecord'
    	);
		Database.insert(new List<DeltakSRP__Academic_Course__c> {testCourse});
		
    	// Create an Academic Start Date
    	DeltakSRP__Academic_Start_Date__c testTerm = new DeltakSRP__Academic_Start_Date__c(
	    	DeltakSRP__Start_Date__c = Date.today(),
	    	DeltakSRP__End_Date__c = Date.today().addDays(120),
	    	DeltakSRP__Term_Label__c = 'Fall 2013'
    	);
    	Database.insert(new List<DeltakSRP__Academic_Start_Date__c>{testTerm});
    	
    	// Create an Academic Section
    	DeltakSRP__Academic_Section__c testSection = new DeltakSRP__Academic_Section__c(
	    	DeltakSRP__Academic_Course__c = testCourse.Id,
	    	DeltakSRP__Academic_Term__c = testTerm.Id,
	    	DeltakSRP__Section_ID__c = '123456789'
    	);
    	Database.insert(New List<DeltakSRP__Academic_Section__c>{testSection});
    	
    	DeltakSRP__Program_Enrollment__c testProgEnrollment = new DeltakSRP__Program_Enrollment__c(
	    	DeltakSRP__Academic_Program__c = testProgram.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Enrollment_Status__c = 'Graduate',
	    	DeltakSRP__Enrollment_Start__c = testTerm.Id,
	    	DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId()
    	);
    	Database.insert(testProgEnrollment);
    	
    	DeltakSRP__Course_Enrollment__c testEnrollment1 = new DeltakSRP__Course_Enrollment__c(
	    	DeltakSRP__Academic_Section__c = testSection.Id,
	    	DeltakSRP__Academic_Start_Date__c = testTerm.Id,
	    	DeltakSRP__Enrolled_Student__c = testStudent.Id,
	    	DeltakSRP__Program_Enrollment__c = testProgEnrollment.Id,
	    	DeltakSRP__Final_Grade__c = 'C',
	    	DeltakSRP__Term_Start__c = Date.today().addDays(-90)
    	);
    	Database.insert(testEnrollment1);
        RosterReport testObj  = new RosterReport();
        string f13 = 'Fall 2013';
        List<String> selectedTerms = new List<String>();
        selectedterms.add(f13);
        testobj.setSelectedTerms(selectedTerms);
        string fp = 'mscs';
        List<String> selectedPrograms = new List<String>();
        selectedPrograms.add(fp);
        testobj.setSelectedPrograms(selectedPrograms);
        string fa = 'testacc';
        List<String> selectedAccounts = new List<String>();
        selectedAccounts.add(fa);
         testobj.setSelectedAccounts(selectedAccounts);
         testobj.setce(new List<DeltakSRP__Course_Enrollment__c>());
        testobj.getce().add(testEnrollment1);
        Pagereference p = testobj.go();
      //  system.assertequals(p, null);
        testobj.setSelectedAccounts(selectedAccounts);
         testobj.setce(new List<DeltakSRP__Course_Enrollment__c>());
        testobj.getce().add(testEnrollment1);
        testobj.rosterreport();
        Boolean b = testobj.getReportGenerated();
      //  system.assertEquals(b, false);
        testobj.setReportGenerated();
        List<SelectOption> so = testobj.getterms();
       // system.assertequals(so.size(), 1);
        testobj.getSelectedTerms();
        
        List<SelectOption> so2 = testobj.getPrograms();
      //  system.assertequals(so2.size(), 1);
        
        testObj.getSelectedPrograms();
        
          
        so = testobj.getAccounts();
       // system.assertequals(so.size(), 1);
        
        testobj.getSelectedAccounts();
        
        rosterreport.statusBean teststatusbean = new rosterreport.statusBean();
        testobj.getsbList().add(teststatusbean); 
        
        rosterreport.studentBean teststudentbean = new rosterreport.studentBean();
        testobj.getsb().add(teststudentbean);
           
        rosterreport.courseBean testcoursebean = new rosterreport.courseBean();
        testcoursebean.settotalNonDeltakCredits(1);  
        testcoursebean.settotalCredits(2);
        rosterreport.termbean testtermbean = new rosterreport.termbean();
        testtermbean.settotalNonDeltakCredits(1); 
        testtermbean.settotalCredits(2);
        testtermbean.settotalEnrollNonDeltak(4);
        testtermbean.settotalActiveDeltakStudents(6);
        testtermbean.settotalActiveNonDeltakStudents(2);
        testtermbean.settotalStudents(9);
        testtermbean.settotalEnroll(15);
        testtermbean.settotalEnrollNonDeltak(10);
        testtermbean.settotalCourseEnrollments (15);
        testtermbean.setcourse( new List<rosterreport.courseBean>());
        testtermbean.getcourse().add(testcoursebean);
        testobj.gettblist().add(testtermbean); 
       
        list<rosterreport.statusBean> sb1 = testobj.getStatusBeanList();
     //   system.assertequals(sb1.size(),1);
        
        list<rosterreport.studentBean> sb2 = testobj.getStudentBeans();
       // system.assertequals(sb2.size(),1);
        
        list<rosterreport.termBean> tb = testobj.getTermBeanList();
      //  system.assertequals(tb.size(),1);
    }
}