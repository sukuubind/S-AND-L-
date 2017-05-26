public without sharing class II_ProcessUTCourseEnrollments {


public static List<Integration_Transaction__c> processIntegrationTransactions(Integration_Interface__c ii, List<Integration_Transaction__c> itList)
{
	Map<String,Schema.RecordTypeInfo> accRtMapByName = (Schema.SObjectType.Account).getRecordTypeInfosByName();
	Account acc = [SELECT Id, Name FROM Account WHERE Name = 'University of Texas at Austin' AND RecordTypeId = :accRtMapByName.get('SRP Academic Institution').getRecordTypeId() LIMIT 1];
	
	//Raw Header column names to their respective index in the data
	Map<String,Integer> nameToIndex = generateNameToIndexMap(ii);
	
	if(nameToIndex.isEmpty())
	{
		for(Integration_Transaction__c it : itList)
		{
			it.Processing_Status__c = 'Errored';
			it.Last_Error__c = 'Line Number: 17 Message: Unable to generate nameToIndex / data headers from Integration Interface.';
		}
		
		return itList;	
	}
	else
	{
		//store shortname : uniqueid key to course enrollment Map values
		Map<String,utCourseEnrollment> utceMap = new Map<String,utCourseEnrollment>();
		//store Integration Transaction id to course enrollment Map values
		Map<Id,utCourseEnrollment> itToUtceMap = new Map<Id,utCourseEnrollment>();
		
		for(Integration_Transaction__c it : itList)
		{
			if(it.Raw_Data__c != null && it.Raw_Data__c.trim() != '')
		 	{
		 		try {
		 			
		 			utCourseEnrollment utce = generateUTCourseEnrollment(it, nameToIndex);
		 			
		 			utceMap.put(utce.ceId,utce);
		 			itToUtceMap.put(it.Id,utce);
		 			
		 		} catch(Exception e) {
		 			it.Processing_Status__c = 'Errored';
					it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
		 		}
		 	}
		 	else
		 	{
		 		it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Line Number: 48 Message: Raw Data is empty.';
		 	}
		}
		
		//get contact map with key values either LMS Username if available or email if LMS username is not available
		Map<String,Contact> cIdToContactMap = getContactMap(itList,itToUtceMap,acc);
		
		System.debug('cIdToContactMap >---> ' + cIdToContactMap);
		
		//Integration Transaction Id to contact map values
		Map<Id,Contact> itToContactMap = new Map<Id,Contact>();
		
		Map<Id,Contact> contactToUpdateMap = new Map<Id,Contact>();
		
		for(Integration_Transaction__c it : itList)
		{
			try {
				
				if(it.Processing_Status__c == 'Queued')
				{
					
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
				
					Contact c = cIdToContactMap.get(utce.uniqueid.toUpperCase());
					
					if(c == null)
					{
						
						c = cIdToContactMap.get(utce.email.toUpperCase());
						
						if(c != null)
						{
							
							if(c.LMS_Username__c == null || c.LMS_Username__c == '')
							{
								c.LMS_Username__c = utce.uniqueid;
								contactToUpdateMap.put(c.Id,c);
							}
							else if(c.LMS_Username__c.toUppercase() != utce.uniqueid.toUppercase())
							{
								throw new itDataException('The LMS Username field in the Affiliation differs from uniqueid value in file. Affiliation: ' + c);
							}
							
						}
						
					}
					
					
				}
			
			} catch(Exception e) {
				it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
			}
		
		}
		
		Map<Id,String> contactsInError = new Map<Id,String>();
		
		if(contactToUpdateMap.values().size() > 0)
		{
			
			List<Contact> contactToUpdateList = contactToUpdateMap.values();
			
			Database.DMLOptions dmlo = new Database.DMLOptions();
			dmlo.optAllOrNone = false;
			Database.SaveResult[] csr= Database.update(contactToUpdateList, dmlo);
			
			Integer cCount = 0;
			
			for(Database.SaveResult sr : csr)
			{
				if(sr.isSuccess())
				{
					Contact c = contactToUpdateMap.get(sr.getId());
					cIdToContactMap.remove(c.Email.toUppercase());
					cIdToContactMap.put(c.LMS_Username__c.toUppercase(), c);
				}
				else
				{
					contactsInError.put(contactToUpdateList[cCount].Id,sr.getErrors() + '');
				}
				
				cCount++;
								
			}
			
			
		}
		
		System.debug('cIdToContactMap After >---> ' + cIdToContactMap);
		
		System.debug('contactsInError >---> ' + contactsInError);
		
		//LMS Username to Integration Transaction Map values
		Map<Id,Integration_Transaction__c> itIdToItMap = new Map<Id,Integration_Transaction__c>();
		
		//uniqueid to Integration transaction Map values for BFP Users 
		Map<String, Integration_Transaction__c> uniqueidToItBFPMap = new Map<String, Integration_Transaction__c>();
			
		for(Integration_Transaction__c it : itList)
		{
			try {
				
				itIdToItMap.put(it.Id, it);
				
				if(it.Processing_Status__c == 'Queued')
				{
					
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
				
					Contact c = cIdToContactMap.get(utce.uniqueid.toUpperCase());
					
					if(c != null)
					{
						itToContactMap.put(it.Id,c);
					}
					else
					{
						c = cIdToContactMap.get(utce.email.toUpperCase());
						
						if(c != null)
						{
							throw new itDataException(contactsInError.get(c.Id));
						}
						else
						{
							throw new itDataException('Could not find matching Affiliation.');
						}
						
					}
					
					if(utce.shortname.contains('BFP_'))
					{
						uniqueidToItBFPMap.put(utce.uniqueid.toUppercase(), it);
					}
					
				}
				
			} catch(Exception e) {
				it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
			}
		
		}
		
		System.debug('itToContactMap >---> ' + itToContactMap);
		System.debug('uniqueidToItBFPMap >---> ' + uniqueidToItBFPMap);
		
		//UTX-program code to academic program map values
		Map<String,DeltakSRP__Academic_Program__c> apEIdToAp = getAcademicProgramMap(itList, itToUtceMap, acc);
		
		System.debug('apEIdToAp >---> ' + apEIdToAp);
		
		//Academic Program Id to academic program map values
		Map<Id,DeltakSRP__Academic_Program__c> idToAP = new Map<Id,DeltakSRP__Academic_Program__c>();
		
		for(DeltakSRP__Academic_Program__c ap : apEIdToAp.values())
		{
			idToAP.put(ap.Id,ap);
		}
		
		System.debug('idToAP >---> ' + idToAP);
		
		//LMS username : programcode : accountid to Opportunity map values
		Map<String,Opportunity> utCEIdentifierToOppMap = getOpportunityMap(itList, itToUtceMap, acc);
		
		System.debug('utCEIdentifierToOppMap >---> ' + utCEIdentifierToOppMap);
		
		Map<String,Schema.RecordTypeInfo> oppRtMapByName = (Schema.SObjectType.Opportunity).getRecordTypeInfosByName();
		
		//Integration Transaction Id to Opportunity Map values
		Map<Id,Opportunity> itToOpportunity = new Map<Id,Opportunity>();
		
		//Integration Transaction Id to Opportunity Map values for opportunities to create
		Map<Id,Opportunity> itToOpportunityToCreate = new Map<Id,Opportunity>();
		
		for(Integration_Transaction__c it : itList)
		{
			try {
			
				if(it.Processing_Status__c == 'Queued')
				{
					
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
					
					String oppIdentifierString = utce.uniqueid.toUppercase() + ':UTX-' 
										 + utce.shortname.split('_')[0] + ':' + acc.Id;
			
				 	String oppIdentifierBFPString = utce.uniqueid.toUppercase() + ':UTX-BFP:' + acc.Id;
				 	
				 	Opportunity opp = null;
				 	opp = utCEIdentifierToOppMap.get(oppIdentifierBFPString);
				
					if(opp == null)
					{
						opp = utCEIdentifierToOppMap.get(oppIdentifierString);
					}
					
					if(opp == null && 
					( !uniqueidToItBFPMap.keySet().contains(utce.uniqueid.toUppercase()) || 
						(uniqueidToItBFPMap.keySet().contains(utce.uniqueid.toUppercase()) && utce.shortname.contains('BFP_')) 
					) )
					{
						
						Contact c = itToContactMap.get(it.Id);
						DeltakSRP__Academic_Program__c ap = apEIdToAp.get('UTX-' + utce.shortname.split('_')[0]);
						
						if(c != null && ap != null)
						{
							
							Opportunity o = new Opportunity();
							o.RecordTypeId = oppRtMapByName.get('SRP Opportunity').getRecordTypeId();
							o.Name = utce.firstname + ' ' + utce.lastname;
							o.stageName = 'Dormant';
							o.DeltakSRP__Sub_Stage__c = 'Duplicate Record';
							o.DeltakSRP__Student__c = c.Id;
							o.DeltakSRP__Academic_Program__c = ap.Id;
							o.AccountId = acc.Id;
							o.CloseDate = DateTime.newInstance(2100,1,1).date();
							o.SRP_Person__c = c.DeltakSRP__Person__c;
							
							if(System.Test.isRunningTest())
							{
								o.stageName = 'Start';
							}
							
							itToOpportunityToCreate.put(it.Id, o);
							
						}
						else
						{
							
							String error = 'Affiliation: ';
							
							if(c != null)
							{
								error += c;
							}
							else
							{
								error += 'match not found.';
							}
							
							error += ' | Academic Program: ';
							
							if(ap != null)
							{
								error += ap;
							}
							else
							{
								error += 'match not found.';	
							}
							
							throw new itDataException(error);
						}
						
					}
					else
					{
						itToOpportunity.put(it.Id, opp);
					}
					
				}
				
			} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 		}
		}
		
		if(itToOpportunityToCreate.values().size() > 0 && !nullsInSobjectList(itToOpportunityToCreate.values()))
		{
			
			Database.DMLOptions dmlo = new Database.DMLOptions();
			dmlo.optAllOrNone = false;
			Database.SaveResult[] oppsr= Database.insert(itToOpportunityToCreate.values(), dmlo);
			
			for(Id itId : itToOpportunityToCreate.keySet())
			{
				Opportunity o = itToOpportunityToCreate.get(itId);
				
				Integration_Transaction__c it = itIdToItMap.get(itId);
				
				try {
					
					
					if(o == null)
					{
						throw new itDataException('Could not find and/or create Opportunity.');
					}
					else if(o.Id == null)
					{
						
						Contact c = itToContactMap.get(itId);
						utCourseEnrollment utce = itToUtceMap.get(itId);
						DeltakSRP__Academic_Program__c ap = apEIdToAp.get('UTX-' + utce.shortname.split('_')[0]);
						
						Integer recCount = 0;
						
						for(Opportunity currO : itToOpportunityToCreate.values())
						{
							
							try {
							
								if(currO.DeltakSRP__Student__c == o.DeltakSRP__Student__c && currO.DeltakSRP__Academic_Program__c == o.DeltakSRP__Academic_Program__c)
								{
									throw new itDataException(oppsr[recCount].getErrors() + '');
								}
							
							} catch(Exception e) {
	 							it.Processing_Status__c = 'Errored';
								it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 						} finally {
	 							recCount++;
							}
						}
						
					}
					else
					{
						itToOpportunity.put(itId, o);
						
						Contact c = itToContactMap.get(itId);
						DeltakSRP__Academic_Program__c ap = idToAP.get(o.DeltakSRP__Academic_Program__c);
						
						String oppIdentifierString = c.LMS_Username__c.toUppercase() + ':' 
										 + ap.DeltakSRP__SIS_External_Id__c + ':' + acc.Id;
			
				 		
						utCEIdentifierToOppMap.put(oppIdentifierString,o);
					}
					
				} catch(Exception e) {
	 				it.Processing_Status__c = 'Errored';
					it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 			}
				
				
				
			}
		}
		
		for(Integration_Transaction__c it : itList)
		{
			try {
			
				if(it.Processing_Status__c == 'Queued' && itToOpportunity.get(it.Id) == null)
				{
					
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
					
					String oppIdentifierString = utce.uniqueid.toUppercase() + ':UTX-' 
										 + utce.shortname.split('_')[0] + ':' + acc.Id;
			
				 	String oppIdentifierBFPString = utce.uniqueid.toUppercase() + ':UTX-BFP:' + acc.Id;
				 	
				 	Opportunity opp = null;
				 	opp = utCEIdentifierToOppMap.get(oppIdentifierBFPString);
				
					if(opp == null)
					{
						opp = utCEIdentifierToOppMap.get(oppIdentifierString);
					}
					
					if(opp == null)
					{
						
						throw new itDataException('Could not find and/or create Opportunity.');
						
					}
					else
					{
						itToOpportunity.put(it.Id, opp);
					}
					
				}
				
			} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 		}
		}
		
		System.debug('utCEIdentifierToOppMap Final >---> ' + utCEIdentifierToOppMap);
		System.debug('itToOpportunity Final >---> ' + itToOpportunity);
		
		//query for academic terms for existing the academic programs
		List<DeltakSRP__Academic_Start_Date__c> atList = [SELECT Id, DeltakSRP__Academic_Program__c FROM DeltakSRP__Academic_Start_Date__c WHERE DeltakSRP__Academic_Program__c IN :apEIdToAp.values()];
		
		//Academic program id to academic term object record map
		Map<Id,DeltakSRP__Academic_Start_Date__c> apToAtMap = new Map<Id,DeltakSRP__Academic_Start_Date__c>();
		for(DeltakSRP__Academic_Start_Date__c currAt : atList)
		{
			apToAtMap.put(currAt.DeltakSRP__Academic_Program__c, currAt);
		}
		
		System.debug('apToAtMap >---> ' + apToAtMap);
		
		System.debug('itToOpportunity >---> ' + itToOpportunity);
		
		//enrolled student id : academic program id to Program Enrollment Map Values	
		Map<String, DeltakSRP__Program_Enrollment__c> peStringMap = getProgramEnrollmentMap(itList, itToOpportunity);
		
		//Integration Transaction id to Program Enrollment Map values
		Map<Id,DeltakSRP__Program_Enrollment__c> peMap = new Map<Id, DeltakSRP__Program_Enrollment__c>();
		
		//Integration Transaction id to Program Enrollment Map values
		Map<Id,DeltakSRP__Program_Enrollment__c> peMapToCreate = new Map<Id, DeltakSRP__Program_Enrollment__c>();
		
		
		for(Integration_Transaction__c it : itList)
		{
			try {
			
				if(it.Processing_Status__c == 'Queued')
				{
					Opportunity opp = itToOpportunity.get(it.Id);
					
					if(opp == null)
					{
						throw new itDataException('Missing Opportunity.');
					}
					
					DeltakSRP__Program_Enrollment__c pe = peStringMap.get(opp.DeltakSRP__Student__c + ':' + opp.DeltakSRP__Academic_Program__c);
					
					if(pe != null)
					{
						peMap.put(it.Id, pe);
					}
					else
					{
						
						utCourseEnrollment utce = itToUtceMap.get(it.Id);
						
						Contact c = itToContactMap.get(it.Id);
						DeltakSRP__Academic_Program__c ap = idToAP.get(opp.DeltakSRP__Academic_Program__c);
						
						DeltakSRP__Program_Enrollment__c peTmp = new DeltakSRP__Program_Enrollment__c();
						peTmp.DeltakSRP__Enrolled_Student__c = opp.DeltakSRP__Student__c;
						peTmp.DeltakSRP__Academic_Program__c = opp.DeltakSRP__Academic_Program__c;
						peTmp.DeltakSRP__Enrollment_Start__c = apToAtMap.get(opp.DeltakSRP__Academic_Program__c).Id;
						peTmp.DeltakSRP__Opportunity__c = opp.Id;
						peTmp.DeltakSRP__Enrollment_Status__c = 'New';
						peTmp.DeltakSRP__SIS_External_Id__c = 'UTX-' + c.LMS_Username__c + '-' + ap.DeltakSRP__SIS_External_Id__c.replace('UTX-','');
						
						peMapToCreate.put(it.Id,peTmp);
						peStringMap.put(opp.DeltakSRP__Student__c + ':' + opp.DeltakSRP__Academic_Program__c,peTmp);
					}
				}
			
			} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 		}
			
		}
		
		System.debug('peMapToCreate >---> ' + peMapToCreate);
		
		if(peMapToCreate.values().size() > 0 && !nullsInSobjectList(peMapToCreate.values()))
		{
			
			Database.DMLOptions dmlo = new Database.DMLOptions();
			dmlo.optAllOrNone = false;
			Database.SaveResult[] pesr= Database.insert(peMapToCreate.values(), dmlo);
			
			for(Id itId : peMapToCreate.keySet())
			{
				DeltakSRP__Program_Enrollment__c peTmp = peMapToCreate.get(itId);
				
				Integration_Transaction__c it = itIdToItMap.get(itId);
				try {
					
					if(peTmp == null)
					{
						throw new itDataException('Could not find and/or create Program Enrollment.');
					}
					else if(peTmp.Id == null)
					{
						
						Integer recCount = 0;
						
						for(DeltakSRP__Program_Enrollment__c currPe : peMapToCreate.values())
						{
							try {
								
								if(currPe.DeltakSRP__SIS_External_Id__c == peTmp.DeltakSRP__SIS_External_Id__c)
								{
									throw new itDataException(pesr[recCount].getErrors() + '');
								}
							
							}catch(Exception e) {
	 							it.Processing_Status__c = 'Errored';
								it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 						} finally {
								recCount++;
							}
						}
						
					}
					else
					{
						peMap.put(itId, peTmp);
					}
					
				} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 			}
				
			}
			
		}
		
		//UTX-section code to academic section map values
		Map<String, DeltakSRP__Academic_Section__c> asStringMap = getAcademicSectionMap(itList, itToUtceMap);
		
		//Integration Transaction Id tp academic section map values
		Map<Id, DeltakSRP__Academic_Section__c> asMap = new Map<Id, DeltakSRP__Academic_Section__c>();
		
		for(Integration_Transaction__c it : itList)
		{
			try {
			
				if(it.Processing_Status__c == 'Queued')
				{
					
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
					
					if(!utce.shortname.contains('BFP_'))
					{
						
						DeltakSRP__Academic_Section__c asTmp = asStringMap.get('UTX-' + utce.shortname);
						
						if(asTmp != null)
						{
							asMap.put(it.Id, asTmp);
						}
						else
						{
							throw new itDataException('Academic Section match not found.');
						}
						
					}
					
				}
				
			} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 		}
			
		}
		
		//Contact id : academic section id to course enrollment map values
		Map<String, DeltakSRP__Course_Enrollment__c> ceMap = getCourseEnrollmentMap(itList, itToUtceMap, itToContactMap, asMap);
		
		//ce identifier string to Integration Transaction Map values
		Map<String, Integration_Transaction__c> ceIdToCourseEnrollmentMap = new Map<String,Integration_Transaction__c>();
		
		Set<DeltakSRP__Course_Enrollment__c> ceSet = new Set<DeltakSRP__Course_Enrollment__c>();
		
		for(Integration_Transaction__c it : itList)
		{
			try {
			
				if(it.Processing_Status__c == 'Queued')
				{
					utCourseEnrollment utce = itToUtceMap.get(it.Id);
				
					if(!utce.shortname.contains('BFP_'))
					{
						Contact c = itToContactMap.get(it.Id);
						DeltakSRP__Academic_Section__c asTmp = asMap.get(it.Id);
						DeltakSRP__Program_Enrollment__c peTmp = peMap.get(it.Id);
						
						DeltakSRP__Course_Enrollment__c ceTmp = ceMap.get(c.Id + ':' + asTmp.Id);
						
						if(c == null)
						{
							throw new itDataException('Missing Affiliation.');
						}
						
						if(asTmp == null)
						{
							throw new itDataException('Missing Academic Section.');
						}
						
						if(peTmp == null)
						{
							throw new itDataException('Missing Program Enrollment.');
						}
						
						if(ceTmp == null)
						{
							
							DeltakSRP__Course_Enrollment__c ce = new DeltakSRP__Course_Enrollment__c();
							ce.DeltakSRP__Enrolled_Student__c = c.Id;
							ce.DeltakSRP__Program_Enrollment__c = peTmp.Id;
							ce.DeltakSRP__Academic_Section__c = asTmp.Id;
							ce.DeltakSRP__Academic_Start_Date__c = asTmp.DeltakSRP__Academic_Term__c;
							ce.DeltakSRP__Status__c = 'Enrolled';
							
							String asTmpIdentifier = asTmp.DeltakSRP__SIS_External_Id__c;
							
							if(asTmpIdentifier != null)
							{
								asTmpIdentifier = asTmpIdentifier.replace('UTX-','');
							}
							
							ce.DeltakSRP__SIS_External_Id__c = 'UTX-' + asTmpIdentifier + '-' + c.LMS_Username__c + '-' + asTmp.DeltakSRP__Academic_Term__c;
							
							ceSet.add(ce);
							
							ceIdToCourseEnrollmentMap.put(ce.DeltakSRP__SIS_External_Id__c, it);
							
						}
					}
					
				}
				
			} catch(Exception e) {
	 			it.Processing_Status__c = 'Errored';
				it.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 		}
		}
		
		if(ceSet.size() > 0 )
		{
			
			List<DeltakSRP__Course_Enrollment__c> ceList = new List<DeltakSRP__Course_Enrollment__c>(ceSet);
			
			Database.DMLOptions dmlo = new Database.DMLOptions();
			dmlo.optAllOrNone = false;
			Database.SaveResult[] cesr= Database.insert(ceList, dmlo);
			
			Integer recCount = 0;
			
			for(DeltakSRP__Course_Enrollment__c ce : ceList)
			{
				
				Integration_Transaction__c tmpIt = ceIdToCourseEnrollmentMap.get(ce.DeltakSRP__SIS_External_Id__c);
				
					
				try {
					
				
					if(!cesr[recCount].isSuccess())
					{
						throw new itDataException(cesr[recCount].getErrors() + '');
					}
				
					
				} catch(Exception e) {
	 				tmpIt.Processing_Status__c = 'Errored';
					tmpIt.Last_Error__c = 'Apex Class: II_ProcessUTCourseEnrollments.cls Line Number: ' + e.getLineNumber() + ' Message: ' + e;
	 			} finally{
	 				recCount++;
	 			}
	 			
			}
			
		}
		
		
		
		
	}
	
	
	
	return itList;
	
}


