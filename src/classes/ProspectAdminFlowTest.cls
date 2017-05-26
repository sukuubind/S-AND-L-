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
public with sharing class ProspectAdminFlowTest {
	
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
	/*
	static testMethod void testUserAlloc()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
	    
	    testobj.userAllocation();
	    system.assertEquals(false,testobj.eqAlloc);
	}
	
	static testMethod void testSaveAll()
	{
		RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectAdminFlowController testobj = new ProspectAdminFlowController(sc);
	    
	     Team_Member__c tm = new Team_Member__c();
//	    ProspectAdminFlowController.MemberAllocField wrap = new MemberAllocField(tm);
	    
	   
	//    testobj.MemberAllocField testWrapper = new testobj.MemberAllocField(tm);
	    
	    testobj.saveAll();
	    
	    
	    
	}
	
	
	

	
	/*
	public void getAccount(Boolean isSRM, Integer num)
	{
		for(Integer i=0;i<=num;i++)
		{
			if(isSRM)
			{
				RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
		        Account a = new Account();
		        a.recordTypeid = rt1.Id;
		        a.name = 'test account SRM';
		        insert a;
			}
			if(!isSRM)
			{
				RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Academic Institution' limit 1];
        
		        Account a = new Account();
		        a.recordTypeid = rt1.Id;
		        a.name = 'test account SRP';
		        insert a;
			}
		}
	}
	
	public void getUser(Boolean recType, Integer num)
	{
		for(Integer i=0;i<=num;i++)
		{
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
		}
	}
	
	public void getCampContacts(Integer num)
	{
		for(Integer i=0; i<num; i++)
		{
			Campus_Contacts__c c = new Campus_Contacts__c();
	  //      c.Name= u.Username;
	        c.Organization__c = a.Id;
	        c.Employee__c = u.id;   
	        c.Title__c = 'Director of Admission';
	        insert c;
		}
	}
	*/
}