global class IMSIntegrationService {

global class SalesStage{
	webservice Datetime DateTimes;
	webservice String SalesStageName;
	webservice String SubStageName;
}
global class IMSID{
	Id OpportunityId;
	webservice String IMSID;
	webservice List<SalesStage> SalesStages; 
}
global class IMSService{
	webservice List<IMSID> IMSIDs;
}

	/**
	1. Find all opportunity stages that are changed in the last 24 hours
	2. Store the opportunity id in a set
	3. Find all opportunity sub stages change that happened in the last 24 hours
	4. Store the opporutnity id in a set
	5. Query for all the opportunity using the set in (2) and (4)
	6. Parse through all the opportunity queried in (5)
	7. For every opportunity in (6), 
	8. get the opportunity stage history from (1)
	9. Check in the list of substages from (3) if the created date of stage and substage are the same. 
		If they are the same, then stage and substage were changed at the same time. Treat the stage and substage change as a single activity
	10. Store the id of the substage in a set and exclude this id whenever querying for the same opportunity stage.
	11. Store the substages that do not get mixed with any stage changes. These are standalone substages.
	12. Repeat 8 - 11 for all stage history changes for the opportunity
	13. We are still within the scope of opportuity in step (7). Get all standalone opportunity field history changes for the opportunity
	14. For every opportunity field history(substage) change in (13), create a single activity
	15. If there are no standalone opportunity field history(substage) change in (13), check in the original substage query in (3) for the opportunity
	16. For every opportunity field history (substage) change in (15), create a single activity
	17. Sort the response based on CreatedDateTime
	18. Return the response
	
	**/

public static Set<Id> opptyIds = new Set<Id>();
public static Set<Id> flag = new Set<Id>();
public static Map<Id, OpportunityFieldHistory> opptyIdToCreatedHistory = new Map<Id, OpportunityFieldHistory>();

public static Map<Id, List<OpportunityHistory>> fetchOpportunityHistoryChanges(Datetime fromdatetime){
	Datetime timetogoback = Datetime.now();
	if(fromdatetime != null){
		timetogoback = fromdatetime;
	}else{
		timetogoback = timetogoback.addHours(-24);
	    System.Debug('Last 24 hours -- '+timetogoback);
	}
	List<OpportunityHistory> oppsModInTime = [Select o.StageName, 
													 o.OpportunityId, 
													 o.CreatedDate 
												From OpportunityHistory o 
												where o.CreatedDate >= :timetogoback
												and o.OpportunityId in :opptyIds
												order by o.CreatedDate
											  ];
	Map<Id, List<OpportunityHistory>> opptyToHistory = new Map<id, List<OpportunityHistory>>();
	if(oppsModInTime != null && oppsModInTime.size() > 0){
		for(OpportunityHistory opptyHist : oppsModInTime){
			// Creating a set of opportunity ids to query the IMS id in those opportunities
			//opptyIds.add(opptyHist.OpportunityId);
			// Creating a map of opportunity id to list of opportunity history to track all the stage changes in the last 24 hours
			if(opptyToHistory != null && opptyToHistory.containsKey(opptyHist.OpportunityId)){
				List<OpportunityHistory> thisOpptyHist = opptyToHistory.get(opptyHist.OpportunityId);
				thisOpptyHist.add(opptyHist);
				opptyToHistory.put(opptyHist.OpportunityId, thisOpptyHist);
			}else {
				List<OpportunityHistory> thisOpptyHist = new List<OpportunityHistory>();
				thisOpptyHist.add(opptyHist);
				opptyToHistory.put(opptyHist.OpportunityId, thisOpptyHist);
			}
		}
	}
	return opptyToHistory;
}

public static Map<Id, List<OpportunityFieldHistory>> fetchSubStageChanges(Datetime fromdatetime){
	
	Datetime timetogoback = Datetime.now();
	if(fromdatetime != null){
		timetogoback = fromdatetime;
	}else{
		timetogoback = timetogoback.addHours(-24);
	    System.Debug('Last 24 hours -- '+timetogoback);
	}
	System.Debug(opptyIds);
	List<String> fieldsToQuery = new List<String>();
	fieldsToQuery.add('Sub_Stage__c');
	fieldsToQuery.add('created');
	List<OpportunityFieldHistory> listOfFieldHistory = [Select o.Id,
															o.OpportunityId, 
															o.OldValue,
															o.NewValue, 
															o.Field, 
															o.CreatedDate 
														 From OpportunityFieldHistory o where o.CreatedDate >= :timetogoback
														 and o.Field in :fieldsToQuery
														 and o.OpportunityId in :opptyIds
														 order by o.CreatedDate
														 
														];
														
    System.Debug(listOfFieldHistory.size());
														
	
	
	if(listOfFieldHistory != null && listOfFieldHistory.size() > 0){
		for(OpportunityFieldHistory thisFieldHistory : listOfFieldHistory){
			if(thisFieldHistory.Field == 'created'){
				opptyIdToCreatedHistory.put(thisFieldHistory.OpportunityId, thisFieldHistory);
				break;
			}
		}
	}
	
	
	Map<Id, List<OpportunityFieldHistory>> opptyToSubStage = new Map<Id, List<OpportunityFieldHistory>>();
	if(listOfFieldHistory != null && listOfFieldHistory.size() > 0){
		for(OpportunityFieldHistory thisFieldHistory : listOfFieldHistory){
			
			if(String.valueOf(thisFieldHistory.OldValue) == 'Duplicate Record'){
				flag.add(thisFieldHistory.Id);
				if(opptyToSubStage != null && opptyToSubStage.containsKey(thisFieldHistory.OpportunityId)){
					List<OpportunityFieldHistory> opptyFieldHistoryList = opptyToSubStage.get(thisFieldHistory.OpportunityId);
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}else{
					List<OpportunityFieldHistory> opptyFieldHistoryList = new List<OpportunityFieldHistory>();
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}
			}
			
			if((String.valueOf(thisFieldHistory.OldValue) != String.valueOf(thisFieldHistory.NewValue)) && thisFieldHistory.Field == 'Sub_Stage__c'){
				//opptyIds.add(thisFieldHistory.OpportunityId);
				if(opptyToSubStage != null && opptyToSubStage.containsKey(thisFieldHistory.OpportunityId)){
					List<OpportunityFieldHistory> opptyFieldHistoryList = opptyToSubStage.get(thisFieldHistory.OpportunityId);
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}else{
					List<OpportunityFieldHistory> opptyFieldHistoryList = new List<OpportunityFieldHistory>();
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}
			}
		}
	}
	System.Debug(opptyToSubStage);
	return opptyToSubStage;
}
public static Map<Id, Opportunity> opptyIdTo_Oppty = new Map<Id, Opportunity>();
public static Map<Id, Decimal> fetchIMSIDs(Datetime fromdatetime){
	Datetime timetogoback = Datetime.now();
	if(fromdatetime != null){
		timetogoback = fromdatetime;
	}else{
		timetogoback = timetogoback.addHours(-24);
	    System.Debug('Last 24 hours -- '+timetogoback);
	}
	Map<Id, Decimal> opptyToIMS = new Map<Id, Decimal>();
	List<Opportunity> opptyList = [Select Id, IMS_ID__c, Sub_Stage__c from Opportunity where LastModifiedDate >= :timetogoback /*Id in :opptyIds*/ and IMS_Id__c != NULL and IMS_Id__c != 0];
	if(opptyList != null && opptyList.size() > 0){
		for(Opportunity oppty : opptyList){
			if(oppty.IMS_ID__c != null){
				opptyIds.add(oppty.id);
				opptyToIMS.put(oppty.Id, oppty.IMS_ID__c);
				opptyIdTo_Oppty.put(oppty.Id, oppty);
			}
		}
	}
	return opptyToIMS;
	
}





public static IMSService computeStages(){
	Datetime last24hours = Datetime.now();
	last24hours = last24hours.addHours(-24);
	System.Debug('Last 24 hours -- '+last24Hours);
	Map<Id, Decimal> opptyToIMS =fetchIMSIDs(null);
	System.Debug(opptyToIMS);
	/** We should use the createddate in this query because, whenever a stage changes, 
	*   a record in the opportunity history is created.
	*   Query all the opportunity history records that was created in the last 24 hours
	*/
	
	Map<Id, List<OpportunityHistory>> opptyToHistory = fetchOpportunityHistoryChanges(null);
	/**List<OpportunityHistory> oppsModInLast24Hours = [Select o.StageName, 
													 o.OpportunityId, 
													 o.CreatedDate 
												From OpportunityHistory o 
												where o.CreatedDate >= :last24Hours
												order by o.CreatedDate
											  ];
	//Set<id> opptyIds = new Set<id>();
	
	if(oppsModInLast24Hours != null && oppsModInLast24Hours.size() > 0){
		for(OpportunityHistory opptyHist : oppsModInLast24Hours){
			// Creating a set of opportunity ids to query the IMS id in those opportunities
			opptyIds.add(opptyHist.OpportunityId);
			// Creating a map of opportunity id to list of opportunity history to track all the stage changes in the last 24 hours
			if(opptyToHistory != null && opptyToHistory.containsKey(opptyHist.OpportunityId)){
				List<OpportunityHistory> thisOpptyHist = opptyToHistory.get(opptyHist.OpportunityId);
				thisOpptyHist.add(opptyHist);
				opptyToHistory.put(opptyHist.OpportunityId, thisOpptyHist);
			}else {
				List<OpportunityHistory> thisOpptyHist = new List<OpportunityHistory>();
				thisOpptyHist.add(opptyHist);
				opptyToHistory.put(opptyHist.OpportunityId, thisOpptyHist);
			}
		}
	}**/
	// Creating a map of opportunity to substage if any
	Map<Id, List<OpportunityFieldHistory>> opptyToSubStage = fetchSubStageChanges(null);
	/**List<OpportunityFieldHistory> listOfFieldHistory = [Select o.Id,
															o.OpportunityId, 
															o.OldValue,
															o.NewValue, 
															o.Field, 
															o.CreatedDate 
														 From OpportunityFieldHistory o where o.CreatedDate >= :last24Hours
														 and o.Field = 'Sub_Stage__c'
														 order by o.CreatedDate
														 
														];
	
	if(listOfFieldHistory != null && listOfFieldHistory.size() > 0){
		for(OpportunityFieldHistory thisFieldHistory : listOfFieldHistory){
			if(String.valueOf(thisFieldHistory.OldValue) != String.valueOf(thisFieldHistory.NewValue)){
				opptyIds.add(thisFieldHistory.OpportunityId);
				if(opptyToSubStage != null && opptyToSubStage.containsKey(thisFieldHistory.OpportunityId)){
					List<OpportunityFieldHistory> opptyFieldHistoryList = opptyToSubStage.get(thisFieldHistory.OpportunityId);
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}else{
					List<OpportunityFieldHistory> opptyFieldHistoryList = new List<OpportunityFieldHistory>();
					opptyFieldHistoryList.add(thisFieldHistory);
					opptyToSubStage.put(thisFieldHistory.OpportunityId, opptyFieldHistoryList);
				}
			}
		}
	}**/
	
	// Creating a map of opportunity to IMSID
	
	/**List<Opportunity> opptyList = [Select Id, IMS_ID__c from Opportunity where Id in :opptyIds];
	if(opptyList != null && opptyList.size() > 0){
		for(Opportunity oppty : opptyList){
				if(oppty.IMS_ID__c != null)
					opptyToIMS.put(oppty.Id, oppty.IMS_ID__c);
		}
	}**/

	IMSService imsser = fetchIMSResponse(opptyToIMS, opptyToSubStage, opptyToHistory);
	System.Debug(imsser);
	return imsser;
	
	
}

public static IMSService fetchIMSResponse(Map<Id, Decimal> opptyToIMS, 
										  Map<Id, List<OpportunityFieldHistory>> opptyToSubStage, 
										  Map<Id, List<OpportunityHistory>> opptyToHistory){
	// Generating the response to the IMS Service call out
	System.Debug(opptyToIMS);
	System.Debug(opptyToSubStage);
	System.Debug(opptyToHistory);
	
	
	
	
	IMSService globalIMSService = new IMSService();
	if(opptyToIMS != null && opptyToIMS.size() > 0){
		List<IMSID> imsidList = new List<IMSID>();
		Set<Id> opportunityId = opptyToIMS.keySet();
		for(Id thisOppty : opportunityId){
			Map<Id, List<OpportunityFieldHistory>> standAloneSubStageChanges = new Map<Id, List<OpportunityFieldHistory>>();
			IMSID imsids = new IMSID();
			imsids.IMSID = String.valueOf(opptyToIMS.get(thisOppty));
			imsids.OpportunityId = thisOppty;
			List<OpportunityHistory> thisOpptyHist = opptyToHistory.get(thisOppty);
			
			List<OpportunityFieldHistory> temp_thisOpptyFieldHistory = opptyToSubStage.get(thisOppty);
			if((thisOpptyHist == null || (thisOpptyHist != null && thisOpptyHist.size() == 0)) && 
				(temp_thisOpptyFieldHistory == null || ((temp_thisOpptyFieldHistory != null && ((temp_thisOpptyFieldHistory.size() == 1 && temp_thisOpptyFieldHistory[0].Field == 'created') 
																	|| temp_thisOpptyFieldHistory.size() == 0))))){
					System.Debug('Continuing');
				continue;
				}else{
				System.Debug(thisOpptyHist);
				System.Debug(temp_thisOpptyFieldHistory);
			}
			List<SalesStage> salesStageList = new List<SalesStage>();
			Set<Id> opportunityFieldHistoryId = new Set<Id>();
			Set<Id> opportunityAlreadyAddedFieldHistoryID = new Set<Id>();
			if(thisOpptyHist != null && thisOpptyHist.size() > 0){
				for(OpportunityHistory thisHistory : thisOpptyHist){
					SalesStage thisSalesStage = new SalesStage();
					thisSalesStage.DateTimes = (thisHistory.CreatedDate);
					thisSalesStage.SalesStageName = thisHistory.StageName;
					if(opptyToSubStage.containsKey(thisHistory.OpportunityId)){
						List<OpportunityFieldHistory> thisOpptyFieldHistoryList = opptyToSubStage.get(thisHistory.OpportunityId);
						if(thisOpptyFieldHistoryList != null && thisOpptyFieldHistoryList.size() > 0){
							for(OpportunityFieldHistory thisopptyFieldHistory : thisOpptyFieldHistoryList){
								System.Debug('THis Oppportunity Field History -- '+thisopptyFieldHistory);
								if(thisHistory.StageName == 'Dormant' && String.valueOf(thisopptyFieldHistory.OldValue) == 'Duplicate Record'){
									thisSalesStage.SubStageName = String.valueOf(thisopptyFieldHistory.oldValue);
								}
								if(thisHistory.CreatedDate == thisopptyFieldHistory.CreatedDate){
									thisSalesStage.SubStageName = String.valueOf(thisopptyFieldHistory.newValue);
									opportunityFieldHistoryId.add(thisopptyFieldHistory.id);
								}else{
									if(standAloneSubStageChanges != null && standAloneSubStageChanges.containsKey(thisHistory.OpportunityId)){
										if(!opportunityAlreadyAddedFieldHistoryID.contains(thisopptyFieldHistory.id)){
											List<OpportunityFieldHistory> standalonesubstages = standAloneSubStageChanges.get(thisHistory.OpportunityId);
											standalonesubstages.add(thisopptyFieldHistory);
											opportunityAlreadyAddedFieldHistoryID.add(thisopptyFieldHistory.id);
											standAloneSubStageChanges.put(thisHistory.OpportunityId, standalonesubstages);
										}
									}else{
										List<OpportunityFieldHistory> standalonesubstages = new List<OpportunityFieldHistory>();
										standalonesubstages.add(thisopptyFieldHistory);
										opportunityAlreadyAddedFieldHistoryID.add(thisopptyFieldHistory.id);
										standAloneSubStageChanges.put(thisHistory.OpportunityId, standalonesubstages);
									}
								}
							}
							
						}
					}else if(thisHistory.StageName == 'Dormant'){
							thisSalesStage.SubStageName = opptyIdTo_Oppty.get(thisHistory.OpportunityId).Sub_Stage__c;
							
						}
					
					salesStageList.add(thisSalesStage);
				}
			
			}
			List<OpportunityFieldHistory> standAloneSub_StageChanges =  standAloneSubStageChanges.get(thisOppty);
			List<OpportunityFieldHistory> originalSubStageList = opptyToSubStage.get(thisOppty);
			if(standAloneSub_StageChanges != null && standAloneSub_StageChanges.size() > 0){
				for(OpportunityFieldHistory fieldHistory : standAloneSub_StageChanges){
					if(!opportunityFieldHistoryId.contains(fieldHistory.id)){ // done to exclude any already reported substage change
						SalesStage thisSalesStage = new SalesStage();
						thisSalesStage.DateTimes = (fieldHistory.CreatedDate);
						thisSalesStage.SubStageName = String.valueOf(fieldHistory.NewValue);
						salesStageList.add(thisSalesStage);
					}
				}
			}
			// IF only a substage was done on an opportunity, the logic uptil now will not catch the scenario.
			// We have to parse through the original substage list to find the only substage changes
			else if(originalSubStageList != null && originalSubStageList.size() > 0){
				for(OpportunityFieldHistory fieldHistory : originalSubStageList){
					if(!opportunityFieldHistoryId.contains(fieldHistory.id)){ // done to exclude any already reported substage change
						SalesStage thisSalesStage = new SalesStage();
						thisSalesStage.DateTimes = (fieldHistory.CreatedDate);
						thisSalesStage.SubStageName = String.valueOf(fieldHistory.NewValue);
						salesStageList.add(thisSalesStage);
					}
				}
				
			}
			imsids.SalesStages = salesStageList;
			imsidList.add(imsids);
		}
		
		
	globalIMSService.IMSIDs = imsidList;	
		
		
	}
	
	 
	return globalIMSService;
}

public static IMSService computeStagesByTime(Datetime fromdatetime){
	Map<Id, Decimal> opptyToIMS =fetchIMSIDs(fromdatetime);
	Map<Id, List<OpportunityHistory>> opptyToHistory = fetchOpportunityHistoryChanges(fromdatetime);
	Map<Id, List<OpportunityFieldHistory>> opptyToSubStage = fetchSubStageChanges(fromdatetime);
	
	return fetchIMSResponse(opptyToIMS, opptyToSubStage, opptyToHistory);
}


webservice static IMSService  fetchStageHistory(){
	IMSService fetchStage = computeStages();
	fetchStage = sortByDate(fetchStage);
	return fetchStage;
	}
	
	webservice static IMSService fetchStageHistoryByTime(Datetime fromdatetime){
		Datetime defaultto = Datetime.now();
		defaultto = defaultto.addDays(-30);
		if(fromdatetime < defaultto){
			fromdatetime = defaultto;
		}
		
		
		IMSService fetchStage = computeStagesByTime(fromdatetime);
		fetchStage = sortByDate(fetchStage);
		return fetchStage;
	}

public static IMSService sortByDate(IMSService imsobjects){
	IMSService returnService = new IMSService();
	if(imsobjects != null){
		List<IMSID> imsids = imsobjects.IMSIDs;
		if(imsids != null && imsids.size() > 0){
			Map<String, Map<DateTime, SalesStage> > opptyidToDatetimemap = new Map<String, Map<DateTime, SalesStage> >();
			Map<Id, String> opptyIdToIMSID = new Map<id, String>();
			for(IMSID thisimsid : imsids){
				Map<DateTime, SalesStage> datetimeToSaleStage = new Map<DateTime, SalesStage>();
				List<SalesStage> salesStageInput = thisimsid.SalesStages;
				if(salesStageInput != null && salesStageInput.size() > 0){
					for(SalesStage thisSalesStage : salesStageInput){
						Datetime changedtime = (thisSalesStage.DateTimes);
						datetimeToSaleStage.put(changedtime, thisSalesStage);
					}
				}
			opptyidToDatetimemap.put(thisimsid.OpportunityId, datetimeToSaleStage);
			opptyIdToIMSID.put(thisimsid.OpportunityId, thisimsid.IMSID);
			}
			List<IMSID> imsidList = new List<IMSID>();
			if(opptyidToDatetimemap != null && opptyidToDatetimemap.size() > 0){
				Set<String> opptyididset = opptyidToDatetimemap.keySet();
				for(String opptyid : opptyididset){
					
					IMSID newIMSID = new IMSID();
				    newIMSID.IMSID = opptyIdToIMSID.get(opptyid);
				    newIMSID.OpportunityId = opptyid;
					
					Map<DateTime, SalesStage> datetimetosalesstage = opptyidToDatetimemap.get(opptyid);
					List<Datetime> datetimelist = new List<Datetime>();
					datetimelist.addAll(datetimetosalesstage.keySet());
					datetimelist.sort();
					List<SalesStage> salesstagelist = new List<SalesStage>();
					for(Datetime thisdatetime : datetimelist){
						Salesstage thissalesstage = datetimetosalesstage.get(thisdatetime);
						salesstagelist.add(thissalesstage);
					}
					newIMSID.SalesStages = salesstagelist;
					imsidList.add(newIMSID);
				}
			}
			returnService.IMSIDs = imsidList;
		}else{
			return imsobjects;
		}
	}else{
		return imsobjects;
	}
	return returnService;
}


static  testmethod void testIMS(){
	
	    
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        	Test.startTest();
        	Opportunity o = new Opportunity();
        	o.StageName = 'New Inquiry';
        	o.CloseDate = System.Today();
        	o.Name = 'New OpptyName';
        	o.IMS_ID__c = 123456;
        	insert o;
        	
        	o.StageName = 'Appointment Scheduled';
        	o.Sub_Stage__c = 'Chat';
        	update o;
        	
        	o.StageName = 'Appointment Completed';
        	o.Sub_Stage__c = 'Chat';
        	update o;
        	
        	o.Sub_Stage__c = 'Personal Visit';
        	update o;
        	System.Debug(o);
        	
        	IMSIntegrationService.IMSService thisIMSservice = IMSIntegrationService.computeStages();
			List<IMSIntegrationService.IMSID> imsids = thisIMSservice.IMSIDs;
			System.AssertEquals(1, imsids.size());
			
			List<IMSIntegrationService.SalesStage> salesstages = imsids[0].SalesStages;
			System.Debug(salesstages);
			System.AssertEquals(3, salesstages.size());
			
			String imsid = imsids[0].IMSID;
			System.AssertEquals('123456',  imsid);
			
			System.Debug(thisIMSservice);
			
			IMSIntegrationService.IMSService thisIMSservice1  = IMSIntegrationService.sortByDate(thisIMSService);
			
	Test.stopTest();
        }
	
}
static  testmethod void testIMSWithDateTime(){
	
	    
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
        	Test.startTest();
        	Opportunity o = new Opportunity();
        	o.StageName = 'New Inquiry';
        	o.CloseDate = System.Today();
        	o.Name = 'New OpptyName';
        	o.IMS_ID__c = 123456;
        	insert o;
        	
        	o.StageName = 'Appointment Scheduled';
        	o.Sub_Stage__c = 'Chat';
        	update o;
        	
        	o.StageName = 'Appointment Completed';
        	o.Sub_Stage__c = 'Chat';
        	update o;
        	
        	o.Sub_Stage__c = 'Personal Visit';
        	update o;
        	System.Debug(o);
        	
        	Datetime last20hours = Datetime.now();
	        last20hours = last20hours.addHours(-20);
        	
        	IMSIntegrationService.IMSService thisIMSservice = IMSIntegrationService.computeStagesByTime(last20hours);
			List<IMSIntegrationService.IMSID> imsids = thisIMSservice.IMSIDs;
			System.AssertEquals(1, imsids.size());
			
			List<IMSIntegrationService.SalesStage> salesstages = imsids[0].SalesStages;
			System.Debug(salesstages);
			System.AssertEquals(3, salesstages.size());
			
			String imsid = imsids[0].IMSID;
			System.AssertEquals('123456',  imsid);
			
			System.Debug(thisIMSservice);
			
			IMSIntegrationService.IMSService thisIMSservice1  = IMSIntegrationService.sortByDate(thisIMSService);
			
	Test.stopTest();
        }
	
}

}