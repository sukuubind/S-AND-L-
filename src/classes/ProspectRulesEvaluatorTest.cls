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
@isTest(seealldata=true)
private class ProspectRulesEvaluatorTest {
	static testMethod void testRefineScore_Case(){
		
       RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            RecordType rt5 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Help' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            insert a;
            
            contact c = new Contact();
            c.FirstName = 'fname1';
            c.LastName = 'lname1';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt4.Id;
            insert c;
            
            
            PRO_Rule__c rule = new PRO_Rule__c();
            rule.Academic_Institution__c = a.id;
            rule.Active__c = true;
            insert rule;
            
            List<PRO_Rule_Set__c> rulesetList = new List<PRO_Rule_Set__c>();
            PRO_Rule_Set__c ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'Account';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'test account';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 1;
            rulesetList.add(ruleset);
            
           /* ruleset.Object_API_Name__c = 'Account';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'test account';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 2;
            rulesetList.add(ruleset);*/
            
            insert rulesetList; 
            rule.Formula__c = '1';
            update rule;
        
            
            Team__c t = new Team__c();
            t.Team_Rule__c = rule.id;
            t.Active__c = true;
            t.Team_Account__c = a.id;
            insert t;
            
           
            
            Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
        
            User u = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
            insert u;
            User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser112@testorg.com'); 
            insert u2;        
                           
            Team_Member__c tm = new Team_Member__c();
            tm.Which_Team__c = t.id;
            tm.who_id__c = u.id;
            tm.allocation__c = 0.75;
            tm.allocation_counter__c = 7.5;
            insert tm;
            
            Team_Member__c tm2 = new Team_Member__c();
            tm2.Which_Team__c = t.id;
            tm2.who_id__c = u2.id;
            tm2.allocation__c = 0.25;
            tm2.allocation_counter__c = 2.5;
            insert tm2;
            
            Case c2 = new Case();
            c2.RecordTypeId = rt5.Id;
            //c2.Name = 'Test Case';
            //c2.DeltakSRP__Student__c = c.Id;
            c2.ContactId = c.Id;
            c2.AccountId = a.Id;
            c2.Subject = 'prospect not working';
            c2.Description = 'prospect not working';
            
            List<Case> oplist = new List<Case>();
            oplist.add(c2);
            Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
            Id prospectuserid = setting.PROspect_User_ID__c;
            for(integer i=0; i<2; i++){
                c2 = new Case();
                c2.RecordTypeId = rt5.Id;
            //c2.Name = 'Test Case';
            c2.ContactId = c.Id;
            c2.ContactId = c.Id;
            c2.AccountId = a.Id;
            c2.Subject = 'prospect not working';
            c2.Description = 'prospect not working';
                oplist.add(c2);
            }   
            
            insert oplist;
            List<Case> clist = [Select OwnerId, Id, IsDeleted, CaseNumber, ContactId, AccountId, Type, RecordTypeId, Status, Reason, Origin, Subject, Priority, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Lead_Failure__c, Sub_Type__c, Person__c, Budget__c, Campaign__c, Category__c, Course_Section__c, Course__c, Date_Committed__c, Desired_Due_Date__c, Instructor__c, Length_of_Campaign__c, NA2_Id__c, Requested_By__c, Resolution__c, Sub_Category__c, Vendor_Contact_Email__c, Vendor_Contact_Name__c, Vendor_Contact_Phone__c, Vendor__c, CaseNumber__c, Closed_Date_c__c, Created_Date__c, Last_Modified_Date__c, Notify_Affiliation_of_Case_Closed__c, Partner__c, Send_Email_Notification_to_Affiliation__c, Requestor__c, Engage_Type__c, Engage_Status__c, Next_Steps__c, Engage_Developer_Assigned__c, Begin_Development__c, Scheduled_for_Release__c, DRI__c, Hours__c, Case_Category__c, Cost__c, Anticipated_Hours__c, M_S_Internal_Date__c, Estimated_Dev_Time__c, Estimated_Design_Time__c, Release_Priority__c, Caller_Name__c, Development_Status__c, Estd_Design_Time__c, Estimated_Development_Time__c, Assigned_To__c, Next_Step__c, Begin_Development_Date__c, Current_Release__c, Release_Version__c, Release_Scheduled__c, Actual_Release_Date__c, Development_Priority__c, Affects_Product__c, Module__c, Issue_Priority__c, Issue_Type__c, Platform__c, Caller_Email__c, Caller_Phone_Number__c, DeltakSRP__PotentialLiability__c, n2de__Action__c, n2de__Is_distributed__c, n2de__Is_reassigned__c, n2de__Is_trigger_enabled__c, n2de__Is_triggered__c, n2de__Last_distributed__c, n2de__Last_reassigned__c, Escalated_to_Campus__c, Notify_Caller_Email__c, New_Case_comment__c, Related_Objects__c, Related_Areas__c, Jira_Story__c, Hours_Spent__c, Escalation_Code__c, Days_Since_Last_Update__c, Case_Affiliation_Name__c, Current_Page_URL__c, JIRA_Issue_No__c, JIRA_Link__c, JIRA_Ticket_Exists__c, Activity_Type__c, Case_Comment_Created_By__c, Case_Comment__c, Case_Creation__c, Cherwell_Case_ID__c, Email_Counter__c, Email__c, sendAttachment__c, Engage_URL__c FROM Case  where ContactId = :c.id];
            List<Id> caseIdLIst = new LIst<Id>();
            for(Case o : clist){
                caseIdLIst.add(o.id);
            }
            
            PROspectLogHandler handler = new ProspectLogHandler();
            handler.createProspectLogRecordForCase(clist, clist);
            List<PRO_Log__c> prologList = [Select Account__r.Name, PRO_Team__r.ESC_Exempt__c, Team_Member__c, SystemModstamp, Status__c, Process_This_Log__c, SRP_Term__c, SRP_Specialization__c, SRP_Program__c, SRM_Term__c, SRM_Specialization__c, SRM_Program__c, Regular_Not_Escalated__c, Previous_Pro_Log__c, PRO_Team__c, OwnerId, Opportunity__c, Next_Run_Time__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Contact__c, Campaign__c, Account__c, Case__c From PRO_Log__c where Case__c IN :caseIdLIst];
            
            
            List<PRO_Log__c> refinedList = ProspectRulesEvaluator_CaseMgmt.refineTheScope(proLogList);
           
            handler.closeAllLogsForTheseOppty(caseIdLIst, 'Case'); 
            
    
	}
    static testMethod void testRefineScope() {
       RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            insert a;
            
            contact c = new Contact();
            c.FirstName = 'fname1';
            c.LastName = 'lname1';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt4.Id;
            insert c;
            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            insert ap;
            
            PRO_Rule__c rule = new PRO_Rule__c();
            rule.Academic_Institution__c = a.id;
            rule.Active__c = true;
            insert rule;
            
            List<PRO_Rule_Set__c> rulesetList = new List<PRO_Rule_Set__c>();
            PRO_Rule_Set__c ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'Account';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'test account';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 1;
            rulesetList.add(ruleset);
            
            ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'DeltakSRP__Academic_Program__c';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'abcd';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 2;
            rulesetList.add(ruleset);
            
            insert rulesetList; 
            rule.Formula__c = '(AND,1,2)';
            update rule;
        
            
            Team__c t = new Team__c();
            t.Team_Rule__c = rule.id;
            t.Active__c = true;
            t.Team_Account__c = a.id;
            insert t;
            
           
            
            Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
        
            User u = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
            insert u;
            User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser112@testorg.com'); 
            insert u2;        
                           
            Team_Member__c tm = new Team_Member__c();
            tm.Which_Team__c = t.id;
            tm.who_id__c = u.id;
            tm.allocation__c = 0.75;
            tm.allocation_counter__c = 7.5;
            insert tm;
            
            Team_Member__c tm2 = new Team_Member__c();
            tm2.Which_Team__c = t.id;
            tm2.who_id__c = u2.id;
            tm2.allocation__c = 0.25;
            tm2.allocation_counter__c = 2.5;
            insert tm2;
            
            Opportunity o2 = new Opportunity();
            o2.RecordTypeId = rt3.Id;
            o2.Name = 'Test Opportunity';
            o2.StageName = 'New Inquiry';
            o2.CloseDate = system.today()+100;
            o2.DeltakSRP__Student__c = c.Id;
            o2.Student__c = c.Id;
            o2.DeltakSRP__Lead_Source_ID__c = '12345';
            o2.DeltakSRP__Academic_Program__c = ap.Id;
            o2.AccountId = a.Id;
            
            List<Opportunity> oplist = new List<Opportunity>();
            oplist.add(o2);
            Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
            Id prospectuserid = setting.PROspect_User_ID__c;
            for(integer i=0; i<2; i++){
                o2 = new Opportunity();
                o2.RecordTypeId = rt3.Id;
                o2.Name = 'Test Opportunity';
                o2.StageName = 'New Inquiry';
                o2.CloseDate = system.today()+100;
                o2.DeltakSRP__Student__c = c.Id;
                o2.Student__c = c.Id;
                o2.DeltakSRP__Lead_Source_ID__c = '12345';
                o2.DeltakSRP__Academic_Program__c = ap.Id;
                o2.AccountId = a.Id;
                o2.OwnerId = prospectuserid;
                oplist.add(o2);
            }   
            
            insert oplist;
            List<Opportunity> olist = [Select Student__c, Program__c, Specialization__c, Academic_Start_Date__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, CampaignId, Campaign.ParentId, Email__c, DeltakSRP__Email__c, id, RecordTypeId, Name, StageName, CloseDate, DeltakSRP__Student__c, DeltakSRP__Lead_Source_ID__c, DeltakSRP__Academic_Program__c, AccountId, Ownerid from Opportunity where DeltakSRP__Student__c = :c.id];
            List<Id> opptyIdLIst = new LIst<Id>();
            for(Opportunity o : olist){
                opptyIdLIst.add(o.id);
            }
            List<PRO_Log__c> prologList = [Select Account__r.Name, PRO_Team__r.ESC_Exempt__c, Team_Member__c, SystemModstamp, Status__c, Process_This_Log__c, SRP_Term__c, SRP_Specialization__c, SRP_Program__c, SRM_Term__c, SRM_Specialization__c, SRM_Program__c, Regular_Not_Escalated__c, Previous_Pro_Log__c, PRO_Team__c, OwnerId, Opportunity__c, Next_Run_Time__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Contact__c, Campaign__c, Account__c From PRO_Log__c where Opportunity__c IN :opptyIdLIst];
            System.AssertNotEquals(0, prologList.size());
            List<PRO_Log__c> refinedList = ProspectRulesEvaluator.refineTheScope(proLogList);
            System.AssertEquals(refinedList.size(),proLogList.size());
            ProspectLogHandler handler = new ProspectLogHandler();
            handler.closeAllLogsForTheseOppty(opptyIdLIst, 'Opportunity'); 
            Opportunity o = oplist[0];
           // o.OwnerId = UserInfo.getUserId();
           // Database.update(o);
            o.OwnerId = setting.PROspect_User_ID__c;
            Database.update(o);
            o.StageName = 'Appointment Scheduled';
            o.DeltakSRP__Sub_Stage__c = 'Phone';
            Database.update(o);
            u2.isActive = false;
            //update u2;
    }
    static testMethod void testFindTeams(){
         RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            insert a;
            
            contact c = new Contact();
            c.FirstName = 'fname1';
            c.LastName = 'lname1';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt4.Id;
            insert c;
            DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
            ap.Name = 'abcd';
            ap.DeltakSRP__School__c = a.id;
            ap.DeltakSRP__Degree_Type__c = 'Certificate';
            ap.DeltakSRP__Abbrev__c = 'CID';
            ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
            insert ap;
            
            PRO_Rule__c rule = new PRO_Rule__c();
            rule.Academic_Institution__c = a.id;
            rule.Active__c = true;
            insert rule;
            
            List<PRO_Rule_Set__c> rulesetList = new List<PRO_Rule_Set__c>();
            PRO_Rule_Set__c ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'Account';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'test account';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 1;
            rulesetList.add(ruleset);
            
            ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'DeltakSRP__Academic_Program__c';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'abcd';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 2;
            rulesetList.add(ruleset);
            
            insert rulesetList; 
            rule.Formula__c = '(AND,1,2)';
            update rule;
        
            
            Team__c t = new Team__c();
            t.Team_Rule__c = rule.id;
            t.Active__c = true;
            t.Team_Account__c = a.id;
            insert t;
            
           
            
            Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
        
            User u = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
            insert u;
            User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser112@testorg.com'); 
            insert u2;        
                           
            Team_Member__c tm = new Team_Member__c();
            tm.Which_Team__c = t.id;
            tm.who_id__c = u.id;
            tm.allocation__c = 0.75;
            tm.allocation_counter__c = 7.5;
            insert tm;
            
            Team_Member__c tm2 = new Team_Member__c();
            tm2.Which_Team__c = t.id;
            tm2.who_id__c = u2.id;
            tm2.allocation__c = 0.25;
            tm2.allocation_counter__c = 2.5;
            insert tm2;
            
            Opportunity o2 = new Opportunity();
            o2.RecordTypeId = rt3.Id;
            o2.Name = 'Test Opportunity';
            o2.StageName = 'New Inquiry';
            o2.CloseDate = system.today()+100;
            o2.DeltakSRP__Student__c = c.Id;
            o2.Student__c = c.Id;
            o2.DeltakSRP__Lead_Source_ID__c = '12345';
            o2.DeltakSRP__Academic_Program__c = ap.Id;
            o2.AccountId = a.Id;
            
            List<Opportunity> oplist = new List<Opportunity>();
            oplist.add(o2);
            Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
            Id prospectuserid = setting.PROspect_User_ID__c;
           /* for(integer i=0; i<10; i++){
                o2 = new Opportunity();
                o2.RecordTypeId = rt3.Id;
                o2.Name = 'Test Opportunity';
                o2.StageName = 'New Inquiry';
                o2.CloseDate = system.today()+100;
                o2.DeltakSRP__Student__c = c.Id;
                o2.Student__c = c.Id;
                o2.DeltakSRP__Lead_Source_ID__c = '12345';
                o2.DeltakSRP__Academic_Program__c = ap.Id;
                o2.AccountId = a.Id;
                o2.OwnerId = prospectuserid;
                oplist.add(o2);
            }   */
            
            insert oplist;
            List<Opportunity> olist = [Select Student__c, Program__c, Specialization__c, Academic_Start_Date__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, CampaignId, Campaign.ParentId, Email__c, DeltakSRP__Email__c, id, RecordTypeId, Name, StageName, CloseDate, DeltakSRP__Student__c, DeltakSRP__Lead_Source_ID__c, DeltakSRP__Academic_Program__c, AccountId, Ownerid from Opportunity where DeltakSRP__Student__c = :c.id];
            List<Id> opptyIdLIst = new LIst<Id>();
            for(Opportunity o : olist){
                opptyIdLIst.add(o.id);
            }
            PROspectLogHandler handler = new ProspectLogHandler();
            handler.createProspectLogRecordForOpportunity(olist, false);
            List<PRO_Log__c> prologList = [Select Account__r.Name, PRO_Team__r.ESC_Exempt__c, Team_Member__c, SystemModstamp, Status__c, Process_This_Log__c, SRP_Term__c, SRP_Specialization__c, SRP_Program__c, SRM_Term__c, SRM_Specialization__c, SRM_Program__c, Regular_Not_Escalated__c, Previous_Pro_Log__c, PRO_Team__c, OwnerId, Opportunity__c, Next_Run_Time__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Contact__c, Campaign__c, Account__c From PRO_Log__c where Opportunity__c IN :opptyIdLIst];
            
            Map<Opportunity, Team__c> opptyToteam = ProspectRulesEvaluator.findTeams(prologList);
            
            Map<Id, Id> opptyIdToTeamMemberId = new Map<Id, Id>();
            for(Opportunity o : olist){
                 opptyIdToTeamMemberId.put(o.Id, tm2.Id);
            }
            
            handler.createLogRecords(null, prologList, opptyIdToTeamMemberId, false);
            handler.createLogRecords(null, prologList, opptyIdToTeamMemberId, true);
            
            
           delete tm2;
           tm.allocation__c = .15;
           update tm; 
            
            
            
            
    }
    
