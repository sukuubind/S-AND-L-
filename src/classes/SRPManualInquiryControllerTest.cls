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
@isTest(SeeAllData=true)
public class SRPManualInquiryControllerTest {
    
    private static void testSRPNewInquiryUtil(){
        
         RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        
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
        ap.DeltakSRP__Active__c = true;
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
            
            o.Name='Test';
            o.AccountID=a.Id;
            o.Student__c=c.Id;        
            insert o;
        
        SRPNewInquiryUtil.loadAllCampuses(true);
        SRPNewInquiryUtil.loadCurrentCampus(a.Id, true);
        SRPNewInquiryUtil.loadPrograms(a.Id);
        SRPNewInquiryUtil.setNewReferralOwner(o);
        SRPNewInquiryUtil.getCampaignCode('New Referral Page');
    }
    
   
    static testMethod void myUnitTest() {
        User u = [Select Id from User where name =: 'Configuration Manager'];
         
        system.runas(u){    
        SRPManualInquiryController testobj = new SRPManualInquiryController();
        testobj.Cancel();
        List<SelectOption> goptions = testobj.genderOptions;
        List<SelectOption> toptions = testobj.timeframeOptions;
              
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAN';
        a.name = 'test account';
        insert a;
        
        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        ap.DeltakSRP__Active__c = true;
        insert ap;
        
        DeltakSRP__Academic_Specialization__c asp = new DeltakSRP__Academic_Specialization__c(DeltakSRP__Academic_Program__c = ap.Id);
        insert asp;
        
        testobj.StudentFirstName = 'TestFname';
        testobj.StudentLastName = 'testLname';
        
        testobj.campusid = a.Id;
        testobj.programid = ap.Id;
        testobj.specializationid = asp.id;
        testobj.home_phone = '1234567890';
        testobj.selectedTimeframe = 'timeframe';
        testobj.campaignCode = 'campaigncode';
        testobj.Email = 'a@b.com';
        testobj.country = 'united states';
        testobj.saveSRMLead();
        
        Opportunity o = new Opportunity();
        //o = [Select Id, OwnerId, Owner.isActive, stagename, home_phone__c, deltaksrp__home_phone__c from Opportunity where accountId = :a.Id];
        //system.assertequals(o.stagename, 'New Inquiry');    
        }
             
     }
     
     static testMethod void testValidateNewInquiry() {
     
        User u = [Select Id from User where Id =: userinfo.getuserid()];
        
        system.runas(u){    
        SRPManualInquiryController testobj = new SRPManualInquiryController();
        testobj.Cancel();
    
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAN';
        a.name = 'test account';
        insert a;
        
        DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
        ap.Name = 'abcd';
        ap.DeltakSRP__School__c = a.id;
        ap.DeltakSRP__Degree_Type__c = 'Certificate';
        ap.DeltakSRP__Abbrev__c = 'CID';
        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
        ap.DeltakSRP__Active__c = true;
        ap.DeltakSRP__Require_Specialization__c = true;
        insert ap;
        
        DeltakSRP__Academic_Specialization__c asp = new DeltakSRP__Academic_Specialization__c(DeltakSRP__Academic_Program__c = ap.Id);
        insert asp;
        
        Campaign_Administration__c camp = new Campaign_Administration__c();
        camp.Name = 'Test Campaign';
        insert camp;
 
  //     List<SelectOption> toptions = testobj.timeframeOptions;

       
        Boolean value; 
        Integer i;
        
              
        testobj.StudentFirstName = 't';
        system.assertequals(false, testobj.validateFisrtName()); 
        
        testobj.StudentFirstName = 'test';
        system.assertequals(true, testobj.validateFisrtName());  
        
        testobj.StudentLastName = 't';
        system.assertequals(false, testobj.validateLastName()); 
        
        testobj.StudentLastName = 'test';
        system.assertequals(true, testobj.validateLastName());  
       
        testobj.Email = '';
        system.assertequals(false, testobj.validateEmail());
        
        testobj.Email = 'a.c@';
        system.assertequals(false, testobj.validateEmail());
              
        testobj.Email = 'a.b@gmail.com';
        system.assertequals(true, testobj.validateEmail());
          
        testobj.Home_Phone = '12345';
        system.assertequals(false, testobj.validateHomePhone());
        
        testobj.Home_Phone = '1234567890';
        system.assertequals(true, testobj.validateHomePhone());
       
        testobj.Mobile_Phone = '12345';
        system.assertequals(false, testobj.validateMobilePhone());
        
        testobj.Mobile_Phone = '1234567890';
        system.assertequals(true, testobj.validateMobilePhone());
        
        testobj.Work_Phone = '12345';
        system.assertequals(false, testobj.validateWorkPhone());
        
        testobj.Work_Phone = '1234567890';
        system.assertequals(true, testobj.validateWorkPhone());
        
        testobj.campusId = '-None-';
        system.assertequals(false, testobj.validateCampus());
    
        testobj.campusid = a.Id;
        system.assertequals(true, testobj.validateCampus());   
    
        testobj.programId = '-None-';
        system.assertequals(false, testobj.validateProgram());
   
        testobj.programid = ap.Id;
        system.assertequals(true, testobj.validateProgram());
  
        testobj.specializationId = '-None-';
        system.assertequals(false, testobj.validateSpecialization());
        
        testobj.specializationid = asp.id;
        system.assertequals(true, testobj.validateSpecialization());

        testobj.selectedTimeframe = '-None-';
        system.assertequals(false, testobj.validateTimeframe());
        
        List<string> timeframeOptions = new List<string>();
        timeframeOptions.add('ct1');
        for(i=0; i<timeframeOptions.size();i++)
        {
        testobj.selectedTimeframe = timeframeOptions[i];
             system.assertequals(true, testobj.validateTimeframe());           
             break;
             }
                 
        testobj.campaignCode = '-None-';
        system.assertequals(false, testobj.validateCampaign());
       
    //  true condition  
        testobj.campaignCode = camp.id;
        system.assertequals(true, testobj.validateCampaign());
 
        }
     
     }

}