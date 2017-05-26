@isTest
private class AdmissionsDocsControllerTest {

    static testMethod void Test() {
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	DateTime timeNow=System.now();
        date d = Date.newInstance(timeNow.year(),timeNow.month(),timeNow.day());
        
		Opportunity o = new Opportunity();        
			o.CloseDate=d;
	        o.StageName='New Inquiry';
	        o.Name='Test';
	        //o.AccountID=a.Id;
        insert o;
		
		//This document has a receive date which means it will be entered into the 
		//receivedDocsList in the AdmissionsDocsController class
		Program_Admission_Document__c pad1 = new Program_Admission_Document__c(
       		Document_Name__c = 'Application',
			Opportunity__c = o.Id,
			Order__c = 1,
			Comments__c = 'This is test application 1.',
			Date_Received__c = d);	
       	insert pad1;
       	
       	//This document does not have a receive date which means it will be entered into the 
		//missingDocsList in the AdmissionsDocsController class
       	Program_Admission_Document__c pad2 = new Program_Admission_Document__c(
       		Document_Name__c = 'Application',
			Opportunity__c = o.Id,
			Order__c = 2,
			Comments__c = 'This is test application 2.',
			Date_Received__c = null);	
       	insert pad2;
       	
		Test.startTest();
   		AdmissionsDocsController a = new AdmissionsDocsController();
   		
   		//Set the Oppty ID
   		a.OpptyId = o.Id;   		
   		
   		//Get the received and missing docs from the controller
   		Program_Admission_Document__c [] receivedDocs =  a.receivedDocsList;
   		Program_Admission_Document__c [] missingDocs =  a.missingDocsList;

		//There should be 1 doc in each list 
   		System.assertEquals(1, receivedDocs.size());
   		System.assertEquals(1, missingDocs.size());	
   		
   		//Asert that the right application went in the right list based on whether it was received or not
   		System.assertEquals(receivedDocs[0].Comments__c, 'This is test application 1.');
   		System.assertEquals(missingDocs[0].Comments__c, 'This is test application 2.');
   		
		Test.stopTest();
        }
    }
}