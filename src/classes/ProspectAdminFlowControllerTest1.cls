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
private class ProspectAdminFlowControllerTest1 {

    static testMethod void testAddRuleSet() {
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        PageReference pageRef = Page.ProspectAdminFlowRuleCreate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);  

        Test.startTest();
        testObj.ruleId = rl.id;
        testObj.ruleSetsToInsert= new List<PRO_Rule_Set__c>();
        
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        testobj.sequenceNo.fieldValue = '1';
        testobj.objType.fieldValue = 'Account';
        testobj.fieldName.fieldValue = 'Organization Name';
        testobj.operator.fieldValue = 'EQUALS';
        testobj.value.fieldValue = 'test account';
        testObj.ruleId = rl.id;
        testobj.addRuleSet();
        System.assertEquals(true, testobj.validated); 
        System.assertEquals(1,testObj.ruleSetsToInsert.size());
        testObj.getAddedRuleSets(rl.id);
        //System.assertEquals(1,testObj.addedRuleSets.size());
        Test.stopTest();
        
    }
    
    static testMethod void testAddRuleSetFail1() {
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        PageReference pageRef = Page.ProspectAdminFlowRuleCreate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);  

        Test.startTest();
        testObj.ruleId = rl.id;
        testObj.ruleSetsToInsert= new List<PRO_Rule_Set__c>();
        
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        testobj.sequenceNo.fieldValue = '';
        testobj.objType.fieldValue = 'Account';
        testobj.fieldName.fieldValue = 'Organization Name';
        testobj.operator.fieldValue = 'EQUALS';
        testobj.value.fieldValue = 'test account';
        testObj.ruleId = rl.id;
        testobj.addRuleSet();
        System.assertEquals(false, testobj.validated); 
        System.assertEquals(0,testObj.ruleSetsToInsert.size());
        Test.stopTest();
        
    }
    
    static testMethod void testAddRuleSetFail2() {
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        PageReference pageRef = Page.ProspectAdminFlowRuleCreate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);  

        Test.startTest();
        testObj.ruleId = rl.id;
        testObj.ruleSetsToInsert= new List<PRO_Rule_Set__c>();
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        testobj.sequenceNo.fieldValue = '1';
        testobj.objType.fieldValue = 'Account';
        testobj.fieldName.fieldValue = 'Organization Name';
        testobj.operator.fieldValue = 'EQUALS';
        testobj.value.fieldValue = 'test account';
        testObj.ruleId = rl.id;
        testobj.addRuleSet();
        system.debug('ruleSetsToInsert-->'+testObj.ruleSetsToInsert);
        System.assertEquals(1,testObj.ruleSetsToInsert.size());
        testObj.getAddedRuleSets(rl.id);
       //   System.assertEquals(1,testObj.addedRuleSets.size());
        
        testobj.sequenceNo.fieldValue = '2';
        testobj.objType.fieldValue = 'Academic Start Date';
        testobj.fieldName.fieldValue = 'Program';
        testobj.operator.fieldValue = 'EQUALS';
        testobj.value.fieldValue = 'ABC';
        testObj.ruleId = rl.id;
        testobj.addRuleSet();
        System.assertEquals(1,testObj.ruleSetsToInsert.size());
        testObj.getAddedRuleSets(rl.id);
      //    System.assertEquals(1,testObj.addedRuleSets.size());
        Test.stopTest();
        
    }
    
   static testMethod void testRemoveRuleSet() {
        
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
            
        
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Abbreviation__c';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'TAC';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        insert rs;
        System.debug('rs-->'+rs);
        
        PageReference pageRef = Page.ProspectAdminFlowRuleCreate;
        pageRef.getParameters().put('ruleSetid',rs.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        

        Test.startTest();
        List<PRO_Rule_Set__c> rSets = [Select t.id, t.Sequence__c, t.Object_Name__c, t.Field_Name__c, t.Operator__c, t.Value__c, t.Rule__r.Formula__c 
                                       From PRO_Rule_Set__c t 
                                       where t.Rule__c =: rl.id
                                       order by t.Sequence__c];
        system.debug('rSets-->'+rSets);
        System.assertEquals(1,rSets.size());
        //testObj.addedRuleSets = new List<ruleSets>();
        testobj.removeRuleSet();
        List<PRO_Rule_Set__c> rSets1 = [Select t.id, t.Sequence__c, t.Object_Name__c, t.Field_Name__c, t.Operator__c, t.Value__c, t.Rule__r.Formula__c 
                                       From PRO_Rule_Set__c t 
                                       where t.Rule__c =: rl.id
                                       order by t.Sequence__c];
        system.debug('rSets-->'+rSets1);
        System.assertEquals(0,rSets1.size());
        Test.stopTest();
        
    }
    
     static testMethod void testStep3ChooseTeam() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Name';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'test account';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs);
        
        PRO_Rule_Set__c rs1 = new PRO_Rule_Set__c();
        rs1.Sequence__c = 2;
        rs1.Object_Name__c = 'Account';
        rs1.Field_Name__c = 'Abbreviation__c';
        rs1.Operator__c = 'EQUALS';
        rs1.Value__c = 'TAC';
        rs1.Rule__c = rl.id;
        rs1.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs1);
        System.debug('rs1-->'+rs1);
        
        if(prs!=null && prs.size()>0)
        {
             Database.insert(prs,true);
        }
        
        Team__c t = new Team__c(); 
        String longName = 'AaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaa';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = true;
        t.Team_Rule__c = rl.id;
        insert t;
        testobj.teamId = t.id;
        testObj.teamName = t.Team_Name__c;
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3;          
                    system.debug('Users-->'+u1.id+ ' -->'+u2.id+ ' -->'+u3.id+ ' -->');
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        insert doa;
        
        List<Campus_Contacts__c> ccs = new List<Campus_Contacts__c>();
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Employee__c = u1.id;
        cc1.Title__c = 'Program Manager';
        cc1.Organization__c = a.id;
        
        ccs.add(cc1);
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Employee__c = u2.id;
        cc2.Title__c = 'Program Manager';
        cc2.Organization__c = a.id;
        
        ccs.add(cc2);
        
        Campus_Contacts__c cc3 = new Campus_Contacts__c();
        cc3.Employee__c = u3.id;
        cc3.Title__c = 'Program Manager';
        cc3.Organization__c = a.id;
        
        ccs.add(cc3);
        
        Campus_Contacts__c cc4 = new Campus_Contacts__c();
        cc4.Employee__c = doa.id;
        cc4.Title__c = 'Director of Admission';
        cc4.Organization__c = a.id;
        
        ccs.add(cc4);
        
        Database.insert(ccs,true);
        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = testobj.teamId;
        tm.Allocation__c = 1.0;         
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        teamMembers.add(tm);
        
        Database.insert(teamMembers,true);

        testObj.chooseTeam=true;
        testObj.cloneTeam=false;
        testObj.createTeam=false;
        
        
        
       // Prospect_Profiles__c ppc = new Prospect_Profiles__c(Name='Deltak: Program Managers',ProfileId__c = prof.Id);
		//insert ppc;
        
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        List<Id> profileIds = new List<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        System.debug('profList!-->'+profList);
        
        System.debug('profileIds!-->'+profileIds);
        if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
        
        System.debug('profileIds!-->'+profileIds);
        List<Campus_Contacts__c> allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :a.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        System.debug('allCampusContacts-->'+allCampusContacts);
        testObj.allCampusContacts = allCampusContacts;
        testObj.account.id = a.id;
        testObj.profileIds = profileIds;                                                
        
        testObj.teamMemberList = new List<Team_Member__c>();
        testObj.selectedMembers = new List<String>();
        
        //testObj.selectedMembers.add(u1.id);
        testObj.getTeamMembers();
        testObj.getAllUsers();
        
        testObj.allOtherUsers = new List<String>();
        testObj.allOtherUsers.add(u2.id);
        testObj.allOtherUsers.add(u3.id);
        testObj.selectedUsers = new List<String>();
        testObj.selectedUsers.add(u1.id);
        testObj.getOtherUsers(); 
       system.debug('allOtherUsers-->'+testObj.allOtherUsers);
        for(Integer i=0; i<testObj.otherUsers.size(); i++)
        {
            testobj.otherUsers[i].selected=true;
        }
        
        List<String> rlSumm = new List<String>();
        testobj.displayRuleSummary = rlSumm;
        
        List<String> rlSet = new List<String>();
        testobj.ruleSets = rlSet;
        
        List<SelectOption> addOpt = new List<SelectOption>();
        testobj.allRuleSets = addOpt;
        
        
        //System.assertEquals(4,testObj.members.size()); 
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
        System.assertEquals(longName,testObj.teamName);
        
        String shortName = 'SHORT NAME';
        testObj.teamName = shortName;
        testObj.step3();
        testObj.createRule();
        
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        
        testObj.assocFieldSets = new List<selectOption>();
        
        testObj.objType.fieldValue = 'Select One';
		testObj.loadAssociatedFieldSets();
		testObj.objType.fieldValue = 'Account';
		testObj.loadAssociatedFieldSets();
        testObj.getTeamMembers();
        testObj.getOtherUsers(); 
        //System.assertEquals(3,testObj.members.size()); 
        //System.assertEquals(0,testObj.otherUsers.size());
        //System.assertEquals(4,testObj.allCampusContacts.size());  
        System.assertEquals(shortName,testObj.teamName);
     
     }
     
     static testMethod void testStep3CloneTeam() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
        
        testObj.teamName = 'Copy of Team1';
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
       Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
       User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3;           
                    system.debug('Users-->'+u1.id+ ' -->'+u2.id+ ' -->'+u3.id+ ' -->');
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        insert doa;
        
        List<Campus_Contacts__c> ccs = new List<Campus_Contacts__c>();
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Employee__c = u1.id;
        cc1.Title__c = 'Program Manager';
        cc1.Organization__c = a.id;
        
        ccs.add(cc1);
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Employee__c = u2.id;
        cc2.Title__c = 'Program Manager';
        cc2.Organization__c = a.id;
        
        ccs.add(cc2);
        
        Campus_Contacts__c cc3 = new Campus_Contacts__c();
        cc3.Employee__c = u3.id;
        cc3.Title__c = 'Program Manager';
        cc3.Organization__c = a.id;
        
        ccs.add(cc3);
        
        Campus_Contacts__c cc4 = new Campus_Contacts__c();
        cc4.Employee__c = doa.id;
        cc4.Title__c = 'Director of Admission';
        cc4.Organization__c = a.id;
        
        ccs.add(cc4);
        
        Database.insert(ccs,true);
       /* 
        Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = testobj.teamId;
        tm.Allocation__c = 1.0;         
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        teamMembers.add(tm);*/
        
        //Database.insert(teamMembers,true);

        testObj.chooseTeam=false;
        testObj.cloneTeam=true;
        testObj.createTeam=false;
        
