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
@isTest (seealldata = true)
private class II_ProcessManualIntegrationTransactionsT {

     static testMethod void TestScheduled1()
   {
   	 
     Id aRTId = (Schema.SObjectType.Account).getRecordTypeInfosByName().get('SRP Academic Institution').getRecordTypeId();
	 Id cRTId = (Schema.SObjectType.Contact).getRecordTypeInfosByName().get('SRP Student').getRecordTypeId();
	 Id oRTId = (Schema.SObjectType.Opportunity).getRecordTypeInfosByName().get('SRP Opportunity').getRecordTypeId();
       
     List<Account> accList = [SELECT Id, Name FROM Account WHERE Name = 'University of Texas at Austin' AND RecordTypeId = :aRTId LIMIT 1];
       
       Account a = new Account();
       if(accList != null && accList.size() > 0)
       {
         a = accList[0];
       }
       else
       {
         a.Name = 'University of Texas at Austin';
         a.RecordTypeId = aRTId;
         insert a;
       }
      
       
       Contact c = new Contact();
       c.RecordTypeId = cRTId;
       c.FirstName = 'mattx';
       c.LastName = 'collinsx';
       c.Email = 'matthew.collins+testing@geekluv.comx';
       c.AccountId = a.Id;
       insert c;
       
       Contact c2 = new Contact();
       c2.RecordTypeId = cRTId;
       c2.FirstName = 'matthewx';
       c2.LastName = 'collinsx';
       c2.Email = 'matthew.collins@geekluv.comx';
       c2.AccountId = a.Id;
       insert c2;
       
       DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
       ap.Name = 'UTX | FDN ACCTx';
       ap.DeltakSRP__School__c = a.Id;
       ap.DeltakSRP__Abbrev__c = 'FDN ACCTx';
       ap.DeltakSRP__Program_Title__c = 'Foundations of Accountingx';
       ap.DeltakSRP__Degree_Type__c = 'Certificatex';
       ap.DeltakSRP__SIS_External_Id__c = 'UTX-ACCx';
       insert ap;
       ap.DeltakSRP__SIS_External_Id__c = 'UTX-ACCx';
       update ap;
       
       Integer countBFP = [SELECT Count() FROM DeltakSRP__Academic_Program__c WHERE DeltakSRP__SIS_External_Id__c = 'UTX-BFP'];
       
       if(countBFP == 0)
       {
         DeltakSRP__Academic_Program__c ap2 = new DeltakSRP__Academic_Program__c();
         ap2.Name = 'UTX | FDN BFPx';
         ap2.DeltakSRP__School__c = a.Id;
         ap2.DeltakSRP__Abbrev__c = 'FDN BFPx';
         ap2.DeltakSRP__Program_Title__c = 'Foundations of Accountingx';
         ap2.DeltakSRP__Degree_Type__c = 'Certificatex';
         ap2.DeltakSRP__SIS_External_Id__c = 'UTX-BFP';
         insert ap2;
         ap2.DeltakSRP__SIS_External_Id__c = 'UTX-BFP';
         update ap2;
       }
       
       DeltakSRP__Academic_Program__c ap3 = new DeltakSRP__Academic_Program__c();
       ap3.Name = 'UTX | FDN LEBx';
       ap3.DeltakSRP__School__c = a.Id;
       ap3.DeltakSRP__Abbrev__c = 'FDN LEBx';
       ap3.DeltakSRP__Program_Title__c = 'Foundations of Accountingx';
       ap3.DeltakSRP__Degree_Type__c = 'Certificatex';
       ap3.DeltakSRP__SIS_External_Id__c = 'UTX-LEBx';
       insert ap3;
       ap3.DeltakSRP__SIS_External_Id__c = 'UTX-LEBx';
       update ap3;
       
       DeltakSRP__Academic_Start_Date__c sd = new DeltakSRP__Academic_Start_Date__c();
       sd.DeltakSRP__Academic_Program__c = ap.Id;
       sd.DeltakSRP__Start_Date__c = DateTime.now().date();
       insert sd;
       
       DeltakSRP__Academic_Course__c ac = new DeltakSRP__Academic_Course__c();
       ac.Name = 'ACC 310F Foundations of Accountingx';
       ac.DeltakSRP__Academic_Institution__c = a.Id;
       ac.DeltakSRP__Primary_Program__c = ap.Id;
       insert ac;
       
       DeltakSRP__Academic_Course__c ac2 = new DeltakSRP__Academic_Course__c();
       ac2.Name = 'LEB 320F Foundations of the Legal Environment of Businessx';
       ac2.DeltakSRP__Academic_Institution__c = a.Id;
       ac2.DeltakSRP__Primary_Program__c = ap3.Id;
       insert ac2;
       
       DeltakSRP__Academic_Section__c asection = new DeltakSRP__Academic_Section__c();
       asection.Name = 'ACCx_310F-DS-01-05-2015x';
       asection.DeltakSRP__Academic_Course__c = ac.Id;
       asection.DeltakSRP__SIS_External_Id__c = 'UTX-ACCx_310F-DS-01-05-2015x';
       asection.DeltakSRP__Section_ID__c = 'ACC_310F-DS-01-05-20';
       asection.DeltakSRP__Academic_Term__c = sd.Id;
       insert asection;
       asection.DeltakSRP__SIS_External_Id__c = 'UTX-ACCx_310F-DS-01-05-2015x';
       update asection;
       
       DeltakSRP__Academic_Section__c asection2 = new DeltakSRP__Academic_Section__c();
       asection2.Name = 'LEBx_320F-DS-01-05-2015x';
       asection2.DeltakSRP__Academic_Course__c = ac2.Id;
       asection2.DeltakSRP__SIS_External_Id__c = 'UTX-LEBx_320F-DS-01-05-2015x';
       asection2.DeltakSRP__Section_ID__c = 'LEB_320F-DS-01-05-20';
       asection2.DeltakSRP__Academic_Term__c = sd.Id;
       insert asection2;
       asection2.DeltakSRP__SIS_External_Id__c = 'UTX-LEBx_320F-DS-01-05-2015x';
       update asection2;
       
       Opportunity o = new Opportunity();
       o.RecordTypeId = oRTId;
       o.Name = 'test';
       o.stageName = 'New Inquiry';
       o.CloseDate = DateTime.newInstance(2100,1,1).date();
       o.AccountId = a.Id;
       o.DeltakSRP__Student__c = c.Id;
       o.DeltakSRP__Academic_Program__c = ap.Id;
       insert o;
       
   	
   	List<Integration_Interface__c> iiList = [SELECT Id, Status__c, Name, Interface_Identifier__c, Records_Per_Batch__c, Error_Log_Per__c, Include_Old_Errors__c, Raw_Header__c
   	FROM Integration_Interface__c WHERE Interface_Identifier__c = 'UTX Course Enrollments'];
   	
   	Integration_Interface__c ii = new Integration_Interface__c();
   	
   	if(iiList.size() > 0)
   	{
   		ii = iiList[0];
   	}
   	
   	ii.Status__c = 'Ready';
   	ii.Name = 'UTX Course Enrollments';
   	ii.Interface_Identifier__c = 'UTX Course Enrollments';
   	ii.Records_Per_Batch__c = 1;
   	ii.Error_Log_Per__c = 'Run';
   	ii.Include_Old_Errors__c = 'NO';
   	ii.Raw_Header__c = 'uniqueid,firstname,lastname,email,enrollmentdate,shortname,fullname,startdate';
   	
   	if(iiList.size() > 0)
   	{
   		update ii;
   	}
   	else
   	{
   		insert ii;
   	}
   	
   	List<Integration_Transaction__c> itList = new List<Integration_Transaction__c>();
   	
   	Integration_Transaction__c it = new Integration_Transaction__c();
   	it.Integration_Interface__c = ii.Id;
   	it.Processing_Status__c = 'Queued';
   	it.Raw_Data__c = 'matt.collins@engage.mccombs.utexas.edux,mattx,collinsx,matthew.collins+testing@geekluv.comx,1415391647,ACCx_310F-DS-01-05-2015x,ACC 310F Foundations of Accountingx,1420437600';
   	
   	itList.add(it);
   	
   	insert itList;
   	
   	System.Test.startTest();
   	
   	List<Id> itIdList = new List<Id>();
   	
   	for(Integration_Transaction__c itTmp : itList)
   	{
   		itIdList.add(itTmp.Id);
   	}
   	
   	II_ProcessManualIntegrationTransactions.processUTX_Course_Enrollments(itIdList);
         
   	System.Test.stopTest();
   }
}