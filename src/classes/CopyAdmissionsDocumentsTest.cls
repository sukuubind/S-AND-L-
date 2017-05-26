@isTest
private class CopyAdmissionsDocumentsTest {

    static testMethod void myUnitTest() {
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	Account a = new Account();
    	a.Name = 'Test Account';
    	insert a;    	
        
		
        
        //set up a program and set the opportunity to it
       	Academic_Program__c ap = new Academic_Program__c();
       	ap.Name = 'Test Program';
       	ap.School__c = a.Id;
       	insert ap;
       	
       	Opportunity o = new Opportunity();
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        o.CloseDate=d;
        o.StageName='New Inquiry';
        //o.ForecastCategoryName='Pipeline';
        o.Name='Test';
        o.AccountID=a.Id;                     
        o.Program__c = ap.Id;
        insert o;
        
        Program_Admission_Template__c temp = new Program_Admission_Template__c();
        temp.Program__c = ap.Id;
        temp.Name = 'Test Template';
        temp.Type__c = 'Resume';
        insert temp;
        
        PageReference pg= new PageReference('/apex/CopyAdmissionsDocuments?id='+o.Id);        
        Test.setCurrentPage(pg);        
         
        ApexPages.StandardController newController = new ApexPages.StandardController(o);
        CopyAdmissionsDocumentsController controller1 = new CopyAdmissionsDocumentsController(newController);
        
        CopyAdmissionsDocumentsController controller = new CopyAdmissionsDocumentsController();
        controller1.CopyDocs(); 
        controller1.Cancel();
        }
    }
}