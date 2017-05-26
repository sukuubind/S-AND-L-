global without sharing class SRPUploadAttachmentForCampaigns {
	
     WebService static String parseAttachmentSheet(String uploadCampaignId){
        System.debug(uploadCampaignId);
        String message = '';
        List<Campain_Leads_Upload__c> campaignLeads = [Select Upload_Complete__c from Campain_Leads_Upload__c where Id = :uploadCampaignId.trim()];
        if(campaignLeads[0].Upload_Complete__c){
            message+= 'The upload is already complete. To upload again, delete the attachment and re-attach the file';
        }else{
            List <string> emailAddressList = NewInquiryUtil.getEmalAddresses();
            List<Attachment> attachmentList = [Select a.ParentId, 
                                                      a.LastModifiedDate, 
                                                      a.Body From Attachment a
                                                      where a.ParentId = :uploadCampaignId.trim()
                                                      order by a.LastModifiedDate desc limit 1
                                                ];
            List<Lead> leads = new List<Lead>(); 
            List<Opportunity> opportunities = new List<Opportunity>();
            List<Contact> contacts = new List<Contact>();
            Map<Lead, String> leadownermap = new Map<Lead, String>();
            
            List<String[]> inputFeed = new List<String[]>();
            Set<String> campignCodes = getAvailableCampaignCodes();
            Set<String> errorValues = new Set<String>();
            
            if(attachmentList == null || attachmentList.size() == 0){
                message+= 'No Attachments found';
            }else{
                Attachment toUseAttachment = attachmentList[0];
                Blob body = toUseAttachment.Body;
                system.debug('body.toString()>>>>'+body.toString());
                CSVReader reader = new CSVReader((body.toString()));
                system.debug('body.toString()>>>>'+body.toString());
                String[] line1 = null;
                Integer lineNumber = 0;
                Boolean error = false;
                while( (line1 = reader.readLine()) != null){
                	system.debug('inside while loop>>>>'+line1);
                    if(lineNumber == 0){
                        lineNumber++;
                        continue;
                    }
                    
                    String campaignCode = line1[3];
                    system.debug('campaignCode>>>>'+campaignCode);
                    
                    if(!campignCodes.contains(campaignCode)){
                        if(!errorValues.contains(campaignCode) || errorValues.size() == 0)
                            message+='Campaign Code ['+campaignCode+'] is not found in Deltak \n';
                        error = true;
                        errorValues.add(campaignCode);
                    }
                    if(!error)
                        inputFeed.add(line1);
                    
                }
                System.Debug('inputfeed>>>>'+inputFeed);
                 if(!error){
                 	
                 	RecordType rt = [Select Id from RecordType where Name= 'SRP Lead'];
                 	RecordType rt2 = [Select Id from RecordType where Name= 'SRP Opportunity'];
                 	
                 	List<String> CampaignCodes = new List<String>();
                 	Map<String, Campaign> CampaignCodeMap = new Map<String, Campaign>();
                 	for(String[] line : inputFeed){
	                 	List<Campaign> clist = new List<Campaign>();
			            CampaignCodes.add(line[3]);
                 	}    
                 	
                 	List<Campaign> clist = new List<Campaign>();
			        clist = [Select Id, Parent.Name, Campaign_Code__c from campaign where Campaign_Code__c in: CampaignCodes];
			        
			        for(Campaign c: clist){
			        	CampaignCodeMap.put(c.Campaign_code__c, c);
			        }   
			         
			         //List<SRPMassUploadDataWrapper> wraplist = new List<SRPMassUploadDataWrapper>();
			         Map<Opportunity,SRPMassUploadDataWrapper> OppWrapMap = new Map<Opportunity,SRPMassUploadDataWrapper>();
			         
			         Set<Id> userIds = new set<Id>();
			         for(String[] line : inputFeed){
			         	
			         	if(line.size()>21 && line[21] != null && line[21]!='' && line[21].length()>=15){
			         		system.debug('line[21]>>>>'+line[21]);
			         		userIds.add(line[21].trim());
			         	}else{
			         		userids.add(userinfo.getuserid());
			         	}	
			         }
			        
			         system.debug('userids>>>>'+userids);
			         List<User> owners = new List<User>();
			         owners = [Select Id from User where Id in:userids];
			         system.debug('owners>>>>'+owners);
			         		         
                     for(String[] line : inputFeed){
                     	String oid;
                     	if(line.size()>21 && line[21].length()>=15)
                     		oid = line[21];
                     	else
                     		oid = userinfo.getuserid();	
                     		
                        Campaign camp = Campaigncodemap.get(line[3]);
                        system.debug('camp.Parent.Name>>>>'+camp.Parent.Name);
                        system.debug('line[2]>>>>'+line[2]);
                        SRPMassUploadDataWrapper wrap = new SRPMassUploadDataWrapper(line[0], line[3], line[4], line[5],
                        	line[6], line[8], line [7], line[9], line[10], line[11] + ' '+ line[12], line[13], line[14],
                        	line[15], line[16], line[17], line[18], line[19], line[20], oid, line[2], null);
                        //wraplist.add(wrap);
                        if(camp.Parent.Name == 'Conference' && line[2] == 'Low'){
	                        Lead l = new Lead();
	                        l.recordTypeId = rt.Id;
	                        if(line[0]!=null && line[0]!='')
	                        	l.DeltakSRP__Is_SRP_Record__c = Boolean.valueof(line[0]);
	                        l.DeltakSRP__Inquiry_rating__c = line[2];
	                        l.RFI_Campaign_Code__c = line[3];
	                        l.Source__c = line[4]; 
	                        l.leadsource = line[5];
	                        l.DeltakSRP__Academic_Institution_Lookup__c = line[6];
	                        l.lastname = line[8];
	                        l.firstname = line[7];
	                        l.title = line [9];
	                        l.company = line[10];
	                        if(l.company == null || l.company=='')
	                        	l.company = 'No company specified during mass upload lead';
	                        l.street = line[11] + ' ' +line[12];
	                        l.city = line[13];
	                        l.state = line[14];
	                        l.country = line[15];
	                        l.postalcode = line[16];
	                        l.deltakSRP__home_phone__c = line[17];
	                        l.deltaksrp__work_phone__c = line[18];
	                        l.email = line[19];
	                        l.DeltakSRP__AcademicProgram__c = line[20];
	                        l.leadsource = 'Mass Upload';
	                        system.debug('oid>>>>'+oid); 
	                        
	                        if(oid != '' || oid!=null){
	                        	for(User u: owners){
	                        		if(u.id == oid.trim())
	                        			l.ownerid = u.Id;
	                        	}
	                        }
	                        system.debug('l.ownerid>>>>'+l.ownerid);
	                        
	                        leads.add(l);
	                        lineNumber++ ;
                        }else{
                        	Opportunity o = new Opportunity();
                        	o.Name = line[7]+' '+line[8];
                        	o.stageName = 'New Inquiry';
                        	o.closeDate = system.today();
                        	o.recordtypeid = rt2.id;
                        	o.campaignid = Campaigncodemap.get(line[3]).Id;
                        	o.DeltakSRP__Inquiry_Rating__c = line[2];
                        	o.DeltakSRP__Source__c = line[4];
                        	o.Leadsource = line[5];
                        	o.accountid = line[6];
                        	o.DeltakSRP__AcademicProgram__c = line[20];
                        	o.SRP_Retain_Ownership__c = false;
                        	o.leadsource = 'Mass Upload';
                        	if(oid != '' || oid!=null){
	                        	for(User u: owners){
	                        		if(u.id == oid.trim())
	                        			o.ownerid = u.Id;
	                        	}
	                        	o.SRP_Retain_Ownership__c = true;
	                        }
	                        system.debug('o.ownerid>>>>'+o.ownerid);
                        	system.debug('wrap>>>>'+wrap);
                        	opportunities.add(o); 
                        	oppwrapmap.put(o, wrap);
                        }   
                        
                        
	                }
                    try{
                    		
                		System.Debug('leads.size()>>>>'+leads.size());
                    	System.Debug('Opportunities.size()>>>>'+opportunities.size());
                    	String leadmessage = '';	
                    	Set<Id> leadsToDelete = new Set<Id>();
                    	if(leads.size() > 0){
                    	
                        	SRPMassUploadHandler.onBeforeInsert(Leads);
                        	insert leads;
                        	                        	
					        List<Lead> goodLeads = new List<Lead>();
					        for(Lead l : leads){
					            if(l.DeltakSRP__Is_Duplicate__c){
					                leadsToDelete.add(l.Id);
					            }else{
					                goodLeads.add(l);
					            }
					        }
					        List<CampaignMember> cmlist = new List<CampaignMember>();
					        clist = [Select Id from campaign where Name = : 'Bucket'];
					    	if(clist.size()>0){
						    	for(Lead l : leads){	
						    		for(contact c: contacts){
							    		CampaignMember cmember = new CampaignMember();
							            cmember.contactId = l.DeltakSRP__Contact__c;
							            cmember.CampaignID = clist[0].Id;
							            cmember.Status='Sent';
							            cmlist.add(cmember);
						    		}   
						    	}	 
					    	}
    	
					    	if(cmlist.size()>0)
					    		database.insert(cmlist, false);
					        
					        if(!leadsToDelete.isEmpty()){
					            delete [Select Id From Lead Where Id in :leadsToDelete];
					            leadmessage = + leadsToDelete.size() + ' lead(s) were duplicates and not uploaded.';
					        }
                        	
                    	}
                    	
                    	List<Opportunity> NonDuplicateOpportunities = new List<Opportunity>();
                        if(Opportunities.size()>0){ 
                        	NonDuplicateOpportunities = SRPMassUploadHandler.onBeforeInsert(opportunities,oppwrapmap);
                        	
                        	if(NonDuplicateOpportunities!= null && NonDuplicateOpportunities.size()>0){
                        		system.debug('NonDuplicateOpportunities.size>>>>'+NonDuplicateOpportunities.size());
                        		system.debug('NonDuplicateOpportunities>>>>'+NonDuplicateOpportunities);
	                        	insert NonDuplicateOpportunities; 
	                        	
	                        	system.debug('NonDuplicateOpportunities Id>>>>'+NonDuplicateOpportunities[0].Id);
	                        	
	                        	List<Id> nonDupOppIds = new List<Id>();
	                        	for(Opportunity o: NonDuplicateOpportunities){
	                        		nonDupOppIds.add(o.Id);
	                        	}
	                        	
	                        	NonDuplicateOpportunities = [Select o.DeltakSRP__Student__r.DeltakSRP__Person__c, o.webschedulerstatus__c, o.updateTPSFlag__c, o.of_courses_to_develop__c, o.n2de__Last_reassigned__c, o.n2de__Last_distributed__c, o.n2de__Is_reassigned__c, o.n2de__Is_distributed__c, o.cwschedappt__c, o.Yrs_Wrk_Exp__c, o.X9_Day__c, o.X90_days__c, o.X8_Day__c, o.X7_Day__c, o.X6_mos__c, o.X6_Day__c, o.X60_days__c, o.X5_Day__c, o.X4_Day__c, o.X3_Day__c, o.X30_days__c, o.X2_Day__c, o.X1_yr__c, o.X1_Day__c, o.X14_Day__c, o.X13_Day__c, o.X12_Day__c, o.X11_Day__c, o.X10_Day__c, o.Work_Phone__c, o.Why_Now__c, o.Weekly_Trend__c, o.Weekly_Goal__c, o.WebScheduler_Email__c, o.Wachman_Student__c, o.VOH_Date__c, o.VOH_Completed__c, o.Type_of_Law_Degree__c, o.Type, o.Tuition_rate_per_credit__c, o.Transferred_From_Opportunity__c, o.Total_credits__c, o.Total_Yrs_Wrk_Exp__c, o.Title__c, o.Time_to_Quality_Contact__c, o.Time_to_Initial_Attempt__c, o.Time_Zone__c, o.Term_Structure__c, o.SystemModstamp, o.Sub_Stage__c, o.Student__c, o.Student_Type__c, o.Student_Record_ID__c, o.Student_Last_Name__c, o.Student_ID__c, o.Student_First_Name__c, o.Student_Enrollment__c, o.Starts_per_year__c, o.Start_Date_of_Program__c, o.Start_Date__c, o.StageName, o.Specialization__c, o.Source__c, o.School_Newspaper__c, o.Same_Vendor__c, o.Same_Vendor_Count__c, o.STQC_Seconds__c, o.STIA_Seconds__c, o.SRP_Waived_Documents__c, o.SRP_Update_TPS_Flag__c, o.SRP_Transferred_from_Opportunity__c, o.SRP_Total_Yrs_Wrk_Exp__c, o.SRP_Title__c, o.SRP_TimeZone__c, o.SRP_Student_Record_ID__c, o.SRP_Student_Name__c, o.SRP_Student_Last_Name__c, o.SRP_Student_Id__c, o.SRP_Student_First_Name__c, o.SRP_Required_Documents__c, o.SRP_Referred_by_Opportunity__c, o.SRP_Recorded_Call__c, o.SRP_Reactivated_By_Name__c, o.SRP_QP_Sum__c, o.SRP_Program_Degree_Type__c, o.SRP_Program_Abbreviation__c, o.SRP_Prog_Spec_Abbrev__c, o.SRP_Preferred_Name__c, o.SRP_Pipeline_Start__c, o.SRP_Pipeline_Dormant__c, o.SRP_Pipeline_Dead__c, o.SRP_Pipeline_Contacted__c, o.SRP_Pipeline_Appointment__c, o.SRP_Pipeline_Applied__c, o.SRP_Person__c, o.SRP_Owner_Name__c, o.SRP_Owner_Email__c, o.SRP_Override_Documents__c, o.SRP_OK_To_text__c, o.SRP_No_Program_Admission_Documents__c, o.SRP_Manual_GPA_count__c, o.SRP_Mailing_Zip__c, o.SRP_Mailing_Street__c, o.SRP_Mailing_State__c, o.SRP_Mailing_Province__c, o.SRP_Mailing_Country__c, o.SRP_Mailing_City__c, o.SRP_Gender__c, o.SRP_GPA_Sum__c, o.SRP_GPA_Count__c, o.SRP_Fiscal_Calendar_Year__c, o.SRP_Fiscal_Calendar_Week__c, o.SRP_File_Approved_Check__c, o.SRP_Employment_Status__c, o.SRP_Employer_Company__c, o.SRP_Email_Opt_Out__c, o.SRP_Do_Not_Call__c, o.SRP_Days_Since_Booked_Application__c, o.SRP_Credits_Sum__c, o.SRP_Approved_Documents__c, o.SRP_Admissions_Phone__c, o.Roll_Counter__c, o.Required_Documents__c, o.Required_Documents_Received__c, o.Request_Status__c, o.Req_Docs_for_Validation__c, o.Referred_By_Student__c, o.Referred_By_Person__c, o.Referred_By_Opportunity__c, o.Referred_By_Contact__c, o.Recorded_Call__c, o.RecordTypeId, o.Reactivated_Date__c, o.Reactivated_By__c, o.Reactivated_By_Name__c, o.RFP__c, o.Quality_Contact__c, o.QP_Sum__c, o.Provisional_Reason__c, o.Projected_Program_Size__c, o.Programs__c, o.Program__c, o.Program_Structure__c, o.Program_Status__c, o.Program_Start_Dates__c, o.Program_Specialization__c, o.Program_Specialization_Abbreviation__c, o.Program_Link__c, o.Program_Interest__c, o.Program_Goal__c, o.Program_Degree_Type__c, o.Program_Abbrev__c, o.Probability, o.Pro_Forma_Sign_Off__c, o.Pro_Forma_Complete__c, o.Pricebook2Id, o.Preferred_Phone__c, o.Preferred_Name__c, o.Position_Title__c, o.Pipeline_Start__c, o.Pipeline_Dormant__c, o.Pipeline_Contacted__c, o.Pipeline_Appointment__c, o.Pipeline_Applied__c, o.Physical_Requirement__c, o.Person__c, o.Pending_Application_Stage_Date__c, o.Pending_Activity_Exists__c, o.Pending_Activity_Date__c, o.Payment_Type__c, o.Payment_Type_For_Books__c, o.Payback__c, o.Partner_Federal_School_Code__c, o.Parent_Organization_Name__c, o.OwnerId, o.Other_School__c, o.Other_Program__c, o.Other_Concerns__c, o.Original_Opportunity__c, o.Original_Created_Date__c, o.Original_Campaign__c, o.Online_EA_Sent__c, o.Online_Application_Stage__c, o.On_Ground_Only__c, o.Obstacles__c, o.OK_to_Text__c, o.Non_Revenue_Generating__c, o.Non_Matriculated__c, o.No_Program_Identified__c, o.NoContact__c, o.NextStep, o.Name, o.NSO_Scheduled__c, o.NSO_Location__c, o.NSO_Date__c, o.NSO_Completed__c, o.NA3_Id__c, o.Motivation__c, o.Modality__c, o.Mobile_Phone__c, o.Max_Investment__c, o.Marketing_Kick_Off_Date__c, o.Marketing_Goal__c, o.Manual_GPA_Count__c, o.Mailing_Zip__c, o.Mailing_Street__c, o.Mailing_State__c, o.Mailing_Province__c, o.Mailing_Country__c, o.Mailing_City__c, o.Lucky_Customer__c, o.Lock_Yrs_Wrk_Exp__c, o.Lock_GPA__c, o.Lead_to_App__c, o.LeadSource, o.Launch_Date__c, o.Last_File_Update__c, o.Last_Contact__c, o.Last_Attempt__c, o.LP_UTEXTPERM__c, o.LP_UREURL__c, o.LP_UREFRDBY__c, o.LP_UREFPROMOTION__c, o.LP_UREFMEDIATYPE__c, o.LP_UREFKEYWORD__c, o.LP_UOPTOUTCAM__c, o.LP_UOPTINDT__c, o.LP_UHSCODE__c, o.LP_UDescribe__c, o.LP_UCAMPUS__c, o.LP_UCAMPGNTYP__c, o.LP_UADGROUP__c, o.LP_UADCAMPAIGN__c, o.LP_Referral__c, o.LP_Program__c, o.LP_Program2__c, o.LP_OTHERCOLLEGES__c, o.LP_NOTES__c, o.LP_KEY1__c, o.LP_INTLEAD__c, o.LP_Filename__c, o.LP_Email__c, o.LP_Campaign__c, o.Job_Type__c, o.Is_Converted__c, o.IsWon, o.IsDeleted, o.IsDead__c, o.IsClosed, o.Interest_Timeframe__c, o.Inquiry_Rating__c, o.Initiated_By__c, o.Initial_Start_Date__c, o.Initial_Contact__c, o.Id, o.IM_Username__c, o.IM_Type__c, o.IMS_ID__c, o.How_Heard__c, o.How_Heard_Detail__c, o.Home_Phone__c, o.Highest_Degree_Earned__c, o.HasOpportunityLineItem, o.Goldmine_CreateDate__c, o.Goldmine_AccountNo__c, o.Gender__c, o.GPA__c, o.GPA_Sum__c, o.GPA_Count__c, o.GM_Sales_Stage__c, o.GM_Migration__c, o.GMId__c, o.ForecastCategoryName, o.ForecastCategory, o.Flag_for_Concern__c, o.Flag_for_Concern_Reason__c, o.Fiscal_Period_Start__c, o.Fiscal_Period_End__c, o.Fiscal_Calendar__c, o.Fiscal_Calendar_Year__c, o.Fiscal_Calendar_Week__c, o.Fiscal_Calendar_Period__c, o.FiscalYear, o.FiscalQuarter, o.Fiscal, o.File_Complete__c, o.File_Complete_Check__c, o.Fax__c, o.ExpectedRevenue, o.Exceptions__c, o.Enrollment_Coordinator__c, o.Employment_Status__c, o.Employer_Company__c, o.Email_from_Student__c, o.Email__c, o.Email_Opt_Out__c, o.Duplicate_Number__c, o.Drop_Denied_Reason__c, o.Documents__c, o.Do_Not_Call__c, o.Discount__c, o.Discount_Type__c, o.Description, o.Describe_other_curriculum_structure__c, o.Deltak_Revenue_Share__c, o.Deltak_Provided_Course_Dev__c, o.Deltak_Provided_CMS__c, o.Deltak_Corp_Stage__c, o.DeltakSRP__webschedulerstatus__c, o.DeltakSRP__cwschedappt__c, o.DeltakSRP__Years_Work_Experience__c, o.DeltakSRP__Work_Phone__c, o.DeltakSRP__Why_Now__c, o.DeltakSRP__WebScheduler_Email__c, o.DeltakSRP__Time_to_Quality_Contact__c, o.DeltakSRP__Time_to_Initial_Attempt__c, o.DeltakSRP__Synchronize__c, o.DeltakSRP__Sub_Stage__c, o.DeltakSRP__Student__c, o.DeltakSRP__Student_School_Fit_Score__c, o.DeltakSRP__Student_Name__c, o.DeltakSRP__Start_Date__c, o.DeltakSRP__Source__c, o.DeltakSRP__STQC_Seconds__c, o.DeltakSRP__STIA_Seconds__c, o.DeltakSRP__Roll_Counter__c, o.DeltakSRP__Required_Documents__c, o.DeltakSRP__Required_Documents_Received__c, o.DeltakSRP__Req_Docs_for_Validation__c, o.DeltakSRP__Referred_By__c, o.DeltakSRP__Reactivated_Date__c, o.DeltakSRP__Reactivated_By__c, o.DeltakSRP__Quality_Contact__c, o.DeltakSRP__Provisional__c, o.DeltakSRP__Provisional_Reason__c, o.DeltakSRP__Primary_Concern_Reason__c, o.DeltakSRP__Preferred_Phone__c, o.DeltakSRP__Pending_Activity_Exists__c, o.DeltakSRP__Pending_Activity_Date__c, o.DeltakSRP__Payment_Type_for_Books__c, o.DeltakSRP__Payment_Type__c, o.DeltakSRP__Other_Program_Information__c, o.DeltakSRP__Other_Concerns__c, o.DeltakSRP__OrderNumber__c, o.DeltakSRP__Obstacles__c, o.DeltakSRP__OK_To_Delete__c, o.DeltakSRP__Non_Matriculated__c, o.DeltakSRP__Motivation__c, o.DeltakSRP__Modality__c, o.DeltakSRP__Mobile_Phone__c, o.DeltakSRP__Lead_to_App__c, o.DeltakSRP__Lead_Time_to_Initial_Attempt__c, o.DeltakSRP__Lead_Source_ID__c, o.DeltakSRP__Last_File_Update__c, o.DeltakSRP__Last_Contact__c, o.DeltakSRP__Last_Attempt__c, o.DeltakSRP__LP_UREURL__c, o.DeltakSRP__LP_UREF_MEDIATYPE__c, o.DeltakSRP__LP_UREFPROMOTION__c, o.DeltakSRP__LP_UREFKEYWORD__c, o.DeltakSRP__LP_UADGROUP__c, o.DeltakSRP__LP_UADCAMPAIGN__c, o.DeltakSRP__LP_Campaign__c, o.DeltakSRP__Interest_Timeframe__c, o.DeltakSRP__Inquiry_Rating__c, o.DeltakSRP__Initial_Start_Date__c, o.DeltakSRP__Initial_Attempt__c, o.DeltakSRP__How_Heard__c, o.DeltakSRP__Home_Phone__c, o.DeltakSRP__GPA__c, o.DeltakSRP__Forecasted_Tuition__c, o.DeltakSRP__Flag_for_Concern__c, o.DeltakSRP__Fiscal_Calendar__c, o.DeltakSRP__Fiscal_Calendar_Period__c, o.DeltakSRP__Financial_Qualification_Score__c, o.DeltakSRP__Financial_Plan__c, o.DeltakSRP__File_Complete__c, o.DeltakSRP__File_Complete_Check__c, o.DeltakSRP__External_Id__c, o.DeltakSRP__Event__c, o.DeltakSRP__Email_from_Student__c, o.DeltakSRP__Email__c, o.DeltakSRP__Drop_Denied_Reason__c, o.DeltakSRP__Discount__c, o.DeltakSRP__Discount_Value__c, o.DeltakSRP__Discount_Type__c, o.DeltakSRP__Days_Until_Start__c, o.DeltakSRP__Days_To_File_Complete__c, o.DeltakSRP__Days_Since_Last_Contact__c, o.DeltakSRP__Days_Since_Last_Attempt__c, o.DeltakSRP__Days_Since_File_Update__c, o.DeltakSRP__Days_Since_Created__c, o.DeltakSRP__Date_Submitted__c, o.DeltakSRP__Date_Registered__c, o.DeltakSRP__Date_Booked__c, o.DeltakSRP__Date_Accepted__c, o.DeltakSRP__Conditional_Reason__c, o.DeltakSRP__Communication__c, o.DeltakSRP__Commitment_Level__c, o.DeltakSRP__Campus_Schedule_Code__c, o.DeltakSRP__Campaign_Name__c, o.DeltakSRP__Appointment_Completed__c, o.DeltakSRP__Anticipated_Start_Date__c, o.DeltakSRP__Active_Inquiry__c, o.DeltakSRP__Acceptance_Status__c, o.DeltakSRP__Academic_Start_Date__c, o.DeltakSRP__Academic_Specialization__c, o.DeltakSRP__Academic_Program__c, o.DeltakSRP__Academic_Institution_Id_from_Inquiry__c, o.DeltakSRP__AcademicProgram__c, o.DeltakSRP_How_Heard_Detail__c, o.DeltakSRPSMS__Student_Mobile_Phone__c, o.Degree_Subject_Matter__c, o.Degree_Level__c, o.Days_Until_Start__c, o.Days_To_File_Complete__c, o.Days_Since_Last_Contact__c, o.Days_Since_Last_Attempt__c, o.Days_Since_File_Update__c, o.Days_Since_Created__c, o.Days_Since_Booked_Application__c, o.Date_Transferred__c, o.Date_Submitted__c, o.Date_Registered__c, o.Date_Booked__c, o.Date_Accepted__c, o.Curriculum_Structure__c, o.Credits_Sum__c, o.Created_Date_Time__c, o.CreatedDate, o.CreatedById, o.Country_of_Citizenship__c, o.Corporate_Landing_Page_URL__c, o.Conditional_Reason__c, o.Concerns__c, o.Commitment_Level__c, o.College_or_School_at_Institution__c, o.CloseDate, o.Certificate_Matriculation__c, o.Campus_Schedule_Code__c, o.Campus_Program_Id__c, o.Campaign_Name__c, o.CampaignId, o.CMS_in_Use__c, o.Breakeven_Months__c, o.Birthdate__c, o.Best_Time_to_Contact__c, o.Benefits__c, o.Association_Membership_Name__c, o.Appointment_Completed__c, o.Anticipated_Start_Date__c, o.Amount, o.Admissions_Phone__c, o.Admissions_Manager__c, o.Admissions_Fax__c, o.Admission_Website__c, o.Additional_Notes__c, o.Active_Inquiry__c, o.AccountId, o.Acceptance_Status__c, o.Academic_program_formula__c, o.Academic_Start_Date__c, o.Academic_Services__c, o.Academic_Services_Start_Date__c From Opportunity o
	                        		where Id in: nonDupOppIds];
	                        	
	                        	SRPMassUploadHandler.onAfterInsert(NonDuplicateOpportunities);
                        	}	
                        	List<CampaignMember> cmlist = new List<CampaignMember>();
					    	if(clist.size()>0){
						    	for(Opportunity o : NonDuplicateOpportunities){	
						    		for(contact c: contacts){
						    			if(o.campaignId != null){
								    		CampaignMember cmember = new CampaignMember();
								            cmember.contactId = o.DeltakSRP__student__c;
								            cmember.CampaignID = o.campaignId;
								            cmember.Status='Sent';
								            cmlist.add(cmember);
						    			}    
						    		}   
						    	}	 
					    	}
    	
					    	if(cmlist.size()>0)
					    		database.insert(cmlist, false);
                        }
                        
                        Campain_Leads_Upload__c upload = new Campain_Leads_Upload__c(Id = uploadCampaignId.trim());
                        upload.Upload_Complete__c = true;
                        update upload;
                        system.debug('File successfully uploaded>>>>');
                        message += 'File successfully uploaded! ';
                        if(NonDuplicateOpportunities.size()<opportunities.size()){
                        	message += 'Some or All opportunities were duplicates.';
                        }else{
                        	message += 'There were no duplicate opportunities found. ';
                        }
                        
                        if(leadsTodelete.size() > 0){
                        	message += leadmessage;
                        }
                        system.debug('message>>>>'+message);
                    }catch(Exception e){
                        System.Debug(e);
                        message+= 'Error Occurred - '+e;
                    }
                }else{
                    message += 'Please correct the above errors.';
                }
            }
            }
        return message;
        
    }
    
    private static Set<String> getAvailableCampaignCodes(){
        
          Set<String> returnSet = new Set<String>();
         List<Campaign> campList = [Select id, Campaign_Code__c, IsActive
                                                from Campaign 
                                                where (Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < today 
                                                AND EndDate >= today
                                                And IsActive = true) 
                                                ];
        if(campList != null && campList.size() > 0){
            for(Campaign a : campList){
                returnSet.add(a.Campaign_Code__c);
            }
        }
        return returnSet;
                                                
    }
    
}