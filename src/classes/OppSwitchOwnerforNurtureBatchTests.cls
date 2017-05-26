@isTest
public class OppSwitchOwnerforNurtureBatchTests {
	
    
    Public Static User uNurture;
    Public static User u2;
    Public static date d;
    Public static DeltakSRP__Academic_Program__c ap;
    Public static Account a;
    Public static Contact c;
    Public static DateTime t;
    Public static Opportunity o;
    
    static testmethod void Test_SwitchOwnerForNurtureBatch(){
   		
        Test_Init();

        System.runAs(u2) {   
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);            
            o = new Opportunity();
            o.CloseDate=d;
            o.StageName='Dormant';
            o.DeltakSRP__Sub_Stage__c = 'Unable to Contact';
            o.DeltakSRP__Academic_Program__c = ap.Id;           
            o.AccountID=a.Id;
            o.DeltakSRP__Student__c=c.Id;   
            o.DeltakSRP__Start_Date__c = sd;
            o.Name='Test '; //+ i; 
            o.RecordTypeId = OpportunityUtilities.getSRPOppRecordType();
            insert o;
        }	
        
        Test.setCreatedDate(o.id, Date.today() - 61);
        Test.startTest();            
        OpportunitySwitchOwnerForNurtureBatch b = new OpportunitySwitchOwnerForNurtureBatch();
        Database.executeBatch(b);
        Test.stopTest();
 
        // Verify results
        o = [SELECT id, ownerID, createdDate FROM Opportunity WHERE id = :o.id];
        System.debug('o.createdDate: ' + o.createdDate);
        
        System.assertEquals(uNurture.Id, o.ownerID);
    }
    
    
    static testmethod void Test_SwitchOwnerForNurtureBatchFails(){
   		
        Test_Init();

        System.runAs(u2) {   
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);            
            //Test bad stage
            o = new Opportunity();
            o.CloseDate=d;
            o.StageName='Prospecting';
            o.DeltakSRP__Sub_Stage__c = 'Unable to Contact';
            o.DeltakSRP__Academic_Program__c = ap.Id;           
            o.AccountID=a.Id;
            o.DeltakSRP__Student__c=c.Id;   
            o.DeltakSRP__Start_Date__c = sd;
            o.Name='Test '; //+ i; 
            o.RecordTypeId = OpportunityUtilities.getSRPOppRecordType();
            insert o;
            
            //Test bad substage
            Opportunity o2 = new Opportunity();
            o2.CloseDate=d;
            o2.StageName='Dormant';
            o2.DeltakSRP__Sub_Stage__c = 'Chat';
            o2.DeltakSRP__Academic_Program__c = ap.Id;           
            o2.AccountID=a.Id;
            o2.DeltakSRP__Student__c=c.Id;   
            o2.DeltakSRP__Start_Date__c = sd;
            o2.Name='Test 2';  
            o2.RecordTypeId = OpportunityUtilities.getSRPOppRecordType();
            insert o2;
            
            //Test no record type
            Opportunity o3 = new Opportunity();
            o3.CloseDate=d;
            o3.StageName='Dormant';
            o3.DeltakSRP__Sub_Stage__c = 'Unable to Contact';
            o3.DeltakSRP__Academic_Program__c = ap.Id;           
            o3.AccountID=a.Id;
            o3.DeltakSRP__Student__c=c.Id;   
            o3.DeltakSRP__Start_Date__c = sd;
            o3.Name='Test 3'; //+ i; 
            //o3.RecordTypeId = OpportunityUtilities.getSRPOppRecordType();
            insert o3;
            
    
            //Test 59 day created date             
            Opportunity o4 = new Opportunity();
            o4.CloseDate=d;
            o4.StageName='Dormant';
            o4.DeltakSRP__Sub_Stage__c = 'Unable to Contact';
            o4.DeltakSRP__Academic_Program__c = ap.Id;           
            o4.AccountID=a.Id;
            o4.DeltakSRP__Student__c=c.Id;   
            o4.DeltakSRP__Start_Date__c = sd;
            o4.Name='Test 4'; //+ i; 
            o4.RecordTypeId = OpportunityUtilities.getSRPOppRecordType();
            insert o4;
            
            Test.setCreatedDate(o.id, Date.today() - 61);
            Test.setCreatedDate(o2.id, Date.today() - 61);
            Test.setCreatedDate(o3.id, Date.today() - 61);
            Test.setCreatedDate(o4.id, Date.today() - 59);
        }	
        
        Test.startTest();            
        OpportunitySwitchOwnerForNurtureBatch b = new OpportunitySwitchOwnerForNurtureBatch();
        Database.executeBatch(b);
        Test.stopTest();
 
        // Verify results
        List<Opportunity> opps = [SELECT id, Name, ownerID, CreatedDate FROM Opportunity WHERE ownerID = :uNurture.Id];
        System.debug('opps: ' + opps);
        System.assert(opps.size() == 0);
    }
    
    
    public static void Test_Init(){
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        //Create Test Data
        u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        
        insert u2;
        
        uNurture = new User(alias = 'nurtUser', email='nurtureuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Nurture',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='nurtureuser11@testorg.com');
        insert uNurture;
        
        Opportunity_Settings__c mcs = new Opportunity_Settings__c();
        mcs.NurtureUserID__c = uNurture.Id;
        insert mcs;

        System.runAs(u2) {
                
            //OpportuntyUtilities.idNurtureUser = uNurture.Id;
            
            t=System.now();
            d = Date.newInstance(t.year(),t.month(),t.day());
             
            a = new Account();
            a.Name = 'Test Account';
            a.Nurture_Unable_To_Contact__c = true;
            insert a;
            
            Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';    
            c.AccountID = a.Id;   
            c.DeltakSRP__Employer_Company__c = 'Disney'; 
            insert c;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
            ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'Test Program';
            ap.DeltakSRP__School__c = a.Id;
            insert ap;
            
            //set up a program and set the opportunity to it
            DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
            ap2.Name = 'Test Program 2';
            ap2.DeltakSRP__School__c = a2.Id;
            insert ap2;
            
            DeltakSRP__Academic_Start_Date__c startDate = new DeltakSRP__Academic_Start_Date__c();
            startDate.DeltakSRP__Start_Date__c = d;
            startDate.DeltakSRP__Academic_Program__c = ap.Id;
            insert startDate;
        }
    }
}