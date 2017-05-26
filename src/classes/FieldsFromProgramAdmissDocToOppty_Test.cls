/**
 * Created by sukumar.bindra1 on 2/16/2017.
 */
/**
 * Created by sukumar.bindra1 on 2/16/2017.
 */

@isTest(seeAllData=true)
private class FieldsFromProgramAdmissDocToOppty_Test {

    static testMethod void testBehaviorBulk() {


        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];

        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                emailencodingkey='UTF-8', lastname='Testing',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = pro.Id,
                timezonesidkey='America/Los_Angeles',
                username='newuser11@testorg.com');
        System.runAs(u2) {

            DateTime t = System.now();
            date d = Date.newInstance(t.year(), t.month(), t.day());
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;

            Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;

            Academic_Program__c ap = new Academic_Program__c();
            ap.Name = 'Test Program';
            ap.School__c = a.Id;
            insert ap;

            Academic_Program__c ap2 = new Academic_Program__c();
            ap2.Name = 'Test Program 2';
            ap2.School__c = a2.Id;
            insert ap2;

            Academic_Start_Date__c startDate = new Academic_Start_Date__c();
            startDate.Start_Date__c = d;
            startDate.Program__c = ap.Id;
            insert startDate;

            date sd = Date.newInstance(t.year(), t.month(), t.day() + 1);


            Contact c = new Contact();
            c.FirstName = 'Joe';
            c.LastName = 'Smith';
            c.Phone = '2222222222';
            c.AccountID = a.Id;
            c.Employer_Company__c = 'Disney';
            insert c;

            Contact c2 = new Contact();
            c2.FirstName = 'Chris';
            c2.LastName = 'Baker';
            c2.Phone = '2222222222';
            insert c2;

            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity;
            Map<String, Schema.RecordTypeInfo> OppRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

            Id rtId = OppRecordTypeInfo.get('SRP Opportunity').getRecordTypeId();
            System.debug(rtId);


            List<Opportunity> oppsListToInsert = new List<Opportunity>();
            for (Integer i = 0; i <= 200; i++) {
                Opportunity newOpp = new Opportunity();
                newOpp.StageName = 'New Inquiry';
                newOpp.CloseDate = Date.today().addDays(3);
                newOpp.Name = 'Test_' + String.valueOf(i);
                newOpp.RecordTypeId = rtId;
                newOpp.AccountID = a.Id;
                newOpp.Student__c = c.Id;
                newOpp.Start_Date__c = sd;
                oppsListToInsert.add(newOpp);
            }
            insert oppsListToInsert;

            Schema.DescribeSObjectResult padSchema = Schema.SObjectType.DeltakSRP__Program_Admission_Document__c;
            Map<String, Schema.RecordTypeInfo> padRecordTypeInfo = padSchema.getRecordTypeInfosByName();

            Id padrtId = padRecordTypeInfo.get('Application Fee').getRecordTypeId();
            System.debug(padrtId);


            List<DeltakSRP__Program_Admission_Document__c> progAdmListToInsert = new List<DeltakSRP__Program_Admission_Document__c>();
            for (Integer i = 0; i <= 200; i++) {
                DeltakSRP__Program_Admission_Document__c progAdmDoc = new DeltakSRP__Program_Admission_Document__c();


                progAdmDoc.DeltakSRP__Document_Name__c = 'Application ' + String.ValueOf(i);
                progAdmDoc.DeltakSRP__Opportunity__c = oppsListToInsert[i].Id;
                progAdmDoc.DeltakSRP__Order__c = i;
                progAdmDoc.DeltakSRP__Comments__c = 'This is a test application';
                progAdmDoc.DeltakSRP__Date_Received__c = d;
                progAdmDoc.RecordTypeId = padrtId;
                progAdmDoc.DeltakSRP__Waived__c = false;
                progAdmListToInsert.add(progAdmDoc);
            }
            insert progAdmListToInsert;
            ProgramAdmissionDocumentToOpptyMapping__c fieldMapping = new ProgramAdmissionDocumentToOpptyMapping__c();
            fieldMapping.Name = 'FieldMapping';
            fieldMapping.ProgramAdmissionDocumentField__c = 'DeltakSRP__Waived__c';
            fieldMapping.OpportunityField__c = 'Application_Fee_Waiver__c';
            insert fieldMapping;


            List<DeltakSRP__Program_Admission_Document__c> progAdmDocListToUpdate = new List<DeltakSRP__Program_Admission_Document__c>();
            Integer y = 0;
            for (DeltakSRP__Program_Admission_Document__c progAdminDoc : progAdmListToInsert) {
                y++;

                progAdminDoc.DeltakSRP__Waived__c = true;
                progAdmDocListToUpdate.add(progAdminDoc);
            }

            update progAdmDocListToUpdate;

            List<Opportunity> oppsListWithWaivedText = [SELECT Id, Application_Fee_Waiver__c FROM Opportunity WHERE Application_Fee_Waiver__c = true];
            System.assertEquals(oppsListWithWaivedText.size(), 201);

        }
    }



    static testMethod void testBehaviorBulkNegative() {


        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];

        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                emailencodingkey='UTF-8', lastname='Testing',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = pro.Id,
                timezonesidkey='America/Los_Angeles',
                username='newuser11@testorg.com');

        System.runAs(u2) {
            DateTime t = System.now();
            date d = Date.newInstance(t.year(), t.month(), t.day());
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;

            Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;

            Academic_Program__c ap = new Academic_Program__c();
            ap.Name = 'Test Program';
            ap.School__c = a.Id;
            insert ap;


            Academic_Program__c ap2 = new Academic_Program__c();
            ap2.Name = 'Test Program 2';
            ap2.School__c = a2.Id;
            insert ap2;

            Academic_Start_Date__c startDate = new Academic_Start_Date__c();
            startDate.Start_Date__c = d;
            startDate.Program__c = ap.Id;
            insert startDate;

            date sd = Date.newInstance(t.year(), t.month(), t.day() + 1);


            Contact c = new Contact();
            c.FirstName = 'Joe';
            c.LastName = 'Smith';
            c.Phone = '2222222222';
            c.AccountID = a.Id;
            c.Employer_Company__c = 'Disney';
            insert c;

            Contact c2 = new Contact();
            c2.FirstName = 'Chris';
            c2.LastName = 'Baker';
            c2.Phone = '2222222222';
            insert c2;

            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity;
            Map<String, Schema.RecordTypeInfo> OppRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();


            Id rtId = OppRecordTypeInfo.get('SRP Opportunity').getRecordTypeId();
            System.debug(rtId);


            List<Opportunity> oppsListToInsert = new List<Opportunity>();
            for (Integer i = 0; i <= 200; i++) {
                Opportunity newOpp = new Opportunity();
                newOpp.StageName = 'New Inquiry';
                newOpp.CloseDate = Date.today().addDays(3);
                newOpp.Name = 'Test_' + String.valueOf(i);
                newOpp.RecordTypeId = rtId;
                newOpp.AccountID = a.Id;
                newOpp.Student__c = c.Id;
                newOpp.Start_Date__c = sd;
                oppsListToInsert.add(newOpp);
            }
            insert oppsListToInsert;

            Schema.DescribeSObjectResult padSchema = Schema.SObjectType.DeltakSRP__Program_Admission_Document__c;
            Map<String, Schema.RecordTypeInfo> padRecordTypeInfo = padSchema.getRecordTypeInfosByName();
            Id padrtId = padRecordTypeInfo.get('Application').getRecordTypeId();
            System.debug(padrtId);


            List<DeltakSRP__Program_Admission_Document__c> progAdmListToInsert = new List<DeltakSRP__Program_Admission_Document__c>();
            for (Integer i = 0; i <= 200; i++) {
                DeltakSRP__Program_Admission_Document__c progAdmDoc = new DeltakSRP__Program_Admission_Document__c();
                progAdmDoc.DeltakSRP__Document_Name__c = 'Application ' + String.ValueOf(i);
                progAdmDoc.DeltakSRP__Opportunity__c = oppsListToInsert[i].Id;
                progAdmDoc.DeltakSRP__Order__c = i;
                progAdmDoc.DeltakSRP__Comments__c = 'This is a test application';
                progAdmDoc.DeltakSRP__Date_Received__c = d;
                progAdmDoc.RecordTypeId = padrtId;
                progAdmDoc.DeltakSRP__Waived__c = false;
                progAdmListToInsert.add(progAdmDoc);
            }
            insert progAdmListToInsert;
            ProgramAdmissionDocumentToOpptyMapping__c fieldMapping = new ProgramAdmissionDocumentToOpptyMapping__c();
            fieldMapping.Name = 'FieldMapping';
            fieldMapping.ProgramAdmissionDocumentField__c = 'DeltakSRP__Waived__c';
            fieldMapping.OpportunityField__c = 'Application_Fee_Waiver__c';
            insert fieldMapping;

            List<DeltakSRP__Program_Admission_Document__c> progAdmDocListToUpdate = new List<DeltakSRP__Program_Admission_Document__c>();
            Integer y = 0;
            for (DeltakSRP__Program_Admission_Document__c progAdminDoc : progAdmListToInsert) {
                y++;
                progAdminDoc.DeltakSRP__Waived__c = true;
                progAdmDocListToUpdate.add(progAdminDoc);
            }
            update progAdmDocListToUpdate;
            List<Opportunity> oppsListWithWaivedText = [SELECT Id, Application_Fee_Waiver__c FROM Opportunity WHERE Application_Fee_Waiver__c = true];
            System.assertEquals(oppsListWithWaivedText.size(), 0);

        }
    }



}