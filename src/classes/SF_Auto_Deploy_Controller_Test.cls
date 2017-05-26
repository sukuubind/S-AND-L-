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
private class SF_Auto_Deploy_Controller_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        System.Test.startTest();
        
        Automated_Deployment__c ad = new Automated_Deployment__c();
        ad.Jira_Story__c = 'test';
        ad.Jira_Sprint__c = 'test';
        ad.Notes__c = 'test';
        ad.Deployment_Type__c = 'GIT to ORG';
        ad.Git_Repo__c = 'GITREPO';
        ad.Git_Repo_Src_Directory__c = 'GITREPO/src';
        ad.Source_Org__c = 'TST';
        ad.Source_Org_Type__c = 'TST';
        ad.Destination_Org__c = 'TST';
        ad.Destination_Org_Type__c = 'TST';
        ad.Rollback_On_Error__c = false;
        ad.Single_Package__c = false;
        ad.Check_Only__c = false;
        ad.Max_Poll__c = 200;
        ad.Auto_Update_Package__c = false;
        ad.Run_All_Tests__c = false;
        ad.Deployed__c = 'YES';
        ad.Deployment_Running__c = true;
        
        insert ad;
        
        ApexPages.currentPage().getParameters().put('id',ad.Id);
      	ApexPages.StandardController stdAD = new ApexPages.StandardController(ad);
        SF_Auto_Deploy_Controller ADController = new SF_Auto_Deploy_Controller(stdAD);
        
        ADController.currAD.Git_Repo__c = null;
        
        ADController.refreshDeployment();
        
        ADController.validate();
        ADController.validateRelease();
        
        ad.Deployment_Running__c = false;
        update ad;
        
        ADController.validate();
        
        Attachment attach = new Attachment();
      	attach.Body = Blob.valueOf('someXML');
      	attach.Name = 'testFilename.xml';
      	attach.ContentType = 'text/xml';
      	attach.ParentID = ad.id;
      	
      	insert attach;
      	
      	stdAD = new ApexPages.StandardController(ad);
        ADController = new SF_Auto_Deploy_Controller(stdAD);
      	
      	ADController.refreshDeployment();
      	
      	ADController.validate();
      	ADController.validateRelease();
      	
      	ADController.deploy();
      	ADController.release();
      	
      	ADController.foundErrors = false;
      	
      	ADController.adConfig.Initiating_Org_Instance__c = 'aa11';
      	ADController.adConfig.Initiating_Org__c = 'ORG';
      	ADController.adConfig.Endpoint_Url__c = 'deployURL';
      	ADController.adConfig.Release_Endpoint_Url__c = 'releaseURL';
      	ADController.adConfig.Encryption_Key__c = 'encryptionKeyThirtyTwoByteLength'; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';
      	
      	ad.Rollback_On_Error__c = true;
        ad.Single_Package__c = true;
        ad.Check_Only__c = true;
        ad.Auto_Update_Package__c = true;
        ad.Run_All_Tests__c = true;
        ad.Deployed__c = 'NO';
        ad.Deployment_Running__c = false;
      	
      	update ad;
      	
      	ADController.currAD.Rollback_On_Error__c = true;
        ADController.currAD.Single_Package__c = true;
        ADController.currAD.Check_Only__c = true;
        ADController.currAD.Auto_Update_Package__c = true;
        ADController.currAD.Run_All_Tests__c = true;
        ADController.currAD.Deployed__c = 'NO';
        ADController.currAD.Deployment_Running__c = false;
      	
      	ADController.validate();
      	ADController.validateRelease();
      	
      	ADController.adConfig.Encryption_Key__c = 'hNeinfOlOlI0DzaUlXk4jzv4NimSIJbU4N159GG3Ur0='; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';
      	
      	ADController.validate();
      	ADController.validateRelease();
      	
      	ADController.adConfig.Encryption_Key__c = 'hNeinfOlOlI0DzaUlXk4j4/b+8yobo+orzP8JBXMRYsHXUsjcQufaJmRIBc7bI1i'; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';
      	
      	ADController.validate();
      	ADController.validateRelease();
      	
      	ADController.foundErrors = false;
      	
      	ADController.doNothing();
      	ADController.deploy();
      	
      	ADController.refreshDeployment();
      	ADController.refreshDeployment();
      	ADController.refreshDeployment();
      	ADController.refreshDeployment();
      	
      	ad.Deployed__c = 'YES';
       	update ad;
       	
       	ADController.refreshDeployment = true;
       	ADController.refreshCounter = 1;
       	
      	ADController.refreshDeployment();
      	
      	ADController.deploy();
      	
      	ADController.currAD.Rollback_On_Error__c = false;
        ADController.currAD.Single_Package__c = false;
        ADController.currAD.Check_Only__c = false;
        ADController.currAD.Auto_Update_Package__c = false;
        ADController.currAD.Run_All_Tests__c = false;
      	ADController.currAD.Deployed__c = 'NO';
      	ADController.initialLoad = true;
      	
      	
      	ADController.deploy();
      	ADController.refreshDeployment();
      	ADController.deploy();
      	
      	ADController.initialLoad = false;
      	
      	ADController.deploy();
      	ADController.refreshDeployment();
      	ADController.deploy();
      	
      	ADController.currAD.Git_Repo__c = null;
      	ADController.validateRelease();
      	
      	ADController.release();
      	
      	ADController.currAD.Git_Repo__c = 'GITREPO';
      	ADController.releaseVersion = 'v0.01test';
      	ADController.releaseComment = 'comment';
      	
      	ADController.adConfig.Encryption_Key__c = 'encryptionKeyThirtyTwoByteLength'; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';
      	
      	ADController.validateRelease();
      	ADController.release();
      	
      	ADController.adConfig.Encryption_Key__c = 'hNeinfOlOlI0DzaUlXk4jzv4NimSIJbU4N159GG3Ur0='; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';
      	
      	ADController.validateRelease();
      	ADController.release();
      	
      	ADController.adConfig.Encryption_Key__c = 'hNeinfOlOlI0DzaUlXk4j4/b+8yobo+orzP8JBXMRYsHXUsjcQufaJmRIBc7bI1i'; //"encryptionKeyThirtyTwoByteLength" 
      	ADController.adConfig.Decryption_Key__c = 'decryptionKeyThirtyTwoByteLength';      	
      	
      	ADController.validateRelease();
      	ADController.release();
      	
      	SF_Auto_Deploy_Controller.releaseResponse rr = new SF_Auto_Deploy_Controller.releaseResponse('','');
      	
      	ADController.currAD.Id = null;
      	ADController.validate();
      	  
        System.Test.stopTest();
        
    }
}