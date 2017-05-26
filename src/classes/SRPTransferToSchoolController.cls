/*
 * Chris Baker
 * 
 * 12/6/10
 *
 * This class is a controller for TransferToSchool.page
 */
 
public class SRPTransferToSchoolController {
	
	/**********************
	 * Variables
	 **********************/
	//the list of Accounts to choose from
	public List<SelectOption> campuses {get; set ;}
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
     
	
	//Form input boxes
	public string StudentName {
		get {
			if(opp.deltaksrp__student__r.firstname != null)
				return opp.deltaksrp__student__r.firstname + ' ' + opp.deltaksrp__student__r.lastname;
			else
				return '';
		}
		set;}
	
	public List<SelectOption> timeframeOptions {
        get {        
			return SRPNewInquiryUtil.getTimeFrames();
        }        
        set;
    }
    public string selectedTimeframe {
    	get {
    		return opp.DeltakSRP__Interest_Timeframe__c;
    	}	
		set;
	}
    
    public List<SelectOption> genderOptions {
        get {
            List <SelectOption>options = new List<SelectOption>();
            options.add( new SelectOption( '', '-None-'));
            options.add( new SelectOption( 'Male', 'Male'));
            options.add( new SelectOption( 'Female', 'Female'));            
            return options;
        }
        
        set;
    }    
    public string selectedGender{get;set;}
    public string firstname{get; set;}
    public string lastname {get; set;}
    public string Email{get; set;}
    public string Home_Phone{get; set;}
    public string Work_Phone{get; set;}
    public string Mobile_Phone{get; set;}
    public string Address{get; set;}
    public string City{get; set;}    
    public string State{get; set;}
    public string Country{get; set;}
    public string Zip{get; set;} 
    public string Gender{get;set;}
    private Map <string, string> timeFrameMap;
    
    //The opportunity being transferred 
    private Opportunity opp;
    
    public List<SelectOption> countries {get; set ;}
    
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
    
    
	/**********************
	* Constructor
	**********************/
	public SRPTransferToSchoolController(ApexPages.StandardController controller) {
		
		 generateCountryOptions();
		
        Opportunity oppStd = (Opportunity)controller.getRecord();
        opp = [
        	SELECT 
        		Id, 
        		Student_First_Name__c, 
        		Student_Last_Name__c, 
        		Person__c, 
        		AccountID,
        		deltaksrp__Email__c,
        		deltaksrp__Home_Phone__c,
        		deltaksrp__Work_Phone__c,
        		deltaksrp__Mobile_Phone__c,
        		deltaksrp__student__r.firstname,
        		deltaksrp__student__r.lastname,
        		SRP_Mailing_Street__c,
        		SRP_Mailing_City__c,
        		SRP_Mailing_State__c,
        		SRP_Mailing_Zip__c,
        		SRP_Mailing_Country__c,
        		Gender__c,
        		SRP_Gender__c,
        		deltaksrp__Interest_Timeframe__c	 
        	FROM Opportunity 
        	WHERE Id = :oppStd.Id LIMIT 1
    	];
        system.debug('opp.deltaksrp__student__r.firstname>>>>'+opp.deltaksrp__student__r.firstname);
        campuses = SRPNewInquiryUtil.loadCampuses(true, opp.AccountID);
        campusId = opp.AccountId;
        email = opp.DeltakSRP__Email__c;
        home_phone = opp.DeltakSRP__Home_Phone__c;
        Work_Phone = opp.DeltakSRP__Work_Phone__c;
        Mobile_Phone = opp.DeltakSRP__Mobile_Phone__c;
    	Address = opp.SRP_Mailing_Street__c;
        City = opp.SRP_Mailing_City__c; 
        State = opp.SRP_Mailing_State__c;
        Country = opp.SRP_Mailing_Country__c;
        Zip = opp.SRP_Mailing_Zip__c;
        selectedGender = opp.SRP_Gender__c;
        firstname = opp.deltaksrp__student__r.firstname;
        lastname = opp.deltaksrp__student__r.lastname;
        studentname='';
        campusChanged();
    } 
     
    
    
