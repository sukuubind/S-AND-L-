public without sharing class SRPManualInquiryController {
/**********************
     * Variables
     **********************/
    //the list of Accounts to choose from
    public List<SelectOption> campuses {get; set ;}
    public List<SelectOption> countries {get; set ;}
    public List<Account> campusSobjs {get; set;}    
    public string campusId {get; set;}
   
    //the list of Programs to choose from
    public List<DeltakSRP__Academic_Program__c> programSobjs {get; set;}   
    public List<SelectOption> programs {get; set;}
    public string programId {get; set;}
    
    //the list of Specializations to choose from
    public List<DeltakSRP__Academic_Specialization__c> specializationObjs {get; set;}
    public List<SelectOption> specializations {get; set;}
    public string specializationId{get; set;}
        
    // Campaign Variables
    //the list of campaigns to choose from  
    public List<string> campaignCustomSettings {get; set;}
    
    public List<SelectOption> campaignOptions {
        get;
        set; 
    }
    
    //the selected campaign code
    public string campaignCode{get; set;}
    
    //indicates whether to show the ReferralNotice or not  
    public boolean renderReferralNotice {get;set;} 
    
    
    //Form input boxes
    public string StudentName {get;set;}
    public string StudentFirstName {get;set;}
    public string StudentLastName {get;set;}
    public string company {get; set;}
    
    public List<SelectOption> timeframeOptions {
        get {        
            return SRPNewInquiryUtil.getTimeFrames();
        }        
        set;
    }
    public string selectedTimeframe {get; set;}
    
    public List<SelectOption> genderOptions {
        get {
            List <SelectOption>options = new List<SelectOption>();
            options.add( new SelectOption( '', Label.None_Option));
            options.add( new SelectOption( 'M', Label.Male_Option));
            options.add( new SelectOption( 'F', Label.Female_Option));            
            return options;
        }
        
        set;
    }    
    public string selectedGender{get;set;}
    public string OppId {get; set;}
    public string Email{get;set;}
    public string Home_Phone{get;set;}
    public string Work_Phone{get;set;}
    public string Mobile_Phone{get;set;}
    public string Address{get;set;}
    public string City{get;set;}    
    public string State{get;set;}
    public string Zip{get;set;}
    public string Country{get;set;}
    public string Gender{get;set;}
    public string OwnerID{get;set;} 
    public boolean RetainOwner{get;set;}
    public string retainOwnerHelp {get{ return Label.NewInquiry_RetainOwnershipMessage;} set;}
    private Map <string, string> timeFrameMap;
    public Opportunity o;
    
    /**********************
    * Constructor
    **********************/
    
    public void generateCountryOptions(){
    	system.debug('inside generate country options>>>>');
    	countries = new List<SelectOption>();
        countries.add( new SelectOption( '', Label.None_Option)); 
        
        Map<String, SRP_Phone_Codes__c> phonecodes = SRP_Phone_Codes__c.getall();    
        
        for(String s: phonecodes.keyset()){
        	if(phonecodes.get(s).is_country__c == true)
        		countries.add( new SelectOption(s.toUpperCase(), s.toUpperCase()));
        }
        
        countries.sort();
        
    }
    
    public SRPManualInquiryController() {
        
        OppId = Apexpages.currentPage().getParameters().get('Id');
        system.debug('OppId>>>>'+OppId);
        
        generateCountryOptions();
        
        
        if(OppId != null){
            o = [Select ownerid, AccountId, Deltaksrp__student__c from Opportunity where Id=: oppId LIMIT 1];
            campusId = o.accountId;
            campuschanged();
        }
        
        if(OppId == null){
            RetainOwner = true;
            retainOwnershipChanged();
            
            //List <SelectOption> campOptions = new List<SelectOption>();
            campaignOptions = new List<SelectOption>();
                    
            List<Campaign_Administration__c> cplist = [Select campaign_Name__c, Campaign_Code__c, Name from Campaign_Administration__c where Campaign_Code__c != null ORDER BY Campaign_Code__c];       
                
            campaignOptions.add(new SelectOption(Label.None_Option, Label.None_Option));
             
            //load the list of campaigns from the Custome Settings
            for (Campaign_Administration__c campCode : cplist) {
            //for (Campaign_Picklist__c campCode : campaignCustomSettingsMap) {
                campaignOptions.add(new SelectOption(campCode.Campaign_Code__c, campCode.Campaign_Code__c));
            }
            System.debug('campaignOptions' + campaignOptions);
            campaignCode = campaignOptions[0].getValue();
            
            campaignChanged();
        }    
        
        //renderReferralNotice = true;
    }
    
    /***********************************************************************
     * Called when the retainOwnerShip Checkbox is clicked
     ************************************************************************/
    public void retainOwnershipChanged() {
        if (RetainOwner) {
            campuses = SRPNewInquiryUtil.loadCampusContactCampuses(true);
        }
        
        else {
            campuses = SRPNewInquiryUtil.loadAllCampuses(true);
        }
        
        campusId = campuses[0].getValue();
        campusChanged();
    }
    
    /***********************************************************************
     * Called when the campus dropdown selection changes on the page
     ************************************************************************/
    public void campusChanged() {
        System.debug('!!! campusid changed to ' + campusId);
        programs = SRPNewInquiryUtil.loadPrograms(campusId);        
        
        if(programs.size() > 0){
            programId = programs[0].getValue();
            programChanged();
        } 
    }
    
    /***********************************************************************
     * Called when the program dropdown selection changes on the page
     ***********************************************************************/
    public void programChanged() {
        specializations = SRPNewInquiryUtil.loadSpecializations(programId);
    }
    
    /***********************************************************************
     * Called when the campaign changes on the page
     ***********************************************************************/
    public void campaignChanged() {
        
        
        if (campaignCode != null && campaignCode.toLowerCase().contains('referral')) {
            renderReferralNotice = true;
        }
        
        else {
            renderReferralNotice = false;
        }

        System.debug('!!! campaignChanged to ' + campaignCode + ' !!!');
        
    }
    
    // to verify that first name is entered properly
    
    public Boolean validateFisrtName(){
    
      //  String fNameAlertLabel = System.Label.New_Inquiry_Form_student_fname_error_message;
        Integer len = ( StudentFirstName != null ? StudentFirstName.length() : 0);
        if(len < 2)
        {
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_student_fname_error_message));
            return false;
    
        }
         else   
        {
            return true;
        }
    return false;                                   
    
    }
    
  // to varify that last name is entered properly
      
    public Boolean validateLastName(){  
    
     Integer len = (StudentLastName != null ? StudentLastName.length() : 0);
        if(len < 2)
        {
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_student_lname_error_message));
            return false;
    
        }
         else   
        {
            return true;
        }
    return false; 
    
    }
   
   // to verify campus is selected or not
   
    public Boolean validateCampus(){
    
        if (campusId == '-None-' || campusId == '')
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_campus_error_message));
             return false;
        }
        else   
        {
            return true;
        }
        return false;
        
    } 
    
    // to verify program is selected or not
    
   public Boolean validateProgram(){ 
     
      if (programId == '-None-' || programId == '')
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_Program_Error_message));
             return false;
        }
        else   
        {
            return true;
        }
        return false;
     
     }
     
     // to verify if specialization is selected or not
     
     public Boolean validateSpecialization(){ 
     
     if (specializationId == '-None-' || specializationId == '')
        {
        	List<DeltakSRP__Academic_Program__c> programSobjs  = new List<DeltakSRP__Academic_Program__c>();
        	programSobjs = [SELECT Id, Name, deltakSRP__Require_Specialization__c
                        FROM DeltakSRP__Academic_Program__c
                        WHERE Id =: programid];
             if(programSobjs.size()>0 && programSobjs[0].deltakSRP__Require_Specialization__c == true){          
             	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_specialization_error_message));
             	return false;
             }else
             	return true;	
        }
        else   
        {
            return true;
        }
        return false;
     
     
     }
     
     // to verify if timeframe is selected 
     
   public Boolean validateTimeframe(){ 
     
     if (selectedTimeframe == '-None-' || selectedTimeframe == '' || selectedTimeframe == ' ' || selectedTimeframe == null)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_timeframe_error_message));
             return false;
        }
        else   
        {
            return true;
        }
        return false;
  
    }
     

     
     //to verify format of email is correct
     
     public Boolean validateEmail(){ 
 //    System.debug('in validateemail$$$$');
     Integer len = (Email !=null ? Email.length() : 0);
     
     // apply following validation if email is entered
         if(len > 0)
         {
              
               if(!Pattern.matches('^([a-z0-9+._-]+@)([a-z0-9-]+\\.)+(a(?:[cdefgilmnoqrstuwxz]|ero|(rp|si)a)$|(b([abdefghijmnorstvwyz]|iz))$|(c([acdfghiklmnoruvxyz]|at|o(m|op)))$|(d[ejkmoz])$|(e([ceghrstu]|du))$|(f[ijkmor])$|(g([abdefghilmnpqrstuwy]|ov))$|(h[kmnrtu])$|(i([delmnoqrst])|(n(fo|t)))$|(j([emop]|obs))$|(k[eghimnprwyz])$|(l[abcikrstuvy])$|(m([acdeghklmnopqrstuvwxyz]|il|obi|useum))$|(n([acefgilopruz]|ame|et))$|o(m|rg)$|(p([aefghklmnrstwy]|ro))$|(qa)$|(r[eosuw])$|(s[abcdeghijklmnortuvyz])$|(t([cdfghjklmnoprtvwz]|(rav)?el))$|(u[agkmsyz])$|(v[aceginu])$|(w[fs])$|(y[etu])$|(z[amw])$)+', Email.toLowerCase()))
                 {
               //      System.debug('in pattern$$$$');
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_email_missing_text));
                     return false;
                 }
                 else
                 {
                     return true;
                 }
         
         }
      // give error if email is not entered
         else
         {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_email_error_message));
              return false;
         }
     
     }
   
      // to validate format of home phone number
      
    public Boolean validateHomePhone(){
    
    Integer len = (Home_Phone != null ? Home_Phone.length() : 0);
        if(len<10 || len>15) 
        {
        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_home_Phone_error_message));
            return false;
            
        }
        else   
        {
            return true;
        }
       
    }
      
   // to validate format of mobile number
    
    public Boolean validateMobilePhone(){
    
    Integer len = 0;
    len = (Mobile_Phone != null ? Mobile_Phone.length() : 0);
    
    if(len > 0)
    {
    
        if(len<10 || len>25) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_mobile_phone_error_message));
            return false;
        }
        
        else
        {
            return true;
        }
        
    }
    else
    {
        return true;
    }
    
    }
    
    
    // to validate format of work phone number
    
   public Boolean validateWorkPhone(){
    
    Integer len = (Work_Phone != null ? Work_Phone.length() : 0);
    
        if(len > 0)
        {
        
            if(len<10 || len>15) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_workphone_error_message));
                return false;
            }
            
            else
            {
                return true;
            }
            
        }
        else
        {
            return true;
        }
    
    }
    
    public Boolean validateCampaign(){
        system.debug('campaigncode>>>>'+campaigncode);
        if((campaignCode == '-None-' || campaignCode == null) && (oppid == null || oppid==''))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_campaign_error_message));
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public Boolean validateCountry(){
        system.debug('country>>>>'+country);
        if(country==null || country=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.New_Inquiry_Form_country_error_message));
            return false;
        }
        else
        {
            return true;
        }
    }
    
     
    public Pagereference saveSRMLead(){
       
    if(validateFisrtName() == true && validateLastName() == true && validateCampus() == true && validateProgram() == true && validateSpecialization() == true && validateTimeframe() == true && validateEmail() == true && validateHomePhone() == true && validateMobilePhone() == true && validateWorkPhone() == true && validateCampaign() == true && validateCountry()==true)
    {
 
        try{
            Lead l = new Lead();
            
            if(OppId==null && retainowner)
                l.ownerId = userinfo.getUserId();
            else{
            	DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
            	l.ownerid = partnersettings.SRP_Lead_Engine_UserId__c;
            }    
            
            if(studentfirstname!=null && studentfirstname.length() > 1){
            	l.firstname = studentfirstname.substring(0,1).toUpperCase()+studentfirstname.substring(1,studentfirstname.length()).toLowerCase();
            }
            
            if(studentlastname != null && studentlastname.length() > 1){	
            	l.lastname = studentlastname.substring(0,1).toUpperCase()+studentlastname.substring(1,studentlastname.length()).toLowerCase();
            }
            l.deltaksrp__academic_institution_lookup__c = campusid;
            l.DeltakSRP__Academic_Program_Lookup__c = programid;
            l.company = 'none';
            
            List<DeltakSRP__Academic_Specialization__c> asp = new List<DeltakSRP__Academic_Specialization__c> ();
            asp = [Select Id from DeltakSRP__Academic_Specialization__c 
                    where Deltaksrp__Specialization_Abbreviation__c = :specializationid];
                
            if(asp.size() >0)       
                l.DeltakSRP__Academic_Specialization_Lookup__c = asp[0].Id;
            
            l.DeltakSRP__Interest_Timeframe__c = selectedTimeframe;
            l.DeltakSRP__Gender__c = selectedGender;
            l.email = email;
            l.mobilephone = mobile_phone;
            l.DeltakSRP__Home_Phone__c = home_phone;
            l.DeltakSRP__Work_Phone__c = work_phone;
            l.street = address;
            l.city = city;
            l.state = state;
            l.country = country;
            l.postalcode = zip;
            l.DeltakSRP__Inquiry_Rating__c = 'High';
            l.DeltakSRP__is_srp_record__c = true;
            
            system.debug('retainowner>>>>'+retainowner);
            system.debug('l.DeltakSRP__Home_Phone__c>>>>'+l.DeltakSRP__Home_Phone__c);
            
            if(OppId != null){
                l.RFI_Campaign_code__c = 'SG Referral';
                l.SRP_Retain_Ownership__c = true;
                l.ownerid = o.ownerid;
            }else{
                l.rfi_campaign_code__c = campaigncode;
                l.SRP_Retain_Ownership__c = retainowner;
            }
            
            system.debug('l.deltaksrp__is_duplicate__c>>>>'+l.deltaksrp__is_duplicate__c);
            RecordType rt = [Select Id from recordtype where name = 'SRP Lead' LIMIT 1];
            l.recordtypeId = rt.Id;
          
          /* Fadi added for Assignment Rules  
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        if(AR != null && AR.Id != null)
        {
            l.setOptions(dmlOpts);
        }    */
              
            insert l;
            
            try{
                lead l2 = new Lead();
                l2 = [Select convertedOpportunityId from lead where id=:l.Id];
                system.debug('l2>>>>'+l2);
                if(l2.convertedopportunityId !=null){
                    
                    /*Opportunity opp = [Select Id, SRP_Referred_by_Opportunity__c, Deltaksrp__referred_by__c, SRP_Retain_Ownership__c, DeltakSRP__webschedulerstatus__c, DeltakSRP__Student__c from Opportunity where Id =: l2.convertedopportunityid];
                     Contact c = [Select Id, DeltakSRP__Work_Phone__c, mobilephone, homephone from Contact where Id=:opp.DeltakSRP__Student__c];
                    system.debug('c>>>>'+c);
                   if(work_phone!=null)
                        c.DeltakSRP__Work_Phone__c = work_phone;
                    if(mobile_phone!=null)
                        c.mobilephone = mobile_phone;
                    if(home_phone!=null)
                        c.homephone = home_phone;
                        
                    update c;
                    system.debug('c updated>>>>'+c);*/
                    
                    //system.debug('retainowner>>>>'+retainowner);
                    //opp.SRP_Retain_Ownership__c = retainowner;
                    
                    if(oppId != null){
                    	Opportunity opp = new Opportunity(Id=l2.convertedopportunityId);
                        //opp.SRP_Retain_Ownership__c = true;
                        opp.SRP_Referred_by_Opportunity__c = oppId;
                        opp.Deltaksrp__referred_by__c = o.deltaksrp__student__c;
                        update opp;
                    }   
                        
                    
                    
                    PageReference pg= new PageReference('/'+l2.convertedopportunityId);
                    pg.setRedirect(true);
                    return pg;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Conv_Oppty_Not_Found));
                    return null;
                }   
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Lead Found'));
                return null;
            }   
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()));
            return null;
        }   
        
        }
        return null;
    }
    
    
    
    /***********************************************************************
     * Called when the cancel button is pressed
     ***********************************************************************/
    public PageReference Cancel() {
        
        System.debug('Cancel --> campaignCode ' + campaignCode);
        PageReference pg;
        if(OppId == null)
            pg= new PageReference('/home/home.jsp');
        else
            pg= new PageReference('/'+OppId);   
                pg.setRedirect(true);
                return pg;
    }
}