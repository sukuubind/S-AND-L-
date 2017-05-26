@isTest(SeeAllData=true)
private class SRPStudentOnlineAppTriggerTest {

    static testMethod void myUnitTest() {
         // test
        User u = [Select id from user where Profile.Name = 'System Administrator' and isactive=true limit 1 ]; 
        
        System.runAs(u) {           
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
    	RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
    	RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
    	
    	Account a = new Account();
    	a.recordTypeid = rt2.Id;
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	
    	contact c = new Contact();
    	c.FirstName = 'fname';
    	c.LastName = 'lname';
    	c.Email = 'testemail@salesforce.com';
    	c.Phone = '1234567890';
    	c.AccountId = a.Id;
    	c.RecordTypeId = rt3.Id;
    	insert c;
    	
    	
    	
    	DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
    	
    	DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
    	asd.DeltakSRP__Academic_Program__c = ap.id;
    	asd.DeltakSRP__Start_Date__c = system.today() + 100;
    	asd.DeltakSRP__End_Date__c = system.today() + 200;
    	insert asd;
    	
    	Opportunity o = new Opportunity();
    	o.RecordTypeId = rt1.Id;
    	o.name = 'Test Opp';
    	o.AccountId = a.Id;
    	o.DeltakSRP__Academic_Program__c = ap.Id;
    	o.StageName = 'New Inquiry';
    	o.Sub_Stage__c = 'Awaiting Verification';
    	o.CloseDate = system.today() + 400;
    	o.DeltakSRP__Start_Date__c = system.today() + 100;
    	o.Online_Application_Stage__c = 'Registered to Apply';
    	o.DeltakSRP__Student__c = c.Id;
    	insert o;
    	
    	Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
    	/*UserRole ur = [Select Id from UserRole where name = 'Loyola University - New Orleans Customer Manager' LIMIT 1];
    	
    	Profile p = [Select Id from Profile where name = 'Online Application Portal User'];
        User u = new User();
        u.ProfileId = p.Id;
        u.FirstName = 'fname';
        u.LastName = 'lname';
        u.alias = 'newUser';
        u.email='testemail@salesforce.com';
        u.emailencodingkey='UTF-8';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US';
        u.timezonesidkey='America/Los_Angeles';
        u.username='newuser11@testorg.com';
        u.UserRoleId = ur.ID;
        String userId = Site.createPortalUser(u, a.Id, 'deltak123', true);
        system.debug('u.id >>>'+u.id); */
        //User u = [Select Id from User where profileid =: pr.Id and isactive = true limit 1];   
        
       /* DeltakSRP__Trigger_Override__c to = DeltakSRP__Trigger_Override__c.getinstance();
        to.DeltakSRP__Override_All__c = true;
        to.DeltakSRP__Override_Application__c = true;
        upsert to;
           *
        system.debug('to.DeltakSRP__Override_All__c>>>>'+to.DeltakSRP__Override_All__c);   */
        
        List<DeltakSRP__Student_Online_Application__c> onlineapp = new List<DeltakSRP__Student_Online_Application__c>();
        
       onlineapp = [Select d.Type_of_Visa__c, d.Transfer_Credit__c, d.SystemModstamp, d.Statistics_University__c, d.Statistics_Coursework_Hours__c, d.StM_OLA_Conviction_Explanation__c, d.Special_Training__c, d.SRP_Unlock_Request_Email__c, d.SRP_Unlock_Email_Recepient__c, d.SRP_Student_Name__c, d.SRP_Opportunity_Owner_Name__c, d.SRP_Attachment_Email_Sent__c, d.SRP_Application_Emails_Sent__c, d.Registered_Nurse_License_Numb__c, d.Race__c, d.RN_License_State__c, d.Program_Manager__c, d.Planned_Hours_to_Work__c, d.Permission_to_Release_Trans__c, d.OwnerId, d.Other_Phone__c, d.Other_Names__c, d.Optional_Waiver__c, d.Opportunity_Owner__c, d.Name, d.Military_Status__c, d.Military_Service_Dates__c, d.Military_Branch__c, d.Marital_Status__c, d.Maiden__c, d.LastModifiedDate, d.LastModifiedById, d.Is_English_1st__c, d.IsDeleted, d.Intention_to_Practice__c, d.Id, d.How_Heard__c, d.FA_Info_Request__c, d.Ethnicity__c, d.Employment_Start_Date__c, d.Employment_End_Date__c, d.Employer_Tuition_Reimburse__c, d.Employer_Position__c, d.Duty_Type__c, d.DeltakSRP__Zip_Postal_Code__c, d.DeltakSRP__Work_Phone__c, d.DeltakSRP__Veteran__c, d.DeltakSRP__Undergraduate_College_State__c, d.DeltakSRP__Undergraduate_College_Postal_Code__c, d.DeltakSRP__Undergraduate_College_Name__c, d.DeltakSRP__Undergraduate_College_Location__c, d.DeltakSRP__Undergraduate_College_City__c, d.DeltakSRP__Transcript_Requested__c, d.DeltakSRP__Title__c, d.DeltakSRP__Synchronize__c, d.DeltakSRP__Suffix__c, d.DeltakSRP__Submitted__c, d.DeltakSRP__Street_Address__c, d.DeltakSRP__State_Province__c, d.DeltakSRP__Start_Date__c, d.DeltakSRP__Social_Security_Number__c, d.DeltakSRP__Social_Security_Number_Encrypted__c, d.DeltakSRP__Semester_Entering__c, d.DeltakSRP__Previous_Name_s__c, d.DeltakSRP__Payment_Type__c, d.DeltakSRP__Payment_Transaction_Authorization_ID__c, d.DeltakSRP__Payment_Status__c, d.DeltakSRP__Payment_Processor__c, d.DeltakSRP__Payment_Date__c, d.DeltakSRP__Payment_Currency__c, d.DeltakSRP__Payment_Credit_Card_Last_Four_Digits__c, d.DeltakSRP__Payment_Check_Number__c, d.DeltakSRP__Payment_Amount__c, d.DeltakSRP__Online_Application_Config__c, d.DeltakSRP__OK_To_Delete__c, d.DeltakSRP__Mobile_Phone__c, d.DeltakSRP__Middle_Name__c, d.DeltakSRP__Last_Name__c, d.DeltakSRP__Job_Title__c, d.DeltakSRP__Integrate__c, d.DeltakSRP__Home_Phone__c, d.DeltakSRP__Graduate_Transcript_Requested__c, d.DeltakSRP__Graduate_Start_Date__c, d.DeltakSRP__Graduate_GPA__c, d.DeltakSRP__Graduate_End_Date__c, d.DeltakSRP__Graduate_Degree_Type__c, d.DeltakSRP__Graduate_College_State__c, d.DeltakSRP__Graduate_College_Postal_Code__c, d.DeltakSRP__Graduate_College_Name__c, d.DeltakSRP__Graduate_College_Location__c, d.DeltakSRP__Graduate_College_City__c, d.DeltakSRP__Graduate_Area_of_Study__c, d.DeltakSRP__Gender__c, d.DeltakSRP__GPA_out_of_4_0__c, d.DeltakSRP__GPA__c, d.DeltakSRP__First_Name__c, d.DeltakSRP__External_Id__c, d.DeltakSRP__Ethnicity__c, d.DeltakSRP__Essay__c, d.DeltakSRP__Essay_Attached_as_Document__c, d.DeltakSRP__End_Date__c, d.DeltakSRP__Email_Address__c, d.DeltakSRP__Degree_Type__c, d.DeltakSRP__Date_of_Birth__c, d.DeltakSRP__Country__c, d.DeltakSRP__Completed_Education__c, d.DeltakSRP__Company_State__c, d.DeltakSRP__Company_Postal_Code__c, d.DeltakSRP__Company_Name__c, d.DeltakSRP__Company_City__c, d.DeltakSRP__Company_Address_2__c, d.DeltakSRP__Company_Address_1__c, d.DeltakSRP__City__c, d.DeltakSRP__Citizenship__c, d.DeltakSRP__Business_Phone__c, d.DeltakSRP__Birthplace__c, d.DeltakSRP__Area_of_Study__c, d.DeltakSRP__Application_Status__c, d.DeltakSRP__Affiliation__c, d.DeltakSRP__Affiliation_Opportunity__c, d.DeltakSRP__Address_Line_3__c, d.DeltakSRP__Address_Line_2__c, d.DeltakSRP__Address_Line_1__c, d.DeltakSRP__Academic_Start_Date__c, d.DeltakSRP__Academic_Specialization__c, d.DeltakSRP__Academic_Program__c, d.CreatedDate, d.CreatedById, d.County__c, d.Convicted_of_Felony__c, d.Contact_Preference__c, d.Campus__c, d.Avg_Hrs_Week__c, d.Attended_Before__c, d.Account_Name__c From DeltakSRP__Student_Online_Application__c d 
        	where d.DeltakSRP__Application_Status__c = 'In Progress' and d.DeltakSRP__Academic_Program__c != null and d.DeltakSRP__Online_Application_Config__c != null
        	and d.DeltakSRP__Affiliation_Opportunity__c != null and d.DeltakSRP__Affiliation__c != null 
        	and d.DeltakSRP__Submitted__c != True and DeltakSRP__Email_Address__c = 'tapp@gmail.com' LIMIT 1]; 
       
        DeltakSRP__Student_Online_Application_Tuple__c tup= new DeltakSRP__Student_Online_Application_Tuple__c();
        tup.DeltakSRP__Company_Name__c = 'Deltak';
        tup.DeltakSRP__Student_Online_Application__c = onlineapp[0].id;
        tup.Dates_of_Employment_End__c = system.today() -100;
        insert tup;
        
        Opportunity opp = [Select Admissions_manager__c from Opportunity where Id=: onlineapp[0].DeltakSRP__Affiliation_Opportunity__c limit 1];
        opp.Admissions_Manager__c = userinfo.getUserId();
        update opp;
        
       Test.startTest();
        onlineapp[0].DeltakSRP__Application_Status__c = 'Submitted, Awaiting Payment';
        onlineapp[0].DeltakSRP__Payment_type__c = 'No Payment';
        onlineapp[0].DeltakSRP__Address_Line_1__c = '123 main st';
        onlineapp[0].DeltakSRP__Address_Line_2__c = 'apt A';
        onlineapp[0].DeltakSRP__Address_Line_3__c = 'floor 1';
        onlineapp[0].DeltakSRP__Company_Name__c = 'Deltak';
        onlineapp[0].DeltakSRP__Submitted__c = true;
        update onlineapp[0];	
        
        
        
        /*delete tup;
        onlineapp[0].DeltakSRP__Application_Status__c = 'Submitted';
        onlineapp[0].DeltakSRP__Submitted__c =true;
        update onlineapp[0];*/
        
       Test.stopTest(); 
    	//system.runAs(u){
	        /*DeltakSRP__Student_Online_Application__c testobj = new DeltakSRP__Student_Online_Application__c();
	        testobj.DeltakSRP__Academic_Program__c = ap.Id;
	        testobj.DeltakSRP__Affiliation__c = c.id;
	        testobj.DeltakSRP__Affiliation_Opportunity__c = o.Id;
	        testobj.DeltakSRP__Application_Status__c = 'In Progress';
	        testobj.DeltakSRP__Academic_start_date__c = asd.id;
	        insert testobj;*/
        
   	   // } 
    }
    }
}