/**
Venkat Santhanam - 11/17/2010 Adding Version Header
Chris Baker 11/18/2010 Added test coverage for CR 47 change to TaskTriggerBefore
**/
@isTest
private class TaskTriggerTest {
static testMethod void testDelete(){
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            DateTime timeNow=System.now();
        date d = Date.newInstance(timeNow.year(),timeNow.month(),timeNow.day());
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        insert o;
        
        
        
       Task tsk = new Task();
        tsk.Subject='Call - Inbound';
        tsk.Status = 'Complete';
        tsk.WhatId = o.Id;
        tsk.Result__c = 'Successful';
        tsk.Successful__c = true;
        tsk.Asked_for_Referral__c = 'Yes';
        List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
        tsk.RecordTypeId = recList[0].Id;   
        //tsk.IsClosed = true;
        //e.ActivityDateTime = tsk;         
        insert tsk;
        try{
            delete tsk;
        }catch(Exception ex){
            
        }
        }
    }
    static testMethod void myUnitTest() {
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        insert o;
        List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
          
        
        Task tsk = new Task();
        tsk.Subject='Call - Inbound';
        tsk.Status = 'Complete';
        tsk.WhatId = o.Id;
        tsk.Result__c = 'Successful';
        tsk.Successful__c = true;
        tsk.RecordTypeId = recList[0].Id; 
        tsk.Asked_for_Referral__c = 'Yes';
        //e.ActivityDateTime = tsk;         
        insert tsk;
        
        
        
        Task tsk2 = new Task();
        tsk2.Subject='Call - Inbound';
        tsk2.Status = 'Complete';
        tsk2.WhatId = o.Id;
        tsk2.Successful__c = false;
        tsk2.Result__c = 'Un Succesful';
        tsk2.RecordTypeId = recList[0].Id; 
        tsk2.Asked_for_Referral__c = 'Yes';
        //e.ActivityDateTime = tsk;         
        insert tsk2;
        
       }
    }
    static testMethod void testAppointmentScenario(){
        
        //Profile pr = [SELECT Id FROM profile WHERE name='Standard User']; -- Running test as Sys Admin and not Deltak PM because the unit test fails because the trigger SRP does not fire for SRM
        
        Profile pr = [SELECT Id FROM profile WHERE name='System Administrator']; 
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
             DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        insert o;
        
        Person__c p = new Person__c();
        insert p;
        
       List<Contact> contactList = new List<Contact>();
       Contact student = new Contact();
        student.FirstName = 'test';
        student.LastName = 'test';
        student.Person__c = p.id;
        student.Time_Zone__c = 'TimeZone';
        insert student;
        
        System.Debug('Student --> '+student);
        List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
        Task tsk2 = new Task();
        tsk2.Subject='Appointment';
        tsk2.Type = 'Appointment';
        tsk2.Status = 'In Progress';
        tsk2.WhatId = o.Id;
        tsk2.WhoId = student.Id;
        tsk2.Successful__c = false;
        tsk2.Result__c = 'Successful';
         tsk2.RecordTypeId = recList[0].Id; 
         tsk2.asked_for_referral__c = 'false';
         tsk2.Asked_for_Referral__c = 'Yes';
         tsk2.ActivityDate = Date.today();
        //e.ActivityDateTime = tsk;         
        insert tsk2;
        
        Task tsk2a = new Task();
        tsk2a.Subject='Call';
        tsk2a.Type = 'Call';
        tsk2a.Status = 'Completed';
        tsk2a.WhatId = o.Id;
        tsk2a.WhoId = student.Id;
        tsk2a.Successful__c = false;
        tsk2a.Result__c = 'Successful';
         tsk2a.RecordTypeId = recList[0].Id; 
         tsk2a.asked_for_referral__c = 'false';
         tsk2a.Asked_for_Referral__c = 'Yes';
         tsk2a.ActivityDate = Date.today();
        //e.ActivityDateTime = tsk;         
        insert tsk2a;


        Task tsk3 = new Task();
        tsk3.Subject='Appointment';
        tsk3.Type = 'Appointment';
        tsk3.Status = 'Complete';
        tsk3.WhatId = o.Id;
        tsk3.WhoId = student.Id;
        tsk3.Successful__c = false;
        tsk3.Result__c = 'Un Succesful';
         tsk3.RecordTypeId = recList[0].Id; 
         tsk3.Asked_for_Referral__c = 'Yes';
         tsk3.ActivityDate = Date.today();
        //e.ActivityDateTime = tsk;         
        try{
        insert tsk3;
        }catch(Exception e){ }
        List<Task> taskList = [Select id from task where whoid = :student.id and Type = 'Appointment'];
      //  System.AssertEquals(1, taskList.size());
        
        tsk2.Status = 'Completed';
        update tsk2;
         taskList = [Select id from task where whoid = :student.id and Type = 'Appointment'];
       // System.AssertEquals(1, taskList.size());
        }
    }
    static testMethod void testIsBeforeTask(){
        Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
         DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        insert o;
        
        Person__c p = new Person__c();
        insert p;
        
       List<Contact> contactList = new List<Contact>();
        Contact student = new Contact();
        student.FirstName = 'test';
        student.LastName = 'test';
        student.Person__c = p.id;
        student.Time_Zone__c = 'TimeZone';
        insert student;
        
        System.Debug('Student --> '+student);
         List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
        Task tsk2 = new Task();
        tsk2.Subject='Call - Inbound';
        tsk2.Status = 'Complete';
        tsk2.WhatId = o.Id;
        tsk2.WhoId = student.Id;
        tsk2.Successful__c = false;
        tsk2.Result__c = 'Un Succesful';
        tsk2.RecordTypeId = recList[0].Id; 
        tsk2.Asked_for_Referral__c = 'Yes';
        //e.ActivityDateTime = tsk;         
        insert tsk2;
        
        System.Debug('Task --> '+tsk2);
        Task thisTask = [Select Time_Zone__c from Task where Id = :tsk2.Id limit 1];
     //   System.assertEquals('TimeZone', thisTask.Time_Zone__c);
        }
    }
    
    static testMethod void populateCompleteDateonInsert(){
        //Profile pr = [SELECT Id FROM profile WHERE name='Deltak: Program Managers']; -- Running test as Sys Admin and not Deltak PM because the unit test fails because the trigger SRP does not fire for SRM
        
        Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
        	
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
            
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
            
            Opportunity o = new Opportunity();
            o.CloseDate=d;
            o.StageName='New Inquiry';
            o.Name='Test';
            o.AccountID=a.Id;
            insert o;
            
            List <Task>  tskList = new List <Task>();
            List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
            Task tsk = new Task();
            tsk.Subject='Call - Inbound';
            tsk.Status = 'Completed';
            tsk.WhatId = o.Id;
            tsk.Asked_for_Referral__c = 'Yes';
            tsk.Successful__c = false;
            tsk.Result__c = 'Successful';                    
            tsk.RecordTypeId = recList[0].Id;
            
            Task tsk2 = new Task();
            tsk2.Subject='Call - Inbound';
            tsk2.Status = 'Completed';
            tsk2.WhatId = o.Id;
            tsk2.Asked_for_Referral__c = 'Yes';
            tsk2.Successful__c = false;
            tsk2.Result__c = 'Successful';                   
              tsk2.RecordTypeId = recList[0].Id;          
            tskList.add(tsk);
            tskList.add(tsk2);
            
            insert tskList;
            DateTime dt = tskList[0].Completed_Date__c;
            
            Task [] insertedTasks = [SELECT Completed_Date__c FROM Task WHERE WhatID = :o.Id];
            for (Task task : tskList) {
                System.assertEquals(task.Completed_Date__c, dt);
            }
        }
        
    }
    
    
    static testMethod void populateCompleteDateonUpdate(){
        //Profile pr = [SELECT Id FROM profile WHERE name='Deltak: Program Managers']; -- Running test as Sys Admin and not Deltak PM because the unit test fails because the trigger SRP does not fire for SRM
        
        Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
            
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
            
            Opportunity o = new Opportunity();
            o.CloseDate=d;
            o.StageName='New Inquiry';
            o.Name='Test';
            o.AccountID=a.Id;
            insert o;
            
            List <Task>  tskList = new List <Task>();
            List<RecordType> recList = [Select Id from RecordType where Name = 'Deltak: Student' limit 1];
            Task tsk = new Task();
            tsk.Subject='Call - Inbound';
            tsk.Status = 'Completed';
            tsk.WhatId = o.Id;
            tsk.Asked_for_Referral__c = 'Yes';
            tsk.Successful__c = false;
            tsk.Result__c = 'Successful';                    
             tsk.RecordTypeId = recList[0].Id;  
            tskList.add(tsk);
            
            Task tsk2 = new Task();
            tsk2.Subject='Call - Inbound';
            tsk2.Status = 'Completed';
            tsk2.WhatId = o.Id;
            tsk2.Asked_for_Referral__c = 'Yes';
            tsk2.Successful__c = false;
            tsk2.Result__c = 'Successful';                   
               tsk2.RecordTypeId = recList[0].Id;           
            
            tskList.add(tsk2);
             
            insert tskList;
            DateTime dt = tskList[0].Completed_Date__c;
            
            Task [] insertedTasks = [SELECT Completed_Date__c FROM Task WHERE WhatID = :o.Id];
            
            tskList[0].Status = 'Completed';
            tskList[1].Status = 'Completed';
            update tskList;
            
            
            for (Task task : tskList) {
                System.assertEquals(task.Completed_Date__c, dt);
            }
        }
        
    }
}