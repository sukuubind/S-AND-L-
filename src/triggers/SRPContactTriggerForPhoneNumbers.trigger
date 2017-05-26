trigger SRPContactTriggerForPhoneNumbers on Contact (before insert, before update) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPContactTriggerForPhoneNumbers__c);   
    
    if(bypassTrigger)   return;
    
        
    for(Contact c: Trigger.New){  
    	if((c.mobilephone == null || c.mobilephone=='') && c.DeltakSRPSMS__Ok_To_Text__c == true){        	
	  		if(c.DeltakSRP__Work_Phone__c!=null && c.DeltakSRP__Work_Phone__c!='') 
	  			c.mobilephone = c.DeltakSRP__Work_Phone__c;
	  			
	  		if(c.homephone!=null && c.homephone!='')	
	  			c.mobilephone = c.homephone;
	  		
	  		if(c.phone!=null && c.phone!='')
	  			c.mobilephone = c.phone;
    	}		
  		
	}
    
    if(trigger.isinsert){
	    List<Contact> contacts = new List<Contact>();
	    
	    for(Contact c: Trigger.New){
	    	if(c.recordtypeid == DeltakSRP__SRP_Partner_Settings__c.getinstance().DeltakSRP__Contact_Record_Type_Id__c){
	    	  system.debug('c.firstname>>>>'+c.firstname);
	    	  system.debug('c.lastname>>>>'+c.lastname);
	    	  system.debug('c.email>>>>'+c.email);
	    	  system.debug('c.accountid>>>>'+c.accountid);
              if(trigger.isbefore){		
                  if(c.firstname!=null && c.firstname.length() > 1)
                  	  c.firstname = c.firstname.substring(0,1).toUpperCase()+c.firstname.substring(1,c.firstname.length()).toLowerCase();
                  if(c.lastname!=null && c.lastname.length() > 1)
                  	  c.lastname = c.lastname.substring(0,1).toUpperCase()+c.lastname.substring(1,c.lastname.length()).toLowerCase();
                  contacts.add(c);	  
                  
                  
                  
              }
	    	}	
	    }
		
		system.debug('contacts>>>>'+contacts);
		SRPContactTriggerHandler.onbeforeInsert(contacts);
	}
	
	if(trigger.isupdate){
	    List<Contact> contacts = new List<Contact>();
	    
	    for(Contact c: Trigger.New){
	    	if(c.recordtypeid == DeltakSRP__SRP_Partner_Settings__c.getinstance().DeltakSRP__Contact_Record_Type_Id__c &&(
	    		Trigger.oldmap.get(c.id).phone != Trigger.newmap.get(c.id).phone ||
	    		Trigger.oldmap.get(c.id).homephone != Trigger.newmap.get(c.id).homephone ||
	    		Trigger.oldmap.get(c.id).DeltakSRP__Work_Phone__c != Trigger.newmap.get(c.id).DeltakSRP__Work_Phone__c || 
	    		Trigger.oldmap.get(c.id).mobilephone != Trigger.newmap.get(c.id).mobilephone || 
	    		Trigger.oldmap.get(c.id).mailingcountry != Trigger.newmap.get(c.id).mailingcountry ||
	    		Trigger.oldmap.get(c.id).mailingstate != Trigger.newmap.get(c.id).mailingstate))
	    		contacts.add(c);
	    }
		
		system.debug('contacts.size>>>>'+contacts.size()); 
		system.debug('contacts>>>>'+contacts);
		SRPContactTriggerHandler.onbeforeInsert(contacts);
	}


	if(trigger.isupdate && trigger.isBefore) {
		SRPContactTriggerHandler.onBeforeUpdateFormatPhone(Trigger.new,Trigger.oldMap);
	}
}