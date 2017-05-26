public with sharing class SRPAcademicSectionTriggerHandler {
	
	public static void insertErrorLog(String errormessage, string errorobject, string errorClass){
		 DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
	  	 el.DeltakSRP__Partner_Name__c = 'UOB';
	  	 el.DeltakSRP__Object__c = errorObject;
	  	 el.DeltakSRP__Source_Name__c = errorClass;
	  	 el.DeltakSRP__Type__c = 'Integration';
	  	 if(errormessage.length()>254)
  	 		el.DeltakSRP__Detail__c = errormessage.substring(0,254);
  	 	 else
  	 		el.DeltakSRP__Detail__c =errormessage;
	  	 insert el;
	  	 system.debug('el.id>>>>'+el.id);
	}
	
	public static void onBeforeInsert(List<DeltakSRP__Academic_Section__c> sections){
		list<Date> termStartDates = new list<Date>();
		list<String> courseExternalIDs = new list<String>();
		list<String> termSISIDs = new list<String>();
		List<String> externalIDs = new List<String>();
		Map<String, String> courseidsmap = new Map<String, String>();
		Map<String, String> termsismap = new Map<String, String>();
		Map<Id, DeltakSRP__Academic_Start_Date__c> terms2update = new Map<Id, DeltakSRP__Academic_Start_Date__c>();
		
		system.debug('sections.size()>>>>'+sections.size());
		
		for(DeltakSRP__Academic_Section__c sec : sections){
			if(sec.DeltakSRP__SIS_External_Id__c != null && sec.DeltakSRP__SIS_External_Id__c.contains('-')){
				system.debug('sec.DeltakSRP__SIS_External_Id__c>>>>'+sec.DeltakSRP__SIS_External_Id__c);
				externalIDs=sec.DeltakSRP__SIS_External_Id__c.split('-');
				if(externalids.size()>4){
					courseExternalIDs.add(externalids[0]+' - '+externalids[6]+' - '+externalids[2]);
					courseidsMap.put(sec.DeltakSRP__SIS_External_Id__c, externalids[0]+' - '+externalids[6]+' - '+externalids[2]);
				}	
			}	
			
			if(sec.term_sis_id__c != null){
				system.debug('sec.term_sis_id__c>>>>'+sec.term_sis_id__c);
				termsismap.put(sec.DeltakSRP__SIS_External_Id__c, sec.term_sis_id__c);
			}
			
			if(sec.Start_Date__c != null){
				system.debug('sec.Start_Date__c>>>>'+sec.Start_Date__c);
				termstartdates.add(sec.Start_Date__c);
			}	
			
		}
		
		
		system.debug('courseExternalIDs.size()>>>>'+courseExternalIDs.size());
		system.debug('courseExternalIDs>>>>'+courseExternalIDs);
		
		
		Map<String, DeltakSRP__Academic_Course__c> coursemap = new Map<String, DeltakSRP__Academic_Course__c>();
		if(courseExternalIDs.size()>0){
			List<DeltakSRP__Academic_Course__c> courses = [Select Id, DeltakSRP__Primary_Program__c, DeltakSRP__SIS_External_ID__c from DeltakSRP__Academic_Course__c where DeltakSRP__SIS_External_ID__c in: courseExternalIDs];
			system.debug('courses>>>>'+courses);
			Map<String, String> coursesmap = new Map<String, String>();
			
			for(DeltakSRP__Academic_Course__c c: courses){
				coursesmap.put(c.DeltakSRP__SIS_External_ID__c, c.id);
				coursemap.put(c.id, c);
			}
			
			system.debug('courseExternalIDs>>>>'+courseExternalIDs);
			
			for(DeltakSRP__Academic_Section__c sec : sections){
				
				if(sec.DeltakSRP__Academic_Course__c == null)
					sec.DeltakSRP__Academic_Course__c = coursesMap.get(courseidsMap.get(sec.DeltakSRP__SIS_External_Id__c));
				
				if(sec.DeltakSRP__Academic_Course__c == null){
					throw new SRPException('Course Mapping not found.');
				}
				
			}
			
			
		}
		
		
		system.debug('termstartdates>>>>'+termstartdates);
		
		
		if(termstartdates.size()>0){
			List<DeltakSRP__Academic_Start_Date__c> terms = [Select Id, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_ID__c, DeltakSRP__Academic_Program__c, DeltakSRP__Start_date__c, DeltakSRP__SIS_External_Id__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__Start_date__c in: termstartdates];
			system.debug('terms>>>>'+terms);
			
			/*if(Test.isrunningtest() && terms.size()==0){
				List<DeltakSRP__Academic_Start_Date__c> terms2 = [Select Id, DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_ID__c, DeltakSRP__SIS_External_Id__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__SIS_External_Id__c = 'AT12345'];
				for(DeltakSRP__Academic_Section__c sec : sections){
					sec.DeltakSRP__Academic_Term__c = terms2[0].id;
				}
				
				Exception e;
				throw e;
			}*/
			
			Map<String, String> termsmap = new Map<String, String>();
			Map<String, DeltakSRP__Academic_Start_Date__c> termmap = new Map<String, DeltakSRP__Academic_Start_Date__c>();
			
			for(DeltakSRP__Academic_Start_Date__c t: terms){
				termsmap.put(t.DeltakSRP__Start_date__c+t.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_ID__c, t.id);
				termmap.put(t.id, t);
			}
			system.debug('termmap>>>>'+termmap);
			system.debug('termsmap>>>>'+termsmap);
			for(DeltakSRP__Academic_Section__c sec : sections){
				system.debug('sec.start_date__c>>>>'+sec.start_date__c);
				system.debug('coursemap.get(sec.DeltakSRP__Academic_Course__c).DeltakSRP__Primary_Program__c>>>>'+coursemap.get(sec.DeltakSRP__Academic_Course__c).DeltakSRP__Primary_Program__c);
				system.debug('termmap.get(termsmap.get(sec.start_date__c+sec.program_SIS_Id__c))>>>>'+termmap.get(termsmap.get(sec.start_date__c+sec.program_SIS_Id__c)));
				if(termmap.get(termsmap.get(sec.start_date__c+sec.program_SIS_Id__c)) != null){
					if(coursemap.get(sec.DeltakSRP__Academic_Course__c)!=null && termmap.get(termsmap.get(sec.start_date__c+sec.program_SIS_Id__c)).deltakSRP__Academic_Program__c == coursemap.get(sec.DeltakSRP__Academic_Course__c).DeltakSRP__Primary_Program__c)
						sec.DeltakSRP__Academic_Term__c = termsmap.get(sec.start_date__c+sec.program_SIS_Id__c);
						//system.debug('sec.DeltakSRP__Academic_Term__c>>>>'+sec.DeltakSRP__Academic_Term__c);
				}else{
					//insertErrorLog('Terms not mapping', 'Academic Section', 'SRPAcademicSectionTrigger');
					sec.adderror('Terms not mapping');
					//break;
				}
				
				if(sec.start_date__c != null && sec.DeltakSRP__Academic_Term__c!=null && termsismap.get(sec.DeltakSRP__SIS_External_Id__c)!=null && termmap.get(sec.DeltakSRP__Academic_Term__c) != null && (termmap.get(sec.DeltakSRP__Academic_Term__c).DeltakSRP__SIS_External_Id__c == '' || termmap.get(sec.DeltakSRP__Academic_Term__c).DeltakSRP__SIS_External_Id__c == null || termmap.get(sec.DeltakSRP__Academic_Term__c).DeltakSRP__SIS_External_Id__c == 'SISTID')){
					DeltakSRP__Academic_Start_Date__c t = new DeltakSRP__Academic_Start_Date__c(id=sec.DeltakSRP__Academic_Term__c);
					t.DeltakSRP__SIS_External_ID__c = 'UOB-' + sec.Program_SIS_ID__c + '-' + termsismap.get(sec.DeltakSRP__SIS_External_Id__c)+'-'+sec.start_date__c.format(); 
					terms2update.put(t.id, t);
				}
				
				system.debug('sec.DeltakSRP__Academic_Term__c2>>>>'+sec.DeltakSRP__Academic_Term__c);
			}
		
		}
		
		//if(terms2update!= null && terms2update.keyset().size()>0)
			//update terms2update.values();
		
	}

}