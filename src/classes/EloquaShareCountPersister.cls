public with sharing class EloquaShareCountPersister {
	//@future
	public static void updateShareCount(Map<String, Integer> shareCountMap, Map<Id, Integer> shareCountMapId){
		List<Contact> contactstoUpdate = new List<Contact>();
		if(shareCountMap != null && shareCountMap.size() > 0){
			List<Contact> contactsFetchedByName = fetchContactForEmail(shareCountMap);
			if(contactsFetchedByName != null && contactsFetchedByName.size() > 0){
				contactstoUpdate.addAll(contactsFetchedByName);
			}
			
		}
		if(shareCountMapId != null && shareCountMapId.size() > 0){
			List<Contact> contactsFetchedById = fetchContactForId(shareCountMapId);
			if(contactsFetchedById != null && contactsFetchedById.size() > 0){
				contactstoUpdate.addAll(contactsFetchedById);
			}
		}
		
		if(contactstoUpdate != null && contactstoUpdate.size() > 0){ 
			
		System.Debug('VS -- Contact List -- '+contactstoUpdate);
			try{
				Database.update(contactstoUpdate);
			}catch(Exception e){
				System.Debug(e);
			}
		}
	}
	
	public static List<Contact> fetchContactForEmail(Map<String, Integer> shareCountMap){
		System.Debug('VS -- Share Count Map --- '+shareCountMap);
		List<String> affiliationIdList = new List<String>();
		List<Contact> contactList = new List<Contact>();
		if(shareCountMap != null && shareCountMap.size() > 0){
			
			for(String afflId : shareCountMap.keySet()){
				affiliationIdList.add(afflId);
			}
			
			 contactList = [Select Id,
												Email,
												Share_Count__c 
											from Contact 
											where Email IN :affiliationIdList
										];
			if(contactList != null && contactList.size() > 0){
				for(Contact thisCont : contactList){
					if(shareCountMap.containsKey(thisCont.Email)){
						thisCont.Share_Count__c = shareCountMap.get(thisCont.Email);
						
					}
				}
			
			
			}
			
			
			
		}
		return contactList;
	}
	
	public static List<Contact> fetchContactForId(Map<Id, Integer> shareCountMap){
				System.Debug('VS -- Share Count Map --- '+shareCountMap);
		List<String> affiliationIdList = new List<String>();
		List<Contact> contactList = new List<Contact>();
		if(shareCountMap != null && shareCountMap.size() > 0){
			
			for(String afflId : shareCountMap.keySet()){
				affiliationIdList.add(afflId);
			}
			
		  contactList = [Select Id,
												Email,
												Share_Count__c 
											from Contact 
											where Id IN :affiliationIdList
										];
			if(contactList != null && contactList.size() > 0){
				for(Contact thisCont : contactList){
					if(shareCountMap.containsKey(thisCont.Id)){
						thisCont.Share_Count__c = shareCountMap.get(thisCont.Id);
						
					}
				}
			System.Debug('VS -- Contact List -- '+contactList);
			
			
			}
			
			
			
		}
	return contactList;
	}
	



}