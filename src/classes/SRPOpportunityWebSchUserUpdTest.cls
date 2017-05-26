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
@isTest(seeAllData=true)
private class SRPOpportunityWebSchUserUpdTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
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
           
            for (integer i = 0; i<1; i++) {
                Opportunity o = new Opportunity();
                o.CloseDate=d;
                o.StageName='New Inquiry';
                o.deltaksrp__academic_Program__c = ap.Id;           
                o.AccountID=a.Id;
                o.deltaksrp__Student__c=contactList.get(i).Id;   
                o.deltaksrp__Start_Date__c = sd;
                o.Name='Test ' + i; 
                o.RecordTypeId = recList[0].Id;
                o.OwnerId = '00532000003htmI';
                o.DeltakSRP__webschedulerstatus__c = null;
                o.DeltakSRP__cwschedappt__c = null;
                o.DeltakSRP__WebScheduler_Email__c=null;
                oppList.add(o);
            }
                    
            
            insert oppList;
            
             User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
             Id lUserId = loggedInUser.id;
            
            set <Id> oppSet = new Set<Id>();
            
            //now change it back to a valid one
            for (Opportunity oppRecord : oppList) {        
                oppRecord.OwnerId = lUserId;
                oppRecord.DeltakSRP__webschedulerstatus__c = 'New';
                oppSet.add(oppRecord.Id);
            }  
            
            update oppList;
            
            Opportunity [] updatedOpps = [SELECT id, DeltakSRP__Webscheduler_User__c, OwnerId FROM Opportunity WHERE Id IN :oppSet];
            
            for (Opportunity oppRecord : updatedOpps) {
               System.assertEquals(oppRecord.OwnerId, oppRecord.DeltakSRP__Webscheduler_User__c);            
            }
             
          Test.stopTest();
    }
}