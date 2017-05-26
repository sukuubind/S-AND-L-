/**
 * SRMLeadTriggerHandler.cls
 * @description Handles Lead process of dedup and oppty conversion in bulk specifically for SRM Internal implementation
 * @author Pratik
 * @date 09/08/2014
 */
global without sharing class SRPLeadTriggerHandlerBulk { 
    
    /** 
     * @description Clean up duplicate leads on after insert
     */
    webservice Static void convertLeadManually(Id LeadId){
    	List<Lead> leads = [Select l.smagicinteract__SMSOptOut__c, l.Website, l.Type_of_Law_Degree__c, l.Title, l.SystemModstamp, l.Street, l.Status, l.State, l.Source__c, l.Salutation, l.SRP_Retain_Ownership__c, l.SRP_Other_Program_Information__c, l.RecordTypeId, l.Rating, l.RFI_Campaign_Code__c, l.PostalCode, l.Phone, l.OwnerId, l.NumberOfEmployees, l.Name, l.Mobile__c, l.MobilePhone, l.MasterRecordId, l.Mailing_Province__c, l.Longitude, l.LeadSource, l.Latitude, l.LastName, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.JigsawContactId, l.Jigsaw, l.Is_Converted__c, l.IsUnreadByOwner, l.IsDeleted, l.IsConverted, l.Industry, l.Id, l.IM_Username__c, l.IM_Type__c, l.Highest_Degree_Earned__c, l.HasOptedOutOfFax, l.HasOptedOutOfEmail, l.FirstName, l.Fax, l.EmailBouncedReason, l.EmailBouncedDate, l.Email, l.DoNotCall, l.Description, l.DeltakSRP__cwschedappt__c, l.DeltakSRP__Years_Work_Experience__c, l.DeltakSRP__Work_Phone__c, l.DeltakSRP__Web_Scheduler_Email__c, l.DeltakSRP__WebScheduler_Status__c, l.DeltakSRP__WebScheduler_Email__c, l.DeltakSRP__Time_to_Initial_Attempt__c, l.DeltakSRP__Time_to_Initial_Attempt_Lead_Map__c, l.DeltakSRP__Term__c, l.DeltakSRP__TIme_Zone__c, l.DeltakSRP__Synchronize__c, l.DeltakSRP__Student_School_Fit_Score__c, l.DeltakSRP__Send_Email_On_Convert__c, l.DeltakSRP__STIA_Seconds__c, l.DeltakSRP__Referred_by__c, l.DeltakSRP__Reason_for_Timing__c, l.DeltakSRP__Reactivated_by__c, l.DeltakSRP__Reactivated_Date__c, l.DeltakSRP__Quality_Contact__c, l.DeltakSRP__Primary_Concern__c, l.DeltakSRP__Preferred_Phone__c, l.DeltakSRP__Payment_Type_for_Books__c, l.DeltakSRP__Payment_Type__c, l.DeltakSRP__Other_Concerns__c, l.DeltakSRP__Opportunity_User__c, l.DeltakSRP__Obstacles_to_Success__c, l.DeltakSRP__OK_To_Delete__c, l.DeltakSRP__Motivation__c, l.DeltakSRP__Modality__c, l.DeltakSRP__Lead_Source_ID__c, l.DeltakSRP__Last_Contact__c, l.DeltakSRP__Last_Attempt__c, l.DeltakSRP__LP_UREURL__c, l.DeltakSRP__LP_UREF_MEDIATYPE__c, l.DeltakSRP__LP_UREFPROMOTION__c, l.DeltakSRP__LP_UREFKEYWORD__c, l.DeltakSRP__LP_UADGROUP__c, l.DeltakSRP__LP_UADCAMPAIGN__c, l.DeltakSRP__Is_SRP_Record__c, l.DeltakSRP__Is_Duplicate__c, l.DeltakSRP__Is_Denied_Registration__c, l.DeltakSRP__Interest_Timeframe__c, l.DeltakSRP__Inquiry_Rating__c, l.DeltakSRP__Initial_Attempt__c, l.DeltakSRP__How_Heard__c, l.DeltakSRP__Home_Phone__c, l.DeltakSRP__Gender__c, l.DeltakSRP__GPA__c, l.DeltakSRP__Flag_for_Concern__c, l.DeltakSRP__Financial_Qualification_Score__c, l.DeltakSRP__Financial_Plan__c, l.DeltakSRP__External_Id__c, l.DeltakSRP__Event__c, l.DeltakSRP__Event_Registration_Code__c, l.DeltakSRP__Email_Tracking_ID__c, l.DeltakSRP__Duplicate_Lead_Count__c, l.DeltakSRP__Duplicate_Last_Identified__c, l.DeltakSRP__Discount__c, l.DeltakSRP__Discount_Type__c, l.DeltakSRP__Contact__c, l.DeltakSRP__Commitment_Score__c, l.DeltakSRP__Birthdate__c, l.DeltakSRP__Best_Time_to_Contact__c, l.DeltakSRP__Account_External_Id__c, l.DeltakSRP__Academic_Term_Lookup__c, l.DeltakSRP__Academic_Specialization__c, l.DeltakSRP__Academic_Specialization_Lookup__c, l.DeltakSRP__Academic_Program_Lookup__c, l.DeltakSRP__Academic_Institution_Record_Id__c, l.DeltakSRP__Academic_Institution_Lookup__c, l.DeltakSRP__Academic_Institution_ID__c, l.DeltakSRP__AcademicProgram__c, l.DeltakSRP__AcademicInstitution__c, l.DeltakSRPSMS__Ok_To_Text__c, l.CreatedDate, l.CreatedById, l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.CompanyDunsNumber, l.Company, l.City, l.Citizenship__c, l.AnnualRevenue From Lead l where l.Id=: leadId];
    	onAfterInsert(leads);
    }
     
    public static void onAfterInsert(List<Lead> leads){
        Set<Id> leadsToDelete = new Set<Id>();
        List<Lead> goodLeads = new List<Lead>();
        system.debug('leads>>>>'+leads);
        for(Lead l : leads){
            if(l.DeltakSRP__Is_Duplicate__c){
                leadsToDelete.add(l.Id);
            }else{
                goodLeads.add(l);
            }
        }
        
        if(!leadsToDelete.isEmpty()){
            delete [Select Id From Lead Where Id in :leadsToDelete];
        }
        
        if(!goodLeads.isEmpty()){
            Map<Id,Lead> goodLeadMap = new Map<Id,Lead>(goodLeads);
            goodLeads = 
                [Select 
                    Id,
                    FirstName,
                    LastName,
                    Company,
                    Name,
                    Phone,
                    MobilePhone,
                    OwnerId,
                    DeltakSRP__Work_Phone__c,
                    DeltakSRP__Home_Phone__c,
                    Email,
                    DeltakSRPSMS__Ok_To_Text__c,
                    DoNotCall,
                    HasOptedOutOfEmail,
                    //DeltakSRP__Lead_Source_Id__c,
                    DeltakSRP__Contact__c,
                    DeltakSRP__Contact__r.Name,
                    DeltakSRP__Event_Registration_Code__c,
                    DeltakSRP__Duplicate_Lead_Count__c,
                    DeltakSRP__Academic_Program_Lookup__c,
                    DeltakSRP__Academic_Institution_Lookup__r.Abbreviation__c,
                    deltakSRP__Contact__r.RecordType.Name,
                    deltakSRP__Contact__r.AccountId,
                    deltakSRP__Send_Email_On_Convert__c,
                    RFI_Campaign_Code__c,
                    DeltakSRP__Inquiry_Rating__c,
                    SRP_Retain_Ownership__c,
                    LeadSource
                 From 
                    Lead 
                 Where 
                    Id in :goodLeadMap.keySet()];
                    
            //handleEventRegistration(goodLeads,null);
        }
        
        system.debug('goodleads>>>>'+goodleads);
        List<Opportunity> activePartialDuplicateOpportunities = new List<Opportunity> ();
        List<Opportunity> dormantPartialDuplicateOpportunities = new List<Opportunity> ();
        List<Opportunity> activeNonPartialDuplicateOpportunities = new List<Opportunity> ();
        List<Opportunity> dormantNonPartialDuplicateOpportunities = new List<Opportunity> ();
        List<Opportunity> differentPartnerPartialDuplicateOpportunities = new List<Opportunity> ();
        if(goodleads.size()>0) {
	        
	        activePartialDuplicateOpportunities = getActivePartialDuplicates(goodLeads);
	        
	        dormantPartialDuplicateOpportunities = getDormantPartialDuplicates(goodLeads);
	        
	        activeNonPartialDuplicateOpportunities = getActiveNonPartialDuplicates(goodLeads);
	       
	        dormantNonPartialDuplicateOpportunities = getDormantNonPartialDuplicates(goodLeads);
	      
	        differentPartnerPartialDuplicateOpportunities = getDifferentPartnerOpportunities(goodleads);
        }
        Map<Lead,String> leadToStageMap = new Map<Lead,String>();
        Map<Lead,Opportunity> leadtoOpptyMap = new Map<Lead, Opportunity>();
        
         system.debug('good leads>>>>'+goodleads);
        for(Lead current : goodLeads){
        	/*system.debug('current.RFI_Campaign_Code__c>>>>'+current.RFI_Campaign_Code__c);
            if(current.RFI_Campaign_Code__c == 'Conference' && current.DeltakSRP__Inquiry_Rating__c == 'Low')
                continue;*/
                
            Boolean duplicatefound = false;
            
            for(Opportunity existingopp : activePartialDuplicateOpportunities){
                    if(isPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Active Partial Duplicate Lead>>>>');
                        //SRPLeadConvertHelper.convertlead(current, Label.Opportunity_Dormant_Stage_Name,Label.Opportunity_Dormant_SubStage_Name,existingopp);
                        leadToStageMap.put(current, Label.Opportunity_Dormant_Stage_Name);
                        leadToOpptyMap.put(current, existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
       
            for(Opportunity existingopp : dormantPartialDuplicateOpportunities){
                    if(isPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant Partial Duplicate Lead>>>>');
                        //SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name, '', existingopp);
                        leadToStageMap.put(current, Label.Opportunity_New_Inquiry_Stage_Name);
                        leadToOpptyMap.put(current, existingopp);
                        break;  
                        //send duplicate/dormant email notification
                    }
            }  
 
            for(Opportunity existingopp : activeNonPartialDuplicateOpportunities){
                    if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Active non-Partial Duplicate Lead');
                        //SRPLeadConvertHelper.convertlead(current, Label.Opportunity_Dormant_Stage_Name,Label.Opportunity_Dormant_SubStage_Name,existingopp);
                         leadToStageMap.put(current, Label.Opportunity_Dormant_Stage_Name);
                         leadToOpptyMap.put(current, existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
        
            for(Opportunity existingopp : dormantNonPartialDuplicateOpportunities){
                    if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant non-Partial Duplicate Lead');
                        //SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',existingopp);
                        leadToStageMap.put(current, Label.Opportunity_New_Inquiry_Stage_Name);
                        leadToOpptyMap.put(current, existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            for(Opportunity existingopp : differentPartnerPartialDuplicateOpportunities){
                    if(isPartialDuplicateDiffPartner(current,existingopp)){
                        duplicatefound = true;
                        system.debug('different Partner partial duplicate');
                        //SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',existingopp);
                        leadToStageMap.put(current, Label.Opportunity_New_Inquiry_Stage_Name);
                        leadToOpptyMap.put(current, existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            system.debug('duplicate found>>>>'+duplicatefound);
                if(duplicatefound==false){
                    //throw new SRMException(' new lead!!!');
                    //SRPLeadConvertHelper.convertLead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',null);
                    leadToStageMap.put(current, Label.Opportunity_New_Inquiry_Stage_Name);
                }
                
        }   
        
        if(goodleads.size()> 0)            
        	SRPLEadConvertHelperBulk.convertLeads(leadToStageMap, leadToOpptyMap);
    }
    
    
    public static List<Opportunity> getDifferentPartnerOpportunities(List<Lead> leads){
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
                
        for (Lead newLead : leads) {
            academicInstitutions.add(newLead.DeltakSRP__Academic_Institution_Lookup__c);
            leadEmails.add(newLead.Email);
            if(newLead.Phone != null){
                	leadPhones.add(newLead.Phone);
                	//leadphones.add(formattedphone(newLead.Phone));
                	//leadphones.add(unformattedphone(newLead.Phone));
            }    	
            if(newlead.mobilephone != null){
            	leadphones.add(newLead.MobilePhone);
            	//leadphones.add(formattedphone(newLead.MobilePhone));
            	//leadphones.add(unformattedphone(newLead.MobilePhone));
            }	
            if(newlead.DeltakSRP__Work_Phone__c != null){
            	leadphones.add(newLead.DeltakSRP__Work_Phone__c);
            	//leadphones.add(formattedphone(newLead.DeltakSRP__Work_Phone__c));
            	//leadphones.add(unformattedphone(newLead.DeltakSRP__Work_Phone__c));
            }	
            if(newlead.deltaksrp__home_phone__c != null){
            	leadphones.add(newLead.DeltakSRP__Home_Phone__c);
            	//leadphones.add(formattedphone(newLead.DeltakSRP__Home_Phone__c));
            	//leadphones.add(unformattedphone(newLead.DeltakSRP__Home_Phone__c));
            }	
                			
            leadLastNames.add(newLead.LastName);
            leadAcademicPrograms.add(newLead.DeltakSRP__Academic_Program_Lookup__c);
            //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
            leadFirstNames.add(newLead.FirstName);
        }   
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive from Opportunity where
                    (deltaksrp__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    And DeltakSRP__academic_program__c in :leadAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And accountid    not in :academicInstitutions
                    ];
        system.debug('different partner opps>>>>'+existingopportunities);   
        return existingOpportunities;
    }
    
    public static List<Opportunity> getActiveNonPartialDuplicates(List<Lead> leads){
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
                
        
        for (Lead newLead : leads) {
                academicInstitutions.add(newLead.DeltakSRP__Academic_Institution_Lookup__c);
                leadEmails.add(newLead.Email);
                
                if(newLead.Phone != null){
                	leadPhones.add(newLead.Phone);
                	//leadphones.add(formattedphone(newLead.Phone));
                	//leadphones.add(unformattedphone(newLead.Phone));
                }	
                if(newlead.mobilephone != null){
                	leadphones.add(newLead.MobilePhone);
                	//leadphones.add(formattedphone(newLead.mobilePhone));
                	//leadphones.add(unformattedphone(newLead.mobilePhone));
                }	
                if(newlead.DeltakSRP__Work_Phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Work_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__Work_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__Work_Phone__c));
                }	
                if(newlead.deltaksrp__home_phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Home_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__home_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__Home_Phone__c));
                }	
                			
                leadLastNames.add(newLead.LastName);
                leadAcademicPrograms.add(newLead.DeltakSRP__Academic_Program_Lookup__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                leadFirstNames.add(newLead.FirstName);
        }   
        
         
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive from Opportunity where
                    (DeltakSRP__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    //And DeltakSRP__academic_program__c  not in :leadAcademicPrograms
                    //And DeltakSRP__Lead_Source_ID__c  not in :leadSources)
                    And accountid    in :academicInstitutions
                    And stagename != :Label.Opportunity_Dormant_Stage_Name
                    //And StageName in (:Label.Opportunity_Active_StageName_1, :Label.Opportunity_Active_StageName_2, :Label.Opportunity_Active_StageName_3, :Label.Opportunity_Active_StageName_4, :Label.Opportunity_Active_StageName_5,
                      //      :Label.Opportunity_Active_StageName_6, :Label.Opportunity_Active_StageName_7, :Label.Opportunity_Active_StageName_8, :Label.Opportunity_Active_StageName_9, :Label.Opportunity_Active_StageName_10, :Label.Opportunity_Active_StageName_11)
                    ];
                       
        system.debug('ActiveNonPartialDuplicates>>>>'+existingOpportunities) ;
        
        
        return existingOpportunities;
    }
    
    public static List<Opportunity> getDormantNonPartialDuplicates(List<Lead> leads){
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
        
        for (Lead newLead : leads) {
                academicInstitutions.add(newLead.DeltakSRP__Academic_Institution_Lookup__c);
                leadEmails.add(newLead.Email);
               
                if(newLead.Phone != null){
                	leadPhones.add(newLead.Phone);
                	//leadphones.add(formattedphone(newLead.Phone));
                	//leadphones.add(unformattedphone(newLead.Phone));
                }	
                if(newlead.mobilephone != null){
                	leadphones.add(newLead.MobilePhone);
                	//leadphones.add(formattedphone(newLead.mobilePhone));
                	//leadphones.add(unformattedphone(newLead.mobilePhone));
                }	
                if(newlead.DeltakSRP__Work_Phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Work_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__Work_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__Work_Phone__c));
                }	
                if(newlead.deltaksrp__home_phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Home_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__home_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__home_Phone__c));
                }	
                			
                leadLastNames.add(newLead.LastName);
                leadAcademicPrograms.add(newLead.DeltakSRP__Academic_Program_Lookup__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                leadFirstNames.add(newLead.FirstName);
        }   
        
        
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive from Opportunity where
                    (Deltaksrp__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    //And DeltakSRP__academic_program__c not in :leadAcademicPrograms
                   // And DeltakSRP__Lead_Source_ID__c not in :leadSources)
                    And accountid    in :academicInstitutions
                    And StageName = :Label.Opportunity_Dormant_Stage_Name
                    ];
            system.debug('dormant non partial duplicate>>>>'+existingopportunities);            
            return existingOpportunities;
    }
    
    
    public static List<Opportunity> getDormantPartialDuplicates(List<Lead> leads){
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
//        Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
               
         
        for (Lead newLead : leads) {
                academicInstitutions.add(newLead.DeltakSRP__Academic_Institution_Lookup__c);
                leadEmails.add(newLead.Email);
                
                if(newLead.Phone != null){
                	leadPhones.add(newLead.Phone);
                	//leadphones.add(formattedphone(newLead.Phone));
                	//leadphones.add(unformattedphone(newLead.Phone));
                }	
                if(newlead.mobilephone != null){
                	leadphones.add(newLead.MobilePhone);
                	//leadphones.add(formattedphone(newLead.mobilePhone));
                	//leadphones.add(unformattedphone(newLead.mobilePhone));
                }	
                if(newlead.DeltakSRP__Work_Phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Work_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__Work_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__Work_Phone__c));
                }	
                if(newlead.deltaksrp__home_phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Home_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__home_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__home_Phone__c));
                }	
                			
                leadLastNames.add(newLead.LastName);
                leadAcademicPrograms.add(newLead.DeltakSRP__Academic_Program_Lookup__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                leadFirstNames.add(newLead.FirstName);
        }   
        
        
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive from Opportunity where
                    (deltaksrp__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    //And DeltakSRP__academic_program__c in :leadAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And accountid    in :academicInstitutions 
                    And StageName = :Label.Opportunity_Dormant_Stage_Name
                    ];
        
        system.debug('dormant partial duplicates>>>>'+existingopportunities);            
                       
        return existingOpportunities;
    }
    
    
    public static List<Opportunity> getActivePartialDuplicates(List<Lead> leads){
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
        
        DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        Id profileId = UserInfo.getProfileId();
        
        for (Lead newLead : leads) 
        { 
                academicInstitutions.add(newLead.DeltakSRP__Academic_Institution_Lookup__c);
                leadEmails.add(newLead.Email);
                
                if(newLead.Phone != null){
                	leadPhones.add(newLead.Phone);
                	//leadphones.add(formattedphone(newLead.Phone));
                	//leadphones.add(unformattedphone(newLead.Phone));
                }	
                if(newlead.mobilephone != null){
                	leadphones.add(newLead.MobilePhone);
                	//leadphones.add(formattedphone(newLead.mobilePhone));
                	//leadphones.add(unformattedphone(newLead.mobilePhone));
                }	
                if(newlead.DeltakSRP__Work_Phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Work_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__Work_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__Work_Phone__c));
                }	
                if(newlead.deltaksrp__home_phone__c != null){
                	leadphones.add(newLead.DeltakSRP__Home_Phone__c);
                	//leadphones.add(formattedphone(newLead.DeltakSRP__home_Phone__c));
                	//leadphones.add(unformattedphone(newLead.DeltakSRP__home_Phone__c));
                }	
                			
                leadLastNames.add(newLead.LastName);
                leadAcademicPrograms.add(newLead.DeltakSRP__Academic_Program_Lookup__c);
//                leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                leadFirstNames.add(newLead.FirstName);
        }   
        system.debug('leadphones in partial match>>>>'+leadphones);
        system.debug('leademails in partial match>>>>'+leademails);
        system.debug('leadLastNames in partial match>>>>'+leadLastNames);
        system.debug('leadFirstNames in partial match>>>>'+leadFirstNames);
        system.debug('academicInstitutions in partial match>>>>'+academicInstitutions);
        system.debug('leadAcademicPrograms in partial match>>>>'+leadAcademicPrograms);
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
					deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive from Opportunity where
                    (deltaksrp__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    //And DeltakSRP__academic_program__c not in :leadAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And AccountId    in :academicInstitutions
                    And stagename != :Label.Opportunity_Dormant_Stage_Name
                    //And StageName in (:Label.Opportunity_Active_StageName_1, :Label.Opportunity_Active_StageName_2, :Label.Opportunity_Active_StageName_3, :Label.Opportunity_Active_StageName_4, :Label.Opportunity_Active_StageName_5,
                      //      :Label.Opportunity_Active_StageName_6, :Label.Opportunity_Active_StageName_7, :Label.Opportunity_Active_StageName_8, :Label.Opportunity_Active_StageName_9, :Label.Opportunity_Active_StageName_10, :Label.Opportunity_Active_StageName_11)
                    ];
                    
        system.debug('activepartialduplicates>>>>'+existingopportunities);
                    
        return existingOpportunities;
    } 
    
    

    
    
    
     private static boolean isnonpartialduplicate(Lead current, Opportunity existing){
        system.debug('isDuplicateWithoutRegCode(current,existing)>>>>'+isDuplicateWithoutRegCode(current,existing));
        return
        isDuplicateWithoutRegCode(current,existing)  &&  
            (
//                current.DeltakSRP__Lead_Source_ID__c != existing.DeltakSRP__Lead_Source_ID__c && 
                current.DeltakSRP__Academic_Program_Lookup__c != existing.DeltakSRP__Academic_Program__c
            )
            &&
            current.DeltakSRP__Academic_Institution_Lookup__c == existing.AccountId;
    }
    
    private static boolean ispartialduplicateDiffPartner(Lead current, Opportunity existing){
        return 
        isDuplicateWithoutRegCode(current,existing)  && 
            (
        //        current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c || 
                current.DeltakSRP__Academic_Program_Lookup__c == existing.DeltakSRP__Academic_Program__c 
            )
            &&
            current.DeltakSRP__Academic_Institution_Lookup__c != existing.AccountId;
    }
    
    private static boolean ispartialduplicate(Lead current, Opportunity existing){
    	system.debug('isDuplicateWithoutRegCode(current,existing)>>>>'+isDuplicateWithoutRegCode(current,existing));
        return 
        isDuplicateWithoutRegCode(current,existing)  && 
            (
          //      current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c || 
                current.DeltakSRP__Academic_Program_Lookup__c == existing.DeltakSRP__Academic_Program__c 
            )
            &&
            current.DeltakSRP__Academic_Institution_Lookup__c == existing.AccountId;
    }
    
    
    /*public static String formattedphone(String pnumber){
    	String phonenumber;
    	String formattedNumber;
    	
    	if(pnumber == null)
    		return null;
    	
    	if(pnumber.contains('-') || pnumber.contains('(') || pnumber.contains(')'))
    		phonenumber = unformattedPhone(pnumber);
    	else
    		phonenumber = pnumber;	
    	
    	if(pnumber.length()>=10)
    		formattedNumber = '('+phonenumber.substring(0, 3) + ') ' +phonenumber.substring(3, 6) + '-' + phonenumber.substring(6, 10);

    	return formattedNumber;			
    }
    
    public static String unformattedPhone(String pnumber){
    	if(pnumber == null)
    		return null;
    	String phonenumber = pnumber;
    	phonenumber = phonenumber.replace('-','');
    	phonenumber = phonenumber.replace('.','');
	    phonenumber=phonenumber.replace(')','');
	    phonenumber=phonenumber.replace('(','');
	    phonenumber=phonenumber.replace(' ','');
	    phonenumber=phonenumber.replace('x','');
    	system.debug('phonenumber>>>>'+phonenumber);
		phonenumber.trim();
    	return phonenumber;	
    }*/
    
    private static boolean isDuplicateWithoutRegCode(Lead current,Opportunity existing){
          return 
            ((current.Phone != null && (current.Phone == existing.deltaksrp__student__r.mobilephone || current.Phone == existing.DeltakSRP__student__r.homephone || current.Phone == existing.deltaksrp__student__r.DeltakSRP__Work_Phone__c))  
            || (current.MobilePhone != null && (current.MobilePhone == existing.deltaksrp__student__r.mobilephone || current.MobilePhone == existing.DeltakSRP__student__r.homephone || current.MobilePhone == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.deltaksrp__student__r.mobilephone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__student__r.homephone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.deltaksrp__student__r.mobilephone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__student__r.homephone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.Email != null && current.Email == existing.deltaksrp__Email__c)) &&
          current.FirstName == existing.DeltakSRP__Student__r.FirstName &&
          current.LastName == existing.DeltakSRP__Student__r.LastName; 
    }
}