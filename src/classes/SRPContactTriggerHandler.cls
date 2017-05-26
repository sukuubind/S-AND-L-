public with sharing class SRPContactTriggerHandler {
	
	
	public static string unformatphonenumber(String phonenumber){
		
		system.debug('phonenumber in unformatnumber>>>'+phonenumber);
		
		phonenumber = phonenumber.replace('-','');
		phonenumber = phonenumber.replace('.','');
	    phonenumber=phonenumber.replace(')','');
	    phonenumber=phonenumber.replace('(','');
	    phonenumber=phonenumber.replace(' ','');
	    phonenumber=phonenumber.replace('x','');
		system.debug('phonenumber>>>>'+phonenumber);
		phonenumber.trim();
		
		while(phonenumber.startswith('0')){
			phonenumber = phonenumber.substring(1, phonenumber.length());
			system.debug('inside removing any leading 0>>>>'+phonenumber);
		}
		
		return phonenumber;
	}



	public static String FormatPhone(String Phone) {
		string nondigits = '[^0-9]';
		String nothing = 'NA';
		if (Phone == null)
			return nothing;
		// if lenght is greater than 11 and less than 10 return the same value back
		if (phone.length() <= 11  || phone.length() > 12)
			return nothing;

		string PhoneDigits;

		// remove all non numeric

		PhoneDigits = Phone.replaceAll(nondigits, '');

		if(PhoneDigits == null || PhoneDigits == '1')
		{
			return nothing;
		}
		else

			if (PhoneDigits.substring(0, 1) == '1' && PhoneDigits.length() == 11) {
				return PhoneDigits.substring(1, 4) + '-' +
						PhoneDigits.substring(4, 7) + '-' +
						PhoneDigits.substring(7, 11);
			}

		else
				if((PhoneDigits.substring(0, 1) == '1' && PhoneDigits.length() == 12))

		{
			// 10 digit: reformat with dashes
			//  if (PhoneDigits.length() == 10){
			PhoneDigits = PhoneDigits.substring(0, 3) + '-' +
					PhoneDigits.substring(3, 6) + '-' +
					PhoneDigits.substring(6, 10);

			return PhoneDigits;
		}
		else
		{
			return nothing;
		}

	}
	
	public static List<Contact> onBeforeInsert(List<Contact> contacts){
		Map<String, SRP_Phone_Codes__c> phonecodes = SRP_Phone_Codes__c.getall();
		system.debug('phonecodes>>>>'+phonecodes);
		for(Contact c: contacts){


			if(c.phone != null &&  (c.mailingcountry != null || c.mailingstate != null)){
				String generalphonenumber = unformatphonenumber(c.phone);
						
				String phonecode = '';
				
				system.debug('c.mailingcountry>>>>'+c.mailingcountry);
				system.debug('c.mailingstate>>>>'+c.mailingstate);
				//VR - Added logic to verify Is_Country__c before updating phone codes from Custom Settings.
				if(c.mailingcountry != null && phonecodes.get(c.mailingcountry.tolowercase())!=null && phonecodes.get(c.mailingcountry.tolowercase()).Is_Country__c==true){
					phonecode = phonecodes.get(c.mailingcountry.tolowercase()).phone_code__c;
				
					system.debug('phonecode>>>>'+phonecode);
					
					if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+')){
							continue;
						}
						
					if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode)){
						c.phone = '+'+generalphonenumber;
						continue;
					}
					
					system.debug('generalphonenumber2>>>>'+generalphonenumber);
					system.debug('phonecode2>>>>'+phonecode);
					if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+')){
						c.phone = '+'+phonecode+generalphonenumber;
						system.debug('c.generalphone>>>>'+c.phone);
						continue;
					}
				}		
				
				if(c.mailingcountry == null && c.mailingstate != null && phonecodes.get(c.mailingstate.tolowercase())!=null && phonecodes.get(c.mailingstate.tolowercase()).Is_Country__c==false){
					phonecode = phonecodes.get(c.mailingstate.tolowercase()).phone_code__c;
					if(phonecode != '' && phonecode != null && generalphonenumber.startswith('+')){
							continue;
						}
						
					if(phonecode != '' && phonecode != null && generalphonenumber.startswith(phonecode)){
						c.phone = '+'+generalphonenumber;
						continue;
					}
					
					if(phonecode != '' && phonecode != null && !generalphonenumber.startswith('+')){
						c.phone = '+'+phonecode+generalphonenumber;
						continue;
					}
				}
			}


		}
		
		for(Contact c: contacts){
			if(c.homephone!= null && (c.mailingcountry != null || c.mailingstate != null)){
				
				system.debug('c.mailingcountry>>>>'+c.mailingcountry);
				system.debug('c.mailingstate>>>>'+c.mailingstate);
				
				String homephonenumber = unformatphonenumber(c.homephone);
				String phonecode = '';
				
				if(c.mailingcountry != null && phonecodes.get(c.mailingcountry.tolowercase())!=null && phonecodes.get(c.mailingcountry.tolowercase()).Is_Country__c==true){
					phonecode = phonecodes.get(c.mailingcountry.tolowercase()).phone_code__c;
					system.debug('phonecode>>>>'+phonecode);	
					
					if(c.homephone != null)		
						homephonenumber = unformatphonenumber(c.homephone);
						
						
					if(phonecode != '' && phonecode != null && homephonenumber.startswith('+')){
						continue;
					}
					
					if(phonecode != '' && phonecode != null && homephonenumber.startswith(phonecode)){
						c.homephone = '+'+homephonenumber;
						continue;
					}
					
					system.debug('homephonenumber2>>>>'+homephonenumber);
					system.debug('phonecode2>>>>'+phonecode);
					if(phonecode != '' && phonecode != null && !homephonenumber.startswith('+')){
						c.homephone = '+'+phonecode+homephonenumber;
						system.debug('c.homephone>>>>'+c.homephone);
						continue;
					}
				}	
				
				if(c.mailingcountry == null && c.mailingstate != null && phonecodes.get(c.mailingstate.tolowercase())!=null && phonecodes.get(c.mailingstate.tolowercase()).Is_Country__c==false){
					phonecode = phonecodes.get(c.mailingstate.tolowercase()).phone_code__c;
					if(phonecode != '' && phonecode != null && homephonenumber.startswith('+')){
							continue;
						}
						
					if(phonecode != '' && phonecode != null && homephonenumber.startswith(phonecode)){
						c.homephone = '+'+homephonenumber;
						continue;
					}
					
					if(phonecode != '' && phonecode != null && !homephonenumber.startswith('+')){
						c.homephone = '+'+phonecode+homephonenumber;
						continue;
					}
				}
				
			}
			
		}
		
		for(Contact c: contacts){
			if(c.DeltakSRP__Work_Phone__c!= null && (c.mailingcountry != null || c.mailingstate != null)){
				String workphonenumber = unformatphonenumber(c.DeltakSRP__Work_Phone__c);
				String phonecode = '';
				if(c.mailingcountry != null && phonecodes.get(c.mailingcountry.tolowercase())!=null && phonecodes.get(c.mailingcountry.tolowercase()).Is_Country__c==true){
					phonecode = phonecodes.get(c.mailingcountry.tolowercase()).phone_code__c;
					system.debug('phonecode>>>>'+phonecode);
					if(c.DeltakSRP__Work_Phone__c != null)
						 workphonenumber = unformatphonenumber(c.DeltakSRP__Work_Phone__c);
			    	
					if(phonecode != '' && phonecode != null && workphonenumber.startswith('+')){
							continue;
						}
						
					if(phonecode != '' && phonecode != null && workphonenumber.startswith(phonecode)){
						c.DeltakSRP__Work_phone__c = '+'+workphonenumber;
						continue;
					}
					
					system.debug('workphonenumber2>>>>'+workphonenumber);
					system.debug('phonecode2>>>>'+phonecode);
					if(phonecode != '' && phonecode != null && !workphonenumber.startswith('+')){
						c.DeltakSRP__Work_phone__c = '+'+phonecode+workphonenumber;
						system.debug('c.workphone>>>>'+c.DeltakSRP__Work_phone__c);
						continue;
					}
				}
				
				if(c.mailingcountry == null && c.mailingstate != null && phonecodes.get(c.mailingstate.tolowercase())!=null && phonecodes.get(c.mailingstate.tolowercase()).Is_Country__c==false){
					phonecode = phonecodes.get(c.mailingstate.tolowercase()).phone_code__c;
					if(phonecode != '' && phonecode != null && workphonenumber.startswith('+')){
							continue;
						}
						
					if(phonecode != '' && phonecode != null && workphonenumber.startswith(phonecode)){
						c.DeltakSRP__Work_phone__c = '+'+workphonenumber;
						continue;
					}
					
					if(phonecode != '' && phonecode != null && !workphonenumber.startswith('+')){
						c.DeltakSRP__Work_phone__c = '+'+phonecode+workphonenumber;
						continue;
					}
					
				}
				
			}
			
		}
		
		for(Contact c: contacts){
			if(c.mobilephone != null &&  (c.mailingcountry != null || c.mailingstate != null)){
				String mobilephonenumber;
				
				if(c.mobilephone != null)
					mobilephonenumber = unformatphonenumber(c.mobilephone);
				
				
				if(c.mailingcountry != null && phonecodes.get(c.mailingcountry.tolowercase())!=null && phonecodes.get(c.mailingcountry.tolowercase()).Is_Country__c==true){
					String phonecode = '';
					phonecode = phonecodes.get(c.mailingcountry.tolowercase()).phone_code__c;
					system.debug('phonecode>>>>'+phonecode);
					if(phonecode != '' && phonecode != null && mobilephonenumber.startswith('+')){
						continue;
					}
					
					if(phonecode != '' && phonecode != null && mobilephonenumber.startswith(phonecode)){
						c.mobilephone = '+'+mobilephonenumber;
						continue;
					}
					
					system.debug('mobilephonenumber2>>>>'+mobilephonenumber);
					system.debug('phonecode2>>>>'+phonecode);
					if(phonecode != '' && phonecode != null && !mobilephonenumber.startswith('+')){
						c.mobilephone = '+'+phonecode+mobilephonenumber;
						system.debug('c.mobilephone>>>>'+c.mobilephone);
						continue;
					}
					
					
				}	
				
				
				if(c.mailingcountry == null && c.mailingstate != null && phonecodes.get(c.mailingstate.tolowercase())!=null && phonecodes.get(c.mailingstate.tolowercase()).Is_Country__c==false){
					String phonecode = '';
					phonecode = phonecodes.get(c.mailingstate.tolowercase()).phone_code__c;
					system.debug('phonecode in mobile state>>>>'+phonecode); 
					system.debug('mobilephonenumber>>>>'+mobilephonenumber);
					if(phonecode != '' && phonecode != null && mobilephonenumber.startswith('+')){
						continue;
					}
					
					if(phonecode != '' && phonecode != null && mobilephonenumber.startswith(phonecode)){
						c.mobilephone = '+'+mobilephonenumber;
						continue;
					}
					
					if(phonecode != '' && phonecode != null && !mobilephonenumber.startswith('+')){
						c.mobilephone = '+'+phonecode+mobilephonenumber;
						continue;
					}
					
				}
				
			}
		}
	
		return contacts;
		
	}



	public static List<Contact> onBeforeUpdateFormatPhone(List<Contact> contacts,Map<ID,Contact> oldMap){
    List<Contact> contactsList = new List<Contact>();
		for(Contact cont : contacts)
		{
			if(cont.phone != oldMap.get(cont.Id).Phone)
			{
				cont.DeltakSRP_Formatted_Phone__c = FormatPhone(cont.phone);
				contactsList.add(cont);
			}
		}
		return contactsList;
	}
	
}