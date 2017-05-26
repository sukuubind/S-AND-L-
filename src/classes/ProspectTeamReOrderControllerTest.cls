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
private class ProspectTeamReOrderControllerTest {

    static testMethod void testReOrderGetTeams() {
     	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectTeamReOrderPage;
		Test.setCurrentPage(pageRef);
	   	
	   	ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectTeamReOrderController testobj = new ProspectTeamReOrderController(sc);
        
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
   		String longName = 'Team1';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = false;
        t.Team_Rule__c = rl.id;
        insert t;
       
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com');
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com');
        
		List<Team_Member__c> teamMembers = new List<Team_Member__c>();
		
		Team_Member__c tm1 = new Team_Member__c();
        tm1.Who_Id__c = u1.id;
		tm1.Which_Team__c = t.Id;
		tm1.Allocation__c = 0.33;			
		
		teamMembers.add(tm1);
		
		
		Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
		tm2.Which_Team__c = t.Id;
		tm2.Allocation__c = 0.33;			
		
		teamMembers.add(tm2);
		
		Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u2.id;
		tm3.Which_Team__c = t.Id;
		tm3.Allocation__c = 0.34;			
		
		teamMembers.add(tm3);
		
		Database.insert(teamMembers,true);
	    

		testObj.getTeams();

     }
     
     static testMethod void testReOrderMoveUpTeam() {
     	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectTeamReOrderPage;
		Test.setCurrentPage(pageRef);
	   	
	   	ApexPages.StandardController sc = new ApexPages.StandardController(a);	
	    ProspectTeamReOrderController testobj = new ProspectTeamReOrderController(sc);
        
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
   		String longName = 'Team1';
        t.Team_Name__c = longName;
        t.Team_Account__c = a.id;       
        t.Team_Order__c = 1;
        t.Default_Team__c = false;
        t.Team_Rule__c = rl.id;
        insert t;
       
        
        //Get PM User for School SHU
        Profile prof = [Select p.id, p.Name From Profile p where p.Name = 'Deltak: Program Managers' limit 1];
        UserRole urole = [Select u.Id, u.Name From UserRole u where u.Name = 'Deltak Innovation Management' limit 1];
        
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u1 = new User(alias = 'newUser1', email='newuser1@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        User u2 = new User(alias = 'newUser2', email='newuser2@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser22@testorg.com');
        User u3 = new User(alias = 'newUser3', email='newuser3@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = prof.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser33@testorg.com');
        
		List<Team_Member__c> teamMembers = new List<Team_Member__c>();
		
		Team_Member__c tm1 = new Team_Member__c();
        tm1.Who_Id__c = u1.id;
		tm1.Which_Team__c = t.Id;
		tm1.Allocation__c = 0.33;			
		
		teamMembers.add(tm1);
		
		
		Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
		tm2.Which_Team__c = t.Id;
		tm2.Allocation__c = 0.33;			
		
		teamMembers.add(tm2);
		
		Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u2.id;
		tm3.Which_Team__c = t.Id;
		tm3.Allocation__c = 0.34;			
		
		teamMembers.add(tm3);
		
		Database.insert(teamMembers,true);
	    

		testObj.getTeams();
		testObj.teamIdToWorkWith = t.Id;
		testObj.moveTeamUp();
		testObj.moveTeamDown();

     }
}