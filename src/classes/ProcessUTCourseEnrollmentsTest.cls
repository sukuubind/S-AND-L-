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
private class ProcessUTCourseEnrollmentsTest {

   static testMethod void TestinBoundEmail()
   {
   		RecordType aRT = [SELECT Id, Name FROM RecordType WHERE Name = 'SRP Academic Institution' LIMIT 1];
   		RecordType cRT = [SELECT Id, Name FROM RecordType WHERE Name = 'SRP Student' LIMIT 1];
   		RecordType oRT = [SELECT Id, Name FROM RecordType WHERE Name = 'SRP Opportunity' LIMIT 1];
   		
   		List<Account> accList = [SELECT Id, Name FROM Account WHERE Name = 'University of Texas at Austin' AND RecordTypeId = :aRT.Id LIMIT 1];
   		
   		Account a = new Account();
   		if(accList != null && accList.size() > 0)
   		{
   			a = accList[0];
   		}
   		else
   		{
   			a.Name = 'University of Texas at Austin';
   			a.RecordTypeId = aRT.Id;
   			insert a;
   		}
   		
   		Contact c = new Contact();
   		c.RecordTypeId = cRT.Id;
   		c.FirstName = 'mattx';
   		c.LastName = 'collinsx';
   		c.Email = 'matthew.collins+testing@geekluv.comx';
   		c.AccountId = a.Id;
   		insert c;
   		
   		Contact c2 = new Contact();
   		c2.RecordTypeId = cRT.Id;
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
   		o.RecordTypeId = oRT.Id;
   		o.Name = 'test';
   		o.stageName = 'New Inquiry';
   		o.CloseDate = DateTime.newInstance(2100,1,1).date();
   		o.AccountId = a.Id;
   		o.DeltakSRP__Student__c = c.Id;
   		o.DeltakSRP__Academic_Program__c = ap.Id;
   		insert o;
   		
       // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Test';
      email.fromAddress = 'someaddress@deltak-innovation.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      //build binary csv attachment
      String binaryCSV = 'uniqueid,firstname,lastname,email,enrollmentdate,shortname,fullname,startdate\n';
		binaryCSV += 'matt.collins@engage.mccombs.utexas.edux,mattx,collinsx,matthew.collins+testing@geekluv.comx,1415391647,ACCx_310F-DS-01-05-2015x,ACC 310F Foundations of Accountingx,1420437600\n';
		binaryCSV += 'matthew.collins@engage.mccombs.utexas.edux,matthewx,collinsx,matthew.collins@geekluv.comx,1416324661,BFP_ALLx,Business Foundations Program Certificatex,1415422800\n';
		binaryCSV += 'matthew.collins@engage.mccombs.utexas.edux,matthewx,collinsx,matthew.collins@geekluv.comx,1415985196,LEBx_320F-DS-01-05-2015x,LEB 320F Foundations of the Legal Environment of Businessx,1420437600';
      
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf(binaryCSV);
      attachment.fileName = 'sample-2.csv';
      attachment.mimeTypeSubType = 'text/csv';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
      
  
      // add an Text atatchment
		/*  
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
      */
      
      // call the email service class and test it with the data in the testMethod
      ProcessUTCourseEnrollments  testInbound=new ProcessUTCourseEnrollments ();
      testInbound.handleInboundEmail(email, env);
    	
      Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.UT_Course_Enrollment__c.fields.getMap();
    	List<String> fieldList = new List<String>();
    	for(String s : schemaFieldMap.keySet())
    	{
      	fieldList.add(s);
    	}
    
    	String q = 'SELECT ' + String.join(fieldList,',') + 
    	' FROM UT_Course_Enrollment__c WHERE Status__c = \'New\'';
    	Id batchInstanceId = Database.executeBatch(new UTCourseEnrollmentBatchProcess(q), 5);  
      	batchInstanceId = Database.executeBatch(new UTCourseEnrollmentBatchProcess(q), 5); 
      	
      	List<UT_Course_Enrollment__c> ceList = [Select Id, Status__c FROM UT_Course_Enrollment__c WHERE Student_Last_Name__c = 'collinsx'];
      
		for(UT_Course_Enrollment__c ce : ceList)
		{
			ce.Status__c = 'New';
		}
		
		update ceList;
		
		batchInstanceId = Database.executeBatch(new UTCourseEnrollmentBatchProcess(q), 5);
     
   
   }
    
    static testMethod void TestScheduled()
   {
   	System.Test.startTest();
   		String jobId = System.schedule('testBasicScheduledApex', '0 0 0 1 1 ? 2099', new UTCourseEnrollmentScheduler());
   		
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