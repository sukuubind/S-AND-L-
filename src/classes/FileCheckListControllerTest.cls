@isTest
private class FileCheckListControllerTest {

    static testMethod void myUnitTest() {
    Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    DateTime t=System.now();
    date d = Date.newInstance(t.year(),t.month(),t.day());	
    
    //Perform data preparation. Create Account.
    	Account a = new Account();
    	a.Name = 'Test Account';
    	insert a; 
    	
    //Perform data preparation. Create Opportunity.
    	Opportunity o = new Opportunity(
    		Name = 'Test Opportunity',
    		CloseDate = d,
    		StageName = 'New Inquiry', 
    		AccountID = a.Id );
    	insert o;

     //set up a few program admissions document records.    
     	List <Program_Admission_Document__c> insertList = new 	List <Program_Admission_Document__c>(); 	
       	Program_Admission_Document__c pad1 = new Program_Admission_Document__c(
       		Document_Name__c = 'Application',
			Opportunity__c = o.Id,
			Order__c = 1,
			Comments__c = 'This is a test application.',
			Date_Received__c = d);	
       	insertList.add(pad1);
       
       	
       	Program_Admission_Document__c pad2 = new Program_Admission_Document__c(
       		Document_Name__c = 'Application Fee',
			Opportunity__c = o.Id,
			Order__c = 2,
			Comments__c = 'This is a test application fee.',
			Date_Received__c = d,
			Fee_Amount__c = 40.05 );	
			insertList.add(pad2);
       	insert insertList;
      
       	FileCheckListController controller = new FileCheckListController(new ApexPages.StandardController(o));
       	List <Program_Admission_Document__c> docs = controller.docs;
       	System.assertEquals(2, docs.size());
       	PageReference pg= new PageReference('/apex/File_Checklist?id='+o.Id);        
        Test.setCurrentPage(pg);        
        }    
    }
}