global class BatchUpdateAdmissionsGoals implements Database.Batchable<sObject>, Database.Stateful{
	global final String Query;
	global final String Entity;
	global final String Field;
	global final String Value;
	
	List <Opportunity> opportunityList;
	Admissions_Goal__c [] goals;
	Date todayDate, sevenDaysAgo;
	
	AdmissionsGoal [] goalList; 
	
	global BatchUpdateAdmissionsGoals(String q, String e, String f, String v){
		Query=q; Entity=e; Field=f;Value=v;
		opportunityList = new List <Opportunity> ();
		
		goals = [SELECT a.Weekly_Un_Contacted_Leads__c, 
			   a.Weekly_Referrals__c, a.Weekly_Leads__c,
			   a.Weekly_Contact_Percent__c, a.Weekly_Appointments__c, 
			   a.Weekly_Applications__c, a.Un_Contacted_Leads__c, 
			   a.Start_Program_Goal__c, a.Start_Assuming_65_ATS__c, a.School__c, a.Program__c, 
			   a.Percent_to_Goal__c, a.New_Leads_Contacted__c, a.Net_Starts__c, a.Name, 
			   a.Leads__c, a.Lead_to_Start__c, a.Lead_to_Application__c, 
			   a.Interview_to_Application__c, a.Id, a.Contacted_Leads__c, 
			   a.Contact_to_Interview__c, a.Appointments__c, a.Appointments_Expected__c, 
			   a.Applications_Received__c, a.Applications_Expected__c, a.Application_to_Start__c, 
			   a.Admissions_User__c, a.Actual_Start__c, a.Academic_Start_Date__c
			   FROM Admissions_Goal__c a
			   WHERE a.Locked__c = False]; 
		
		goalList = new AdmissionsGoal[goals.size()];
		
		for (Integer i=0; i<goalList.size(); i++) {
			goalList[i] = new AdmissionsGoal();
		}
		
		Set <Id> repIds = new Set <Id>();
		
		for (Admissions_Goal__c g : goals) {
			repIDs.add(g.Admissions_User__c);
		}
		
		//Task [] tasks = [SELECT Id FROM Task WHERE What.Name LIKE :campusPrefix];
		
		DateTime t=System.now();
		todayDate = Date.newInstance(t.year(),t.month(),t.day());
		sevenDaysAgo = Date.newInstance(t.year(),t.month(),t.day()-7);
		
	}

	global Database.QueryLocator start(Database.BatchableContext BC){		
		
		return Database.getQueryLocator(query);		
	} 
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set <Id> oppIDs = new Set <Id>();
		
		for(sObject s : scope){
			if(s.getsObjectType() == Opportunity.sObjectType) {
			 	
			 	Opportunity o = (Opportunity)s;
			 	
			 	oppIDs.add(o.Id);
			}
		}
		
		Decimal totalLeads, 
				weeklyLeads,  
				totalAppointments,
				weeklyAppointments,				
			    weeklyReferrals,
			    weeklyUnContactedLeads,
			    weeklyApplications,
			    totalApplicationsReceived,
		        totalUnContactedLeads,
			    totalStart;
				
		Integer count = 0;
		
		for (Admissions_Goal__c g : goals) {
			totalLeads  = goalList[count].totalLeads;
			weeklyLeads = goalList[count].weeklyLeads;			
			weeklyAppointments = goalList[count].weeklyAppointments;
			totalAppointments = goalList[count].totalAppointments;			
			weeklyReferrals = goalList[count].weeklyReferrals;
			weeklyUnContactedLeads = goalList[count].weeklyUnContactedLeads;
			weeklyApplications = goalList[count].weeklyApplications;
			totalApplicationsReceived = goalList[count].totalApplicationsReceived;
			totalUnContactedLeads = goalList[count].totalUnContactedLeads;
			totalStart = goalList[count].totalStart;
			
			for(sObject s : scope){
				
				if(s.getsObjectType() == Opportunity.sObjectType) {
			 	
				 	Opportunity o = (Opportunity)s;
					
					if (o == null) {
						System.debug ('BatchUpdateAdmissionsGoals - Opportunity was null while updating Admissions Goals. Skipping record');
						continue;
					}
					
					System.debug('BatchUpdateAdmissionsGoals - Processing Admissions_Goal__c '+ g.Id + ' for Opportunity '+ o.Id );
					
				
					DateTime opp_dateTime, ref_dateTime;
					
					//*****************************************
					//Set Create Date for Opportunity
					//*****************************************
					
					//If the GM Migration flag is true and there's no Goldmine Create date, 
					//then skip this opportunity
					if (o.GM_Migration__c == True && o.Goldmine_CreateDate__c==null) {
						System.debug('BatchUpdateAdmissionsGoals - GM_Migration__c = true and there is no GM create date. Skipping this record');
						continue;
					}
					
					//If the GM Migration flag is true and there is a Goldmine create date 
					//Then use that date as the create date
					if (o.GM_Migration__c == True && o.Goldmine_CreateDate__c!=null) {
						System.debug('BatchUpdateAdmissionsGoals - GM_Migration__c = true and there is a GM create date. Using GM Create Date');
						opp_dateTime = o.Goldmine_CreateDate__c;
					}
					
					//If the GM Migration flag is false
					//Then use the Salesforce create date as the create date
					if (o.GM_Migration__c == false) {
						System.debug('BatchUpdateAdmissionsGoals - GM_Migration__c = false. Using Salesforce Create Date');
						opp_dateTime = o.CreatedDate;
					}
					
					//*****************************************
					//Set Create Date for Referred Opportunity
					//*****************************************
					
					//If the GM Migration flag is true and there's no Goldmine Create date, 
					//then skip this opportunity
					if (o.Referred_By_Opportunity__c != null && o.Referred_By_Opportunity__r.GM_Migration__c == True && o.Referred_By_Opportunity__r.Goldmine_CreateDate__c==null) {
						System.debug('BatchUpdateAdmissionsGoals - Referred_By_Opportunity__r.GM_Migration__c = true and there is no Referred_By_Opportunity__r.GM_Create_Ddate. Skipping this record');
						ref_dateTime = null;
					}
					
					//If the GM Migration flag is true and there is a Goldmine create date 
					//Then use that date as the create date
					if (o.Referred_By_Opportunity__r.GM_Migration__c == True && o.Referred_By_Opportunity__r.Goldmine_CreateDate__c!=null) {
						System.debug('BatchUpdateAdmissionsGoals - Referred_By_Opportunity__r.GM_Migration__c = true and there is a Referred_By_Opportunity__r.GM create date. Using Referred_By_Opportunity__r.GM Create Date');
						ref_dateTime = o.Referred_By_Opportunity__r.Goldmine_CreateDate__c;
					}
					
					//If the GM Migration flag is false
					//Then use the Salesforce create date as the create date
					if (o.Referred_By_Opportunity__r.GM_Migration__c == false) {
						System.debug('BatchUpdateAdmissionsGoals - Referred_By_Opportunity__r.GM_Migration__c = false. Using Referred_By_Opportunity__r.Salesforce Create Date');
						ref_dateTime = o.Referred_By_Opportunity__r.CreatedDate;
					}
					
					Date createDate = Date.newInstance(
						opp_dateTime.year(),
						opp_dateTime.month(),
						opp_dateTime.day()
					);
					
					Date refCreateDate = null;
					// if the referred opportunity's create date is null it means that referred opportunity was
					//migrated from Goldmine but the Goldmine Create Date was null
					if (ref_dateTime == null) {
						refCreateDate = null;
					}
					
					else {
						refCreateDate = Date.newInstance(
							ref_dateTime.year(),
							ref_dateTime.month(),
							ref_dateTime.day()
						);
					}
					
					//*****************************
					// Start counting the metrics 
					//*****************************					  
					if (o.Academic_Start_Date__c             == g.Academic_Start_Date__c &&
						o.Referred_By_Opportunity__c         != null                     &&
						o.Referred_By_Opportunity__r.OwnerId == g.Admissions_User__c     &&
						refCreateDate					     != null                     &&
						(refCreateDate                        >  sevenDaysAgo             && 
						refCreateDate                        <= todayDate            ) )  {														
							weeklyReferrals++;
							System.debug('BatchUpdateAdmissionsGoals - Increment weeklyReferrals to ' + weeklyReferrals);
						}
					
					if (o.Academic_Start_Date__c == g.Academic_Start_Date__c &&
						o.OwnerID                == g.Admissions_User__c    ) {
							totalLeads++;
							System.debug('BatchUpdateAdmissionsGoals - Increment totalLeads to ' + totalLeads);
					}
					
					if (o.Academic_Start_Date__c == g.Academic_Start_Date__c &&
						o.OwnerID                == g.Admissions_User__c     &&
						(createDate               > sevenDaysAgo             && 
						createDate               <=  todayDate))               {							
							weeklyLeads++;
							System.debug('BatchUpdateAdmissionsGoals - Increment weeklyLeads to ' + weeklyLeads);
					}	
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&	
						o.Date_Booked__c             != NULL) {
							
							totalApplicationsReceived++;
							System.debug('BatchUpdateAdmissionsGoals - Increment totalApplicationsReceived to ' + totalApplicationsReceived);
					}
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&	
						(o.Date_Booked__c             > sevenDaysAgo             && 
						o.Date_Booked__c             <=  todayDate    )) {
							
							weeklyApplications++;
							System.debug('BatchUpdateAdmissionsGoals - Increment totalApplicationsReceived to ' + totalApplicationsReceived);
					}
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&
						o.Appointment_Completed__c   != NULL                     )               {
							totalAppointments++;	
							System.debug('BatchUpdateAdmissionsGoals - Increment totalAppointments to ' + totalAppointments);
					}
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&
						(o.Appointment_Completed__c   > sevenDaysAgo             && 
						o.Appointment_Completed__c   <= todayDate                )){
							weeklyAppointments++;	
							System.debug('BatchUpdateAdmissionsGoals - Increment weeklyAppointments to ' + weeklyAppointments);
					}
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&
						o.Last_Contact__c            == NULL) {
							System.debug('BatchUpdateAdmissionsGoals - Increment totalUnContactedLeads to ' + totalUnContactedLeads);
							totalUnContactedLeads++;
					}	
					
					if (o.Academic_Start_Date__c     == g.Academic_Start_Date__c &&
						o.OwnerID                    == g.Admissions_User__c     &&
						(createDate                   > sevenDaysAgo             && 
						createDate                   <=  todayDate              )&&
						o.Last_Contact__c == NULL                               ) {
							
							weeklyUnContactedLeads++;
							System.debug('BatchUpdateAdmissionsGoals - Increment weeklyUnContactedLeads to ' + weeklyUnContactedLeads);
					}
					
					if (o.Academic_Start_Date__c == g.Academic_Start_Date__c &&
						o.OwnerID                == g.Admissions_User__c     &&
						o.StageName              == 'Start') {
							
							totalStart++;
							System.debug('BatchUpdateAdmissionsGoals - Increment totalStart to ' + totalStart);
					}
					
					
					
					
				}
			}
			 
			//************************************************************************
			// Call the updateValues methon in the public AdmissionsGoal class
			//************************************************************************
			goalList[count].updateValues(totalLeads, 
										 weeklyLeads,  
										 totalAppointments,
										 weeklyAppointments,
									   weeklyReferrals,
									   weeklyUnContactedLeads,
									   weeklyApplications,
									   totalApplicationsReceived,
									   totalUnContactedLeads,
									   totalStart);
			
			//Iterate the count value
			count++;
		}	
	}
	
	global void finish(Database.BatchableContext BC){
		Integer i = 0;

		for (Admissions_Goal__c g : goals) {
			g.Leads__c = goalList[i].totalLeads;
			g.Weekly_Leads__c = goalList[i].weeklyLeads;
			g.Appointments__c = goalList[i].totalAppointments;
			g.Weekly_Appointments__c = goalList[i].weeklyAppointments;
			g.Weekly_Referrals__c =	goalList[i].weeklyReferrals;
			g.Weekly_Un_Contacted_Leads__c = goalList[i].weeklyUnContactedLeads;
			g.Weekly_Applications__c = goalList[i].weeklyApplications;
			g.Applications_Received__c = goalList[i].totalApplicationsReceived;
			g.Un_Contacted_Leads__c = goalList[i].totalUnContactedLeads;
			g.Actual_Start__c = goalList[i].totalStart;
			i++;
		}

		update goals;
	}
}