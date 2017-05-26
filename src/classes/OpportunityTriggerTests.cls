@isTest (SeeAllData=true)
private class OpportunityTriggerTests{

    static testMethod void testValidateChangingStartDate() {
        
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        String currentProfileId = ((String) (pro.Id)).substring(0, 15);
		
	/*	upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);*/
        
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.Employer_Company__c = 'Disney'; 
            insert c;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
             Academic_Program__c ap = new Academic_Program__c();
             ap.Name = 'Test Program';
             ap.School__c = a.Id;
             insert ap;
             
             //set up a program and set the opportunity to it
             Academic_Program__c ap2 = new Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.School__c = a2.Id;
             insert ap2;
             
             Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = d;
             startDate.Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
            List <Opportunity> oppList = new List<Opportunity>();
            
             List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
           
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.Program__c = ap.Id;           
                o.AccountID=a.Id;
                o.Student__c=c.Id;   
                o.Start_Date__c = sd;
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
                    
            
            insert oppList;
            
            set <Id> oppSet = new Set<Id>();
            
            //now change it back to a valid one
            for (Opportunity oppRecord : oppList) {        
                oppRecord.Start_Date__c = d;
                oppSet.add(oppRecord.Id);
            }  
            
            update oppList;
            
            Opportunity [] updatedOpps = [SELECT Academic_Start_Date__c FROM Opportunity WHERE Id IN :oppSet];
            
            for (Opportunity oppRecord : updatedOpps) {
               // System.assertEquals(startDate.Id, oppRecord.Academic_Start_Date__c);            
            }
             
            Test.stopTest();
        }
    }
    
   
    
    static testMethod void testCreateEnrollmentRecord() {
        
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
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
            c.Employer_Company__c = 'Apple';
            contactList.add(c);       
            //insert c;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';
             c2.AccountID = a2.Id;
             c2.Employer_Company__c = 'Disney';
             contactList.add(c2);      
            insert contactList;
            
            //set up a program and set the opportunity to it
            List<Academic_Program__c> acadProgList = new List<Academic_Program__c>();
            Academic_Program__c ap = new Academic_Program__c();
            ap.Name = 'Test Program';
            ap.School__c = a.Id;
            acadProgList.add(ap);           
             
             //set up a program and set the opportunity to it
             Academic_Program__c ap2 = new Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.School__c = a2.Id;
             acadProgList.add(ap2);
             insert acadProgList;
             
             Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = d;
             startDate.Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);           
            
            List <Opportunity> oppList = new List<Opportunity>();           
            List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
            for (integer i = 0; i<10; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.Program__c = ap.Id;           
                o.AccountID=a.Id;
                o.Student__c=c.Id;   
                //o.Start_Date__c = sd;
                o.Start_Date__c = d; //CB
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                oppList.add(o);
            }
            
            insert oppList;
            
            set <Id> oppSet = new Set<Id>();
            
            //now change it back to a valid one
            for (Opportunity oppRecord : oppList) {        
                oppRecord.StageName = 'Start';
                oppRecord.Date_Accepted__c = sd;
                oppRecord.Date_Submitted__c = sd;
                oppRecord.Acceptance_Status__c = 'Fully Admitted';
                oppSet.add(oppRecord.Id);
            }  
            
            update oppList;
            
            //verify that the opportunity now has a link to the newly created enrollment record
            Opportunity [] oppty = [select  Student__c, Program__c, Start_Date__c, Id, Student_Enrollment__c
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
        }
    }
    
     static testMethod void testUpdateEnrollmentRecord() {
        
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        Test.startTest();
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Academic_Program__c> acadProgList = new List<Academic_Program__c>();
         
        Account a = new Account();
        a.Name = 'Test Account';
        accountList.add(a);
        
         Account a2 = new Account();
        a2.Name = 'Test Account 2';
        accountList.add(a2);
        insert accountList;
      
        Contact c = new Contact ();
        c.FirstName='Joe';
        c.LastName='Smith';
        c.Phone='2222222222';
        c.AccountID = a.Id; 
        c.Employer_Company__c = 'Disney';
        contactList.add(c);       
        
        
        Contact c2 = new Contact ();
        c2.FirstName='Chris';
        c2.LastName='Baker';
        c2.Phone='2222222222';
        c2.Employer_Company__c = 'Apple';    
        c2.AccountID = a2.Id;
        contactList.add(c2);    
        insert contactList;
        
        //set up a program and set the opportunity to it
         Academic_Program__c ap = new Academic_Program__c();
         ap.Name = 'Test Program';
         ap.School__c = a.Id;
         acadProgList.add(ap);
         
         
         //set up a program and set the opportunity to it
         Academic_Program__c ap2 = new Academic_Program__c();
         ap2.Name = 'Test Program 2';
         ap2.School__c = a2.Id;
         acadProgList.add(ap2);
         insert acadProgList;
         
         Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
         startDate.Start_Date__c = d;
         startDate.Program__c = ap.Id;
         insert startDate;
         
         Campus_Contacts__c cc = new Campus_Contacts__c();
         
        
        Student_Enrollment__c e = new  Student_Enrollment__c (); 
        e.Student_Affiliation__c = c2.id;
        e.Start_Date__c = d;
        e.Academic_Start_Date__c = startDate.Id;
        e.Program__c = ap.Id;  
           
        insert e; 
        
        date sd = Date.newInstance(t.year(),t.month(),t.day()+1); 
        List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Program__c = ap2.Id;
        o.Name='Test';
        o.AccountID=a2.Id;
        o.Student__c=c2.Id;   
        o.Start_Date__c = sd;  
        o.Student_Enrollment__c = e.Id;  
        o.RecordTypeId = recList[0].Id; 
        insert o;
        
        //Link the enrollment record to the inserted opportunity
        e.Opportunity__c = o.Id;
        update e;
        
        //the opportunity goes to start
        o.StageName = 'Start';
        o.Date_Accepted__c = sd;
        o.Date_Submitted__c = sd;
        o.Acceptance_Status__c = 'Fully Admitted';
        update o;
         
        
        Student_Enrollment__c enrollment = [
            select Student_Affiliation__c,
                   Program__c,
                   Start_Date__c,
                   Opportunity__c 
            FROM   Student_Enrollment__c
            WHERE  Id = :e.Id
            LIMIT  1];
        
        
       Test.stopTest();
        }
    }
    
    //Set Referred_By_Person__c by setting it to the Person who is related to the Referred by Opportunity field 
    static testMethod void testSetReferredByPerson() {
        
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
           
          
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';   
            c.AccountID = a.Id;     
            insert c;
            
            Person__c p = new Person__c();
            insert p;
            System.debug('--- Person Id = '+ p.Id);
            List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
            Opportunity o = new Opportunity();
            o.CloseDate=d;
            o.StageName='New Inquiry';
            o.RecordTypeId = recList[0].Id;
            o.Name='Test';
            o.AccountID=a.Id;
            o.Student__c=c.Id;            
            insert o;    
            System.debug('--- Opp 1 Id = '+ o.Id);
            
            Opportunity o2 = new Opportunity();
            o2.CloseDate=d;
            o2.StageName='New Inquiry';        
            o2.Name='Test';
            o2.AccountID=a.Id;
            o2.Student__c=c.Id;   
            o2.Person__c = p.Id;
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
        }
    }
    
    static testMethod void testChangeStudentTask() {
         Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        String currentProfileId = ((String) (pro.Id)).substring(0, 15);
		
	/*	upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);*/
        
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        Person__c p = new Person__c();
        insert p;
        
        Person__c p2 = new Person__c();
        insert p2;
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
       
      
        Contact c = new Contact ();
        c.FirstName='Contact 1';
        c.LastName='Contact 1';
        c.Phone='2222222222';   
        c.AccountID = a.Id;  
        c.Person__c = p.Id;  
        insert c;
        
        Contact c2 = new Contact ();
        c2.FirstName='Contact 2';
        c2.LastName='Contact 2';
        c2.Phone='2222222222';   
        c2.AccountID = a.Id;     
        c2.Person__c = p2.Id;
        insert c2;
        List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
        Opportunity o2 = new Opportunity();
        o2.CloseDate=System.today();
        o2.StageName='New Inquiry';        
        o2.Name='Test';
        o2.AccountID=a.Id;
        o2.Student__c=c.Id;   
        o2.Person__c = p.Id;
        o2.RecordTypeId = recList[0].Id;
        insert o2;
        List<RecordType> recList1 = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
        Task tsk = new Task();
        tsk.Subject='Call - Inbound';
        tsk.Status = 'Complete';
        tsk.WhatId = o2.Id;        
        tsk.Result__c = 'Successful';
        tsk.Successful__c = true; 
        tsk.RecordTypeId = recList1[0].Id; 
        tsk.Asked_for_Referral__c = 'Yes';      
        insert tsk;
        
        
        o2.Student__c = c2.Id;
        update o2;
        
        Task [] verifyTask = [Select WhoId FROM Task WHERE Id = :tsk.Id];
       
        //System.assertEquals(verifyTask[0].WhoId, c2.Id);
        }
       
    }
    
    
    static testMethod void testChangeStudentEvent() {
         Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        String currentProfileId = ((String) (pro.Id)).substring(0, 15);
		
	/*	upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);*/
        
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        Person__c p = new Person__c();
        insert p;
        
        Person__c p2 = new Person__c();
        insert p2;
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
       
      
        Contact c = new Contact ();
        c.FirstName='Contact 1';
        c.LastName='Contact 1';
        c.Phone='2222222222';   
        c.AccountID = a.Id;  
        c.Person__c = p.Id;  
        insert c;
        
        Contact c2 = new Contact ();
        c2.FirstName='Contact 2';
        c2.LastName='Contact 2';
        c2.Phone='2222222222';   
        c2.AccountID = a.Id;     
        c2.Person__c = p2.Id;
        insert c2;
        List<RecordType> recList = [Select Id from RecordType where Name = 'Student Opportunity' limit 1];
        Opportunity o2 = new Opportunity();
        o2.CloseDate=System.today();
        o2.StageName='New Inquiry';        
        o2.Name='Test';
        o2.AccountID=a.Id;
        o2.Student__c=c.Id;   
        o2.Person__c = p.Id;
        o2.RecordTypeId = recList[0].Id;
        insert o2;
        
        List<RecordType> recList1 = [Select Id from RecordType where Name = 'Deltak: Student Event' limit 1];
        Event e = new Event();
        e.Subject='Call student';
        e.Type = 'Call';
        e.Event_Status__c = 'Started';
        e.WhatId = o2.Id;
        e.DurationInMinutes = 22;
        e.Successful__c = true;
        e.Result__c = 'Succesful';                
        e.ActivityDateTime = System.now();         
        e.RecordTypeId = recList1[0].Id;
        insert e;
        
        o2.Student__c = c2.Id;
        update o2;
        
        
        Event [] verifyEvent  = [Select WhoId FROM Event WHERE Id = :e.Id];
        
       // System.assertEquals(verifyEvent[0].WhoId, c2.Id);
        }
    }
}