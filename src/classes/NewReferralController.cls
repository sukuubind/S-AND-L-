/*
 * Chris Baker
 * 
 * 12/6/10
 *
 * This class is a controller for NewReferral.page
 */
 
public class NewReferralController {
	
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
    private Opportunity opp;
    
	/**********************
	* Constructor
	**********************/
	public NewReferralController(ApexPages.StandardController controller) {
        Opportunity oppStd = (Opportunity)controller.getRecord();
        opp = [SELECT Id, Owner.isActive, Person__c, AccountID FROM Opportunity WHERE Id = :oppStd.Id LIMIT 1]; 
        System.debug('Opp --> ' + opp);
        RetainOwner = true;
        campuses = NewInquiryUtil.loadCurrentCampus(opp.AccountId, false);
        campusId = opp.AccountId;
        campusChanged();
    }
    
    /***********************************************************************
	 * Called when the campus dropdown selection changes on the page
	 ************************************************************************/
	public void campusChanged() {
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
        
        //if the specialization is set to No Specialization then just send the program abbrev,
        //otherwise send <ProgramAbbrev>[space]<SpecializationAbbrev>
        string program_spec = (specializationId == 'No Specialization') ? program[0].Abbrev__c : program[0].Abbrev__c + ' ' + specializationId;
        
        //get the sales stage
        string salesStage = NewInquiryUtil.getSalesStage(selectedTimeFrame);
        
        System.debug('salesStage --> '+salesStage);
        
        //get the email addresses to send to
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
        
        //BEGIN CR64 - Adding Campaign Code - CB    
        'uCampaign='+ NewInquiryUtil.getCampaignCode ('New Referral Page') + '\n' +
        //END CR64 - Adding Campaign Code - CB
                       
        'uleaddate= '+System.now().format('yyyyMMdd') + '\n' + 
        'uleadtime= '+System.now().format('h:mm a') + '\n';
        
        body += 'OwnerId=' + NewInquiryUtil.setNewReferralOwner(opp) + '\n';
        
        body += 'referredByOpportunity='+opp.Id+'\n'+
		'referredByPerson='+opp.Person__c+'\n'+
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
    	
    	try {
	    	if (successful) {
				PageReference pg= new PageReference('/apex/ManualLeadPageFinish?id='+ApexPages.currentPage().getParameters().get('id'));
				pg.setRedirect(true);
				return pg;   
	    	}
	    	else {
	    		return null;
	    	}
    	}    	
    	catch(Exception e){
			System.Debug('Error' + e);
			return null;
		}
	}
	/***********************************************************************
	 * Called when the cancel button is pressed
	 ***********************************************************************/
	public PageReference Cancel() {
		 PageReference pg= new PageReference('/'+opp.Id);
                pg.setRedirect(true);
                return pg;
	}
}