//        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
        //Prospect_Profiles__c ppc = new Prospect_Profiles__c(Name='Deltak: Program Managers',ProfileId__c = prof.Id);
		//insert ppc;
        
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        List<Id> profileIds = new List<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        System.debug('profList!-->'+profList);
        
        System.debug('profileIds!-->'+profileIds);
        if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
        
        System.debug('profileIds!-->'+profileIds);
        List<Campus_Contacts__c> allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :a.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        System.debug('allCampusContacts-->'+allCampusContacts);
        testObj.allCampusContacts = allCampusContacts;
        testObj.account.id = a.id;
        testObj.profileIds = profileIds;                                                
        
        testObj.teamMemberList = new List<Team_Member__c>();
        testObj.selectedMembers = new List<String>();
        testObj.selectedMembers.add(u1.id);
        testObj.getTeamMembers();
        testObj.selectedUsers = new List<String>();
        
        testObj.allOtherUsers = new List<String>();
        testObj.allOtherUsers.add(u2.id);
        testObj.allOtherUsers.add(u3.id);
        testObj.getOtherUsers(); 
       system.debug('allOtherUsers-->'+testObj.allOtherUsers);
        for(Integer i=0; i<testObj.otherUsers.size(); i++)
        {
            testobj.otherUsers[i].selected=true;
        }
        
        List<String> rlSumm = new List<String>();
        testobj.displayRuleSummary = rlSumm;
        
        List<String> rlSet = new List<String>();
        testobj.ruleSets = rlSet;
        
        List<SelectOption> addOpt = new List<SelectOption>();
        testobj.allRuleSets = addOpt;
        
        
        //System.assertEquals(1,testObj.members.size()); 
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
//      System.assertEquals(longName,testObj.teamName);
        
       
        testObj.step3();
        
        testObj.getTeamMembers();
        testObj.getOtherUsers(); 
        //System.assertEquals(3,testObj.members.size()); 
        //System.assertEquals(0,testObj.otherUsers.size());
        //System.assertEquals(4,testObj.allCampusContacts.size());  
        System.assertEquals('Copy of Team1',testObj.teamName);
     
     }
     
     static testMethod void testStep3CreateTeam() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
     /*   PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Name';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'test account';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs);
        
        PRO_Rule_Set__c rs1 = new PRO_Rule_Set__c();
        rs1.Sequence__c = 2;
        rs1.Object_Name__c = 'Account';
        rs1.Field_Name__c = 'Abbreviation__c';
        rs1.Operator__c = 'EQUALS';
        rs1.Value__c = 'TAC';
        rs1.Rule__c = rl.id;
        rs1.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs1);
        System.debug('rs1-->'+rs1);
        
        if(prs!=null && prs.size()>0)
        {
             Database.insert(prs,true);
        }
        
        Team__c t = new Team__c(); 
        String longName = 'Team123';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = true;
        t.Team_Rule__c = rl.id;
        insert t;*/
        
        testObj.teamName = 'New Team1';
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
       User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3;          
                    system.debug('Users-->'+u1.id+ ' -->'+u2.id+ ' -->'+u3.id+ ' -->');
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        insert doa;
        
        List<Campus_Contacts__c> ccs = new List<Campus_Contacts__c>();
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Employee__c = u1.id;
        cc1.Title__c = 'Program Manager';
        cc1.Organization__c = a.id;
        
        ccs.add(cc1);
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Employee__c = u2.id;
        cc2.Title__c = 'Program Manager';
        cc2.Organization__c = a.id;
        
        ccs.add(cc2);
        
        Campus_Contacts__c cc3 = new Campus_Contacts__c();
        cc3.Employee__c = u3.id;
        cc3.Title__c = 'Program Manager';
        cc3.Organization__c = a.id;
        
        ccs.add(cc3);
        
        Campus_Contacts__c cc4 = new Campus_Contacts__c();
        cc4.Employee__c = doa.id;
        cc4.Title__c = 'Director of Admission';
        cc4.Organization__c = a.id;
        
        ccs.add(cc4);
        
        Database.insert(ccs,true);
        
       /* Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = testobj.teamId;
        tm.Allocation__c = 1.0;         
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        teamMembers.add(tm);
        
        Database.insert(teamMembers,true);*/

        testObj.chooseTeam=false;
        testObj.cloneTeam=false;
        testObj.createTeam=true;
        