public static Map<String, DeltakSRP__Course_Enrollment__c> getCourseEnrollmentMap(List<Integration_Transaction__c> itList, Map<Id,utCourseEnrollment> itToUtceMap, Map<Id, Contact> itToContactMap, Map<Id, DeltakSRP__Academic_Section__c> asMap)
{
	
	Map<String, DeltakSRP__Course_Enrollment__c> ceStringMap = new Map<String, DeltakSRP__Course_Enrollment__c>();
	
	Set<String> whereClauseCESet = new Set<String>();
	
	for(Integration_Transaction__c it : itList)
	{
		if(it.Processing_Status__c == 'Queued')
		{
			utCourseEnrollment utce = itToUtceMap.get(it.Id);
			
			if(!utce.shortname.contains('BFP_'))
			{
				Contact c = itToContactMap.get(it.Id);
				DeltakSRP__Academic_Section__c asTmp = asMap.get(it.Id);
				
				whereClauseCESet.add('(DeltakSRP__Enrolled_Student__c = \'' + c.Id + '\' AND DeltakSRP__Academic_Section__c = \'' + asTmp.Id + '\')');
			}	
		}
	}
	
	//query for Course Enrollments
	List<DeltakSRP__Course_Enrollment__c> ceList = new List<DeltakSRP__Course_Enrollment__c>();
	if(whereClauseCESet.size() > 0)
	{
		String ceQuery = 'SELECT Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Section__c, DeltakSRP__Academic_Section__r.DeltakSRP__SIS_External_Id__c FROM DeltakSRP__Course_Enrollment__c WHERE ' + String.join(new List<String>(whereClauseCESet),' OR ');
		System.debug('ceQuery >---> ' + ceQuery);
	 	ceList = Database.query(ceQuery);
	}
	
	System.debug('ceList >---> ' + ceList);
	
	for(DeltakSRP__Course_Enrollment__c ce : ceList)
	{
		ceStringMap.put(ce.DeltakSRP__Enrolled_Student__c + ':' + ce.DeltakSRP__Academic_Section__c, ce);
	}
	
	return ceStringMap;
	
}

