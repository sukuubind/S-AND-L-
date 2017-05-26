trigger SE_SetAcademicStartDate on Student_Enrollment__c (before insert, before update) {
	
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
	
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
    if (!loggedInUser.Profile.Name.contains('Integration')) {
        Set<id> newProgramIds = new Set<id>();
        final string startDateERror = 'The selected start date is not available for this student\'s program.';
        
        List < Map <String, Id> > startDateMapList = new List < Map<String, Id> >();
        Map<String, Id> startDateMap = new Map<String, Id>();
        Set <String> startDateSet = new Set<String>();
        Map <Id, Id> startDate_to_startDateProgram_map = new Map <Id, Id>();
        
        for (integer record = 0; record < trigger.new.size(); record++) {
            newProgramIds.add(trigger.new[record].Program__c);                
        }   
        
        System.Debug('After First For Loop ------'+Limits.getScriptStatements());
        
        Academic_Start_Date__c [] startDates;
        startDates = [select Id, Start_Date__c, Program__c 
                        FROM Academic_Start_Date__c
                        WHERE Program__c IN :newProgramIds];
                        
        for (Academic_Start_Date__c sd : startDates) {
            System.debug('OpportunityTrigger - adding start date: '+sd.Start_Date__c);
            startDateSet.add(String.valueOf(sd.Start_Date__c)+'-'+sd.Program__c);  
            startDate_to_startDateProgram_map.put(sd.Id, sd.Program__c);          
            startDateMapList.add(new Map <String, Id>());
        }
        
        System.Debug('After Academic StartDate For Loop ------'+Limits.getScriptStatements());    
        System.debug('Student_Enrollment__c -add items to startDateMapList'); 
        
        Integer i = 0;        
        //This creates a list of maps of start dates used to set the lookup to the start date record on the Student_Enrollment__c 
        for (Id pg : newProgramIds) {
            for (Academic_Start_Date__c sd : startDates) {
              if (startDate_to_startDateProgram_map.get(sd.Id) == pg) {              
                System.debug('OpportunityTrigger - add start date {' + sd.Start_Date__c + '} For list number {' + i + '} for Program ID {'+pg+'}');
                //System.debug('OpportunityTrigger - add start date {' + sd.Start_Date__c + '} For list number {' + i + '}');
                  startDateMapList[i].put(String.valueOf(sd.Start_Date__c)+'-'+pg, sd.Id);
                  startDateMap.put(String.valueOf(sd.Start_Date__c)+'-'+pg, sd.Id);
              }               
            }
            i++;
        }
        
        
        
        for (integer record = 0; record < trigger.new.size(); record++) {
        Student_Enrollment__c newRecord = trigger.new[record];        
        Student_Enrollment__c oldRecord;
         
        if (trigger.isUpdate) {
        	oldRecord = trigger.old[record];
        }
        
        Boolean academicStartDateFound = false;
        
        /******************************
        //If the start date changed
        /*******************************/
        if ( (trigger.isUpdate && newRecord.Start_Date__c != oldRecord.Start_Date__c) || trigger.isInsert) {
            if (!startDateSet.contains(String.valueOf(newRecord.Start_Date__c)+'-'+newRecord.Program__c) ) {
                System.debug('Error '+startDateERror);
                newRecord.Start_Date__c.addError (startDateERror);
            }
            // If the start date is valid for the current program, set the start date lookup
            else {
                System.debug(' Setting start date lookup on Student_Enrollment__c ');
            
                 System.Debug('Before StartDateMapList For Loop ------'+Limits.getScriptStatements());
                 Id startDateID = startDateMap.get(String.valueOf(newRecord.Start_Date__c)+'-'+newRecord.Program__c);
                        if (startDateID != null) {
                            System.debug('Set Academic_Start_Date__c to '+startDateID);
                            newRecord.Academic_Start_Date__c = startDateID;
                            academicStartDateFound = true;
                        }
            }
            System.Debug('After StartDateMapList For Loop ------'+Limits.getScriptStatements());
          } 
      } 
  }
}