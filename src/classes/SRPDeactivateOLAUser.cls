global with sharing class SRPDeactivateOLAUser implements Database.Batchable<Sobject>{

	String query;
	String pId = '00e60000000z146';

	// Constructor
	global SRPDeactivateOLAUser() {
	
	} 
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		query = 'SELECT Id, ContactId FROM User WHERE ProfileId =\'' + pId + '\'AND IsActive = true ';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<User> scope) {
	  	
//	  	List<User> uId = new List<User>();
//	  	scope =  uId;

	  	deactivateUsers(scope);
	} 
           
    global void finish(Database.BatchableContext BC){

  	} 
  	
	public void deactivateUsers(List<User> scope)
	{
		// Users with following stages and substages should be active
		String[] stageNames = new String[]{'New Inquiry','Initiated Communication','Appointment Scheduled','Appointment Completed',
											'Pending Application','Booked Qualified Application','Completed File'};	
			 
		String[] dormantSubStages = new String[]{'Longterm Interest No Timeframe',
										   'Long Term Strategic Relationship','Longterm Interest'};	
										   
		String[] rollSubStages = new String[]{'Start Next Term'};									   
		
//		List<User> uId = new List<User>();
		
//		uId = [SELECT Id, ContactId FROM User WHERE ProfileId = :pId AND IsActive = true];

		// Map where contactId is key and userId is value
		Map<Id, Id> contactUserIds = new Map<Id, Id>();
	
	// replaced uId with scope after writing batchable
		if(scope.size() != 0)
		{
			for(Integer i=0; i< scope.size();i++)
			{
				contactUserIds.put(scope.get(i).ContactId,scope.get(i).Id);
			}
		
		}
	
		// List of all contactIds
		Set<Id> cId = contactUserIds.keySet();
	
		List<Opportunity> doNotDeactivate = new List<Opportunity>();
		
		doNotDeactivate = [SELECT DeltakSRP__Student__c FROM Opportunity 
		 				   WHERE (
		 						 	(StageName IN :stageNames) OR
				 			     	(StageName='Dormant' AND (DeltakSRP__Sub_Stage__c IN :dormantSubStages )) OR
				 			     	(StageName='Roll' AND (DeltakSRP__Sub_Stage__c IN :rollSubStages ))
		 			  			 )	
		 			  	   AND DeltakSRP__Student__c IN :cId];		
		 			  	   
	//	List<Id> usersToActivate = new List<Id>();	
		List<Id> usersToDeactivate = new List<Id>();	
	
	//	List<User> activeUsers = new List<User>();	
		List<User> deactiveUsers = new List<User>();

		Set<Id> studentCidInQuery = new Set<Id>();
		
		if(doNotDeactivate.size() > 0)
		{
			for(Opportunity j:doNotDeactivate)
			{
				studentCidInQuery.add(j.DeltakSRP__Student__c);
			}
		}
		
		for (Id k:contactUserIds.keySet())
		{ 		
			if(!studentCidInQuery.contains(k))
			{
				usersToDeactivate.add(contactuserIds.get(k));
			}
			
		}
		
	// make IsActive flag false for those records to be deactivated
		for(Id k:usersToDeactivate)
		{
			User u = new User(Id=k);
			
			u.isactive = false;
			deactiveUsers.add(u);
		}
			
	//	update Users to deactivate;
		if(deactiveUsers.size() > 0)
			update deactiveUsers;
	
	}
}