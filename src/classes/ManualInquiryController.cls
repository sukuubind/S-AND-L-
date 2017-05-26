/*
 * Chris Baker
 * 
 * 12/6/10
 *
 * This class is a controller for ManualInquiry.page
 */ 
 
public class ManualInquiryController {
	
	/**********************
	 * Variables
	 **********************/
	//the list of Accounts to choose from
	public List<SelectOption> campuses {get; set ;}
    public List<Account> campusSobjs {get; set;}    
    public string campusId {get; set;}
   
    //the list of Programs to choose from
    public List<Academic_Program__c> programSobjs {get; set;}   
    public List<SelectOption> programs {get; set;}
    public string programId {get; set;}
    
    //the list of Specializations to choose from
    public List<Academic_Specialization__c> specializationObjs {get; set;}
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
	
	public List<SelectOption> timeframeOptions {
        get {        
			return NewInquiryUtil.getTimeFrames();
        }        
        set;
    }
    public string selectedTimeframe {get; set;}
    
    public List<SelectOption> genderOptions {
        get {
            List <SelectOption>options = new List<SelectOption>();
            options.add( new SelectOption( '', '-None-'));
            options.add( new SelectOption( 'M', 'Male'));
            options.add( new SelectOption( 'F', 'Female'));            
            return options;
        }
        
        set;
    }    
    public string selectedGender{get;set;}
    
    public string Email{get;set;}
    public string Home_Phone{get;set;}
    public string Work_Phone{get;set;}
    public string Mobile_Phone{get;set;}
    public string Address{get;set;}
    public string City{get;set;}    
    public string State{get;set;}
    public string Zip{get;set;}
    public string Gender{get;set;}
    public string OwnerID{get;set;} 
    public boolean RetainOwner{get;set;}
    public string retainOwnerHelp {get{ return 'Check this box if you would like to own this inquiry.';} set;}
    private Map <string, string> timeFrameMap;
    
	/**********************
	* Constructor
	**********************/
	public ManualInquiryController() {
        RetainOwner = true;
        retainOwnershipChanged();
        
        //List <SelectOption> campOptions = new List<SelectOption>();
        campaignOptions = new List<SelectOption>();
		Campaign_Picklist__c [] campaignCustomSettingsMap  = 
			[SELECT Name, Campaign_Code__c FROM Campaign_Picklist__c
			WHERE Page__c = 'New Inquiry'
			ORDER BY Name ASC ];
			
			
		/*Campaign [] campaignCustomSettingsMap  = 
			[SELECT Name, Campaign_Code__c FROM Campaign
			WHERE isActive = True AND Lowest_Level_in_Hierarchy__c = True];*/
			
		campaignOptions.add(new SelectOption('-None-', '-None-'));
		
		//load the list of campaigns from the Custome Settings
		for (Campaign_Picklist__c campCode : campaignCustomSettingsMap) {
		//for (Campaign campCode : campaignCustomSettingsMap) {
			campaignOptions.add(new SelectOption(campCode.Campaign_Code__c, campCode.Name));
		}
		System.debug('campaignOptions' + campaignOptions);
		campaignCode = campaignOptions[0].getValue();
		
        campaignChanged();
        
        //renderReferralNotice = true;
    }
    
    /***********************************************************************
	 * Called when the retainOwnerShip Checkbox is clicked
	 ************************************************************************/
    public void retainOwnershipChanged() {
    	if (RetainOwner) {
    		campuses = NewInquiryUtil.loadCampusContactCampuses(true);
    	}
    	
    	else {
    		campuses = NewInquiryUtil.loadAllCampuses(true);
    	}
    	
    	campusId = campuses[0].getValue();
    	campusChanged();
    }
    
    /***********************************************************************
	 * Called when the campus dropdown selection changes on the page
	 ************************************************************************/
	public void campusChanged() {
		System.debug('!!! campusid changed to ' + campusId);
    	programs = NewInquiryUtil.loadPrograms(campusId);    	
    	
    	if(programs.size() > 0){
            programId = programs[0].getValue();
            programChanged();
        } 
    }
    
