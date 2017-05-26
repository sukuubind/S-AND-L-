trigger SRPAcademicSectionTrigger on DeltakSRP__Academic_Section__c (before insert) {
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 

	Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPAcademicSectionTrigger__c); 
        
     if(Trigger.isbefore){
     	String errorMessage;
     	try{
     		List<DeltakSRP__Academic_Section__c> sections = new List<DeltakSRP__Academic_Section__c>();
			for(DeltakSRP__Academic_Section__c s: Trigger.New){
				if(s.DeltakSRP__SIS_External_Id__c != null && s.DeltakSRP__SIS_External_Id__c.startswith('UOB'))
					sections.add(s);
			}		
			if(sections.size()>0)	
     			SRPAcademicSectionTriggerHandler.onBeforeInsert(sections);
     		
     	}catch(Exception e){
     		 system.debug('e.getmessage>>>>'+e.getmessage()); 
     		 SRPAcademicSectionTriggerHandler.insertErrorLog(e.getmessage(), 'Academic Section', 'SRPAcademicSectionTrigger');
     	} 
     }   
        
}