//        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
       // Prospect_Profiles__c ppc = new Prospect_Profiles__c(Name='Deltak: Program Managers',ProfileId__c = prof.Id);
		//insert ppc;
        
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        List<Id> profileIds = new List<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        System.debug('profList!-->'+profList);
        
        System.debug('profileIds!-->'+profileIds);
        if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
        
        System.debug('profileIds!-->'+profileIds);
        List<Campus_Contacts__c> allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :a.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        System.debug('allCampusContacts-->'+allCampusContacts);
        testObj.allCampusContacts = allCampusContacts;
        testObj.account.id = a.id;
        testObj.profileIds = profileIds;                                                
        testObj.getTeamMembers();
        testObj.getOtherUsers();
        testObj.teamMemberList = new List<Team_Member__c>();
        testObj.selectedUsers = new List<String>();
        testObj.selectedMembers = new List<String>();
        testObj.selectedUsers.add(u1.id);
        //testObj.getTeamMembers();
        testObj.allOtherUsers = new List<String>();
        testObj.selectedUsers.add(u2.id);
        testObj.selectedUsers.add(u3.id);
        testObj.getAllUsers(); 
       system.debug('allOtherUsers-->'+testObj.allOtherUsers);
        for(Integer i=0; i<testObj.allUsers.size(); i++)
        {
            testobj.allUsers[i].selected=true;
        }
        
        List<String> rlSumm = new List<String>();
        testobj.displayRuleSummary = rlSumm;
        
        List<String> rlSet = new List<String>();
        testobj.ruleSets = rlSet;
        
        List<SelectOption> addOpt = new List<SelectOption>();
        testobj.allRuleSets = addOpt;
        
        
        //System.assertEquals(1,testObj.members.size()); 
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
//      System.assertEquals(longName,testObj.teamName);
        
        
        testObj.step3();
        
         
        //System.assertEquals(3,testObj.members.size()); 
        //System.assertEquals(0,testObj.otherUsers.size());
        //System.assertEquals(4,testObj.allCampusContacts.size());  
        System.assertEquals('New Team1',testObj.teamName);
     
     }
     
     static testMethod void testStep4() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep3;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Name';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'test account';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs);
        
        PRO_Rule_Set__c rs1 = new PRO_Rule_Set__c();
        rs1.Sequence__c = 2;
        rs1.Object_Name__c = 'Account';
        rs1.Field_Name__c = 'Abbreviation__c';
        rs1.Operator__c = 'EQUALS';
        rs1.Value__c = 'TAC';
        rs1.Rule__c = rl.id;
        rs1.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs1);
        System.debug('rs1-->'+rs1);
        
        if(prs!=null && prs.size()>0)
        {
             Database.insert(prs,true);
        }
        
        Team__c t = new Team__c(); 
        String longName = 'AaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaa';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = false;
        t.Team_Rule__c = rl.id;
        insert t;
        testobj.teamId = t.id;
        testObj.teamName = t.Team_Name__c;
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
       User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3; 
        
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        
        Team_Member__c tm1 = new Team_Member__c();
        tm1.Who_Id__c = u1.id;
        tm1.Which_Team__c = testobj.teamId;
        tm1.Allocation__c = 0.33;           
        
        teamMembers.add(tm1);
        
        
        Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
        tm2.Which_Team__c = testobj.teamId;
        tm2.Allocation__c = 0.33;           
        
        teamMembers.add(tm2);
        
        Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u2.id;
        tm3.Which_Team__c = testobj.teamId;
        tm3.Allocation__c = 0.34;           
        
        teamMembers.add(tm3);
        
        Database.insert(teamMembers,true);

        testObj.chooseTeam=true;
        testObj.cloneTeam=false;
        testObj.createTeam=false;
        testObj.createRule = false;
        testObj.isDefault = false;
        testObj.memberListchanged = false;
        testObj.eqAlloc = true;
        
        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
        
        testObj.account.id = a.id;
        
        testObj.selectedMembers = new List<String>();
        testObj.selectedMembers.add(u1.id);
        testObj.selectedMembers.add(u2.id);
        testObj.selectedMembers.add(u3.id);

        
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
        
        testObj.step4();
        testObj.userAllocation();
        testObj.setEqualAllocation();
        testObj.saveAll();
        
        System.assertEquals(3,testObj.memAllocList.size()); 
     
     }
     
     static testMethod void testStep4CreateRule() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep3;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Name';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'test account';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs);
        
        PRO_Rule_Set__c rs1 = new PRO_Rule_Set__c();
        rs1.Sequence__c = 2;
        rs1.Object_Name__c = 'Account';
        rs1.Field_Name__c = 'Abbreviation__c';
        rs1.Operator__c = 'EQUALS';
        rs1.Value__c = 'TAC';
        rs1.Rule__c = rl.id;
        rs1.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs1);
        System.debug('rs1-->'+rs1);
        
        if(prs!=null && prs.size()>0)
        {
             Database.insert(prs,true);
        }
        
        
        Team__c t = new Team__c(); 
        String longName = 'AaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaa';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = false;
        t.Team_Rule__c = rl.id;
        insert t;
        testobj.teamId = t.id;
        testObj.teamName = t.Team_Name__c;
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
       User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3; 
          
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        insert doa;
        
        List<Campus_Contacts__c> ccs = new List<Campus_Contacts__c>();
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Employee__c = u1.id;
        cc1.Title__c = 'Program Manager';
        cc1.Organization__c = a.id;
        
        ccs.add(cc1);
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Employee__c = u2.id;
        cc2.Title__c = 'Program Manager';
        cc2.Organization__c = a.id;
        
        ccs.add(cc2);
        
        Campus_Contacts__c cc3 = new Campus_Contacts__c();
        cc3.Employee__c = u3.id;
        cc3.Title__c = 'Program Manager';
        cc3.Organization__c = a.id;
        
        ccs.add(cc3);
        
        Campus_Contacts__c cc4 = new Campus_Contacts__c();
        cc4.Employee__c = doa.id;
        cc4.Title__c = 'Director of Admission';
        cc4.Organization__c = a.id;
        
        ccs.add(cc4);
        
        Database.insert(ccs,true);
        
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        
        Team_Member__c tm1 = new Team_Member__c();
        tm1.Who_Id__c = u1.id;
        tm1.Which_Team__c = testobj.teamId;
        tm1.Allocation__c = 0.33;           
        
        teamMembers.add(tm1);
        
        
        Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
        tm2.Which_Team__c = testobj.teamId;
        tm2.Allocation__c = 0.33;           
        
        teamMembers.add(tm2);
        
        Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u2.id;
        tm3.Which_Team__c = testobj.teamId;
        tm3.Allocation__c = 0.34;
        tm3.Active__c = false;           
        
        teamMembers.add(tm3);
        
        Database.insert(teamMembers,true);
        
       // Prospect_Profiles__c ppc = new Prospect_Profiles__c(Name='Deltak: Program Managers',ProfileId__c = prof.Id);
		//insert ppc;
        
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        List<Id> profileIds = new List<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        System.debug('profileIds!-->'+profileIds);
        if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
        
        System.debug('profileIds!-->'+profileIds);
        testObj.profileIds = profileIds;

        testObj.chooseTeam=false;
        testObj.cloneTeam=false;
        testObj.createTeam=false;
        testObj.createRule = true;
        testObj.isDefault = false;
        testObj.memberListchanged = false;
        testObj.eqAlloc = true;
        
        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
        
        testObj.account.id = a.id;
        
        testObj.selectedMembers = new List<String>();
        testObj.selectedMembers.add(u1.id);
        testObj.selectedMembers.add(u2.id);
        testObj.selectedMembers.add(u3.id);

        testObj.getTeamMembers();
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        testObj.formula.fieldValue = '(AND,1,2)';
        testObj.rulesAdded = 1;
        testObj.step4();
        testObj.userAllocation();
        testObj.getMemberAlloc();
        //SET ONE USER INACTIVE
        List<Team_Member__c> testInactiveUpd = new List<Team_Member__c>();
        for(Team_Member__c tm: [Select t.id, t.Who_Id__c, t.Allocation__c,t.Active__c From Team_Member__c t where t.Which_Team__c =: testobj.teamId and t.Who_Id__c = :u1.id])
        {
        	Team_Member__c tmInactive = tm;
        	tmInactive.Active__c=false;
        	testInactiveUpd.add(tmInactive);	
        }
        if(testInactiveUpd!=null && testInactiveUpd.size()>0)
        {
        	database.update(testInactiveUpd);
        }
        
        
        testObj.setEqualAllocation();
        testObj.flipMemberStatus();
        testObj.saveAll();
        
        // SET SAME USER ACTIVE
        List<Team_Member__c> testActiveUpd = new List<Team_Member__c>();
        for(Team_Member__c tm: [Select t.id, t.Who_Id__c, t.Allocation__c,t.Active__c From Team_Member__c t where t.Which_Team__c =: testobj.teamId and t.Who_Id__c = :u1.id])
        {
        	Team_Member__c tmActive = tm;
        	tmActive.Active__c=true;
        	testActiveUpd.add(tmActive);	
        }
        if(testActiveUpd!=null && testActiveUpd.size()>0)
        {
        	database.update(testActiveUpd);
        }
        
        
        testObj.setEqualAllocation();
        testObj.flipMemberStatus();
        testObj.saveAll();
        
        List<String> remMembers = new List<String>();
        for(String mem: testObj.selectedMembers)
        {
        	remMembers.add(mem);
        	break;
        }
        testObj.selectedMembers = remMembers;
        
        testObj.chooseTeam = true;
        testObj.saveTeamAndTeamMembers();
        testObj.cancel();
        
        System.assertEquals(3,testObj.memAllocList.size()); 
     
     }
     
	