public static Map<String, DeltakSRP__Academic_Section__c> getAcademicSectionMap(List<Integration_Transaction__c> itList, Map<Id,utCourseEnrollment> itToUtceMap)
{
	
	Map<String, DeltakSRP__Academic_Section__c> asStringMap = new Map<String, DeltakSRP__Academic_Section__c>();
	
	Set<String> whereClauseASSet = new Set<String>();
	
	for(Integration_Transaction__c it : itList)
	{
		if(it.Processing_Status__c == 'Queued')
		{
			utCourseEnrollment utce = itToUtceMap.get(it.Id);
			
			if(!utce.shortname.contains('BFP_'))
			{
				whereClauseASSet.add('(DeltakSRP__SIS_External_Id__c = \'UTX-' + utce.shortname + '\')');
			}
		}
	}
	
	//academic section query
	List<DeltakSRP__Academic_Section__c> asList = new List<DeltakSRP__Academic_Section__c>();
	if(whereClauseASSet.size() > 0)
	{
		String asQuery = 'SELECT Id, DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Term__c FROM DeltakSRP__Academic_Section__c WHERE ' + String.join(new List<String>(whereClauseASSet),' OR ');
		System.debug('asQuery >---> ' + asQuery);
		asList = Database.query(asQuery);
	}
	
	System.debug('asList >---> ' + asList);
	
	for(DeltakSRP__Academic_Section__c asection : asList)
	{
		asStringMap.put(asection.DeltakSRP__SIS_External_Id__c, asection);
	}
	
	System.debug('asStringMap >---> ' + asStringMap);
	
	return asStringMap;
	
}

