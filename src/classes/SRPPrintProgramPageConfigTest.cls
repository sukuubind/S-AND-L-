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
public with sharing class SRPPrintProgramPageConfigTest {
	
	static testMethod void testAppDetails()
	{
		DeltakSRP__Student_Online_Application__c soa = [Select d.DeltakSRP__Online_Application_Config__r.Name,
													d.DeltakSRP__Affiliation__r.Name,Name,
													d.DeltakSRP__Academic_Program__r.Name,
													d.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c, 
													d.DeltakSRP__Academic_Start_Date__r.DeltakSRP__End_Date__c
											From DeltakSRP__Student_Online_Application__c d
											where DeltakSRP__Affiliation__r.AccountId = '0016000000QsPaQ' limit 1]; 
		
		ApexPages.StandardController sc = new ApexPages.StandardController(soa);	
		SRPPrintProgramPageConfigs testobj = new SRPPrintProgramPageConfigs(sc);
		
		Test.startTest();
		
		DeltakSRP__Student_Online_Application__c[] appDetails = testobj.applicationDetails();
	
		testobj.pgmConfigs();
		testobj.pgmConfigsForList();
		Test.stopTest();
		
		System.assertNotEquals(null,appDetails);

		
	}

}