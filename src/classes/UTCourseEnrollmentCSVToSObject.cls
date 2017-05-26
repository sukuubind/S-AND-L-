public class UTCourseEnrollmentCSVToSObject {

public static List<UT_Course_Enrollment__c> csvToSobject(String csvString, String csvFilename)
{
	
	Map<String,Schema.RecordTypeInfo> accRtMapByName = (Schema.SObjectType.Account).getRecordTypeInfosByName();
	
	Account acc = [SELECT Id, Name FROM Account WHERE Name = 'University of Texas at Austin' AND RecordTypeId = :accRtMapByName.get('SRP Academic Institution').getRecordTypeId() LIMIT 1];
	
	
	List<UT_Course_Enrollment__c> utCEList = new List<UT_Course_Enrollment__c>();
	
	CSVReader reader = new CSVReader(csvString);
	
	List<String> line1 = null;
    Integer lineNumber = 0;
	
	//map of csv column header names to their index sequence
	Map<String,Integer> nameToIndex = new Map<String,Integer>();
	
	//map of opportunity identifier (firstname:lastname:email:UTX-shortname.split('_')[0]:University of Texas at Austin) to the UT_Course_Enrollment object record
	Map<String, UT_Course_Enrollment__c> oppIdentifierToUTCE = new Map<String, UT_Course_Enrollment__c>();
	
	//set to hold unique id's of records that come in with a BFP enrollment
	Set<String> utCEUniqueIdSet = new Set<String>();
	
	while( (line1 = reader.readLine()) != null){
		
		System.debug('line1: ' + line1);
		
		 if(lineNumber == 0)
		 {
            lineNumber++;
            Integer countFields = 0;
            
            for(String s : line1)
            {
            	nameToIndex.put(s.trim().toLowerCase(),countFields);
            	System.debug('header >---> ' + s);
            	System.debug('index >---> ' + countFields);
            	countFields++;
            }
            
         	continue;
         }
		
		System.debug('nameToIndex >---> ' + nameToIndex);
		
		UT_Course_Enrollment__c utCE = new UT_Course_Enrollment__c();
		
		utCE.Student_Unique_Id__c = line1[nameToIndex.get('uniqueid')].trim();
		utCE.Student_First_Name__c = line1[nameToIndex.get('firstname')].trim();
		utCE.Student_Last_Name__c = line1[nameToIndex.get('lastname')].trim();
		utCE.Student_Email__c = line1[nameToIndex.get('email')].trim();
		utCE.Course_Short_Name__c = line1[nameToIndex.get('shortname')].trim();
		utCE.Course_Full_Name__c = line1[nameToIndex.get('fullname')].trim();
		utCE.Course_Enrollment_DateTime__c = DateTime.newInstance(Long.valueof(line1[nameToIndex.get('enrollmentdate')].trim()) * 1000);
		utCE.Course_Start_DateTime__c = DateTime.newInstance(Long.valueof(line1[nameToIndex.get('startdate')].trim()) * 1000);
		
		utCE.Name = utCE.Student_First_Name__c + ' ' + utCE.Student_Last_Name__c + ', ' + utCE.Course_Short_Name__c;
		utCE.Email_Attachments__c = '[' + DateTime.now() + '] ' + csvFilename;
		utCE.CSV_Line__c = String.join(line1,',');
		utCE.Status__c = 'New';
		
		System.debug('utCE >---> ' + utCE);
		
		String tmpOppIdentifier = utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + 
								utCE.Student_Email__c.toLowerCase() + ':UTX-' + utCE.Course_Short_Name__c.split('_')[0] + 
								':' + acc.Id; 
		
		oppIdentifierToUTCE.put(tmpOppIdentifier,utCE);
		
		utCEList.add(utCE);
		
		if(utCE.Course_Short_Name__c.contains('BFP_'))
		{
			utCEUniqueIdSet.add(utCE.Course_Short_Name__c);
		}
		
	}
	
	system.debug('oppIdentifierToUTCE >---> ' + oppIdentifierToUTCE);
	
	//build whereclause to query for existing opportunities that may match incoming enrollment records
	Set<String> whereClauseSet = new Set<String>();
	
	for(String s : oppIdentifierToUTCE.keySet())
	{
		
		List<String> sList = s.split(':');
		
		whereClauseSet.add('(DeltakSRP__Student__r.FirstName = \'' + sList[0].toLowerCase() + '\' AND DeltakSRP__Student__r.LastName = \'' + sList[1].toLowerCase() + 
							'\' AND DeltakSRP__Student__r.Email = \'' + sList[2].toLowerCase() + '\' AND (DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'' 
							+ sList[3] + '\' OR DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'UTX-BFP\') AND AccountId = \'' + acc.Id + '\')');
		
	}
	
	String whereClause = String.join(new List<String>(whereClauseSet),' OR ');
	
	System.debug('whereClause >---> ' + whereClause);
	
	String queryString = 'SELECT Id, DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Student__r.Email, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c, Account.Name, AccountId FROM Opportunity WHERE ' + 
					whereClause;
					
	List<Opportunity> oppList = new List<Opportunity>();
	
	if(whereClauseSet.size() > 0)
	{
		oppList = Database.query(queryString);
	}
	
	System.debug('oppList >---> ' + oppList);
	
	Map<String,Opportunity> identifierToOpp = new Map<String,Opportunity>();
	
	//loop over matching opportunities and get matches from the map using the Academic Program Id for non-BFP
	for(Opportunity opp : oppList)
	{
		
		String tmpOppIdentifier = opp.DeltakSRP__Student__r.FirstName.toLowerCase() + ':' + opp.DeltakSRP__Student__r.LastName.toLowerCase() + ':' + 
								opp.DeltakSRP__Student__r.Email.toLowerCase() + ':' + opp.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c + 
								':' + opp.AccountId; 
		
		System.debug('tmpOppIdentifier >---> ' + tmpOppIdentifier);
		
		identifierToOpp.put(tmpOppIdentifier, opp);
		
	}
	
	System.debug('identifierToOpp >---> ' + identifierToOpp);
	
	//loop over matching opportunities and get matches from the map using the Academic Program Id for BFP
	for(UT_Course_Enrollment__c utCE : oppIdentifierToUTCE.values())
	{
		if(utCE.Opportunity__c == null)
		{
			
			String tmpOppIdentifier = utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + 
								utCE.Student_Email__c.toLowerCase() + ':UTX-' + utCE.Course_Short_Name__c.split('_')[0] + ':' + acc.Id; 
			
			String tmpOppIdentifierBFP = utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + 
								utCE.Student_Email__c.toLowerCase() + ':UTX-BFP:' + acc.Id; 
			
			System.debug('tmpOppIdentifierBFP >---> ' + tmpOppIdentifierBFP);
			System.debug('tmpOppIdentifier >---> ' + tmpOppIdentifier);
			
			Opportunity opp = null;
			opp = identifierToOpp.get(tmpOppIdentifierBFP);
			System.debug('BFPopp >---> ' + opp);
			if(opp == null)
			{					
				opp = identifierToOpp.get(tmpOppIdentifier);
				System.debug('non-BFPopp >---> ' + opp);
			}
					
			if(opp != null)
			{
				utCE.Opportunity__c = opp.Id;
			}
				
			
		}
	}
	
	System.debug('utCEListFinal >---> ' + utCEList);
	
	return utCEList;
}


public static Boolean createMissingOpps(List<UT_Course_Enrollment__c> utCEList)
{
	Map<String,Schema.RecordTypeInfo> oppRtMapByName = (Schema.SObjectType.Opportunity).getRecordTypeInfosByName();
	Map<String,Schema.RecordTypeInfo> accRtMapByName = (Schema.SObjectType.Account).getRecordTypeInfosByName();
	
	Account acc = [SELECT Id, Name FROM Account WHERE Name = 'University of Texas at Austin' AND RecordTypeId = :accRtMapByName.get('SRP Academic Institution').getRecordTypeId() LIMIT 1];
	
	//whereclauseset for querying for matching contacts
	Set<String> whereClauseContactSet = new Set<String>();
	
	//whereclauseset for querying for matching academic programs
	Set<String> whereClauseAcademicProgramSet = new Set<String>();
	
	Set<String> whereClauseOpportunitySet = new Set<String>();
		
	//map to hold course enrollment student unique id that come from the csv file, and map to the ut course enrollment record
	Map<String, Id> utCEBFPMap = new Map<String,Id>();
	
	System.debug('utCEList >---> ' + utCEList);
	
	for(UT_Course_Enrollment__c utCE : utCEList)
	{
		if(utCE.Opportunity__c == null && utCE.Status__c == 'New')
		{
			whereClauseContactSet.add('(FirstName =\'' + utCE.Student_First_Name__c + '\' AND LastName = \'' + utCE.Student_Last_Name__c +'\' AND Email = \'' + 
							utCE.Student_Email__c + '\' AND AccountId = \'' + acc.Id + '\')');
		
			whereClauseAcademicProgramSet.add('(DeltakSRP__SIS_External_Id__c = \'UTX-' + utCE.Course_Short_Name__c.split('_')[0] + '\')');
			
			whereClauseOpportunitySet.add('(DeltakSRP__Student__r.FirstName = \'' + utCE.Student_First_Name__c + '\' AND DeltakSRP__Student__r.LastName = \'' + utCE.Student_Last_Name__c + 
							'\' AND DeltakSRP__Student__r.Email = \'' + utCE.Student_Email__c + '\' AND (DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'UTX-' 
							+ utCE.Course_Short_Name__c.split('_')[0] + '\' OR DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c = \'UTX-BFP\') AND AccountId = \'' + acc.Id + '\')');
		
			
		}
		
		if(utCE.Course_Short_Name__c.contains('BFP_'))
		{
			utCEBFPMap.put(utCE.Student_Unique_Id__c, utCE.Id);
		}
		
	}
	
	system.debug('whereClauseContactSet >---> ' + whereClauseContactSet);
	
	String queryContact = 'SELECT Id, FirstName, LastName, Email, Account.Name, AccountId, DeltakSRP__Person__c FROM Contact WHERE (' + String.join(new List<String>(whereClauseContactSet),' OR ') + ')';
	
	system.debug('queryContact >---> ' + queryContact);
	
	List<Contact> contactList = Database.query(queryContact);
	
	system.debug('contactList >---> ' + contactList);
	
	//map from firstname:lastname:email:University of Texas at Austin of contact to contact record
	Map<String,Contact> utceToContact = new Map<String,Contact>();
	
	for(Contact c : contactList)
	{
		String tmpString = c.FirstName.toLowerCase() + ':' + c.LastName.toLowerCase() + ':' + c.Email.toLowerCase() + ':' + c.AccountId;
		utceToContact.put(tmpString,c);
	}
	
	System.debug('utceToContact >---> ' + utceToContact);
	
	System.debug('whereClauseAcademicProgramSet >---> ' + whereClauseAcademicProgramSet);
	
	String queryAcademicProgram = 'SELECT Id, Name, DeltakSRP__SIS_External_Id__c FROM DeltakSRP__Academic_Program__c WHERE (' + String.join(new List<String>(whereClauseAcademicProgramSet),' OR ') + ')';
	
	system.debug('queryAcademicProgram >---> ' + queryAcademicProgram);
	
	List<DeltakSRP__Academic_Program__c> AcademicProgramList = Database.query(queryAcademicProgram);
	
	//map from external id field to academic program record (i.e. UTX-ACC)
	Map<String,DeltakSRP__Academic_Program__c> utceToAcademicProgram = new Map<String,DeltakSRP__Academic_Program__c>();
	
	for(DeltakSRP__Academic_Program__c ap : AcademicProgramList)
	{
		utceToAcademicProgram.put(ap.DeltakSRP__SIS_External_Id__c,ap);
	}
	
	System.debug('utceToAcademicProgram >---> ' + utceToAcademicProgram);
	
	system.debug('whereClauseOpportunitySet >---> ' + whereClauseOpportunitySet);
	
	String queryOpportunity = 'SELECT Id, DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Student__r.Email, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c, Account.Name, AccountId FROM Opportunity WHERE (' + 
					String.join(new List<String>(whereClauseOpportunitySet),' OR ') + ')';
					
	List<Opportunity> oppList = Database.query(queryOpportunity);
	
	System.debug('oppList >---> ' + oppList);
	
	Map<String,Opportunity> utCEIdentifierToOppMap = new Map<String,Opportunity>();
	
	for(Opportunity opp : oppList)
	{
		String tmpOppIdentifier = opp.DeltakSRP__Student__r.FirstName.toLowerCase() + ':' + opp.DeltakSRP__Student__r.LastName.toLowerCase() + ':' + opp.DeltakSRP__Student__r.Email.toLowerCase() + ':' + 
									opp.DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c + ':' + opp.AccountId;
		
		utCEIdentifierToOppMap.put(tmpOppIdentifier,opp);
		
	}
	
	System.debug('utCEIdentifierToOppMap >---> ' + utCEIdentifierToOppMap);
	
	//map of ut course enrollment record id to opp to create
	Map<Id,Opportunity> oppsToCreate = new Map<Id,Opportunity>();
	
	//attempt to match UTCE's to opportunities and if matched save in this list 
	List<UT_Course_Enrollment__c> utCEsToUpdate = new List<UT_Course_Enrollment__c>();
	
	//set of ut course enrollment record ids that no opportunity will be created for due to missing contact or academic program
	Set<Id> utCEsToError = new Set<Id>();
	
	//set of ur course enrollment record ids that came in with BFP certificate program
	Set<Id> utCEsToBFP = new Set<Id>();
	
	System.debug('utCEBFPMap >---> ' + utCEBFPMap);
	
	for(UT_Course_Enrollment__c utCE : utCEList)
	{
		String oppIdentifierString = utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + utCE.Student_Email__c.toLowerCase() + ':UTX-' 
									 + utCE.Course_Short_Name__c.split('_')[0] + ':' + acc.Id;
		
		String oppIdentifierBFPString = utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + utCE.Student_Email__c.toLowerCase() + ':UTX-BFP:' 
									    + acc.Id;
		
		if(utCE.Opportunity__c == null && utCE.Status__c == 'New')
		{
			Opportunity opp = null;
			opp = utCEIdentifierToOppMap.get(oppIdentifierBFPString);
			
			if(opp == null)
			{
				opp = utCEIdentifierToOppMap.get(oppIdentifierString);
			}
			
			if(opp != null)
			{
				utCE.Opportunity__c = opp.Id;
				utCEsToUpdate.add(utCE);
			}
			
		}
		
		//if no opportunity and status is new and 
		//either the student unique id is not in the BFP map of unique ids (non-BFP enrollments) 
		//or the student unique id is in the BFP map and the course is a BFP course ((BFP enrollments))
		//then create an opportunity
		if(utCE.Opportunity__c == null && utCE.Status__c == 'New' && 
		( !utCEBFPMap.keySet().contains(utCE.Student_Unique_Id__c) || 
			(utCEBFPMap.keySet().contains(utCE.Student_Unique_Id__c) && utCE.Course_Short_Name__c.contains('BFP_')) 
		) )
		{
			Contact c = utceToContact.get(utCE.Student_First_Name__c.toLowerCase() + ':' + utCE.Student_Last_Name__c.toLowerCase() + ':' + utCE.Student_Email__c.toLowerCase() + ':' + acc.Id);
			DeltakSRP__Academic_Program__c ap = utceToAcademicProgram.get('UTX-' + utCE.Course_Short_Name__c.split('_')[0]);
			
			if(c != null && ap != null)
			{
				
				Opportunity o = new Opportunity();
				o.RecordTypeId = oppRtMapByName.get('SRP Opportunity').getRecordTypeId();
				o.Name = utCE.Student_First_Name__c + ' ' + utCE.Student_Last_Name__c;
				o.stageName = 'Dormant';
				o.DeltakSRP__Sub_Stage__c = 'Duplicate Record';
				o.DeltakSRP__Student__c = c.Id;
				o.DeltakSRP__Academic_Program__c = ap.Id;
				o.AccountId = acc.Id;
				o.CloseDate = DateTime.newInstance(2100,1,1).date();
				o.SRP_Person__c = c.DeltakSRP__Person__c;
				
				oppsToCreate.put(utCE.Id, o);
				
			}
			else
			{
				utCEsToError.add(utCE.Id);
			}
			
		}
		//if ut course enrollment has no assigned opportunity, is new, and is a BFP student but the record is not a BFP record (one of the courses related to BFP)
		else if(utCE.Opportunity__c == null && utCE.Status__c == 'New' && 
		utCEBFPMap.keySet().contains(utCE.Student_Unique_Id__c) && !utCE.Course_Short_Name__c.contains('BFP_'))
		{
			utCEsToBFP.add(utCE.Id);
		}
	}
	
	System.debug('utCEsToUpdate >---> ' + utCEsToUpdate);
	
	if(utCEsToUpdate.size() > 0)
	{
		update utCEsToUpdate;
	}
	
	system.debug('oppsToCreate >---> ' + oppsToCreate.values());
	
	if(oppsToCreate.values() != null && oppsToCreate.values().size() > 0)
	{
		insert oppsToCreate.values();
	}
	
	system.debug('oppsToCreate complete >---> ' + oppsToCreate.values());
	
	//query for id, status, andopportunity fields for ut course enrollments which opps were created for in order to update
	List<UT_Course_Enrollment__c> successutCEList = [SELECT Id, Status__c, Opportunity__c FROM UT_Course_Enrollment__c WHERE Id IN :oppsToCreate.keySet()];
	
	system.debug('successutCEList >---> ' + successutCEList);
	
	//update opportunity field with inserted opportunity ids for ut course enrollments which opps were created for
	for(UT_Course_Enrollment__c utce : successutCEList)
	{
		utce.Opportunity__c = oppsToCreate.get(utce.Id).Id;
		utce.Status__c = 'New';
	}
	
	//query for failed opps to update status
	List<UT_Course_Enrollment__c> failedutCEList = [SELECT Id, Status__c FROM UT_Course_Enrollment__c WHERE Id IN :utCEsToError];
	
	for(UT_Course_Enrollment__c utce : failedutCEList)
	{
		utce.Status__c = 'Error';
	}
	
	//query for BFP ut course enrollments to update
	List<UT_Course_Enrollment__c> bfputCEList = [SELECT Id, Status__c, Opportunity__c, Student_Unique_Id__c FROM UT_Course_Enrollment__c WHERE Id IN :utCEsToBFP];
	
	System.debug('utCEBFPMap >---> ' + utCEBFPMap);
	
	//get the opportunity created for the BFP enrollment record and use the same one for related courses.
	for(UT_Course_Enrollment__c utce : bfputCEList)
	{
		try {
			utce.Opportunity__c = oppsToCreate.get(utCEBFPMap.get(utce.Student_Unique_Id__c)).Id;
			utce.Status__c = 'New';
		}Catch(Exception e){utce.Status__c = 'Error';}
	}
	
	//combine all ut course enrollment records that need updating
	List<UT_Course_Enrollment__c> updateutCEList = new List<UT_Course_Enrollment__c>();
	updateutCEList.addAll(successutCEList);
	updateutCEList.addAll(failedutCEList);
	updateutCEList.addAll(bfputCEList);
	
	if(updateutCEList.size() > 0)
	{
		update updateutCEList;
	}
	
	return true;
	
}

public static Boolean processUTCourseEnrollmentRecords(List<UT_Course_Enrollment__c> utCEList)
{
	//set for opportunity ids
	Set<Id> oppIdSet = new Set<Id>();
	
	//set for ut course enrollment ids
	Set<Id> utCEIdSet = new Set<Id>();
	for(UT_Course_Enrollment__c utCE : utCEList)
	{
		if(utCE.Status__c == 'New' && utCE.Opportunity__c != null)
		{
			utCEIdSet.add(utCE.Id);
			oppIdSet.add(utCE.Opportunity__c);
		}
	}
	
	//select ur course enrollment records
	List<UT_Course_Enrollment__c> utCEListToUpdate = 
	[SELECT Id, Status__c, Course_Short_Name__c, Opportunity__c, Opportunity__r.DeltakSRP__Student__c, 
	Opportunity__r.DeltakSRP__Academic_Program__c, Course_Start_DateTime__c, Program_Enrollment__c, 
	Course_Enrollment__c, Academic_Section__c  
	FROM UT_Course_Enrollment__c WHERE Id IN :utCEIdSet];
	
	System.debug('utCEListToUpdate >---> ' + utCEListToUpdate);
	
	//academic program set of ids
	Set<Id> apIdSet = new Set<Id>();
	
	//whereclause for Program Enrollments query
	Set<String> whereClausePESet = new Set<String>();
	
	//whereclause for Course Enrollments query
	Set<String> whereClauseCESet = new Set<String>();
	
	//whereclause for Academic Sections query
	Set<String> whereClauseASSet = new Set<String>();
	
	for(UT_Course_Enrollment__c utCE : utCEListToUpdate)
	{
		
		apIdSet.add(utCE.Opportunity__r.DeltakSRP__Academic_Program__c);	
		utCE.Status__c = 'Processed';
		whereClausePESet.add('(DeltakSRP__Enrolled_Student__c = \'' + utCE.Opportunity__r.DeltakSRP__Student__c + '\' AND DeltakSRP__Academic_Program__c = \'' + utCE.Opportunity__r.DeltakSRP__Academic_Program__c + '\')');
		
		if(!utCE.Course_Short_Name__c.contains('BFP_'))
		{
			whereClauseCESet.add('(DeltakSRP__Enrolled_Student__c = \'' + utCE.Opportunity__r.DeltakSRP__Student__c + '\' AND DeltakSRP__Academic_Section__r.DeltakSRP__SIS_External_Id__c = \'UTX-' + utCE.Course_Short_Name__c + '\')');
			whereClauseASSet.add('(DeltakSRP__SIS_External_Id__c = \'UTX-' + utCE.Course_Short_Name__c + '\')');
		
		}
		
	}
	
	//query for academic terms for existing the academic programs
	List<DeltakSRP__Academic_Start_Date__c> atList = [SELECT Id, DeltakSRP__Academic_Program__c FROM DeltakSRP__Academic_Start_Date__c WHERE DeltakSRP__Academic_Program__c IN :apIdSet];
	
	//Academic program id to academic term object record map
	Map<Id,DeltakSRP__Academic_Start_Date__c> apToAtMap = new Map<Id,DeltakSRP__Academic_Start_Date__c>();
	for(DeltakSRP__Academic_Start_Date__c currAt : atList)
	{
		apToAtMap.put(currAt.DeltakSRP__Academic_Program__c, currAt);
	}
	
	System.debug('apToAtMap >---> ' + apToAtMap);
	
	//program enrollment query
	String peQuery = 'SELECT Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Program__c FROM DeltakSRP__Program_Enrollment__c WHERE ' + String.join(new List<String>(whereClausePESet),' OR ');
	
	System.debug('peQuery >---> ' + peQuery);
	
	List<DeltakSRP__Program_Enrollment__c> peList = Database.query(peQuery);
	
	System.debug('peList >---> ' + peList);
	
	//student-academic program identifier to program enrollment object record map
	Map<String,DeltakSRP__Program_Enrollment__c> sapToPE = new Map<String,DeltakSRP__Program_Enrollment__c>();
	for(DeltakSRP__Program_Enrollment__c pe : peList)
	{
		sapToPE.put(pe.DeltakSRP__Enrolled_Student__c + ':' + pe.DeltakSRP__Academic_Program__c, pe);
	}
	
	System.debug('sapToPE >---> ' + sapToPE);
	
	//list of Program Enrollments to create
	List<DeltakSRP__Program_Enrollment__c> peToCreate = new List<DeltakSRP__Program_Enrollment__c>();
	
	for(UT_Course_Enrollment__c utCE : utCEListToUpdate)
	{
		String tmpIdentifier = utCE.Opportunity__r.DeltakSRP__Student__c + ':' + utCE.Opportunity__r.DeltakSRP__Academic_Program__c;
		//if no existing Program Enrollment, create one
		if(sapToPE.get(tmpIdentifier) == null)
		{
			
			DeltakSRP__Program_Enrollment__c pe = new DeltakSRP__Program_Enrollment__c();
			pe.DeltakSRP__Enrolled_Student__c = utCE.Opportunity__r.DeltakSRP__Student__c;
			pe.DeltakSRP__Academic_Program__c = utCE.Opportunity__r.DeltakSRP__Academic_Program__c;
			pe.DeltakSRP__Enrollment_Start__c = apToAtMap.get(utCE.Opportunity__r.DeltakSRP__Academic_Program__c).Id;
			pe.DeltakSRP__Opportunity__c = utCE.Opportunity__c;
			pe.DeltakSRP__Enrollment_Status__c = 'New';
			
			sapToPE.put(tmpIdentifier, pe);
			
			peToCreate.add(pe);
			
		}
	}
	
	//if there are Program Enrollments in the list, create them
	if(peToCreate.size() > 0)
	{
		insert peToCreate;
	}
	
	//go back and add the newly created Program Enrollments to the student-academic program to Program Enrollment object record map
	for(DeltakSRP__Program_Enrollment__c pe : peToCreate)
	{
		sapToPE.put(pe.DeltakSRP__Enrolled_Student__c + ':' + pe.DeltakSRP__Academic_Program__c, pe);
	}
	
	System.debug('sapToPE >---> ' + sapToPE);
	
	//query for Course Enrollments
	List<DeltakSRP__Course_Enrollment__c> ceList = new List<DeltakSRP__Course_Enrollment__c>();
	if(whereClauseCESet.size() > 0)
	{
		String ceQuery = 'SELECT Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Section__c, DeltakSRP__Academic_Section__r.DeltakSRP__SIS_External_Id__c FROM DeltakSRP__Course_Enrollment__c WHERE ' + String.join(new List<String>(whereClauseCESet),' OR ');
		System.debug('ceQuery >---> ' + ceQuery);
	 	ceList = Database.query(ceQuery);
	}
	
	System.debug('ceList >---> ' + ceList);
	
	//map of student-academic section to course enrollment object record map
	Map<String,DeltakSRP__Course_Enrollment__c> scsToCEMap = new Map<String,DeltakSRP__Course_Enrollment__c>();
	for(DeltakSRP__Course_Enrollment__c ce : ceList)
	{
		scsToCEMap.put(ce.DeltakSRP__Enrolled_Student__c + ':' + ce.DeltakSRP__Academic_Section__r.DeltakSRP__SIS_External_Id__c, ce);
	}
	
	System.debug('scsToCEMap >---> ' + scsToCEMap);
	
	//academic section query
	List<DeltakSRP__Academic_Section__c> asList = new List<DeltakSRP__Academic_Section__c>();
	if(whereClauseASSet.size() > 0)
	{
		String asQuery = 'SELECT Id, DeltakSRP__SIS_External_Id__c, DeltakSRP__Academic_Term__c FROM DeltakSRP__Academic_Section__c WHERE ' + String.join(new List<String>(whereClauseASSet),' OR ');
		System.debug('asQuery >---> ' + asQuery);
		asList = Database.query(asQuery);
	}
	
	System.debug('asList >---> ' + asList);
	
	//academic section external id to academic section object record map
	Map<String,DeltakSRP__Academic_Section__c> extIdToASMap = new Map<String,DeltakSRP__Academic_Section__c>();
	for(DeltakSRP__Academic_Section__c asection : asList)
	{
		extIdToASMap.put(asection.DeltakSRP__SIS_External_Id__c, asection);
	}
	
	System.debug('extIdToASMap >---> ' + extIdToASMap);
	
	//course enrollments list to create
	Map<Id,DeltakSRP__Course_Enrollment__c> utceToCEMap = new Map<Id,DeltakSRP__Course_Enrollment__c>();
	for(UT_Course_Enrollment__c utCE : utCEListToUpdate)
	{
		String tmpIdentifierCE = utCE.Opportunity__r.DeltakSRP__Student__c + ':UTX-' + utCE.Course_Short_Name__c;
		String tmpIdentifierPE = utCE.Opportunity__r.DeltakSRP__Student__c + ':' + utCE.Opportunity__r.DeltakSRP__Academic_Program__c;
		String tmpIdentifierAS = 'UTX-' + utCE.Course_Short_Name__c;
		
		//if the course is not BFP and there is no existing course enrollment for that student/course section combination, create one
		if(!utCE.Course_Short_Name__c.contains('BFP_') && scsToCEMap.get(tmpIdentifierCE) == null)
		{
			
			DeltakSRP__Course_Enrollment__c ce = new DeltakSRP__Course_Enrollment__c();
			ce.DeltakSRP__Enrolled_Student__c = utCE.Opportunity__r.DeltakSRP__Student__c;
			ce.DeltakSRP__Program_Enrollment__c = sapToPE.get(tmpIdentifierPE).Id;
			ce.DeltakSRP__Academic_Section__c = extIdToASMap.get(tmpIdentifierAS).Id;
			ce.DeltakSRP__Academic_Start_Date__c = extIdToASMap.get(tmpIdentifierAS).DeltakSRP__Academic_Term__c;
			ce.DeltakSRP__Status__c = 'Enrolled';
			
			utceToCEMap.put(utCE.Id, ce);
			
			utCE.Program_Enrollment__c = ce.DeltakSRP__Program_Enrollment__c;
			utCE.Academic_Section__c = ce.DeltakSRP__Academic_Section__c;
			
		}
	}
	
	System.debug('utceToCEMap >---> ' + utceToCEMap);
	
	//if any course enrollments to create, create them
	if(utceToCEMap.values().size() > 0)
	{
		insert utceToCEMap.values();
	}
	
	for(UT_Course_Enrollment__c utCE : utCEListToUpdate)
	{
		DeltakSRP__Course_Enrollment__c tmpCE = null;
		
		tmpCE = utceToCEMap.get(utCE.Id);
		
		if(tmpCE != null)
		{
			utCE.Course_Enrollment__c = tmpCE.Id;
		}
		
	}
	
	
	//update ut course enrollment records' status to processed
	update utCEListToUpdate;
	
	return true;
	
}




}