//test class for step 1	
	static testMethod void testTeamList()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Program Managers'];
        
        User u = new User();
        u.alias = 'newUser';
        u.email='newuser@testorg.com';
        u.emailencodingkey='UTF-8';
        u.lastname='Testing';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US'; 
        u.profileid = pro.Id;
        u.timezonesidkey='America/Los_Angeles';
		u.username='newuser11@testorg.com';
		insert u; 
		
        Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
              
      
		PageReference pageRef = Page.ProspectAdminFlowStep1;
		Test.setCurrentPage(pageRef);

	    ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);	

		Test.startTest();
		List<Team__c> teamNames = new List<Team__c> ();
		List<selectOption> selectTeams=new List<selectOption>();
     	teamNames = ProspectUtils.getTeamDetails(a.Id);
     	selectTeams = new List<selectOption> ();
     	for(Team__c teamNm: teamNames)
     	{
     		selectTeams.add(new SelectOption(teamNm.Id, teamNm.Team_Name__c));
     	}
     	Test.stopTest();
     	testobj.step1();
		system.assertNotEquals(0,selectTeams.size());
   	    system.assertEquals(Page.ProspectAdminFlowStep1.getURL(), testobj.step1().getURL());     	        
	}
	
//test class for selecting default team	
	static testMethod void testSelectDefaultTeam()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
         Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
     	PageReference pageRef = Page.ProspectAdminFlowStep1;
      	Test.setCurrentPage(pageRef);
     
     	ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);	
	    
	    Test.startTest();
	  	testobj.selectedTeam = t.id;
	   	testobj.selectDefault();
		Test.stopTest();
	}
	