public static Map<String, DeltakSRP__Program_Enrollment__c> getProgramEnrollmentMap(List<Integration_Transaction__c> itList, Map<Id,Opportunity> itToOpportunity)
{
	 
	Map<String, DeltakSRP__Program_Enrollment__c> peStringMap = new Map<String, DeltakSRP__Program_Enrollment__c>();
	
	Set<String> whereClausePESet = new Set<String>();
	
	for(Integration_Transaction__c it : itList)
	{
		if(it.Processing_Status__c == 'Queued')
		{
			Opportunity opp = itToOpportunity.get(it.Id);
			System.debug('it >---> ' + it);
			System.debug('opp >---> ' + opp);
			whereClausePESet.add('(DeltakSRP__Enrolled_Student__c = \'' + opp.DeltakSRP__Student__c + '\' AND DeltakSRP__Academic_Program__c = \'' + opp.DeltakSRP__Academic_Program__c + '\')');
		}
	}
	
	
	if(whereClausePESet.size() > 0)
	{
		//program enrollment query
		String peQuery = 'SELECT Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Program__c FROM DeltakSRP__Program_Enrollment__c WHERE ' + String.join(new List<String>(whereClausePESet),' OR ');
		
		System.debug('peQuery >---> ' + peQuery);
		
		List<DeltakSRP__Program_Enrollment__c> peList = Database.query(peQuery);
		
		System.debug('peList >---> ' + peList);
		
		for(DeltakSRP__Program_Enrollment__c pe : peList)
		{
			peStringMap.put(pe.DeltakSRP__Enrolled_Student__c + ':' + pe.DeltakSRP__Academic_Program__c, pe);
		}
		
	}
	
	return peStringMap;
	
}

