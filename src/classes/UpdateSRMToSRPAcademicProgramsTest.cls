@isTest(SeeAllData=false)
private class UpdateSRMToSRPAcademicProgramsTest {

    static testMethod void myUnitTest() {
        Account a = new Account();
    	a.Abbreviation__c = 'TAC';
    	a.name = 'test account';
    	insert a;
    	
    	//Id srmStudentRecordType = [Select Id from RecordType where name= 'Deltak Student'].Id;
    	
    	List<Academic_Program__c> ProgramsToInsert = new List<Academic_Program__c>();
        for(Integer i=0; i<200; i++){
        	Academic_Program__c ap = new Academic_Program__c();
        	ap.School__c = a.Id;
        	ProgramsToInsert.add(ap);
        }
        insert programsToinsert;
        
        integer srpapcount = [Select count() from DeltakSRP__Academic_Program__c];
        test.starttest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Academic Programs');
	        UpdateSrmToSrpAcademicPrograms testObj = new UpdateSrmToSrpAcademicPrograms(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
	        Id BatchId = Database.executeBatch(testObj, 200); 
        test.stoptest();
        integer srpapcount2 = [Select count() from DeltakSRP__Academic_Program__c];
        
        system.assertequals(srpapcount + 200, srpapcount2);
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