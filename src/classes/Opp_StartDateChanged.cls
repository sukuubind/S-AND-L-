public with sharing class Opp_StartDateChanged {


public Opp_StartDateChanged(){
	
}

public static List<Opportunity> findAcademicStartDateRecords(List<Opportunity> opptyList){
Set<id> newProgramIds = new Set<id>();
string startDateERror = 'The selected start date is not available for this student\'s program.';
List < Map <String, Id> > startDateMapList = new List < Map<String, Id> >();
Map<String, Id> startDateMap = new Map<String, Id>();
 Set <String> startDateSet = new Set<String>();
  Map <Id, Id> startDate_to_startDateProgram_map = new Map <Id, Id>();
for(Opportunity o : opptyList) {    
        newProgramIds.add(o.Program__c);
    }
    System.Debug('After First Opportunity For Loop ------'+Limits.getScriptStatements());
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
        System.debug('OpportunityTrigger -add items to startDateMapList'); 
        Integer i = 0;        
        //This creates a list of maps of start dates used to set the lookup to the start date record on the Opportunity
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
    
     System.Debug('After NewProgramIds For Loop ------'+Limits.getScriptStatements());
    
    List<Opportunity> returnOpportunityList = new List<Opportunity>();
        
    for (integer record = 0; record < opptyList.size(); record++) {
        Opportunity newRecord = opptyList[record];
         Boolean academicStartDateFound = false;
        /******************************
        //If the start date changed
        /*******************************/
  //      if (newRecord.Start_Date__c != oldRecord.Start_Date__c && newRecord.Start_Date__c != null) {
                    
            if (!startDateSet.contains(String.valueOf(newRecord.Start_Date__c)+'-'+newRecord.Program__c) ) {
                System.debug('OpportunityTrigger - Error '+startDateERror);
                newRecord.Start_Date__c.addError (startDateERror);
           }
            // If the start date is valid for the current program, set the start date lookup
            else {
                System.debug('OpportunityTrigger - Setting start date lookup on Opportunity');
            
      
            
            
             System.Debug('Before StartDateMapList For Loop ------'+Limits.getScriptStatements());
                //for (  Map <String, Id> sdmap : startDateMapList) {       
                   // System.debug('OpportunityTrigger - Looking for start date ID for '+newRecord.Start_Date__c);        
                    Id startDateID = startDateMap.get(String.valueOf(newRecord.Start_Date__c)+'-'+newRecord.Program__c);
                        if (startDateID != null) {
                            System.debug('OpportunityTrigger - Set Academic_Start_Date__c to '+startDateID);
                            newRecord.Academic_Start_Date__c = startDateID;
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
			newRecord.Academic_Start_Date__c = null;
		}
	}
}
/*public class Opp_StartDateChanged {
	public static final string startDateError = 'The selected start date is not available for this student\'s program.';
	
	public static List <Opportunity> startDateChanged(List <Opportunity>  oldOpps, List <Opportunity> newOpps) {		
		Set <Date> startDateSet = new Set<Date>();
	    List < Map <Date, Id> > startDateMapList = new List < Map<Date, Id> >();
		Map <Id, Id> startDate_to_startDateProgram_map = new Map <Id, Id>();
		Set <id> newProgramIds = new Set<id>();		
		
		System.debug ('New opportunity values ' + newOpps);
		System.debug ('Old opportunity values ' + oldOpps);
		
		System.debug ('Getting list of programs Ids associated with changed Opportunities... ');
		for(Opportunity o : newOpps) {    
	        newProgramIds.add(o.Program__c);	        
	    }
		System.debug ('List of programs Ids associated with changed Opportunities: ' + newProgramIds);
		
		System.debug ('Getting list of startDates associated with changed Opportunities... ');
		Academic_Start_Date__c [] startDates;
		startDates = [select Id, Start_Date__c, Program__c 
	                        FROM Academic_Start_Date__c 
	                        WHERE Program__c IN :newProgramIds];
	                        
		for (Academic_Start_Date__c sd : startDates) {
	    	System.debug('adding start date: ' + sd.Start_Date__c);
	        startDateSet.add(sd.Start_Date__c);  
	        startDate_to_startDateProgram_map.put(sd.Id, sd.Program__c);          
	        startDateMapList.add(new Map <Date, Id>());
	    }
		
		System.debug('Add items to startDateMapList...'); 
        Integer i = 0;        
        //This creates a list of maps of start dates used to set the lookup to the start date record on the Opportunity
        for (Id pg : newProgramIds) {
            for (Academic_Start_Date__c sd : startDates) {
                if (startDate_to_startDateProgram_map.get(sd.Id) == pg) {               
                    System.debug('add start date {' + sd.Start_Date__c + '} For list number {' + i + '} for Program ID {'+pg+'}');
                    //System.debug('OpportunityTrigger - add start date {' + sd.Start_Date__c + '} For list number {' + i + '}');
                    startDateMapList[i].put(sd.Start_Date__c, sd.Id);
                }               
            }
            i++;
        }
        
		System.debug(' --- startDateSete : ' + startDateSet);
		System.debug(' --- startDate_to_startDateProgram_map : ' + startDate_to_startDateProgram_map);
		System.debug(' --- startDateMapList : ' + startDateMapList);
		
		List <Opportunity> errored = new List<Opportunity>();	
			
		for (integer record = 0; record < newOpps.size(); record++) {
	    	Opportunity newRecord = newOpps[record];
	        Opportunity oldRecord = oldOpps[record];  
			
			System.debug(' --- Check if startDateSet contains ' + newRecord.Start_Date__c );		       	    	
	        if (!startDateSet.contains(newRecord.Start_Date__c) ) {
	        	System.debug('Error '+startDateERror);
	        	errored.add(newRecord);
	       	}
	       	
	        // If the start date is valid for the current program, set the start date lookup
	        else {
	        	System.debug('Setting start date lookup on Opportunity');
	        
	            for (  Map <Date, Id> sdmap : startDateMapList) {       
            		System.debug('Looking for start date ID for '+newRecord.Start_Date__c);       	
            		Id startDateID = sdmap.get(newRecord.Start_Date__c);
            		System.debug('startDateID = ' + startDateID);
            		if (startDateID != null) {
            			System.debug('Set Academic_Start_Date__c to '+startDateID);
            			newRecord.Academic_Start_Date__c = startDateID;
            		}
            	}
			}
		}
		
		return errored;
	}
*/