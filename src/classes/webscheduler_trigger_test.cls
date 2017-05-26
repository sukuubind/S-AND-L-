@isTest
public class webscheduler_trigger_test{
 
    static testMethod void testbulkremove(){
    Profile pr = [SELECT Id FROM profile WHERE name='System Administrator'];
    
   
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    
    
    insert upm;
    
    System.runAs(upm){
        ID acctid = findAccountRecordType();
        
        //insert test objects
        Account a = new Account();
        a.Name = 'Test Account';
        a.recordTypeID = acctid;
        a.Admissions_Phone__c = '888-888-8888';
        insert a; 

    Contact newcontact = new Contact();
    Contact newcontact2 = new Contact();
    Contact newcontact3 = new Contact(); 
           
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.Employer_Company__c = 'Test Company';
    newcontact.accountid = a.id;
      
    System.assertnotequals(newcontact.recordtypeid, null);
   
    newcontact2.recordtypeid = newcontact.recordtypeid;
    newcontact2.firstname = 'John';
    newcontact2.lastname = 'Doe';
    newcontact2.Employer_Company__c = 'Test Company';
    newcontact2.accountid = a.id;
    
    newcontact3.recordtypeid = newcontact.recordtypeid;
    newcontact3.firstname = 'Jane';
    newcontact3.lastname = 'Learning';
    newcontact3.Employer_Company__c = 'Test Company';
    newcontact3.accountid = a.id;
    
    List<Contact> newContactlist = new List<Contact>();
    newContactlist.add(newcontact);
    newContactlist.add(newcontact2);
    newContactlist.add(newcontact3);    
    insert newContactList;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
   insert s;
    
    //insert opportunities with scheduled appointments
    List<Opportunity> theopplist = new List<Opportunity>();
    List<ID> theoppids = new List<ID>();
    
    Date t = date.today().adddays(-2);
    
    Opportunity theopp = new Opportunity();
    Opportunity theopp2 = new Opportunity();
    Opportunity theopp3 = new Opportunity();
    
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.Email_from_Student__c = 'teststd@test.com';
    theopp.CloseDate = t;
    theopp.cwschedappt__c = datetime.now().adddays(2);
    theopp.webschedulerstatus__c = 'Scheduled';
 
    theopp2.recordtypeid = theopp.recordtypeid;
    theopp2.stagename = 'Start';
    theopp2.student__c = newcontact2.id;
    theopp2.Program__c = acadprog.Id; 
    theopp2.AccountID = a.Id;
    theopp2.OwnerID = upm.id;
    theopp2.name = 'John Doe';
    theopp2.Email_from_Student__c = 'testjohndoe@test.com';
    theopp2.CloseDate = t;
    theopp2.cwschedappt__c = datetime.now().adddays(2);
    theopp2.webschedulerstatus__c = 'Rescheduled';
 
    theopp3.recordtypeid = theopp.recordtypeid;
    theopp3.stagename = 'Start';
    theopp3.student__c = newcontact3.id;
    theopp3.Program__c = acadprog.Id; 
    theopp3.AccountID = a.Id;
    theopp3.OwnerID = upm.id;
    theopp3.name = 'Jane Learning';
    theopp3.Email_from_Student__c = 'testjanelearning@test.com';
    theopp3.CloseDate = t;   
    theopp3.cwschedappt__c = datetime.now().adddays(3);
    theopp3.webschedulerstatus__c= 'Scheduled';    
    
    
    theopplist.add(theopp);
    theopplist.add(theopp2);
    theopplist.add(theopp3);    
    
    insert theopplist;
    System.debug('@asha - Webscheduler Trigger Test - Inserting new Opportunities - '+ theopplist);
    
    theoppids.add(theopp.id);
    theoppids.add(theopp2.id);
    theoppids.add(theopp3.id);
    
    //insert 3 events to match the scheduled appts on the Opportunity
    
    List<Event> theeventlist = new List<Event>();
    
    Event webevent = new Event();

   webevent.subject = 'Web Scheduled Appointment';
   webevent.WhatID = theopp.id;
   webevent.ActivityDate = theopp.cwschedappt__c.date(); 
   webevent.DurationInMinutes = 30; 
   webevent.EndDateTime = theopp.cwschedappt__c.addminutes(30);
   webevent.StartDateTime = theopp.cwschedappt__c;
   webevent.ShowAs = 'Busy';
   webevent.ownerid = upm.id;
   webevent.Event_Status__c = 'Not Started';
   webevent.Type = 'Web Appointment';
   webevent.RecordTypeId = findEventRecordType() ;
   System.assertnotequals(webevent.RecordTypeId, null);
   
   Event webevent2 = new Event();

   webevent2.subject = 'Web Scheduled Appointment';
   webevent2.WhatID = theopp2.id;
   webevent2.ActivityDate = theopp2.cwschedappt__c.date(); 
   webevent2.DurationInMinutes = 30; 
   webevent2.EndDateTime = theopp2.cwschedappt__c.addminutes(30);
   webevent2.StartDateTime = theopp2.cwschedappt__c;
   webevent2.ShowAs = 'Busy';
   webevent2.ownerid = upm.id;
   webevent2.Event_Status__c = 'Not Started';
   webevent2.Type = 'Web Appointment';
   webevent2.RecordTypeId = webevent.RecordTypeId ;

   Event webevent3 = new Event();

   webevent3.subject = 'Web Scheduled Appointment';
   webevent3.WhatID = theopp3.id;
   webevent3.ActivityDate = theopp3.cwschedappt__c.date(); 
   webevent3.DurationInMinutes = 30; 
   webevent3.EndDateTime = theopp3.cwschedappt__c.addminutes(30);
   webevent3.StartDateTime = theopp3.cwschedappt__c;
   webevent3.ShowAs = 'Busy';
   webevent3.ownerid = upm.id;
   webevent3.Event_Status__c = 'Not Started';
   webevent3.Type = 'Web Appointment';
   webevent3.RecordTypeId = webevent.RecordTypeId ;     
   
   theeventlist.add(webevent);
   theeventlist.add(webevent2);    
   theeventlist.add(webevent3);   
     
   insert theeventlist;  
   System.debug('@asha - Webscheduler Trigger Test - Inserting Web Scheduler Events - '+ theeventlist);
      
    Test.startTest(); 
        //verify 3 events before update
        List<Event> pulledEvents = [Select id FROM Event WHERE WhatID IN :theoppids];
        System.assertequals(pulledEvents.size(),3);
        
        //update opportunities
        List<Opportunity> pulledOpps =[Select id,cwschedappt__c, webschedulerstatus__c FROM Opportunity where id IN: theoppids];
        System.assertequals(pulledOpps.size(),3);
        System.debug('@asha - Webscheduler Trigger Test - Number of Opportunities being updated '+ pulledOpps.size());
        for(Opportunity opp:pulledOpps){
             opp.webschedulerstatus__c = 'New';
            System.debug('@asha - Webscheduler Trigger Test - Updating Opportunity '+ opp);
        }
        update pulledOpps;
       
        // System.debug('@asha: Running WebSchedulerUtils bulk cancel');
        // WebSchedulerUtils.bulkCancelAppointment(pulledOpps);
       
        
        //verify no events after update
        List<Event> pulledEvents2 = [Select id FROM Event WHERE WhatID IN :theoppids];
        System.assertequals(pulledEvents2.size(),0);
        
    
    Test.stopTest();
    }//end runAs
    }//end testmethod
    
    
    private static ID findAccountRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Account;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Campus/Partner') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }    
      private static ID findContactRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Contact;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Deltak Student') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
       
     private static ID findEventRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Event;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Deltak: Student Event*') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
    
     private static ID findOpportunityRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Opportunity;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Student Opportunity') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
    
}