    /***********************************************************************
	 * Called when the campus dropdown selection changes on the page
	 ************************************************************************/
	public void campusChanged() {
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
	 * Called when the Save button is pressed
	 ***********************************************************************/
	 
	 
	 
	public PageReference saveOpp() {
		//get the school name 
	if(validateSpecialization() == true){		       
       try{
	    	Lead l = new Lead();
	    	//l.ownerId = userinfo.getUserId();
	    	DeltakSRP__SRP_Partner_Settings__c partnersettings = DeltakSRP__SRP_Partner_Settings__c.getinstance();
            l.ownerid = partnersettings.SRP_Lead_Engine_UserId__c; 
	    	if(firstname!=null)
	    		l.firstname = firstname.substring(0,1).toUpperCase()+firstname.substring(1,firstname.length()).toLowerCase();
	    	if(lastname!=null)
	    		l.lastname = lastname.substring(0,1).toUpperCase()+lastname.substring(1,lastname.length()).toLowerCase();
	 		//l.firstname = opp.deltaksrp__student__r.firstname;
	 		//l.lastname = opp.deltaksrp__student__r.lastname;
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
	  		
	  		system.debug('l>>>>'+l);
	  		
	  		List<Campaign> campaigns = new List<Campaign>();
	  		campaigns = [Select Id, Campaign_Code__c from Campaign where name =:'SG Referral' ];
	  		
	  		if(campaigns.size()>0)
	  			l.RFI_Campaign_Code__c = campaigns[0].Campaign_Code__c;
	  					
	 		RecordType rt = [Select Id from recordtype where name = 'SRP Lead' LIMIT 1];
	 		l.recordtypeId = rt.Id;
	  		
	 		if(l.ownerid == null){
	 			Database.DMLOptions dmo = new Database.DMLOptions();
				//dmo.assignmentRuleHeader.assignmentRuleId= '01QD0000000EqAn';
				l.setOptions(dmo);
				insert l;
	 		}else{
	 			insert l;
	 		}
	 		
	 		lead l2 = new Lead();
	 	    try{
	 	    	l2 = [Select deltakSRP__gender__c, convertedOpportunityId from lead where id=:l.Id];
	 	    	system.debug('l2>>>>'+l2);
	 	    	if(l2.convertedopportunityId !=null){
	 	    		Id contactId;
	 	    		List<Opportunity> oppUpdateList = new List<Opportunity>();
	 	    		oppUpdateList = [Select DeltakSRP__Student__c, Transferred_From_Opportunity__c, Date_Transferred__c from Opportunity
	 	    			where Id =: l2.ConvertedOpportunityId];
	 	    		
	 	    		if(oppUpdateList.size() > 0 && opp != null){
	 	    			contactId = oppUpdateList[0].deltakSRP__student__c;
	 	    			oppUpdateList[0].SRP_Transferred_From_Opportunity__c = opp.Id; 
	 	    			update oppUpdateList[0];
	 	    			
	 	    			system.debug('selectedGender>>>>'+selectedGender);
	 	    			if(contactId != null){
		 	    			List<Contact> contactList = new List<Contact>();
		 	    			contactList = [Select deltakSRP__Gender__c, MailingStreet, MailingCity,MailingState, Mailingcountry,MailingPostalCode  from contact where Id=: contactId];
		 	    			if(contactlist.size() > 0){
		 	    				contactList[0].DeltakSRP__Gender__c = selectedGender;
		 	    				contactList[0].MailingStreet = Address;
		 	    				contactList[0].MailingCity = City;
		 	    				contactList[0].MailingState = state;
		 	    				contactList[0].MailingPostalCode = zip;
		 	    				contactList[0].MailingCountry = country;
		 	    				system.debug('contactList[0]>>>>'+contactList[0]);
		 	    				update contactList[0];
		 	    			}
	 	    			}	
	 	    		}
	 	    		
		 	    	PageReference pg= new PageReference('/'+l2.convertedopportunityId);
					pg.setRedirect(true);
					return pg;
	 	    	}else{
	 	    		system.debug('duptestmessage1>>>>'+Label.Conv_Oppty_Not_Found);
	 	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Conv_Oppty_Not_Found));
	 	    		return null;
	 	    	}	
	 	    }catch(Exception e){
	 	    	system.debug('duptestmessage2>>>>'+Label.Duplicate_Lead_Found);
	 	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Duplicate_Lead_Found));
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
		 PageReference pg= new PageReference('/'+opp.Id);
                pg.setRedirect(true);
                return pg;
	}
}