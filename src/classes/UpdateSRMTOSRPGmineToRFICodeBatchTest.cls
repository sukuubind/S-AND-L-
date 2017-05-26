@isTest
private class UpdateSRMTOSRPGmineToRFICodeBatchTest {

    static testMethod void myUnitTest() {
        Account a = new Account();
        a.Abbreviation__c = 'TAC';
        a.name = 'test account';
        insert a;
        
        Academic_Program__c ap = new Academic_Program__c();
        ap.School__c = a.Id;
        insert ap;
        
        DeltakSRP__Academic_Program__c dap = new DeltakSRP__Academic_Program__c();
        dap.DeltakSRP__School__c = a.Id;
        dap.Academic_Program__c = ap.Id;
        insert dap;
        
        Academic_Specialization__c asp = new Academic_Specialization__c();
        asp.Academic_Program__c = ap.Id;
        insert asp;
        
        /*DeltakSRP__Academic_Specialization__c das = new DeltakSRP__Academic_Specialization__c();
        das.DeltakSRP__Academic_Program__c = dap.Id;
        das.SRM_Academic_Specialization__c = asp.Id;
        insert das;*/
        
        List<Goldmine_to_Salesforce_Program__c> GMSFToInsert = new List<Goldmine_to_Salesforce_Program__c>();
        //for(Integer i=0; i<200; i++){
            Goldmine_to_Salesforce_Program__c gmsf = new Goldmine_to_Salesforce_Program__c();
			gmsf.Goldmine_Program__c = 'testCode';   
			gmsf.Account__c = a.Id;
			gmsf.Program_Id__c = ap.id;
			gmsf.Specialization_Id__c = asp.id;        
            GMSFToInsert.add(gmsf);
        //}
        insert GMSFToInsert;
        
        Integer GMSFcount = [Select count() from Goldmine_to_Salesforce_Program__c];
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Opportunities');
            UpdateSRMTOSRPGoldmineToRFIProgCodeBatch testObj = new UpdateSRMTOSRPGoldmineToRFIProgCodeBatch(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
            Id BatchId = Database.executeBatch(testObj, 200);
        test.stoptest();     
        Integer RFIPCCount = [Select count() from RFI_to_Academic_Programs_Code__c];
        
        system.assertequals(GMSFCount, RFIPCCount);
    }   
    
    private static String postChatterGroupFeedItem(String targetUpdate)
	{
		String chatterFeedItemId;
		
		 
		CollaborationGroup cg = new CollaborationGroup();
		cg.Name = 'SRM To SRP Migration Status Test';
		cg.CollaborationType='Private';
		insert cg;
		
		String chatterFeedId = cg.Id + '';
		
		if(chatterFeedId != null && chatterFeedId != '')
		{
		
			FeedItem fi = new FeedItem();
	      	fi.Body = 'Update ' + targetUpdate + ' batch process queued by [' + UserInfo.getUserEmail() +']';
	      	fi.ParentId = chatterFeedId;
	      	insert fi;
	      
	      	chatterFeedItemId = fi.Id + '';
		
		}
		
		return chatterFeedItemId;
		
	}
    
}