// test class to test delete team logic	
	static testMethod void testDeleteTeam()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
         Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
     	PageReference pageRef = Page.ProspectAdminFlowStep1;     
     	Test.setCurrentPage(pageRef);
     	
	    ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
	    	
	    testobj.selectedTeam = t.id;
	   	testobj.deleteTeam();   
	}
	
// test class to test select team logic
	static testMethod void testSelectButton()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
         Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
		PageReference pageRef = Page.ProspectAdminFlowStep1;
		Test.setCurrentPage(pageRef);

	    ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);	
	    
	    testobj.selectedTeam = t.id;
	    testobj.step2Choose();
	    
	    testobj.selectedTeam = null;
	    testobj.step2Choose();	    	
	}

//test class to test clone logic	
	static testMethod void testClone()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
         Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
        PageReference pageRef = Page.ProspectAdminFlowStep1;
		Test.setCurrentPage(pageRef);
        
	    ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);	
	   
		testobj.selectedTeam = t.id;
		testobj.step2Clone();
	}
	
	static testMethod void testClonefail()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
         Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
        PageReference pageRef = Page.ProspectAdminFlowStep1;
		Test.setCurrentPage(pageRef);
        
	    ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);	
	   
		testobj.selectedTeam = null;
		testobj.step2Clone();
	}
	
//test case to test create team logic	
	static testMethod void testCreateTeam()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        Team__c t = new Team__c();
        t.Team_Name__c = 'testTeam';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 4;
        t.Default_Team__c = true;
        insert t;
        
        Profile pro = [SELECT Id FROM profile WHERE name='Deltak: Program Managers'];
        User u = new User();
	    u.alias = 'newUser';
	    u.email='newuser@testorg.com';
	    u.emailencodingkey='UTF-8';
	    u.lastname='Testing';
	    u.languagelocalekey='en_US';
	    u.localesidkey='en_US'; 
	    u.profileid = pro.Id;
	    u.timezonesidkey='America/Los_Angeles';
		u.username='newuser11@testorg.com'; 
		u.IsActive = true;
		insert u;
	    
	    Campus_Contacts__c c = new Campus_Contacts__c();
	    c.Organization__c = a.Id;
	    c.Employee__c = u.id;   
	    c.Title__c = 'Director of Admission';
	    insert c;	    
	    
	    PageReference pageRef = Page.ProspectAdminFlowStep1;     
     	Test.setCurrentPage(pageRef);
     	
     	ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
	    
	    testobj.step2Create();	    
	}
	
