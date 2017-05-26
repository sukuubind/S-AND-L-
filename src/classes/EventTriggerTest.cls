/**
Venkat Santhanam - 11/17/2010 Adding Version Header
Chris Baker 11/18/2010 Added test coverage for CR 47 change to EventTriggerBefore  
**/
@isTest
private class EventTriggerTest {
  
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
        
        
        
        Event e = new Event();
        e.Subject='Call student';
        e.Type = 'Call';
        e.Event_Status__c = 'Completed';
        e.WhatId = o.Id;
        e.DurationInMinutes = 22;
        e.Successful__c = true;
        e.Result__c = 'Succesful';
        DateTime t=System.now();        
        e.ActivityDateTime = t;  
          List<RecordType> recList = [Select Id from RecordType where DeveloperName = 'Deltak_Student_Event' limit 1];
        e.RecordTypeId = recList[0].Id;       
        insert e;
        try{
          delete e;
        }catch(Exception ex){
          
        }
        }
  }
/*
    static testMethod void myUnitTest() {
      Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
      
      User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        Test.startTest();
        DateTime timeNow=System.now();
        date d = Date.newInstance(timeNow.year(),timeNow.month(),timeNow.day());
        List <Event> eventList = new List <Event>();
         
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'FirstName1028';
        c.LastName = 'LastName1028';
        c.AccountID = a.Id;
        insert c;
        
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='Test';
        o.AccountID=a.Id;
        o.Student__c = c.Id;
        insert o;
        
        
        
        Event e = new Event();
        e.Subject='Call student';
        e.Type = 'Call';
        e.Event_Status__c = 'Completed';
        e.WhatId = o.Id;
        e.WhoID = c.Id;
        e.DurationInMinutes = 22;
        e.Successful__c = true;
        e.Result__c = 'Succesful';
        DateTime t=System.now();        
        e.ActivityDateTime = t;
        eventList.add(e);         
        //insert e;
        
        
        Event e2 = new Event();
        e2.Subject='Call student';
        e2.Type = 'Call';
        e2.Event_Status__c = 'Completed';
        e2.WhatId = o.Id;
        e2.WhoID = c.Id;
        e2.DurationInMinutes = 22;
        e2.Successful__c = false;
        e2.Result__c = 'Succesful';      
        e2.ActivityDateTime = t;         
        //insert e2;
        eventList.add(e2);
        
        
        System.debug('Chris Contact ID: '+c.Id);
        System.debug('Chris Opp ID: '+o.Id);
        System.debug('Chris Events : '+eventList);
        insert eventList;
        }
        test.stopTest();
        
    }
    */
    static testMethod void testIsBeforeEvent(){
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
      
       Event e = new Event();
        e.Subject='Call student';
        e.WhatId = o.Id;
        e.WhoId = student.Id;
        e.DurationInMinutes = 22;
        e.Successful__c = true;
        e.Result__c = 'Succesful';
        DateTime t=System.now();        
        e.ActivityDateTime = t;    
          List<RecordType> recList = [Select Id from RecordType where DeveloperName = 'Deltak_Student_Event' limit 1];
        e.RecordTypeId = recList[0].Id;     
        insert e;
        
         System.Debug('Event --> '+e);
        Event thisEvent = [Select Time_Zone__c from Event where Id = :e.Id limit 1];
       // System.assertEquals('TimeZone', thisEvent.Time_Zone__c);
        }
    }
    
     static testMethod void populateCompleteDateonInsert(){
        Profile pr = [SELECT Id FROM profile WHERE name='Deltak: Program Managers'];
        
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
            
            List <Event>  eventList = new List <Event>();
            
            Event event = new Event();
            event.Subject='Call - Inbound';
            event.Event_Status__c = 'Completed';
            event.WhatId = o.Id;
            event.DurationInMinutes = 22;
            event.Successful__c = false;
            event.Result__c = 'Successful';                  
            event.ActivityDateTime = d;
              List<RecordType> recList = [Select Id from RecordType where DeveloperName = 'Deltak_Student_Event' limit 1];
        event.RecordTypeId = recList[0].Id;
            
            Event event2 = new Event();
            event2.Subject='Call - Inbound';
            event2.Event_Status__c = 'Completed';
            event2.WhatId = o.Id;
            event2.DurationInMinutes = 22;
            event2.Successful__c = false;
            event2.Result__c = 'Successful';    
            event2.ActivityDateTime = d;                 
                 
        event2.RecordTypeId = recList[0].Id;       
            eventList.add(event);
            eventList.add(event2);
            
            insert eventList;
            DateTime dt = eventList[0].Completed_Date__c;
            
            Event [] insertedEvents = [SELECT Completed_Date__c FROM Event WHERE WhatID = :o.Id];
            for (Event e : eventList) {
                System.assertEquals(e.Completed_Date__c, dt);
            }
        }
     }
     
     
     static testMethod void populateCompleteDateonUpdate(){
        Profile pr = [SELECT Id FROM profile WHERE name='Deltak: Program Managers'];
        
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
            
            List <Event>  eventList = new List <Event>();
            
            Event event = new Event();
            event.Subject='Call - Inbound';
            event.Event_Status__c = 'In Progress';
            event.WhatId = o.Id;
            event.DurationInMinutes = 22;
            event.Successful__c = false;
            event.Result__c = 'Successful';                  
            event.ActivityDateTime = d;
              List<RecordType> recList = [Select Id from RecordType where DeveloperName = 'Deltak_Student_Event' limit 1];
        event.RecordTypeId = recList[0].Id;
            
            Event event2 = new Event();
            event2.Subject='Call - Inbound';
            event2.Event_Status__c = 'In Progress';
            event2.WhatId = o.Id;
            event2.DurationInMinutes = 22;
            event2.Successful__c = false;
            event2.Result__c = 'Successful';    
            event2.ActivityDateTime = d;       
          
        event2.RecordTypeId = recList[0].Id;          
                        
            eventList.add(event);
            eventList.add(event2);
            
            insert eventList;
            
            DateTime dt = eventList[0].Completed_Date__c;
            
            Event [] insertedEvents = [SELECT Completed_Date__c FROM Event WHERE WhatID = :o.Id];
            
            eventList[0].Event_Status__c = 'Completed';
            eventList[1].Event_Status__c = 'Completed';
            update eventList;
            
            for (Event e : eventList) {
                System.assertEquals(e.Completed_Date__c, dt);
            }
        }
     }
}