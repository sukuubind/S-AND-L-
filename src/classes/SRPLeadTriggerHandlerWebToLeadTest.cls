/**
 Author: Girija Ogale
 Date: 03/18/2016
 Description: Test class to test functionality of Web-to-lead response functionality
 */

@isTest(seealldata=true)
public with sharing class SRPLeadTriggerHandlerWebToLeadTest {
    
    static testMethod void webToLeadTest() 
    {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
                
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        a.Goldmine_Key5__c = 'tacc';
        insert a;
        
        Lead l = new Lead();
        l.Status = 'Open';
        l.Company = 'Deltak';
        l.DeltakSRP__Academic_Institution_Lookup__c = a.id;
        l.FirstName = 'fname8';
        l.LastName = 'lname8';
        l.RecordTypeId = rt2.Id;
        l.Phone = '1234567890';
        l.MobilePhone = '1234567890';
        l.DeltakSRP__Work_Phone__c = '1234567890';
        l.DeltakSRP__Home_Phone__c = '1234567890';
        l.RFI_Campaign_Code__c = 'I- Masterstudies';
        l.SMS_Ok_To_Text_Incoming__c = 'TRUE';
        l.DoNotCall_Incoming__c = 'No';
        l.HasOptedOutOfEmail_Incoming__c = '0';
        
        insert l;
    }
    
    static testMethod void webToLeadTest1() 
    {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
                
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        a.Goldmine_Key5__c = 'tacc';
        insert a;
        
        Lead l = new Lead();
        l.Status = 'Open';
        l.Company = 'Deltak';
        l.DeltakSRP__Academic_Institution_Lookup__c = a.id;
        l.FirstName = 'fname8';
        l.LastName = 'lname8';
        l.RecordTypeId = rt2.Id;
        l.Phone = '1234567890';
        l.MobilePhone = '1234567890';
        l.DeltakSRP__Work_Phone__c = '1234567890';
        l.DeltakSRP__Home_Phone__c = '1234567890';
        l.RFI_Campaign_Code__c = 'I- Masterstudies';
        l.SMS_Ok_To_Text_Incoming__c = 'No';
        l.DoNotCall_Incoming__c = 'True';
        l.HasOptedOutOfEmail_Incoming__c = '1';
        
        insert l;
    }

}