public static Map<String,Opportunity> getOpportunityMap(List<Integration_Transaction__c> itList, Map<Id,utCourseEnrollment> itToUtceMap, Account acc)
{
	
	Map<String,Opportunity> utCEIdentifierToOppMap = new Map<String,Opportunity>();
	
	Set<String> whereClauseOpportunitySet = new Set<String>();
	
	for(Integration_Transaction__c it : itList)
	{
		if(it.Processing_Status__c == 'Queued')
		{
			
			utCourseEnrollment utce = itToUtceMap.get(it.Id);
			whereClauseOpportunitySet.add('(DeltakSRP__Student__r.LMS_Username__c = \'' + utce.uniqueid + '\' AND (DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'UTX-' 
							+ utce.shortname.split('_')[0] + '\' OR DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'UTX-BFP\') AND AccountId = \'' + acc.Id + '\')');
		
		}
	}
	
	System.debug('whereClauseOpportunitySet >---> ' + whereClauseOpportunitySet);
	
	if(whereClauseOpportunitySet.size() > 0)
	{
		
		String queryOpportunity = 'SELECT Id, DeltakSRP__Student__c, DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Student__r.Email, DeltakSRP__Student__r.LMS_Username__c, DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c, Account.Name, AccountId FROM Opportunity WHERE (' + 
					String.join(new List<String>(whereClauseOpportunitySet),' OR ') + ')';		
		
		System.debug('queryOpportunity >---> ' + queryOpportunity);
		
		List<Opportunity> oppList = Database.query(queryOpportunity);
		
		for(Opportunity opp : oppList)
		{
			
			String tmpOppIdentifier = opp.DeltakSRP__Student__r.LMS_Username__c.toUppercase() + ':' + opp.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c + ':' + opp.AccountId;
		
			utCEIdentifierToOppMap.put(tmpOppIdentifier,opp);
		
		}
		
	}
	
	return utCEIdentifierToOppMap;
	
}

