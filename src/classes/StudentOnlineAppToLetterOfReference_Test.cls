/**
 * Created by sukumar.bindra1 on 3/21/2017.
 */

@isTest(SeeAllData=true)
private class StudentOnlineAppToLetterOfReference_Test {
    static testMethod void testBehavior() {

        List<DeltakSRP__Student_Letter_of_Reference_Selection__c> slrs = new List<DeltakSRP__Student_Letter_of_Reference_Selection__c>();
        //  List<DeltakSRP__Student_Online_Application__c> soa = new List<DeltakSRP__Student_Online_Application__c>();
        List<DeltakSRP__Student_Online_Application__c> soa1 = new List<DeltakSRP__Student_Online_Application__c>();
        User u = [Select id from user where Profile.Name = 'System Administrator' and isactive = true limit 1];

        System.runAs(u) {
            RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];

            Account a = new Account();
            a.recordTypeid = rt2.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Waiver_Options_Enabled__c = true;
            insert a;

            contact c = new Contact();
            c.FirstName = 'fname';
            c.LastName = 'lname';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt3.Id;
            insert c;

            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            insert ap;

            DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
            asd.DeltakSRP__Academic_Program__c = ap.id;
            asd.DeltakSRP__Start_Date__c = system.today() + 100;
            asd.DeltakSRP__End_Date__c = system.today() + 200;
            insert asd;

            Opportunity o = new Opportunity();
            o.RecordTypeId = rt1.Id;
            o.name = 'Test Opp';
            o.AccountId = a.Id;
            o.DeltakSRP__Academic_Program__c = ap.Id;
            o.StageName = 'New Inquiry';
            o.Sub_Stage__c = 'Awaiting Verification';
            o.CloseDate = system.today() + 400;
            o.DeltakSRP__Start_Date__c = system.today() + 100;
            o.Online_Application_Stage__c = 'Registered to Apply';
            o.DeltakSRP__Student__c = c.Id;

            Profile pr = [SELECT Id FROM profile WHERE name = 'System Administrator'];

            List<RecordType> recordIdList = [SELECT Id FROM RecordType WHERE Name = 'UCC - University College Cork' LIMIT 1];

            Contact aff = [SELECT Id, Name FROM Contact Where AccountId = :a.Id LIMIT 1];

            Test.startTest();

            DeltakSRP__Student_Online_Application__c sa = [SELECT Id, I_waive_my_right_to_access_this_report__c, LOR_Waive_Selection_Signature__c, LOR_Attestation_Signature__c FROM DeltakSRP__Student_Online_Application__c LIMIT 1];

            sa.DeltakSRP__Affiliation__c = aff.Id;
            sa.DeltakSRP__Affiliation_Opportunity__c = o.Id;
            sa.DeltakSRP__Academic_Program__c = ap.Id;
            sa.DeltakSRP__Academic_Start_Date__c = asd.Id;
            sa.Maiden__c = 'test';
            sa.DeltakSRP__Address_Line_1__c = 'test' ;
            sa.DeltakSRP__Address_Line_2__c = 'test';
            sa.DeltakSRP__Address_Line_3__c = 'test';
            sa.DeltakSRP__Application_Status__c = 'InProgress';
            sa.DeltakSRP__Payment_Type__c = 'No Payment';
            sa.DeltakSRP__Submitted__c = false;
            sa.LOR_Attestation_Signature__c = 'Test';
            sa.I_waive_my_right_to_access_this_report__c = 'No';
            sa.LOR_Waive_Selection_Signature__c = 'Test';
            sa.RecordTypeId = recordIdList[0].Id;

            update sa;

            DeltakSRP__Student_Letter_of_Reference__c s = [SELECT Id, LOR_Attestation_Signature__c, LOR_Waive_Selection_Signature__c, I_waive_my_right_to_access_this_report__c FROM DeltakSRP__Student_Letter_of_Reference__c LIMIT 1];

            List<RecordType> recordIdList1 = [SELECT Id FROM RecordType WHERE Name = 'Cork LOR' LIMIT 1];
            List<DeltakSRP__Student_Letter_of_Reference__c> slr = new List<DeltakSRP__Student_Letter_of_Reference__c>();
            for (Integer i = 0; i < 200; i++) {
                DeltakSRP__Student_Letter_of_Reference__c nslr = new DeltakSRP__Student_Letter_of_Reference__c();
                nslr.Name = String.valueOf(i);
                nslr.DeltakSRP__Affiliation__c = aff.Id;
                nslr.RecordTypeId = recordIdList1[0].Id;
                slr.add(nslr);
            }

            insert slr;

            for (integer y = 0; y < 200; y++) {
                DeltakSRP__Student_Letter_of_Reference_Selection__c slrsel = new DeltakSRP__Student_Letter_of_Reference_Selection__c();
                slrsel.DeltakSRP__Student_Online_Application__c = sa.Id;
                slrsel.DeltakSRP__Student_Letter_of_Reference__c = slr[y].Id;
                slrs.add(slrsel);
            }
            insert slrs;
            Test.stopTest();
            List<DeltakSRP__Student_Letter_of_Reference__c> ListToCompare = [SELECT Id FROM DeltakSRP__Student_Letter_of_Reference__c WHERE LOR_Attestation_Signature__c = 'Test' AND I_waive_my_right_to_access_this_report__c = 'No' AND LOR_Waive_Selection_Signature__c = 'Test'];
            System.assertEquals(ListToCompare.size(), 200);
        }
    }

    static testMethod void testBehaviorForSoaToSlrAll() {

        List<DeltakSRP__Student_Letter_of_Reference_Selection__c> slrs = new List<DeltakSRP__Student_Letter_of_Reference_Selection__c>();
        //  List<DeltakSRP__Student_Online_Application__c> soa = new List<DeltakSRP__Student_Online_Application__c>();
        List<DeltakSRP__Student_Online_Application__c> soa1 = new List<DeltakSRP__Student_Online_Application__c>();
        User u = [Select id from user where Profile.Name = 'System Administrator' and isactive = true limit 1];

        System.runAs(u) {
            RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];

            Account a = new Account();
            a.recordTypeid = rt2.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            insert a;

            contact c = new Contact();
            c.FirstName = 'fname';
            c.LastName = 'lname';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt3.Id;
            insert c;

            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            insert ap;

            DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
            asd.DeltakSRP__Academic_Program__c = ap.id;
            asd.DeltakSRP__Start_Date__c = system.today() + 100;
            asd.DeltakSRP__End_Date__c = system.today() + 200;
            insert asd;

            Opportunity o = new Opportunity();
            o.RecordTypeId = rt1.Id;
            o.name = 'Test Opp';
            o.AccountId = a.Id;
            o.DeltakSRP__Academic_Program__c = ap.Id;
            o.StageName = 'New Inquiry';
            o.Sub_Stage__c = 'Awaiting Verification';
            o.CloseDate = system.today() + 400;
            o.DeltakSRP__Start_Date__c = system.today() + 100;
            o.Online_Application_Stage__c = 'Registered to Apply';
            o.DeltakSRP__Student__c = c.Id;

            Profile pr = [SELECT Id FROM profile WHERE name = 'System Administrator'];

            List<RecordType> recordIdList = [SELECT Id FROM RecordType WHERE Name = 'UCC - University College Cork' LIMIT 1];

            Contact aff = [SELECT Id, Name FROM Contact Where AccountId = :a.Id LIMIT 1];

            Test.startTest();

            DeltakSRP__Student_Online_Application__c sa = [SELECT Id, I_waive_my_right_to_access_this_report__c, LOR_Waive_Selection_Signature__c, LOR_Attestation_Signature__c FROM DeltakSRP__Student_Online_Application__c LIMIT 1];

            sa.DeltakSRP__Affiliation__c = aff.Id;
            sa.DeltakSRP__Affiliation_Opportunity__c = o.Id;
            sa.DeltakSRP__Academic_Program__c = ap.Id;
            sa.DeltakSRP__Academic_Start_Date__c = asd.Id;
            sa.Maiden__c = 'test';
            sa.DeltakSRP__Address_Line_1__c = 'test' ;
            sa.DeltakSRP__Address_Line_2__c = 'test';
            sa.DeltakSRP__Address_Line_3__c = 'test';
            sa.DeltakSRP__Application_Status__c = 'InProgress';
            sa.DeltakSRP__Payment_Type__c = 'No Payment';
            sa.DeltakSRP__Submitted__c = false;
            sa.LOR_Attestation_Signature__c = 'Test';
            sa.I_waive_my_right_to_access_this_report__c = 'No';
            sa.LOR_Waive_Selection_Signature__c = 'Test';
            sa.RecordTypeId = recordIdList[0].Id;

            update sa;

            DeltakSRP__Student_Letter_of_Reference__c s = [SELECT Id, LOR_Attestation_Signature__c, LOR_Waive_Selection_Signature__c, I_waive_my_right_to_access_this_report__c FROM DeltakSRP__Student_Letter_of_Reference__c LIMIT 1];

            List<RecordType> recordIdList1 = [SELECT Id FROM RecordType WHERE Name = 'Cork LOR' LIMIT 1];
            List<DeltakSRP__Student_Letter_of_Reference__c> slr = new List<DeltakSRP__Student_Letter_of_Reference__c>();
            for (Integer i = 0; i < 200; i++) {
                DeltakSRP__Student_Letter_of_Reference__c nslr = new DeltakSRP__Student_Letter_of_Reference__c();
                nslr.Name = String.valueOf(i);
                nslr.DeltakSRP__Affiliation__c = aff.Id;
                nslr.RecordTypeId = recordIdList1[0].Id;
                slr.add(nslr);
            }

            insert slr;

            for (integer y = 0; y < 200; y++) {
                DeltakSRP__Student_Letter_of_Reference_Selection__c slrsel = new DeltakSRP__Student_Letter_of_Reference_Selection__c();
                slrsel.DeltakSRP__Student_Online_Application__c = sa.Id;
                slrsel.DeltakSRP__Student_Letter_of_Reference__c = slr[y].Id;
                slrs.add(slrsel);
            }
            insert slrs;

            Set<Id> slrsSetIds = new Set<Id>();
            for (DeltakSRP__Student_Letter_of_Reference__c sl : slr) {
                slrsSetIds.add(sl.Id);
            }

            Test.stopTest();
            List<DeltakSRP__Student_Letter_of_Reference__c> ListToCompare = [SELECT Id FROM DeltakSRP__Student_Letter_of_Reference__c WHERE Program_Id__c != null AND Id IN:slrsSetIds];
            System.assertEquals(ListToCompare.size(), 200);
        }
    }

    static testMethod void testBehaviorForSoaToSlrAllNegative() {

        List<DeltakSRP__Student_Letter_of_Reference_Selection__c> slrs = new List<DeltakSRP__Student_Letter_of_Reference_Selection__c>();
        //  List<DeltakSRP__Student_Online_Application__c> soa = new List<DeltakSRP__Student_Online_Application__c>();
        List<DeltakSRP__Student_Online_Application__c> soa1 = new List<DeltakSRP__Student_Online_Application__c>();
        User u = [Select id from user where Profile.Name = 'System Administrator' and isactive = true limit 1];

        System.runAs(u) {
            RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];

            Account a = new Account();
            a.recordTypeid = rt2.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            insert a;

            contact c = new Contact();
            c.FirstName = 'fname';
            c.LastName = 'lname';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt3.Id;
            insert c;

            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            insert ap;

            DeltakSRP__Academic_Start_Date__c asd = new DeltakSRP__Academic_Start_Date__c();
            asd.DeltakSRP__Academic_Program__c = ap.id;
            asd.DeltakSRP__Start_Date__c = system.today() + 100;
            asd.DeltakSRP__End_Date__c = system.today() + 200;
            insert asd;

            Opportunity o = new Opportunity();
            o.RecordTypeId = rt1.Id;
            o.name = 'Test Opp';
            o.AccountId = a.Id;
            o.DeltakSRP__Academic_Program__c = ap.Id;
            o.StageName = 'New Inquiry';
            o.Sub_Stage__c = 'Awaiting Verification';
            o.CloseDate = system.today() + 400;
            o.DeltakSRP__Start_Date__c = system.today() + 100;
            o.Online_Application_Stage__c = 'Registered to Apply';
            o.DeltakSRP__Student__c = c.Id;

            Profile pr = [SELECT Id FROM profile WHERE name = 'System Administrator'];

            List<RecordType> recordIdList = [SELECT Id FROM RecordType WHERE Name = 'UCC - University College Cork' LIMIT 1];

            Contact aff = [SELECT Id, Name FROM Contact Where AccountId = :a.Id LIMIT 1];

            Test.startTest();

            DeltakSRP__Student_Online_Application__c sa = [SELECT Id, I_waive_my_right_to_access_this_report__c, LOR_Waive_Selection_Signature__c, LOR_Attestation_Signature__c,Program_Id__c FROM DeltakSRP__Student_Online_Application__c WHERE Program_Id__c = null LIMIT 1];

            sa.DeltakSRP__Affiliation__c = aff.Id;
            sa.DeltakSRP__Affiliation_Opportunity__c = o.Id;
            // sa.DeltakSRP__Academic_Program__c = ap.Id;
            //  sa.DeltakSRP__Academic_Start_Date__c = asd.Id;
            sa.Maiden__c = 'test';
            sa.DeltakSRP__Address_Line_1__c = 'test' ;
            sa.DeltakSRP__Address_Line_2__c = 'test';
            sa.DeltakSRP__Address_Line_3__c = 'test';
            sa.DeltakSRP__Application_Status__c = 'InProgress';
            sa.DeltakSRP__Payment_Type__c = 'No Payment';
            sa.DeltakSRP__Submitted__c = false;
            sa.LOR_Attestation_Signature__c = 'Test';
            sa.I_waive_my_right_to_access_this_report__c = 'No';
            sa.LOR_Waive_Selection_Signature__c = 'Test';
            sa.DeltakSRP__Academic_Program__c = null;
            sa.RecordTypeId = recordIdList[0].Id;

            update sa;

            DeltakSRP__Student_Letter_of_Reference__c s = [SELECT Id, LOR_Attestation_Signature__c, LOR_Waive_Selection_Signature__c, I_waive_my_right_to_access_this_report__c FROM DeltakSRP__Student_Letter_of_Reference__c LIMIT 1];

            List<RecordType> recordIdList1 = [SELECT Id FROM RecordType WHERE Name = 'Cork LOR' LIMIT 1];
            List<DeltakSRP__Student_Letter_of_Reference__c> slr = new List<DeltakSRP__Student_Letter_of_Reference__c>();
            for (Integer i = 0; i < 200; i++) {
                DeltakSRP__Student_Letter_of_Reference__c nslr = new DeltakSRP__Student_Letter_of_Reference__c();
                nslr.Name = String.valueOf(i);
                nslr.DeltakSRP__Affiliation__c = aff.Id;
                nslr.RecordTypeId = recordIdList1[0].Id;
                slr.add(nslr);
            }

            insert slr;

            for (integer y = 0; y < 200; y++) {
                DeltakSRP__Student_Letter_of_Reference_Selection__c slrsel = new DeltakSRP__Student_Letter_of_Reference_Selection__c();
                slrsel.DeltakSRP__Student_Online_Application__c = sa.Id;
                slrsel.DeltakSRP__Student_Letter_of_Reference__c = slr[y].Id;
                slrs.add(slrsel);
            }
            insert slrs;
            Set<Id> slrsSetIds = new Set<Id>();
            for (DeltakSRP__Student_Letter_of_Reference__c sl : slr) {
                slrsSetIds.add(sl.Id);
            }

            Test.stopTest();
            List<DeltakSRP__Student_Letter_of_Reference__c> ListToCompare = [SELECT Id FROM DeltakSRP__Student_Letter_of_Reference__c WHERE Program_Id__c != null AND Id IN:slrsSetIds];
            System.assertEquals(ListToCompare.size(), 0);
        }
    }

}