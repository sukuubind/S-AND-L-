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
@isTest
private class Eloqua_ContactTriggerTest {

    static testMethod void Insert_DifferentEmailScenario() {
    	Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	Boolean sameEmail = false;
        List<Contact> contactList = insertContact(5, false, false);
        List<Id> contactListIds = new List<Id>();
        for(Contact c : contactList){
        	contactListIds.add(c.Id);
        }
        List<Contact> updatedContactList = [Select Id, Share_Count__c from Contact where Id IN :contactListIds];
    	System.assertNotEquals(null, updatedContactList);
    	System.AssertEquals(5, updatedContactList.size());
    	for(Contact cc : updatedContactList){
    		System.AssertEquals(0, cc.Share_Count__c);
    	}
        }
    }
    static testMethod void Insert_sameEmailScenario() {
    	Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	
    	
    	Test.startTest();
    	Boolean sameEmail = true;
       /**	Contact firstContact = new Contact();
       	firstContact.FirstName = 'Venkat Test';
       	firstContact.LastName = 'Santhanam Test';
       	firstContact.Email = 'venkat.santhanam@rasmussen.edu';
       	insert firstContact;**/
       	
       	
       
        List<Contact> contactList = insertContact(5, sameEmail, false);
        List<Id> contactListIds = new List<Id>();
        Test.stopTest();
              
        for(Contact c : contactList){
        	contactListIds.add(c.Id);
        }
        
        List<Contact> updatedContactList = [Select Id, Share_Count__c from Contact where Id IN :contactListIds];
    	
    	System.assertNotEquals(null, updatedContactList);
    	System.AssertEquals(5, updatedContactList.size());
    	for(Contact cc : updatedContactList){
    		System.AssertEquals(4, cc.Share_Count__c);
    	}
       }
    
    }
    static testMethod void Update_ValidEmails(){
    	Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, (Select Id, GM_Name__c From Users where ProfileId = :prof.Id and GM_Name__c != null limit 1) From UserRole u where u.Name = 'Sacred Heart Staff' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
    	Test.StartTest();
    	Boolean sameEmail = true;
    	 List<Contact> contactList = insertContact(10, sameEmail, false);
    	  List<Id> contactListIds = new List<Id>();
    	  for(Contact c : contactList){
        	contactListIds.add(c.Id);
        }
    	 
    	 Integer i = 0;
    	 for(Contact c : contactList){
	    	 if(i == 5)
	    	      break;	
	    	 c.Email = 'venkat.santhanam@edlconsulting.com'+String.valueOf(i);
	    	
	    	i++;
    	}
    	System.Debug('Contact List Updated VS --- '+contactList);
    	update contactList;
    	Test.stopTest();
    	 List<Contact> updatedContactList = [Select Id, Share_Count__c, Email from Contact where Id IN :contactListIds];
    	 System.assertNotEquals(null, updatedContactList);
    	System.AssertEquals(10, updatedContactList.size());
    	i = 0;
    	for(Contact cc : updatedContactList){
    		
    		if(cc.Email == 'venkat.santhanam@edlconsulting.com'+String.valueOf(i)){
    			System.AssertEquals(0, cc.Share_Count__c);
    		}
    		
    		i++;
    	}
    	
        }
    	
    }
    private static List<Contact> insertContact(Integer count, Boolean sameEmail, Boolean setShareCount){
    	 Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
    Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();             
    List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
    for (Schema.RecordTypeInfo rtInfo : RT) {
        System.debug(rtInfo.getName());
        System.debug(rtInfo.getRecordTypeId());
        recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
    }
    System.Debug(recordTypeName_to_recordTypeId);
    	List<Contact> contactList = new List<Contact>();
    	for(Integer i = 0; i < count; i++){
    		Contact thisCont = new Contact();
    		thisCont.FirstName = 'Test Venkat'+String.valueOf(i);
    		thisCont.LastName = 'Test Santhanam'+String.valueOf(i);
    		thisCont.RecordTypeId = recordTypeName_to_recordTypeId.get('Deltak Student');
    		if(sameEmail){
    			thisCont.Email = 'venkat.santhanam@rasmussen.edu0000';
    		}else{
    			thisCont.Email = 'venkat.santhanam@rasmussen.edu.'+String.valueOf(i);
    		}
    		if(setShareCount){
    			thisCont.Share_Count__c = 1;
    		}
    		contactList.add(thisCont);
    	}
    	insert contactList;
    	return contactList;
    }
}