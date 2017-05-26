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
private class ProspectOpportunityAssignment_CaseTest {

  
       static testMethod void myUnitTest_CaseMgmt(){
		
    		List<String> rtNames = new List<String>();
       		rtNames.add('SRP Academic Institution');
        	rtNames.add('SRP Lead');
        	rtNames.add('SRP Opportunity');
        	rtNames.add('SRP Student');
        	rtNames.add('SRP Help');
        
    		List<RecordType> rtList = [Select r.Name, r.Id From RecordType r where r.Name IN :rtNames
                                      ];
        	RecordType rt1 = null;
            RecordType rt2 = null;
            RecordType rt3 = null;
            RecordType rt4 = null;
            RecordType rt5 = null;
        
        
        	for(RecordType rt : rtList){
                if(rt.Name == 'SRP Academic Institution'){
                    rt1 = rt;
                }
                if(rt.Name == 'SRP Lead'){
                    rt2 = rt;
                }
                if(rt.Name == 'SRP Opportunity'){
                    rt3 = rt;
                }
                if(rt.Name == 'SRP Student'){
                    rt4 = rt;
                }
                if(rt.Name == 'SRP Help'){
                	rt5 = rt;
                }
            }
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname1';
	        c.LastName = 'lname1';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
    		
    	
	        
	        Team__c t = new Team__c();
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
             List<Team_Member__c> tmList = new List<Team_Member__c>();
        
	        Team_Member__c tm = new Team_Member__c();
	        tm.Which_Team__c = t.id;
	        tm.who_id__c = u.id;
	        tm.allocation__c = 0.75;
	        tm.allocation_counter__c = 7.5;
	        //insert tm;
	        tmList.add(tm);
	        
	        Team_Member__c tm2 = new Team_Member__c();
	        tm2.Which_Team__c = t.id;
	        tm2.who_id__c = u2.id;
	        tm2.allocation__c = 0.25;
	        tm2.allocation_counter__c = 2.5;
	        //insert tm2;
	        tmList.add(tm2);
	        insert tmList;
        
	        List<Team_member__c> tmems = tmList;
	        
	        
	        ProspectOpportunityAssignment_CaseMgmt.resetAllocationCountersOfTeam(tmems);
	        system.debug('tmems[0].allocation_counter__c>>>>'+tmems[0].allocation_counter__c);
	        
	        ProspectOpportunityAssignment_CaseMgmt.getTeamMemberWithSecondHighestAllocationCounter(tmems, u.id);
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
            
	        system.debug('oplist.size()>>>>'+oplist.size());
	        Map<Case, Team__c> opptyTeamMap = new Map<Case, Team__c>();
	        
	        for(integer i=0; i<2; i++){
	        	opptyTeamMap.put(oplist[i], t);
	        }
	        
	        Map<Id, Id> omap = ProspectOpportunityAssignment_CaseMgmt.performCaseAssignment(opptyTeamMap);
	        
	        
    
	}
        
    
}