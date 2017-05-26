trigger SRPAcademicCourseTrigger on DeltakSRP__Academic_Course__c (before insert, before update) {
	
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 

	Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPAcademicCourseTrigger__c);
	
	if(Trigger.isbefore){
		Try{
			List<DeltakSRP__Academic_Course__c> courses = new List<DeltakSRP__Academic_Course__c>();
			for(DeltakSRP__Academic_Course__c c: Trigger.New){
				if(c.DeltakSRP__SIS_External_Id__c != null && c.DeltakSRP__SIS_External_Id__c.startswith('UOB'))
					courses.add(c);
			}
			if(courses.size()>0)
				SRPAcademicCourseTriggerHandler.handlebeforeinsert(courses); 
		}catch(Exception e){
			 DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
		  	 el.DeltakSRP__Partner_Name__c = 'University of Birmingham';
		  	 el.DeltakSRP__Object__c = 'Academic Course';
		  	 el.DeltakSRP__Type__c = 'Integration';
		  	 if(e.getmessage().length()>254)
	  	 		el.DeltakSRP__Detail__c = e.getmessage().substring(0,254);
	  	 	 else
	  	 		el.DeltakSRP__Detail__c = e.getmessage();
		  	 insert el;
		}	
	}
}