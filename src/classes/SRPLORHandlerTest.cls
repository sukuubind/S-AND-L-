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
@isTest(seealldata=true)
private class SRPLORHandlerTest {

    static testMethod void testLORUpdatedPADScenario() {
       /*RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.DeveloperName = 'Letter_of_Recommendation' and SObjectType = 'DeltakSRP__Program_Admission_Document__c' limit 1];
        List<User> userList = [Select id from User where Name = 'SRP Lead Engine' limit 1];
        
        Account a = new Account();
        a.ownerId = userList[0].Id;
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        insert ap;
        
         //insert a contact
        Contact c1 = new Contact();  
        c1.ownerId = userList[0].Id;      
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.id;
        c1.DoNotCall = true;
        c1.DeltakSRPSMS__Ok_To_Text__c = true;
        c1.HasOptedOutOfEmail = true;
        c1.Recorded_Call__c = 'Yes';
        insert c1;
        
        Opportunity o = new Opportunity();
        o.ownerId = userList[0].Id;
        o.RecordTypeId = rt2.Id;
        o.CloseDate=system.today() + 365;
        o.StageName='New Inquiry';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.deltaksrp__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        insert o;
        
        DeltakSRP__Program_Admission_Document__c pad = new DeltakSRP__Program_Admission_Document__c();
        pad.RecordTypeid = rt3.Id;
        pad.DeltakSRP__Opportunity__c = o.id;
        insert pad;
        
        DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
        asd.DeltakSRP__Start_Date__c = system.today();
        asd.DeltakSRP__End_Date__c = system.today() + 10;
        asd.DeltakSRP__Academic_Program__c = ap.Id;
        insert asd;
        
        DeltakSRP__Student_Online_Application__c soa = new DeltakSRP__Student_Online_Application__c();
        soa.DeltakSRP__Affiliation__c = c1.Id;
        soa.DeltakSRP__Affiliation_Opportunity__c = o.Id;
        soa.DeltakSRP__Academic_Program__c = ap.Id;
        soa.DeltakSRP__Academic_Start_Date__c = asd.Id;
        soa.Maiden__c = 'test';
        soa.DeltakSRP__Address_Line_1__c = 'test' ;
        soa.DeltakSRP__Address_Line_2__c = 'test';
        soa.DeltakSRP__Address_Line_3__c = 'test';
        soa.DeltakSRP__Application_Status__c = 'In Progress';
        soa.DeltakSRP__Payment_Type__c = 'No Payment2';
        soa.DeltakSRP__Submitted__c= false;
        insert soa;*/
        DeltakSRP__Student_Online_Application__c soa = [SELECT ID,DeltakSRP__Affiliation__c  FROM DeltakSRP__Student_Online_Application__c 
        													WHERE DeltakSRP__Affiliation__c !=null AND DeltakSRP__Affiliation_Opportunity__c != null LIMIT 1];
        
        DeltakSRP__Student_Letter_of_Reference__c lor = new DeltakSRP__Student_Letter_of_Reference__c();
        lor.DeltakSRP__Affiliation__c = soa.DeltakSRP__Affiliation__c;
        lor.name = 'Test Lor Name';
        lor.DeltakSRP__Status__c = 'New';
        insert lor;
        
        DeltakSRP__Student_Letter_of_Reference_Selection__c lors = new DeltakSRP__Student_Letter_of_Reference_Selection__c();
        lors.DeltakSRP__Student_Online_Application__c = soa.id;
        lors.DeltakSRP__Student_Letter_of_Reference__c = lor.id;
        insert lors;
        
        lor.DeltakSRP__Status__c = 'Complete';
        update lor;
        
        delete lors;
        
        
        
    }
}