public static Map<String,DeltakSRP__Academic_Program__c> getAcademicProgramMap(List<Integration_Transaction__c> itList, Map<Id,utCourseEnrollment> itToUtceMap, Account acc)
{
	
	Map<String,DeltakSRP__Academic_Program__c> apEIdToAp = new Map<String,DeltakSRP__Academic_Program__c>();

	Set<String> whereClauseAcademicProgramSet = new Set<String>();
	
	whereClauseAcademicProgramSet.add('(DeltakSRP__SIS_External_Id__c LIKE \'UTX-%\')');
	/*
	for(Integration_Transaction__c it : itList)
	{
		if(it.Processing_Status__c == 'Queued')
		{
			
			utCourseEnrollment utce = itToUtceMap.get(it.Id);
			whereClauseAcademicProgramSet.add('(DeltakSRP__SIS_External_Id__c = \'UTX-' + utce.shortname.split('_')[0] + '\')');
			
		}
	}
	*/
	System.debug('whereClauseAcademicProgramSet >---> ' + whereClauseAcademicProgramSet);
	
	if(whereClauseAcademicProgramSet.size() > 0)
	{
		
		String academicProgramQuery = 'SELECT Id, Name, DeltakSRP__SIS_External_Id__c FROM DeltakSRP__Academic_Program__c WHERE DeltakSRP__School__c = \'' + acc.Id + '\' AND (' + String.join(new List<String>(whereClauseAcademicProgramSet),' OR ') + ')';
		
		System.debug('academicProgramQuery >---> ' + academicProgramQuery);
		
		List<DeltakSRP__Academic_Program__c> apList = Database.query(academicProgramQuery);
		
		for(DeltakSRP__Academic_Program__c ap : apList)
		{
			apEIdToAp.put(ap.DeltakSRP__SIS_External_Id__c,ap);
		}
		
	}
	
	return apEIdToAp;
	
}

