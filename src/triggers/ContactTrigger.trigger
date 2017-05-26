trigger ContactTrigger on Contact (after update) { 
	
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
	
	User loggedInUser = [SELECT LastName, Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
	boolean updFlag = false;
	
   if (!(loggedInUser.Profile.Name.contains('Integration'))) {
	    	
		Set<Id> TriggerIds = new Set<Id>();
		Map<Id,Id> oppId_to_ContactID = new Map<Id,Id>();
		Map<id,Opportunity> oppsToUpdate = new Map<id,Opportunity>();
		
		 //get the record types and put them in a map
       	Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
       	Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();				
		List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();				
		for (Schema.RecordTypeInfo rtInfo : RT) {
			System.debug(rtInfo.getName());
			System.debug(rtInfo.getRecordTypeId());
			recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );			
		}
		
	    //get the new WhatIDs pulled in trhough the trigger
	    for(Contact c : Trigger.new) {
	    	String RecTtype = c.RecordTypeId;
            if (RecTtype == '' || RecTtype == null || recordTypeName_to_recordTypeId.get('Deltak Student') == RecTtype) {
	        	TriggerIds.add(c.Id);      
            }           
	    }
	     
	    
	    Opportunity [] Opps =  [select Id, Student__c, Email_from_Student__c, Student__r.Employer_Company__c
	                               FROM Opportunity 
	                               WHERE Student__c IN :TriggerIds
	                               AND RecordType.Name = 'Student Opportunity'
	                               AND StageName != 'Start' 
	                               AND StageName != 'Closed Duplicate'
	                               ];
	    
	    for (Opportunity o : Opps) {	    	   	
	    			oppsToUpdate.put(o.Id, o);
	    			oppId_to_ContactID.put(o.Id, o.Student__c);
	    }
	   
	   	
		for (integer record = 0; record < trigger.size; record++) {
			for (Opportunity o : Opps) {
				System.debug('*** ContactTrigger - Opportunity ID: '+ o.Id);
				System.debug('*** ContactTrigger - oppId_to_ContactID.get(o.Id): '+ oppId_to_ContactID.get(o.Id));
				System.debug('*** ContactTrigger - Contact ID being updated: '+ trigger.new[record].Id);
				System.debug('*** ContactTrigger - Before updating, the Email_from_Student__c = ' + o.Email_from_Student__c); 
				
				if ((oppId_to_ContactID.get(o.Id) == trigger.new[record].Id)) {		
					System.debug('*** ContactTrigger - 	Update Email_from_Student__c to ' + trigger.new[record].Email);
					if(oppsToUpdate.get(o.id).Email_from_Student__c !=trigger.new[record].Email){//added by AbhaS 02/12
						oppsToUpdate.get(o.id).Email_from_Student__c = trigger.new[record].Email;
					} //added by AbhaS 02/12
				}				
			}		 
		}
		
		String errorMsg = '';		
		Map<Id, String> emsgContactId = new Map<Id, String>();
				
		//update the opportunities
		try{
		    update oppsToUpdate.values();
		}
		catch(System.DmlException e){	
			
			for(Integer i=0;i< e.getNumDml();i++){
				errorMsg = e.getDmlMessage(i);
				if(errorMsg.contains('Employer/Company value is required to move to this Opportunity stage. Please update on the Student Affiliation record.')==true){
					System.debug('ErrorMSG- '+ errorMsg  + ' ----' + e.getDmlId(i));
					
					Id OppId = Id.valueOf(e.getDmlId(i));
					emsgContactId.put(oppId_to_ContactID.get(OppId), errorMsg);
					
				}
			}
			 Contact [] contacts =  [select Id  FROM Contact  WHERE Id IN :trigger.new ];
	         
	         for(Contact c: contacts){
				System.debug('Error Message - '+emsgContactId.get(c.Id));
				trigger.new[0].addError(errorMsg);
	         }
		}      
    }
}