@isTest
public class OfferAppointmentExtension_Test{

 static testMethod void testOfferAppointment(){

    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    
    
    insert upm;
    
    
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

    //create contact
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.accountid = a.id;
    newcontact.Employer_Company__c = 'Test Company';
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
    //create academic program
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
    //create academic specialization      
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    //create opportunity
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.webschedulerstatus__c = 'Completed';
    theopp.Email_from_Student__c = 'teststd@test.com';
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    System.runAs(upm){
        //setup a ref to the page   
    PageReference p = new Pagereference('/apex/OfferAppointmentExtension?id=' + theopp.id);
     Test.setCurrentPage(p);  
     
    //construct standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(theopp);
        OfferAppointmentExtension controller = new OfferAppointmentExtension(con);
    Test.startTest();
      //test the opportunity update
        controller.updateWebSchedulerStatus();
        Opportunity o = [Select id, webschedulerstatus__c FROM Opportunity where id = : theopp.id limit 1];
        System.assertequals(o.webschedulerstatus__c, 'New');
        
    
    Test.stopTest();
    
    }//end runas
   }//end testmethod 
   
     private static ID findAccountRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Account;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Campus/Partner') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }    
    
     private static ID findContactRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Contact;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Deltak Student') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
    
     private static ID findOpportunityRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Opportunity;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Student Opportunity') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
}