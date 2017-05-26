public with sharing class SRPOpportunityTriggerHandler {

public void handleBeforeInsert(List<Opportunity> opptyIds)
{
    addParentName(opptyIds);
} 
public void handleLockDownDates(List<Opportunity> newOpptyList){
    List<Id> termIds = new List<Id>();
    Map<Id, Id> opptyIdToTermId = new Map<id, Id>();
    for(Opportunity opp : newOpptyList){
        termIds.add(opp.DeltakSRP__Academic_Start_Date__c);
        opptyIdToTermId.put(opp.id, opp.DeltakSRP__Academic_Start_Date__c);
    }
    System.Debug('opptyIdToTermId -- '+opptyIdToTermId);
    List<DeltakSRP__Academic_Start_Date__c> termsList = [Select Id, Lock_Down_Date__c from DeltakSRP__Academic_Start_Date__c where Id IN :opptyIdToTermId.values()];
    Map<Id, Date> termIdToLockDownDate = new Map<Id, Date>();
    for(DeltakSRP__Academic_Start_Date__c thisTerm : termsList){
        termIdToLockDownDate.put(thisTerm.Id, thisTerm.Lock_Down_Date__c);
    }
    System.Debug('termIdToLockDownDate -- '+termIdToLockDownDate);
    for(Opportunity opp : newOpptyList){
        Id termId = opptyIdToTermId.get(opp.id);
        if(termId != null && termIdToLockDownDate != null && termIdToLockDownDate.containsKey(termId) && termIdToLockDownDate.get(termId) != null){
            opp.Term_Lock_Down_Date__c = termIdToLockDownDate.get(termId);
            System.Debug('opp.id -- '+opp.id);
        }
        
    }
}
public void handleRestrictedStates(List<Opportunity> newOpptyList){
    List<Id> programids = new List<Id>();
    List<Id> accountids = new List<id>();
    System.Debug('newOpptyList -- '+newOpptyList);
    for(Opportunity opp : newOpptyList){
        if(opp.SRP_Mailing_State__c != null && opp.SRP_Mailing_State__c != ''){
            programids.add(opp.DeltakSRP__Academic_Program__c);
            accountids.add(opp.AccountId);
        }
    }
    System.Debug('programids -- '+programids);
    System.Debug('accountids -- '+accountids);
    List<Account> accounts = [Select Id, OwnerId from Account where Id IN :accountids];
    Map<Id, Id> accountidtoownerid = new Map<id, Id>();
    for(Account a : accounts){
        accountidtoownerid.put(a.id, a.ownerid);
    }
    System.Debug('accountidtoownerid--'+accountidtoownerid);
    List<DeltakSRP__Academic_Program__c> srpProgramList = [Select id, Restricted_States__c from DeltakSRP__Academic_Program__c where Id IN :programIds];
    System.Debug('srpProgramList -- '+srpProgramList);
    Map<Id, Set<String>> programToRestrictedStates = new Map<Id, Set<String>>();
    for(DeltakSRP__Academic_Program__c thisProgram : srpProgramList) {
        if(thisProgram.Restricted_States__c != null){
            List<String> stateList = new List<String>();
            stateList = thisProgram.Restricted_States__c.split(';');
            Set<String> stateSet = new Set<String>();       
            if(stateList.size() > 0)
            {
                for(String s : stateList)
                {
                    stateSet.add(s.trim().toUpperCase());
                }
            }
        programToRestrictedStates.put(thisProgram.Id, stateSet);
        }
        
        
    }
    System.Debug('programToRestrictedStates -- '+programToRestrictedStates);
    for(Opportunity opp : newOpptyList){
        System.Debug('opp.DeltakSRP__Academic_Program__c -- '+opp.DeltakSRP__Academic_Program__c);
        if(programToRestrictedStates != null && programToRestrictedStates.containsKey(opp.DeltakSRP__Academic_Program__c)){
            Set<String> stateSet = programToRestrictedStates.get(opp.DeltakSRP__Academic_Program__c);
            System.Debug('opp.SRP_Mailing_State__c -- '+opp.SRP_Mailing_State__c);
            System.Debug('stateSet -- '+stateSet);
            System.Debug('accountidtoownerid.get(opp.Accountid) -- '+accountidtoownerid.get(opp.Accountid));
            if(opp.SRP_Mailing_State__c != null && opp.SRP_Mailing_State__c != ''){
                if(stateSet != null && stateSet.contains(opp.SRP_Mailing_State__c.trim().toUpperCase())){
                    
                    opp.stageName = 'Dormant';
                    opp.DeltakSRP__Sub_Stage__c = 'State Restricted';
                    opp.ownerid = accountidtoownerid.get(opp.Accountid);
                }
                System.Debug('opp -- '+opp); 
            }
        }
    }
    
    
    
}
public void handleNotes(List<Opportunity> newOppList, List<Opportunity> oldOppList){
	
	system.debug('in handle Notes');
	
	Map<Id, Boolean> prospectSupportedAccount = new Map<Id, Boolean>();
    Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
    List<String> supportedAccountRecordTypes = new List<String>();
    supportedAccountRecordTypes.add(ProspectConstants.SRP_ACCOUNT_RECORDTYPE);
    supportedAccountRecordTypes.add(ProspectConstants.SRM_ACCOUNT_RECORDTYPE);
    List<Account> accountList = [Select Id, PRO_Distribution_End_Hours__c, PRO_Distribution_Hours_End_Minutes__c, 
                                        PRO_Distribution_Hours_Escalation_Minute__c, PRO_Distribution_Hours_Start_Minutes__c,
                                        PRO_Distribution_Start_Hours__c, PROspect_Enabled__c from Account
                                        Where Account.RecordType.DeveloperName IN :supportedAccountRecordTypes];                                        
                                        
    for(Account thisAccount : accountList){
        prospectSupportedAccount.put(thisAccount.Id, thisAccount.PROspect_Enabled__c);
    }        
	DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
	Id leadEngineUserid = null;
    
	// Girija starts    
    system.debug('in parseNotesField');
	DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();  
	system.debug('settings'+settings);
	List<String> recordType = new List<String>();
    recordType.add('Deltak: Student Event');
    recordType.add('Deltak: Student');
	List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordType];
 	Map<String, Id> recordTypeNameToId = new Map<String, Id>();
 	if(recordTypes != null && recordTypes.size() > 0)
 	{
        for(RecordType thisRecordType : recordTypes){
            recordTypeNameToId.put(thisRecordType.Name, thisRecordType.Id);
        }
    }       
    List<Event> eventListToInsert = new List<Event>();    
    List<Task> taskListToInsert = new List<Task>();    
  
	for(Integer i=0;i<newOppList.size();i++)
	{		 
		Opportunity o = newOppList[i];
		Opportunity oldO = oldOppList[i];
		 //Girija: SRP-1562- Notes parsing code starts here
	        // if opportunity is JHUAAP oppty, this code will check if the Notes field has 'Event Date:'
	        // If yes, it will parse the notes and will insert Event and Task  
	    if(prospectSupportedAccount != null && prospectSupportedAccount.containsKey(o.AccountId) && prospectSupportedAccount.get(o.AccountId)){
            leadEngineUserid = setting.PROspect_User_ID__c;
        }else{
            leadEngineUserid = partnersettings.SRP_Lead_Engine_UserId__c;
        }
		String notesField = oldO.LP_NOTES__c;
		
		if(oldO.ownerId == leadEngineUserid && (oldO.ownerid != o.ownerid))
      	{   
			if(o.AccountId == settings.JHUAAP_AccountId__c && notesField != null && notesField.length() > 0 && notesField.contains('Event Date:'))
	        {  
	        	String eventString = notesField.replaceAll('Event Date:', '').Trim(); 
	        	//at this point we should have smthg like "2016-25-02-11-15-00"
	        	List<String> eventList = eventString.split('-');            	
	        	List<Integer> eventInts = new List<Integer>();            	
	        	if(eventList.size() == 6)
	        	{            	
	        		eventInts.add(Integer.valueOf(eventList[0]));	//year
	        		eventInts.add(Integer.valueOf(eventList[1]));	//month
	        		eventInts.add(Integer.valueOf(eventList[2]));	//day
	        		eventInts.add(Integer.valueOf(eventList[3]));	//hour
	        		eventInts.add(Integer.valueOf(eventList[4]));	//minute
	        		eventInts.add(Integer.valueOf(eventList[5]));	//second            		
	        	}          	
	        	DateTime eventDTstart = null;            	
	        	if(eventInts.size() == 6)
	        	{            		
	        		eventDTstart = DateTime.newInstance(eventInts[0],eventInts[1],eventInts[2],eventInts[3],eventInts[4],eventInts[5]);	//in Eastern Timezone
	        		eventDTstart = eventDTstart.addHours(-1);	//convert to Central Timezone            		
	        	}            	
	        	if(eventDTstart != null && eventDTstart > DateTime.now())
	        	{           		
	        		DateTime eventDTend = eventDTstart.addMinutes(30);            		
	        		Event e = new Event();
	        		e.RecordTypeId = recordTypeNameToId.get('Deltak: Student Event');
	        		e.OwnerId = o.OwnerId;
	        		e.Subject = 'RFI Appointment';
	        		e.Type = 'Call';
	        		e.WhatId = o.id;
	        		e.WhoId = o.Student__c ;
	        		e.StartDateTime = eventDTstart;
	        		e.EndDateTime = eventDTEnd;         		
	        	//	insert e;      
	        	    eventListToInsert.add(e);  	
	        		Id eventId = e.Id;
	        		
	        		Task t = new Task();
	        		t.RecordTypeId = recordTypeNameToId.get('Deltak: Student');
	        		t.OwnerId = o.OwnerId;
	        		t.Subject = 'RFI Appointment';
	        		t.Type = 'Call - Outbound';
	        		t.WhatId = o.id;
	        		t.WhoId = o.Student__c ;
	        		t.Status = 'Not Started';
	        		t.Priority = 'Normal';
	        		t.ActivityDate = eventDTstart.date();
	        		
	        		taskListToInsert.add(t);
	        	}                	
	        } 
      }
	}
	// inserts event for the created opportunity - JHU AAP related
    if(eventListToInsert != null && eventListToInsert.size() > 0)
    	insert eventListToInsert;	
    
    //inserts Task for the created opportunity - JHU AAP related 
    Database.DMLOptions dmlo = new Database.DMLOptions();
	dmlo.EmailHeader.triggerUserEmail = true;
	if(taskListToInsert != null && taskListToInsert.size() > 0)
		database.insert(taskListToInsert, dmlo); 
    //Girija: SRP-1562- Notes parsing code ENDS here
    
}
public void addParentName(List<Opportunity> opptyIds)
{
    // store Campaign Id and respective parent name from Campaign in campaignDetails list
    List<Campaign> campaignDetails = new List<Campaign>();    
    campaignDetails = [SELECT Id, Parent.Name FROM Campaign where Lowest_Level_in_Hierarchy__c = true and ((campaign_code__c != null and campaign_code__c != '') or name = 'Bucket')];
    // Build a map of Campaign Id and parent name
    Map<Id,String> parentNameCampId = new Map<Id,String>();
    if(campaignDetails.size() !=0)
    {   
        for(Integer i=0; i<=campaignDetails.size()-1; i++)
        {
            parentNameCampId.put(campaignDetails.get(i).Id,campaignDetails.get(i).Parent.Name);
        }
    }
    system.debug('MAP'+parentNameCampId);
    if(opptyIds.size()>0)
    { 
        for(Opportunity o : opptyIds)
        {
            String parentCampaignName = parentNameCampId.get(o.campaignId);
            o.Parent_Name__c = parentCampaignName;
            system.debug('PARENT'+o.Parent_Name__c);
        }
    }    
}
public void handleNotesBeforeInsert(List<Opportunity> opptyIds)
{
    DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
    if(opptyIds.size()>0 && opptyIds != null)
    {           
        for(Opportunity o : opptyIds)
        {                       
        //Girija: SRP-1562 Notes parsing    
        // Notes parsing for 'country of citizenship' and 'type of law degree' code starts here     
            String notesField = o.LP_NOTES__c;              
            String typeOfLawDegree = '';
            String CountryOfCitizenship = '';               
            if(notesField != null && notesField.length() > 0)
            {                           
                List<String> splitString = new List<string>();                  
                splitString = notesField.split('\\|');
                system.debug('splitString--->>>'+splitString);
                if(splitString.size()>0)
                {
                    for(String s: splitstring)
                    {
                        if(s.contains('Country_Of_Citizenship'))
                        {
                            List<String> slist = s.split('Country_Of_Citizenship: ');
                            if(slist != null && slist.size() > 1) 
                            {
                                String countryValue = slist[1];
                                system.debug('countryValue-->>'+countryValue);
                                if(countryValue.contains('\\')) 
                                {
                                    countryofcitizenship = countryValue.replaceAll('\\\\', '');  
                                    system.debug('countryofcitizenship after backslash-->>'+countryofcitizenship);
                                }
                                else 
                                	countryofcitizenship = countryValue;
                            }
                        }
                        if(s.contains('Type_Of_Law_Degree'))
                        {
                            List<String> slist = s.split('Type_Of_Law_Degree: ');
                            if(slist != null && slist.size()>1) 
                                typeoflawdegree = slist[1];
                        }
                    }
                 } 
                if(countryofcitizenship != null)
                    countryofcitizenship.trim();
                if(typeoflawdegree != null) 
                    typeoflawdegree.trim();
    			system.debug('countryofcitizenship-->>'+countryofcitizenship);
                o.type_of_law_degree__c = typeoflawdegree;
                o.country_of_citizenship__c = countryofcitizenship;
            }               
            // Notes parsing for 'country of citizenship' and 'type of law degree' code ends here       
            
            // Notes parsing for 'Workexperience' and 'GPA' code starts here    
                       
            if(o.AccountId == settings.JHUAAP_AccountId__c && notesField != null && notesField.length() > 0 && (notesField.contains('workexp=') || notesField.contains('gpa=')) )
            {
                if((notesField.contains('workexp=') && notesField.contains('gpa=')))
                {                	              
                    String workexpGpaString = notesField.replaceAll('workexp=', '').Trim();                     
                    //If the actual string is "workexp=5#gpa=4.0 and above" , at this point we have "5#gpa=4.0 and above"                   
                    List<String> valueList = workexpGpaString.split('#');  
                    System.debug('VALUELIST-->>'+valuelist);     
                    String workexp = valueList[0];
                    o.DeltakSRP__Years_Work_Experience__c  = Integer.valueOf(workexp);
                    List<String> valueList2 = valueList[1].split('=');                      
                    String gpaValue = valueList2[1];
                    o.DeltakSRP__GPA__c  = assignGpaValue(gpaValue);                    
                }
                if((notesField.contains('workexp=') && !(notesField.contains('gpa='))))
                {
                    String workexpGpaString = notesField.replaceAll('workexp=', '').Trim();                 
                    o.DeltakSRP__Years_Work_Experience__c = Integer.valueOf(workexpGpaString);
                }
                if(!((notesField.contains('workexp=')) && notesField.contains('gpa=')))
                {
                    String gpaValue = notesField.replaceAll('gpa=', '').Trim();
                    o.DeltakSRP__GPA__c  = assignGpaValue(gpaValue);
                }           
            }// Notes parsing for 'Workexperience' and 'GPA' code ends here             
        }
    }
}
public static Double assignGpaValue(String gpaValue)
{
    Double gpa= 0;
    if(gpaValue == '4.0 and above')
        gpa = 4.0;
    if(gpaValue == '3.99 – 3.50')  // the length of '-' matters. If small - is used, the comparison fails. Hence used longer '–'.
        gpa = 3.75;
    if(gpaValue == '3.49 – 3.0') 
        gpa = 3.25;
    if(gpaValue == '2.99 – 2.50')
        gpa = 2.75;
    if(gpaValue == '2.49 or below')
        gpa = 2.49; 
    return gpa;
}
    

}