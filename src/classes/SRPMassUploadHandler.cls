public without sharing class SRPMassUploadHandler {


    /*
    Girija: added methods unformatphonenumber and onBeforeInsert(List<SRP_Mass_Upload_Data__c> datalist) 
     for SRP:1292 - Change Deduplication logic in Mass Upload tool to use country codes with phone numbers 
    */
    public static string unformatphonenumber(String phonenumber)
    {
        phonenumber = phonenumber.replace('-','');
        phonenumber = phonenumber.replace('.','');
        phonenumber=phonenumber.replace(')','');
        phonenumber=phonenumber.replace('(','');
        phonenumber=phonenumber.replace(' ','');
        phonenumber=phonenumber.replace('x','');
        system.debug('phonenumber>>>>'+phonenumber);
        phonenumber.trim();
        
        while(phonenumber.startswith('0'))
        {
            phonenumber = phonenumber.substring(1, phonenumber.length());
            system.debug('inside removing any leading 0>>>>'+phonenumber);
        }       
        return phonenumber;
    }
    
    public static List<SRP_Mass_Upload_Data__c> onBeforeInsert(List<SRP_Mass_Upload_Data__c> datalist)
    {
        Map<String,SRP_Phone_Codes__c> countryphonecodes = SRP_Phone_Codes__c.getall();
        for(SRP_Mass_Upload_Data__c m : datalist)
        {
            system.debug('m.Home_Phone__c>>'+m.Home_Phone__c);
            if(m.Home_Phone__c !=null && m.Home_Phone__c !='')
            {
                if(m.country__c != null || m.state__c != null)
                {
                    String generalphonenumber = unformatphonenumber(m.Home_Phone__c);
                    String phonecode = '';
                    
                    if(m.country__c != null && countryphonecodes.get(m.country__c.tolowercase()) != null)
                    {
                        phonecode = countryphonecodes.get(m.country__c.tolowercase()).Phone_Code__c;
                        
                        if(phonecode!=null && phonecode!='' && generalphonenumber.startswith('+'))
                        {
                            continue;
                        }
                        if(phonecode!=null && phonecode!='' && generalphonenumber.startswith(phonecode))
                        {
                        	m.Home_Phone__c = '+'+generalphonenumber;
                            continue;
                        }
                        if(phonecode!= null && phonecode !='' && !(generalphonenumber.startswith('+')))
                        {
                            m.Home_Phone__c = '+'+phonecode+generalphonenumber;
                            system.debug('m.Home_Phone__c1>>'+m.Home_Phone__c);
                            continue;
                        }
                    }
                    
                    if(m.country__c == null && m.state__c!= null && countryphonecodes.get(m.state__c.tolowercase())!=null)
                    {
                        phonecode = countryphonecodes.get(m.state__c.tolowercase()).phone_code__c;
                        if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+'))
                        {
                          continue;
                        }
                        
                        if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode))
                        {
                            m.Home_Phone__c = '+'+generalphonenumber;
                            system.debug('m.Home_Phone__c2>>'+m.Home_Phone__c);
                            continue;
                        }
                      
                        if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+'))
                        {
                            m.Home_Phone__c = '+'+phonecode+generalphonenumber;
                            system.debug('m.Home_Phone__c3>>'+m.Home_Phone__c);
                            continue;
                        }
                    }
                }
            }
        }
        
        for(SRP_Mass_Upload_Data__c m : datalist)
        {
            system.debug('(m.Work_Phone__c '+m.Work_Phone__c );
            
            if(m.Work_Phone__c !=null && m.Work_Phone__c !='') 
            {
                if(m.country__c != null || m.state__c != null)
                {
                    String generalphonenumber = unformatphonenumber(m.Work_Phone__c);
                    String phonecode = '';
                    
                    if(m.country__c != null && countryphonecodes.get(m.country__c.tolowercase()) != null)
                    {
                        phonecode = countryphonecodes.get(m.country__c.tolowercase()).Phone_Code__c;
                        
                        if(phonecode!=null && phonecode!='' && generalphonenumber.startswith('+'))
                        {
                            continue;
                        }
                        if(phonecode!=null && phonecode!='' && generalphonenumber.startswith(phonecode))
                        {
                        	m.Work_Phone__c = '+'+generalphonenumber;
                            continue;
                        }
                        if(phonecode!= null && phonecode !='' && !(generalphonenumber.startswith('+')))
                        {
                            m.Work_Phone__c = '+'+phonecode+generalphonenumber;
                            system.debug('m.Work_Phone__c1>>'+m.Work_Phone__c);
                            continue;
                        }
                    }
                    
                    if(m.country__c == null && m.state__c!= null && countryphonecodes.get(m.state__c.tolowercase())!=null)
                    {
                        phonecode = countryphonecodes.get(m.state__c.tolowercase()).phone_code__c;
                        if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+'))
                        {
                          continue;
                        }
                        
                        if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode))
                        {
                            m.Work_Phone__c = '+'+generalphonenumber;
                            system.debug('m.Work_Phone__c2'+m.Work_Phone__c);
                            continue;
                        }
                      
                        if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+'))
                        {
                            m.Work_Phone__c = '+'+phonecode+generalphonenumber;
                            system.debug('m.Work_Phone__c3'+m.Work_Phone__c);
                            continue;
                        }
                    }
                }
            }
        }
        
    /*  for(SRP_Mass_Upload_Data__c m : datalist)
        {
            if(m.Mobile_Phone__c !=null && (m.country__c != null || m.state__c != null))
            {
                String generalphonenumber = unformatphonenumber(m.Mobile_Phone__c);
                String phonecode = '';
                
                if(m.country__c != null && countryphonecodes.get(m.country__c.tolowercase()) != null)
                {
                    phonecode = countryphonecodes.get(m.country__c.tolowercase()).Phone_Code__c;
                    
                    if(phonecode!=null && phonecode!='' && generalphonenumber.startswith('+'))
                    {
                        continue;
                    }
                    if(phonecode!=null && phonecode!='' && generalphonenumber.startswith(phonecode))
                    {
                        continue;
                    }
                    if(phonecode!= null && phonecode !='' && !(generalphonenumber.startswith('+')))
                    {
                        m.Mobile_Phone__c = '+'+phonecode+generalphonenumber;
                        continue;
                    }
                }
                
                if(m.country__c == null && m.state__c!= null && countryphonecodes.get(m.state__c.tolowercase())!=null)
                {
                    phonecode = countryphonecodes.get(m.state__c.tolowercase()).phone_code__c;
                    if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+'))
                    {
                      continue;
                    }
                    
                    if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode))
                    {
                        m.Mobile_Phone__c = '+'+generalphonenumber;
                        continue;
                    }
                  
                    if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+'))
                    {
                        m.Mobile_Phone__c = '+'+phonecode+generalphonenumber;
                        continue;
                    }
                }
            }
        }       */
        return datalist;        
    }
    
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
        Map<Id,Lead> duplicateLeads = new Map<Id,Lead>();
       
        // Get RecordType and Partner Account defaults
        DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        Id profileId = UserInfo.getProfileId();
        
        
        for (Lead newLead : leads) {
                if(newLead.DeltakSRP__Academic_Institution_Lookup__c != null)
                    academicInstitutions.add(string.valueof(newLead.DeltakSRP__Academic_Institution_Lookup__c).substring(0,15));
                leadEmails.add(newLead.Email);
                
                if(newLead.Phone != null){
                    leadPhones.add(newLead.Phone);
                    //leadphones.add(unformattedphone(newlead.phone));
                    //leadphones.add(formattedphone(newlead.phone));
                }   
                if(newlead.mobilephone != null){
                    leadphones.add(newLead.MobilePhone);
                    //leadphones.add(unformattedphone(newlead.mobilephone));
                    //leadphones.add(formattedphone(newlead.mobilephone));
                }   
                if(newlead.DeltakSRP__Work_Phone__c != null){
                    leadphones.add(newLead.DeltakSRP__Work_Phone__c);
                    //leadphones.add(unformattedphone(newlead.DeltakSRP__Work_Phone__c));
                    //leadphones.add(formattedphone(newlead.DeltakSRP__Work_Phone__c));
                }   
                if(newlead.deltaksrp__home_phone__c != null){
                    leadphones.add(newLead.DeltakSRP__Home_Phone__c);
                    //leadphones.add(unformattedphone(newlead.DeltakSRP__Home_Phone__c));
                    //leadphones.add(formattedphone(newlead.DeltakSRP__Home_Phone__c));
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
        }
        
        system.debug('leademails>>>>'+leademails);
        system.debug('leadPhones>>>>'+leadPhones);
        system.debug('leadFirstNames>>>>'+leadFirstNames);
        system.debug('leadLastNames>>>>'+leadLastNames);
        system.debug('leadAcademicPrograms>>>>'+leadAcademicPrograms);
        //system.debug('leadSources>>>>'+leadSources);
        system.debug('academicInstitutions>>>>'+academicInstitutions);
                 
           
        //Get all matching, existing opportunities to check for duplicates
        List<Lead> existingLeads = new List<Lead>();
        existingLeads = [Select Id, email, phone,
                    DeltakSRP__home_phone__c, deltaksrp__work_phone__c,
                    mobilephone, FirstName, LastName, DeltakSRP__Lead_Source_ID__c,
                    DeltakSRP__Academic_Institution_lookup__c, DeltakSRP__Academic_Program_lookup__c from Lead where
                    (email in :leadEmails 
                    or mobilephone in :leadPhones 
                    or DeltakSRP__home_phone__c in:leadPhones 
                    or DeltakSRP__Work_Phone__c in:leadPhones)
                    And firstName in :leadFirstNames
                    And LastName in :leadLastNames
//                    And DeltakSRP__Lead_Source_ID__c in :leadSources
                    And DeltakSRP__Academic_Institution_lookup__c    in :academicInstitutions
                    And DeltakSRP__Academic_Program_lookup__c in :leadAcademicPrograms and isdeleted = false
                   ];
  
         system.debug('existing Leads total duplicates >>>>'+existingLeads);
       
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
        
        
        for(Lead current : srpLeads){
            
                //Search for duplicates if this is not part of an upsert operation (e.g. integration)
                //Where the dupe check has already been done
                 current.DeltakSRP__Is_Duplicate__c = false;
                 if(current.DeltakSRP__External_Id__c == null){
                    for(Lead existingopp : existingLeads){
                       if(isDuplicate(current,existingopp)){
                            system.debug('found duplicate>>>>');
                            current.DeltakSRP__Is_Duplicate__c = true;
                           }else{
                            system.debug('duplicate not found>>>>'+Limits.getLimitQueries());
                       }
                    }
                 }    
                //Dont check for contacts if this lead already has one associated (e.g. integration)
                if(current.DeltakSRP__Contact__c == null && current.DeltakSRP__Is_Duplicate__c != true){
                    Contact matchingContact = null;
                    for(Contact c : matchingContacts){
                       if(isDuplicate(current,c)){
                            matchingContact = c; 
                        } 
                    }
                    leadContactMap.put(
                        current,
                        getContactInfo(current,matchingContact,settings.DeltakSRP__Contact_Record_Type_Id__c)
                    );
                }
                
            
            //}catch(SRPException e){}
        }
        
        // Create a deduplicated list of Contact records starting with
        //  the List of Contacts in the Lead, Contact map
        List<Contact> contacts = leadContactMap.values();
        Set<Contact> uniqueContacts = new Set<Contact>();
        for(Contact c : contacts){ 
            if(c != null){         
              uniqueContacts.add(c);
            }
        }
        contacts.clear();
        contacts.addAll(uniqueContacts);
        system.debug('contacts>>>>'+contacts);
        //Database.update(duplicateLeads.values(),false);  
        Map<Contact, Id> contactTocontactIdMap = new Map<Contact, Id>();
        if(contacts != null && contacts.size() > 0){
             upsert contacts;
             for(Contact c: contacts){
                system.debug('c.id>>>>'+c.Id);
                contactTocontactIdMap.put(c,c.Id);
             }
        }       
        
        for(Lead l : leads){
          Contact c = leadContactMap.get(l);
          if(c != null){
            l.DeltakSRP__Contact__c = contactTocontactIdMap.get(c);
          }
        } 
        
    }  
    
    public static List<Opportunity> onBeforeInsert(List<Opportunity> opps, Map<Opportunity, SRPMassUploadDataWrapper> opptyWrapMap){
        List<Opportunity> nondupOpps = new List<Opportunity>();
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
        Set<String> oppAcademicPrograms2 = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<String> oppAcademicPrgFromRFI = new Set<String>();
        Set<String> academicInstitutions     = new Set<String>();
        Map<Opportunity,Contact> oppContactMap = new Map<opportunity,Contact>();
        Map<Id,Opportunity> duplicateopps = new Map<Id,Opportunity>();
        DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        
        
         for (Opportunity newopp : opps) {
            system.debug('new opp>>>>'+newopp);
                if(newopp.accountId != null)
                    academicInstitutions.add(string.valueof(newopp.accountid).substring(0,15));
                if(opptyWrapMap.get(newopp).email != null)
                    oppEmails.add(opptyWrapMap.get(newopp).email);
                if(opptyWrapMap.get(newopp).mobilephone != null){   
                    oppphones.add(opptyWrapMap.get(newopp).mobilephone);
                    /*oppphones.add(unformattedphone(opptyWrapMap.get(newopp).mobilephone));
                    oppphones.add(formattedphone(opptyWrapMap.get(newopp).mobilephone));*/
                }   
                if(opptyWrapMap.get(newopp).workphone != null){ 
                    oppphones.add(opptyWrapMap.get(newopp).workphone);
                    //oppphones.add(unformattedphone(opptyWrapMap.get(newopp).workphone));
                    //oppphones.add(formattedphone(opptyWrapMap.get(newopp).workphone));
                }   
                if(opptyWrapMap.get(newopp).homephone != null){
                    oppphones.add(opptyWrapMap.get(newopp).homephone);  
                    //oppphones.add(unformattedphone(opptyWrapMap.get(newopp).homephone));
                    //oppphones.add(formattedphone(opptyWrapMap.get(newopp).homephone));
                }       
                if(opptyWrapMap.get(newopp).lastname != null)       
                    oppLastNames.add(opptyWrapMap.get(newopp).lastname);
                if(opptyWrapMap.get(newopp).firstname != null)  
                    oppFirstNames.add(opptyWrapMap.get(newopp).firstname);
                oppAcademicPrograms2.add(newopp.DeltakSRP__AcademicProgram__c);
        }
        system.debug('opptywrapmap1>>>>'+opptywrapmap); 
        List<RFI_to_Academic_Programs_Code__c> rtapc = new List<RFI_to_Academic_Programs_Code__c>();
        rtapc = [Select ID, Program_Code__c, Academic_Program__c, Academic_Specialization__c from RFI_to_Academic_Programs_Code__c where Program_Code__c in: oppAcademicPrograms2 and Organization_Id__c in: academicInstitutions];
        
        Map<String, Id> codeToProgramMap = new Map<String, Id>();
        
        if(rtapc.size()>0){
            for(RFI_to_Academic_Programs_Code__c r: rtapc){
                if(r.Academic_Program__c != null)
                    codeToProgramMap.put(r.Program_Code__c, r.Academic_Program__c);
            }
        }
        Map<Opportunity, SRPMassUploadDataWrapper> opptyWrapMap2 = new Map<Opportunity, SRPMassUploadDataWrapper>();
        for(Opportunity current : opps){
            SRPMassUploadDataWrapper wrap = opptywrapmap.get(current);
            if(codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c) != null && codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c) != null)
                current.DeltakSRP__academic_program__c = codeToProgramMap.get(current.DeltakSRP__AcademicProgram__c);       
           
           //Girija: added else condition to reflect other program in 'Other Program Information' field    
             else            
                current.DeltakSRP__Other_Program_Information__c = current.DeltakSRP__AcademicProgram__c;                     
             
            oppAcademicPrograms.add(current.DeltakSRP__Academic_Program__c);
            opptyWrapMap2.put(current, wrap);
        }
        system.debug('opptyWrapMap2>>>>'+opptyWrapMap2);
        system.debug('oppemails>>>>'+oppemails);
        system.debug('oppPhones>>>>'+oppPhones);
        system.debug('oppFirstNames>>>>'+oppFirstNames);
        system.debug('oppLastNames>>>>'+oppLastNames);
        system.debug('oppAcademicPrograms>>>>'+oppAcademicPrograms);
        //system.debug('leadSources>>>>'+leadSources);
        system.debug('academicInstitutions>>>>'+academicInstitutions);
           
        //Get all matching, existing opportunities to check for duplicates
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Email__c, 
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,DeltakSRP__Student__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, DeltakSRP__AcademicProgram__c, DeltakSRP__Student__r.phone,
                    DeltakSRP__Student__r.DeltakSRP__Student_Email__c, DeltakSRP__Student__r.email, DeltakSRP__Student__r.DeltakSRP__Work_Email__c from Opportunity where
                    (DeltakSRP__Email__c in :oppEmails 
                    or DeltakSRP__Student__r.DeltakSRP__Student_Email__c in :oppemails
                    or DeltakSRP__Student__r.phone in: oppphones
                    or DeltakSRP__Student__r.mobilephone in :oppPhones 
                    or DeltakSRP__Student__r.homephone in:oppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:oppPhones)
                    And DeltakSRP__Student__r.firstName in :oppFirstNames
                    And DeltakSRP__Student__r.LastName in :oppLastNames
                    And AccountId    in :academicInstitutions
                    And DeltakSRP__Academic_Program__c in :oppAcademicPrograms and isdeleted = false
                    And StageName != 'Dormant'
                   ];
  
         system.debug('existing opportunities total duplicates >>>>'+existingopportunities);
       
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
                DeltakSRP__Person__c,
                HomePhone,
                Work_Phone__c
             From 
                Contact
             Where
                (Email in :oppEmails 
                    Or DeltakSRP__Work_Email__c in :oppEmails
                    Or DeltakSRP__Student_Email__c in :oppEmails
                    Or Phone in :oppPhones 
                    Or MobilePhone in :oppPhones 
                    Or HomePhone in :oppPhones 
                    Or DeltakSRP__Work_Phone__c in :oppPhones)
                And FirstName in :oppFirstNames
                And LastName in :oppLastNames
                And AccountId in :academicInstitutions];        
        
        system.debug('matchingcontacts>>>>'+matchingcontacts);
        
        for(Opportunity current : opps){ 
            //Dont check for contacts if this lead already has one associated (e.g. integration)
            if(current.DeltakSRP__Student__c == null){
                Contact matchingContact = null;
                for(Contact c : matchingContacts){
                    if(isDuplicate(opptyWrapMap2.get(current),c)){
                        system.debug('found matching contact>>>>');
                        matchingContact = c; 
                    } 
                }
                
                oppContactMap.put(
                    current,
                    getContactInfo(current,matchingContact,settings.DeltakSRP__Contact_Record_Type_Id__c, opptyWrapMap2)
                );
            }
            
                    
            if(existingOpportunities.size() == 0){
                nonDupOpps.add(current);
                continue;
            }
            
            boolean dupfound = false;
            
            for(Opportunity existingopp : existingOpportunities){
                  if(isDuplicate(current,existingopp) && isDuplicate(opptywrapmap2.get(current),existingopp)){
                    system.debug('found duplicate>>>>');
                    dupfound = true;
                    continue;
                   }else{
                    system.debug('duplicate not found>>>>');
                }
            }
            
            if(dupfound == false)
                nonDupOpps.add(current);
            
        }
        
        // Create a deduplicated list of Contact records starting with
        //  the List of Contacts in the Lead, Contact map
        List<Contact> contacts = OppContactMap.values();
        Set<Contact> uniqueContacts = new Set<Contact>();
        for(Contact c : contacts){ 
            if(c != null){         
              uniqueContacts.add(c);
            }
        }
        contacts.clear();
        contacts.addAll(uniqueContacts);
        
        //Database.update(duplicateLeads.values(),false);  
        system.debug('contacts>>>>'+contacts);
        system.debug('nonDupOpps>>>>'+nonDupOpps);
        
        Map<Contact, Id> contactTocontactIdMap = new Map<Contact, Id>();
        if(contacts != null && contacts.size() > 0 && nonDupOpps.size()>0){
             Database.upsert(contacts,false);
             for(Contact c: contacts){
                system.debug('c.id>>>>'+c.Id);
                contactTocontactIdMap.put(c,c.Id);
             }
        }       
        
        List<Contact> upsertedContacts = new List<Contact>();
        
        
        system.debug('OppContactMap>>>>'+ OppContactMap);
        for(Opportunity o : nonDupOpps){
          Contact c = OppContactMap.get(o);
          system.debug('c>>>>'+c);
          if(c != null){
            o.DeltakSRP__Student__c = contactTocontactIdMap.get(c);

          }
        } 
        return nonDupOpps;
    }
    
    public static void onAfterInsert(List<Opportunity> opps){
        
        /*List<Id> oppIds = new List<Id>();
        for(Opportunity o: opps){
            oppIds.add(o.Id);
        }
        
        List<Opportunity> opportunities = 
                [Select 
                    Id,
                    SRP_Student_First_Name__c,
                    SRP_Student_Last_Name__c,
                    SRP_Employer_Company__c,
                    Name,
                    OwnerId,
                    DeltakSRP__Work_Phone__c,
                    DeltakSRP__Home_Phone__c,
                    DeltakSRP__Mobile_Phone__c,
                    DeltakSRP__Email__c,
                    SRP_Ok_To_Text__c,
                    SRP_Do_Not_Call__c,
                    SRP_Email_Opt_Out__c,
                    //DeltakSRP__Lead_Source_Id__c,
                    DeltakSRP__Student__c,
                    DeltakSRP__Student__r.Name,
                    DeltakSRP__Academic_Program__c,
                    Account.Abbreviation__c,
                    DeltakSRP__Student__r.RecordType.Name,
                    DeltakSRP__Student__r.AccountId,
                    DeltakSRP__Inquiry_Rating__c
                 From 
                    Opportunity 
                 Where 
                    Id in :oppIds];*/
                    
                    
        List<Opportunity> activePartialDuplicateOpportunities = new List<Opportunity> ();
        activePartialDuplicateOpportunities = getActivePartialDuplicates(opps);
        
        List<Opportunity> dormantPartialDuplicateOpportunities = new List<Opportunity> ();
        dormantPartialDuplicateOpportunities = getDormantPartialDuplicates(opps);
        
        /*List<Opportunity> activeNonPartialDuplicateOpportunities = new List<Opportunity> ();
        activeNonPartialDuplicateOpportunities = getActiveNonPartialDuplicates(opportunities);*/
        
        List<Opportunity> dormantNonPartialDuplicateOpportunities = new List<Opportunity> ();
        dormantNonPartialDuplicateOpportunities = getDormantNonPartialDuplicates(opps);
 
        List<Opportunity> differentPartnerPartialDuplicateOpportunities = new List<Opportunity>();
        differentPartnerPartialDuplicateOpportunities = getDifferentPartnerOpportunities(opps);
        
        List<Opportunity> oppstoUpdate = new List<Opportunity>();
        
        for(Opportunity current: opps){
            Opportunity opptoUpdate = new Opportunity();
            opptoUpdate = current;
            
            Boolean duplicatefound = false;
            for(Opportunity existingopp : activePartialDuplicateOpportunities){
                if(isPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Active Partial Duplicate Opportunity>>>>');
                        opptoUpdate.StageName = Label.Opportunity_Dormant_Stage_Name;
                        opptoUpdate.DeltakSRP__Sub_Stage__c = Label.Opportunity_Dormant_SubStage_Name;
                        opptoUpdate.SRP_Person__c = current.DeltakSRP__Student__r.DeltakSRP__Person__c;
                        oppToUpdate.SRP_Retain_Ownership__c = true;
                        opptoUpdate.OwnerId = existingopp.OwnerId;
                        oppstoUpdate.add(opptoUpdate);
                        break;
                        //send duplicate/dormant email notification
                }
            }
            
            for(Opportunity existingopp : dormantPartialDuplicateOpportunities){
                if(isPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant Partial Duplicate Opportunity>>>>');
                        oppToUpdate.StageName = Label.Opportunity_New_Inquiry_Stage_Name;
                        opptoUpdate.SRP_Person__c = current.DeltakSRP__Student__r.DeltakSRP__Person__c;
                        oppToUpdate.SRP_Retain_Ownership__c = true;
                        opptoUpdate.OwnerId = existingopp.OwnerId;
                        oppstoUpdate.add(opptoUpdate);
                        break;
                        //send duplicate/dormant email notification
                }
            }
            
            /*for(Opportunity existingopp : activeNonPartialDuplicateOpportunities){
                if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Active Non Partial Duplicate Opportunity>>>>');
                        opptoUpdate.StageName = Label.Opportunity_Dormant_Stage_Name;
                        opptoUpdate.DeltakSRP__Sub_Stage__c = Label.Opportunity_Dormant_SubStage_Name;
                        oppstoUpdate.add(opptoUpdate);
                        break;
                        //send duplicate/dormant email notification
                }
            }*/
            
             for(Opportunity existingopp : dormantNonPartialDuplicateOpportunities){
                    if(isnonPartialDuplicate(current,existingopp)){
                        duplicatefound = true;
                        system.debug('Dormant non-Partial Duplicate Opportunity>>>>');
                        opptoUpdate.StageName = Label.Opportunity_New_Inquiry_Stage_Name;
                        opptoUpdate.SRP_Person__c = current.DeltakSRP__Student__r.DeltakSRP__Person__c;
                        oppToUpdate.SRP_Retain_Ownership__c = true;
                        opptoUpdate.OwnerId = existingopp.OwnerId;
                        oppstoUpdate.add(opptoUpdate);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            for(Opportunity existingopp : differentPartnerPartialDuplicateOpportunities){
                    if(isPartialDuplicateDiffPartner(current,existingopp)){
                        duplicatefound = true;
                        system.debug('different Partner partial Opportunity>>>>');
                        opptoUpdate.StageName = Label.Opportunity_New_Inquiry_Stage_Name;
                        opptoUpdate.SRP_Person__c = current.DeltakSRP__Student__r.DeltakSRP__Person__c;
                        oppstoUpdate.add(opptoUpdate);
                        break;
                        //send duplicate/dormant email notification
                    }
            }
            
            if(duplicatefound == false){
                opptoUpdate.SRP_Person__c = current.DeltakSRP__Student__r.DeltakSRP__Person__c;
                oppstoupdate.add(opptoUpdate);
            }   
            
        }
        
        if(oppstoUpdate.size()>0)
            update oppstoupdate;
  
        
    }
    
    public static List<Opportunity> getActivePartialDuplicates(List<Opportunity> opps){
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
        
        DeltakSRP__SRP_Partner_Settings__c settings = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        Id profileId = UserInfo.getProfileId();
        
        for (Opportunity newopp : opps) 
        { 
                academicInstitutions.add(newopp.AccountId);
                oppEmails.add(newOpp.DeltakSRP__Email__c);

              /* if(newopp.deltaksrp__mobile_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Mobile_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
               }    */
                if(newopp.DeltakSRP__Work_Phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Work_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Work_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Work_Phone__c));
                }   
                if(newopp.deltaksrp__home_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Home_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Home_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Home_Phone__c));
                }   
                            
                oppLastNames.add(newOpp.SRP_Student_Last_Name__c);
                oppAcademicPrograms.add(newOpp.DeltakSRP__Academic_Program__c);
