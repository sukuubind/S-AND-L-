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
 * NEED TO HAVE BUSINESSHOURS RECORDS SETUP BEFORE RUNNING THIS TEST
 */
@isTest(seealldata = true)
private class Live_Agent_After_Hours_Chat_Controller_T {

    static testMethod void userAfterHours() {
        // TO DO: implement unit test
        
        User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
        After_Hours_Profile_Id__c
        FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
        u.Is_After_Hours_User__c = true;
        u.After_Hours_Cluster__c = 'TEST';
        u.Normal_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15); 
        u.After_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);   
    
        update u;
        
        System.Test.startTest();
          
        System.runAs(u)
        {
        
            Profile p = [SELECT Id FROM Profile LIMIT 1];
            
            
            Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
            
            laahcc.currUser.After_Hours_Cluster__c = 'TEST';
            laahcc.afterHoursProfileId = p.Id;
            laahcc.normalHoursProfileId = p.Id;
            laahcc.foundErrors = false;
            laahcc.isAfterHoursUser = true;
            
            laahcc.checkUserInAfterHoursWindow();
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.currUser.Is_After_Hours_Enabled__c = true;
            
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.currUser.Is_After_Hours_Enabled__c = false;
            
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.afterHoursProfileId = null;
            laahcc.normalHoursProfileId = null;
            laahcc.foundErrors = false;
            laahcc.isAfterHoursUser = true;
            
            laahcc.callUpdateAfterHoursMode();
            
        }
        
        System.Test.stopTest();
        
    }
    
    static testMethod void userAfterHours2() {
        // TO DO: implement unit test
        
        User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
        After_Hours_Profile_Id__c
        FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
        u.Is_After_Hours_User__c = true;
        u.After_Hours_Cluster__c = 'TEST2';
        u.Normal_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15); 
        u.After_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);   
    
        update u;
        
        System.Test.startTest();
          
        System.runAs(u)
        {
        
            Profile p = [SELECT Id FROM Profile LIMIT 1];
            
            
            Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
            
            laahcc.currUser.After_Hours_Cluster__c = 'TEST2';
            laahcc.afterHoursProfileId = p.Id;
            laahcc.normalHoursProfileId = p.Id;
            laahcc.foundErrors = false;
            laahcc.isAfterHoursUser = true;
            
            laahcc.checkUserInAfterHoursWindow();
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.currUser.Is_After_Hours_Enabled__c = true;
            
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.currUser.Is_After_Hours_Enabled__c = false;
            
            laahcc.callUpdateAfterHoursMode();
            
        }
        
        System.Test.stopTest();
        
    }
    
    static testMethod void userAfterHoursBadCluster() {
        // TO DO: implement unit test
        
        User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
        After_Hours_Profile_Id__c
        FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
        u.Is_After_Hours_User__c = true;
        u.After_Hours_Cluster__c = 'ORLsdfhsj';
        u.Normal_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15); 
        u.After_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);   
    
        update u;
        
        System.Test.startTest();
        
        System.runAs(u)
        {
        
            Profile p = [SELECT Id FROM Profile LIMIT 1];
            
            
            Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
            
            laahcc.currUser.After_Hours_Cluster__c = 'ORLsdfhsj';
            laahcc.afterHoursProfileId = p.Id;
            laahcc.normalHoursProfileId = p.Id;
            laahcc.foundErrors = false;
            laahcc.isAfterHoursUser = true;
            
            laahcc.checkUserInAfterHoursWindow();
            laahcc.callUpdateAfterHoursMode();
            
            laahcc.currUser.Is_After_Hours_Enabled__c = true;
            laahcc.currUser.Is_After_Hours_Enabled__c = true;
            
            laahcc.callUpdateAfterHoursMode();
            
        }
        
        System.Test.stopTest();
        
    }
    
    static testMethod void userAfterHoursBadProfiles() {
        // TO DO: implement unit test
        
        User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
        After_Hours_Profile_Id__c
        FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
        u.Is_After_Hours_User__c = true;
        u.After_Hours_Cluster__c = 'TEST';
        u.Normal_Hours_Profile_Id__c = 'ewkjhbfwekj';
        u.After_Hours_Profile_Id__c = 'skfguewjk';
    
        update u;
        
        System.Test.startTest();
        
        System.runAs(u)
        {
        
            Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
            
            laahcc.checkUserInAfterHoursWindow();
            laahcc.callUpdateAfterHoursMode();
            
        }
        
        u.Is_After_Hours_User__c = false;
        update u;
        
        System.runAs(u)
        {
        
            Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
            
            laahcc.checkUserInAfterHoursWindow();
            laahcc.callUpdateAfterHoursMode();
            
        }
        
        System.Test.stopTest();
        
    }
    
    static testMethod void apiAfterHours() {
        // TO DO: implement unit test
        
        User u = [SELECT Id,Is_After_Hours_User__c,After_Hours_Cluster__c, ProfileId, Normal_Hours_Profile_Id__c, 
        After_Hours_Profile_Id__c
        FROM User WHERE UserPermissionsLiveAgentUser = TRUE AND IsActive = TRUE LIMIT 1];
    
        u.Is_After_Hours_User__c = true;
        u.After_Hours_Cluster__c = 'TEST';
        u.Normal_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15); 
        u.After_Hours_Profile_Id__c = String.valueOf(u.ProfileId).substring(0,15);   
    
        update u;
        
        System.Test.startTest();
        
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('op','switchProfile');
        ApexPages.currentPage().getParameters().put('userId','' + u.Id);
        ApexPages.currentPage().getParameters().put('profileId','' + p.Id);
        ApexPages.currentPage().getParameters().put('isAfterHoursEnabled','true');
        
        Live_Agent_After_Hours_Chat_Controller laahcc = new Live_Agent_After_Hours_Chat_Controller();
        laahcc.checkUserInAfterHoursWindow();
        laahcc.updateAfterHoursMode();
        
        ApexPages.currentPage().getParameters().put('isAfterHoursEnabled','false');
        laahcc = new Live_Agent_After_Hours_Chat_Controller();
        laahcc.checkUserInAfterHoursWindow();
        laahcc.updateAfterHoursMode();
        
        ApexPages.currentPage().getParameters().put('profileId','frwerfw' + p.Id);
        laahcc = new Live_Agent_After_Hours_Chat_Controller();
        laahcc.checkUserInAfterHoursWindow();
        laahcc.updateAfterHoursMode();
        
        ApexPages.currentPage().getParameters().put('userId','efrerw' + u.Id);
        laahcc = new Live_Agent_After_Hours_Chat_Controller();
        laahcc.checkUserInAfterHoursWindow();
        //laahcc.updateAfterHoursMode();
        
        System.Test.stopTest();
        
    }
}