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
private class SRPOnlineApplicationTriggerUtilsTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
  		RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
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
        
        DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
        ap2.Name = 'abcd2';
        ap2.DeltakSRP__School__c = a.id;
        ap2.DeltakSRP__Degree_Type__c = 'Certificate2';
        ap2.DeltakSRP__Abbrev__c = 'CID2';
        ap2.DeltakSRP__Program_Title__c = 'Certificate in CS2';
        insert ap2;
        
        Contact c = new Contact();       
        c.FirstName='Pratik';
        c.LastName='SRPStudentOnlineApplicationEmailTrigger';
        c.email = 'pratik.tanna@deltak-innovation.com';
        c.DoNotCall = true;
        c.DeltakSRPSMS__Ok_To_Text__c = true;
        c.HasOptedOutOfEmail = true;
        c.Recorded_Call__c = 'Yes';
        insert c;
        
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
        
        
        DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
        asd.DeltakSRP__Start_Date__c = system.today();
        asd.DeltakSRP__End_Date__c = system.today() + 10;
        asd.DeltakSRP__Academic_Program__c = ap.Id;
        insert asd;
        
        DeltakSRP__Academic_Start_Date__c asd2 = new DeltakSRP__Academic_Start_Date__c();
        asd2.DeltakSRP__Start_Date__c = system.today();
        asd2.DeltakSRP__End_Date__c = system.today() + 10;
        asd2.DeltakSRP__Academic_Program__c = ap2.Id;
        insert asd2;
        
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
        o.DeltakSRP__Academic_Start_Date__c = asd.Id;
        insert o;
        
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
        insert soa;
        
        DeltakSRP__Program_Admission_Document__c pad = new DeltakSRP__Program_Admission_Document__c();
        pad.DeltakSRP__Opportunity__c = o.Id;
        insert pad;
        
        DeltakSRP__Program_Admission_Template__c pat = new DeltakSRP__Program_Admission_Template__c();
        pat.Name = 'test';
        pat.DeltakSRP__Type__c = 'Application';
        pat.DeltakSRP__Matching_ID__c = 'anidequaltothepatsrecordextid';
        pat.DeltakSRP__Order__c = 1;
        pat.DeltakSRP__Program__c = ap.Id;
        insert pat;
        
        DeltakSRP__Program_Admission_Template_Selection__c pats = new DeltakSRP__Program_Admission_Template_Selection__c();
        pats.DeltakSRP__Ext_Program_Admission_Template__c = 'anidequaltothepatsrecordextid';
        pats.DeltakSRP__Academic_Program__c = ap.Id;
        insert pats;
        
        SRPOnlineApplicationTriggerUtils.copyAdmissionsDocumentsToOpportunity(o);
        
        
    }
}