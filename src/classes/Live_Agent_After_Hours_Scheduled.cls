global class Live_Agent_After_Hours_Scheduled implements Schedulable {
   
   global void execute(SchedulableContext SC) {
		
		List<User> uList = [SELECT Id, Is_After_Hours_Enabled__c, ProfileId, After_Hours_Profile_Id__c, Normal_Hours_Profile_Id__c, 
			Is_After_Hours_User__c, After_Hours_Cluster__c FROM User
					WHERE Is_After_Hours_User__c = TRUE AND UserPermissionsLiveAgentUser = TRUE];
		
		List<User> uListToUpdate = new List<User>();
		
		for(User u : uList)
		{
			try {
				
				Id normalHoursId = Id.valueOf(u.Normal_Hours_Profile_Id__c);
				
				if(normalHoursId != u.ProfileId || u.Is_After_Hours_Enabled__c)
				{
					u.ProfileId = normalHoursId;
					u.Is_After_Hours_Enabled__c = false;
					
					uListToUpdate.add(u);
				}
				
				
			} catch(Exception e){
				
			}
			
		}
		
		if(uListToUpdate.size() > 0)
		{
			update uListToUpdate;
		}
		
   }
   
   
}