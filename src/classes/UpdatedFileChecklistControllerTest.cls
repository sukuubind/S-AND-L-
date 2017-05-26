@isTest(seeAllData=true)
public with sharing class UpdatedFileChecklistControllerTest {

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
     	List <DeltakSRP__Program_Admission_Document__c> insertList = new 	List <DeltakSRP__Program_Admission_Document__c>(); 	
       	DeltakSRP__Program_Admission_Document__c pad1 = new DeltakSRP__Program_Admission_Document__c(
       		DeltakSRP__Document_Name__c = 'Application',
			DeltakSRP__Opportunity__c = o.Id,
			DeltakSRP__Order__c = 1,
			DeltakSRP__Comments__c = 'This is a test application.',
			DeltakSRP__Date_Received__c = d);	
       	insertList.add(pad1);
       
       	
       	DeltakSRP__Program_Admission_Document__c pad2 = new DeltakSRP__Program_Admission_Document__c(
       		DeltakSRP__Document_Name__c = 'Application Fee',
			DeltakSRP__Opportunity__c = o.Id,
			DeltakSRP__Order__c = 2,
			DeltakSRP__Comments__c = 'This is a test application fee.',
			DeltakSRP__Date_Received__c = d,
			DeltakSRP__Fee_Amount__c = 40.05 );	
			insertList.add(pad2);
       	insert insertList;
      
       	UpdatedFileCheckListController controller = new UpdatedFileCheckListController(new ApexPages.StandardController(o));
       	List <DeltakSRP__Program_Admission_Document__c> docs = controller.docs;
       	System.assertEquals(2, docs.size());
       	PageReference pg= new PageReference('/apex/Updated_File_Checklist?id='+o.Id);        
        Test.setCurrentPage(pg);        
        }    
    }
}