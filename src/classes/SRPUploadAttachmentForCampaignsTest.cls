@isTest(seealldata=true)
private class SRPUploadAttachmentForCampaignsTest {

    static testMethod void myUnitTest() {
         Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
	        Account a = new Account();
	        a.Name = 'Test Account';
	        a.Display_on_New_Inquiry_Page__c  = true;
	        a.Active__c = true;
	        a.Goldmine_Key5__c = 'Test Account';
	        insert a; 
	        
	        Account a2 = new Account();
	        a2.Name = 'Test Account2';
	        a2.Display_on_New_Inquiry_Page__c  = true;
	        a2.Active__c = true;
	        a2.Goldmine_Key5__c = 'Test Account';
	        insert a2; 
	        
	        Campaign camp = new Campaign();
	        camp.Name = 'Campaign Name';
	        camp.Campaign_Code__c = 'SRP Corporate Conference - Disney';
	        camp.Lowest_Level_in_Hierarchy__c = true;
	        camp.StartDate = Date.Today()-1;
	        camp.EndDate = Date.Today()+1;
	        camp.IsActive = true;
	        insert camp;
	        
	        Campaign camp3 = new Campaign();
	        camp3.Name = 'Conference';
	        camp3.Campaign_Code__c = 'Conference';
	        camp3.Lowest_Level_in_Hierarchy__c = true;
	        camp3.StartDate = Date.Today()-1;
	        camp3.EndDate = Date.Today()+1;
	        camp3.IsActive = true;
	        insert camp3;
	        
	        Campaign camp2 = new Campaign();
	        camp2.Name = 'Campaign Name';
	        camp2.Campaign_Code__c = 'SRP Corporate Conference - Disney2';
	        camp2.Lowest_Level_in_Hierarchy__c = true;
	        camp2.StartDate = Date.Today()-1;
	        camp2.EndDate = Date.Today()+1;
	        camp2.IsActive = true;
	        camp2.ParentId = camp3.id;
	        insert camp2;
	       
	        Campaign camp4 = new Campaign();
	        camp4.Name = 'Bucket';
	        camp4.Campaign_Code__c = 'SRP Bucket';
	        camp4.Lowest_Level_in_Hierarchy__c = true;
	        camp4.StartDate = Date.Today()-1;
	        camp4.EndDate = Date.Today()+1;
	        camp4.IsActive = true;
	        camp4.ParentId = camp3.id;
	        insert camp4;
	        
	        Campain_Leads_Upload__c leads = new Campain_Leads_Upload__c();
	        leads.Name = 'test';
	        insert leads;
	        
	        RecordType rt = [Select Id from Recordtype where Name = 'SRP Student'];
	        RecordType rt2 = [Select Id from Recordtype where Name = 'SRP Opportunity'];
	        
	        Contact c = new Contact();
	        c.recordTypeId = rt.Id;
	        c.FirstName = 'MassUpload';
        	c.LastName = 'Test2';
        	c.Email = 'testemail@salesforce.com';
        	c.Phone = '1234567890';
        	c.AccountId = a.id;
        	c.title = 'President';
        	//c.company = 'Salesforce';
	        c.mailingStreet = 'Somewhere in CA';
	        c.mailingcity='San Francisco';
	        c.mailingstate = 'CA';
	        c.mailingcountry = 'United States';
	        c.mailingpostalcode = '32801';
	        c.homephone = '(222)222-2222';
	        c.DeltakSRP__Work_Phone__c = '(444)444-4444';
	        c.email = 'Massuploadtest2@gmail.com';
	        c.DeltakSRP__Preferred_Phone__c = 'Home';
	        insert c;
	        
	        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
	        ap.Name = 'abcd';
	        ap.DeltakSRP__School__c = a.id;
	        ap.DeltakSRP__Degree_Type__c = 'Certificate';
	        ap.DeltakSRP__Abbrev__c = 'CID';
	        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
	        insert ap;
	        
	        DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
	        ap2.Name = 'abcd';
	        ap2.DeltakSRP__School__c = a.id;
	        ap2.DeltakSRP__Degree_Type__c = 'Certificate';
	        ap2.DeltakSRP__Abbrev__c = 'CIE';
	        ap2.DeltakSRP__Program_Title__c = 'Certificate in EE';
	        insert ap2;
	        
	        RFI_to_Academic_Programs_Code__c rapc = new RFI_to_Academic_Programs_Code__c();
	        rapc.Program_Code__c = 'CJ Administration4';
	        rapc.Academic_Program__c = ap.Id;
	        insert rapc;
	        
	        RFI_to_Academic_Programs_Code__c rapc2 = new RFI_to_Academic_Programs_Code__c();
	        rapc2.Program_Code__c = 'CJ Administration5';
	        rapc2.Academic_Program__c = ap2.Id;
	        insert rapc2;
	        
	        Opportunity o = new Opportunity();
	        o.AccountId = a.id;
	        o.StageName = 'New Inquiry';
	        o.closedate = system.today() + 100;
	        o.DeltakSRP__Student__c = c.Id;
	        o.DeltakSRP__Academic_Program__c = ap2.Id;
	        o.name = 'test name';
	        o.recordtypeid = rt2.id;
	        insert o;
	        
	        Attachment at = new Attachment();
	        at.Name = 'Attachment Name';
	        at.parentid = leads.id;
	        String body = 'Is SRP Record,Inquiry Record Type,Inquiry Rating,RFI Campaign Code,Source,Lead Source,Academic Institution (ID),First Name,Last Name,Title,Company,Mailing Street 1,Mailing Street 2,Mailing City,Mailing State,Mailing Country,Mailing Zip,Home Phone,Work Phone,Email,Academic Program (from RFI),OwnerID\n';
	        body+='1,SRP Lead,Low,SRP Corporate Conference - Disney2,Web,Conference,'+a.id+',MassUpload,Test1,Business Analyst,Disney,Somewhere in Orlando,Apt5,Orlando,FL,United States,32801,111-111-1111,333-333-3333,Massuploadtest1@gmail.com,CJ Administration5,00560000001WZU5\n';
	        body+='1,SRP Lead,High,SRP Corporate Conference - Disney,Web,Conference,'+a.id+',MassUpload,Test2,President,Salesforce,Somewhere in CA,Apt1,San Francisco,CA,United States,32801,(222)222-2222,(444)444-4444,Massuploadtest2@gmail.com,CJ Administration5,00560000001WZU5\n';
	        
	        for(integer i=3; i<100; i++){
	        	body+='1,SRP Lead,High,SRP Corporate Conference - Disney,Web,Conference,'+a.id+',MassUpload,Test'+i+',President,Salesforce,Somewhere in CA,Apt1,San Francisco,CA,United States,32801,(222)222-2222,(444)444-4444,Massuploadtest'+i+'@gmail.com,CJ Administration5,00560000001WZU5\n';
	        }
	        
	        at.Body=Blob.valueOf(body);
	        insert at;
	        
	        System.Debug('getLimitCpuTime()1>>>>'+limits.getLimitCpuTime());
	        System.Debug('getCpuTime()1>>>>'+limits.getCpuTime());
	        String message = SRPUploadAttachmentForCampaigns.parseAttachmentSheet(leads.id);
	        System.Debug('getLimitCpuTime()2>>>>'+limits.getLimitCpuTime());
	        System.Debug('getCpuTime()2>>>>'+limits.getCpuTime());
	        
	        //System.assertEquals('File successfully uploaded', message);
        
    	}
	}
}