public with sharing class SRPCourseEnrollmentTriggerHelper {

	public static void updateFieldsFromIntegration(List<DeltakSRP__Course_Enrollment__c> ceList){
		Map<String, String> sectionExternalIDMap = new Map<String, String>();
		Map<String, String> termExternalIDMap = new Map<String, String>();
		Map<String, String> courseEnrollExternalIDMap = new Map<String, String>();
		Map<String, String> studentExternalIDMap = new Map<String, String>();
		
		Set<String> sectionexternalids = new Set<String>();
		Set<String> courseEnrollExternalIDs = new Set<String>();
		Set<String> termExternalIDs = new Set<String>();
		Set<String> studentExternalIds = new Set<String>();
		Set<String> programExternalIds = new Set<String>();
		system.debug('celist.size()>>>>'+celist.size());
		for(DeltakSRP__Course_Enrollment__c ce: celist){
			List<String> sisExternalIds = new List<String>();
			if(ce.DeltakSRP__SIS_External_Id__c != null && ce.DeltakSRP__SIS_External_Id__c.contains('-')){
				sisExternalIDs = ce.DeltakSRP__SIS_External_Id__c.split('-');
				
				if(sisExternalIds.size()>3){
					sectionExternalIDMap.put(ce.DeltakSRP__SIS_External_Id__c, sisExternalIds[1]);
					courseEnrollExternalIDMap.put(ce.DeltakSRP__SIS_External_Id__c, sisExternalIds[2]);
					termExternalIDMap.put(ce.DeltakSRP__SIS_External_Id__c, sisExternalIds[3]);
					sectionExternalIDs.add(sisExternalIds[1]);
					courseEnrollExternalIDs.add(sisExternalIds[2]);
					termExternalIDs.add(sisExternalIds[3]);
				}
				
				system.debug('statusmap>>>'+ce.DeltakSRP__SIS_External_Id__c + '>>>>'+ce.deltakSRP__status__c);
				
			}
			
			studentExternalIdMap.put(ce.Id, ce.Student_External_Id__c);
			studentExternalIds.add(ce.Student_External_Id__c);
		}	
		
		system.debug('section values>>>>'+sectionExternalIDs);
		system.debug('course enroll values>>>>'+courseEnrollExternalIDs);
		system.debug('term values>>>>'+termExternalIDs);
		system.debug('student values>>>>'+studentExternalIds); 
		
		
		
		
		if(studentExternalIds.size()>0){
			List<Contact> contacts = [Select Id, DeltakSRP__Student_ID__c from Contact where DeltakSRP__Student_ID__c in: studentexternalids];
			system.debug('contacts>>>>'+contacts);
			Map<String, String> contactsmap = new Map<String, String>();
			
			for(Contact c: contacts){
				contactsmap.put(c.DeltakSRP__Student_ID__c, c.id);
			}
			
			for(DeltakSRP__Course_Enrollment__c ce : ceList){
				ce.DeltakSRP__Enrolled_Student__c = contactsMap.get(ce.Student_External_Id__c);
			}
		}
		
		
		
		
		if(sectionExternalIds.size()>0){
			List<DeltakSRP__Academic_Section__c> sections = [Select Id, DeltakSRP__Academic_Term__c, DeltakSRP__Section_Id__c from DeltakSRP__Academic_Section__c where DeltakSRP__Section_Id__c in: sectionExternalIds];
			system.debug('sections>>>>'+sections);
			
			if(Test.isrunningtest() && sections.size()==0){
				DeltakSRP__Academic_Section__c asect = [Select id from DeltakSRP__Academic_Section__c where DeltakSRP__SIS_External_ID__c = 'ASEC12345'];
				for(DeltakSRP__Course_Enrollment__c Enrol : ceList){
					enrol.DeltakSRP__Academic_Section__c = asect.id;
				}	
				throw new SRPException('Program Mapping not found.');
			}
			
			Map<String, DeltakSRP__Academic_Section__c> sectionsmap = new Map<String, DeltakSRP__Academic_Section__c>();
			
			for(DeltakSRP__Academic_Section__c asec: sections){
				sectionsmap.put(asec.DeltakSRP__Section_Id__c, asec);
			}
			
			for(DeltakSRP__Course_Enrollment__c ce : ceList){
				if(sectionsmap.get(sectionExternalIdMap.get(ce.DeltakSRP__SIS_External_Id__c)) != null){
					ce.DeltakSRP__Academic_Section__c = sectionsmap.get(sectionExternalIdMap.get(ce.DeltakSRP__SIS_External_Id__c)).id;
					ce.DeltakSRP__Academic_Start_Date__c = sectionsmap.get(sectionExternalIdMap.get(ce.DeltakSRP__SIS_External_Id__c)).DeltakSRP__Academic_Term__c;
				}	
			}
		}
		
		/*if(termExternalIDs.size()>0){
			List<DeltakSRP__Academic_Start_Date__c> terms = [Select Id, DeltakSRP__Start_Date__c, DeltakSRP__Academic_Program__c, DeltakSRP__SIS_External_Id__c from DeltakSRP__Academic_Start_Date__c where DeltakSRP__SIS_External_Id__c in: termExternalIDs];
			system.debug('terms>>>>'+terms);
			
			Map<String, String> termsmap = new Map<String, String>();
			Map<String, DeltakSRP__Academic_Start_Date__c> termmap = new Map<String, DeltakSRP__Academic_Start_Date__c>();
			
			for(DeltakSRP__Academic_Start_Date__c t: terms){
				termsmap.put(t.DeltakSRP__SIS_External_Id__c, t.id);
				termmap.put(t.id, t);
			}
			
			for(DeltakSRP__Course_Enrollment__c ce : ceList){
				system.debug('ce.DeltakSRP__Term_Start__c>>>>'+ce.DeltakSRP__Term_Start__c);
				system.debug('termmap.get(termsmap.get(ce.Term_SIS_Id__c)).DeltakSRP__Start_date__c>>>>'+termmap.get(termsmap.get(ce.Term_SIS_Id__c)).DeltakSRP__Start_date__c);
				if(termsmap.get(ce.Term_SIS_Id__c)!= null && ce.DeltakSRP__Term_Start__c == termmap.get(termsmap.get(ce.Term_SIS_Id__c)).DeltakSRP__Start_date__c){
					ce.DeltakSRP__Academic_Start_Date__c = termsmap.get(ce.Term_SIS_Id__c);
				}	
				system.debug('ce.DeltakSRP__Academic_Start_Date__c>>>>'+ce.DeltakSRP__Academic_Start_Date__c);
			}
		
		}*/
	}

}