//test case to test create rule logic	
	static testMethod void testCreateRule()
	{			
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
                
	   /* Account a = new Account();
	    a = [Select id from Account where recordTypeid= :rt1.Id limit 1];
        */
		PageReference pageRef = Page.prospectadminflowstep2;
		Test.setCurrentPage(pageRef);
						
		ApexPages.StandardController sc = new ApexPages.StandardController(a);	
		ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
		  
		testobj.chooseTeam = false;
		testobj.createTeam = false;
		testobj.cloneTeam = false;
		testObj.getObjectTypeList(true);
		testObj.getObjectTypeList(false);
		
		testobj.createRule();
		

	}
	
// test class to test get rules logic	
	static testMethod void testGetRules()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
   
        PRO_Rule__c prc = new PRO_Rule__c();
        prc.Active__c = true;
	   	prc.Academic_Institution__c = a.id;
        insert prc; 
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c p = new PRO_Rule_Set__c();
        p.Value__c = 'SRM TEST ORG';
        p.Sequence__c = 1;
        p.Rule__c = prc.id;
        p.Operator__c = 'EQUALS';
        p.Object_API_Name__c ='Account';
        p.Object_Name__c = 'Account';
        p.Field_Name__c = 'Name'; 
        prs.add(p);
                
        PRO_Rule_Set__c q = new PRO_Rule_Set__c();
        q.Value__c = 'abc';
        q.Sequence__c = 2;
        q.Rule__c = prc.id;
        q.Operator__c = 'CONTAINS';
        q.Object_API_Name__c ='Account';
        q.Object_Name__c = 'Account';
        q.Field_Name__c = 'Affiliate__c'; 
        prs.add(q);        
        Database.insert(prs,true);
      
        Team__c t = new Team__c();
        t.Team_Name__c = 'SRM Team 3';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 5;
        t.Default_Team__c = true;
        t.Team_Rule__c = prc.id;
        insert t;   		
  		
        system.debug('Id' +t.id);
        PageReference pageRef = Page.prospectadminflowstep2;       
     	Test.setCurrentPage(pageRef);
     	        
		ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
		
		testobj.teamId = t.id;
		List<String> rlSumm = new List<String>();
		testobj.displayRuleSummary = rlSumm;
		testobj.getRuleSummary(t.id);
		
	}
	