    /***********************************************************************
	 * Called when the program dropdown selection changes on the page
	 ***********************************************************************/
    public void programChanged() {
    	specializations = NewInquiryUtil.loadSpecializations(programId);
    }
    
    /***********************************************************************
	 * Called when the campaign changes on the page
	 ***********************************************************************/
    public void campaignChanged() {
    	
    	
    	if (campaignCode.toLowerCase().contains('referral')) {
    		renderReferralNotice = true;
    	}
    	
    	else {
    		renderReferralNotice = false;
    	}

		System.debug('!!! campaignChanged to ' + campaignCode + ' !!!');
		
    }
    
    /***********************************************************************
	 * Called when the Save button is pressed
	 ***********************************************************************/
	public PageReference saveOpp() {
		//get the school name        
        Account [] school = [select Goldmine_Key5__c FROM Account WHERE Id = :campusId];
        
        if (school.size() == 0) {
        	System.debug('---> Error: List of schools is empty');
        	return null;
        }
        
        //get the program name
        Academic_Program__c [] program = [select Abbrev__c FROM Academic_Program__c WHERE Id = :programId];
        
        if (program.size() == 0) {
        	System.debug('---> Error: List of programs is empty');
        	return null;
        }
        
        string program_spec = (specializationId == 'No Specialization') ? program[0].Abbrev__c : program[0].Abbrev__c + ' ' + specializationId;
        
        string salesStage;
        salesStage = NewInquiryUtil.getSalesStage(selectedTimeFrame);
        System.debug('salesStage --> '+salesStage);
        
        List <string> emailAddressList = NewInquiryUtil.getEmalAddresses();
        
        string body='[Instructions]\n'+
        'DupCheck1=Email\n'+
        'DupCheck2=Key5\n'+
        'OnNewAttachTrack=WebLead\n'+
        'OnDupAttachTrack=WebLead Duplicate\n'+
        'SaveThis=Lead from Web Import\n'+
        '\n\n[Data]\n'+
        'Contact='+StudentName+'\n'+
        'Address1='+Address+'\n'+               
        'ucourseint='+program_spec+'\n'+   
        'City='+City+'\n'+
        'State='+State+'\n'+
        'Zip='+Zip+'\n'+
        'Phone1='+Work_Phone+'\n'+
        'Phone2='+Home_Phone+'\n'+
        'Phone3='+Mobile_Phone+'\n'+
        'Email='+Email+'\n'+ 
        'ugender='+selectedGender+'\n'+                                     
        'Key2='+ salesStage + '\n'+
        'Key5='+school[0].Goldmine_Key5__c+'\n' +
        'uCampaign=' + campaignCode + '\n' + 
        'uleaddate= '+System.now().format('yyyyMMdd') + '\n' + 
        'uleadtime= '+System.now().format('h:mm a') + '\n';
         
        if (RetainOwner) {
        	body += 'OwnerId=' + userinfo.getUserId() + '\n';
        }
        
        body +=
        '\n[ContSupp]\n'+
        'cs1_RecType=P\n'+
        'cs1_Contact=E-mail Address\n' + 
        'cs1_contsupref='+Email;
                 
        boolean successful = NewInquiryUtil.sendToLeadRouter(
        	'Goldmine Population',
        	body,
        	'Goldmine Population',
        	'noreply@deltakedu.com',
        	emailAddressList
    	);
    	
    	if (successful) {
			PageReference pg= new PageReference('/apex/ManualLeadPageFinish?id='+ApexPages.currentPage().getParameters().get('id'));
			pg.setRedirect(true);
			return pg;   
    	}
    	else {
    		return null;
    	}
	}
	
	/***********************************************************************
	 * Called when the cancel button is pressed
	 ***********************************************************************/
	public PageReference Cancel() {
		
		System.debug('Cancel --> campaignCode ' + campaignCode);
		 PageReference pg= new PageReference('/home/home.jsp');
                pg.setRedirect(true);
                return pg;
	}
}