public static Map<String,Contact> getContactMap(List<Integration_Transaction__c> itList, Map<Id,utCourseEnrollment> itToUtceMap, Account acc)
{
	
	Set<String> contactWhereSet = new Set<String>();
	
	for(Integration_Transaction__c it : itList)
	{
		
		if(it.Processing_Status__c == 'Queued')
		{
			utCourseEnrollment utce = itToUtceMap.get(it.Id);
			
			contactWhereSet.add('(LMS_Username__c = \'' + utce.uniqueId + '\') OR (Email = \'' + utce.email + '\')');
		}
		
	}
	
	System.debug('contactWhereSet >---> ' + contactWhereSet);
	
	Map<String,Contact> contactMap = new Map<String, Contact>();
	
	if(contactWhereSet.size() > 0)
	{
		String contactQuery = 'SELECT Id, firstName, lastName, Email, LMS_Username__c, Account.Name, AccountId, DeltakSRP__Person__c FROM Contact WHERE AccountId = \'' + acc.Id + '\' AND (' + String.join(new List<String>(contactWhereSet),' OR ') + ')';
		
		System.debug('contactQuery >---> ' + contactQuery);
		
		for(Contact c : Database.query(contactQuery))
		{
			
			if(c.LMS_Username__c != null && c.LMS_Username__c != '')
			{
				contactMap.put(c.LMS_Username__c.toUppercase(), c);
			}
			
			if(c.Email != null && c.Email != '')
			{
				contactMap.put(c.Email.toUppercase(),c);
			}
				
		}
		
		
	}

	return contactMap;
	
}