    static testMethod void testFindTeams_Case(){
    	
         RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            RecordType rt5 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Help' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            insert a;
            
            contact c = new Contact();
            c.FirstName = 'fname1';
            c.LastName = 'lname1';
            c.Email = 'testemail@salesforce.com';
            c.Phone = '1234567890';
            c.AccountId = a.Id;
            c.RecordTypeId = rt4.Id;
            insert c;
            
            
            PRO_Rule__c rule = new PRO_Rule__c();
            rule.Academic_Institution__c = a.id;
            rule.Active__c = true;
            insert rule;
            
            List<PRO_Rule_Set__c> rulesetList = new List<PRO_Rule_Set__c>();
            PRO_Rule_Set__c ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'Account';
            ruleset.Field_Name__c = 'Name';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'test account';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 1;
            rulesetList.add(ruleset);
            
            ruleset = new PRO_Rule_Set__c();
            ruleset.Object_API_Name__c = 'Case';
            ruleset.Field_Name__c = 'Type';
            ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
            ruleset.Value__c = 'PROspect';
            ruleset.Rule__c = rule.id;
            ruleset.Sequence__c = 2;
            rulesetList.add(ruleset);
            
            insert rulesetList; 
            rule.Formula__c = '(AND,1,2)';
            update rule;
        
            
            Team__c t = new Team__c();
            t.Team_Rule__c = rule.id;
            t.Active__c = true;
            t.Team_Account__c = a.id;
            insert t;
            
           
            
            Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
        
            User u = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
            insert u;
            User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser112@testorg.com'); 
            insert u2;        
                           
            Team_Member__c tm = new Team_Member__c();
            tm.Which_Team__c = t.id;
            tm.who_id__c = u.id;
            tm.allocation__c = 0.75;
            tm.allocation_counter__c = 7.5;
            insert tm;
            
            Team_Member__c tm2 = new Team_Member__c();
            tm2.Which_Team__c = t.id;
            tm2.who_id__c = u2.id;
            tm2.allocation__c = 0.25;
            tm2.allocation_counter__c = 2.5;
            insert tm2;
            
            Case c2 = new Case();
            c2.RecordTypeId = rt5.Id;
            //c2.Name = 'Test Case';
            //c2.DeltakSRP__Student__c = c.Id;
            c2.ContactId = c.Id;
            c2.AccountId = a.Id;
            c2.Subject = 'Prospect not working';
            c2.Description = 'Prospect not working';
            
            List<Case> oplist = new List<Case>();
            oplist.add(c2);
            Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
            Id prospectuserid = setting.PROspect_User_ID__c;
            for(integer i=0; i<2; i++){
                c2 = new Case();
                c2.RecordTypeId = rt5.Id;
            //c2.Name = 'Test Case';
            c2.ContactId = c.Id;
            c2.ContactId = c.Id;
            c2.AccountId = a.Id;
            c2.Subject = 'Prospect not working';
            c2.Description = 'Prospect not working';
                oplist.add(c2);
            }   
            
            insert oplist;
            List<Case> clist = [Select Id, IsDeleted, CaseNumber, ContactId, AccountId, Type, RecordTypeId, Status, Reason, Origin,  Subject, Priority, Description, IsClosed, ClosedDate,  OwnerId,  CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,Lead_Failure__c, Sub_Type__c, Person__c, Budget__c, Campaign__c, Category__c, Course_Section__c, Course__c, Date_Committed__c, Desired_Due_Date__c, Instructor__c, Length_of_Campaign__c, NA2_Id__c, Requested_By__c, Resolution__c, Sub_Category__c, Vendor_Contact_Email__c, Vendor_Contact_Name__c, Vendor_Contact_Phone__c, Vendor__c, CaseNumber__c, Closed_Date_c__c, Created_Date__c, Last_Modified_Date__c, Notify_Affiliation_of_Case_Closed__c, Partner__c, Send_Email_Notification_to_Affiliation__c, Requestor__c, Engage_Type__c, Engage_Status__c, Next_Steps__c, Engage_Developer_Assigned__c, Begin_Development__c, Scheduled_for_Release__c, DRI__c, Hours__c, Case_Category__c, Cost__c, Anticipated_Hours__c, M_S_Internal_Date__c, Estimated_Dev_Time__c, Estimated_Design_Time__c, Release_Priority__c, Caller_Name__c, Development_Status__c, Estd_Design_Time__c, Estimated_Development_Time__c, Assigned_To__c, Next_Step__c, Begin_Development_Date__c, Current_Release__c, Release_Version__c, Release_Scheduled__c, Actual_Release_Date__c, Development_Priority__c, Affects_Product__c, Module__c, Issue_Priority__c, Issue_Type__c, Platform__c, Caller_Email__c, Caller_Phone_Number__c, DeltakSRP__PotentialLiability__c, n2de__Action__c, n2de__Is_distributed__c, n2de__Is_reassigned__c, n2de__Is_trigger_enabled__c, n2de__Is_triggered__c, n2de__Last_distributed__c, n2de__Last_reassigned__c, Escalated_to_Campus__c, Notify_Caller_Email__c, New_Case_comment__c, Related_Objects__c, Related_Areas__c, Jira_Story__c, Hours_Spent__c, Escalation_Code__c, Days_Since_Last_Update__c, Case_Affiliation_Name__c, Current_Page_URL__c, JIRA_Issue_No__c, JIRA_Link__c, JIRA_Ticket_Exists__c, Activity_Type__c, Case_Comment_Created_By__c, Case_Comment__c, Case_Creation__c, Cherwell_Case_ID__c, Email_Counter__c, Email__c, sendAttachment__c, Engage_URL__c FROM Case  where ContactId = :c.id];
            List<Id> caseIdLIst = new LIst<Id>();
            for(Case o : clist){
                caseIdLIst.add(o.id);
            }
            PROspectLogHandler handler = new ProspectLogHandler();
            handler.createProspectLogRecordForCase(clist, clist);
            List<PRO_Log__c> prologList = [Select Account__r.Name, PRO_Team__r.ESC_Exempt__c, Team_Member__c, SystemModstamp, Status__c, Process_This_Log__c, SRP_Term__c, SRP_Specialization__c, SRP_Program__c, SRM_Term__c, SRM_Specialization__c, SRM_Program__c, Regular_Not_Escalated__c, Previous_Pro_Log__c, PRO_Team__c, OwnerId, Opportunity__c, Next_Run_Time__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Contact__c, Campaign__c, Account__c, Case__c From PRO_Log__c where Case__c IN :caseIdLIst];
            
            Map<Case, Team__c> opptyToteam = ProspectRulesEvaluator_CaseMgmt.findTeams(prologList);
            
            Map<Id, Id> caseIdToTeamMemberId = new Map<Id, Id>();
            for(Case o : clist){
                 caseIdToTeamMemberId.put(o.Id, tm2.Id);
            }
            
            handler.createLogRecords_case(null, prologList, caseIdToTeamMemberId, false);
            handler.createLogRecords_case(null, prologList, caseIdToTeamMemberId, true);
            
            
           delete tm2;
           tm.allocation__c = .15;
           update tm; 
            
            
            
            
    
    }
    
    
    