//                leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                oppFirstNames.add(newOpp.SRP_Student_First_Name__c);
        }   
        
        system.debug('academicInstitutions####'+academicInstitutions);
        system.debug('oppEmails####'+oppEmails);
        system.debug('oppLastNames####'+oppLastNames);
        system.debug('oppFirstNames####'+oppFirstNames);
        system.debug('oppAcademicPrograms####'+oppAcademicPrograms);
        system.debug('Oppphones in partial match####'+Oppphones);
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, stagename, SRP_Retain_Ownership__c, SRP_Person__c from Opportunity where
                    (deltaksrp__Email__c in :OppEmails 
                    or DeltakSRP__Student__r.mobilephone in :OppPhones 
                    or DeltakSRP__Student__r.homephone in:OppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:OppPhones)
                    And DeltakSRP__Student__r.FirstName in :OppFirstNames
                    And DeltakSRP__Student__r.LastName in :OppLastNames
                    And DeltakSRP__academic_program__c not in :OppAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And AccountId    in :academicInstitutions
                    And StageName in (:Label.Opportunity_Active_StageName_1, :Label.Opportunity_Active_StageName_2, :Label.Opportunity_Active_StageName_3, :Label.Opportunity_Active_StageName_4, :Label.Opportunity_Active_StageName_5,
                            :Label.Opportunity_Active_StageName_6, :Label.Opportunity_Active_StageName_7, :Label.Opportunity_Active_StageName_8, :Label.Opportunity_Active_StageName_9, :Label.Opportunity_Active_StageName_10, :Label.Opportunity_Active_StageName_11)
                    ];
                    
        system.debug('activepartialduplicates>>>>'+existingopportunities);
                    
        return existingOpportunities;
    } 
    
    public static List<Opportunity> getDormantPartialDuplicates(List<Opportunity> opps){
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
//        Set<String> leadSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
               
         
        for (Opportunity newopp : opps) {
                academicInstitutions.add(newopp.AccountId);
                oppEmails.add(newopp.deltakSRP__Email__c);
                /*if(newopp.deltaksrp__mobile_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Mobile_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                }  */ 
                if(newopp.DeltakSRP__Work_Phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Work_Phone__c);
                    ///oppphones.add(formattedphone(newOpp.DeltakSRP__Work_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Work_Phone__c));
                }   
                if(newopp.deltaksrp__home_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Home_Phone__c);
                    ///oppphones.add(formattedphone(newOpp.DeltakSRP__Home_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Home_Phone__c));
                }   
                    
                            
                oppLastNames.add(newopp.SRP_Student_Last_Name__c);
                oppAcademicPrograms.add(newopp.DeltakSRP__Academic_Program__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                oppFirstNames.add(newopp.SRP_Student_First_Name__c);
        }   
        
        
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, stagename, SRP_Retain_Ownership__c, SRP_Person__c from Opportunity where
                    (deltaksrp__Email__c in :oppEmails 
                    or DeltakSRP__Student__r.mobilephone in :oppPhones 
                    or DeltakSRP__Student__r.homephone in:oppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:oppPhones)
                    And DeltakSRP__Student__r.FirstName in :oppFirstNames
                    And DeltakSRP__Student__r.LastName in :oppLastNames
                    And DeltakSRP__academic_program__c not in :oppAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And accountid    in :academicInstitutions 
                    And StageName = :Label.Opportunity_Dormant_Stage_Name
                    ];
        
        system.debug('dormant partial duplicates>>>>'+existingopportunities);            
                       
        return existingOpportunities;
    }
    
    public static List<Opportunity> getActiveNonPartialDuplicates(List<Opportunity> opps){
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
        //Set<String> oppSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
                
        
        for (Opportunity newopp : opps) {
                academicInstitutions.add(newopp.AccountId);
                oppEmails.add(newopp.deltakSRP__Email__c);
                
                /*if(newopp.deltaksrp__mobile_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Mobile_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
               } */   
                if(newopp.DeltakSRP__Work_Phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Work_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Work_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Work_Phone__c));
                }   
                if(newopp.deltaksrp__home_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Home_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Home_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Home_Phone__c));
                }   
                    
                            
                oppLastNames.add(newopp.SRP_Student_Last_Name__c);
                oppAcademicPrograms.add(newopp.DeltakSRP__Academic_Program__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                oppFirstNames.add(newopp.SRP_Student_First_Name__c);
        }   
        
         
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid from Opportunity where
                    (DeltakSRP__Email__c in :oppEmails 
                    or DeltakSRP__Student__r.mobilephone in :oppPhones 
                    or DeltakSRP__Student__r.homephone in:oppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:oppPhones)
                    And DeltakSRP__Student__r.FirstName in :oppFirstNames
                    And DeltakSRP__Student__r.LastName in :oppLastNames
                    And DeltakSRP__academic_program__c  not in :oppAcademicPrograms
                    //And DeltakSRP__opp_Source_ID__c  not in :oppSources)
                    And accountid    in :academicInstitutions
                    And StageName in (:Label.Opportunity_Active_StageName_1, :Label.Opportunity_Active_StageName_2, :Label.Opportunity_Active_StageName_3, :Label.Opportunity_Active_StageName_4, :Label.Opportunity_Active_StageName_5,
                            :Label.Opportunity_Active_StageName_6, :Label.Opportunity_Active_StageName_7, :Label.Opportunity_Active_StageName_8, :Label.Opportunity_Active_StageName_9, :Label.Opportunity_Active_StageName_10, :Label.Opportunity_Active_StageName_11)
                    ];
                       
        system.debug('ActiveNonPartialDuplicates>>>>'+existingOpportunities) ;
        
        
        return existingOpportunities;
    }
    
    public static List<Opportunity> getDormantNonPartialDuplicates(List<Opportunity> opps){
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
        
        for (Opportunity newopp : opps) {
                academicInstitutions.add(newopp.accountid);
                oppEmails.add(newopp.DeltakSRP__Email__c);
               
                /*if(newopp.deltaksrp__mobile_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Mobile_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
               }  */  
                if(newopp.DeltakSRP__Work_Phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Work_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Work_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Work_Phone__c));
                }   
                if(newopp.deltaksrp__home_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Home_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Home_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Home_Phone__c));
                }   
                    
                            
                oppLastNames.add(newopp.SRP_Student_Last_Name__c);
                oppAcademicPrograms.add(newopp.DeltakSRP__Academic_Program__c);
                //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
                oppFirstNames.add(newopp.SRP_STudent_First_Name__c);
        }   
        
        
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, stagename, SRP_Retain_Ownership__c, SRP_Person__c from Opportunity where
                    (Deltaksrp__Email__c in :oppEmails 
                    or DeltakSRP__Student__r.mobilephone in :oppPhones 
                    or DeltakSRP__Student__r.homephone in:oppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:oppPhones)
                    And DeltakSRP__Student__r.FirstName in :oppFirstNames
                    And DeltakSRP__Student__r.LastName in :oppLastNames
                    And DeltakSRP__academic_program__c in :oppAcademicPrograms
                   // And DeltakSRP__Lead_Source_ID__c not in :leadSources)
                    And accountid    in :academicInstitutions
                    And StageName = :Label.Opportunity_Dormant_Stage_Name
                    ];
            system.debug('dormant non partial duplicate>>>>'+existingopportunities);            
            return existingOpportunities;
    }
    
    public static List<Opportunity> getDifferentPartnerOpportunities(List<Opportunity> opps){
        Set<String> oppEmails           = new Set<String>();
        Set<String> oppPhones           = new Set<String>();       
        Set<String> oppLastNames        = new Set<String>();
        Set<String> oppAcademicPrograms = new Set<String>();
        //Set<String> leadSources          = new Set<String>();
        Set<String> oppFirstNames       = new Set<String>();
        Set<Id> academicInstitutions     = new Set<Id>();
        
                
        for (Opportunity newopp : opps) {
            academicInstitutions.add(newopp.AccountId);
            if(newopp.DeltakSRP__Email__c != null)
                oppEmails.add(newopp.DeltakSRP__Email__c);
            
            /*if(newopp.deltaksrp__mobile_phone__c != null){
                    oppphones.add(newOpp.DeltakSRP__Mobile_Phone__c);
                    //oppphones.add(formattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
                    //oppphones.add(unformattedphone(newOpp.DeltakSRP__Mobile_Phone__c));
            } */  
            if(newopp.DeltakSRP__Work_Phone__c != null){
                oppphones.add(newOpp.DeltakSRP__Work_Phone__c);
                //oppphones.add(formattedphone(newOpp.DeltakSRP__Work_Phone__c));
                //oppphones.add(unformattedphone(newOpp.DeltakSRP__Work_Phone__c));
            }   
            if(newopp.deltaksrp__home_phone__c != null){
                oppphones.add(newOpp.DeltakSRP__Home_Phone__c);
                //oppphones.add(formattedphone(newOpp.DeltakSRP__Home_Phone__c));
                //oppphones.add(unformattedphone(newOpp.DeltakSRP__Home_Phone__c));
            }   
                    
            if(newopp.SRP_Student_Last_Name__c != null)             
                oppLastNames.add(newopp.SRP_Student_Last_Name__c);
            if(newopp.DeltakSRP__Academic_Program__c != null)   
                oppAcademicPrograms.add(newopp.DeltakSRP__Academic_Program__c);
            //leadSources.add(newLead.DeltakSRP__Lead_Source_ID__c);
            if(newopp.SRP_Student_First_Name__c != null)
                oppFirstNames.add(newopp.SRP_Student_First_Name__c);
        }   
        
        system.debug('academicInstitutions>>>>'+academicInstitutions);
        system.debug('oppEmails>>>>'+oppEmails);
        system.debug('oppphones>>>>'+oppphones);
        system.debug('oppLastNames>>>>'+oppLastNames);
        system.debug('oppAcademicPrograms>>>>'+oppAcademicPrograms);
        
        List<Opportunity> existingOpportunities = new List<Opportunity>();
        existingOpportunities = [Select Id, DeltakSRP__Event__r.DeltakSRP__Registration_Code__c, DeltakSRP__Email__c,
                    deltaksrp__student__r.homephone, deltaksrp__student__r.mobilephone, deltaksrp__student__r.deltaksrp__work_phone__c,
                    DeltakSRP__Mobile_Phone__c, DeltakSRP__Home_Phone__c, DeltakSRP__Work_Phone__c,
                    DeltakSRP__Student__r.FirstName, DeltakSRP__Student__r.LastName, DeltakSRP__Lead_Source_ID__c,
                    AccountId, DeltakSRP__Academic_Program__c, ownerid, stagename, SRP_Retain_Ownership__c, SRP_Person__c from Opportunity where
                    (deltaksrp__Email__c in :oppEmails 
                    or DeltakSRP__Student__r.mobilephone in :oppPhones 
                    or DeltakSRP__Student__r.homephone in:oppPhones 
                    or DeltakSRP__Student__r.DeltakSRP__Work_Phone__c in:oppPhones)
                    And DeltakSRP__Student__r.FirstName in :oppFirstNames
                    And DeltakSRP__Student__r.LastName in :oppLastNames
                    And DeltakSRP__academic_program__c in :oppAcademicPrograms
                    //or DeltakSRP__Lead_Source_ID__c in :leadSources)
                    And accountid    not in :academicInstitutions
                    ];
        system.debug('different partner opps>>>>'+existingopportunities);   
        return existingOpportunities;
    }
    
    private static boolean ispartialduplicate(Opportunity current, Opportunity existing){
        
        return 
        isDuplicateWithoutRegCode(current,existing)  && 
            (
          //      current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c || 
                current.DeltakSRP__Academic_Program__c != existing.DeltakSRP__Academic_Program__c 
            )
            &&
            current.AccountId == existing.AccountId;
    }
    
    private static boolean isDuplicateWithoutRegCode(Opportunity current,Opportunity existing){
          /*String currentmobilephone = unformattedPhone(current.DeltakSRP__Mobile_Phone__c);   
          String currentHomephone = unformattedPhone(current.DeltakSRP__Home_Phone__c);
          String currentWorkphone = unformattedPhone(current.DeltakSRP__Work_Phone__c);
          String existingMobilephone = unformattedPhone(existing.deltakSRP__mobile_phone__c);
          String existingHomephone = unformattedPhone(existing.DeltakSRP__Home_Phone__c);
          String existingWorkphone = unformattedPhone(existing.DeltakSRP__Work_Phone__c);*/
          String currentmobilephone = current.DeltakSRP__Mobile_Phone__c;   
          String currentHomephone = current.DeltakSRP__Home_Phone__c;
          String currentWorkphone = current.DeltakSRP__Work_Phone__c;
          String existingMobilephone = existing.deltakSRP__mobile_phone__c;
          String existingHomephone = existing.DeltakSRP__Home_Phone__c;
          String existingWorkphone = existing.DeltakSRP__Work_Phone__c;
          return 
            ((current.DeltakSRP__Mobile_Phone__c != null && (currentmobilephone == existingMobilephone || currentmobilephone == existingHomephone || currentmobilephone == existingWorkphone))
            || (current.DeltakSRP__Home_Phone__c != null && (currentHomephone == existingMobilephone || currentHomephone ==existingHomephone || currentHomephone == existingWorkphone))
            || (current.DeltakSRP__Work_Phone__c != null && (currentWorkphone == existingMobilephone || currentWorkphone == existingHomephone || currentWorkphone == existingWorkphone))
            || (current.deltaksrp__Email__c != null && current.deltaksrp__Email__c == existing.deltaksrp__Email__c)) &&
          current.SRP_Student_First_Name__c == existing.DeltakSRP__Student__r.firstname && 
          current.SRP_Student_Last_Name__c == existing.DeltakSRP__Student__r.lastname; 
    }
    
    private static boolean isnonpartialduplicate(Opportunity current, Opportunity existing){
        
        return
        isDuplicateWithoutRegCode(current,existing)  &&  
            (
//                current.DeltakSRP__Lead_Source_ID__c != existing.DeltakSRP__Lead_Source_ID__c && 
                current.DeltakSRP__Academic_Program__c == existing.DeltakSRP__Academic_Program__c
            )
            &&
            current.AccountId == existing.AccountId;
    }
    
     private static boolean ispartialduplicateDiffPartner(Opportunity current, Opportunity existing){
        return 
        isDuplicateWithoutRegCode(current,existing)  && 
            (
        //        current.DeltakSRP__Lead_Source_ID__c == existing.DeltakSRP__Lead_Source_ID__c || 
                current.DeltakSRP__Academic_Program__c == existing.DeltakSRP__Academic_Program__c 
            )
            &&
            current.AccountId != existing.AccountId;
    }
    
    private static boolean isDuplicate(Opportunity current, Opportunity existing){
        
        return
            current.DeltakSRP__Academic_Program__c == existing.DeltakSRP__Academic_Program__c &&
            current.AccountId == existing.AccountId; 
    }
    
    
    private static boolean isDuplicate(SRPMassUploadDataWrapper current, Opportunity existing){
          /*String currentmobilephone = unformattedPhone(current.mobilephone);  
          String currentHomephone = unformattedPhone(current.homephone);
          String currentWorkphone = unformattedPhone(current.workphone);
          String existingMobilephone = unformattedPhone(existing.DeltakSRP__Student__r.MobilePhone);
          String existingHomephone = unformattedPhone(existing.DeltakSRP__Student__r.HomePhone);
          String existingWorkphone = unformattedPhone(existing.DeltakSRP__Student__r.DeltakSRP__Work_Phone__c);
          String existingphone = unformattedPhone(existing.DeltakSRP__Student__r.Phone);*/
          
          String currentmobilephone = current.mobilephone;  
          String currentHomephone = current.homephone;
          String currentWorkphone = current.workphone;
          String existingMobilephone = existing.DeltakSRP__Student__r.MobilePhone;
          String existingHomephone = existing.DeltakSRP__Student__r.HomePhone;
          String existingWorkphone = existing.DeltakSRP__Student__r.DeltakSRP__Work_Phone__c;
          String existingphone = existing.DeltakSRP__Student__r.Phone;
          
        return 
          ((current.mobilephone != null && (currentmobilephone == existingphone || currentmobilephone == existingMobilephone || currentmobilephone == existingHomephone || currentmobilephone == existingWorkphone))
            || (current.homephone != null && (currentHomephone == existingphone || currentHomephone == existingMobilephone || currentHomephone == existingHomephone || currentHomephone == existingWorkphone))
            || (current.workphone != null && (currentWorkphone == existingphone || currentWorkphone ==existingMobilephone || currentWorkphone == existingHomephone || currentWorkphone == existingWorkphone))
            || (current.email != null && (current.email == existing.DeltakSRP__Student__r.Email || current.email == existing.DeltakSRP__Student__r.DeltakSRP__Work_Email__c || current.email == existing.DeltakSRP__Student__r.DeltakSRP__Student_Email__c ))) &&
          current.firstname == existing.DeltakSRP__Student__r.firstname &&
          current.lastname == existing.DeltakSRP__Student__r.lastname;
    }
    
    private static boolean isDuplicate(SRPMassUploadDataWrapper current, Contact existing){
          /*String currentmobilephone = unformattedPhone(current.mobilephone);  
          String currentHomephone = unformattedPhone(current.homephone);
          String currentWorkphone = unformattedPhone(current.workphone);
          String existingMobilephone = unformattedPhone(existing.MobilePhone);
          String existingHomephone = unformattedPhone(existing.homephone);
          String existingWorkphone = unformattedPhone(existing.DeltakSRP__Work_Phone__c);
          String existingphone = unformattedPhone(unformattedPhone(existing.Phone));*/
          
          String currentmobilephone = current.mobilephone;  
          String currentHomephone = current.homephone;
          String currentWorkphone = current.workphone;
          String existingMobilephone = existing.MobilePhone;
          String existingHomephone = existing.homephone;
          String existingWorkphone = existing.DeltakSRP__Work_Phone__c;
          String existingphone = existing.Phone;
          
        return 
          ((current.mobilephone != null && (currentmobilephone == existingphone || currentmobilephone == existingMobilephone || currentmobilephone == existingHomephone || currentmobilephone == existingWorkphone))
            || (current.homephone != null && (currentHomephone == existingphone || currentHomephone == existingMobilephone || currentHomephone == existingHomephone || currentHomephone == existingWorkphone))
            || (current.workphone != null && (currentWorkphone == existingphone || currentWorkphone == existingMobilephone || currentWorkphone == existingHomephone || currentWorkphone == existingWorkphone))
            || (current.email != null && (current.email == existing.Email || current.email == existing.DeltakSRP__Work_Email__c || current.email == existing.DeltakSRP__Student_Email__c ))) &&
          current.firstname == existing.firstname &&
          current.lastname == existing.lastname &&
          current.accountId == existing.AccountId;
    }  
    
    private static Contact getContactInfo(Opportunity opp,Contact contact,Id recTypeId, Map<Opportunity, SRPMassUploadDataWrapper> owrapmap) {
        // If the Lead record in question needs a Contact created
        system.debug('owrapmap>>>>'+owrapmap);
        if(contact == null){
            contact = new Contact(
                FirstName    = owrapmap.get(opp).firstname,
                LastName     = owrapmap.get(opp).lastname,
                Email        = owrapmap.get(opp).email,
                Phone        = owrapmap.get(opp).homephone,
                DeltakSRP__Work_Phone__c= owrapmap.get(opp).workphone,
                HomePhone    = owrapmap.get(opp).homephone,
                RecordTypeId = recTypeId,
                AccountId    = owrapmap.get(opp).accountid,
                DeltakSRP__Employer_Company__c = owrapmap.get(opp).company,
                DeltakSRPSMS__Ok_To_Text__c = false,
                HasOptedOutOfEmail = false,
                donotcall = false,
                LeadSource = owrapmap.get(opp).LeadSource,
                mailingStreet = owrapmap.get(opp).street,
                MailingCountry = owrapmap.get(opp).country,
                mailingPostalCode = owrapmap.get(opp).postalcode,
                mailingcity = owrapmap.get(opp).city,
                mailingstate = owrapmap.get(opp).state,
                DeltakSRP__Job_Title__c = owrapmap.get(opp).title
             );   
             system.debug('created new contact>>>>'+contact); 
        }        
        
        if(owrapmap.get(opp).ownerid != null)
            contact.OwnerId = owrapmap.get(opp).ownerid.trim();
        
        if(contact.DeltakSRP__Work_Phone__c != null) contact.DeltakSRP__Preferred_Phone__c = 'Work';
        if(contact.MobilePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Mobile';
        if(contact.HomePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Home';
        
        return contact;
    }
    /*public static String unformattedPhone(String pnumber){
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
    
    private static Contact getContactInfo(Lead lead,Contact contact,Id recTypeId) {
        // If the Lead record in question needs a Contact created
        if(contact == null){
            contact = new Contact(
                FirstName    = lead.FirstName,
                LastName     = lead.LastName,
                Email        = lead.Email,
                Phone        = lead.Phone,
                MobilePhone  = lead.MobilePhone,
                title     = lead.Title,
                DeltakSRP__Work_Phone__c= lead.DeltakSRP__Work_Phone__c,
                HomePhone    = lead.DeltakSRP__Home_Phone__c,
                RecordTypeId = recTypeId,
                AccountId    = lead.DeltakSRP__Academic_Institution_Lookup__c,
                DeltakSRP__Employer_Company__c = lead.company,
                DeltakSRPSMS__Ok_To_Text__c = lead.DeltakSRPSMS__Ok_To_Text__c,
                HasOptedOutOfEmail = lead.HasOptedOutOfEmail,
                donotcall = lead.DoNotCall,
                LeadSource = lead.LeadSource
             );   
             system.debug('created new contact>>>>'+contact); 
        }        
        
        if(contact.DeltakSRP__Work_Phone__c != null) contact.DeltakSRP__Preferred_Phone__c = 'Work';
        if(contact.MobilePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Mobile';
        if(contact.HomePhone != null) contact.DeltakSRP__Preferred_Phone__c = 'Home';
        
        if(lead.ownerid != null)
            contact.OwnerId = lead.OwnerId;
        
        return contact;
    }
    
    private static boolean isDuplicate(Lead current, Lead existing){
        return 
            isDuplicateWithoutRegCode(current,existing)  &&
            current.DeltakSRP__Academic_Program_Lookup__c == existing.DeltakSRP__Academic_Program_Lookup__c &&
            current.DeltakSRP__Academic_Institution_Lookup__c == existing.DeltakSRP__Academic_Institution_Lookup__c; 
    }
    
    private static boolean isDuplicateWithoutRegCode(Lead current,Lead existing){
        return 
          ((current.Phone != null && (current.Phone == existing.Phone || current.Phone == existing.MobilePhone || current.Phone == existing.DeltakSRP__Home_Phone__c || current.Phone == existing.DeltakSRP__Work_Phone__c))  
            || (current.MobilePhone != null && (current.MobilePhone == existing.Phone || current.MobilePhone == existing.MobilePhone || current.MobilePhone == existing.DeltakSRP__Home_Phone__c || current.MobilePhone == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.Phone || current.DeltakSRP__Home_Phone__c == existing.MobilePhone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Home_Phone__c || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.Phone || current.DeltakSRP__Work_Phone__c == existing.MobilePhone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Home_Phone__c || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.Email != null && current.Email == existing.Email)) &&
          current.FirstName == existing.FirstName &&
          current.LastName == existing.LastName; 
    }   
    
    private static boolean isDuplicate(Lead current, Contact existing){
        return 
          ((current.Phone != null && (current.Phone == existing.Phone || current.Phone == existing.MobilePhone || current.Phone == existing.HomePhone || current.Phone == existing.DeltakSRP__Work_Phone__c)) 
            || (current.MobilePhone != null && (current.MobilePhone == existing.Phone || current.MobilePhone == existing.MobilePhone || current.MobilePhone == existing.HomePhone || current.MobilePhone == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Home_Phone__c != null && (current.DeltakSRP__Home_Phone__c == existing.Phone || current.DeltakSRP__Home_Phone__c == existing.MobilePhone || current.DeltakSRP__Home_Phone__c == existing.HomePhone || current.DeltakSRP__Home_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.DeltakSRP__Work_Phone__c != null && (current.DeltakSRP__Work_Phone__c == existing.Phone || current.DeltakSRP__Work_Phone__c == existing.MobilePhone || current.DeltakSRP__Work_Phone__c == existing.HomePhone || current.DeltakSRP__Work_Phone__c == existing.DeltakSRP__Work_Phone__c))
            || (current.Email != null && (current.Email == existing.Email || current.Email == existing.DeltakSRP__Work_Email__c || current.Email == existing.DeltakSRP__Student_Email__c ))) &&
          current.FirstName == existing.FirstName &&
          current.LastName == existing.LastName &&
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
        
        if(pnumber.length() >= 10 && phonenumber.length() >= 0)
            formattedNumber = '('+phonenumber.substring(0, 3) + ') ' +phonenumber.substring(3, 6) + '-' + phonenumber.substring(6, 10);

        return formattedNumber;         
    }*/
}