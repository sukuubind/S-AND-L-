public with sharing class SRPOpp_StartDateChanged {
	public SRPOpp_StartDateChanged(){
		
	}
	
	public static List<Opportunity> findAcademicStartDateRecords(List<Opportunity> opptyList){
	Set<id> newProgramIds = new Set<id>();
	string startDateERror = 'The selected start date is not available for this student\'s program.';
	List < Map <String, Id> > startDateMapList = new List < Map<String, Id> >();
	Map<String, Id> startDateMap = new Map<String, Id>();
	 Set <String> startDateSet = new Set<String>();
	  Map <Id, Id> startDate_to_startDateProgram_map = new Map <Id, Id>();
	for(Opportunity o : opptyList) {    
	        newProgramIds.add(o.DeltakSRP__Academic_Program__c);
	    }
	    System.Debug('After First Opportunity For Loop ------'+Limits.getScriptStatements());
	    DeltakSRP__Academic_Start_Date__c [] startDates;
	    startDates = [select Id, DeltakSRP__Start_Date__c, DeltakSRP__Academic_Program__c 
	                        FROM DeltakSRP__Academic_Start_Date__c
	                        WHERE DeltakSRP__Academic_Program__c IN :newProgramIds];
	                        
	   for (DeltakSRP__Academic_Start_Date__c sd : startDates) {
	        	System.debug('OpportunityTrigger - adding start date: '+sd.deltakSRP__Start_Date__c);
	            startDateSet.add(String.valueOf(sd.DeltakSRP__Start_Date__c)+'-'+sd.DeltakSRP__Academic_Program__c);  
	            startDate_to_startDateProgram_map.put(sd.Id, sd.DeltakSRP__Academic_Program__c);          
	            startDateMapList.add(new Map <String, Id>());
	        }
	        system.debug('startdateset>>>>'+startdateset);
	     System.Debug('After Academic StartDate For Loop ------'+Limits.getScriptStatements());    
	        System.debug('OpportunityTrigger -add items to startDateMapList'); 
	        Integer i = 0;        
	        //This creates a list of maps of start dates used to set the lookup to the start date record on the Opportunity
	        for (Id pg : newProgramIds) {
	            for (deltaksrp__Academic_Start_Date__c sd : startDates) {
	            	if (startDate_to_startDateProgram_map.get(sd.Id) == pg) {            	
	            		System.debug('OpportunityTrigger - add start date {' + sd.deltaksrp__Start_Date__c + '} For list number {' + i + '} for Program ID {'+pg+'}');
	            		//System.debug('OpportunityTrigger - add start date {' + sd.Start_Date__c + '} For list number {' + i + '}');
	                	startDateMapList[i].put(String.valueOf(sd.deltaksrp__Start_Date__c)+'-'+pg, sd.Id);
	                	startDateMap.put(String.valueOf(sd.deltaksrp__Start_Date__c)+'-'+pg, sd.Id);
	            	}               
	            }
	            i++;
	        }
	    
	     System.Debug('After NewProgramIds For Loop ------'+Limits.getScriptStatements());
	    
	    List<Opportunity> returnOpportunityList = new List<Opportunity>();
	        
	    for (integer record = 0; record < opptyList.size(); record++) {
	        Opportunity newRecord = opptyList[record];
	         Boolean academicStartDateFound = false;
	        /******************************
	        //If the start date changed
	        /*******************************/
	  //      if (newRecord.Start_Date__c != oldRecord.Start_Date__c && newRecord.Start_Date__c != null) {
	  			system.debug('startdateset>>>>'+startdateset);
	            system.debug('newRecord.deltaksrp__Academic_Start_Date__r.DeltakSRP__Start_Date__c)+newRecord.deltaksrp__academic_Program__c) >>>>' + string.valueof(newRecord.DeltakSRP__Start_Date__c) + '-' + string.valueof(newRecord.deltaksrp__academic_Program__c));
	            if (!startDateSet.contains(String.valueOf(newRecord.DeltakSRP__Start_Date__c)+'-'+newRecord.deltaksrp__academic_Program__c) ) {
	                System.debug('OpportunityTrigger - Error '+startDateERror);
	                newRecord.deltaksrp__Start_Date__c.addError (startDateERror);
	           }
	            // If the start date is valid for the current program, set the start date lookup
	            else {
	                System.debug('OpportunityTrigger - Setting start date lookup on Opportunity');
	            
	      
	            
	            
	             System.Debug('Before StartDateMapList For Loop ------'+Limits.getScriptStatements());
	                //for (  Map <String, Id> sdmap : startDateMapList) {       
	                   // System.debug('OpportunityTrigger - Looking for start date ID for '+newRecord.Start_Date__c);        
	                    Id startDateID = startDateMap.get(String.valueOf(newRecord.deltaksrp__Start_Date__c)+'-'+newRecord.deltaksrp__academic_Program__c);
	                        if (startDateID != null) {
	                            System.debug('OpportunityTrigger - Set Academic_Start_Date__c to '+startDateID);
	                            newRecord.deltaksrp__Academic_Start_Date__c = startDateID;
	                            academicStartDateFound = true;
	                        }
	                    }
	                     System.Debug('After StartDateMapList For Loop ------'+Limits.getScriptStatements());
	                //}
	 //           }
	 		if(academicStartDateFound)
	            returnOpportunityList.add(newRecord);
	        }
	        System.Debug('After FINAL Opportunity For Loop ------'+Limits.getScriptStatements());
		return returnOpportunityList;
		}
	
		public static void startDateChangedToNull (List <Opportunity> newOpps) {
			for (integer record = 0; record < newOpps.size(); record++) {
		    	Opportunity newRecord = newOpps[record];	 
		    	System.debug('Set Opportunity ' + newRecord.Id  + '\'s Academic_Start_Date__c to NULL...');
				newRecord.deltaksrp__Academic_Start_Date__c = null;
			}
		}
}