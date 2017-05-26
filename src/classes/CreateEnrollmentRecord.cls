public  class CreateEnrollmentRecord {
	  public  Campus_Contacts__c [] campusContacts;
		public  Map <Id, Id>    Campus_to_employeeID;		
		public  Set <Id>        prgmResponsibilitySetCC;
		public  Set <String>    prgmResponsibilitySetProgram;
		public  Map <Id,String> prgmResponsibilitybyProgramMap;
		public  Map <Id,Id>     account_to_OwnerIDyMap;
		public Boolean prgmResp_ccIdCheck;
	public CreateEnrollmentRecord() {
		
	}
	public CreateEnrollmentRecord(Campus_Contacts__c [] in_campusContacts, 
		Map <Id, Id>    in_Campus_to_employeeID,		
		Set <Id>        in_prgmResponsibilitySetCC,
		Set <String>    in_prgmResponsibilitySetProgram,
		Map <Id,String> in_prgmResponsibilitybyProgramMap,
		Map <Id,Id>     in_account_to_OwnerIDyMap){
				this.campusContacts = 		in_campusContacts;
				this.Campus_to_employeeID = in_Campus_to_employeeID; 
				this.prgmResponsibilitySetCC = in_prgmResponsibilitySetCC;
				this.prgmResponsibilitySetProgram = in_prgmResponsibilitySetProgram; 
				this.prgmResponsibilitybyProgramMap = in_prgmResponsibilitybyProgramMap; 
				this.account_to_OwnerIDyMap = in_account_to_OwnerIDyMap;
					
					}
			
	
	
	public Id getEnrollmentRecOwnerProgramSpecific(Id programid, Id campusId){
		Id OwnerID = null;
			
		//System.debug('OpportunityTrigger - Looking for a program-specific student success coodinator...');
	        //Set the Owner of the enrollment record by looking through the campus contacts                            
	        for (Campus_Contacts__c cc2 : campusContacts) {
	            
	            //Look to see if there is a student success coodinator program responsibility for the program and school                                       
	            if (prgmResponsibilitybyProgramMap.containsKey(cc2.Id) &&
	            	prgmResponsibilitybyProgramMap.get(cc2.Id) == programId &&
	                cc2.Organization__c == campusId) {                               
	                OwnerId = cc2.Employee__r.Id;
	               // System.debug('OpportunityTrigger - Found an student success coodinator with ID '+OwnerId);
	                return OwnerId;
	            }
	        }   
	        
	        return null;
	
	}
	
	public Id getEnrollmentRecOwnerProgramSpecific (
		Campus_Contacts__c [] campusContacts, 
		Map <Id, Id> Campus_to_employeeID,		
		Set<Id> prgmResponsibilitySetCC,
		Set<String> prgmResponsibilitySetProgram,
		Map<Id,String> prgmResponsibilitybyProgramMap,
		Map<Id,Id> account_to_OwnerIDyMap,
		Id programId,
		Id campusId) {
			Id OwnerID = null;
			
		System.debug('OpportunityTrigger - Looking for a program-specific student success coodinator...');
	        //Set the Owner of the enrollment record by looking through the campus contacts                            
	        for (Campus_Contacts__c cc2 : campusContacts) {
	            
	            //Look to see if there is a student success coodinator program responsibility for the program and school                                       
	            if (prgmResponsibilitybyProgramMap.containsKey(cc2.Id) &&
	            	prgmResponsibilitybyProgramMap.get(cc2.Id) == programId &&
	                cc2.Organization__c == campusId) {                               
	                OwnerId = cc2.Employee__r.Id;
	                System.debug('OpportunityTrigger - Found an student success coodinator with ID '+OwnerId);
	                return OwnerId;
	            }
	        }   
	        
	        return null;
	}
	
	public Id getEnrollmentRecOwnerGeneral(Id campusId){
		Id OwnerID = null;
		
	     	//System.debug('OpportunityTrigger - Could not find a program-sepecific student success coodinator. Looking for a general student success coodinator for this campus...');
	        for (Campus_Contacts__c cc : campusContacts) {
	            
	            //if the campus contact does not have any Program Responsibilities assocaited with it
	            if (!prgmResponsibilitySetCC.contains(cc.Id) && 
	                cc.Organization__c == campusId) {
	                OwnerId = cc.Employee__r.Id;                        
	             //   System.debug('OpportunityTrigger - Found a student success coodinator with ID '+OwnerId);
	                return OwnerId;
	            }
	        }
	        return null;
	
	}
	
	public Id getEnrollmentRecOwnerGeneral (
		Campus_Contacts__c [] campusContacts, 
		Map <Id, Id> Campus_to_employeeID,		
		Set<Id> prgmResponsibilitySetCC,
		Set<String> prgmResponsibilitySetProgram,
		Map<Id,String> prgmResponsibilitybyProgramMap,
		Map<Id,Id> account_to_OwnerIDyMap,
		Id campusId) {
			Id OwnerID = null;
		
	     	System.debug('OpportunityTrigger - Could not find a program-sepecific student success coodinator. Looking for a general student success coodinator for this campus...');
	        for (Campus_Contacts__c cc : campusContacts) {
	            
	            //if the campus contact does not have any Program Responsibilities assocaited with it
	            if (!prgmResponsibilitySetCC.contains(cc.Id) && 
	                cc.Organization__c == campusId) {
	                OwnerId = cc.Employee__r.Id;                        
	                System.debug('OpportunityTrigger - Found a student success coodinator with ID '+OwnerId);
	                return OwnerId;
	            }
	        }
	        return null;
	}
		
	public Id enrollmentOwner(Id programId, Id campusId){
		Id OwnerID = null;
	    	
	    	
			OwnerID = getEnrollmentRecOwnerProgramSpecific(
				programId,
				campusId
			);
			
			if (OwnerID != null) {
				return OwnerID;
			}
			
			//If there is no program responsibility which is specific to the program, 
	        //then look for one which is just specific to the school and is a student success coodinator 
			else{
				OwnerID = getEnrollmentRecOwnerGeneral( // VS Bug Fix 692 ownerID = was missing before. The return Id from the method was not assigned to a ownerID variable
					campusId
				);
			}
	    	
	    	if (OwnerID != null) {
				return OwnerID;
			}
			
	        //If there is still no OwnerId set, use the OwnerID of the opportunity's account
	        else {
	            OwnerID = account_to_OwnerIDyMap.get(campusId);
	           // System.debug('OpportunityTrigger - Could not find a student success coodinator. Using OwnerID of the opportunity\'s account. New Owner ID '+OwnerId);
	            
	            if (OwnerID == null) {
	            	//System.debug('OpportunityTrigger - Could not find an account owner for this opportunity\'s account. Check this map: '+account_to_OwnerIDyMap);
	            }
	            else {
	            	return OwnerID;
	            }
	        }
	        
	        return null;	
		
	}
	
	
	public Id enrollmentOwner (		
		Campus_Contacts__c [] campusContacts, 
		Map <Id, Id>    Campus_to_employeeID,		
		Set <Id>        prgmResponsibilitySetCC,
		Set <String>    prgmResponsibilitySetProgram,
		Map <Id,String> prgmResponsibilitybyProgramMap,
		Map <Id,Id>     account_to_OwnerIDyMap,
		Id programId,
		Id campusId) {
			Id OwnerID = null;
	    	
	    	
			OwnerID = getEnrollmentRecOwnerProgramSpecific(
				campusContacts,
				Campus_to_employeeID,				
				prgmResponsibilitySetCC,
				prgmResponsibilitySetProgram,
				prgmResponsibilitybyProgramMap,
				account_to_OwnerIDyMap,
				programId,
				campusId
			);
			
			if (OwnerID != null) {
				return OwnerID;
			}
			
			//If there is no program responsibility which is specific to the program, 
	        //then look for one which is just specific to the school and is a student success coodinator 
			else{
				OwnerID = getEnrollmentRecOwnerGeneral( // VS Bug Fix 692 ownerID = was missing before. The return Id from the method was not assigned to a ownerID variable
					campusContacts,
					Campus_to_employeeID,					
					prgmResponsibilitySetCC,
					prgmResponsibilitySetProgram,
					prgmResponsibilitybyProgramMap,
					account_to_OwnerIDyMap,
					campusId
				);
			}
	    	
	    	if (OwnerID != null) {
				return OwnerID;
			}
			
	        //If there is still no OwnerId set, use the OwnerID of the opportunity's account
	        else {
	            OwnerID = account_to_OwnerIDyMap.get(campusId);
	            System.debug('OpportunityTrigger - Could not find a student success coodinator. Using OwnerID of the opportunity\'s account. New Owner ID '+OwnerId);
	            
	            if (OwnerID == null) {
	            	System.debug('OpportunityTrigger - Could not find an account owner for this opportunity\'s account. Check this map: '+account_to_OwnerIDyMap);
	            }
	            else {
	            	return OwnerID;
	            }
	        }
	        
	        return null;	
		}
}