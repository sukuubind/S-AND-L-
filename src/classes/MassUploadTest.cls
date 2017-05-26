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
private class MassUploadTest {

    static testMethod void allValidScenario() {
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
        a.Goldmine_Key5__c = 'Test Account';
        insert a; 
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign Name';
        camp.Campaign_Code__c = 'CEC 2011';
        camp.Lowest_Level_in_Hierarchy__c = true;
        camp.StartDate = Date.Today()-1;
        camp.EndDate = Date.Today()+1;
        camp.IsActive = true;
        insert camp;
        
        Campain_Leads_Upload__c leads = new Campain_Leads_Upload__c();
        leads.Name = 'test';
        insert leads;
        
        Attachment at = new Attachment();
        at.Name = 'Attachment Name';
        at.parentid = leads.id;
        String body = 'Campaign Code,Organization Name,Created Date,Create Time,Student Last Name,Student First Name,Title,Employer/Company,Mailing Street,Mailing Address Other,Mailing City,Mailing State,Mailing Country,Mailing Zip,Home Phone,Work Phone,Email,Key5,Course Interest\n';
        body+='CEC 2011,Gonzaga University,10/31/2011,4:53 PM,Marlowe,Philip,,Marlowe Agency,227 Boardwalk Ave.,,San Francisco,CA,United States,94102,555-335-2210,,pmarlowe@test.com,Test Account,COML,low,';
        at.Body=Blob.valueOf(body);
        insert at;
        
        String message = UploadAttachmentForCampaigns.parseAttachmentSheet(leads.id);
        System.Debug('Message'+message);
        System.assertEquals('File successfully uploaded', message);
        
        
        }
    }
    static testMethod void attachmentDeltedTest(){
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
        a.Goldmine_Key5__c = 'Test Account';
        insert a; 
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign Name';
        camp.Campaign_Code__c = 'CEC 2011';
        camp.Lowest_Level_in_Hierarchy__c = true;
        camp.StartDate = Date.Today()-1;
        camp.EndDate = Date.Today()+1;
        camp.IsActive = true;
        insert camp;
        
        Campain_Leads_Upload__c leads = new Campain_Leads_Upload__c();
        leads.Name = 'test';
        insert leads;
        
        Attachment at = new Attachment();
        at.Name = 'Attachment Name';
        at.parentid = leads.id;
        String body = 'Campaign Code,Organization Name,Created Date,Create Time,Student Last Name,Student First Name,Title,Employer/Company,Mailing Street,Mailing Address Other,Mailing City,Mailing State,Mailing Country,Mailing Zip,Home Phone,Work Phone,Email,Key5,Course Interest\n';
        body+='CEC 2011,Gonzaga University,10/31/2011,4:53 PM,Marlowe,Philip,,Marlowe Agency,227 Boardwalk Ave.,,San Francisco,CA,United States,94102,555-335-2210,,pmarlowe@test.com,Test Account,COML,high,';
        at.Body=Blob.valueOf(body);
        insert at;
        
        String message = UploadAttachmentForCampaigns.parseAttachmentSheet(leads.id);
        System.Debug('Message'+message);
        System.assertEquals('File successfully uploaded', message);
        
        delete at;
        Campain_Leads_Upload__c ExtractLead = [Select Upload_Complete__c from Campain_Leads_Upload__c where Id = :leads.Id];
        System.AssertEquals(false, ExtractLead.Upload_Complete__c);
        }
    }
    
    
    static testMethod void attachmentAlreadyExistsTest(){
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
            a.Goldmine_Key5__c = 'Test Account';
            insert a; 
            
            Campaign camp = new Campaign();
        camp.Name = 'Campaign Name';
        camp.Campaign_Code__c = 'CEC 2011';
        camp.Lowest_Level_in_Hierarchy__c = true;
        camp.StartDate = Date.Today()-1;
        camp.EndDate = Date.Today()+1;
        camp.IsActive = true;
        insert camp;
            
            Campain_Leads_Upload__c leads = new Campain_Leads_Upload__c();
            leads.Name = 'test';
            insert leads;
            
            Attachment at = new Attachment();
            at.Name = 'Attachment Name';
            at.parentid = leads.id;
            String body = 'Campaign Code,Organization Name,Created Date,Create Time,Student Last Name,Student First Name,Title,Employer/Company,Mailing Street,Mailing Address Other,Mailing City,Mailing State,Mailing Country,Mailing Zip,Home Phone,Work Phone,Email,Key5,Course Interest\n';
            body+='CEC 2011,Gonzaga University,10/31/2011,4:53 PM,Marlowe,Philip,,Marlowe Agency,227 Boardwalk Ave.,,San Francisco,CA,United States,94102,555-335-2210,,pmarlowe@test.com,Test Account,COML';
            at.Body=Blob.valueOf(body);
            insert at;
            
            Attachment at1 = new Attachment();
            at1.Name = 'Attachment Name1';
            at1.parentid = leads.id;
             body = 'This should not work';
            at1.Body=Blob.valueOf(body);
            try{
                insert at1;
                // The insert process should fail. There is a trigger to not allow the second attachment.
                System.assert(false);
            }catch(Exception e){
                System.assert(true);
            }
        }
    }
    
        
        static testMethod void key5NotValid(){
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
        a.Goldmine_Key5__c = 'Test Account';
        insert a; 
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign Name';
        camp.Campaign_Code__c = 'CEC 2011';
        camp.Lowest_Level_in_Hierarchy__c = true;
        camp.StartDate = Date.Today()-1;
        camp.EndDate = Date.Today()+1;
        camp.IsActive = true;
        insert camp;
        
        Campain_Leads_Upload__c leads = new Campain_Leads_Upload__c();
        leads.Name = 'test';
        insert leads;
        
        Attachment at = new Attachment();
        at.Name = 'Attachment Name';
        at.parentid = leads.id;
        String body = 'Campaign Code,Organization Name,Created Date,Create Time,Student Last Name,Student First Name,Title,Employer/Company,Mailing Street,Mailing Address Other,Mailing City,Mailing State,Mailing Country,Mailing Zip,Home Phone,Work Phone,Email,Key5,Course Interest\n';
        body+='CEC 2011,Gonzaga University,10/31/2011,4:53 PM,Marlowe,Philip,,Marlowe Agency,227 Boardwalk Ave.,,San Francisco,CA,United States,94102,555-335-2210,,pmarlowe@test.com,Gon,COML';
        at.Body=Blob.valueOf(body);
        insert at;
        
        String message = UploadAttachmentForCampaigns.parseAttachmentSheet(leads.id);
        System.Debug('Message'+message);
        String expectedMessage = 'Key5 [Gon] is not found in Deltak \n';
        expectedMessage += 'Please correct the above errors.';
        System.assertEquals(expectedMessage, message);
        
        }
    }
}