// test class to test getAllRulesAndRuleSets logic
	static testMethod void testGetAllRules()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
   
        PRO_Rule__c prc = new PRO_Rule__c();
        prc.Active__c = true;
	   	prc.Academic_Institution__c = a.id;
        insert prc; 
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c p = new PRO_Rule_Set__c();
        p.Value__c = 'SRM TEST ORG';
        p.Sequence__c = 1;
        p.Rule__c = prc.id;
        p.Operator__c = 'EQUALS';
        p.Object_API_Name__c ='Account';
        p.Object_Name__c = 'Account';
        p.Field_Name__c = 'Name'; 
        prs.add(p);
                
        PRO_Rule_Set__c q = new PRO_Rule_Set__c();
        q.Value__c = 'abc';
        q.Sequence__c = 2;
        q.Rule__c = prc.id;
        q.Operator__c = 'CONTAINS';
        q.Object_API_Name__c ='Account';
        q.Object_Name__c = 'Account';
        q.Field_Name__c = 'Affiliate__c'; 
        prs.add(q);        
        Database.insert(prs,true);
      
        Team__c t = new Team__c();
        t.Team_Name__c = 'SRM Team 3';
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 5;
        t.Default_Team__c = true;
        t.Team_Rule__c = prc.id;
        insert t;   		
  		
        system.debug('Id' +t.id);
        PageReference pageRef = Page.prospectadminflowstep2;       
     	Test.setCurrentPage(pageRef);
     	        
		ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
		
		testobj.teamId = t.id;
		List<String> rlSumm = new List<String>();
		testobj.displayRuleSummary = rlSumm;
		
		List<String> rlSet = new List<String>();
		testobj.ruleSets = rlSet;
		
		List<SelectOption> addOpt = new List<SelectOption>();
		testobj.allRuleSets = addOpt;
		
		testobj.getAllRulesAndRuleSets(a.id,t.id);		
	}
	
	 static testMethod void testUserInactiveAndCampusContactDelete() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectAdminFlowStep2;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);  
        ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
        
        PRO_Rule__c rl = new PRO_Rule__c();
        rl.Active__c = true;
        rl.Academic_Institution__c = a.id;
        rl.Active__c = false;
        insert rl;
        
        List<PRO_Rule_Set__c> prs = new List<PRO_Rule_Set__c>();
        PRO_Rule_Set__c rs = new PRO_Rule_Set__c();
        rs.Sequence__c = 1;
        rs.Object_Name__c = 'Account';
        rs.Field_Name__c = 'Name';
        rs.Operator__c = 'EQUALS';
        rs.Value__c = 'test account';
        rs.Rule__c = rl.id;
        rs.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs);
        
        PRO_Rule_Set__c rs1 = new PRO_Rule_Set__c();
        rs1.Sequence__c = 2;
        rs1.Object_Name__c = 'Account';
        rs1.Field_Name__c = 'Abbreviation__c';
        rs1.Operator__c = 'EQUALS';
        rs1.Value__c = 'TAC';
        rs1.Rule__c = rl.id;
        rs1.Object_API_Name__c = ProspectUtils.getObjectAPIName('Account');
        prs.add(rs1);
        System.debug('rs1-->'+rs1);
        
        if(prs!=null && prs.size()>0)
        {
             Database.insert(prs,true);
        }
        
        Team__c t = new Team__c(); 
        String longName = 'AaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaaaaaaaaaBBBbbbbbbbbbbbAaaaaaaaa';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = true;
        t.Team_Rule__c = rl.id;
        insert t;
        testobj.teamId = t.id;
        testObj.teamName = t.Team_Name__c;
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com',Prospect_Inactive__c=false);
         insert u1;
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com',Prospect_Inactive__c=false);
                    insert u2;
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com',Prospect_Inactive__c=false);
          insert u3;          
                    system.debug('Users-->'+u1.id+ ' -->'+u2.id+ ' -->'+u3.id+ ' -->');
        
        Profile profDOA = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Directors of Admissions' limit 1];
        UserRole uroleDOA = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile pDOA = [SELECT Id FROM profile WHERE name='Standard User'];
        
         User doa = new User(alias = 'DOA', email='doa@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = profDOA.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='doa@testorg.com');
        insert doa;
        
        List<Campus_Contacts__c> ccs = new List<Campus_Contacts__c>();
        Campus_Contacts__c cc1 = new Campus_Contacts__c();
        cc1.Employee__c = u1.id;
        cc1.Title__c = 'Program Manager';
        cc1.Organization__c = a.id;
        
        ccs.add(cc1);
        
        Campus_Contacts__c cc2 = new Campus_Contacts__c();
        cc2.Employee__c = u2.id;
        cc2.Title__c = 'Program Manager';
        cc2.Organization__c = a.id;
        
        ccs.add(cc2);
        
        Campus_Contacts__c cc3 = new Campus_Contacts__c();
        cc3.Employee__c = u3.id;
        cc3.Title__c = 'Program Manager';
        cc3.Organization__c = a.id;
        
        ccs.add(cc3);
        
        Campus_Contacts__c cc4 = new Campus_Contacts__c();
        cc4.Employee__c = doa.id;
        cc4.Title__c = 'Director of Admission';
        cc4.Organization__c = a.id;
        
        ccs.add(cc4);
        
        Database.insert(ccs,true);
        testobj.teamId = t.id;
        testobj.teamExempt = false;
        
        Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = testobj.teamId;
        tm.Allocation__c = 1.0;         
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        teamMembers.add(tm);
        
        Database.insert(teamMembers,true);

        testObj.chooseTeam=true;
        testObj.cloneTeam=false;
        testObj.createTeam=false;
        
        
        
       // Prospect_Profiles__c ppc = new Prospect_Profiles__c(Name='Deltak: Program Managers',ProfileId__c = prof.Id);
		//insert ppc;
        
        List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
        List<Id> profileIds = new List<Id>();
        profList = Prospect_Profiles__c.getall().values();
        
        System.debug('profList!-->'+profList);
        
        System.debug('profileIds!-->'+profileIds);
        if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
        
        System.debug('profileIds!-->'+profileIds);
        List<Campus_Contacts__c> allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :a.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        System.debug('allCampusContacts-->'+allCampusContacts);
        testObj.allCampusContacts = allCampusContacts;
        testObj.account.id = a.id;
        testObj.profileIds = profileIds;                                                
        
        testObj.teamMemberList = new List<Team_Member__c>();
        testObj.selectedMembers = new List<String>();
        
        //testObj.selectedMembers.add(u1.id);
        testObj.getTeamMembers();
        testObj.getAllUsers();
        
        testObj.allOtherUsers = new List<String>();
        testObj.allOtherUsers.add(u2.id);
        testObj.allOtherUsers.add(u3.id);
        testObj.selectedUsers = new List<String>();
        testObj.selectedUsers.add(u1.id);
        testObj.getOtherUsers(); 
       system.debug('allOtherUsers-->'+testObj.allOtherUsers);
        for(Integer i=0; i<testObj.otherUsers.size(); i++)
        {
            testobj.otherUsers[i].selected=true;
        }
        
        List<String> rlSumm = new List<String>();
        testobj.displayRuleSummary = rlSumm;
        
        List<String> rlSet = new List<String>();
        testobj.ruleSets = rlSet;
        
        List<SelectOption> addOpt = new List<SelectOption>();
        testobj.allRuleSets = addOpt;
        
        
        //System.assertEquals(4,testObj.members.size()); 
        //System.assertEquals(4,testObj.allCampusContacts.size()); 
        //System.assertEquals(2,testObj.allOtherUsers.size());
         
        System.assertEquals(longName,testObj.teamName);
        
        String shortName = 'SHORT NAME';
        testObj.teamName = shortName;
        testObj.step3();
        testObj.createRule();
        
        testObj.initiatePRORuleSetFields();
        testObj.renderPRORuleSetFields();
        
        testObj.assocFieldSets = new List<selectOption>();
        
        testObj.objType.fieldValue = 'Select One';
		testObj.loadAssociatedFieldSets();
		testObj.objType.fieldValue = 'Account';
		testObj.loadAssociatedFieldSets();
        testObj.getTeamMembers();
        testObj.getOtherUsers(); 
        //System.assertEquals(3,testObj.members.size()); 
        //System.assertEquals(0,testObj.otherUsers.size());
        //System.assertEquals(4,testObj.allCampusContacts.size());  
        System.assertEquals(shortName,testObj.teamName);
     
     }
     
}