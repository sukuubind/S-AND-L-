/**
 * SRMLeadTriggerHandler.cls
 * @description Handles Lead process of dedup and oppty conversion specifically for SRM Instance
 * @author Pratik
 * @date 07/23/2013 
 */
global without sharing class SRPLeadTriggerHandler {
    
    /** 
     * @description Clean up duplicate leads on after insert
     */
    webservice Static void convertLeadManually(Id LeadId){
      List<Lead> leads = [Select l.smagicinteract__SMSOptOut__c, l.Website, l.Type_of_Law_Degree__c, l.Title, l.SystemModstamp, l.Street, l.Status, l.State, l.Source__c, l.Salutation, l.SRP_Retain_Ownership__c, l.SRP_Other_Program_Information__c, l.RecordTypeId, l.Rating, l.RFI_Campaign_Code__c, l.PostalCode, l.Phone, l.OwnerId, l.NumberOfEmployees, l.Name, l.Mobile__c, l.MobilePhone, l.MasterRecordId, l.Mailing_Province__c, l.Longitude, l.LeadSource, l.Latitude, l.LastName, l.LastModifiedDate, l.LastModifiedById, l.LastActivityDate, l.JigsawContactId, l.Jigsaw, l.Is_Converted__c, l.IsUnreadByOwner, l.IsDeleted, l.IsConverted, l.Industry, l.Id, l.IM_Username__c, l.IM_Type__c, l.Highest_Degree_Earned__c, l.HasOptedOutOfFax, l.HasOptedOutOfEmail, l.FirstName, l.Fax, l.EmailBouncedReason, l.EmailBouncedDate, l.Email, l.DoNotCall, l.Description, l.DeltakSRP__cwschedappt__c, l.DeltakSRP__Years_Work_Experience__c, l.DeltakSRP__Work_Phone__c, l.DeltakSRP__Web_Scheduler_Email__c, l.DeltakSRP__WebScheduler_Status__c, l.DeltakSRP__WebScheduler_Email__c, l.DeltakSRP__Time_to_Initial_Attempt__c, l.DeltakSRP__Time_to_Initial_Attempt_Lead_Map__c, l.DeltakSRP__Term__c, l.DeltakSRP__TIme_Zone__c, l.DeltakSRP__Synchronize__c, l.DeltakSRP__Student_School_Fit_Score__c, l.DeltakSRP__Send_Email_On_Convert__c, l.DeltakSRP__STIA_Seconds__c, l.DeltakSRP__Referred_by__c, l.DeltakSRP__Reason_for_Timing__c, l.DeltakSRP__Reactivated_by__c, l.DeltakSRP__Reactivated_Date__c, l.DeltakSRP__Quality_Contact__c, l.DeltakSRP__Primary_Concern__c, l.DeltakSRP__Preferred_Phone__c, l.DeltakSRP__Payment_Type_for_Books__c, l.DeltakSRP__Payment_Type__c, l.DeltakSRP__Other_Concerns__c, l.DeltakSRP__Opportunity_User__c, l.DeltakSRP__Obstacles_to_Success__c, l.DeltakSRP__OK_To_Delete__c, l.DeltakSRP__Motivation__c, l.DeltakSRP__Modality__c, l.DeltakSRP__Lead_Source_ID__c, l.DeltakSRP__Last_Contact__c, l.DeltakSRP__Last_Attempt__c, l.DeltakSRP__LP_UREURL__c, l.DeltakSRP__LP_UREF_MEDIATYPE__c, l.DeltakSRP__LP_UREFPROMOTION__c, l.DeltakSRP__LP_UREFKEYWORD__c, l.DeltakSRP__LP_UADGROUP__c, l.DeltakSRP__LP_UADCAMPAIGN__c, l.DeltakSRP__Is_SRP_Record__c, l.DeltakSRP__Is_Duplicate__c, l.DeltakSRP__Is_Denied_Registration__c, l.DeltakSRP__Interest_Timeframe__c, l.DeltakSRP__Inquiry_Rating__c, l.DeltakSRP__Initial_Attempt__c, l.DeltakSRP__How_Heard__c, l.DeltakSRP__Home_Phone__c, l.DeltakSRP__Gender__c, l.DeltakSRP__GPA__c, l.DeltakSRP__Flag_for_Concern__c, l.DeltakSRP__Financial_Qualification_Score__c, l.DeltakSRP__Financial_Plan__c, l.DeltakSRP__External_Id__c, l.DeltakSRP__Event__c, l.DeltakSRP__Event_Registration_Code__c, l.DeltakSRP__Email_Tracking_ID__c, l.DeltakSRP__Duplicate_Lead_Count__c, l.DeltakSRP__Duplicate_Last_Identified__c, l.DeltakSRP__Discount__c, l.DeltakSRP__Discount_Type__c, l.DeltakSRP__Contact__c, l.DeltakSRP__Commitment_Score__c, l.DeltakSRP__Birthdate__c, l.DeltakSRP__Best_Time_to_Contact__c, l.DeltakSRP__Account_External_Id__c, l.DeltakSRP__Academic_Term_Lookup__c, l.DeltakSRP__Academic_Specialization__c, l.DeltakSRP__Academic_Specialization_Lookup__c, l.DeltakSRP__Academic_Program_Lookup__c, l.DeltakSRP__Academic_Institution_Record_Id__c, l.DeltakSRP__Academic_Institution_Lookup__c, l.DeltakSRP__Academic_Institution_ID__c, l.DeltakSRP__AcademicProgram__c, l.DeltakSRP__AcademicInstitution__c, l.DeltakSRPSMS__Ok_To_Text__c, l.CreatedDate, l.CreatedById, l.Country, l.ConvertedOpportunityId, l.ConvertedDate, l.ConvertedContactId, l.ConvertedAccountId, l.CompanyDunsNumber, l.Company, l.City, l.Citizenship__c, l.AnnualRevenue From Lead l where l.Id=: leadId];
      onAfterInsert(leads);
    }/**
     * @description Clean up duplicate leads on after insert
     */
     
    public static List<Lead> prefixPhoneNumbers(List<Lead> leads) {
      Map<String, SRP_Phone_Codes__c> phonecodes = SRP_Phone_Codes__c.getall(); 
    List<Lead> leadsToReturn = new List<Lead>();
    for(Lead l: leads){
      if(l.phone != null &&  (l.country != null || l.state != null)){
        String generalphonenumber;
        String phonecode = '';
        
        if(l.phone != null)  
          generalphonenumber = unformatphonenumber(l.phone);
            
        system.debug('generalphonenumber>>>>'+generalphonenumber);
        if(l.country != null && phonecodes.get(l.country.tolowercase())!=null){
          phonecode = phonecodes.get(l.country.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          
          
          if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+'+phonecode)){
            l.phone = generalphonenumber;
          }
            
          if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode)){
            l.phone = '+'+generalphonenumber;
          }
          
          system.debug('generalphonenumber2>>>>'+generalphonenumber);
          system.debug('phonecode2>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+'+phonecode) && !generalphonenumber.startswith(phonecode)){
            l.phone = '+'+phonecode+generalphonenumber;
            system.debug('l.generalphone>>>>'+l.phone);
          }
        }    
        
        if(l.country == null && l.state != null && phonecodes.get(l.state.tolowercase())!=null){
          phonecode = phonecodes.get(l.state.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+'+phonecode)){
              l.phone = generalphonenumber;
          }
            
          if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode)){
            l.phone = '+'+generalphonenumber;
          }
          
          if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+'+phonecode) && !generalphonenumber.startswith(phonecode)){
            l.phone = '+'+phonecode+generalphonenumber;
          }
        }
      }
    
      if(l.deltaksrp__home_phone__c!= null && (l.country != null || l.state != null)){
        String homephonenumber;
        String phonecode = '';
        homephonenumber = unformatphonenumber(l.deltaksrp__home_phone__c);
        system.debug('homephonenumber>>>>'+homephonenumber);
        if(l.country != null && phonecodes.get(l.country.tolowercase())!=null){
          phonecode = phonecodes.get(l.country.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);  
            
            
          if(phonecode != '' && phonecode != null && homephonenumber.startswith('+'+phonecode)){
            l.deltaksrp__home_phone__c = homephonenumber;
          }
          
          if(phonecode != '' && phonecode != null && homephonenumber.startswith(phonecode)){
            l.deltaksrp__home_phone__c = '+'+homephonenumber;
          }
          
          system.debug('homephonenumber2>>>>'+homephonenumber);
          system.debug('phonecode2>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && !homephonenumber.startswith('+'+phonecode) && !homephonenumber.startswith(phonecode)){
            l.deltaksrp__home_phone__c = '+'+phonecode+homephonenumber;
            system.debug('l.deltaksrp__home_phone__c>>>>'+l.deltaksrp__home_phone__c);
          }
        }  
        
        if(l.country == null && l.state != null && phonecodes.get(l.state.tolowercase())!=null){
          system.debug('inside if state homephonenumber>>>>'+l.state+'>>>>'+homephonenumber);
          phonecode = phonecodes.get(l.state.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && homephonenumber.startswith('+'+phonecode)){
            system.debug('inside if 1>>>>');
            l.deltaksrp__home_phone__c = homephonenumber;
          }
            
          if(phonecode != '' && phonecode != null && homephonenumber.startswith(phonecode)){
            system.debug('inside if 2>>>>');
            l.deltaksrp__home_phone__c = '+'+homephonenumber;
          }
          
          if(phonecode != '' && phonecode != null && !homephonenumber.startswith('+'+phonecode) && !homephonenumber.startswith(phonecode)){
            system.debug('inside if 3>>>>');
            l.deltaksrp__home_phone__c = '+'+phonecode+homephonenumber;
          }
          system.debug('inside if state homephonenumber2>>>>'+l.deltaksrp__home_phone__c);
        }
        
      }
      
    
      if(l.DeltakSRP__Work_Phone__c!= null && (l.country != null || l.state != null)){
        String workphonenumber;
        String phonecode = '';
        
        if(l.DeltakSRP__Work_Phone__c != null)
             workphonenumber = unformatphonenumber(l.DeltakSRP__Work_Phone__c);
            
        
        if(l.country != null && phonecodes.get(l.country.tolowercase())!=null){
          phonecode = phonecodes.get(l.country.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          
          if(phonecode != '' && phonecode != null && workphonenumber.startswith('+'+phonecode)){
            l.DeltakSRP__Work_phone__c = workphonenumber;
          }
            
          if(phonecode != '' && phonecode != null && workphonenumber.startswith(phonecode)){
            l.DeltakSRP__Work_phone__c = '+'+workphonenumber;
          }
          
          system.debug('workphonenumber2>>>>'+workphonenumber);
          system.debug('phonecode2>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && !workphonenumber.startswith('+'+phonecode) && !workphonenumber.startswith(phonecode)){
            l.DeltakSRP__Work_phone__c = '+'+phonecode+workphonenumber;
            system.debug('l.workphone>>>>'+l.DeltakSRP__Work_phone__c);
          }
        }
        
        if(l.country == null && l.state != null && phonecodes.get(l.state.tolowercase())!=null){
          phonecode = phonecodes.get(l.state.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && workphonenumber.startswith('+'+phonecode)){
              l.DeltakSRP__Work_phone__c = workphonenumber;
            }
            
          if(phonecode != '' && phonecode != null && workphonenumber.startswith(phonecode)){
            l.DeltakSRP__Work_phone__c = '+'+workphonenumber;
          }
          
          if(phonecode != '' && phonecode != null && !workphonenumber.startswith('+'+phonecode) && !workphonenumber.startswith(phonecode)){
            l.DeltakSRP__Work_phone__c = '+'+phonecode+workphonenumber;
          }
          
        }
        
      }
      
      if(l.mobilephone != null &&  (l.country != null || l.state != null)){
        String mobilephonenumber;
        
        if(l.mobilephone != null)
          mobilephonenumber = unformatphonenumber(l.mobilephone);
        
        
        if(l.country != null && phonecodes.get(l.country.tolowercase())!=null){
          String phonecode = '';
          phonecode = phonecodes.get(l.country.tolowercase()).phone_code__c;
          system.debug('phonecode>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && mobilephonenumber.startswith('+'+phonecode)){
            l.mobilephone = mobilephonenumber;
          }
          
          if(phonecode != '' && phonecode != null && mobilephonenumber.startswith(phonecode)){
            l.mobilephone = '+'+mobilephonenumber;
          }
          
          system.debug('mobilephonenumber2>>>>'+mobilephonenumber);
          system.debug('phonecode2>>>>'+phonecode);
          if(phonecode != '' && phonecode != null && !mobilephonenumber.startswith('+'+phonecode) && !mobilephonenumber.startswith(phonecode)){
            l.mobilephone = '+'+phonecode+mobilephonenumber;
            system.debug('l.mobilephone>>>>'+l.mobilephone);
          }
          
          
        }  
        
        
        if(l.country == null && l.state != null && phonecodes.get(l.state.tolowercase())!=null){
          String phonecode = '';
          phonecode = phonecodes.get(l.state.tolowercase()).phone_code__c;
           
          if(phonecode != '' && phonecode != null && mobilephonenumber.startswith('+'+phonecode)){
            l.mobilephone = mobilephonenumber;
          }
          
          if(phonecode != '' && phonecode != null && mobilephonenumber.startswith(phonecode)){
            l.mobilephone = '+'+mobilephonenumber;
          }
          
          if(phonecode != '' && phonecode != null && !mobilephonenumber.startswith('+'+phonecode) && !mobilephonenumber.startswith(phonecode)){
            l.mobilephone = '+'+phonecode+mobilephonenumber;
          }
          
        }
        
      }
      system.debug('l>>>>'+l);
      leadsToReturn.add(l);
    }
    
    return leadsToReturn;
    
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
                    deltakSRP__Academic_Institution_Lookup__c,
                    DeltakSRP__Academic_Institution_Lookup__r.Abbreviation__c,
                    deltakSRP__Contact__r.RecordType.Name,
                    deltakSRP__Contact__r.AccountId,
                    deltakSRP__Send_Email_On_Convert__c,
                    RFI_Campaign_Code__c,
                    DeltakSRP__Inquiry_Rating__c,
                    SRP_Retain_Ownership__c,
                    LeadSource,
                    DeltakSRP__Academic_Institution_ID__c,
                    DeltakSRP__AcademicInstitution__c,
                    PPI_Lead_ID__c 
                 From 
                    Lead 
                 Where 
                    Id in :goodLeadMap.keySet()];
                    
            //handleEventRegistration(goodLeads,null);
        }
        
        system.debug('goodleads>>>>'+goodleads);
         
        List<Opportunity> activePartialDuplicateOpportunities = new List<Opportunity> ();
        activePartialDuplicateOpportunities = getActivePartialDuplicates(goodLeads);
        
        List<Opportunity> dormantPartialDuplicateOpportunities = new List<Opportunity> ();
        dormantPartialDuplicateOpportunities = getDormantPartialDuplicates(goodLeads);
        
        List<Opportunity> activeNonPartialDuplicateOpportunities = new List<Opportunity> ();
        activeNonPartialDuplicateOpportunities = getActiveNonPartialDuplicates(goodLeads);
        
        List<Opportunity> dormantNonPartialDuplicateOpportunities = new List<Opportunity> ();
        dormantNonPartialDuplicateOpportunities = getDormantNonPartialDuplicates(goodLeads);
 
        List<Opportunity> differentPartnerPartialDuplicateOpportunities = new List<Opportunity>();
        differentPartnerPartialDuplicateOpportunities = getDifferentPartnerOpportunities(goodleads);
        
        
        // Girija: added logic to support SRP-1595: Lead response web-to-lead for PPI Vendors  
        List<DeltakSRP__Error_Log__c> logList = new List<DeltakSRP__Error_Log__c>();  
        Map<id, String> accountMap = new Map<Id, String>();
        List<Account> acctDetails = [Select id, name from Account];
        for(Account acc : acctDetails)
        { 
            accountMap.put(acc.id,acc.name);
        }            
        Set<id> accountMapKey = new Set<Id>();
        accountMapKey = accountMap.keySet(); 
        RecordType rt = [Select  r.Id, Name From RecordType r where r.SobjectType = 'DeltakSRP__Error_Log__c' and Name='Lead Response' LIMIT 1]; 
        system.debug('recType>>>'+rt);
        List<PPI_Vendor_Details__c> ppi = [Select p.Vendor_Email__c, p.Campaign_Name__c,p.Account_Id__c From PPI_Vendor_Details__c p];
        Map<String, String> ppiCampaignToEmail = new Map<String, String>();
        for(PPI_Vendor_Details__c pv : ppi)
        {
            ppiCampaignToEmail.put(pv.Account_Id__c+pv.Campaign_Name__c,pv.Vendor_Email__c);
        }        
        
        system.debug('ppiCampaignToEmail-->>'+ppiCampaignToEmail);    
                
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
                        SRPLeadConvertHelper.convertlead(current, Label.Opportunity_Dormant_Stage_Name,Label.Opportunity_Dormant_SubStage_Name,existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
       
            for(Opportunity existingopp : dormantPartialDuplicateOpportunities){
                    if(isPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant Partial Duplicate Lead>>>>');
                        SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name, '', existingopp);
                        break;  
                        //send duplicate/dormant email notification
                    }
            }  
 
            for(Opportunity existingopp : activeNonPartialDuplicateOpportunities){
                    if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Active non-Partial Duplicate Lead');
                        SRPLeadConvertHelper.convertlead(current, Label.Opportunity_Dormant_Stage_Name,Label.Opportunity_Dormant_SubStage_Name,existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
        
            for(Opportunity existingopp : dormantNonPartialDuplicateOpportunities){
                    if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant non-Partial Duplicate Lead');
                        SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            for(Opportunity existingopp : differentPartnerPartialDuplicateOpportunities){
                    if(isPartialDuplicateDiffPartner(current,existingopp)){
                        duplicatefound = true;
                        system.debug('different Partner partial duplicate');
                        SRPLeadConvertHelper.convertlead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',existingopp);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            system.debug('duplicate found>>>>'+duplicatefound);
                if(duplicatefound==false){
                    //throw new SRMException(' new lead!!!');
                    SRPLeadConvertHelper.convertLead(current, Label.Opportunity_New_Inquiry_Stage_Name,'',null);
                }
                
            // Girija : added for the purpose of SRP:1595- Lead response web-to-lead for PPI Vendors            
            system.debug('deltakSRP__Contact__r.RecordType.Name>>>>'+current.deltakSRP__Contact__r.RecordType.Name);
            system.debug('accountId>>>'+current.DeltakSRP__Academic_Institution_ID__c);      
            system.debug('deltakSRP__Contact__r.AccountId>>>'+current.deltakSRP__Contact__r.AccountId);
            DeltakSRP__Error_Log__c lg = new DeltakSRP__Error_Log__c();                         
            for(id acId : accountMapKey)
            {
                system.debug('current.DeltakSRP__AcademicInstitution__c--->>>'+current.DeltakSRP__AcademicInstitution__c);
                system.debug('accountMap.get(acId)--->>>'+accountMap.get(acId));
                if(current.DeltakSRP__AcademicInstitution__c == accountMap.get(acId))
                {
                    lg.Lead_Account_Id__c = acId; 
                    system.debug('lead acct--->>>'+lg.Lead_Account_Id__c);
                }
            } 
            
            lg.Lead_First_Name__c = current.firstname;
            lg.Lead_Last_Name__c = current.lastname;
            lg.Campaign_Code__c = current.RFI_Campaign_Code__c;
            system.debug('lg.Campaign_Code__c--->>>'+lg.Campaign_Code__c);
            lg.Lead_Id__c = current.id;
            system.debug('current.RFI_Campaign_Code__c--->>>'+(current.DeltakSRP__AcademicInstitution__c+current.RFI_Campaign_Code__c));
            lg.Vendor_Email__c =  ppiCampaignToEmail.get(current.DeltakSRP__AcademicInstitution__c+current.RFI_Campaign_Code__c);   
            lg.RecordTypeId = rt.id;
            lg.Lead_Id_PPI__c = current.PPI_Lead_ID__c;
            system.debug('lg.Vendor_Email__c--->>>'+lg.Vendor_Email__c);            
            system.debug('log--->>>'+lg);
            logList.add(lg);
                
        }       
         
         if(logList != null && logList.size() > 0)
            insert logList;      
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
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive, DeltakSRP__Student__r.Email from Opportunity where
                    (DeltakSRP__Student__r.Email in :leadEmails 
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
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive, DeltakSRP__Student__r.Email from Opportunity where
                    (DeltakSRP__Student__r.Email in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    And DeltakSRP__academic_program__c  not in :leadAcademicPrograms
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
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive, DeltakSRP__Student__r.Email from Opportunity where
                    (DeltakSRP__Student__r.Email in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    And DeltakSRP__academic_program__c not in :leadAcademicPrograms
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
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive, DeltakSRP__Student__r.Email from Opportunity where
                    (DeltakSRP__Student__r.Email in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    And DeltakSRP__academic_program__c in :leadAcademicPrograms
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
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, owner.isactive,DeltakSRP__Student__r.Email from Opportunity where
                    (deltaksrp__Email__c in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.FirstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
                    And DeltakSRP__academic_program__c not in :leadAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And AccountId    in :academicInstitutions
                    And stagename != :Label.Opportunity_Dormant_Stage_Name
                    //And StageName in (:Label.Opportunity_Active_StageName_1, :Label.Opportunity_Active_StageName_2, :Label.Opportunity_Active_StageName_3, :Label.Opportunity_Active_StageName_4, :Label.Opportunity_Active_StageName_5,
                      //      :Label.Opportunity_Active_StageName_6, :Label.Opportunity_Active_StageName_7, :Label.Opportunity_Active_StageName_8, :Label.Opportunity_Active_StageName_9, :Label.Opportunity_Active_StageName_10, :Label.Opportunity_Active_StageName_11)
                    ];
                    
        system.debug('activepartialduplicates>>>>'+existingopportunities);
                    
        return existingOpportunities;
    } 
    
    /**
     *
     * If the new Lead matches any of the following fields of an existing
     * Lead, the new Lead will not be created in SRP.
     *
     * (Email OR Phone) AND Name AND Program AND Lead Source
     * which is equivalent to
     * (Email AND Name AND Program AND LeadSource)
     * OR (Phone AND Name AND Program AND LeadSource)
     *
     * Updated/changed information in a de-duplicated Lead will be merged
     * to the existing Lead
     *
     * @param: leads    the inserted leads
     * @return void
     */
    public static void onBeforeInsert(List<Lead> leads) {
        Set<String> leadEmails           = new Set<String>();
        Set<String> leadPhones           = new Set<String>();       
        Set<String> leadLastNames        = new Set<String>();
        Set<String> leadAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> leadFirstNames       = new Set<String>();
        Set<String> leadAcademicPrgFromRFI = new Set<String>();
        Set<String> academicInstitutions     = new Set<String>();
        List<Lead> srpLeads              = new List<Lead>();
        Map<Lead,Contact> leadContactMap = new Map<Lead,Contact>();
        Map<String,Lead> leadMap = new Map<String, Lead>();
        Map<String,Contact> contactMap = new Map<String, Contact>();
        Map<Id,Lead> duplicateLeads = new Map<Id,Lead>();
       
        // Get RecordType and Partner Account defaults
        DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        Id profileId = UserInfo.getProfileId();
        
         //Build a Map of existing Accounts
         // SRP-1618 - Added Goldmine_Key5__c and accountKey5Map - Expect Goldmine to Key5 Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
        List<Account> partnerAccounts = [Select Name, Goldmine_Key5__c From Account Where RecordType.Name='SRP Academic Institution'];
        Map<String,Id> accountNameMap = new Map<String,Id>();
        Map<String,Id> accountKey5Map = new Map<String,Id>();
        for(Account accountRecord : partnerAccounts){
            accountNameMap.put(accountRecord.Name, accountRecord.Id);
            if(accountRecord.Goldmine_Key5__c!=null &&accountRecord.Goldmine_Key5__c!='' )
            accountKey5Map.put(accountRecord.Goldmine_Key5__c, accountRecord.Id);
        }
        // SRP-1618 - Added Goldmine_Key5__c and accountKey5Map - Expect Goldmine to Key5 Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
        for (Lead newLead : leads) {
            system.debug('new lead>>>>'+newlead);
                
                // SRP-1618 - Added accountKey5Map - Expect Goldmine to Key5 Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
                newLead.DeltakSRP__Academic_Institution_Lookup__c =getAccountId(newLead,accountNameMap,accountKey5Map,settings,profileId); 
                // SRP-1618 - Added accountKey5Map - Expect Goldmine to Key5 Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
                if(newLead.DeltakSRP__Academic_Institution_Lookup__c != null)
                    academicInstitutions.add(string.valueof(newLead.DeltakSRP__Academic_Institution_Lookup__c).substring(0,15));
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
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                leadFirstNames.add(newLead.FirstName);
                leadAcademicPrgFromRFI.add(newLead.DeltakSRP__AcademicProgram__c);
                srpLeads.add(newLead);   
        }
        
        List<RFI_to_Academic_Programs_Code__c> rtapc = new List<RFI_to_Academic_Programs_Code__c>();
        rtapc = [Select ID, Program_Code__c, Academic_Program__c, Academic_Specialization__c from RFI_to_Academic_Programs_Code__c where Program_Code__c in: leadAcademicPrgFromRFI and Organization_Id__c in: academicInstitutions];
        
        Map<String, Id> codeToProgramMap = new Map<String, Id>();
        Map<String, Id> codeToSpecializationMap = new Map<String, Id>();
        
        if(rtapc.size()>0){
            for(RFI_to_Academic_Programs_Code__c r: rtapc){
                if(r.Academic_Program__c != null)
                    codeToProgramMap.put(r.Program_Code__c, r.Academic_Program__c);
                
                if(r.Academic_Specialization__c != null)    
                    codeToSpecializationMap.put(r.Program_Code__c, r.Academic_Specialization__c);
            }
        }
        
        for(Lead current : srpLeads){
            if(codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c) != null && codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c) != null)
                current.DeltakSRP__academic_program_lookup__c = codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c);
             else
                current.SRP_Other_Program_Information__c = current.DeltakSRP__AcademicProgram__c; 
                
            if(codeToSpecializationMap.get(current.DeltakSRP__AcademicProgram__c) != null && codeToSpecializationMap.get(current.DeltakSRP__AcademicProgram__c) != null)  
                current.DeltakSRP__Academic_Specialization_Lookup__c = codeToSpecializationMap.get(current.DeltakSRP__AcademicProgram__c);
            
            leadAcademicPrograms.add(current.DeltakSRP__Academic_Program_Lookup__c);
            system.debug('current.SRP_Other_Program_Information__c>>>>'+current.SRP_Other_Program_Information__c);
        }
        
        system.debug('leademails>>>>'+leademails);
        system.debug(LoggingLevel.INFO, 'leadPhones>>>>'+leadPhones);
        system.debug('leadFirstNames>>>>'+leadFirstNames);
        system.debug('leadLastNames>>>>'+leadLastNames);
        system.debug('leadAcademicPrograms>>>>'+leadAcademicPrograms);
        //system.debug('leadSources>>>>'+leadSources);
        system.debug('academicInstitutions>>>>'+academicInstitutions);
        
       // SRP-1617 - Expose New Text Field to get SMS_Ok_To_Text values from SRM Partners converted to SRP - VR
        for(Lead current : srpLeads){
            if(current.SMS_Ok_To_Text_Incoming__c != null && (String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='1' || String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='true' || String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='yes'))
            {
                current.DeltakSRPSMS__Ok_To_Text__c = true;
            }
               
            if(current.SMS_Ok_To_Text_Incoming__c != null && (String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='0' || String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='false' || String.valueOf(current.SMS_Ok_To_Text_Incoming__c).toLowerCase()=='no'))
            {
                current.DeltakSRPSMS__Ok_To_Text__c = false;
            }
            
            system.debug('current.SMS_Ok_To_Text_Incoming__c>>>>'+current.SMS_Ok_To_Text_Incoming__c);
            system.debug('current.DeltakSRPSMS__Ok_To_Text__c>>>>'+current.DeltakSRPSMS__Ok_To_Text__c);
            // SRP-1746 - Expose New Text Fields to get DoNotCall and HasOptedOutOfEmail values from SRM Partners converted to SRP - VR
            if(current.DoNotCall_Incoming__c != null && (String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='1' || String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='true' || String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='yes'))
            {
                current.DoNotCall = true;
            }
               
            if(current.DoNotCall_Incoming__c != null && (String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='0' || String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='false' || String.valueOf(current.DoNotCall_Incoming__c).toLowerCase()=='no'))
            {
                current.DoNotCall = false;
            }
            
            system.debug('current.DoNotCall_Incoming__c>>>>'+current.SMS_Ok_To_Text_Incoming__c);
            system.debug('current.DoNotCall>>>>'+current.DeltakSRPSMS__Ok_To_Text__c);
            
            if(current.HasOptedOutOfEmail_Incoming__c != null && (String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='1' || String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='true' || String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='yes'))
            {
                current.HasOptedOutOfEmail = true;
            }
               
            if(current.HasOptedOutOfEmail_Incoming__c != null && (String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='0' || String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='false' || String.valueOf(current.HasOptedOutOfEmail_Incoming__c).toLowerCase()=='no'))
            {
                current.HasOptedOutOfEmail = false;
            }
            
            system.debug('current.HasOptedOutOfEmail_Incoming__c>>>>'+current.SMS_Ok_To_Text_Incoming__c);
            system.debug('current.HasOptedOutOfEmail>>>>'+current.DeltakSRPSMS__Ok_To_Text__c);
            // SRP-1746 - Expose New Text Fields to get DoNotCall and HasOptedOutOfEmail values from SRM Partners converted to SRP - VR
        }
        // SRP-1617 - Expose New Text Field to get SMS_Ok_To_Text values from SRM Partners converted to SRP - VR         
           
        //Get all matching, existing opportunities to check for duplicates
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c,DeltakSRP__webschedulerstatus__c, DeltakSRP__Student__r.Email from Opportunity where
                    (DeltakSRP__Student__r.Email in :leadEmails 
                    or DeltakSRP__Student__r.mobilephone in :leadPhones 
                    or DeltakSRP__Student__r.homephone in:leadPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:leadPhones)
                    And DeltakSRP__Student__r.firstName in :leadFirstNames
                    And DeltakSRP__Student__r.LastName in :leadLastNames
//                    And DeltakSRP__Lead_Source_ID__c in :leadSources
                    And AccountId    in :academicInstitutions
                    And DeltakSRP__Academic_Program__c in :leadAcademicPrograms and isdeleted = false
                    And stagename != :Label.Opportunity_Dormant_Stage_Name
                   ];
  
         system.debug('existing opportunities total duplicates in lead trigger>>>>'+existingopportunities);
       
        //Get all matching existing contacts
        List<Contact> matchingContacts = 
            [Select 
                AccountId,
                Email,
                Phone,
                MobilePhone,
                FirstName,
                LastName,
                DeltakSRP__Work_Email__c,
                DeltakSRP__Work_Phone__c,
                DeltakSRP__Student_Email__c,
                Student_Email__c,
                HomePhone,
                Work_Phone__c
             From 
                Contact
             Where
                (Email in :leadEmails 
                    Or DeltakSRP__Work_Email__c in :leadEmails
                    Or DeltakSRP__Student_Email__c in :leadEmails
                    Or Phone in :leadPhones 
                    Or MobilePhone in :leadPhones 
                    Or HomePhone in :leadPhones 
                    Or DeltakSRP__Work_Phone__c in :leadPhones)
                And FirstName in :leadFirstNames
                And LastName in :leadLastNames
                And AccountId in :academicInstitutions];        
        
        system.debug('matchingcontacts>>>>'+matchingcontacts);
        
        List<Opportunity> oppAppListToUpdate = new List<Opportunity>();
        
        for(Lead current : srpLeads){
              system.debug('current>>>>'+current);
                //Search for duplicates if this is not part of an upsert operation (e.g. integration)
                //Where the dupe check has already been done
                 current.DeltakSRP__Is_Duplicate__c = false;
                 if(current.DeltakSRP__External_Id__c == null){
                    for(Opportunity existingopp : existingOpportunities){
                        if(isDuplicate(current,existingopp)){
                            system.debug('found duplicate>>>>');
                            current.DeltakSRP__Is_Duplicate__c = true;
                            if(current.DeltakSRP__WebScheduler_Status__c == 'New')
                            {
                              existingopp.DeltakSRP__webschedulerstatus__c = ''; //FS
                              oppAppListToUpdate.add(existingopp); //FS
                            }
                        }else{
                            system.debug('duplicate not found>>>>');
                        }
                    }
                 }    
                //Dont check for contacts if this lead already has one associated (e.g. integration)
                if(current.DeltakSRP__Contact__c == null){
                    Contact matchingContact = null;
                    for(Contact c : matchingContacts){
                        if(isDuplicate(current,c)){
                            matchingContact = c; 
                        } 
                    }
                    
                     system.debug('matchingcontact>>>>'+matchingcontact);
                     
                    leadContactMap.put(
                        current,
                        getContactInfo(current,matchingContact,settings.DeltakSRP__Contact_Record_Type_Id__c)
                    );
                    
                    leadMap.put(current.firstName+current.lastname+current.email, current);
                    
                    if(matchingcontact != null)
                      contactMap.put(current.firstName+current.lastname+current.email, matchingContact);
                }
                
            //}catch(SRPException e){}
        }
        
        
        List<Contact> clist = new List<Contact>();
        
        for(Lead current : srpLeads){
          Contact c = leadContactMap.get(current);
          if(c!= null && c.id==null)
            clist.add(c);
        }
        
        Set<Contact> uniqueContacts = new Set<Contact>();
        for(Contact c : clist){ 
            if(c != null){         
              uniqueContacts.add(c);
            }
        }
        clist.clear();
        clist.addAll(uniqueContacts); 
        
        if(clist.size()>0)
          insert clist;
        
        for(Contact c: clist){
          contactMap.put(c.firstname+c.lastname+c.email, c);
        }  
        
        // Create a deduplicated list of Contact records starting with
        //  the List of Contacts in the Lead, Contact map
       
        
        //Database.update(duplicateLeads.values(),false);  
        
        //Solution for Case # 69800 Web Appointment Schedule from RFI with existing opportunity
        //update Opps -FS Start
        if(!oppAppListToUpdate.isEmpty())
        {
          update oppAppListToUpdate;
          
          for(Opportunity opp1 : oppAppListToUpdate)
          {
            opp1.DeltakSRP__webschedulerstatus__c = 'New';
          }
          
          update oppAppListToUpdate;
        } //FS END
        
       
        
        if(contactMap != null && Contactmap.values().size()>0){
          for(Lead l : srpleads){
            Contact c = contactMap.get(l.firstname+l.lastname+l.email);
            if(c!=null)
              l.DeltakSRP__Contact__c = c.Id;
            
            system.debug('l.DeltakSRP__Contact__c>>>>'+l.DeltakSRP__Contact__c);  
          }
          
             //leads[0].DeltakSRP__Contact__c = contacts[0].Id;
        }       
        
        /*for(Lead l : leads){
          Contact c = leadContactMap.get(l);
          if(c != null){
            l.DeltakSRP__Contact__c = c.Id;
          }
        } */
    }    
 

    
    /**
     *
     * instantiates a new Contact for a Lead
     *
     * @param: lead    the lead
     * @return an instance of a Contact for the Lead
     */
    
    private static Contact getContactInfo(Lead lead,Contact contact,Id recTypeId) {
        // If the Lead record in question needs a Contact created
        if(rectypeid == null)
          rectypeid = '012J00000000LczIAE';
        if(contact == null){
            contact = new Contact(
                FirstName    = lead.FirstName,
                LastName     = lead.LastName,
                Email        = lead.Email,
                Phone        = lead.Phone,
                MobilePhone  = lead.MobilePhone,
                DeltakSRP__Work_Phone__c= lead.DeltakSRP__Work_Phone__c,
                HomePhone    = lead.DeltakSRP__Home_Phone__c,
                RecordTypeId = rectypeid,
                AccountId    = lead.DeltakSRP__Academic_Institution_Lookup__c,
                DeltakSRP__Employer_Company__c = lead.company,
                DeltakSRPSMS__Ok_To_Text__c = lead.DeltakSRPSMS__Ok_To_Text__c,
                HasOptedOutOfEmail = lead.HasOptedOutOfEmail,
                donotcall = lead.DoNotCall,
                LeadSource = lead.LeadSource
               // DeltakSRP__Preferred_Phone__c = 'Home'
             ); 
             
            if(contact.DeltakSRP__Work_Phone__c != null) contact.DeltakSRP__Preferred_Phone__c = 'Work';
          if(contact.MobilePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Mobile';
          if(contact.HomePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Home';
               
             system.debug('created new contact>>>>'+contact); 
        }        
        return contact;
    }
    /**
     * @description returns boolean val true if current is a duplicate of existing.  Otherwise, returns false.
     */
    
    /*private static boolean isDuplicate(Lead current, Lead existing){
        return 
            isDuplicateWithoutRegCode(current,existing)  &&
            current.DeltakSRP__Event_Registration_Code__c == existing.DeltakSRP__Event_Registration_Code__c &&
           // current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c && 
            current.DeltakSRP__Academic_Program_Lookup__c == existing.DeltakSRP__Academic_Program_Lookup__c &&
            current.DeltakSRP__Academic_Institution_Lookup__c == existing.DeltakSRP__Academic_Institution_Lookup__c; 
    }*/
    
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
    
    private static boolean isDuplicate(Lead current, Opportunity existing){
        return
        isDuplicateWithoutRegCode(current,existing)  &&
            //current.DeltakSRP__Event_Registration_Code__c == existing.DeltakSRP__Event__r.DeltakSRP__Registration_Code__c &&
        //    current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c && 
            current.DeltakSRP__Academic_Program_Lookup__c == existing.DeltakSRP__Academic_Program__c &&
            current.DeltakSRP__Academic_Institution_Lookup__c == existing.AccountId; 
    }
    
  /* public static String formattedphone(String pnumber){
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
    } */
    
    public static String unformatphonenumber(String pnumber){
      
      if(pnumber == null)
        return null;
      String phonenumber = pnumber;
      phonenumber = phonenumber.replace('-','');
      phonenumber = phonenumber.replace('.','');
      phonenumber=phonenumber.replace(')','');
      phonenumber=phonenumber.replace('(','');
      phonenumber=phonenumber.replace(' ','');
      phonenumber=phonenumber.replace('x','');
      phonenumber=phonenumber.replace('+','');
      system.debug('phonenumber>>>>'+phonenumber);
    phonenumber.trim();
    
    while(phonenumber.startswith('0')){
      phonenumber = phonenumber.substring(1, phonenumber.length());
      system.debug('inside removing the leading 0>>>>'+phonenumber);
    }
    
      return phonenumber;  
    }
    
   /* private static boolean isDuplicateWithoutRegCode(Lead current,Opportunity existing){
          return 
            ((current.Phone != null && (unformattedPhone(current.Phone) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.Phone) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.Phone) == unformattedPhone(existing.deltaksrp__student__r.DeltakSRP__Work_Phone__c)))  
            || (current.MobilePhone != null && (unformattedPhone(current.MobilePhone) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.MobilePhone) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.MobilePhone) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.DeltakSRP__Home_Phone__c != null && (unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.DeltakSRP__Work_Phone__c != null && (unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.Email != null && current.Email == existing.deltaksrp__Email__c)) &&
          current.FirstName == existing.DeltakSRP__Student__r.FirstName &&
          current.LastName == existing.DeltakSRP__Student__r.LastName; 
    }*/
    private static boolean isDuplicateWithoutRegCode(Lead current,Opportunity existing){
          return 
            (current.Phone != null && (current.Phone == existing.deltaksrp__student__r.mobilephone || current.Phone == existing.DeltakSRP__student__r.homephone || current.Phone == existing.deltaksrp__student__r.DeltakSRP__Work_Phone__c))  
            || (current.MobilePhone != null && (current.MobilePhone == existing.deltaksrp__student__r.mobilephone || current.MobilePhone == existing.DeltakSRP__student__r.homephone || current.MobilePhone == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.deltaksrp__student__r.mobilephone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__student__r.homephone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.deltaksrp__student__r.mobilephone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__student__r.homephone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c))
            || (current.Email != null && (current.Email == existing.deltaksrp__student__r.Email)) &&
          current.FirstName == existing.DeltakSRP__Student__r.FirstName &&
          current.LastName == existing.DeltakSRP__Student__r.LastName; 
    }
    
    /*private static boolean isDuplicateWithoutRegCode(Lead current,Opportunity existing){
          return 
            ((current.Phone != null && (unformattedPhone(current.Phone) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.Phone) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.Phone) == unformattedPhone(existing.deltaksrp__student__r.DeltakSRP__Work_Phone__c)))  
            || (current.MobilePhone != null && (unformattedPhone(current.MobilePhone) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.MobilePhone) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.MobilePhone) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.DeltakSRP__Home_Phone__c != null && (unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.DeltakSRP__Home_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.DeltakSRP__Work_Phone__c != null && (unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.deltaksrp__student__r.mobilephone) || unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.homephone) || unformattedPhone(current.DeltakSRP__Work_Phone__c) == unformattedPhone(existing.DeltakSRP__student__r.deltaksrp__Work_Phone__c)))
            || (current.Email != null && current.Email == existing.deltaksrp__Email__c)) &&
          current.FirstName == existing.DeltakSRP__Student__r.FirstName &&
          current.LastName == existing.DeltakSRP__Student__r.LastName; 
    }*/
    
    /*private static boolean isDuplicateWithoutRegCode(Lead current,Lead existing){
        return 
          ((current.Phone != null && (unformattedPhone(current.Phone) == existing.Phone || current.Phone == existing.MobilePhone || current.Phone == existing.DeltakSRP__Home_Phone__c || current.Phone == existing.DeltakSRP__Work_Phone__c))  
            || (current.MobilePhone != null && (current.MobilePhone == existing.Phone || current.MobilePhone == existing.MobilePhone || current.MobilePhone == existing.DeltakSRP__Home_Phone__c || current.MobilePhone == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.Phone || current.DeltakSRP__Home_Phone__c == existing.MobilePhone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Home_Phone__c || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.Phone || current.DeltakSRP__Work_Phone__c == existing.MobilePhone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Home_Phone__c || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.Email != null && current.Email == existing.Email)) &&
          current.FirstName == existing.FirstName &&
          current.LastName == existing.LastName; 
    }*/

    /**
     * @description returns boolean val true if current is a duplicate of existing.  Otherwise, returns false.
     */
    
      private static boolean isDuplicate(Lead current, Contact existing){
        system.debug('current.Phone>>>>'+current.Phone);
        system.debug('existing.Phone>>>>'+existing.Phone);
        system.debug('current.MobilePhone>>>>'+current.MobilePhone);
        system.debug('existing.MobilePhone>>>>'+existing.MobilePhone);
        system.debug('current.DeltakSRP__Home_Phone__c>>>>'+current.DeltakSRP__Home_Phone__c);
        system.debug('existing.homePhone>>>>'+existing.homePhone);
        system.debug('current.FirstName>>>>'+current.FirstName);
        system.debug('existing.FirstName>>>>'+existing.FirstName);
        system.debug('current.LastName>>>>'+current.LastName);
        system.debug('existing.LastName>>>>'+existing.LastName);
        system.debug('current.DeltakSRP__Academic_Institution_Lookup__c>>>>'+ current.DeltakSRP__Academic_Institution_Lookup__c);
        system.debug('existing.AccountId>>>>'+existing.AccountId);
        
        
        
        
        Boolean returnvalue =   current.FirstName == existing.FirstName &&
          current.LastName == existing.LastName &&
          current.DeltakSRP__Academic_Institution_Lookup__c == existing.AccountId && (  
          (current.Phone != null && (current.Phone == existing.Phone || current.Phone == existing.MobilePhone || current.Phone == existing.HomePhone || current.Phone == existing.DeltakSRP__Work_Phone__c)) 
            || (current.MobilePhone != null && (current.MobilePhone ==existing.Phone) || (current.MobilePhone == existing.MobilePhone) || (current.MobilePhone == existing.HomePhone) || (current.MobilePhone == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.Phone) || (current.DeltakSRP__Home_Phone__c == existing.MobilePhone) || (current.DeltakSRP__Home_Phone__c == existing.HomePhone) || (current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.Phone) || (current.DeltakSRP__Work_Phone__c == existing.MobilePhone) || (current.DeltakSRP__Work_Phone__c == existing.HomePhone) || (current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.Email != null && (current.Email == existing.Email || current.Email == existing.DeltakSRP__Work_Email__c || current.Email == existing.DeltakSRP__Student_Email__c )));
       
       system.debug('returnvalue>>>>'+returnvalue);
       return returnvalue;
          
    }  
    
    private static boolean isSRPLead(Lead l,Id recordTypeId){
      return l.DeltakSRP__Is_Srp_Record__c || l.RecordTypeId == recordTypeId;
    }
    
    /*private static void handleEventRegistration(List<Lead> leads,Map<Id,Lead> oldLeadMap){
        Map<String,List<Lead>> regCodeMap = new Map<String,List<Lead>>();
        for(Lead l : leads){
            if(l.DeltakSRP__Event_Registration_Code__c != null && 
                (oldLeadMap == null || 
                    oldLeadMap.get(l.Id).DeltakSRP__Event_Registration_Code__c != l.DeltakSRP__Event_Registration_Code__c ||
                    oldLeadMap.get(l.Id).DeltakSRP__Duplicate_Lead_Count__c != l.DeltakSRP__Duplicate_Lead_Count__c)){
                List<Lead> leadList = regCodeMap.get(l.DeltakSRP__Event_Registration_Code__c);
                if(leadList == null){
                    leadList = new List<Lead>();
                    regCodeMap.put(l.DeltakSRP__Event_Registration_Code__c,leadList);
                }
                leadList.add(l);
            }
        }
            
        Map<Id,Lead> leadsToUpdate = new Map<Id,Lead>();
        List<DeltakSRP__Event_Member__c> membersToUpsert = new List<DeltakSRP__Event_Member__c>();
        Map<Id,Lead> leadsToDelete = new Map<Id,Lead>();
        boolean foundDupe = false;
        for(DeltakSRP__Event__c e : 
            [Select 
                Id,
                DeltakSRP__Registration_Code__c,
                DeltakSRP__Private_Event__c,
                (Select 
                    DeltakSRP__Contact__c,
                    DeltakSRP__Lead__r.FirstName,
                    DeltakSRP__Lead__r.LastName,
                    DeltakSRP__Lead__r.DeltakSRP__Lead_Source_ID__c,
                    DeltakSRP__Lead__r.DeltakSRP__Academic_Program_Lookup__c,
                    DeltakSRP__Lead__r.Phone,DeltakSRP__Lead__r.MobilePhone,
                    DeltakSRP__Lead__r.DeltakSRP__Work_Phone__c,
                    DeltakSRP__Lead__r.DeltakSRP__Home_Phone__c,DeltakSRP__Lead__r.Email,
                    DeltakSRP__Registered__c 
                 From 
                    DeltakSRP__Event_Members__r) 
             From 
                 DeltakSRP__Event__c 
             Where 
                 DeltakSRP__Registration_Code__c in :regCodeMap.keySet()]){
            for(Lead l : regCodeMap.get(e.DeltakSRP__Registration_Code__c)){
                leadsToUpdate.put(l.Id,l);
                l.DeltakSRP__Is_Denied_Registration__c = false;
                l.DeltakSRP__Event__c=e.Id;
                foundDupe=false;
                for(DeltakSRP__Event_Member__c m : e.DeltakSRP__Event_Members__r)
                {
                    //Simple ID check for lead is out of the question if
                    //A lead is manually entered without an Event Registration Code
                    //In that case, we use the same dedupe logic w/out the Event Registration Code check
                    if(l.DeltakSRP__Contact__c == m.DeltakSRP__Contact__c || (m.DeltakSRP__Lead__c != null && isDuplicateWithoutRegCode(l,m.DeltakSRP__Lead__r))){
                        m.DeltakSRP__Registered__c = true;
                        membersToUpsert.add(m);
                        foundDupe=true;
                        
                        //Delete NEW leads only if they came in just for the sake
                        //of registration and an existing match was found.
                        if(oldLeadMap == null || oldLeadMap.isEmpty()){
                            leadsToDelete.put(l.Id,l);
                        }
                    }
                }
                 
                if(!foundDupe){
                    if(!e.DeltakSRP__Private_Event__c){
                        DeltakSRP__Event_Member__c member = new DeltakSRP__Event_Member__c(DeltakSRP__Event__c=e.Id,DeltakSRP__Registered__c=true);
                        if(l.DeltakSRP__Contact__c != null){
                            member.DeltakSRP__Contact__c = l.DeltakSRP__Contact__c;
                        }else{
                            member.DeltakSRP__Lead__c = l.Id;
                        }
                        membersToUpsert.add(member);
                    }else{
                        l.DeltakSRP__Is_Denied_Registration__c=true;
                    }
                }
            }
        }
        
        upsert membersToUpsert id;
        Database.update(leadsToUpdate.values(),false);
        Database.delete(leadsToDelete.values(),false);
    }*/
    
    /*
     * Get the account (academic institution) for the given lead.
     * If the lead has an existing institution, it does not change..
     * If there is only one academic institution in SFDC, then that is used.
     * Otherise, if the academic instituion can be  inferred from the academicinstituion picklist, then that is used.
     * Lastly, if none of these criteria are met, then the lead is defaulted to the value in SRP Partner Settings
     */
    private static Id getAccountId(Lead current,Map<String,Id> accountMap,Map<String,Id> accountKey5Map,DeltakSRP__SRP_Partner_Settings__c settings, Id profileId){
        
        // SRP-1618 - Added Logic to lookup Id in accountKey5Map - Expecting Goldmine_Key5__c Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
        system.debug('accountKey5Map>>>>'+accountKey5Map);
        if(current.DeltakSRP__AcademicInstitution__c != null && accountKey5Map!=null && accountKey5Map.size()>0 && accountKey5Map.get(current.DeltakSRP__AcademicInstitution__c)!=null)
          return accountKey5Map.get(current.DeltakSRP__AcademicInstitution__c);
        // SRP-1618 - Added Logic to lookup Id in accountKey5Map - Expecting Goldmine_Key5__c Value in AcademicInstitution Lookup field from SRM Partners converted to SRP - VR
        
        system.debug('accountMap>>>>'+accountMap);
        if(current.DeltakSRP__Academic_Institution_Lookup__c != null || (settings.DeltakSRP__SRP_Integration_Profile_Id__c != null && profileId == settings.DeltakSRP__SRP_Integration_Profile_Id__c))
            return current.DeltakSRP__Academic_Institution_Lookup__c;
        
        system.debug('after 1st if>>>>');    
        if(accountMap.values().size()>=1){   
            if(accountMap.values().size()==1)
                return accountMap.values().get(0);
            
            system.debug('inside 2nd if after 1st if>>>>');
            system.debug('current.DeltakSRP__AcademicInstitution__c>>>>'+current.DeltakSRP__AcademicInstitution__c); 
            if(current.DeltakSRP__AcademicInstitution__c != null && accountMap.get(current.DeltakSRP__AcademicInstitution__c)!=null)
                return accountMap.get(current.DeltakSRP__AcademicInstitution__c);
        }
        system.debug('after 2nd if>>>>'); 
        return settings.DeltakSRP__Partner_Account_Id__c;
    }
    
    public Static Boolean isDuplicateLead(Lead l, Set<Lead> leadset){
      for(Lead le: leadSet){
        if(l.FirstName == le.firstname &&
          l.LastName == le.lastname &&
          (l.email == le.email ||
          (l.phone == le.phone || l.DeltakSRP__Home_Phone__c == le.DeltakSRP__Home_Phone__c || l.DeltakSRP__Work_Phone__c == le.DeltakSRP__Work_Phone__c || l.MobilePhone == le.MobilePhone))&&
          l.DeltakSRP__Academic_Institution_Lookup__c == le.DeltakSRP__Academic_Institution_Lookup__c &&
          (l.DeltakSRP__Academic_Program_Lookup__c == le.DeltakSRP__Academic_Program_Lookup__c || 
          l.DeltakSRP__AcademicProgram__c == le.deltakSRP__AcademicProgram__c)){
          return true;
        }  
      }
      return false;
    }
    
    /**
     * Handle lead conversion on before update
     * Reason it's before update instead of after..
     * Lead convert seemingly removes relationships (account in our case)
     * after lead conversion.
     */
   /* public static void handleConversion(Map<Id,Lead> oldMap){
        List<DeltakSRP__Lead_Conversion_Record__c> lcrl = new List<DeltakSRP__Lead_Conversion_Record__c>();
        for(Lead l : 
            [Select 
                DeltakSRP__External_Id__c,
                DeltakSRP__Account_External_Id__c 
             From 
                Lead 
             Where 
                Id in :oldMap.keySet()
                And IsConverted = true
             ]){
             lcrl.add(
                 new DeltakSRP__Lead_Conversion_Record__c(
                    DeltakSRP__External_Id__c=l.DeltakSRP__External_Id__c,
                    DeltakSRP__Account_External_Id__c=l.DeltakSRP__Account_External_Id__c
                )
            );
        }
        
        if(!lcrl.isEmpty()){
            try{
                Database.upsert(lcrl,DeltakSRP__Lead_Conversion_Record__c.fields.DeltakSRP__External_id__c,false);
            }catch(DMLException e){}
        }
    }*/
}