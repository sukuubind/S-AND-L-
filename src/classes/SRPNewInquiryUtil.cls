public with sharing class SRPNewInquiryUtil {
    /*************************************************
     * Load all campuses
     *************************************************/
    public static List <SelectOption> loadAllCampuses(boolean noneOption) {
        System.debug('---> Loading all campuses...');
        //get the campuses
        Account [] campusSobjs = 
            [SELECT Id, Name
            FROM Account
            WHERE recordtype.name = 'SRP Academic Institution' and Display_on_New_Inquiry_Page__c = true
            ORDER BY Name
            ];
                        
        return loadCampusSelection(campusSobjs, noneOption);
    }
    
    /**************************************************
     * Load Campuses except for the current one
     *********************************************************/
    public static List <SelectOption> loadCampuses(boolean noneOption, Id AccountID) {
        System.debug('---> Loading campuses...');
         
        //get the campuses
        Account [] campusSobjs = 
            [SELECT Id, Name
            FROM Account
            WHERE Display_on_New_Inquiry_Page__c = True 
            and recordtype.name = 'SRP Academic Institution'
            AND Id <> :AccountID              
            ORDER BY Name
            ];
                        
        return loadCampusSelection(campusSobjs, noneOption);
    }
    
    /*************************************************
     * Load only the campus sent to the method
     *************************************************/
    public static List <SelectOption> loadCurrentCampus(Id school, boolean noneOption) {
        System.debug('---> Loading current campuse with ID '+school);
        
        //get the campuses
        Account [] campusSobjs = 
            [SELECT Id, Name
            FROM Account
            WHERE Display_on_New_Inquiry_Page__c = True
            AND Id = :school                       
            ORDER BY Name
            ];
                        
        return loadCampusSelection(campusSobjs, noneOption);
    }
    
    /*************************************************
     * Load the campuses based upon the campus contacts
     *************************************************/
    public static List <SelectOption> loadCampusContactCampuses(boolean noneOption) {
        System.debug('---> Loading only campuses from Campus Contact campuses...');
        Campus_Contacts__c [] ccList = 
            [SELECT Organization__c
            FROM Campus_Contacts__c
            WHERE Active_User__c = 'ACTIVE'
            AND Employee__c = :userinfo.getUserId()
            AND Retain_Ownership_Available__c = True];
        
        Set <Id> CCSchoolSet = new Set <Id>();
        for (Campus_Contacts__c cc : ccList) {
            CCSchoolSet.add(cc.Organization__c);
        } 
        
        //get the campuses
        Account [] campusSobjs = 
            [SELECT Id, Name
            FROM Account
            WHERE Display_on_New_Inquiry_Page__c = True
            AND Id In :CCSchoolSet AND recordtype.name = 'SRP Academic Institution'
            ORDER BY Name
            ];
        
        return loadCampusSelection(campusSobjs, noneOption);
    }
    
    /*************************************************
     * Load the campuses selections for the dropdown on the page 
     *************************************************/
    public static List <SelectOption> loadCampusSelection(Account [] campusSobjs, boolean noneOption ) {
        List <SelectOption> campuses = new List<SelectOption>();        
        
        if (noneOption) {
            campuses.add(new SelectOption(Label.None_Option,Label.None_Option));
        }                  
        
        //Add the campuses into the dropdown
        for(Account camp : campusSobjs){            
            campuses.add(new SelectOption(camp.Id+'', camp.Name));
        }
        System.debug('---> Campus dropdown List : '+campuses);        
        return campuses;
    }
    
    /*************************************************
     * Load the program selections for the dropdown on the page 
     *************************************************/
    public static List <SelectOption> loadPrograms(string campusId) {
        List<SelectOption> programs = new List<SelectOption>();       
        System.debug('---> Loading programs where School__c = ' + campusId);
        
        DeltakSRP__Academic_Program__c [] programSobjs = [SELECT Id, Name, deltakSRP__Program_Title__c, DeltakSRP__Abbrev__c
                        FROM DeltakSRP__Academic_Program__c
                        WHERE DeltakSRP__School__c = :campusId
                        AND DeltakSRP__Active__c = TRUE
                        ORDER BY Name];                   
                                       
        programs.add(new SelectOption(Label.None_Option,Label.None_Option));
               
        for(DeltakSRP__Academic_Program__c prog : programSobjs){
            programs.add(new SelectOption(prog.Id+'', prog.deltakSRP__Program_Title__c));
        }
        
        return programs;
    }
    
    /*************************************************
     * Load the specialization selections for the dropdown on the page 
     *************************************************/
    public static List <SelectOption> loadSpecializations(string programId) {
        System.debug('---> Loading specializations where Id = ' + programId);
        List<SelectOption> specializations = new List<SelectOption>();
        
        specializations.add(new SelectOption(Label.None_Option, Label.None_Option));
            
        DeltakSRP__Academic_Specialization__c [] specializationObjs = [SELECT Id, DeltakSRP__Specialization_Title__c, DeltakSRP__Specialization_Abbreviation__c, Name 
                              FROM DeltakSRP__Academic_Specialization__c
                              WHERE DeltakSRP__Academic_Program__c = :programId
                              AND DeltakSRP__Active__c = TRUE and DeltakSRP__Specialization_Abbreviation__c!=null and DeltakSRP__Specialization_Title__c!=null];
        
        Boolean flag = false;
        for(DeltakSRP__Academic_Specialization__c spec: specializationObjs){
            flag = true;
            if (spec.DeltakSRP__Specialization_Abbreviation__c != null) {
                specializations.add(new SelectOption(spec.DeltakSRP__Specialization_Abbreviation__c, spec.DeltakSRP__Specialization_Title__c));
            }
            
            else {
                specializations.add(new SelectOption('No Specialization', spec.DeltakSRP__Specialization_Title__c));
            }
        }
        
        if(flag == false){
            specializations.remove(0);
            specializations.add(new SelectOption('--None--', '--None--'));
        }
            
        
        return specializations;        
    }
    
    /*************************************************
     * Load the timeframe selections for the dropdown on the page 
     *************************************************/
    public static List <SelectOption> getTimeFrames() {
        List <SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( Label.None_Option, Label.None_Option));
        Schema.DescribeFieldResult F = Opportunity.Interest_Timeframe__c.getDescribe();
        List <Schema.PicklistEntry> timeFrameList = F.getPicklistValues();
        
        for (Schema.PicklistEntry timeFrame : timeFrameList) {
            options.add( new SelectOption( timeFrame.getValue(), timeFrame.getValue()));
        }
        
        return options;
    }
    
    
     
    /********************************************************
    * Set owner of a new referral
    *********************************************************/
    public static Id setNewReferralOwner(Opportunity o) {
        if (o.Owner.isActive) {
            return o.OwnerId;
        }
        
        else {
            return userinfo.getUserId();
        }
    }
    
    /********************************************************
    * Get the campaign code - CR64 - CB 
    *********************************************************/
    public static string getCampaignCode(string key) {
        string campaignCode;        
        Manual_Inquiry_Campaign__c campaign = Manual_Inquiry_Campaign__c.getValues(key);
        campaignCode = campaign.Campaign_Code__c;       
        return campaignCode;
    }
    
}