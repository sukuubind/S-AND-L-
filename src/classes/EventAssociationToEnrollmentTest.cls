@isTest (seeAllData=true)
private class EventAssociationToEnrollmentTest {
    static testMethod void insertTask() {
       
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
       
        Test.startTest();
        Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
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
             DateTime t=System.now();
             date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
             
             Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = sd;
             startDate.Program__c = ap.Id;
             insert startDate;
             
        //insert a contact
        Contact c1 = new Contact();        
        c1.FirstName='Joe';
        c1.LastName='Smith';
        insert c1;

        //insert a student enrollment associated with the above contact
        Student_Enrollment__c se1 = new  Student_Enrollment__c ();
        se1.Student_Affiliation__c = c1.id;
         se1.Start_Date__c = sd;
        se1.Academic_Start_Date__c = startDate.Id;
        se1.Program__c = ap.Id;        
        
        insert se1; 
        
        
        
                
        //insert a task assosiated with the above contact
        Event event1 = new Event();
        event1.WhoId = c1.Id;        
        event1.DurationInMinutes = 1;
        
        event1.ActivityDateTime = System.now();  
        List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student Event' limit 1];
        event1.RecordTypeId = recList[0].Id;
        event1.result__c='complete';
        insert event1;      
        
        Event verifyTask = [SELECT WhatId FROM Event WHERE Id = :event1.Id LIMIT 1];                
        
        //the expected result is that the task's WhatId will associated with the student enrollment atuomatically
 //FS  System.assertEquals(verifyTask.WhatId, se1.id);
        Test.stopTest();
        
            }}
        
    }
    
    static testMethod void updateTask() {
      
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
        Test.startTest();
        Account a = new Account();
            a.Name = 'Test Account';
            insert a;
           
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
         
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
             DateTime t=System.now();
             date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
             Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = sd;
             startDate.Program__c = ap.Id;
             insert startDate;

        
        //insert 2 contacts
        Contact c1 = new Contact();        
        c1.FirstName='Contact';
        c1.LastName='One';
        insert c1;
        
        Contact c2 = new Contact();        
        c2.FirstName='Contact';
        c2.LastName='Two';
        insert c2;
        
        //insert 2 student enrollments each one associated to each contact above
        Student_Enrollment__c se1 = new  Student_Enrollment__c ();
        se1.Student_Affiliation__c = c1.id;
        se1.Start_Date__c = sd;
        se1.Academic_Start_Date__c = startDate.Id;
        se1.Program__c = ap.Id;
        insert se1; 

        Student_Enrollment__c se2 = new  Student_Enrollment__c ();
        se2.Student_Affiliation__c = c2.id;
        se2.Start_Date__c = sd;
        se2.Academic_Start_Date__c = startDate.Id;
        se2.Program__c = ap.Id;
        insert se2;                 
       
        //insert a task associated with contact one
        Event event1 = new Event();
        event1.WhoId = c1.Id;   
        event1.DurationInMinutes = 1;     
        event1.ActivityDateTime = System.now();
        List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student Event' limit 1];
        event1.RecordTypeId = recList[0].Id;
        event1.Result__c = 'complete';
        insert event1;
        
        Event verifyTask1 = [SELECT WhatId FROM Event WHERE Id = :event1.Id LIMIT 1];
        
        // the task whatId be associated with the 1st student enrollment 
 //FS       System.assertEquals(verifyTask1.WhatId, se1.id);
        
        //now associate the same task to contact two
        event1.WhoId = c2.Id;
        update event1;
     
        Event verifyTask2 = [SELECT WhatId FROM Event WHERE Id = :event1.Id LIMIT 1];
        
        //now the task whatId be associated with the 2nd student enrollment                 
//FS        System.assertEquals(verifyTask2.WhatId, se2.id);
        Test.stopTest();
            }}
    }
    
    //this test case is to test a production issue when a PM would insert an event on an opportunity
     static testMethod void insertOpportunityEvent() {
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
                Test.startTest();
                DateTime t=System.now();
                date d = Date.newInstance(t.year(),t.month(),t.day());
                
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
                
                //set up a program and set the opportunity to it
                Academic_Program__c ap2 = new Academic_Program__c();
                ap2.Name = 'Test Program 2';
                ap2.School__c = a2.Id;
                insert ap2;
                
                 
                Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
                startDate.Start_Date__c = d;
                startDate.Program__c = ap2.Id;
                insert startDate;   
            
                //insert a contact
                Contact c1 = new Contact();        
                c1.FirstName='Joe';
                c1.LastName='Smith';
                c1.AccountId = a2.id;
                insert c1;
                
                
                
                //insert a student enrollment associated with the above contact
                Student_Enrollment__c se1 = new  Student_Enrollment__c ();
                se1.Student_Affiliation__c = c1.id;
                se1.Start_Date__c = d;
                se1.Academic_Start_Date__c = startDate.Id;
                se1.Program__c = ap2.Id;     
                
                insert se1; 
                        
                
        
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.Program__c = ap2.Id;           
                o.AccountID=a2.Id;
                o.Student__c=c1.Id;   
                o.Start_Date__c = d;
                o.Name='Test '; 
                insert o;
        
                Event event1 = new Event();
                event1.WhoId = c1.Id;
                event1.WhatId = o.Id;   
                event1.DurationInMinutes = 1;     
                event1.ActivityDateTime = System.now();
                List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student Event' limit 1];
        event1.RecordTypeId = recList[0].Id;
                insert event1;  
                
                Test.stopTest();
            }
        
        }
     }
}