public static utCourseEnrollment generateUTCourseEnrollment(Integration_Transaction__c it, Map<String,Integer> nameToIndex)
{
	
	CSVReader reader = new CSVReader(it.Raw_Data__c.trim());
	
	List<String> dataList = reader.readLine();
	
	utCourseEnrollment utce = new utCourseEnrollment(
	dataList[nameToIndex.get('uniqueid')],
	dataList[nameToIndex.get('firstname')], 
	dataList[nameToIndex.get('lastname')],
	dataList[nameToIndex.get('email')],
	dataList[nameToIndex.get('enrollmentdate')],
	dataList[nameToIndex.get('shortname')],
	dataList[nameToIndex.get('fullname')],
	dataList[nameToIndex.get('startdate')],
	it.Id
	);
	
		return utce;
	
	
}

public static Map<String,Integer> generateNameToIndexMap(Integration_Interface__c ii)
{
	
	Map<String,Integer> nameToIndex = new Map<String,Integer>();
	
	if(ii.Raw_Header__c != null && ii.Raw_Header__c.trim() != '')
	{
		CSVReader reader = new CSVReader(ii.Raw_Header__c.trim());
		Integer columnIndex = 0;
		
		for(String s : reader.readLine())
		{
			nameToIndex.put(s.trim().toLowerCase(),columnIndex);
        	System.debug('header >---> ' + s);
        	System.debug('index >---> ' + columnIndex);
        	columnIndex++;
		}
		
	}
	
	return nameToIndex;
	
}

public static Boolean nullsInSobjectList(List<SObject> soList)
{
	for(SObject so : soList)
	{
		if(so == null)
		{
			return true;
		}
	}
	
	return false;
}


private class utCourseEnrollment {
public String uniqueid; 
public String firstname;
public String lastname; 
public String email;
public String enrollmentdate;
public String shortname;
public String fullname;
public String startdate;
public final String ceId;
public final String itId;
	
	public utCourseEnrollment(
	String uniqueid,
	String firstname, 
	String lastname,
	String email,
	String enrollmentdate,
	String shortname,
	String fullname,
	String startdate,
	String itId
	)
	{
		if(uniqueid != null)
		{
			this.uniqueid = uniqueid.trim();
		}
		
		if(firstname != null)
		{
			this.firstname = firstname.trim();
		}
		
		if(lastname != null)
		{
			this.lastname = lastname.trim();
		}
		
		if(email != null)
		{
			this.email = email.trim();
		}
		
		if(enrollmentdate != null)
		{
			this.enrollmentdate = enrollmentdate.trim();
		}
		
		if(shortname != null)
		{
			this.shortname = shortname.trim();
		}
		
		if(fullname != null)
		{
			this.fullname = fullname.trim();
		}
		
		if(startdate != null)
		{
			this.startdate = startdate.trim();
		}
		
		if(shortname != null && shortname.trim() != '' && uniqueid != null && uniqueid.trim() != '')
		{
			this.ceId = shortname.toUppercase() + ':' + uniqueid.toUppercase();
		}
		
		if(itId != null && itId != '')
		{
			this.itId = itId;
		}
		
	}
	
}

public class itDataException extends Exception { }

}