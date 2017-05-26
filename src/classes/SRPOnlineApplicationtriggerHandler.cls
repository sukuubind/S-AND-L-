public without sharing class SRPOnlineApplicationtriggerHandler {
    
    public static SRPEmployerWrapper getemployerDetails(Id appId){
        List<DeltakSRP__Student_Online_Application_Tuple__c> tupleList = new List<DeltakSRP__Student_Online_Application_Tuple__c>();
        tupleList = [Select DeltakSRP__Company_Name__c, Position__c from DeltakSRP__Student_Online_Application_Tuple__c where DeltakSRP__Student_Online_Application__c =: appId 
            and (DeltakSRP__Company_Name__c!= null OR DeltakSRP__Company_Name__c != '') ORDER BY Dates_of_Employment_End__c DESC];
        
        if(tupleList.size()>0){
            SRPEmployerWrapper empWrap = new SRPEmployerWrapper(tupleList[0].DeltakSRP__Company_Name__c, tupleList[0].Position__c);
            return empWrap;
        }   
        else
            return null;    
    }   
    
    public Static void handleBeforeInsert(List<Contact> srpcontact, List<DeltakSRP__Student_Online_Application__c> studentOnlineApplications){
        DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        
        
        boolean opptyexist = false;
        boolean opptyfound = false;
        boolean alldormant = true;
        
        List<Opportunity> OpportunitiesToCreate = new List<Opportunity>();
        RecordType rt = [Select Id from RecordType where name =: 'SRP Opportunity'];
        
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        List<Id> AllDormantOpportunityIds = new List<Id>();
        
        Id ownerid;
        system.debug('contact>>>>' +srpcontact);
        
        List<Campaign> blindCampaign = new List<Campaign>();
        blindCampaign = [Select Id from Campaign where name = :Label.BlindCampaignName AND Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < :System.today()
                                                AND EndDate >= :System.today()
                                                And IsActive = true];
        
        List<DeltakSRP__Academic_Start_Date__c> startdates = new List<DeltakSRP__Academic_Start_Date__c>();
        startdates = [Select DeltakSRP__Start_Date__c from DeltakSRP__Academic_Start_Date__c where Id =:studentonlineapplications[0].DeltakSRP__Academic_Start_Date__c];
        
        Id originalSpec; 
        Id originalTerm;
        Map<String, String> ownerEmailMap = new Map<String, String>();
        
        if(srpcontact.size() > 0){
        		List<id> idlist = new List<id>();
        		for(Opportunity opp: srpcontact[0].DeltakSRP__Opportunities__r){
        			idlist.add(opp.ownerId);
	        		idlist.add(opp.admissions_manager__c);
        		}
        		List<User> uList = [Select id, email from User where id in :idList and isActive = true];
        		if(uList!=null && uList.size()>0)
        		{
        			for(User u1: uList)
        			{
        				ownerEmailMap.put(u1.id, u1.email);
        			}
        		}
                for(Opportunity o: srpcontact[0].DeltakSRP__Opportunities__r){
                	
                	opptyexist = true;
                	originalSpec = o.DeltakSRP__Academic_Specialization__c;
                    originalTerm = o.DeltakSRP__Academic_Start_Date__c;
                    
                	if(o.StageName != 'Dormant' && o.owner.isactive && o.DeltakSRP__Academic_Program__c != studentOnlineApplications[0].DeltakSRP__Academic_Program__c)
                	{
                		ownerid = o.OwnerId;
                		alldormant = false;
                	}
                	
                    if(o.DeltakSRP__Academic_Program__c == studentOnlineApplications[0].DeltakSRP__Academic_Program__c)
                        opptyfound = true;
                    
                    if(o.StageName != 'Dormant' && o.DeltakSRP__Academic_Program__c == studentOnlineApplications[0].DeltakSRP__Academic_Program__c){
                        alldormant = false;
                        
                        Opportunity o2 = new Opportunity();
                        o2 = o;
                        o2.Online_Application_Stage__c = 'Partial Application';
                        //o2.StageName = 'New Inquiry';
                        o2.DeltakSRP__Academic_Specialization__c = studentOnlineApplications[0].DeltakSRP__Academic_Specialization__c;
                        o2.DeltakSRP__Start_Date__c = startdates[0].DeltakSRP__Start_Date__c;
                        o2.DeltakSRP__Academic_Start_Date__c = startdates[0].id;
                        System.debug('ownerId--->>>'+ownerid);
                        studentonlineapplications[0].SRP_Unlock_Email_Recepient__c = ownerId;
                        System.debug('ownerEmailMap-->>>'+ownerEmailMap);
                        if(ownerEmailMap!=null && ownerEmailMap.get(ownerId)!=null)
	                    {
	                        studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(ownerId);
	                    }
                        studentonlineapplications[0].Opportunity_Owner__c = ownerId;
                        
                        opportunitiesToUpdate.add(o2);
                        
                        //studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = o2.admissions_manager__c;
                        
                        if(o2.admissions_manager__c != null){
                        	if(ownerEmailMap!=null && ownerEmailMap.get(o2.admissions_manager__c)!=null)
                        	{
                        		studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(o2.admissions_manager__c);
                        	}
                        	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = o2.admissions_manager__c;
                        }	
                        else{
                        	if(o2.OwnerId!=setting.SRP_Lead_Engine_UserId__c)
                        	{
	                        	if(ownerEmailMap!=null && ownerEmailMap.get(o2.ownerId)!=null)
	                        	{
	                        		studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(o2.ownerId);
	                        	}	
	                        	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = o2.OwnerId;
                        	}
                        }			
                        
                    }
                    
                }
                
                if(opptyfound == true && alldormant == false){
                	system.debug('opportunitiesToUpdate>>>>'+opportunitiesToUpdate);
                    update opportunitiesToUpdate;
                }
                
                if(opptyfound == true && alldormant == true){
                    for(Opportunity o: srpcontact[0].DeltakSRP__Opportunities__r){
                        if(o.StageName == 'Dormant' && o.DeltakSRP__Academic_Program__c == studentOnlineApplications[0].DeltakSRP__Academic_Program__c)
                        {
                        	    AlldormantOpportunityIds.add(o.Id);
                        } 	    
                    }            
                }
                
                if(opptyfound == false && alldormant == true){
                    for(Opportunity o: srpcontact[0].DeltakSRP__Opportunities__r){
                    	if(o.owner.isactive)
                        	ownerid = o.ownerid;
                    }
                    system.debug('ownerid onfound>>>>'+ownerid);                    
                }
                
                system.debug('oppty found>>>>'+opptyfound);
            
                if(opptyfound == false){
                    String newOppName = '';
                        
                    if(srpcontact[0].Account.Abbreviation__c != null)
                        newOppName = newOppName + srpcontact[0].Account.Abbreviation__c + '-';
                    
                    if(srpcontact[0].FirstName != null) 
                        newOppName = newOppName + srpcontact[0].FirstName.substring(0,1) + '. ';
                    
                    if(srpcontact[0].lastname != null)
                        newOppName = newOppName + srpcontact[0].LastName;
                    
                    Opportunity o = new Opportunity();
                    o.deltaksrp__student__c = srpcontact[0].Id;
                    o.RecordTypeId = rt.Id;
                    o.StageName='New Inquiry';
                    o.Name = newOppName;
                    o.CloseDate = system.today(); 
                    o.Online_Application_Stage__c = 'Partial Application';
                    o.AccountId = srpcontact[0].AccountId;
                    if(opptyexist == false){
                    	//o.OwnerId = srpcontact[0].account.ownerid;
                    	o.ownerId = setting.SRP_Lead_Engine_UserId__c;
                    	
                    }else{
                    	if(ownerid != null)
                    		o.OwnerId = ownerid; 
                    }
                    system.debug('ownerid>>>>'+ownerid);
                    system.debug('opptyexist>>>>'+opptyexist);
                    system.debug('opptyfound>>>>'+opptyfound);
                    system.debug('o.ownerid>>>>'+o.ownerid);
                    
                    if(ownerid != null)
                    	o.SRP_Retain_Ownership__c = true;
                    	
                    o.DeltakSRP__Academic_Program__c = studentonlineapplications[0].DeltakSRP__Academic_Program__c;
                    o.DeltakSRP__Academic_Specialization__c = studentonlineapplications[0].DeltakSRP__Academic_Specialization__c;
                    o.Online_Application_Stage__c = 'Partial Application';
                    o.DeltakSRP__Academic_Start_Date__c = studentonlineapplications[0].DeltakSRP__Academic_Start_Date__c;
                    o.DeltakSRP__Start_Date__c = startdates[0].DeltakSRP__Start_Date__c;
                    system.debug('o.ownerid>>>>'+o.ownerid);
                    
                    if(blindCampaign.size() > 0)
                    	o.CampaignId = blindcampaign[0].id;
                    
                    OpportunitiesToCreate.add(o);
                    studentonlineapplications[0].Opportunity_Owner__c = o.ownerid;
                    if(o.admissions_manager__c != null){
                    		if(ownerEmailMap!=null && ownerEmailMap.get(o.admissions_manager__c)!=null)
                        	{
                        		studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(o.admissions_manager__c);
                        	}else
                        	{
                        		studentOnlineApplications[0].SRP_Unlock_Request_Email__c = o.admissions_manager__r.email;
                        	}
                        	
                        	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = o.admissions_manager__c;
                    }	
                    else{
                    	if(o.OwnerId!=setting.SRP_Lead_Engine_UserId__c)
                        {
	                    	if(ownerEmailMap!=null && ownerEmailMap.get(o.ownerId)!=null)
	                        {
	                        	studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(o.OwnerId);
	                        }else
	                        {
	                    		studentOnlineApplications[0].SRP_Unlock_Request_Email__c = o.owner.email;
	                        }	
	                    	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = o.OwnerId;
                        }
                    }	
                }
                if(ownerId!=null && ownerEmailMap!=null && ownerEmailMap.get(ownerId)!=null)
	            {
	            	System.debug('Here-->'+OwnerId+'***'+ownerEmailMap);
	            	studentonlineapplications[0].Opportunity_Owner__c = ownerid;
	                studentOnlineApplications[0].SRP_Unlock_Request_Email__c = ownerEmailMap.get(OwnerId);
	            }
            }
            
            if(OpportunitiesToCreate.size()>0)
                insert OpportunitiesToCreate;
        
            system.debug('AlldormantOpportunityIds>>>>'+AlldormantOpportunityIds);
            
            List<Opportunity> OppToUpdate = new List<Opportunity>();
            if(AlldormantOpportunityIds.size() > 0){
                List<Opportunity> AllDormantOpportunities = new List<Opportunity>();
                
                AlldormantOpportunities = [Select Id, ownerid, admissions_manager__r.email, owner.email, DeltakSRP__Academic_Program__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, DeltakSRP__Start_Date__c, Online_Application_Stage__c, account.owner.email, (select createdDate, ActivityDate from Tasks ORDER BY ActivityDate desc), (Select createdDate, ActivityDate from Events ORDER BY ActivityDate desc) from Opportunity where Id in: AlldormantOpportunityIds];
                
                system.debug('AlldormantOpportunities>>>>'+AlldormantOpportunities);
                
                Map<Id, Opportunity> allOppMap = new Map<Id, Opportunity>();
                Opportunity MostRecentOppty = new Opportunity();
                
                for(Opportunity o: AlldormantOpportunities){
                    allOppMap.put(o.Id, o);
                    MostRecentOppty = AlldormantOpportunities[0];
                }
                
                ownerid = AlldormantOpportunities[0].ownerid;
                
                Date cDate = date.newInstance (1900, 2, 17);
                List<Id> currentOppIds = new List<Id>();
                for(Opportunity o: AlldormantOpportunities){
                    
                    currentOppIds.add(o.Id);
                    
                    for(Task t: o.tasks){
                        if(t.ActivityDate > cDate)
                            cDate = t.ActivityDate;
                    }                               
                    
                    for(Event e: o.events){
                        if(e.ActivityDate > cDate)
                            cDate = e.ActivityDate;
                     }                          
                    
                }
                
                List<Task> mostRecentTask = new List<Task>();
                List<Event> mostRecentEvent = new List<Event>();
                mostRecentTask = [Select Id, whatId from Task where whatId in: currentOppIds and ActivityDate = :cDate];
                mostRecentEvent = [Select Id, whatId from Event where whatId in: currentOppIds and ActivityDate = :cDate];
                
                if(mostRecentTask.size() > 0){
                    MostRecentOppty = alloppmap.get(mostRecentTask[0].whatId);
                    MostRecentOppty.StageName='New Inquiry';
                    MostRecentOppty.Online_Application_Stage__c = 'Partial Application';
                }
                
                if(mostRecentEvent.size() > 0){
                    MostRecentOppty = alloppmap.get(mostRecentevent[0].whatId);
                    MostRecentOppty.StageName='New Inquiry';
                    MostRecentOppty.Online_Application_Stage__c = 'Partial Application';
                }
                
                if(mostRecentEvent.size() == 0 && mostRecentTask.size() == 0){
                    MostRecentOppty.StageName='New Inquiry';
                    MostRecentOppty.Online_Application_Stage__c = 'Partial Application';
                    MostRecentOppty.DeltakSRP__Academic_Specialization__c = studentOnlineApplications[0].DeltakSRP__Academic_Specialization__c;
                    MostRecentOppty.DeltakSRP__Start_Date__c = startdates[0].DeltakSRP__Start_Date__c;
                    MostRecentOppty.DeltakSRP__Academic_Start_Date__c = startdates[0].id;
                }
                
                if(MostRecentOppty != null){
                    OppToUpdate.add(MostRecentOppty);
                }    
                
                if(OppToupdate.size() > 0){
                	if(MostRecentOppty.admissions_manager__c != null){
                        	studentOnlineApplications[0].SRP_Unlock_Request_Email__c = MostRecentOppty.admissions_manager__r.email;
                        	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = MostRecentOppty.admissions_manager__c;
                    }	
                    else{
                    	if(MostRecentOppty.OwnerId!=setting.SRP_Lead_Engine_UserId__c)
                        {
	                    	studentOnlineApplications[0].SRP_Unlock_Request_Email__c = MostRecentOppty.owner.email;	
	                    	studentOnlineApplications[0].SRP_Unlock_Email_Recepient__c = MostRecentOppty.OwnerId;
                        }
                    }	
                    studentonlineapplications[0].Opportunity_Owner__c = MostRecentOppty.OwnerId;
                    system.debug('opptoUpdate.Online_Application_Stage__c1>>>>'+opptoUpdate[0].Online_Application_Stage__c);
                    update OppToUpdate;
                    system.debug('opptoUpdate.Online_Application_Stage__c2>>>>'+opptoUpdate[0].Online_Application_Stage__c);
                }       
            }
            
            for(DeltakSRP__Student_Online_Application__c app: studentOnlineApplications){
                if(opportunitiestocreate.size()>0){
                    app.DeltakSRP__Affiliation_Opportunity__c = opportunitiestocreate[0].ID;
                    SRPOnlineApplicationTriggerUtils.copyAdmissionsDocumentsToOpportunity(opportunitiestocreate[0]); 
                }
                
                if(opportunitiestoupdate.size()>0){ 
                    app.DeltakSRP__Affiliation_Opportunity__c = opportunitiestoupdate[0].ID;
                    system.debug('originalSpec>>>>'+originalSpec+  ' ' + opportunitiestoupdate[0].DeltakSRP__Academic_Specialization__c);
                    system.debug('originalTerm>>>>'+originalTerm+ ' ' + opportunitiestoupdate[0].DeltakSRP__Academic_Start_Date__c);
                    if(studentOnlineApplications[0].DeltakSRP__Academic_Specialization__c != originalSpec || studentOnlineApplications[0].DeltakSRP__Academic_Start_Date__c != originalTerm)
                    	SRPOnlineApplicationTriggerUtils.copyAdmissionsDocumentsToOpportunity(opportunitiestoupdate[0]);
                }
                    
                if(opptoUpdate.size()>0){   
                    app.DeltakSRP__Affiliation_Opportunity__c = opptoUpdate[0].ID;  
                    
                    if(studentOnlineApplications[0].DeltakSRP__Academic_Specialization__c != originalSpec || studentOnlineApplications[0].DeltakSRP__Academic_Start_Date__c != originalTerm)
                    	SRPOnlineApplicationTriggerUtils.copyAdmissionsDocumentsToOpportunity(opptoUpdate[0]);
                }   
                    
                system.debug('app.DeltakSRP__Affiliation_Opportunity__c>>>>'+app.DeltakSRP__Affiliation_Opportunity__c);
            }
            
        }
        
        public Static void handleBeforeUpdate(List<Contact> srpcontact, DeltakSRP__Student_Online_Application__c app, DeltakSRP__Student_Online_Application__c oldApp){
                DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance();
                List<DeltakSRP__Student_Online_Application__c> appList = [Select Opportunity_Owner__c, DeltakSRP__Affiliation_Opportunity__r.ownerId, deltakSRP__Affiliation_Opportunity__r.Admissions_manager__r.email, DeltakSRP__Affiliation_Opportunity__r.owner.email
                                    from DeltakSRP__Student_Online_Application__c where Id =: app.Id];
                
              
                if(oldApp.SRP_Attachment_Email_Sent__c == true &&
                    oldApp.deltaksrp__submitted__c != app.deltaksrp__submitted__c){
                        app.SRP_Attachment_Email_Sent__c= false;
                    }
                 app.Opportunity_Owner__c = appList[0].DeltakSRP__Affiliation_Opportunity__r.ownerid;
                   
                   if(oldApp.DeltakSRP__Submitted__c != True && (app.DeltakSRP__Payment_Type__c == 'No Payment' || app.DeltakSRP__Payment_Type__c == 'Mail in Check') && app.DeltakSRP__Submitted__c == True){
                    system.debug('inside if***');
                    app.DeltakSRP__Application_Status__c = 'Submitted, Awaiting Payment';
                    //if(app.deltakSRP__Affiliation_Opportunity__r.Admissions_manager__r.email != null)
                      //  app.srp_unlock_request_email__c =appList[0].deltakSRP__Affiliation_Opportunity__r.Admissions_manager__r.email;
                    //else
                      //  app.srp_unlock_request_email__c = appList[0].DeltakSRP__Affiliation_Opportunity__r.owner.email; 
                      if(app.deltakSRP__Affiliation_Opportunity__r.Admissions_manager__c != null){
                      	app.srp_unlock_email_recepient__c = app.deltakSRP__Affiliation_Opportunity__r.Admissions_manager__c;
                      	app.srp_unlock_request_email__c = app.deltakSRP__Affiliation_Opportunity__r.Admissions_manager__r.email;
                      }	
                      else{
                      	app.srp_unlock_email_recepient__c = appList[0].DeltakSRP__Affiliation_Opportunity__r.ownerid;
                      	app.srp_unlock_request_email__c = app.deltakSRP__Affiliation_Opportunity__r.Admissions_manager__r.email;
                      }	 
                }
                //system.debug('app.srp_unlock_request_email__c***'+app.DeltakSRP__Affiliation_Opportunity__r.owner.email+'***'+app.srp_unlock_request_email__c)
        }
        
        public Static void handleAfterUpdate(List<Contact> srpcontact, DeltakSRP__Student_Online_Application__c app, DeltakSRP__Student_Online_Application__c oldApp){
            List<Contact> contactsToUpdate = new List<Contact>();
            contact c2 = srpcontact[0];
            if((app.DeltakSRP__Application_Status__c == 'Submitted' 
                    && OldApp.DeltakSRP__Application_Status__c != 'Submitted') ||
                    (app.DeltakSRP__Application_Status__c == 'Submitted, Awaiting Payment' 
                    && OldApp.DeltakSRP__Application_Status__c != 'Submitted, Awaiting Payment')){
                        
                        if(app.Maiden__c != null && app.Maiden__c.trim() != '' && (c2.DeltakSRP__Maiden_Name__c == null || c2.DeltakSRP__Maiden_Name__c.trim() == ''))
                        {
                        	c2.DeltakSRP__Maiden_Name__c = app.Maiden__c;
                        }
                        
                        c2.Birthdate = app.DeltakSRP__Date_of_Birth__c;
                        c2.DeltakSRP__Gender__c = app.DeltakSRP__Gender__c;
                    
                        if(app.DeltakSRP__Address_Line_1__c != null)
                            c2.mailingstreet = app.DeltakSRP__Address_Line_1__c;
                        
                        if(app.DeltakSRP__Address_Line_2__c != null)
                            c2.mailingstreet = c2.mailingstreet + app.DeltakSRP__Address_Line_2__c;
                            
                        if(app.DeltakSRP__Address_Line_3__c != null)
                             c2.mailingstreet = c2.mailingstreet    + ' ' +app.DeltakSRP__Address_Line_3__c;
                        
                        c2.mailingcity = app.DeltakSRP__City__c;
                        c2.mailingstate = app.DeltakSRP__State_Province__c;
                        c2.mailingpostalcode = app.DeltakSRP__Zip_Postal_Code__c;
                        c2.mailingcountry = app.DeltakSRP__Country__c;
                        c2.DeltakSRP__Job_Title__c =app.DeltakSRP__Job_Title__c;
                        c2.mobilephone = app.DeltakSRP__Mobile_Phone__c; 
                        SRPEmployerWrapper ewrap = getEmployerDetails(app.Id);
                        
                        if(eWrap != null){
                            c2.DeltakSRP__Employer_Company__c = ewrap.EmployerName;
                            c2.DeltakSRP__Job_Title__c = ewrap.title;
                        }else{
                            if(app.DeltakSRP__Company_Name__c != null)
                                c2.DeltakSRP__Employer_Company__c = app.DeltakSRP__Company_Name__c;
                            else
                                c2.DeltakSRP__Employer_Company__c = 'Not Specified in Online Application';
                        }           
                        //c2.DeltakSRP__Work_Years_Experience__c
                        contactsToUpdate.add(c2);
                        system.debug('updating contacts>>>'+c2);
            }
            
            if(contactstoupdate.size() > 0)
                update contactstoupdate;
            
             //SRP-55: George Abboud 20140724 Modified
            
            //List<String> stageNamesToUpdate = new List<String>{'New Inquiry','Initiated Communication','Appointment Scheduled','Appointment Completed','Pending Application'};
            
            List<Opportunity> relatedOpp = new List<Opportunity>();
            relatedOpp = [Select Id, stagename, DeltakSRP__Sub_Stage__c, Online_Application_Stage__c, DeltakSRP__Date_Booked__c from Opportunity where Id =: app.DeltakSRP__Affiliation_Opportunity__c];
                        
            List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
            if(( (app.DeltakSRP__Application_Status__c == 'Submitted' 
                    && OldApp.DeltakSRP__Application_Status__c != 'Submitted') ||
                    (app.DeltakSRP__Application_Status__c == 'Submitted, Awaiting Payment' 
                    && OldApp.DeltakSRP__Application_Status__c != 'Submitted, Awaiting Payment')) &&
                    relatedopp.size() > 0){
                    	
                    	if(relatedopp[0].DeltakSRP__Date_Booked__c == NULL || String.isBlank(relatedopp[0].DeltakSRP__Date_Booked__c + ''))
                    	{
                        	relatedOpp[0].StageName = 'Pending Application';
                        	relatedOpp[0].DeltakSRP__Sub_Stage__c = 'Awaiting Verification';
                    	}
                    	
                        relatedOpp[0].Online_Application_Stage__c = 'Completed Application';
                        update relatedOpp[0];
                        //SRPOnlineApplicationTriggerUtils.copyAdmissionsDocumentsToOpportunity(relatedOpp);
            }
 
 			//SRP-55: end
 
        } 
}