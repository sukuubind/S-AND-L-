/**
     * SRMLeadConvertHelper
     * @description Class for converting leads automatically from the lead trigger
     * @author Pratik Tanna
     * @date 07/29/2013
*/

public without sharing class SRPLeadConvertHelper {
 
 	
    /**
     * @description 
     * This method is called from LeadTrigger for converting the associated lead
     * into a Contact / Opportunity
     */    
    public static void convertLead(lead l, String Stagename, String substage, Opportunity existingopp){
        try{
            Lead currentLead = l;
            
            String convertedStatus; 
            
            system.debug('currentlead.rfi_campaign_code__c>>>>'+currentlead.rfi_campaign_code__c);
            List<Campaign> clist = new List<Campaign>();
            clist = [Select Id, Parent.Name from campaign where Campaign_Code__c = : l.rfi_campaign_code__c and Campaign_Code__c != null and Campaign_Code__c != '' AND Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < :System.today() 
                                                AND EndDate >= :System.today()
                                                And IsActive = true];
            system.debug('clist>>>>'+clist);
            if(clist.size()>0){
                CampaignMember cmember = new CampaignMember();
                cmember.leadId = l.Id;
                cmember.CampaignID = clist[0].Id;
                cmember.Status='Sent';
                database.insert(cmember, false);
                
                if((clist[0].Parent.Name == 'Conference' && l.DeltakSRP__Inquiry_Rating__c == 'Low') || l.LeadSource=='Mass Upload Lead')
                	return;
            }else{
            	clist = [Select Id from campaign where Name = : 'Bucket'];
            	if(clist.size()>0){
            		CampaignMember cmember = new CampaignMember();
	                cmember.leadId = l.Id;
	                cmember.CampaignID = clist[0].Id;
	                cmember.Status='Sent';
	                database.insert(cmember, false);
            	}
            }                      
           
			RecordType rt = [Select Id from RecordType where DeveloperName = 'SRP_Opportunity' and SobjectType = 'Opportunity'];           
            String newOppName = '';
            
            if(currentlead.DeltakSRP__Academic_Institution_Lookup__r.Abbreviation__c != null)
                newOppName = newOppName + currentlead.DeltakSRP__Academic_Institution_Lookup__r.Abbreviation__c + '-';
            
            if(currentlead.FirstName != null)   
                newOppName = newOppName + currentlead.FirstName.substring(0,1) + '. ';
            
            if(currentLead.lastname != null)
                newOppName = newOppName + currentlead.LastName;
                            
            LeadStatus status = [Select Id,MasterLabel From LeadStatus Where IsConverted=true Limit 1];
            
            
            
            if(status != null)
                convertedStatus = status.masterlabel;
            system.debug('convert>>>>'+newOppName);
            
            system.debug('stagename>>>>'+stagename);
            
            //SRP-2375-SET 2- Do not set the owner id of a new Opportunity to ELoqua Marketing if the old Opportunity is owned 
            String nurtureUserId = OpportunityUtilities.getNurtureUserID();
            String oid;
           	System.Debug('existingopp -- '+existingopp);
            
            
            if(existingopp !=  null && existingopp.owner.isactive && existingopp.ownerid!=nurtureUserId){
           		
                System.Debug('existingopp.owner.isactive -- '+existingopp.owner.isactive);
            System.Debug('existingopp.ownerid -- '+existingopp.ownerid);
            System.Debug('nurtureUserId -- '+nurtureUserId);
                
                currentlead.SRP_Retain_Ownership__c = true;
           		currentlead.ownerid = existingopp.ownerid;
           		oid = existingopp.ownerid;
           		//update currentlead;
           	}
           	//SRP-2375-SET 2- Do not set the owner id of a new Opportunity to ELoqua Marketing if the old Opportunity is owned
            system.debug('currentlead>>>>'+currentlead.SRP_Retain_Ownership__c);
            system.debug('currentlead ownerid>>>>'+currentlead.OwnerId);
            System.Debug('oid -- '+oid);
            //Lead convert fields
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(currentLead.Id);           
            lc.setConvertedStatus(convertedStatus);                      
            lc.setAccountId(currentLead.DeltakSRP__Academic_Institution_Lookup__c);
            lc.setContactId(currentLead.deltakSRP__Contact__c);
            
            if(currentlead.OwnerId != UserInfo.getUserId())
                lc.setSendNotificationEmail(currentLead.deltakSRP__Send_Email_On_Convert__c);
            else
                lc.setSendNotificationEmail(false);
                
            lc.setOverwriteLeadSource(true);
            lc.setOpportunityName(newOppName); 
            
            system.debug('currentlead.ownerid>>>>'+currentlead.ownerid);
            if(oid==null && currentlead.SRP_Retain_Ownership__c != true){
            	Prospect_Setting__c setting = Prospect_Setting__c.getInstance();
            	lc.setOwnerId(setting.prospect_user_Id__c);
                System.Debug('owner assigned to PROspect');
            }else{
            	lc.setOwnerId(oid);
                System.Debug('owner assigned to oid -- '+oid);
            }	
            
            Database.LeadConvertResult result = Database.convertLead(lc);

            if(result.isSuccess()){
               Id oppId = result.getOpportunityId();
               
               
               system.debug('oppId>>>>'+oppId);
               
               Opportunity newopp = [Select ownerid, SRP_Retain_Ownership__c,DeltakSRP__webschedulerstatus__c, DeltakSRP__WebScheduler_Email__c, DeltakSRP__Email__c, campaignid, stagename, DeltakSRP__Student__r.DeltakSRP__Person__c, DeltakSRP__Sub_Stage__c, SRP_Person__c from Opportunity where Id=:oppid];
               
               system.debug('newopp.ownerid>>>>'+newopp.ownerid);
               
               newOpp.StageName = stagename;
               newOpp.DeltakSRP__Sub_Stage__c = substage;
               newOpp.is_converted__c = true;
               newOpp.SRP_Person__c = newOpp.DeltakSRP__Student__r.DeltakSRP__Person__c;
               newOpp.RecordTypeId = rt.Id;
               
               if(newOpp.DeltakSRP__Email__c!=null && newopp.DeltakSRP__webschedulerstatus__c == 'New' && newOpp.DeltakSRP__Email__c != currentlead.Email)
               		newOpp.DeltakSRP__WebScheduler_Email__c = currentlead.email;
               
               if(clist.size()>0)
                newopp.campaignid = clist[0].Id;
               
               system.debug('newOPP>>>>'+newopp.SRP_Retain_Ownership__c);
               update newOpp;
               
               if(currentlead.DeltakSRP__Contact__c != null){
                 contact c = [Select ownerid, donotcall, hasoptedoutofemail, DeltakSRPSMS__Ok_To_Text__c from Contact where Id=:  currentlead.DeltakSRP__Contact__c];
                 
                 c.DoNotCall = currentlead.DoNotCall;
                 c.HasOptedOutOfEmail = currentlead.HasOptedOutOfEmail;
                 c.DeltakSRPSMS__Ok_To_Text__c = currentlead.DeltakSRPSMS__Ok_To_Text__c;
                 c.DeltakSRP__Employer_Company__c = currentlead.Company;
                 c.ownerid = newOpp.ownerid;
                 update c;
                 
               }
               
            }      
        }catch(DMLException ex){
            system.debug('getDmlStatusCode = '+ex.getDmlStatusCode(0));
            if(ex.getDmlStatusCode(0) != 'ENTITY_IS_DELETED')
                throw ex;
        }catch(Exception e){
            system.debug('Exception other than DML Exception is Caught>>>>'+e);
            throw e;
        }
    } 
    
    
}