public class SRMSRPLeadCreate {
	public static Id createLead(LeadProcessor.LP_Person lp_pers, LeadProcessor.LP_Affiliaiton lp_affl, LeadProcessor.LP_Opportunity lp_oppty){
		if(lp_oppty != null && lp_affl != null && lp_pers != null ){
			RecordType rt = [Select Id from RecordType where name= 'SRP Lead' LIMIT 1];
			Lead lead = new Lead();
			lead.RecordTypeId = rt.Id;
			if (lp_pers.ContactName != null)
			{
				String[] name = lp_pers.ContactName.split(' ');
				lead.FirstName = name[0];
				lead.LastName = name[1];
			}
			lead.Street = lp_affl.Address1 + (LeadProcessor.isdataClean(lp_affl.Address2) ? lp_affl.Address2 : '');
			lead.City = lp_affl.City;
			lead.State = lp_affl.State;
			lead.Mailing_Province__c = lp_affl.Province;
			lead.Country = lp_affl.Country;
			lead.PostalCode = lp_affl.Zip;
			lead.DeltakSRP__Work_Phone__c = lp_affl.Phone1;
			lead.DeltakSRP__Home_Phone__c = lp_affl.Phone2;
			lead.MobilePhone = lp_affl.Phone3;
			lead.Mobile__c = lp_affl.Phone3;
			lead.Email = lp_affl.Email;
			lead.PostalCode = lp_affl.Zip;
			lead.DeltakSRP__Gender__c = lp_affl.Gender;
			lead.Title = lp_affl.Title;
			lead.DeltakSRP__Best_Time_to_Contact__c = lp_affl.BestTime;
			
			List<Account> accountList = [Select Id From Account Where Goldmine_Key5__c =: lp_affl.newKey5];
			if (accountList != null && !accountList.isEmpty())
			{
				lead.DeltakSRP__Academic_Institution_ID__c = accountList.get(0).Id;
				lead.DeltakSRP__Academic_Institution_Lookup__c = accountList.get(0).Id;
			}
			
			if (lp_affl.utextperm == 'Yes' || lp_affl.utextperm == 'True')
			{
				lead.DeltakSRPSMS__Ok_To_Text__c = true;
			}
			else
			{
				lead.DeltakSRPSMS__Ok_To_Text__c = false;
			}
			
			lead.DeltakSRP__AcademicProgram__c = lp_oppty.CourseInterest;
			/*LIST<RFI_to_Academic_Programs_Code__c> APCList = [Select Academic_Program__c, Academic_Specialization__c from RFI_to_Academic_Programs_Code__c Where Program_Code__C =: lp_oppty.CourseInterest limit 1];
			if (APCList != null && !APCList.isEmpty())
			{
				lead.DeltakSRP__AcademicProgram__c = APCList.get(0).Academic_Program__c;
				lead.DeltakSRP__Academic_Specialization__c = APCList.get(0).Academic_Specialization__c;
			}*/
			
			lead.RFI_Campaign_Code__c = lp_oppty.R_Campaign;
			lead.DeltakSRP__LP_UREF_MEDIATYPE__c = lp_oppty.UrefMediaType;
			lead.DeltakSRP__LP_UREFKEYWORD__c = lp_oppty.UrefKeyWrd;
			lead.DeltakSRP__LP_UREFPROMOTION__c = lp_oppty.UrefPromotion;
			lead.DeltakSRP__LP_UADCAMPAIGN__c = lp_oppty.UADCAMPGN;
			lead.DeltakSRP__LP_UADGROUP__c = lp_oppty.UADGROUP;
			lead.DeltakSRP__LP_UREURL__c = lp_oppty.urefurl;
			lead.DeltakSRP__How_Heard__c = lp_oppty.uhowheard;
			lead.Highest_Degree_Earned__c = lp_oppty.HighLevel;
			lead.Source__c = lp_oppty.Source;
			lead.DeltakSRP__Modality__c = lp_oppty.UModality;
			lead.IM_Type__c = lp_oppty.UIMType;
			lead.IM_Username__c = lp_oppty.UIMName;
			
			List<User> userList = [Select id from User where Name = 'SRP Lead Engine' limit 1];
     		if(userList != null && userList.size() > 0)
     		{
	     		if (lp_oppty.newKey4 == userList[0].Id)
	     			lead.OwnerId = lp_oppty.newKey4;
     		}
     		
			if (lp_oppty.referredByOpportunity != null && lp_oppty.referredByOpportunity != '')
			{
				lead.DeltakSRP__Referred_by__c = lp_oppty.referredByOpportunity;
			} 
			
			if (lp_oppty.Company == null || lp_oppty.Company == '')
			{
				lead.Company = 'Not Provided';
			}
			else
			{
				lead.Company = lp_oppty.Company;
			}
			
			try{
				insert lead;
				return lead.Id;
			}catch(Exception e){
				return null;
			}
		}
	return null;
	}
}