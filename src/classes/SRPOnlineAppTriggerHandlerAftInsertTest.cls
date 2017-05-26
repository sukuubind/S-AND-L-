@isTest(seealldata=true)
public with sharing class SRPOnlineAppTriggerHandlerAftInsertTest {

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
        //ap.SOA_Record_Type_ID__c = null;
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
        
        Opportunity o = new Opportunity();
        o.ownerId = userList[0].Id;
		o.RecordTypeId = rt2.Id;
		o.CloseDate=system.today() + 365;
        o.StageName='New Inquiry';
        o.deltaksrp__Academic_Program__c = ap.Id;
        o.deltaksrp__start_date__c = system.today() + 10;
        o.AccountID=a.Id;
        o.deltaksrp__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        insert o;
        
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
        
        DeltakSRP__Student_Online_Application__c soa = new DeltakSRP__Student_Online_Application__c();
        soa.DeltakSRP__Affiliation__c = c1.Id;
        soa.DeltakSRP__Affiliation_Opportunity__c = o.Id;
        soa.DeltakSRP__Academic_Program__c = ap.Id;
        soa.DeltakSRP__Academic_Start_Date__c = asd.Id;
        soa.Maiden__c = 'test';
		soa.DeltakSRP__Address_Line_1__c = 'test' ;
		soa.DeltakSRP__Address_Line_2__c = 'test';
		soa.DeltakSRP__Address_Line_3__c = 'test';
		soa.DeltakSRP__Application_Status__c = 'InProgress';
		soa.DeltakSRP__Payment_Type__c = 'No Payment2';
		soa.DeltakSRP__Submitted__c= false;
        insert soa;
        
        SRPEmployerWrapper sew = SRPOnlineApplicationtriggerHandler.getemployerDetails(soa.Id);
        
        System.assertEquals(null,sew);
        
        DeltakSRP__Student_Online_Application_Tuple__c soat = new DeltakSRP__Student_Online_Application_Tuple__c();
        soat.Name = 'test';
        soat.DeltakSRP__Student_Online_Application__c = soa.Id;
        soat.DeltakSRP__Company_Name__c = 'test company';
        soat.Position__c = 'test position';
        insert soat;
        
        sew = SRPOnlineApplicationtriggerHandler.getemployerDetails(soa.Id);
        
        List<Contact> cList = [Select Id, Account.Abbreviation__c, account.name, account.ownerid, account.owner.email, firstname, lastname, DeltakSRP__Maiden_Name__c, (Select Id, stagename, Admissions_manager__c, admissions_manager__r.email, owner.email, owner.isactive, DeltakSRP__Student__c, DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, account.name, account.owner.email from DeltakSRP__Opportunities__r) from Contact where id =:c1.Id];
        System.debug('cList[0].DeltakSRP__Opportunities__r >---> ' + cList[0].DeltakSRP__Opportunities__r);
        List<DeltakSRP__Student_Online_Application__c> soaList = new List<DeltakSRP__Student_Online_Application__c>();
        //soa.DeltakSRP__Academic_Start_Date__c = null;
        soaList.add(soa);
        
        
        Test.startTest();
        SRPOnlineAppTriggerHandlerAfterInsert.handleAfterInsert(cList, soaList);
        test.stopTest();
        
        
	}
}