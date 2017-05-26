@isTest
private class AdmissionsGoalTest {

    static testMethod void Test() {
    	Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    	
    	User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pr.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        AdmissionsGoal ag = new AdmissionsGoal();
       
        
        System.assertEquals(ag.weeklyLeads, 0);
        System.assertEquals(ag.totalLeads, 0);
        System.assertEquals(ag.totalAppointments, 0);
        System.assertEquals(ag.weeklyAppointments, 0);
        System.assertEquals(ag.weeklyReferrals, 0);
        System.assertEquals(ag.weeklyUnContactedLeads, 0);
        System.assertEquals(ag.weeklyApplications, 0);
        System.assertEquals(ag.totalApplicationsReceived, 0);
        System.assertEquals(ag.totalUnContactedLeads, 0);
        System.assertEquals(ag.totalStart, 0);
        
        ag.updateValues(
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0,
        				1.0);		
		
        System.assertEquals(ag.weeklyLeads, 1.0);
        System.assertEquals(ag.totalLeads, 1.0);
        System.assertEquals(ag.totalAppointments, 1.0);
        System.assertEquals(ag.weeklyAppointments, 1.0);        
        System.assertEquals(ag.weeklyReferrals, 1.0);
        System.assertEquals(ag.weeklyUnContactedLeads, 1.0);
        System.assertEquals(ag.weeklyApplications, 1.0);
        System.assertEquals(ag.totalApplicationsReceived, 1.0);
        System.assertEquals(ag.totalUnContactedLeads, 1.0);
        System.assertEquals(ag.totalStart, 1.0);
        }
    }
}