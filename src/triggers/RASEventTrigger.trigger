trigger RASEventTrigger on Event (before insert, before update) {
	
	String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
	
	/**Set<Id> contactIds = new Set<id>();
	
	for(Event e : Trigger.new){
		contactIds.add(e.WhoId);
	}
	Map<Id, String> idToTimeZone = new Map<Id, String>();
	List<Contact> contactList = [Select 
									c.Id,
									c.Time_Zone__c 
									From Contact c
									Where c.Id in :contactIds
								];
	if(contactList != null && contactList.size() > 0){
		for(Contact thisContact : contactList){
			idToTimeZone.put(thisContact.id, thisContact.Time_Zone__c);
		}
	}
	for(Event e : Trigger.new){
		Id thisContactId = e.WhoId;
		if(idToTimeZone != null && idToTimeZone.containsKey(thisContactId)){
			String timeZone = idToTimeZone.get(thisContactId);
			System.debug('Time Zone '+timeZone);
			e.Time_Zone__c = timeZone;
		}
	}**/
}