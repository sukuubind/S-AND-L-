public without sharing class ProspectCaseHandler {
    
    
    public static Map<String, String> keyWordToCaseType = null;
    
    
    public String findType(String subject){
    	 keyWordToCaseType = new Map<String, String>();
    	 Map<String, String> lowercaseversionToActual = new Map<String, String>();
    	for (Prospect_Case_Type_Assignment__c pcta : Prospect_Case_Type_Assignment__c.getAll().values()){ 
    		keyWordToCaseType.put(pcta.Name, pcta.Case_Type__c);
    		lowercaseversionToActual.put(pcta.Name.toLowerCase(), pcta.Case_Type__c);
    	}
    	String[] subjectSplit = subject.split(' ',-1);
    	System.Debug('subjectSplit -- '+subjectSplit);
    	System.Debug('keyWordToCaseType -- '+keyWordToCaseType);
    	for(String thisSub : subjectSplit){
    		String lowerCaseThisSub = thisSub.toLowerCase();
    		if(lowercaseversionToActual != null && lowercaseversionToActual.containsKey(lowerCaseThisSub)){
    			
    			String actualType = lowercaseversionToActual.get(lowerCaseThisSub); 
    			return actualType;// keyWordToCaseType.get(thisSub);
    		}
    	}
    	
    	
    	
    	return null;
    }
    
   
    
    public void ProspectCaseHandler(){
    	 
    	
    	
    	
    }
    public void intelligentlySetCaseType(List<Case> caseList){
    	Set<String> supportedRecordTypes = new Set<String>(); 
	    Schema.DescribeSObjectResult d = Schema.SObjectType.Case; 
		Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
	   
	    Schema.RecordTypeInfo rtByName =  rtMapByName.get('SRP Help');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
		
		rtByName =  rtMapByName.get('SRP Customer');
		supportedRecordTypes.add(rtByName.getRecordTypeId());
    	
    	
    	Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
    	
    	for(Case c  :caseList){
    		String recordTypeId = c.RecordTypeId;
            	if(!supportedRecordTypes.contains(recordTypeId)){
	    			continue;
	    		} 
    		String typeOfCase = null;
    		typeOfCase = findType(c.Subject);
    		if(typeOfCase == null){
    			typeOfCase = findType(c.Description);
    		}
	    	System.Debug('typeOfCase -- '+typeOfCase);
	    	if(typeOfCase == null){
	    		typeOfCase = 'Other';
	    	}
	    	if(typeOfCase != null){
	    		c.OwnerId = setting.PROspect_User_ID__c;
	    		c.Type = typeOfCase;
	    		if(c.contactId == null){
	    		    c.contactId = setting.Prospect_Deltak_Staff_ID__c;
	    		}
	    	}
    	
    	
    	}
    	
    }
   
}