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
private class DataPurgeJobTest {

    static testMethod void TestScheduled()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'test';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 50000;
   		dpj.Batch_Size__c = 200;
   		dpj.Remove_From_Recycle_Bin__c = true;
   		dpj.Mode__c = 'Once Daily';
   		
   		insert dpj;
   		
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new DataPurgeJobSchedule());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
   
   static testMethod void TestOnDemand()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Contact c2 = new Contact();
   		c2.firstName = 'testDPJ';
   		c2.lastName = 'testDPJ';
   		c2.Email = 'DPJ@WLY.COM';
   		
   		insert c2;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'test';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\' OR Id = \'' + c2.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 1;
   		dpj.Batch_Size__c = 1;
   		dpj.Remove_From_Recycle_Bin__c = true;
   		dpj.Mode__c = 'On Demand';
   		dpj.Chain_Runs__c = true;
   		
   		insert dpj;
   		
   	System.Test.startTest();
   	DataPurgeJobSchedule dpjs = new DataPurgeJobSchedule();
   	dpjs.kickoffBatch(dpj.Id);
         
   	System.Test.stopTest();
   	
   } 
   
   static testMethod void TestScheduledErrorSchedule()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'ERRORSCHEDULE';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 50000;
   		dpj.Batch_Size__c = 200;
   		dpj.Mode__c = 'Once Daily';
   		
   		insert dpj;
   		
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new DataPurgeJobSchedule());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		
      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
   
   static testMethod void TestScheduledErrorBatchJob()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'ERRORBATCHJOB';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 50000;
   		dpj.Batch_Size__c = 200;
   		dpj.Mode__c = 'Once Daily';
   		
   		insert dpj;
   		
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new DataPurgeJobSchedule());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		
      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
   
   static testMethod void TestScheduledErrorBatch()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'ERRORBATCH';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 50000;
   		dpj.Batch_Size__c = 200;
   		dpj.Mode__c = 'Once Daily';
   		
   		insert dpj;
   		
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new DataPurgeJobSchedule());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		
      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
   
   static testMethod void TestScheduledErrorBatchFinish()
   	{
   		DateTime dt = DateTime.now();
   		
   		Contact c = new Contact();
   		c.firstName = 'testDPJ';
   		c.lastName = 'testDPJ';
   		c.Email = 'DPJ@WLY.COM';
   		
   		insert c;
   		
   		Data_Purge_Job__c dpj = new Data_Purge_Job__c();
   		dpj.Name = 'ERRORBATCHFINISH';
   		dpj.Object_API_Name__c = 'Contact';
   		dpj.Query_Condition__c = 'Id = \'' + c.Id + '\'';
   		dpj.Status__c = 'Ready';
   		dpj.Query_Limit__c = 50000;
   		dpj.Batch_Size__c = 200;
   		dpj.Mode__c = 'Once Daily';
   		
   		insert dpj;
   		
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new DataPurgeJobSchedule());
   		
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		
      // Verify the expressions are the same
      System.assertEquals('0 0 0 1 1 ? 2099', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2099-01-01 00:00:00', String.valueOf(ct.NextFireTime));
         
   	System.Test.stopTest();
   	
   } 
   
   
}