@isTest (seeAllData=true)
private class SRPOpportunityTriggerTests {
          static testMethod void testValidateChangingStartDate() {
        
      /*  Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {*/
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
                Contact c = new Contact ();
            c.FirstName='Joe'+String.valueOf(i);
            c.LastName='Smith'+String.valueOf(i);
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.deltakSRP__Employer_Company__c = 'Disney'; 
            contactList.add(c);
            }
           
            insert contactList;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
             ap.Name = 'Test Program';
             ap.DeltakSRP__School__c = a.Id;
             insert ap;
             
             //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.DeltakSRP__School__c = a2.Id;
             insert ap2;
             
             DeltakSRP__Academic_Start_Date__c startDate = new DeltakSRP__Academic_Start_Date__c ();
             startDate.deltaksrp__Start_Date__c = d;
             startDate.deltaksrp__Academic_Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
            List <Opportunity> oppList = new List<Opportunity>();
            
             List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
           
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.deltaksrp__academic_Program__c = ap.Id;           
                o.AccountID=a.Id;
                o.deltaksrp__Student__c=contactList.get(i).Id;   
                o.deltaksrp__Start_Date__c = sd;
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
                    
            
            insert oppList;
            
            set <Id> oppSet = new Set<Id>();
            
            //now change it back to a valid one
            for (Opportunity oppRecord : oppList) {        
                oppRecord.deltaksrp__Start_Date__c = d;
                oppSet.add(oppRecord.Id);
            }  
            
            update oppList;
            
            Opportunity [] updatedOpps = [SELECT deltaksrp__Academic_Start_Date__c FROM Opportunity WHERE Id IN :oppSet];
            
            for (Opportunity oppRecord : updatedOpps) {
               // System.assertEquals(startDate.Id, oppRecord.Academic_Start_Date__c);            
            }
             
