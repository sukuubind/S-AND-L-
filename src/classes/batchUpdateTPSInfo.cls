global class batchUpdateTPSInfo implements Database.Batchable<sObject>{
	global final String Query;
	global final String Entity;
	global final String Field;
	global final String Value;

	global batchUpdateTPSInfo(String q, String e, String f, String v){
		Query=q; Entity=e; Field=f;Value=v;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
		
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		
		for(sObject s : scope){
			 if(s.getsObjectType() == Opportunity.sObjectType) {
			 	
			 	Opportunity o = (Opportunity)s;
			 	 
			 	List <Decimal> fileCompleteSet = new List <Decimal> ();			 	
				fileCompleteSet.add(o.X1_Day__c);
				fileCompleteSet.add(o.X2_Day__c);
				fileCompleteSet.add(o.X3_Day__c);
				fileCompleteSet.add(o.X4_Day__c);
				fileCompleteSet.add(o.X5_Day__c);
				fileCompleteSet.add(o.X6_Day__c);
				fileCompleteSet.add(o.X7_Day__c);
				fileCompleteSet.add(o.X8_Day__c);
				fileCompleteSet.add(o.X9_Day__c);
				fileCompleteSet.add(o.X10_Day__c);
				fileCompleteSet.add(o.X11_Day__c);
				fileCompleteSet.add(o.X12_Day__c);
				fileCompleteSet.add(o.X13_Day__c);
				fileCompleteSet.add(o.X14_Day__c);			 
				
				//Set X1 to the current File Complete percentage
				o.X1_Day__c = o.File_Complete__c;
				o.X1_Day__c = o.DeltakSRP__File_Complete__c;
				
				//move all other values up one day
				//Note that fileCompleteSet[13] (the 14th value) is dropped off of the list intentionally
			 	o.X2_Day__c = fileCompleteSet[0];
			 	o.X3_Day__c = fileCompleteSet[1];
			 	o.X4_Day__c = fileCompleteSet[2];
			 	o.X5_Day__c = fileCompleteSet[3];
			 	o.X6_Day__c = fileCompleteSet[4];
			 	o.X7_Day__c = fileCompleteSet[5];
			 	o.X8_Day__c = fileCompleteSet[6];
			 	o.X9_Day__c = fileCompleteSet[7];
			 	o.X10_Day__c = fileCompleteSet[8];
			 	o.X11_Day__c = fileCompleteSet[9];
			 	o.X12_Day__c = fileCompleteSet[10];
			 	o.X13_Day__c = fileCompleteSet[11];
			 	o.X14_Day__c = fileCompleteSet[12];	
			 			 	
				
				//add the opportunity to the list to be updated
				oppsToUpdate.add(o);
			 }
		} 
    	
    	try {
			update oppsToUpdate;
		}
		
		catch(Exception e){
			System.Debug('Error' + e);
		}
    }
    
	global void finish(Database.BatchableContext BC){
	}
	 static  testmethod void batchUpdateTPSInfoTest(){
		
			Test.startTest();
				DateTime t=System.now();
		        date d = Date.newInstance(t.year(),t.month(),t.day());
		        
		        Account a = new Account();
		    	a.Name = 'Test Account';
		    	insert a;    
		    	
				Opportunity o = new Opportunity();
		        o.CloseDate=d;
		        o.StageName='New Inquiry';        
		        o.Name='Test';
		        o.AccountID=a.Id;
		        o.X1_Day__c = 2.0; 
		        o.X2_Day__c = 2.0;
		        o.X3_Day__c = 2.0;
		        o.X4_Day__c = 2.0;
		        o.X5_Day__c = 2.0;
		        o.X6_Day__c = 2.0;
		        o.X7_Day__c = 2.0;
		        o.X8_Day__c = 2.0;
		        o.X9_Day__c = 2.0;
		        o.X10_Day__c = 2.0;
		        o.X11_Day__c = 2.0;
		        o.X12_Day__c = 2.0;
		        o.X13_Day__c = 2.0;
		        o.X14_Day__c = 2.0;  
		        o.Start_Date__c = system.today()-6;          
		        insert o;
		    
				String query = 'SELECT Id, File_Complete__c, X1_Day__c, X2_Day__c, X3_Day__c, X4_Day__c, ' +
		            'X5_Day__c, X6_Day__c, X7_Day__c, X8_Day__c, X9_Day__c, X10_Day__c, '       +
		            'X11_Day__c, X12_Day__c,X13_Day__c, X14_Day__c FROM Opportunity LIMIT 1';
		
		        batchUpdateTPSInfo batchupdate = new  batchUpdateTPSInfo(query, '', '', '');
				ID TPSBatchJobID = Database.executeBatch(batchupdate); 
	        Test.stopTest();     	
              
	}
}