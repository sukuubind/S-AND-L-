public without sharing class SRPCourseEnrollmentTriggerHandler {
//VIGNESH R - UPDATING EARLIEST TERM START DATE ON CONTACT AFTER INSERT, AFTER DELETE AND AFTER UPDATE - CONDITIONALLY
    public static  Map<Id, Contact> handleAfterInsert(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList){
        Map<Id, Contact> returnMap =updateEarliest_Term_Start_Date(courseEnrollmentList, true);
        return returnMap;
    }
    public static  Map<Id, Contact> handleAfterUpdate(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList, Map<Id, DeltakSRP__Course_Enrollment__c> oldMap){
        Map<Id, Contact> returnMap =updateEarliest_Term_Start_Date(courseEnrollmentList, oldMap, false);
        return returnMap;
    }
   /* public static  Map<Id, Contact> handleAfterDelete(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList){
    	Map<Id, Contact> returnMap = updateEarliest_Term_Start_Date(courseEnrollmentList);
    	return returnMap;
    }*/
    
    // AFTER INSERT
    public static Map<Id, Contact> updateEarliest_Term_Start_Date(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList, Boolean isInsert){
    	List<Contact> studentUpdList1 = new List<Contact>();
    	if(courseEnrollmentList!=null && courseEnrollmentList.size()>0)
    	{
    		
    		Map<String,Date> studentCourseSectionStDateMap = new Map<String, Date>();
	    	for(DeltakSRP__Course_Enrollment__c ce:courseEnrollmentList)
	    	{
	    		Date courseSectionStartDate = null;
    			String studentId = null;
	    		courseSectionStartDate = ce.Course_Section_Start_Date__c;
	    		studentId = ce.DeltakSRP__Student_ID__c;
	    		studentCourseSectionStDateMap.put(studentId,courseSectionStartDate);
	    	}
	    	Set<String> students = studentCourseSectionStDateMap.keySet();
	    	List<String> studentList = new List<String>();
	    	for(String sId: students)
	    	{
	    		if(sId!=null)
	    		{
	    			studentList.add(sId);
	    		}
	    	}
	    	//studentList.addAll(students);
	    	if(studentList.size()>0)
	    	{
	    		Map<String, Date> studentEarlyTermStDate = new Map<String, Date>();
	    	
		    	List<Contact> studentDates = [Select Number_Of_Terms_Out__c, DeltakSRP__Student_ID__c, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c in :studentList];
		    	
		    	for(Contact st1: studentDates)
			    {
			   		studentEarlyTermStDate.put(st1.DeltakSRP__Student_ID__c,st1.Earliest_Term_Start_Date__c);
			   	}
			   	Map<String,Date> studentNewETermStDate = new Map<String,Date>();
			   	for(String st2: studentList)
			   	{
			   		if(studentCourseSectionStDateMap.get(st2)!=null)
			   		{
			   			if(studentEarlyTermStDate.get(st2)==null )
			    		{
			    			studentNewETermStDate.put(st2,studentCourseSectionStDateMap.get(st2)); 
			    		}
			    		else if(studentEarlyTermStDate.get(st2) > studentCourseSectionStDateMap.get(st2))
			    		{
			    			studentNewETermStDate.put(st2,studentCourseSectionStDateMap.get(st2)); 
			    		}
			   		}
			   	
			   	}
			   	if(!studentNewETermStDate.isEmpty())
			   	{
				   	Set<String> studentUpd = studentNewETermStDate.keySet();
			    	List<String> studentUpdList = new List<String>();
			    	studentUpdList.addAll(studentUpd);
			    	List<Contact> student = [Select id, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c in :studentUpdList];
			    	
			    	for(Contact st: student)
			    	{
			    		Contact st2 = new Contact(id=st.id);
			    		st2.Earliest_Term_Start_Date__c = studentNewETermStDate.get(st.id);
			    		studentUpdList1.add(st2);
			    	}
			    	if(studentUpdList1!=null && studentUpdList1.size()>0)
			    	{
			    		try{
			    		//Database.update(studentUpdList1);
			    		}catch(Exception e)
			    		{
			    			System.debug(e);
			    		}
			    	}
			   	}
	    	}
	    	
	    	
    	}
    	 return fetchReturnMap(studentUpdList1);
    
    }
    // AFTER DELETE
   /* public static Map<Id, Contact> updateEarliest_Term_Start_Date(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList){
    	List<Contact> studentUpdList1 = new List<Contact>();
    	if(courseEnrollmentList!=null && courseEnrollmentList.size()>0)
    	{
    		List<String> studentIds = new List<String>();
    		
	    	for(DeltakSRP__Course_Enrollment__c ce:courseEnrollmentList)
	    	{
	    		if(ce.DeltakSRP__Student_ID__c!=null)
	    		{
	    			studentIds.add(ce.DeltakSRP__Student_ID__c);
	    		}
	    	
	    	}
	    	if(studentIds.size()>0)
	    	{
	    		List<AggregateResult> eTermStDt = [Select d.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_ID__c, MIN(d.Course_Section_Start_Date__c) 
	    									From DeltakSRP__Course_Enrollment__c d group by d.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_ID__c]; 
				Map<String, Date> studentNewETermStDate = new Map<String, Date>();
				Date newEarlyTermStDt = null;
				for(AggregateResult ar:eTermStDt)
				{
					studentNewETermStDate.put(String.valueOf(ar.get('st')),Date.valueOf(ar.get('estdt')));
					newEarlyTermStDt = Date.valueOf(ar.get('expr0'));
				}
		    	
		    	Map<String, Date> studentETermStDate = new Map<String, Date>();
		    	Date earlyTermStDt = null;
		    	Date earlyTermStDtUpd = null;
		    	List<Contact> student = [Select Number_Of_Terms_Out__c, DeltakSRP__Student_ID__c, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c = :studentIds];
		    	for(Contact st: student)
		    	{
		    		studentETermStDate.put(st.DeltakSRP__Student_ID__c, st.Earliest_Term_Start_Date__c);
		    	}
		    	
		    	Map<String,Date> studentFinalETermStDate = new Map<String,Date>();
		    	for(String stu: studentIds)
		    	{
		    		if(studentETermStDate.get(stu)==null)
		    		{
		    			studentFinalETermStDate.put(stu,studentNewETermStDate.get(stu));
		    		}
		    		else if(studentETermStDate.get(stu) > studentNewETermStDate.get(stu))
		    		{
		    			studentFinalETermStDate.put(stu,studentNewETermStDate.get(stu));
		    		}
		    	}
		    	if(!studentFinalETermStDate.isEmpty())
			   	{
				   	Set<String> studentUpd = studentFinalETermStDate.keySet();
			    	List<String> studentUpdList = new List<String>();
			    	studentUpdList.addAll(studentUpd);
			    	List<Contact> student1 = [Select Number_Of_Terms_Out__c, id, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c in :studentUpdList];
			    	
			    	for(Contact st: student1)
			    	{
			    		Contact st2 = new Contact(id=st.id);
			    		st2.Earliest_Term_Start_Date__c = studentFinalETermStDate.get(st.id);
			    		studentUpdList1.add(st2);
			    	}
			    	if(studentUpdList1!=null && studentUpdList1.size()>0)
			    	{
			    		try{
			    		//Database.update(studentUpdList1);
			    		}catch(Exception e)
			    		{
			    			System.debug(e);
			    		}
			    	}
			   	}
	    	}
	    	
	    	
    	}
    	 return fetchReturnMap(studentUpdList1);
    
    }*/
    // AFTER UPDATE
    public static Map<Id, Contact> updateEarliest_Term_Start_Date(List<DeltakSRP__Course_Enrollment__c> courseEnrollmentList, Map<Id, DeltakSRP__Course_Enrollment__c> oldMap, Boolean isInsert){
    	List<Contact> studentUpdList1 = new List<Contact>();
    	if(courseEnrollmentList!=null && courseEnrollmentList.size()>0)
    	{
    		Map<String,Date> studentCourseSectionStDateMap = new Map<String,Date>();
    		Map<String,Id> studentCourseSectionMap = new Map<String,Id>();
	    	for(DeltakSRP__Course_Enrollment__c ce:courseEnrollmentList)
	    	{
	    		Date courseSectionStartDate = null;
    			String studentId = null;
	    		courseSectionStartDate = ce.Course_Section_Start_Date__c;
	    		studentId = ce.DeltakSRP__Student_ID__c;
	    		studentCourseSectionStDateMap.put(studentId,courseSectionStartDate);
	    		studentCourseSectionMap.put(studentId,ce.DeltakSRP__Academic_Section__r.Id);
	    	}
	    	
	    	Set<String> students = studentCourseSectionStDateMap.keySet();
	    	List<String> studentList = new List<String>();
	    	for(String sId: students)
	    	{
	    		if(sId!=null)
	    		{
	    			studentList.add(sId);
	    		}
	    	}
	    	//studentList.addAll(students);
	    	if(studentList.size()>0)
	    	{
	    		Map<String, Date> studentEarlyTermStDate = new Map<String, Date>();
	    	
		    	List<Contact> studentDates = [Select Number_Of_Terms_Out__c, DeltakSRP__Student_ID__c, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c in :studentList];
		    	
		    	for(Contact st1: studentDates)
			    {
			   		studentEarlyTermStDate.put(st1.DeltakSRP__Student_ID__c,st1.Earliest_Term_Start_Date__c);
			   	}
			   	Map<String,Id> oldStudentCourseSectionMap = new Map<String,Id>();
			   	List<DeltakSRP__Course_Enrollment__c> oldCEList = oldMap.values();
			   	for(DeltakSRP__Course_Enrollment__c oCE: oldCEList)
			   	{
			   		oldStudentCourseSectionMap.put(oCE.DeltakSRP__Student_ID__c,oCE.DeltakSRP__Academic_Section__r.Id);
			   	}
			   	
	    		Map<String,Date> studentNewETermStDate = new Map<String,Date>();
			   	for(String st2: studentList)
			   	{
			   		if(studentCourseSectionStDateMap.get(st2)!=null)
			   		{
			   			if(studentEarlyTermStDate.get(st2)==null )
			    		{
			    			studentNewETermStDate.put(st2,studentCourseSectionStDateMap.get(st2)); 
			    		}
			    		else 
			    		{
			    			//String.valueOf(((studentEnrollHistMap.get(st2)).DeltakSRP__Academic_Term2__c))
			    			String courseSectionId = oldStudentCourseSectionMap.get(st2);
			    			System.debug('courseSectionId-->'+courseSectionId);
			    			if(String.valueOf(studentCourseSectionMap.get(st2)) != courseSectionId)
			    			{
			    				if(studentEarlyTermStDate.get(st2) > studentCourseSectionStDateMap.get(st2))
			    				{
			    					studentNewETermStDate.put(st2,studentCourseSectionStDateMap.get(st2)); 
			    				}
			    			}
	
			    		}
			   		}
			   	
			   	}
	    		
		    	if(!studentNewETermStDate.isEmpty())
			   	{
				   	Set<String> studentUpd = studentNewETermStDate.keySet();
			    	List<String> studentUpdList = new List<String>();
			    	studentUpdList.addAll(studentUpd);
			    	List<Contact> student = [Select Number_Of_Terms_Out__c, id, Earliest_Term_Start_Date__c from Contact where DeltakSRP__Student_ID__c in :studentUpdList];
			    	
			    	for(Contact st: student)
			    	{
			    		Contact st2 = new Contact(id=st.id);
			    		st2.Earliest_Term_Start_Date__c = studentNewETermStDate.get(st.id);
			    		studentUpdList1.add(st2);
			    	}
			    	if(studentUpdList1!=null && studentUpdList1.size()>0)
			    	{
			    		try{
			    		//Database.update(studentUpdList1);
			    		}catch(Exception e)
			    		{
			    			System.debug(e);
			    		}
			    	}
			   	}
	    	}
	    		
    	}
    	 return fetchReturnMap(studentUpdList1);
    }
    
	public static Map<Id, Contact> updateNumberOfTermsOutOnContact(List<DeltakSRP__Course_Enrollment__c> newcourseEnrolls, Map<Id, Contact> inputMap, List<DeltakSRP__Course_Enrollment__c> oldCourseEnrolls){
		 
		 List<DeltakSRP__Course_Enrollment__c> courseEnrolls = new List<DeltakSRP__Course_Enrollment__c>();
		 for(Integer i=0;i<newCourseEnrolls.size();i++){
		 	DeltakSRP__Course_Enrollment__c newRec = newCourseEnrolls.get(i);
		 	if(oldCourseEnrolls != null){
		 		DeltakSRP__Course_Enrollment__c oldRec = oldCourseEnrolls.get(i);
		 		if(newRec.DeltakSRP__Academic_Section__c != oldRec.DeltakSRP__Academic_Section__c){
		 			courseEnrolls.add(newRec);
		 		}
		 	}else{
		 		courseEnrolls.add(newRec);
		 	}
		 	
		 }
		 
		 List<Id> contactids = new List<Id>();
		 List<Id> programids = new List<Id>();
		 
		 /*Map<String, Academic_Term_Settings__c> actSettings = Academic_Term_Settings__c.getAll();
		 List<Academic_Term_Settings__c> ats = new List<Academic_Term_Settings__c>();
		 ats = [Select name, order__c from Academic_Term_Settings__c ORDER BY order__c DESC];*/
		 
		 //system.debug('ats[0]>>>>'+ats[0]);
		 
		 List<DeltakSRP__Course_Enrollment__c> ceList = [Select DeltakSRP__Academic_Section__c, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Section__r.Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c from DeltakSRP__Course_Enrollment__c
		 		where Id in: courseEnrolls];
		 		
		 for(DeltakSRP__Course_Enrollment__c ce: celist){
		 		if(ce.DeltakSRP__Academic_Section__c != null)
		 			contactids.add(ce.DeltakSRP__Enrolled_Student__c);
		 			
		 		programIds.add(ce.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c);	
		 }	
		
		system.debug('programIds>>>>'+programids); 
		List<DeltakSRP__Academic_Program__c> programs = [Select Id, (Select Id, Academic_Term_Master__c, Academic_Term_Master__r.Term_Start_Date__c  from DeltakSRP__Academic_Start_Dates__r where DeltakSRP__Start_Date__c <= :system.today() ORDER BY DeltakSRP__Start_Date__c DESC) from DeltakSRP__Academic_Program__c where id in: programids];
		 
		Map<Id, DeltakSRP__Academic_Program__c> pmap= new Map<Id, DeltakSRP__Academic_Program__c>();
		 
		 for(DeltakSRP__Academic_Program__c p: programs){
		 	pmap.put(p.id, p);	
		 }	
		 
		 List<Contact> contacts = [Select Id, Number_of_Terms_Out__c, last_Enrollment_date__c, (Select Id, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Section__r.Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c, DeltakSRP__Academic_Start_Date__r.Academic_Term_Master__c, DeltakSRP__Academic_Start_Date__r.Academic_Term_Master__r.Term_Start_Date__c  from DeltakSRP__Course_Enrollments__r) from Contact where Id in: contactids];
		 
		 List<Contact> contactsToUpdate = new List<Contact>();
		 
		 List<Academic_Term_Master__c> astmList = [Select id, Previous_Term__c, Term_Label__c, Term_Start_Date__c from Academic_Term_Master__c order by Term_Start_Date__c asc];
		 
		 for(Contact c: contacts){
		 	Integer numTermsOut;
		 	Contact con = (inputMap != null && inputMap.containsKey(c.id) ? inputMap.get(c.id) : new Contact(Id=c.id)); 
		 	if(con.Number_of_Terms_Out__c == null)
		 		con.Number_of_Terms_Out__c = 10000000;
		 		
		 	Boolean TermsOutCalculated = false;
		 	for(DeltakSRP__Course_Enrollment__c ce: ceList){
		 		
		 		numTermsOut =0; 
		 		Date lastEnrollmentDate = c.last_Enrollment_date__c;
		 		Date currentEnrollmentDate = ce.DeltakSRP__Academic_Section__r.Start_Date__c;
		 		System.Debug('lastEnrollmentDate == '+lastEnrollmentDate);
		 		System.Debug('currentEnrollmentDate == '+currentEnrollmentDate);
		 		if(lastEnrollmentDate != null && currentEnrollmentDate >= lastEnrollmentDate){
		 			Boolean breakReady = false;
		 			for(Academic_Term_Master__c astm : astmList){
		 				System.Debug('astm.Term_Start_Date__c -- '+astm.Term_Start_Date__c);
		 				System.Debug('lastEnrollmentDate -- '+lastEnrollmentDate);
		 				System.Debug('currentEnrollmentDate -- '+currentEnrollmentDate);
		 				System.Debug('breakReady -- '+breakReady);
		 				System.Debug('numTermsOut -- '+numTermsOut);
		 				if(astm.Term_Start_Date__c >= lastEnrollmentDate){
		 					numTermsOut++;
		 					breakReady = true;
		 				}
		 				if(breakReady && astm.Term_Start_Date__c < currentEnrollmentDate){
		 					break;
		 				}
		 			}
		 		}
		 		System.Debug('con.Number_of_Terms_Out__c -- '+con.Number_of_Terms_Out__c);
		 		System.Debug('numTermsOut -- '+numTermsOut);
		 		if(con.Number_of_Terms_Out__c > numTermsOut){
		 			con.Number_of_Terms_Out__c = numTermsOut;
		 			TermsOutCalculated = true;
		 		}	
		 	
		 	}
		 	
		 	Boolean lastEnrollmentDate_calculated = false;
		 	for(DeltakSRP__Course_Enrollment__c ce: c.DeltakSRP__Course_Enrollments__r){
		 		
		 		
		 		
		 		
		 		if(con.last_Enrollment_date__c == null || con.last_Enrollment_date__c < ce.DeltakSRP__Academic_Section__r.Start_Date__c){
		 			con.last_Enrollment_date__c  = ce.DeltakSRP__Academic_Section__r.Start_Date__c; 
		 			lastEnrollmentDate_calculated = true;
		 		}
		 		
		 		
		 		
		 		
		 		
		 		
		 	}
		 	System.Debug('TermsOutCalculated -- '+TermsOutCalculated);
		 	System.Debug('lastEnrollmentDate_calculated -- '+lastEnrollmentDate_calculated);
		 	System.Debug('contactsToUpdate -- '+contactsToUpdate);
		 	if(TermsOutCalculated == true || lastEnrollmentDate_calculated == true)
		 		contactsToUpdate.add(con);
		 	else{
		 		con.Number_of_Terms_Out__c = null;
		 		contactstoUpdate.add(con);
		 	}
		 		
		 }
		 System.Debug('contactsToUpdate -- '+contactsToUpdate);
		  return fetchReturnMap(contactsToUpdate);
		/*if(contactsToUpdate.size()>0)
		 	update contactsToUpdate;*/
		 
	}
	
	
	public static Map<Id, Contact> updateCourseCompletePercentageOnContact(List<DeltakSRP__Course_Enrollment__c> courseEnrolls, Map<Id, Contact> inputMap){
		 
		 List<Id> contactids = new List<Id>();
		 
		 for(DeltakSRP__Course_Enrollment__c ce: courseEnrolls){
		 		contactids.add(ce.DeltakSRP__Enrolled_Student__c);
		 }
		 
		 List<DeltakSRP__Curriculum_Plan__c> cplans = [Select ID, DeltakSRP__Student__c, (Select Id, DeltakSRP__Course_Enrollment__c, DeltakSRP__Enrollment_Status__c, DeltakSRP__Course_Enrollment__r.DeltakSRP__Status__c from DeltakSRP__Curriculum_Plan_Entries__r) from DeltakSRP__Curriculum_Plan__c 
		 			where DeltakSRP__Student__c in: contactids and DeltakSRP__active__c = true LIMIT 1];
		 
		 system.debug('cplans.size()>>>>'+cplans.size());
		 List<Contact> contactsToUpdate = new List<Contact>();
		 for(DeltakSRP__Curriculum_Plan__c cp: cplans){
		 	Double numerator=0, denominator=0;
		 	if(cp.deltakSRP__Student__c != null){
			 	for(DeltakSRP__Curriculum_Plan_Entry__c cpe: cp.DeltakSRP__Curriculum_Plan_Entries__r){
			 		
			 		denominator++;
			 		system.debug('cpe.DeltakSRP__Enrollment_Status__c>>>>'+cpe.DeltakSRP__Enrollment_Status__c);
			 		if(cpe.DeltakSRP__Enrollment_Status__c == 'Complete'){
			 			numerator++;
			 		}
			 	}
		 	}
		 	system.debug('denominator>>>>'+denominator);
		 	system.debug('numerator>>>>'+numerator);
		 	if(denominator>0){
		 		double percentComplete;
		 		percentComplete = (numerator*100)/denominator; 
		 		system.debug('percentComplete>>>>'+percentComplete);
			 	Contact c = (inputMap != null && inputMap.containsKey(cp.deltakSRP__Student__c) ? inputMap.get(cp.deltakSRP__Student__c) : new Contact(id=cp.deltakSRP__Student__c));
			 	c.Percentage_of_Courses_Completed__c = percentComplete;
			 	system.debug('c.Percentage_of_Courses_Completed__c>>>>'+c.Percentage_of_Courses_Completed__c);
			 	contactstoUpdate.add(c);
		 	}else{
		 		Contact c = (inputMap != null && inputMap.containsKey(cp.deltakSRP__Student__c) ? inputMap.get(cp.deltakSRP__Student__c) : new Contact(id=cp.deltakSRP__Student__c));
		 		c.Percentage_of_Courses_Completed__c = 0;
			 	contactstoUpdate.add(c);
		 	} 	
		 } 			
		 
		 system.debug('contactsToUpdate.size()>>>>'+contactsToUpdate.size());
		 return fetchReturnMap(contactsToUpdate);
		/* if(contactsToUpdate.size() >0)
		 	update contactsToUpdate;*/
	}
    public static Map<Id, Contact> fetchReturnMap(List<Contact> contactList){
    	
    	Map<Id, Contact> returnMap = new Map<Id, Contact>();
    	if(contactList != null && contactList.size() > 0){
	    	for(Contact c:contactList){
	    		returnMap.put(c.Id, c);
	    	}
    	}
    return returnMap;
    }
    public static void updateContacts(Map<id, Contact> inputMap){
    	System.Debug('inputMap -- '+inputMap);
    	if(inputMap != null && inputMap.size() > 0){
    		try{
    			Database.update(inputMap.values(), false);
    		}catch(Exception e){
    			System.Debug(e);
    		}
    	}
    }
  public static void updateNumberOfTermsOutOnContact_Schedule(List<DeltakSRP__Course_Enrollment__c> celist){
    	Map<Id, Contact> inputMap = null; 
		List<Id> contactids = new List<Id>();
		List<Id> programids = new List<Id>(); 		
		for(DeltakSRP__Course_Enrollment__c ce: celist){
		 		if(ce.DeltakSRP__Academic_Section__c != null)
		 			contactids.add(ce.DeltakSRP__Enrolled_Student__c);
		 			
		 		programIds.add(ce.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c);	
		}	
		
		system.debug('programIds>>>>'+programids); 
		List<DeltakSRP__Academic_Program__c> programs = [Select Id, (Select Id, Academic_Term_Master__c, Academic_Term_Master__r.Term_Start_Date__c  from DeltakSRP__Academic_Start_Dates__r where DeltakSRP__Start_Date__c <= :system.today() ORDER BY DeltakSRP__Start_Date__c DESC) from DeltakSRP__Academic_Program__c where id in: programids];
		 
		Map<Id, DeltakSRP__Academic_Program__c> pmap= new Map<Id, DeltakSRP__Academic_Program__c>();
		 
		 for(DeltakSRP__Academic_Program__c p: programs){
		 	pmap.put(p.id, p);	
		 }	
		 
		 List<Contact> contacts = [Select Id, Number_of_Terms_Out__c, (Select Id, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Section__r.Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c, DeltakSRP__Academic_Start_Date__r.Academic_Term_Master__c, DeltakSRP__Academic_Start_Date__r.Academic_Term_Master__r.Term_Start_Date__c  from DeltakSRP__Course_Enrollments__r) from Contact where Id in: contactids];
		 
		 List<Contact> contactsToUpdate = new List<Contact>();
		 
		 List<Academic_Term_Master__c> astmList = [Select id, Previous_Term__c, Term_Label__c, Term_Start_Date__c from Academic_Term_Master__c order by Term_Start_Date__c asc];
		 
		 for(Contact c: contacts){
		 	Integer numTermsOut;
		 	Contact con = (inputMap != null && inputMap.containsKey(c.id) ? inputMap.get(c.id) : new Contact(Id=c.id)); 
		 	if(con.Number_of_Terms_Out__c == null)
		 		con.Number_of_Terms_Out__c = 10000000;
		 		
		 	Boolean TermsOutCalculated = false;
		 	
		 	for(DeltakSRP__Course_Enrollment__c ce: c.DeltakSRP__Course_Enrollments__r){
		 		numTermsOut =0; 
		 		Date lastEnrollmentDate = con.last_Enrollment_date__c;
		 		Date currentEnrollmentDate = ce.DeltakSRP__Academic_Section__r.Start_Date__c;
		 		if(lastEnrollmentDate != null){
		 			Boolean breakReady = false;
		 			for(Academic_Term_Master__c astm : astmList){
		 				if(astm.Term_Start_Date__c >= lastEnrollmentDate){
		 					numTermsOut++;
		 					breakReady = true;
		 				}
		 				if(breakReady && astm.Term_Start_Date__c < currentEnrollmentDate){
		 					break;
		 				}
		 			}
		 		
		 		}
		 		
		 		
		 		
		 		if(con.last_Enrollment_date__c == null || con.last_Enrollment_date__c < ce.DeltakSRP__Academic_Section__r.Start_Date__c){
		 			con.last_Enrollment_date__c  = ce.DeltakSRP__Academic_Section__r.Start_Date__c; 
		 		}
		 		
		 		
		 		
		 		if(con.Number_of_Terms_Out__c > numTermsOut){
		 			con.Number_of_Terms_Out__c = numTermsOut;
		 			TermsOutCalculated = true;
		 		}	
		 		
		 		
		 	}
		 	
		 	if(TermsOutCalculated == true)
		 		contactsToUpdate.add(con);
		 	else{
		 		con.Number_of_Terms_Out__c = null;
		 		contactstoUpdate.add(con);
		 	}
		 		
		 }
		  //return fetchReturnMap(contactsToUpdate);
		if(contactsToUpdate.size()>0)
		 	Database.update(contactsToUpdate, false);
    }  
    
}