          Test.stopTest();
     //   }
    }
    static testMethod void testOppStartDateChanged(){
         Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
                Contact c = new Contact ();
            c.FirstName='Joe'+String.valueOf(i);
            c.LastName='Smith'+String.valueOf(i);
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.deltakSRP__Employer_Company__c = 'Disney'; 
            contactList.add(c);
            }
           
            insert contactList;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
             ap.Name = 'Test Program';
             ap.DeltakSRP__School__c = a.Id;
             insert ap;
             
             //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.DeltakSRP__School__c = a2.Id;
             insert ap2;
             
             DeltakSRP__Academic_Start_Date__c startDate = new DeltakSRP__Academic_Start_Date__c ();
             startDate.deltaksrp__Start_Date__c = d;
             startDate.deltaksrp__Academic_Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
            List <Opportunity> oppList = new List<Opportunity>();
            
             List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
           
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                if(i < 9)
                o.deltaksrp__academic_Program__c = ap.Id;  
                o.AccountID=a.Id;
                o.deltaksrp__Student__c=contactList.get(i).Id; 
                o.deltaksrp__Start_Date__c = sd;
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
                    
            
            insert oppList;
            
            
            oppList = SRPOpp_StartDateChanged.findAcademicStartDateRecords(oppList);
            SRPOpp_StartDateChanged.startDateChangedToNull(oppList);
            SRPOpp_ProgramChanged.programChangedToNull(oppList, oppList);
            

             
          Test.stopTest();
        
        
    }
    static testMethod void testAdmissionDocsControllerTest(){
        Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
                Contact c = new Contact ();
            c.FirstName='Joe'+String.valueOf(i);
            c.LastName='Smith'+String.valueOf(i);
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.deltakSRP__Employer_Company__c = 'Disney'; 
            contactList.add(c);
            }
           
            insert contactList;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
             ap.Name = 'Test Program';
             ap.DeltakSRP__School__c = a.Id;
             insert ap;
             
             //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.DeltakSRP__School__c = a2.Id;
             insert ap2;
             
             DeltakSRP__Academic_Start_Date__c startDate = new DeltakSRP__Academic_Start_Date__c ();
             startDate.deltaksrp__Start_Date__c = d;
             startDate.deltaksrp__Academic_Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
            List <Opportunity> oppList = new List<Opportunity>();
            
             List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
           
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                if(i < 9)
                o.deltaksrp__academic_Program__c = ap.Id;  
                o.AccountID=a.Id;
                o.deltaksrp__Student__c=contactList.get(i).Id; 
                o.deltaksrp__Start_Date__c = sd;
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
                    
            
            insert oppList;
            
            //List<RecordType> recListP = [Select Id from RecordType where Name = 'Application Fee' limit 1];
            DeltakSRP__Program_Admission_Document__c pad = new DeltakSRP__Program_Admission_Document__c();
            pad.DeltakSRP__Opportunity__c = oppList[0].Id;
            pad.SRP_Academic_Program__c = ap.Id;
            //pad.RecordTypeId = recListP[0].Id;
            insert pad;
            
            SRPAdmissionsdocsController adminDocs = new SRPAdmissionsdocsController();
            List <DeltakSRP__Program_Admission_Document__c>  missedDocuments = adminDocs.missingDocsList;
           List <DeltakSRP__Program_Admission_Document__c> receivedDocuments = adminDocs.receivedDocsList;
            
          Test.stopTest();
    }
    
   
    
    static testMethod void testCreateEnrollmentRecord() {
        
       /* Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) { */
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
            
            List<Account> accountList = new List<Account>();
            Account a = new Account();
            a.Name = 'Test Account';
            accountList.add(a);
            
            
            Account a2 = new Account();
            a2.Name = 'Test Account 2';
            accountList.add(a2);
            insert accountList;
          
            
            List<Contact> contactList = new List<Contact>();
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222'; 
            c.AccountID = a.Id;
            c.deltaksrp__Employer_Company__c = 'Apple';
            c.DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId();
            c.DeltakSRP__Student_ID__c = '121213120';
            contactList.add(c);       
            //insert c;
           
           
            for(Integer i=0;i<10;i++){
             Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';
             c2.AccountID = a2.Id;
             c2.deltaksrp__Employer_Company__c = 'Disney';
             c2.DeltakSRP__Student_Services_Coordinator__c = userinfo.getUserId();
             c2.DeltakSRP__Student_ID__c = '12121312'+String.valueOf(i);
             contactList.add(c2); 
            }
           
            insert contactList; 
           
            
            //set up a program and set the opportunity to it
            List<deltaksrp__Academic_Program__c> acadProgList = new List<deltaksrp__Academic_Program__c>();
            deltaksrp__Academic_Program__c ap = new deltaksrp__Academic_Program__c();
            ap.Name = 'Test Program';
            ap.deltaksrp__School__c = a.Id;
            acadProgList.add(ap);           
             
             //set up a program and set the opportunity to it
             DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.deltaksrp__School__c = a2.Id;
             acadProgList.add(ap2);
             insert acadProgList;
             
             DeltakSRP__Academic_Start_Date__c startDate = new DeltakSRP__Academic_Start_Date__c ();
             startDate.DeltakSRP__Start_Date__c = d;
             startDate.DeltakSRP__Academic_Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);           
            
            List <Opportunity> oppList = new List<Opportunity>();           
            List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.DeltakSRP__Academic_Program__c = ap.Id;           
                o.AccountID=a.Id;
                o.deltaksrp__Student__c=contactList.get(i).Id; 
                //o.Start_Date__c = sd;
                o.DeltakSRP__Start_Date__c = d; //CB
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
            
            insert oppList;
            
            set <Id> oppSet = new Set<Id>();
            
            //now change it back to a valid one
            for (Opportunity oppRecord : oppList) {        
                oppRecord.StageName = 'Start';
                oppRecord.DeltakSRP__Date_Accepted__c = sd;
                oppRecord.DeltakSRP__Date_Submitted__c = sd;
                oppRecord.DeltakSRP__Acceptance_Status__c = 'Fully Admitted';
                oppSet.add(oppRecord.Id);
            }  
            
            update oppList;
            
            //verify that the opportunity now has a link to the newly created enrollment record
            Opportunity [] oppty = [select  DeltakSRP__Student__c, DeltakSRP__Academic_Program__c, DeltakSRP__Start_Date__c, Id, Student_Enrollment__c
                             FROM Opportunity 
                             WHERE Id IN :oppSet];
            
            Set <Id> stdEnrollSet = new Set <Id>();
            
            for (Opportunity o : oppty) {
                stdEnrollSet.add(o.Id);
            }           
            
            Student_Enrollment__c [] enrollment = [select Student_Affiliation__c,
                                                       Program__c,
                                                       Start_Date__c,
                                                       Opportunity__c 
                                                FROM   Student_Enrollment__c
                                                WHERE  Opportunity__c IN :stdEnrollSet
                                                ];
          //  System.assertEquals(oppty.size() , enrollment.size());

            Test.stopTest();
      //  }
    }
    
     
    
    //Set Referred_By_Person__c by setting it to the Person who is related to the Referred by Opportunity field 
    static testMethod void testSetReferredByPerson() {
        
     /*   Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) { */
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
           
          
          List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
             Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';
             c2.AccountID = a.Id;
             c2.deltaksrp__Employer_Company__c = 'Disney';
             
             contactList.add(c2); 
            }
           
            insert contactList; 
            DeltakSRP__Person__c p = new DeltakSRP__Person__c();
            insert p;
            System.debug('--- Person Id = '+ p.Id);
            List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
            Opportunity o = new Opportunity();
            o.CloseDate=d;
            o.StageName='New Inquiry';
            o.RecordTypeId = recList[0].Id;
            o.Name='Test';
            o.AccountID=a.Id;
            o.deltaksrp__Student__c=contactList.get(0).Id;        
            insert o;    
            System.debug('--- Opp 1 Id = '+ o.Id);
            
            Opportunity o2 = new Opportunity();
            o2.CloseDate=d;
            o2.StageName='New Inquiry';        
            o2.Name='Test';
            o2.AccountID=a.Id;
            o.deltaksrp__Student__c=contactList.get(1).Id;     
            o2.SRP_Person__c = p.Id;
            o2.RecordTypeId = recList[0].id;
            insert o2;
            System.debug('--- Opp 2 Id = '+ o2.Id);
            
            o.Referred_By_Opportunity__c = o2.Id;
            try {
                update o;
            }
            catch (Exception e) {
                System.debug(e);            
            }
            Test.stopTest();
      //  }
    }
    
    static testMethod void testChangeStudentTask() {
         /*   Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) { */
        DeltakSRP__Person__c p = new DeltakSRP__Person__c();
        insert p;
        
        DeltakSRP__Person__c p2 = new DeltakSRP__Person__c();
        insert p2;
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
       
      
       List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
             Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';
             c2.AccountID = a.Id;
             c2.deltaksrp__Employer_Company__c = 'Disney';
             
             contactList.add(c2); 
            }
           
            insert contactList; 
        
        Contact c2 = new Contact ();
        c2.FirstName='Contact 2';
        c2.LastName='Contact 2';
        c2.Phone='2222222222';   
        c2.AccountID = a.Id;     
        c2.DeltakSRP__Person__c = p2.Id;
        insert c2;
        List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
        Opportunity o2 = new Opportunity();
        o2.CloseDate=System.today();
        o2.StageName='New Inquiry';        
        o2.Name='Test';
        o2.AccountID=a.Id;
       o2.deltaksrp__Student__c=contactList.get(0).Id; 
        o2.SRP_Person__c = p.Id;
        o2.RecordTypeId = recList[0].Id;
        insert o2;
        List<RecordType> recList1 = [Select Id from RecordType where Name = 'SRP Student' limit 1];
        Task tsk = new Task();
        tsk.Subject='Call - Inbound';
        tsk.Status = 'Complete';
        tsk.WhatId = o2.Id;        
        tsk.DeltakSRP__Result__c = 'Successful';
        tsk.Successful__c = true; 
        tsk.Asked_for_Referral__c = 'Yes';
        //tsk.RecordTypeId = recList1[0].Id;       
        insert tsk;
        
        
        o2.DeltakSRP__Student__c = c2.Id;
        update o2;
        
        Task [] verifyTask = [Select WhoId FROM Task WHERE Id = :tsk.Id];
       
        //System.assertEquals(verifyTask[0].WhoId, c2.Id);
    //}
       
    }
    
    
    static testMethod void testChangeStudentEvent() {
         /*   Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) { */
        DeltakSRP__Person__c p = new DeltakSRP__Person__c();
        insert p;
        
        DeltakSRP__Person__c p2 = new DeltakSRP__Person__c();
        insert p2;
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
       
      
       List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
             Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';
             c2.AccountID = a.Id;
             c2.deltaksrp__Employer_Company__c = 'Disney';
             
             contactList.add(c2); 
            }
           
            insert contactList; 
        
        Contact c2 = new Contact ();
        c2.FirstName='Contact 2';
        c2.LastName='Contact 2';
        c2.Phone='2222222222';   
        c2.AccountID = a.Id;     
        c2.DeltakSRP__Person__c = p2.Id;
        insert c2;
        List<RecordType> recList = [Select Id from RecordType where Name = 'SRP Opportunity' limit 1];
        Opportunity o2 = new Opportunity();
        o2.CloseDate=System.today();
        o2.StageName='New Inquiry';        
        o2.Name='Test';
        o2.AccountID=a.Id;
        o2.deltaksrp__Student__c=contactList.get(0).Id; 
        o2.SRP_Person__c = p.Id;
        o2.RecordTypeId = recList[0].Id;
        insert o2;
        
        List<RecordType> recList1 = [Select Id from RecordType where Name = 'Deltak: Student Event' limit 1];
        Event e = new Event();
        e.Subject='Call student';
        e.Type = 'Call';
        e.DeltakSRP__Event_Status__c = 'Started';
        e.WhatId = o2.Id;
        e.DurationInMinutes = 22;
        e.Successful__c = true;
        e.DeltakSRP__Result__c = 'Succesful';                
        e.ActivityDateTime = System.now();         
        e.RecordTypeId = recList1[0].Id;
        insert e;
        
        o2.DeltakSRP__Student__c = c2.Id;
        update o2;
        
        
        Event [] verifyEvent  = [Select WhoId FROM Event WHERE Id = :e.Id];
        
       // System.assertEquals(verifyEvent[0].WhoId, c2.Id);
    //}
    }
}