    static testMethod void testFindNextRunTime() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            a.PRO_Distribution_Start_Hours__c = '9';
            a.PRO_Distribution_Hours_Start_Minutes__c = '0';
            a.PRO_Distribution_End_Hours__c = '17';
            a.PRO_Distribution_Hours_End_Minutes__c = '0';
            a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
            insert a;
            Datetime currentTimeStamp = Datetime.newInstance(2015, 10, 12, 18, 0, 0);
            ProspectLogHandler handler = new ProspectLogHandler();
            Datetime nextRunTime = handler.findNextRunTime(handler.accountIdToDistrbutionHourSetting.get(a.id), currentTimeStamp);
            System.AssertNotEquals(null, nextRunTime);
            
    }
    static testMethod void testFindNewStatus(){
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
            RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
            RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
            RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
            
            
            Account a = new Account();
            a.recordTypeid = rt1.Id;
            a.Abbreviation__c = 'TAC';
            a.name = 'test account';
            a.Prospect_Enabled__c = true;
            a.PRO_Distribution_Start_Hours__c = '9';
            a.PRO_Distribution_Hours_Start_Minutes__c = '0';
            a.PRO_Distribution_End_Hours__c = '17';
            a.PRO_Distribution_Hours_End_Minutes__c = '0';
            a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
            insert a;
            
            ProspectLogHandler handler = new ProspectLogHandler();
            System.AssertEquals(ProspectConstants.LOG_STATUS_PROCD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, handler.accountIdToDistrbutionHourSetting.get(a.id)));
            System.AssertEquals(ProspectConstants.LOG_STATUS_CLOSD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, null));
            System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_PROCD, null));
            System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_ESCTD, null));
            
            
            
            
            
            
            
    }
    
}