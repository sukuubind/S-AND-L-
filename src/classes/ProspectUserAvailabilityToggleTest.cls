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
private class ProspectUserAvailabilityToggleTest {

    static testMethod void testHandleUser() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
                
        
        PageReference pageRef = Page.ProspectUserAvailabilityToggleV2;
        Test.setCurrentPage(pageRef);
        
         
        
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
//        testobj.teamId = t.id;
 //       testObj.teamName = t.Team_Name__c;
        
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
//        testobj.teamId = t.id;
  //      testobj.teamExempt = false;
        
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = t.id;
        tm.Allocation__c = 0.33;         
        teamMembers.add(tm);
        
        Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
        tm2.Which_Team__c = t.id;
        tm2.Allocation__c = 0.33;
        teamMembers.add(tm2);
        
        Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u3.id;
        tm3.Which_Team__c = t.id;
        tm3.Allocation__c = 0.34;
        teamMembers.add(tm3);
        
        Database.insert(teamMembers,true);
        

        ProspectUserAvailabilityController testobj = new ProspectUserAvailabilityController();
		testObj.loggedInuser = u1.id;
		testObj.checkboxVF = true;
       	testObj.handleUser();
       	List<User> bAdmin = [Select id from User where Name = 'Business Administrator' limit 1];
       	User BA = new User(id=bAdmin[0].id);
       	System.runAs(BA)
       	{
       		String query = ProspectConstants.USER_AVBL_QUERY;
       		ProspectUserAvailabilityScheduleBatch proUABatch = new ProspectUserAvailabilityScheduleBatch(query);
       		Database.executeBatch(proUABatch);
       	}
     
     }
     static testMethod void testHandleAllUsers() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'Campus/Partner' limit 1];
        
        Account a = new Account();
        a.recordTypeid = rt1.Id;
        a.name = 'test account';
        a.PROspect_Enabled__c=true;
        insert a;
        
        PageReference pageRef = Page.ProspectUserAvailabilityToggleV2;
        Test.setCurrentPage(pageRef);

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
//        testobj.teamId = t.id;
 //       testObj.teamName = t.Team_Name__c;
        
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
//        testobj.teamId = t.id;
  //      testobj.teamExempt = false;
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        Team_Member__c tm = new Team_Member__c();
        tm.Who_Id__c = u1.id;
        tm.Which_Team__c = t.id;
        tm.Allocation__c = 0.33; 
        tm.Active__c = true;        
        teamMembers.add(tm);
        
        Team_Member__c tm2 = new Team_Member__c();
        tm2.Who_Id__c = u2.id;
        tm2.Which_Team__c = t.id;
        tm2.Allocation__c = 0.33;
        tm2.Active__c = true;
        teamMembers.add(tm2);
        
        Team_Member__c tm3 = new Team_Member__c();
        tm3.Who_Id__c = u3.id;
        tm3.Which_Team__c = t.id;
        tm3.Allocation__c = 0.34;
        tm3.Active__c = true;
        teamMembers.add(tm3);
        
        Database.insert(teamMembers,true);
        
        Team_Member__c tmI = new Team_Member__c(id=tm.id);
        tmI.Active__c = false;
        Database.update(tmI);
        
        Team_Member__c tmA = new Team_Member__c(id=tm.id);
        tmI.Active__c = true;
        Database.update(tmI);
        
        ProspectUserAvailabilityController testobj = new ProspectUserAvailabilityController();
		testObj.loggedInuser = u1.id;
		testObj.checkboxVF = false;
       	testObj.handleUserBulk();
       	
       	//Girija added:
       	testObj.handleUserBulkMultiAccount();
       	
       	ProspectUserAvailabilityController testobj1 = new ProspectUserAvailabilityController();
		testObj1.loggedInuser = u1.id;
		testObj1.checkboxVF = true;
       	testObj1.handleUserBulk();
       	
       	//Girija added:
       	testObj.handleUserBulkMultiAccount();
       	
       	ProspectUserAvailabilityController testobj1a = new ProspectUserAvailabilityController();
		testObj1a.loggedInuser = u1.id;
		testObj1a.checkboxVF = false;
       	testObj1a.handleUserBulk();
       	
       	//Girija added:
       	testObj.handleUserBulkMultiAccount();
       	
       	List<User> bAdmin = [Select id from User where Name = 'Business Administrator' limit 1];
       	User BA = new User(id=bAdmin[0].id);
       	System.runAs(BA)
       	{
       		String query = ProspectConstants.USER_AVBL_QUERY;
       		ProspectUserAvailabilityScheduleBatch proUABatch = new ProspectUserAvailabilityScheduleBatch(query);
       		Database.executeBatch(proUABatch);
       	}
       	
       	ProspectUserAvailabilityController testobj2 = new ProspectUserAvailabilityController();
		testObj2.loggedInuser = u1.id;
		testObj2.checkboxVF = false;
       	testObj2.handleUserBulk();
       	
       	////Girija added:
       	testObj.handleUserBulkMultiAccount();
       	
       	System.runAs(BA)
       	{
	       	String query1 = ProspectConstants.USER_AVBL_QUERY;
	       	ProspectUserAvailabilityScheduleBatch proUABatch1 = new ProspectUserAvailabilityScheduleBatch(query1);
	       	Database.executeBatch(proUABatch1);
       	}
       	Campus_Contacts__c ccDel = new Campus_Contacts__c(id=cc1.id);
        delete cc1;
       	
       	User u9 = new User(id=u3.id);
       	u9.prospect_inactive__c = true;
       	Database.update(u9,false);
       	
       	System.runAs(BA)
       	{
	       	User u10 =  new User(id=u2.id);
	       	u10.IsActive = false;
	       	Database.update(u10,false);
       	}
       	
       	List<Team_Member__c> teamMemDel = new List<Team_Member__c>();
       	teamMemDel = [Select id, Which_Team__c, Allocation__c, Who_Id__c
                                    From Team_Member__c
                                    Where Who_Id__c =: u2.id];
        List<Id> teamMemberListDelete = new List<Id>();
        if(teamMemDel!=null && teamMemDel.size()>0)
        {
        	for(Team_Member__c tm12 : teamMemDel){
                teamMemberListDelete.add(tm12.id);
        	}
        }
        ProspectTeamMemberBatchDelete proBatch = new ProspectTeamMemberBatchDelete(teamMemberListDelete); 
        Database.executeBatch(proBatch);
       	
     }
}