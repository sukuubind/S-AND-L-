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
@isTest(seeAllData=true)
private class SRPEventRFIControllerTest {

    static testMethod void eventRFITest() {
        List<DeltakSRP__Academic_Program__c> majors = new List<DeltakSRP__Academic_Program__c>();
        majors = [Select d.Id, d.DeltakSRP__Program_Title__c, d.DeltakSRP__School__c From DeltakSRP__Academic_Program__c d where d.DeltakSRP__School__r.Name = 'Loyola University - New Orleans' and d.DeltakSRP__Active__c = true limit 1]; 
        System.debug('majors-->'+majors);
        String pgmId = '';
        if(majors!=null && majors.size()>0)
            pgmId = majors[0].id;
        
        List<DeltakSRP__Event__c> eventNameList = new List<DeltakSRP__Event__c>();
        String eventRegCode = '';
        eventNameList = [Select Name, Id, DeltakSRP__Start__c, DeltakSRP__Registration_Code__c, DeltakSRP__Type__c from DeltakSRP__Event__c where DeltakSRP__Start__c >= TODAY limit 1];
        if (eventNameList != null && !eventNameList.isEmpty())
        {
           eventRegCode = eventNameList[0].DeltakSRP__Registration_Code__c;
        }
        
        PageReference pageRef = Page.SRPEventRFI;
        pageRef.getParameters().put(SRPEventRFIController.EVENT_RFI_EVENT_ID,eventRegCode);
        Test.setCurrentPage(pageRef);
        SRPEventRFIController controller = new SRPEventRFIController();

        //controller.eventType  ='OH2015';
        controller.firstName.fieldValue ='TestUser';
        controller.lastName.fieldValue  ='FirstUser';
        controller.phone.fieldValue ='2246003334';
        controller.email.fieldValue ='testuser@testorg.com';
        //controller.venueType.fieldValue   =
        //controller.eventDate.fieldValue   =
        controller.intendedMajor.fieldValue = pgmId;
         
         controller.saveLead(); 
    }
    
    static testMethod void eventTypeRFITest1() {
        List<DeltakSRP__Academic_Program__c> majors = new List<DeltakSRP__Academic_Program__c>();
        majors = [Select d.Id, d.DeltakSRP__Program_Title__c, d.DeltakSRP__School__c From DeltakSRP__Academic_Program__c d where d.DeltakSRP__School__r.Name = 'Loyola University - New Orleans' and d.DeltakSRP__Active__c = true limit 1]; 
        System.debug('majors-->'+majors);
        String pgmId = '';
        if(majors!=null && majors.size()>0)
            pgmId = majors[0].id;
        
        List<DeltakSRP__Event__c> eventNameList = new List<DeltakSRP__Event__c>();
        String eventType = '';
        String location = 'On Campus';
        DateTime eventDate = null;
        eventNameList = [Select Name, Id, DeltakSRP__Start__c, DeltakSRP__Registration_Code__c, DeltakSRP__Type__c from DeltakSRP__Event__c where DeltakSRP__Start__c >= TODAY limit 1];
        if (eventNameList != null && !eventNameList.isEmpty())
        {
           eventType = eventNameList[0].DeltakSRP__Type__c;
           
           eventDate = eventNameList[0].DeltakSRP__Start__c;
        }
        
        
        PageReference pageRef = Page.SRPEventRFI;
        pageRef.getParameters().put(SRPEventRFIController.EVENT_RFI_EVENT_TYPE,eventType);
        Test.setCurrentPage(pageRef);
        SRPEventRFIController controller = new SRPEventRFIController();

        //controller.eventType  ='OH2015';
        controller.firstName.fieldValue ='TestUser';
        controller.lastName.fieldValue  ='FirstUser';
        controller.phone.fieldValue ='2246003334';
        controller.email.fieldValue ='testuser@testorg.com';
        controller.venueType.fieldValue =location;
        controller.loadEventDates();
        controller.eventDate.fieldValue =String.valueOf(eventDate);
        controller.intendedMajor.fieldValue = pgmId;
        //controller.otherIntendedStartTerm.fieldValue  =
        
        
         
         controller.saveLead(); 
    }
    
    static testMethod void eventTypeRFITest2() {
        List<DeltakSRP__Academic_Program__c> majors = new List<DeltakSRP__Academic_Program__c>();
        majors = [Select d.Id, d.DeltakSRP__Program_Title__c, d.DeltakSRP__School__c From DeltakSRP__Academic_Program__c d where d.DeltakSRP__School__r.Name = 'Loyola University - New Orleans' and d.DeltakSRP__Active__c = true limit 1]; 
        System.debug('majors-->'+majors);
        String pgmId = '';
        if(majors!=null && majors.size()>0)
            pgmId = majors[0].id;
        
        List<DeltakSRP__Academic_Start_Date__c> terms = new List<DeltakSRP__Academic_Start_Date__c>();
        terms = [select id, Name from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Academic_Program__c = :pgmId];
        System.debug('terms-->'+terms);
        String termId = '';
        if(terms!=null && terms.size()>0)
        {
            termId = terms[0].id;
        }
        
        List<DeltakSRP__Event__c> eventNameList = new List<DeltakSRP__Event__c>();
        String eventType = '';
        String location = 'On Campus';
        DateTime eventDate = null;
        eventNameList = [Select Name, Id, DeltakSRP__Start__c, DeltakSRP__Registration_Code__c, DeltakSRP__Type__c from DeltakSRP__Event__c where DeltakSRP__Start__c >= TODAY and DeltakSRP__Type__c = 'Fully_Caffeinated_Tour' limit 1];
        if (eventNameList != null && !eventNameList.isEmpty())
        {
           eventType = eventNameList[0].DeltakSRP__Type__c;
           
           eventDate = eventNameList[0].DeltakSRP__Start__c;
        }
        
        
        
        PageReference pageRef = Page.SRPEventRFI;
        pageRef.getParameters().put(SRPEventRFIController.EVENT_RFI_EVENT_TYPE,eventType);
        Test.setCurrentPage(pageRef);
        SRPEventRFIController controller = new SRPEventRFIController();

        //controller.eventType  ='OH2015';
        controller.firstName.fieldValue ='TestUser';
        controller.lastName.fieldValue  ='FirstUser';
        controller.phone.fieldValue ='2246003334';
        controller.email.fieldValue ='testuser@testorg.com';
        controller.venueType.fieldValue =location;
        controller.loadEventDates();
        controller.eventDate.fieldValue =String.valueOf(eventDate);
        controller.intendedMajor.fieldValue = pgmId;

         
         controller.saveLead(); 
    }
}