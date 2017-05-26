public with sharing class RosterReport {
    transient set<id> progEnrollments = new set<id>();
    transient list<DeltakSRP__Course_Enrollment__c> ce = new list<DeltakSRP__Course_Enrollment__c>();
    transient list<studentBean> sb = new list<studentBean>();
    public list<studentBean> getSb(){
    	return sb; 
    }
    
    transient list<DeltakSRP__Enrollment_History__c> eh = new list<DeltakSRP__Enrollment_History__c>();
   
    transient list<termBean> tbList = new list<termBean>();
      public list<termBean> gettbList(){
    	return tbList; 
    }
    
    transient list<statusBean> sbList = new list<statusBean>();
    public list<statusBean> getSbList(){
    	return sblist;
    }
    transient list<string> selectedTerms = new list<string>();
    transient list<string> selectedPrograms = new list<string>();
    transient list<string> selectedAccounts = new list<string>();
    public list<DeltakSRP__Course_Enrollment__c> termsQuery = new list<DeltakSRP__Course_Enrollment__c>();
    public boolean reportGenerated;
    
    public void setCe(List<DeltakSRP__Course_Enrollment__c> c)
    {
    	ce = c;
    }
    
     public list<DeltakSRP__Course_Enrollment__c> getCe()
    {
    	return ce;
    }
     
    public void RosterReport(){
    	reportGenerated = false;
        termsQuery = [SELECT DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c, 
        					DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name, 
        					DeltakSRP__Enrolled_Student__r.Account.Name 
        					FROM DeltakSRP__Course_Enrollment__c
        					WHERE DeltakSRP__Program_Enrollment__c != NULL 
        					AND DeltakSRP__Academic_Start_Date__c != NULL 
        					ORDER BY DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c];
        					
       System.debug('termsQuery->'+termsQuery); 					
    } 
    
    public pageReference go(){
    	
    	progEnrollments = new set<id>();
    	
    	if(selectedTerms.size() > 3){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You can only select 3 terms at a time!'));
    	}
    	if(selectedPrograms.size() == 0){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You must select a program!'));
    	}
    	if(selectedAccounts.size() == 0){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You must select an account!'));
    	}
    	if(apexPages.hasMessages()){
    		return null;
    	}
    	if(selectedTerms.size() > 0 && selectedPrograms.size() > 0){
    		ce = [SELECT Id, DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name, 
    		DeltakSRP__Enrolled_Student__r.DeltakSRP__No_Enrollment_Confirm__c, 
    		DeltakSRP__Program_Enrollment__c, 
    		DeltakSRP__Program_Enrollment__r.DeltakSRP__Student_Services_Coordinator__r.Name, 
    		DeltakSRP__LastNameFirstName__c, 
    		DeltakSRP__Course_Abbreviation__c, 
    		DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c, 
    		DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Student_Services_Coordinator__r.Name, 
    		DeltakSRP__Program_Term_Start__c, 
    		DeltakSRP__Course_Units__c, 
    		DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Deltak_Student__c, 
    		DeltakSRP__Status__c, 
    		DeltakSRP__Enrolled_Student__r.DeltakSRP__Transfer__c 
    		FROM DeltakSRP__Course_Enrollment__c 
    		WHERE DeltakSRP__Program_Enrollment__c != NULL AND DeltakSRP__Academic_Start_Date__c != NULL 
    		AND DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c IN :selectedTerms AND 
    		DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name IN :selectedPrograms AND 
    		DeltakSRP__Enrolled_Student__r.Account.Name IN :selectedAccounts ORDER BY 
    		DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c];
    		//limit 500];
    	}
 	 	set<string> terms = new set<string>();
        for(DeltakSRP__Course_Enrollment__c item : ce){
            progEnrollments.add(item.DeltakSRP__Program_Enrollment__c);
        }
        eh = [SELECT DeltakSRP__Program_Enrollment__c , DeltakSRP__Status__c, Id, DeltakSRP__Term_Label__c 
        FROM DeltakSRP__Enrollment_History__c WHERE DeltakSRP__Program_Enrollment__c IN :progEnrollments];
        sbList = getStatusBeanList();
        reportGenerated = true;
        return null;
    }
    
    public boolean getReportGenerated(){
    	return reportGenerated;
    }
    
    public void setReportGenerated(){
    	reportGenerated = this.reportGenerated;
    }
    
    public list<SelectOption> getTerms() {
 	 	list<SelectOption> options = new list<SelectOption>();
 	 	set<string> terms = new set<string>();
 	 	for(DeltakSRP__Course_Enrollment__c item : termsQuery){
 	 		if(!terms.contains(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c) && item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c != null){
 	 			options.add(new SelectOption(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c,item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c));
 	 			terms.add(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c);
 	 		}
 	 	}
 	 	return options;
  	}
  	
  	public String[] getSelectedTerms() {
        return selectedTerms;
    }
        
    public void setSelectedTerms(String[] selectedTerms) {
        this.selectedTerms = selectedTerms;
    }
    
    public list<SelectOption> getPrograms() {
 	 	list<SelectOption> options = new list<SelectOption>();
 	 	set<string> programs = new set<string>();
 	 	for(DeltakSRP__Course_Enrollment__c item : termsQuery){
 	 		if(!programs.contains(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name)){
 	 			options.add(new SelectOption(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name,item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name));
 	 			programs.add(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Academic_Program__r.Name);
 	 		}
 	 	}
 	 	return options;
  	}
  	
  	public String[] getSelectedPrograms() {
        return selectedPrograms;
    }
        
    public void setSelectedPrograms(String[] selectedPrograms) {
        this.selectedPrograms = selectedPrograms;
    }
    
    public list<SelectOption> getAccounts() {
 	 	list<SelectOption> options = new list<SelectOption>();
 	 	set<string> accounts = new set<string>();
 	 	for(DeltakSRP__Course_Enrollment__c item : termsQuery){
 	 		if(!accounts.contains(item.DeltakSRP__Enrolled_Student__r.Account.Name)){
 	 			options.add(new SelectOption(item.DeltakSRP__Enrolled_Student__r.Account.Name,item.DeltakSRP__Enrolled_Student__r.Account.Name));
 	 			accounts.add(item.DeltakSRP__Enrolled_Student__r.Account.Name);
 	 		}
 	 	}
 	 	return options;
  	}
  	
  	public String[] getSelectedAccounts() {
        return selectedAccounts;
    }
        
    public void setSelectedAccounts(String[] selectedAccounts) {
        this.selectedAccounts = selectedAccounts;
    }
    
    public list<statusBean> getStatusBeanList(){
    	list<statusBean> statusBeanList = new list<statusBean>();
    	for(DeltakSRP__Course_Enrollment__c item : ce){
        	statusBean status = new statusBean();
        	status.studentName = item.DeltakSRP__LastNameFirstName__c;
            status.programStart = string.ValueOf(item.DeltakSRP__Program_Term_Start__c);
            status.advisor = item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Student_Services_Coordinator__r.Name;
            status.termName = item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c;
            status.courseName = item.DeltakSRP__Course_Abbreviation__c;
            status.deltakStudent = item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Deltak_Student__c;
            status.courseEnrollmentStatus = item.DeltakSRP__Status__c;
            status.noEnrollmentConfirmDate = item.DeltakSRP__Enrolled_Student__r.DeltakSRP__No_Enrollment_Confirm__c;
            for(DeltakSRP__Enrollment_History__c enrollHist : eh){
            	if(item.DeltakSRP__Program_Enrollment__c == enrollHist.DeltakSRP__Program_Enrollment__c){
            		if(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c == enrollHist.DeltakSRP__Term_Label__c){
            			status.status = enrollHist.DeltakSRP__Status__c;
            		}
            	}
            }
            if(item.DeltakSRP__Enrolled_Student__r.DeltakSRP__Transfer__c == true){
            	status.Transfer = true;
            }
            statusBeanList.add(status);
    	}
    	return statusBeanList;
    }
    
    public list<studentBean> getStudentBeans(){
    	map<string,studentBean> sbMap = new map<string,studentBean>();
    	sb = new list<studentBean>();
    	for(DeltakSRP__Course_Enrollment__c item : ce){
    		studentBean bean = new studentBean();
            if(sbMap.get(item.DeltakSRP__LastNameFirstName__c) == null){
                bean.studentName = item.DeltakSRP__LastNameFirstName__c;
                bean.programStart = string.ValueOf(item.DeltakSRP__Program_Term_Start__c);
                bean.advisor = item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Student_Services_Coordinator__r.Name;
                bean.noEnrollmentConfirmDate = item.DeltakSRP__Enrolled_Student__r.DeltakSRP__No_Enrollment_Confirm__c;
                bean.graduate = false;
            }else{
                bean = sbMap.get(item.DeltakSRP__LastNameFirstName__c);
            }
            if(sbMap.get(item.DeltakSRP__LastNameFirstName__c) == null){
            	bean.courseStatuses = new list<courseStatusBean>();
                sb.add(bean);
            }
            sbMap.put(bean.studentName,bean);
        }
		
		boolean dropFlg=false;
		for(studentBean sBean : sb){
	        for(termBean tb : tbList){
	        	boolean foundForTerm = false;
	        	if(foundForTerm == true){
	        		continue;
	        	}
		    	for(courseBean cb : tb.course){
					for(statusBean statBean : sbList){
						if(statBean.studentName == sBean.studentName){
		        			if(statBean.termName == tb.term){
		        				if(foundForTerm == false){
		        					if(statBean.status == 'New'){
			        					if(statBean.deltakStudent == true){
		        							tb.totalNew++;
			        					}else{
											tb.totalNewNonDeltak++;
			        					}
			        					foundForTerm = true;
			        				}
			        				if(statBean.status == 'Return'){
		        						if(statBean.deltakStudent == true){
		        							tb.totalReturning++;
		        						}else{
		        							tb.totalReturningNonDeltak++;
		        						}
		        						foundForTerm = true;
		        					}
		        					if(statBean.status == 'Re-enter'){
		        						tb.totalReEnter++;
		        						foundForTerm = true;
		        					}
		        					if(statBean.transfer == true){
		        						tb.totalTransfer++;
		        						foundForTerm = true;
		        					}
		        					if(statBean.status == 'Drop'){
		        						if(statBean.deltakStudent == true){
		        							tb.totalDrop++;
		        						}else{
		        							tb.totalDropNonDeltak++;
		        						}
		        						foundForTerm = true;
		        					}
		        					if(statBean.status == 'Graduate'){
		        						sbean.graduate = true;
		        						if(statBean.deltakStudent == true){
		        							tb.totalGrads++;
		        						}else{
		        							tb.totalGradsNonDeltak++;
		        						}
		        						foundForTerm = true;
		        					}
		        					if(statBean.status != 'Drop'){
			        					if(statBean.deltakStudent == true){
			        						tb.totalActiveDeltakStudents++;
			        					}else{
			        						tb.totalActiveNonDeltakStudents++;
			        					}
		        					}
		        					tb.totalStudents++;
		        					foundForTerm = true;
		        				}
		        				
		        			}
						}
					}
	    		}
	    	}
        }
        map<string,boolean> name2curDrpFlg = new map<string,boolean>();
	    for(termBean tb : tbList){
	    	for(courseBean cb : tb.course){
	    		tb.totalNonDeltakCredits = tb.totalNonDeltakCredits + cb.totalNonDeltakCredits;
	    		tb.totalCredits = tb.totalCredits + cb.totalCredits;
	    		for(studentBean sBean : sb){
		    		boolean found=false;
		    		courseStatusBean csBean = new courseStatusBean();
		    		if(name2curDrpFlg.get(sBean.studentName) == null){
		    			dropFlg = false;
		    		}else{
		    			dropFlg = name2curDrpFlg.get(sBean.studentName);
		    		}
					for(statusBean statBean : sbList){
						if(statBean.studentName == sBean.studentName){
		        			if(statBean.termName == tb.term){
		        				if(statBean.courseName == cb.course){
		        					if(statBean.courseEnrollmentStatus != 'Withdrawal' && statBean.courseEnrollmentStatus != 'Drop'){
		        						tb.totalEnroll++;
		        						if(statBean.deltakStudent == true){
		        							tb.totalCourseEnrollments++;
		        						}else{
		        							tb.totalEnrollNonDeltak++;
		        						}
		        					}
		        					if(statBean.status == 'Drop'){
		        						sBean.dropFlag = true;
		        						dropFlg=true;
		        					}
		        					if(statBean.status == 'Re-enter'){
		        						dropFlg=false;
		        					}
		        					csBean.dropFlag=dropFlg;
		        					if(statBean.courseEnrollmentStatus == 'Drop' || statBean.courseEnrollmentStatus == 'Withdrawal' || statBean.courseEnrollmentStatus == 'Failed'){
		        						csBean.courseStatus=statBean.status+' - '+statBean.courseEnrollmentStatus;
		        						sbean.courseStatuses.add(csBean);
		        					}else{
		        						csBean.courseStatus=statBean.status;
		        						sBean.courseStatuses.add(csBean);
		        					}
		        					name2curDrpFlg.put(statBean.studentName,dropFlg);
		        					found=true;
		        				}
		            		}
		            	}
		            }
		            if(found==false){
		            	csBean.courseStatus=' ';
		            	csBean.dropFlag = dropFlg;
		            	sBean.courseStatuses.add(csBean);
		            }
				}
				if(tb.totalEnrollNonDeltak != 0){
					tb.avgCreditLoadNonDeltak = tb.totalNonDeltakCredits.divide(tb.totalEnrollNonDeltak,2);
				}else{
					tb.avgCreditLoadNonDeltak = 0.00;
				}
				if(tb.totalActiveDeltakStudents != 0){
					tb.avgCreditLoadDeltak = tb.totalCredits.divide(tb.totalActiveDeltakStudents,2);
				}else{
					tb.avgCreditLoadDeltak = 0.00;
				}
            }
        }
        sb.sort();
        return sb;
    }
    
    public list<termBean> getTermBeanList(){
        map<termBean,set<string>> term2courses = new map<termBean,set<string>>();
        map<string,termBean> terms = new map<string,termBean>();
        tbList = new list<termBean>();
        for(DeltakSRP__Course_Enrollment__c item : ce){
            termBean tb = new termBean();
            tb.totalNew = 0;
            tb.totalNewNonDeltak = 0;
            tb.totalReturning = 0;
            tb.totalReturningNonDeltak = 0;
            tb.totalReEnter = 0;
            tb.totalTransfer = 0;
            tb.totalDrop = 0;
            tb.totalDropNonDeltak = 0;
            tb.totalEnroll = 0;
            tb.totalEnrollNonDeltak = 0;
            tb.totalNonDeltakCredits = 0;
            tb.avgCreditLoadNonDeltak = 0;
            tb.totalCourseEnrollments = 0;
            tb.totalStudents = 0;
            tb.totalActiveDeltakStudents = 0;
            tb.totalCredits = 0;
            tb.avgCreditLoadDeltak = 0;
            tb.totalGrads = 0;
        	tb.totalGradsNonDeltak = 0;
        	tb.totalActiveStudentsNonDeltak = 0;
        	tb.totalDeltakCourseEnrollments = 0;
        	tb.totalActiveNonDeltakStudents = 0;
            courseBean cb = new courseBean();
            cb.totalEnrollments = 0;
            cb.totalCredits = 0;
            cb.totalNonDeltakCredits = 0;
            list<courseBean> cbList = new list<courseBean>();
            set<string> courseNames = new set<string>();
            if(terms.containsKey(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c) == false){
                tb.term = item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c;
                cb.course = item.DeltakSRP__Course_Abbreviation__c;
                cb.totalEnrollments++;
                if(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Deltak_Student__c){
                	if(item.DeltakSRP__Course_Units__c != null)
                		cb.totalCredits = cb.totalCredits + item.DeltakSRP__Course_Units__c;
                }else{
                	if(item.DeltakSRP__Course_Units__c != null)
                		cb.totalNonDeltakCredits = cb.totalNonDeltakCredits + item.DeltakSRP__Course_Units__c;
                }
                cbList.add(cb);
                tb.course = cbList;
                terms.put(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c,tb);
                tbList.add(tb);
                //tableWidth++;
            }else{
                tb = terms.get(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c);
                boolean cbFound = false;
                for(courseBean cBean : tb.course){
                    if(cBean.course == item.DeltakSRP__Course_Abbreviation__c){
                        cbFound = true;
                        cb = cBean;
                    }
                }
                if(cbFound){
                    cb.totalEnrollments++;
                    if(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Deltak_Student__c){
                    	if(item.DeltakSRP__Course_Units__c != null)
		            		cb.totalCredits = cb.totalCredits + item.DeltakSRP__Course_Units__c;
		            }else{
		            	if(item.DeltakSRP__Course_Units__c != null)
		            		cb.totalNonDeltakCredits = cb.totalNonDeltakCredits + item.DeltakSRP__Course_Units__c;
		            }
                }else{
                    cbList = tb.course;
                    cb.course = item.DeltakSRP__Course_Abbreviation__c;
                    cb.totalEnrollments++;
                    if(item.DeltakSRP__Program_Enrollment__r.DeltakSRP__Enrolled_Student__r.DeltakSRP__Deltak_Student__c){
                    	if(item.DeltakSRP__Course_Units__c != NULL)
	                		cb.totalCredits = cb.totalCredits + item.DeltakSRP__Course_Units__c;
	                }else{
	                	if(item.DeltakSRP__Course_Units__c != null)
	                		cb.totalNonDeltakCredits = cb.totalNonDeltakCredits + item.DeltakSRP__Course_Units__c;
	                }
                    cbList.add(cb);
                    tb.course = cbList;
                    terms.put(item.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Term_Label__c,tb);
                    //tableWidth++;
                }
            }
            
        }
        return tbList;
    }
    
    public class studentBean implements Comparable{
        public string studentName {get;set;}
        public string programStart {get;set;}
        public string advisor {get;set;}
        public string noEnrollmentConfirmDate {get;set;}
        public boolean graduate {get;set;}
        //public list<string> courseStatuses {get;set;}
        public list<courseStatusBean> courseStatuses {get;set;}
        public boolean dropFlag {get;set;}
        
        public Integer compareTo(Object compareTo) {
	        studentBean compareToStudentBean = (studentBean)compareTo;
	        Integer returnValue = 0;
	        return studentName.compareTo(compareToStudentBean.studentName);     
	    }
    }
    
    public class courseStatusBean{
    	transient string courseStatus ;
        public String getCourseStatus()
        {
        	return courseStatus;
        }
        
         public void setCourseStatus(String t)
        {
        	courseStatus = t;
        }
        
    	transient boolean dropFlag ;
        public boolean getDropFlag()
        {
        	return dropFlag;
        }
        
         public void setDropFlag(boolean t)
        {
        	dropFlag = t;
        }
    }
    
    public class statusBean{
    	transient string studentName ;
        public String getStudentName()
        {
        	return studentName;
        }
        
         public void setStudentName(String t)
        {
        	studentName = t;
        }
        
    	transient string programStart;
        public String getProgramStart()
        {
        	return programStart;
        }
        
         public void setProgramStart(String t)
        {
        	programStart = t;
        }
        
        transient string advisor ;
        public String getAdvisor()
        {
        	return advisor;
        }
        
         public void setAdvisor(String t)
        {
        	advisor = t;
        }
        
    	transient string termName;
        public String getTermName()
        {
        	return termName;
        }
        
         public void setTermName(String t)
        {
        	termName = t;
        }
        
    	transient string courseName;
        public String getCourseName()
        {
        	return courseName;
        }
        
         public void setCourseName(String t)
        {
        	courseName = t;
        }
        
    	transient string status ;
        public String getStatus()
        {
        	return status;
        }
        
         public void setStatus(String t)
        {
        	status = t;
        }
        
    	transient string noEnrollmentConfirmDate ;
        public String getNoEnrollmentConfirmDate()
        {
        	return noEnrollmentConfirmDate;
        }
        
         public void setNoEnrollmentConfirmDate(String t)
        {
        	noEnrollmentConfirmDate = t;
        }
        
    	transient boolean deltakStudent ;
        public boolean getDeltakStudent()
        {
        	return deltakStudent;
        }
        
         public void setDeltakStudent(boolean t)
        {
        	deltakStudent = t;
        }
        
    	transient string courseEnrollmentStatus ;
        public String getCourseEnrollmentStatus()
        {
        	return courseEnrollmentStatus;
        }
        
         public void setCourseEnrollmentStatus(String t)
        {
        	courseEnrollmentStatus = t;
        }
        
    	transient boolean transfer ;
        public boolean getTransfer()
        {
        	return transfer;
        }
        
         public void setTransfer(boolean t)
        {
        	transfer = t;
        }
        
    }
    
    public class termBean{
        transient string term;
        public String getTerm()
        {
        	return term;
        }
        
         public void setTerm(String t)
        {
        	term = t;
        }
        
        
        transient list<courseBean> course;
        
        public list<courseBean> getCourse()
        {
        	return course;
        }
        
         public void setCourse(list<courseBean> t)
        {
        	course = t;
        }
        
        transient decimal totalNew;
        public decimal getTotalNew()
        {
        	return totalNew;
        }
        
         public void setTotalNew(decimal t)
        {
        	totalNew = t;
        }
        
        transient decimal totalReturning;
        public decimal getTotalReturning()
        {
        	return totalReturning;
        }
        
         public void setTotalReturning(decimal t)
        {
        	totalReturning = t;
        }
        
        transient decimal totalNewNonDeltak;
        public decimal getTotalNewNonDeltak()
        {
        	return totalNewNonDeltak;
        }
        
         public void setTotalNewNonDeltak(decimal t)
        {
        	totalNewNonDeltak = t;
        }
        
        transient decimal totalReturningNonDeltak ;
        public decimal getTotalReturningNonDeltak()
        {
        	return totalReturningNonDeltak;
        }
        
         public void setTotalReturningNonDeltak(decimal t)
        {
        	totalReturningNonDeltak = t;
        }
        
        transient decimal totalReEnter;
        public decimal getTotalReEnter()
        {
        	return totalReEnter;
        }
        
         public void setTotalReEnter(decimal t)
        {
        	totalReEnter = t;
        }
        
        transient decimal totalTransfer;
        public decimal getTotalTransfer()
        {
        	return totalTransfer;
        }
        
         public void setTotalTransfer(decimal t)
        {
        	totalTransfer = t;
        }
        
        transient decimal totalDrop ;
        public decimal getTotalDrop()
        {
        	return totalDrop;
        }
        
         public void setTotalDrop(decimal t)
        {
        	totalDrop = t;
        }
        
        transient decimal totalDropNonDeltak;
        public decimal getTotalDropNonDeltak()
        {
        	return totalDropNonDeltak;
        }
        
         public void setTotalDropNonDeltak(decimal t)
        {
        	totalDropNonDeltak = t;
        }
        
        transient decimal totalEnroll ;
        public decimal getTotalEnroll()
        {
        	return totalEnroll;
        }
        
         public void setTotalEnroll(decimal t)
        {
        	totalEnroll = t;
        }
        
        transient decimal totalEnrollNonDeltak;
        public decimal getTotalEnrollNonDeltak()
        {
        	return totalEnrollNonDeltak;
        }
        
         public void setTotalEnrollNonDeltak(decimal t)
        {
        	totalEnrollNonDeltak = t;
        }
        
        transient decimal totalNonDeltakCredits;
        public decimal getTotalNonDeltakCredits()
        {
        	return totalNonDeltakCredits;
        }
        
         public void setTotalNonDeltakCredits(decimal t)
        {
        	totalNonDeltakCredits = t;
        }
        
        transient decimal avgCreditLoadNonDeltak;
        public decimal getAvgCreditLoadNonDeltak()
        {
        	return avgCreditLoadNonDeltak;
        }
        
         public void setAvgCreditLoadNonDeltak(decimal t)
        {
        	avgCreditLoadNonDeltak = t;
        }
        
        transient decimal totalReEnroll ;
        public decimal getTotalReEnroll()
        {
        	return totalReEnroll;
        }
        
         public void setTotalReEnroll(decimal t)
        {
        	totalReEnroll = t;
        }
        
        transient decimal totalCourseEnrollments;
        public decimal getTotalCourseEnrollments()
        {
        	return totalCourseEnrollments;
        }
        
         public void setTotalCourseEnrollments(decimal t)
        {
        	totalCourseEnrollments = t;
        }
        
        transient decimal totalStudents;
        public decimal getTotalStudents()
        {
        	return totalStudents;
        }
        
         public void setTotalStudents(decimal t)
        {
        	totalStudents = t;
        }
        
        transient decimal totalActiveDeltakStudents;
        public decimal getTotalActiveDeltakStudents()
        {
        	return totalActiveDeltakStudents;
        }
        
         public void setTotalActiveDeltakStudents(decimal t)
        {
        	totalActiveDeltakStudents = t;
        }
        
        transient decimal totalCredits;
        public decimal getTotalCredits()
        {
        	return totalCredits;
        }
        
         public void setTotalCredits(decimal t)
        {
        	totalCredits = t;
        }
        
        transient decimal avgCreditLoadDeltak;
        public decimal getAvgCreditLoadDeltak()
        {
        	return avgCreditLoadDeltak;
        }
        
         public void setAvgCreditLoadDeltak(decimal t)
        {
        	avgCreditLoadDeltak = t;
        }
        
        transient decimal totalGrads;
        public decimal getTotalGrads()
        {
        	return totalGrads;
        }
        
         public void setTotalGrads(decimal t)
        {
        	totalGrads = t;
        }
        
        transient decimal totalGradsNonDeltak;
        public decimal getTotalGradsNonDeltak()
        {
        	return totalGradsNonDeltak;
        }
        
         public void setTotalGradsNonDeltak(decimal t)
        {
        	totalGradsNonDeltak = t;
        }
        
        transient decimal totalActiveStudentsNonDeltak;
        public decimal getTotalActiveStudentsNonDeltak()
        {
        	return totalActiveStudentsNonDeltak;
        }
        
         public void setTotalActiveStudentsNonDeltak(decimal t)
        {
        	totalActiveStudentsNonDeltak = t;
        }
        
        transient decimal totalDeltakCourseEnrollments;
        public decimal getTotalDeltakCourseEnrollments()
        {
        	return totalDeltakCourseEnrollments;
        }
        
         public void setTotalDeltakCourseEnrollments(decimal t)
        {
        	totalDeltakCourseEnrollments = t;
        }
        
        transient decimal totalActiveNonDeltakStudents;
        public decimal getTotalActiveNonDeltakStudents()
        {
        	return totalActiveNonDeltakStudents;
        }
        
         public void setTotalActiveNonDeltakStudents(decimal t)
        {
        	totalActiveNonDeltakStudents = t;
        }
        
        
    }
    
    public class courseBean{
        transient string course ;
        public string getCourse()
        {
        	return course;
        }
        
         public void setCourse(string t)
        {
        	course = t;
        }
        
        transient integer totalEnrollments ;
        public integer getTotalEnrollments()
        {
        	return totalEnrollments;
        }
        
         public void setTotalEnrollments(integer t)
        {
        	totalEnrollments = t;
        }
        
        transient decimal totalCredits;
        public decimal getTotalCredits()
        {
        	return totalCredits;
        }
        
         public void setTotalCredits(decimal t)
        {
        	totalCredits = t;
        }
        
        transient decimal totalNonDeltakCredits;
        public decimal getTotalNonDeltakCredits()
        {
        	return totalNonDeltakCredits;
        }
        
         public void setTotalNonDeltakCredits(decimal t)
        {
        	totalNonDeltakCredits = t;
        }
        
    }
    
    

}