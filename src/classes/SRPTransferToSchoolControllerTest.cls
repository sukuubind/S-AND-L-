@isTest(seealldata=true)
private class SRPTransferToSchoolControllerTest {

    static testMethod void myUnitTest() {
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
    	RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
  
        Account a = new Account();
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
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.id;
        insert c1;
        
        Opportunity o = new Opportunity();
        o.CloseDate=system.today() + 365;
        o.StageName='dormant';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.DeltakSRP__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        o.RecordTypeId = rt2.id;
        insert o;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(o); 
        SRPTransferToSchoolController testobj = new SRPTransferToSchoolController(controller);
        testobj.Cancel();
        List<SelectOption> goptions = testobj.genderOptions;
        List<SelectOption> toptions = testobj.timeframeOptions;
        
        testobj.campusid = a.Id;
	 	testobj.programid = ap.Id;
	 	testobj.home_phone = '1234567890';
        String sname = testobj.StudentName;
        String ogender = testobj.Gender;
        
        SRP_Profiles_List__c spl = new SRP_Profiles_List__c();
        spl.Name = 'current user';
        spl.ProfileId__c = userinfo.getUserId();
        insert spl;
        
        test.startTest();
        	testobj.saveOpp();
        test.stopTest();
        
   		Opportunity o2 = new Opportunity();
       /* o2 = [Select Id, stagename, home_phone__c, deltaksrp__home_phone__c from Opportunity where accountId = :a.Id
        		and stagename = 'New Inquiry'];
        system.assertnotequals(o2.Id, null); */   
        
    }
 	
 	static testMethod void testTransferToSchool() {
     
        User u = [Select Id from User where Id =: userinfo.getuserid()];
        
        system.runas(u){   
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
    	RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
  
        Account a = new Account();
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
        ap.deltakSRP__Require_Specialization__c = true;
        insert ap;
                

          //insert a contact
        Contact c1 = new Contact();        
        c1.FirstName='Joe';
        c1.LastName='Smith';
        c1.AccountId = a.id;
        insert c1;
        
        Opportunity o = new Opportunity();
        o.CloseDate=system.today() + 365;
        o.StageName='dormant';
        o.deltaksrp__Academic_Program__c = ap.Id;           
        o.AccountID=a.Id;
        o.DeltakSRP__Student__c=c1.Id;   
        o.Start_Date__c = system.today() + 10;
        o.Name='Test '; 
        o.RecordTypeId = rt2.id;
        insert o;	
        	
        	 
		ApexPages.StandardController controller = new ApexPages.StandardController(o); 
        SRPTransferToSchoolController testobj = new SRPTransferToSchoolController(controller);        testobj.Cancel();
        
        
        DeltakSRP__Academic_Specialization__c asp = new DeltakSRP__Academic_Specialization__c(DeltakSRP__Academic_Program__c = ap.Id);
        insert asp;
        
        testobj.programid = ap.id;
       
        testobj.specializationId = '-None-';
        system.assertequals(false, testobj.validateSpecialization());
        
        testobj.specializationid = asp.id;
        system.assertequals(true, testobj.validateSpecialization());

        
   
        }
     
     }
}