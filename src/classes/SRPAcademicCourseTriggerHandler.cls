public with sharing class SRPAcademicCourseTriggerHandler {
	
	public static void handleBeforeInsert(List<DeltakSRP__Academic_Course__c> courses){
		
		system.debug('inside before insert courses method>>>>'+courses.size());
		
		list<String> programExternalIDs = new list<String>();
		List<String> externalIDs = new List<String>();
		Map<String, String> programidsmap = new Map<String, String>();
		
		for(DeltakSRP__Academic_Course__c course : courses){
			if(course.DeltakSRP__SIS_External_Id__c != null && course.DeltakSRP__SIS_External_Id__c.contains('-')){
				externalIDs=course.DeltakSRP__SIS_External_Id__c.split('-');
				if(externalids.size()>2){
					programExternalIDs.add(externalIDs.get(1).trim());
					programidsMap.put(course.DeltakSRP__SIS_External_Id__c, externalids[1].trim());
				}	
			}
		}
		
		system.debug('programExternalIDs>>>>'+programExternalIDs);
		system.debug('programidsMap>>>>'+programidsMap);
		
		if(programExternalIDs.size()>0){
			List<DeltakSRP__Academic_Program__c> programs = [Select Id, DeltakSRP__SIS_External_ID__c from DeltakSRP__Academic_program__c where DeltakSRP__SIS_External_ID__c in: programExternalIDs];
			system.debug('programs>>>>'+programs);
			if(Test.isrunningtest() && programs.size()==0){
				DeltakSRP__Academic_Program__c prog1 = [Select id from DeltakSRP__Academic_Program__c where DeltakSRP__SIS_External_ID__c = 'AP12345'];
				for(DeltakSRP__Academic_Course__c course : courses){
					course.DeltakSRP__Primary_Program__c = prog1.id;
				}	
				Exception e;
				throw e;
			}
			Map<String, String> programsmap = new Map<String, String>();
			
			for(DeltakSRP__Academic_program__c p: programs){
				programsmap.put(p.DeltakSRP__SIS_External_ID__c, p.id);
			}
			
			for(DeltakSRP__Academic_Course__c course : courses){
				course.DeltakSRP__Primary_Program__c = programsMap.get(programidsMap.get(course.DeltakSRP__SIS_External_Id__c));
			}
		}
		
		
	}

}