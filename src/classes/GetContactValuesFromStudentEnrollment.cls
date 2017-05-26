@isTest (seeAllData=true)
private class GetContactValuesFromStudentEnrollment {

    static testMethod void TestGetContactValueAfterInsert() {
       
          string PMProfile = 'Deltak: Program Managers';
        
        Profile pro = [SELECT Id FROM profile WHERE name=:PMProfile];
        if (pro != null) {
            User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Testing',
                        languagelocalekey='en_US',
                        localesidkey='en_US', profileid = pro.Id,
                        timezonesidkey='America/Los_Angeles',
                        username='newuser11@testorg.com');
                        
            System.runAs(u2) {
       
         test.startTest();
        
        /** 
         *      First test case  - student enrollment inserted
         *  
         */
       
        Date sDate = Date.newInstance(2012, 03, 29);//start date               
        Date eDate = Date.newInstance(2012, 07, 21);//end date      
        Date dDate = Date.newInstance(2012, 05, 11);//drop date       
        Date sDate2 = Date.newInstance(2012, 03, 29);//start date              
        Date eDate2 = Date.newInstance(2012, 07, 21);//end date      
        Date dDate2 = Date.newInstance(2012, 05, 11);//drop date
        
        Account organization = new Account();
        organization.Name = 'Test Organization';
        organization.Active__c = TRUE;
        
        insert organization;
        //organization added
        
        Academic_Program__c academicProgram1 = new Academic_Program__c();
        academicProgram1.Name = 'Sample Academic Program';
        academicProgram1.School__c = organization.Id;
        academicProgram1.Program_Title__c = 'Sample Program Title';
        academicProgram1.DegreeType__c = 'Certificate';
        academicProgram1.Abbrev__c = 'SAPrg';
        academicProgram1.Active__c = TRUE;
        
        insert academicProgram1;
        //academicprogram1 added
               
        Fiscal_Calendar__c fCalendar = new  Fiscal_Calendar__c();
        fCalendar.End_Date__c = eDate;
        fCalendar.Name = 'Sample Fiscal Calendar';
        fCalendar.Start_Date__c = sDate;
        fCalendar.Period__c = '1';
        
        insert fCalendar;
        //fiscal calendar added
        
        Academic_Start_Date__c startdate1 = new Academic_Start_Date__c();
        startdate1.Start_Date__c = sDate;
        startdate1.Fiscal_Calendar__c = fCalendar.Id;
        startdate1.Program__c = academicProgram1.Id;
        
        insert startdate1;
        //startdate1 added
        
        Academic_Specialization__c academicSpec = new Academic_Specialization__c();
        academicSpec.Name = 'Sample Academic Specialization';
        academicSpec.Academic_Program__c = academicProgram1.Id;
        academicSpec.Spec_Title__c = 'Sample Specialization Title';
        academicSpec.Specialization_Abbrev__c = 'SASpec';
        
        insert academicSpec;
        //specialization added
        
       
        
        Contact affiliation = new Contact();
        affiliation.LastName = 'Johnson';
        affiliation.FirstName = 'Amy';
        affiliation.Email = 'amyJ@gmail.com';
        affiliation.Phone = '3157894521';
        
        insert affiliation;
        //affiliation added
        
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Opportunity;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('Student Opportunity');
        Id recTypeId = rt.getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.Academic_Start_Date__c = startdate1.Id;
        testOpp.Program__c = academicProgram1.Id;
        testOpp.Specialization__c = academicSpec.Id;
        testOpp.Name = 'Test Opporunity for Amy Johnson';
        testOpp.CloseDate = eDate;
        testOpp.StageName = 'New Inquiry';
        testOpp.AccountId = organization.Id;
        testOpp.RecordTypeId = recTypeId;
        insert testOpp;
        //opportunity added
        
        
        
        Student_Enrollment__c testEnrollment = new Student_Enrollment__c();      
        testEnrollment.Student_Affiliation__c = affiliation.Id;
        testEnrollment.Name = 'Test Student Enrollment';
        testEnrollment.Program__c = academicProgram1.Id;
        testEnrollment.Specialization__c = academicSpec.Id;
        testEnrollment.Start_Date__c = sDate;
        testEnrollment.Enrollment_Status__c = 'New';
        testEnrollment.Drop_Date__c = dDate;
        testEnrollment.Drop_Sub_Categories__c = 'Leave of Absence';
        testEnrollment.Drop_Common_Uses__c = 'Personal';
        testEnrollment.Drop_Reason__c = 'Moving';
        testEnrollment.Opportunity__c = testOpp.Id;
        testEnrollment.Do_Not_Register__c = TRUE;
        
        insert testEnrollment;
        //student enrollment added
        
        Academic_Program__c academicProgram2 = new Academic_Program__c();
        academicProgram2.Name = 'Sample Academic Program2';
        academicProgram2.School__c = organization.Id;
        academicProgram2.Program_Title__c = 'Sample Program Title';
        academicProgram2.DegreeType__c = 'Associates';
        academicProgram2.Abbrev__c = 'SAPrg2';
        academicProgram2.Active__c = TRUE;
        
        insert academicProgram2;
        //academicprogram2 added
        
        Fiscal_Calendar__c fCalendar2 = new  Fiscal_Calendar__c();
        fCalendar2.End_Date__c = eDate2;
        fCalendar2.Name = 'Sample Fiscal Calendar2';
        fCalendar2.Start_Date__c = sDate2;
        fCalendar2.Period__c = '1';
        
        insert fCalendar2;
        //fiscal calendar added
        
        Academic_Start_Date__c startdate2 = new Academic_Start_Date__c();
        startdate2.Start_Date__c = sDate2;
        startdate2.Fiscal_Calendar__c = fCalendar2.Id;
        startdate2.Program__c = academicProgram2.Id;
        
        insert startdate2;
        //startdate1 added
        
         Academic_Specialization__c academicSpec2 = new Academic_Specialization__c();
        academicSpec2.Name = 'Sample Academic Specialization2';
        academicSpec2.Academic_Program__c = academicProgram2.Id;
        academicSpec2.Spec_Title__c = 'Sample Specialization Title2';
        academicSpec2.Specialization_Abbrev__c = 'SASpec2';
        
        insert academicSpec2;
        //specialization2 added
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Academic_Start_Date__c = startdate1.Id;
        testOpp2.Program__c = academicProgram2.Id;
        testOpp2.Specialization__c = academicSpec2.Id;
        testOpp2.Name = 'Test Opporunity2 for Amy Johnson';
        testOpp2.CloseDate = eDate;
        testOpp2.StageName = 'New Inquiry';
        testOpp2.AccountId = organization.Id;
        testOpp2.RecordTypeId = recTypeId;
        insert testOpp2;
        //opportunity2 added
        
        Student_Enrollment__c testEnrollment2 = new Student_Enrollment__c();      
        testEnrollment2.Student_Affiliation__c = affiliation.Id;
        testEnrollment2.Name = 'Test Student Enrollment2';
        testEnrollment2.Program__c = academicProgram2.Id;
        testEnrollment2.Specialization__c = academicSpec2.Id;
        testEnrollment2.Start_Date__c = sDate;
        testEnrollment2.Enrollment_Status__c = 'New';
        testEnrollment2.Drop_Date__c = dDate;
        testEnrollment2.Drop_Sub_Categories__c = 'Program Withdrawal';
        testEnrollment2.Drop_Common_Uses__c = 'Faculty';
        testEnrollment2.Drop_Reason__c = 'Timeliness of turnaround time on grades was inadequate';
        testEnrollment2.Opportunity__c = testOpp2.Id;
        testEnrollment2.Do_Not_Register__c = TRUE;
        
        insert testEnrollment2;
        //student enrollment added
        
        /*List<Contact> updatedAffiliation = [SELECT Program__c, Specialization__c, Start_Date__c, Drop_Date__c, Drop_Sub_Categories__c, Drop_Common_Uses__c, Drop_Reason__c, Enrollment_Status__c, Do_Not_Register__c 
                                                FROM Contact 
                                                WHERE Id = :affiliation.Id];
        
        
        System.assertEquals(updatedAffiliation[0].Program__c, academicProgram2.Program_Title__c);
        System.assertEquals(updatedAffiliation[0].Specialization__c, academicSpec2.Spec_Title__c);
        System.assertEquals(updatedAffiliation[0].Start_Date__c, testEnrollment2.Start_Date__c);
        System.assertEquals(updatedAffiliation[0].Drop_Date__c, testEnrollment2.Drop_Date__c);
        System.assertEquals(updatedAffiliation[0].Drop_Sub_Categories__c, testEnrollment2.Drop_Sub_Categories__c);
        System.assertEquals(updatedAffiliation[0].Drop_Common_Uses__c, testEnrollment2.Drop_Common_Uses__c);
        System.assertEquals(updatedAffiliation[0].Drop_Reason__c, testEnrollment2.Drop_Reason__c);
        System.assertEquals(updatedAffiliation[0].Enrollment_Status__c, testEnrollment2.Enrollment_Status__c);
        System.assertEquals(updatedAffiliation[0].Do_Not_Register__c, testEnrollment2.Do_Not_Register__c);*/
        
        test.stopTest();
            }}
    }
    
    static testMethod void TestGetContactValueAfterUpdate() {
       
          string PMProfile = 'Deltak: Program Managers';
        
        Profile pro = [SELECT Id FROM profile WHERE name=:PMProfile];
        if (pro != null) {
            User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Testing',
                        languagelocalekey='en_US',
                        localesidkey='en_US', profileid = pro.Id,
                        timezonesidkey='America/Los_Angeles',
                        username='newuser11@testorg.com');
                        
            System.runAs(u2) {
         test.startTest();
        
        /** 
         *      Second test case  - student enrollment updated
         *  
         */
       
        Date sDate = Date.newInstance(2012, 03, 29);//start date               
        Date eDate = Date.newInstance(2012, 07, 21);//end date       
        Date dDate = Date.newInstance(2012, 05, 11);//drop date
        Date dDate_1 = Date.newInstance(2012, 06, 10);//drop date        
        Date sDate2 = Date.newInstance(2012, 03, 29);//start date               
        Date eDate2 = Date.newInstance(2012, 07, 21);//end date      
        Date dDate2 = Date.newInstance(2012, 05, 11);//drop date
        
        Account organization = new Account();
        organization.Name = 'Test Organization';
        organization.Active__c = TRUE;
        
        insert organization;
        //organization added
        
        Academic_Program__c academicProgram1 = new Academic_Program__c();
        academicProgram1.Name = 'Sample Academic Program';
        academicProgram1.School__c = organization.Id;
        academicProgram1.Program_Title__c = 'Sample Program Title';
        academicProgram1.DegreeType__c = 'Certificate';
        academicProgram1.Abbrev__c = 'SAPrg';
        academicProgram1.Active__c = TRUE;
        
        insert academicProgram1;
        //academicprogram1 added
        
        Fiscal_Calendar__c fCalendar = new  Fiscal_Calendar__c();
        fCalendar.End_Date__c = eDate;
        fCalendar.Name = 'Sample Fiscal Calendar';
        fCalendar.Start_Date__c = sDate;
        fCalendar.Period__c = '1';
        
        insert fCalendar;
        //fiscal calendar added
        
        Academic_Start_Date__c startdate1 = new Academic_Start_Date__c();
        startdate1.Start_Date__c = sDate;
        startdate1.Fiscal_Calendar__c = fCalendar.Id;
        startdate1.Program__c = academicProgram1.Id;
        
        insert startdate1;
        //startdate1 added
        
        Academic_Specialization__c academicSpec = new Academic_Specialization__c();
        academicSpec.Name = 'Sample Academic Specialization';
        academicSpec.Academic_Program__c = academicProgram1.Id;
        academicSpec.Spec_Title__c = 'Sample Specialization Title';
        academicSpec.Specialization_Abbrev__c = 'SASpec';
        
        insert academicSpec;
        //specialization added
        
        Contact affiliation = new Contact();
        affiliation.LastName = 'Johnson';
        affiliation.FirstName = 'Amy';
        affiliation.Email = 'amyJ@gmail.com';
        affiliation.Phone = '3157894521';
        
        insert affiliation;
        //affiliation added
          
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Opportunity;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('Student Opportunity');
        Id recTypeId = rt.getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.Academic_Start_Date__c = startdate1.Id;
        testOpp.Program__c = academicProgram1.Id;
        testOpp.Specialization__c = academicSpec.Id;
        testOpp.Name = 'Test Opporunity for Amy Johnson';
        testOpp.CloseDate = eDate;
        //testOpp.Student__c = affiliation.Id;
        testOpp.StageName = 'New Inquiry';
        testOpp.AccountId = organization.Id;
        testOpp.RecordTypeId = recTypeId;
        insert testOpp;
        //opportunity added
        
        Student_Enrollment__c testEnrollment = new Student_Enrollment__c();      
        testEnrollment.Student_Affiliation__c = affiliation.Id;
        testEnrollment.Name = 'Test Student Enrollment';
        testEnrollment.Program__c = academicProgram1.Id;
        testEnrollment.Specialization__c = academicSpec.Id;
        testEnrollment.Start_Date__c = sDate;
        testEnrollment.Enrollment_Status__c = 'New';
        testEnrollment.Drop_Date__c = dDate;
        testEnrollment.Drop_Sub_Categories__c = 'Leave of Absence';
        testEnrollment.Drop_Common_Uses__c = 'Personal';
        testEnrollment.Drop_Reason__c = 'Moving';
        testEnrollment.Opportunity__c = testOpp.Id;
        testEnrollment.Do_Not_Register__c = TRUE;
        
        insert testEnrollment;
        //student enrollment added
        
        testEnrollment.Drop_Date__c = dDate_1;
        update testEnrollment;
        //student enrollment updated
        
                Academic_Program__c academicProgram2 = new Academic_Program__c();
        academicProgram2.Name = 'Sample Academic Program2';
        academicProgram2.School__c = organization.Id;
        academicProgram2.Program_Title__c = 'Sample Program Title';
        academicProgram2.DegreeType__c = 'Associates';
        academicProgram2.Abbrev__c = 'SAPrg2';
        academicProgram2.Active__c = TRUE;
        
        insert academicProgram2;
        //academicprogram2 added
        
        Fiscal_Calendar__c fCalendar2 = new  Fiscal_Calendar__c();
        fCalendar2.End_Date__c = eDate2;
        fCalendar2.Name = 'Sample Fiscal Calendar2';
        fCalendar2.Start_Date__c = sDate2;
        fCalendar2.Period__c = '1';
        
        insert fCalendar2;
        //fiscal calendar added
        
        Academic_Start_Date__c startdate2 = new Academic_Start_Date__c();
        startdate2.Start_Date__c = sDate2;
        startdate2.Fiscal_Calendar__c = fCalendar2.Id;
        startdate2.Program__c = academicProgram2.Id;
        
        insert startdate2;
        //startdate1 added
        
         Academic_Specialization__c academicSpec2 = new Academic_Specialization__c();
        academicSpec2.Name = 'Sample Academic Specialization2';
        academicSpec2.Academic_Program__c = academicProgram2.Id;
        academicSpec2.Spec_Title__c = 'Sample Specialization Title2';
        academicSpec2.Specialization_Abbrev__c = 'SASpec2';
        
        insert academicSpec2;
        //specialization2 added
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Academic_Start_Date__c = startdate1.Id;
        testOpp2.Program__c = academicProgram2.Id;
        testOpp2.Specialization__c = academicSpec2.Id;
        testOpp2.Name = 'Test Opporunity2 for Amy Johnson';
        testOpp2.CloseDate = eDate;
        testOpp2.StageName = 'New Inquiry';
        testOpp2.AccountId = organization.Id;
        testOpp2.RecordTypeId = recTypeId;
        insert testOpp2;
        //opportunity2 added
        
        Student_Enrollment__c testEnrollment2 = new Student_Enrollment__c();      
        testEnrollment2.Student_Affiliation__c = affiliation.Id;
        testEnrollment2.Name = 'Test Student Enrollment2';
        testEnrollment2.Program__c = academicProgram2.Id;
        testEnrollment2.Specialization__c = academicSpec2.Id;
        testEnrollment2.Start_Date__c = sDate;
        testEnrollment2.Enrollment_Status__c = 'New';
        testEnrollment2.Drop_Date__c = dDate;
        testEnrollment2.Drop_Sub_Categories__c = 'Program Withdrawal';
        testEnrollment2.Drop_Common_Uses__c = 'Faculty';
        testEnrollment2.Drop_Reason__c = 'Timeliness of turnaround time on grades was inadequate';
        testEnrollment2.Opportunity__c = testOpp2.Id;
        testEnrollment2.Do_Not_Register__c = TRUE;
        insert testEnrollment2;
        //student enrollment added
        
        testEnrollment2.Drop_Reason__c = 'The instructor(s) did not meet expectations';
        update testEnrollment2;
        //student enrollment updated
        
        /*List<Contact> updatedAffiliation = [SELECT Program__c, Specialization__c, Start_Date__c, Drop_Date__c, Drop_Sub_Categories__c, Drop_Common_Uses__c, Drop_Reason__c, Enrollment_Status__c, Do_Not_Register__c
                                                FROM Contact 
                                                WHERE Id = :affiliation.Id];
        
    
        System.assertEquals(updatedAffiliation[0].Program__c, academicProgram2.Program_Title__c);
        System.assertEquals(updatedAffiliation[0].Specialization__c, academicSpec2.Spec_Title__c);
        System.assertEquals(updatedAffiliation[0].Start_Date__c, testEnrollment2.Start_Date__c);
        System.assertEquals(updatedAffiliation[0].Drop_Date__c, testEnrollment2.Drop_Date__c);
        System.assertEquals(updatedAffiliation[0].Drop_Sub_Categories__c, testEnrollment2.Drop_Sub_Categories__c);
        System.assertEquals(updatedAffiliation[0].Drop_Common_Uses__c, testEnrollment2.Drop_Common_Uses__c);
        System.assertEquals(updatedAffiliation[0].Drop_Reason__c, testEnrollment2.Drop_Reason__c);
        System.assertEquals(updatedAffiliation[0].Enrollment_Status__c, testEnrollment2.Enrollment_Status__c);
        System.assertEquals(updatedAffiliation[0].Do_Not_Register__c, testEnrollment2.Do_Not_Register__c);*/
        
        test.stopTest();
        
            }}
    }
}