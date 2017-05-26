@isTest(SeeAllData=false)
private class updateSrmToSrpAcademicStartDateTest {

    static testMethod void myUnitTest() {
      
        String currentProfileId = userinfo.getProfileId();
		currentProfileId = currentProfileId.substring(0, 15);
		
		upsert new SRP_Profiles_List__c(
  		  Name = 'sandbox',
   		  ProfileId__c = currentProfileId
		);
      
      List<Academic_Start_Date__c > asdtoinsert = new List<Academic_Start_Date__c >();
      
      Account a = new Account();
      a.Abbreviation__c = 'TAC';
      a.name = 'test account';
      insert a;
      
      Academic_Program__c ap = new Academic_Program__c();
      ap.School__c = a.Id;
      insert ap;
      
      for(Integer i=0; i<200; i++){
          Academic_Start_Date__c  asd = new Academic_Start_Date__c ();
          asd.Start_Date__c = system.today();
          asd.end_date__c = system.today() + 365;
          asd.program__c = ap.Id;
         asdtoinsert.add(asd);
      }
        
        insert asdtoinsert;
        
        integer srpasdcount = [Select count() from Deltaksrp__Academic_Start_Date__c];
        
        System.Test.startTest();
        	String chatterFeedItemId = postChatterGroupFeedItem('Academic Start Dates');
          updateSrmToSrpAcademicStartDate testObj = new updateSrmToSrpAcademicStartDate(a.id,chatterFeedItemId,new List<String>{'test@email.com'});
          Id BatchId = Database.executeBatch(testObj, 200);
        system.test.stoptest();
        
        integer srpasdcount2 = [Select count() from DeltakSRP__Academic_Start_Date__c]; 
        
        //system.assertequals(srpasdcount + 200, srpasdcount2);
      
        
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