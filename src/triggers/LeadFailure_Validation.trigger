trigger LeadFailure_Validation on Lead_Failure__c (before update) {
    
    String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        for (integer record = 0; record < trigger.size; record++) {
        Lead_Failure__c  lead_fail = Trigger.new[record];
            if(!lead_fail.Ignore_Lead__c){
            
            
                if (trigger.old[record].Resend_Status__c == true) {
                    lead_fail.addError('This failure record is already processed.');
                }
                String contactName = trigger.new[record].ContactName__c;
                if( contactName  == null || contactName == '' ){
                    lead_fail.ContactName__c.addError('There is no contactname present.');
                }
                if(contactName != null){
                    String[] namesList = contactName.split(' ');
                    if(namesList.size() != 2){
                        lead_fail.ContactName__c.addError('Contactname should have first name and last name');
                    }
                    for(integer index = 0;index < namesList.size();index++){
                        String thisName = namesList[index];
                        if(thisName.length() <3){
                            lead_fail.ContactName__c.addError('Firstname and Lastname should be atleast 3 characters long');
                        }
                    }
                }
                String email = trigger.new[record].Email__c;
                if(email != null){
                    String regex = '^([a-z0-9+._-]+@)([a-z0-9-]+\\.)+(a(?:[cdefgilmnoqrstuwxz]|ero|(rp|si)a)$|(b([abdefghijmnorstvwyz]|iz))$|(c([acdfghiklmnoruvxyz]|at|o(m|op)))$|(d[ejkmoz])$|(e([ceghrstu]|du))$|(f[ijkmor])$|(g([abdefghilmnpqrstuwy]|ov))$|(h[kmnrtu])$|(i([delmnoqrst])|(n(fo|t)))$|(j([emop]|obs))$|(k[eghimnprwyz])$|(l[abcikrstuvy])$|(m([acdeghklmnopqrstuvwxyz]|il|obi|useum))$|(n([acefgilopruz]|ame|et))$|o(m|rg)$|(p([aefghklmnrstwy]|ro))$|(qa)$|(r[eosuw])$|(s[abcdeghijklmnortuvyz])$|(t([cdfghjklmnoprtvwz]|(rav)?el))$|(u[agkmsyz])$|(v[aceginu])$|(w[fs])$|(y[etu])$|(z[amw])$)+';
                     if(!Pattern.matches(regex, email)){
                         lead_fail.Email__c.addError('Email is invalid. Please correct this email address.');
                     }
                }
                if((email == null || email == '') && 
                    (trigger.new[record].Phone1__c == null || trigger.new[record].Phone1__c == '') &&
                    (trigger.new[record].Phone2__c == null || trigger.new[record].Phone2__c == '')){
                        lead_fail.Phone1__c.addError('One of the following should be present: Phone1, Phone2, Email');
                        lead_fail.Phone2__c.addError('One of the following should be present: Phone1, Phone2, Email');
                        lead_fail.Email__c.addError('One of the following should be present: Phone1, Phone2, Email');
                    }
                
             List <string> emailAddressList = NewInquiryUtil.getEmalAddresses();
                
                string body='[Instructions]\n'+
                'DupCheck1=Email\n'+
                'DupCheck2=Key5\n'+
                'OnNewAttachTrack=WebLead\n'+
                'OnDupAttachTrack=WebLead Duplicate\n'+
                'SaveThis=Lead from Web Import\n'+
                '\n\n[Data]\n'+
                'Contact='+lead_fail.ContactName__c+'\n'+
                'Address1='+lead_fail.Address1__c+' '+lead_fail.Address2__c+'\n'+               
                'ucourseint='+lead_fail.CourseInterest__c+'\n'+   
                'City='+lead_fail.City__c+'\n'+
                'State='+lead_fail.State__c+'\n'+
                'Zip='+lead_fail.Zip__c+'\n'+
                'Phone1='+lead_fail.Phone1__c+'\n'+
                'Phone2='+lead_fail.Phone2__c+'\n'+
                'Phone3='+lead_fail.Phone3__c+'\n'+
                'Email='+lead_fail.Email__c+'\n'+ 
                'ugender='+lead_fail.Gender__c+'\n'+                                     
                'Key2='+ lead_fail.Key2__c+ '\n'+
                'Key5='+lead_fail.Key5__c+'\n' +
                'uCampaign=' + lead_fail.R_Campaign__c+ '\n' + 
                'uleaddate= '+System.now().format('yyyyMMdd') + '\n' + 
                'uleadtime= '+System.now().format('h:mm a') + '\n';
                 
               
                 body += 'OwnerId=' + lead_fail.OwnerId__c + '\n';
                
                
                body +=
                '\n[ContSupp]\n'+
                'cs1_RecType=P\n'+
                'cs1_Contact=E-mail Address\n' + 
                'cs1_contsupref='+lead_fail.Email__c;
                         
                boolean successful = NewInquiryUtil.sendToLeadRouter(
                    'Goldmine Population',
                    body,
                    'Goldmine Population',
                    'noreply@deltakedu.com',
                    emailAddressList
                );
                
                if(successful){
                    lead_fail.Resend_Status__c = true;
                }else{
                    lead_fail.addError('This failure record could not be resent.');
                }
            }
        }
    }
}