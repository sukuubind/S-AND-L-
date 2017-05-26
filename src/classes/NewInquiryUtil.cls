/*
 * Chris Baker
 * 
 * 12/6/10
 *
 * This class is a utility class with methods that are shared by 
 * ManualInquiryController, NewReferralController, TransferToSchoolController
 */
 
public class NewInquiryUtil {
	/*************************************************
	 * Load all campuses
	 *************************************************/
	public static List <SelectOption> loadAllCampuses(boolean noneOption) {
		System.debug('---> Loading all campuses...');
		
		//get the campuses
        Account [] campusSobjs = 
        	[SELECT Id, Name
			FROM Account
			WHERE recordtype.name = 'Campus/Partner' and Display_on_New_Inquiry_Page__c = True                       
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
			WHERE recordtype.name = 'Campus/Partner' and Display_on_New_Inquiry_Page__c = True   
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
			WHERE recordtype.name = 'Campus/Partner' and Display_on_New_Inquiry_Page__c = True
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
			WHERE recordtype.name = 'Campus/Partner' and Display_on_New_Inquiry_Page__c = True
			AND Id In :CCSchoolSet
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
        	campuses.add(new SelectOption('-None-','-None-'));
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
        
        Academic_Program__c [] programSobjs = [SELECT Id, Name, Program_Title__c, Abbrev__c
                        FROM Academic_Program__c
                        WHERE School__c = :campusId
                        AND Active__c = TRUE
                        ORDER BY Name];                   
                                       
        programs.add(new SelectOption('-None-','-None-'));
               
        for(Academic_Program__c prog : programSobjs){
            programs.add(new SelectOption(prog.Id+'', prog.Program_Title__c));
        }
        
        return programs;
	}
	
	/*************************************************
	 * Load the specialization selections for the dropdown on the page 
	 *************************************************/
	public static List <SelectOption> loadSpecializations(string programId) {
		System.debug('---> Loading specializations where Id = ' + programId);
		List<SelectOption> specializations = new List<SelectOption>();
        
        Academic_Program__c [] specRequired = [SELECT Id, Require_Specialization__c
                                               FROM Academic_Program__c
                                               WHERE Id=:programId
                                               AND Active__c = TRUE];
                                           
        if (specRequired.size()>0) {
            if (!specRequired[0].Require_Specialization__c) {
                System.debug ('Require_Specialization__c = false');
                specializations.add(new SelectOption('No Specialization', 'No Specialization'));
                
            }
            else {
                System.debug ('Require_Specialization__c = true');
                specializations.add(new SelectOption('-None-', '-None-'));
            }
            
            Academic_Specialization__c [] specializationObjs = [SELECT Id, Spec_Title__c, Specialization_Abbrev__c, Name 
                                  FROM Academic_Specialization__c
                                  WHERE Academic_Program__c = :programId
                                  AND Active__c = TRUE];
            
            for(Academic_Specialization__c spec: specializationObjs){
                if (spec.Specialization_Abbrev__c != null) {
                    specializations.add(new SelectOption(spec.Specialization_Abbrev__c, spec.Spec_Title__c));
                }
                
                else {
                    specializations.add(new SelectOption('No Specialization', spec.Spec_Title__c));
                }
            }
        }
        
        else {            
            specializations.add(new SelectOption('-None-', '-None-'));
        }
        
        return specializations;        
	}
	
	/*************************************************
	 * Load the timeframe selections for the dropdown on the page 
	 *************************************************/
	public static List <SelectOption> getTimeFrames() {
		List <SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '-None-', '-None-'));
        Schema.DescribeFieldResult F = Opportunity.Interest_Timeframe__c.getDescribe();
        List <Schema.PicklistEntry> timeFrameList = F.getPicklistValues();
        
        for (Schema.PicklistEntry timeFrame : timeFrameList) {
        	options.add( new SelectOption( timeFrame.getValue(), timeFrame.getValue()));
        }
        
        return options;
	}
	
	/*************************************************
	 * Send SMTP message to Lead Router 
	 *************************************************/
	public static boolean sendToLeadRouter(
		string subject, 
		string body,
		string displayName,
		string replyTo,
		List <String> emailAddresses
		) {
			System.debug ('Sending lead to the following email addresses --> ' + emailAddresses);
			
	        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	                
	        email.setSubject(subject);
	        email.setPlainTextBody(body);
	                    
	        // Specify the address used when the recipients reply to the email. 
	        email.setReplyTo(replyTo);
	                    
	        // Specify the name used as the display name.
	        email.setSenderDisplayName(displayName);
	        
	        //Set the email addresses
	        email.setToAddresses(emailAddresses);
			
			//Added because of Case #00502350 so that the user's signature is not sent with the email to lead router - CB
			email.setUseSignature(false);	        
	        
	        //Send the email
	        Messaging.SendEmailResult [] mailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
	                    
	        //Check for errors
	        for (Messaging.SendEmailResult result: mailResults) {
	            if (!result.isSuccess()) {
	                for (Messaging.Sendemailerror error : result.getErrors()) {
	                    System.debug('---> Error sending email to Lead Routher - Email failure' + error.getMessage() );
	                    return false;
	                }
	            }
	        }    
			return true;
	}
	
	/*************************************************
	 * Get Sales Stage 
	 *************************************************/
	public static string getSalesStage(string selectedTimeFrame) {
		System.debug('selectedTimeFrame --> '+selectedTimeFrame);        
	    string salesStage;
	    TimeFrameToSalesStageMap__c tf = TimeFrameToSalesStageMap__c.getAll().get(selectedTimeFrame);
		if (tf != null) {
	        salesStage = tf.GoldmineStage__c;
	        if (salesStage == null) {
	        	salesStage = TimeFrameToSalesStageMap__c.getAll().get('Default').GoldmineStage__c;
	        }
	        return salesStage;
	        
		}
		else {
			System.debug('Error: Could not find selectedTimeFrame ---> ' + selectedTimeFrame);
			return null;
		}
	}
	
	/*************************************************
	 * Get email addresses from the custom settings 
	 *************************************************/
	public static List <string> getEmalAddresses() {
		System.debug('Getting email addresses from LeadRouterEmail__c custom setting...');
		List <LeadRouterEmail__c> leadRouterEmailList = new List <LeadRouterEmail__c> ();
		leadRouterEmailList = LeadRouterEmail__c.getAll().values();
		
        List <string> emailAddressList = new List <string>();
        for (LeadRouterEmail__c e : leadRouterEmailList) {
        	System.debug('looking at LeadRouterEmail__c record ---> '+e);
        	if (e.Active__c) {
        		System.debug('adding LeadRouterEmail__c record ---> '+e);
        		emailAddressList.add(e.SendTo__c);
        	}
        }
        return emailAddressList;
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