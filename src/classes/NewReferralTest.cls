@isTest
private class NewReferralTest {

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
    	insert a; 
    	
    	
        //set up a program and set the opportunity to it
       	Academic_Program__c ap = new Academic_Program__c();
       	ap.Name = 'Test Program';
       	ap.School__c = a.Id;
       	ap.Program_Title__c = 'Test Program';
       	insert ap;
       	
       	
    	Contact c = new Contact ();
        c.FirstName='Joe';
        c.LastName='Smith';
        c.Phone='2222222222';     
        c.AccountID = a.Id;   
        insert c;
        
		Opportunity o = new Opportunity();
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        o.CloseDate=d;
        o.StageName='New Inquiry';
        
        //o.ForecastCategoryName='Pipeline';
        o.Name='Test';
        o.AccountID=a.Id;
        o.Student__c=c.Id;        
        insert o;
        
        
         
		PageReference pg= new PageReference('/apex/NewReferral?id='+o.Id);        
        Test.setCurrentPage(pg);         
        
        ApexPages.StandardController newController = new ApexPages.StandardController(o);
        NewReferralController controller = new NewReferralController(newController);
        
        string ownerID = controller.ownerID;
        controller.campusId = a.Id;
        controller.programId = ap.Id;
	    List <SelectOption> tfOptions = controller.timeFrameOptions;
	    List <SelectOption> gOptions = controller.genderOptions;        
        
        controller.saveOpp();
        controller.Cancel();
        }
    }
}