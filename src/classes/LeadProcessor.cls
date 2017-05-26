global class LeadProcessor {
     
     global class LP_Person{
        webservice String ContactName;
        webservice String RasId;
     }
     
     global class LP_Failure{
        webservice String failure;
        webservice String failureDescription; 
     }
     
     global class LP_Affiliaiton{    
         webservice String Address1; 
         webservice String Address2;
         webservice String City; 
         webservice String State; 
         webservice String Province;  //@AbhaS - related to Columbia Updates - 12/07/2012
         webservice String Country;   //@AbhaS - related to Columbia Updates - 11/19/2012
         webservice String Zip; 
         webservice String Phone1; 
         webservice String Phone2; 
         webservice String phone3;
         webservice String Email; 
         webservice String Gender;
         webservice String Title;
         webservice String BestTime;
         webservice String HSGradYear;
         webservice String newKey5;
         webservice String utextperm;  
     }
     
     global class LP_Opportunity{
         webservice Integer GMId;
         webservice String Program;
         webservice String CourseInterest;
         webservice String Program2;
         webservice String Key1;
         webservice String Key2;
         webservice String Key5;
         webservice String R_Campaign;
         webservice String Referal;
         webservice String UrefKeyWrd;
         webservice String UrefMediaType;//@AbhaS UTM field - 10/15/12
         webservice String UrefPromotion;//@AbhaS UTM field - 10/15/12
         webservice String UADCAMPGN;
         webservice String UADGROUP;
         webservice String UINTLEAD;
         webservice String urefurl; 
         webservice String notes; 
         webservice String uhowheard;
         webservice String udescribe;
         webservice String filename;
         webservice String uhscode; 
         webservice String UOptOutCam;
         webservice String UCAMPGNTYP;
         webservice String ucampus; 
         webservice String urefrdby;
         webservice String Other_Colleges;
         webservice Date uoptindt;
         webservice Datetime DateCreated; 
         webservice String HighLevel; 
         webservice String newKey4; 
         webservice String Company; 
         webservice String Source; 
         webservice String UModality; 
         webservice String UIMType; 
         webservice String UIMName; 
         webservice String OwnerId; 
         webservice String referredByOpportunity; 
         webservice String referredByPerson; 
         webservice String TransferredFromOpportunity;
         webservice Integer IMSID;
     }
     
     
     
     
     /** VS Adding functionality new Lead Processor Fields START **/
     global class LeadRouter_AdditionalFields{
     webservice  String Program; 
     webservice String Program2;
     webservice String Key1;
     webservice String Key2;
     webservice String Key5;
     webservice String R_Campaign;
     webservice String Source;
     webservice String Company;
     webservice String Referal;
     webservice String UrefKeyWrd;
     webservice String UrefMediaType;//@AbhaS UTM field - 10/15/12
     webservice String UrefPromotion;//@AbhaS UTM field - 10/15/12
     webservice String UADCAMPGN;
     webservice String UADGROUP;
     webservice String UINTLEAD;
     webservice String urefurl; 
     webservice String notes; 
     webservice String uhowheard;
     webservice String udescribe;
     webservice String filename;
     webservice String uhscode; 
     webservice String UOptOutCam;
     webservice String UCAMPGNTYP;
     webservice String utextperm;
     webservice String phone3;
     webservice String ucampus; 
     webservice String urefrdby;
     webservice String Other_Colleges;
     webservice String uoptindt; // Added by VS - 12/28/2010 - For Terri to implement CR55
     }
     public static boolean isdataClean(String inputString){
        system.debug('inputString>>>>'+inputString);
        if(inputString != null && inputString.equalsIgnoreCase('(no string passed)'))
             return false;
        else
             return true;
        
     }
     public static String validateEmail(String email){
     if(email == null || email == ''){
        return '';
     }
     String regex = '^([a-z0-9+._-]+@)([a-z0-9-]+\\.)+(a(?:[cdefgilmnoqrstuwxz]|ero|(rp|si)a)$|(b([abdefghijmnorstvwyz]|iz))$|(c([acdfghiklmnoruvxyz]|at|o(m|op)))$|(d[ejkmoz])$|(e([ceghrstu]|du))$|(f[ijkmor])$|(g([abdefghilmnpqrstuwy]|ov))$|(h[kmnrtu])$|(i([delmnoqrst])|(n(fo|t)))$|(j([emop]|obs))$|(k[eghimnprwyz])$|(l[abcikrstuvy])$|(m([acdeghklmnopqrstuvwxyz]|il|obi|useum))$|(n([acefgilopruz]|ame|et))$|o(m|rg)$|(p([aefghklmnrstwy]|ro))$|(qa)$|(r[eosuw])$|(s[abcdeghijklmnortuvyz])$|(t([cdfghjklmnoprtvwz]|(rav)?el))$|(u[agkmsyz])$|(v[aceginu])$|(w[fs])$|(y[etu])$|(z[amw])$)+';
     if(Pattern.matches(regex, email))
         return email;
     else
         return '';
    
     }
     public static String convertDateTime(String inputDate){
        String outputDate = '';
        String[] tempDate = inputDate.split(' ', -1);
        
        String timeValue = null;
        String ampmValue = null;
        String dateValue = tempDate[0];
        if(tempDate.size() > 1){
            timeValue = tempDate[1];
            ampmValue = tempDate[2];
        }
        String hourValue = '00';
        String minuteValue = '00';
        String secondvalue = '00';
        
        if(timevalue != null){
            String[] timeValueTemp = timeValue.split(':',-2);
            System.Debug('VS -- Time Value Temp ---'+timeValueTemp);
             if(timeValueTemp != null && timeValueTemp.size() > 0){
                 hourValue = timeValueTemp[0];
                 minuteValue = timeValueTemp[1];
                 secondValue = timeValueTemp[2];
             }
        }
        
        if(ampmValue != null && ampmValue.equalsIgnoreCase('pm') && !('12'.equals(hourValue)))
            hourValue = String.valueOf(Integer.valueOf(hourValue)+12);
            
        String[] dateValueTemp = dateValue.split('/',-2);
        String monthValue = dateValueTemp[0];
        String dayValue = dateValueTemp[1];
        String yearValue = dateValueTemp[2];
        
        outputDate = yearValue + '-' + monthValue
                     + '-' + dayValue + ' ' + hourValue + ':' + 
                    minuteValue +  ':' + secondValue;
          
        
        
        
        return outputDate;
     }
     
     webservice static List<String>  lp_with_handle_failure(LP_Person lp_pers, LP_Affiliaiton lp_affl, LP_Opportunity lp_oppty, LP_Failure lp_fail){
        if(lp_fail == null){
            return lp_run(lp_pers, lp_affl, lp_oppty);
        }else{
            RasReportLeadFailure lead_fail = new RasReportLeadFailure();
            Id lead_failId = lead_fail.createFailureRecord(lp_pers, lp_affl, lp_oppty, lp_fail);
            
            List<String> returnString = new List<String>();
                returnString.add('Success');
                returnString.add(lead_failId);
        return returnString;
        }
     }
     
     
     
     webservice static List<String>  lp_run(LP_Person lp_pers, LP_Affiliaiton lp_affl, LP_Opportunity lp_oppty){
        // If the inquiry is SRP bound, create and populate a lead, then insert it into the database
        //List<User> userList = [Select id from User where Name = 'SRP Lead Engine' limit 1];
        if(lp_affl != null && lp_affl.newKey5 != null && lp_affl.newKey5 != ''){
        	List<Account> accountList = [Select id, RecordType.DeveloperName from Account where Goldmine_Key5__c = :lp_affl.newKey5 limit 1];
        	if(accountList != null && accountList.size() > 0){
	            if (accountList[0].RecordType.DeveloperName == 'SRP_Account')
	            {
	                id leadId = SRMSRPLeadCreate.createLead(lp_pers, lp_affl, lp_oppty);
	                List<String> lr = new List<String>(); 
	                if(leadId != null){
	                    lr.add('Success'); 
	                    lr.add(leadId); 
	                }else{
	                    lr.add('Failure'); 
	                    lr.add('lead not inserted'); 
	                }
	                 return lr; 
	            }
        	}
        }
        
            Map<String, String> stageNameMap = new Map<String, String>();
        stageNameMap.put('06', '12+ months' );
        stageNameMap.put('07', '6-12  months' );
        stageNameMap.put('08', '3-6 months' );
        stageNameMap.put('09', '0-3 months' );
        stageNameMap.put('10', 'ASAP' );

      
       /** VS Adding functionality new Lead Processor Fields START **/
      String Program1= ''; 
      String Program2= '';
      String Key1= '';
      String Key2= '';
      String Key5 = '';
      String R_Campaign= '';
      String Referal= '';
      String UrefKeyWrd= '';
      String UrefMediaType = '';//@AbhaS UTM field - 10/15/12
      String UrefPromotion = '';//@AbhaS UTM field - 10/15/12
      String UADCAMPGN= '';
      String UADGROUP= '';
      String UINTLEAD= '';
      String urefurl= ''; 
      String notes= '';
      String uhowheard= '';
      String udescribe= '';
      String filename= '';
      String uhscode= '';
      String UOptOutCam= '';
      String UCAMPGNTYP= '';
      String utextperm= '';
      String phone3= '';
      String ucampus= ''; 
      String urefrdby= '';
      String Other_Colleges= '';
      Date uoptindt = null;
      String ContactName = ''; 
      String Address1= '';  
      String Address2= ''; 
      String City= '';  
      String State= ''; 
      String Province = '';  //@AbhaS - related to Columbia Updates - 12/07/2012
      String Country = '';   //@AbhaS - related to Columbia Updates - 11/19/2012
      String Zip= '';  
      String Phone1= '';  
      String Phone2= '';  
      String LP_Email = '';
      String Email = '';
      String Gender= ''; 
      String BestTime= '';  
      String Program= '';  
      String CourseInterest= '';  
      String HSGradYear= '';  
      Datetime DateCreated= null; 
      String HighLevel= '';  
      String newKey4= '';  
      String Company= '';  
      String Title= ''; 
      String Source= ''; 
      String UModality= '';  
      String UIMType= '';  
      String UIMName= '';  
      String RasId= '';  
      String OwnerId= ''; 
      String referredByOpportunity= ''; 
      String referredByPerson= ''; 
      String TransferredFromOpportunity= ''; 
      String newKey5 = '';
      
     if(lp_oppty != null && lp_affl != null && lp_pers != null ){
        Program1 = (lp_oppty.Program != null && isDataClean(lp_oppty.Program) ? lp_oppty.Program : '');
        Program2 = (lp_oppty.Program2 != null && isDataClean(lp_oppty.Program2) ? lp_oppty.Program2 : '');
        Key1 = (lp_oppty.Key1 != null && isDataClean(lp_oppty.Key1) ? lp_oppty.Key1 : '');
        Key2 = (lp_oppty.Key2 != null && isDataClean(lp_oppty.Key2) ? lp_oppty.Key2 : '');
        Key5 = (lp_oppty.Key5 != null && isDataClean(lp_oppty.Key5) ? lp_oppty.Key5 : '');
        newKey5 = Key5;
        R_Campaign =(lp_oppty.R_Campaign != null && isDataClean(lp_oppty.R_Campaign) ? lp_oppty.R_Campaign : '');
        Referal = (lp_oppty.Referal != null && isDataClean(lp_oppty.Referal) ? lp_oppty.Referal : '');
        UrefKeyWrd = (lp_oppty.UrefKeyWrd != null && isDataClean(lp_oppty.UrefKeyWrd) ? lp_oppty.UrefKeyWrd : '');
        UrefMediaType = (lp_oppty.UrefMediaType != null && isDataClean(lp_oppty.UrefMediaType) ? lp_oppty.UrefMediaType : '');//@AbhaS UTM field - 10/15/12
        UrefPromotion = (lp_oppty.UrefPromotion != null && isDataClean(lp_oppty.UrefPromotion) ? lp_oppty.UrefPromotion : '');//@AbhaS UTM field - 10/15/12
        UADCAMPGN = (lp_oppty.UADCAMPGN != null && isDataClean(lp_oppty.UADCAMPGN) ? lp_oppty.UADCAMPGN : '');
        UADGROUP = (lp_oppty.UADGROUP != null && isDataClean(lp_oppty.UADGROUP) ? lp_oppty.UADGROUP : '');
        UINTLEAD = (lp_oppty.UINTLEAD != null && isDataClean(lp_oppty.UINTLEAD) ? lp_oppty.UINTLEAD : '');
        urefurl = (lp_oppty.urefurl != null && isDataClean(lp_oppty.urefurl) ? lp_oppty.urefurl : '');
        notes = (lp_oppty.notes != null && isDataClean(lp_oppty.notes) ? lp_oppty.notes : '');
        uhowheard = (lp_oppty.uhowheard != null && isDataClean(lp_oppty.uhowheard) ? lp_oppty.uhowheard : '');
        udescribe = (lp_oppty.udescribe != null && isDataClean(lp_oppty.udescribe) ? lp_oppty.udescribe : '');
        filename = (lp_oppty.filename != null && isDataClean(lp_oppty.filename) ? lp_oppty.filename : '');
        uhscode = (lp_oppty.uhscode != null && isDataClean(lp_oppty.uhscode) ? lp_oppty.uhscode : '');
        UOptOutCam = (lp_oppty.UOptOutCam != null && isDataClean(lp_oppty.UOptOutCam) ? lp_oppty.UOptOutCam : '');
        UCAMPGNTYP = (lp_oppty.UCAMPGNTYP != null && isDataClean(lp_oppty.UCAMPGNTYP) ? lp_oppty.UCAMPGNTYP : '');
        System.Debug('VS -- Incoming UTEXTPERM -- '+lp_affl.utextperm);
        utextperm = (lp_affl.utextperm != null && isDataClean(lp_affl.utextperm) ? lp_affl.utextperm : 'No');
        if(''.equals(utextperm))
            utextperm = 'No';
        phone3 = (lp_affl.phone3 != null && isDataClean(lp_affl.phone3) ? lp_affl.phone3 : '');
        ucampus = (lp_oppty.ucampus != null && isDataClean(lp_oppty.ucampus) ? lp_oppty.ucampus : '');
        urefrdby = (lp_oppty.urefrdby != null && isDataClean(lp_oppty.urefrdby) ? lp_oppty.urefrdby : '');
        Other_Colleges = (lp_oppty.Other_Colleges != null && isDataClean(lp_oppty.Other_Colleges) ?  lp_oppty.Other_Colleges : '');
        uoptindt = (lp_oppty.uoptindt);
     }
      /** VS Adding functionality new Lead Processor Fields END **/
      Integer GmId = lp_oppty.GMId;
      ContactName = (lp_pers.ContactName != null && isDataClean(lp_pers.ContactName) ? lp_pers.ContactName : ''); 
      Address1= (lp_affl.Address1 != null && isDataClean(lp_affl.Address1) ? lp_affl.Address1 : '');  
      Address2= (lp_affl.Address2 != null && isDataClean(lp_affl.Address2) ? lp_affl.Address2 : ''); 
      City= (lp_affl.City != null && isDataClean(lp_affl.City) ? lp_affl.City : '');  
      State= (lp_affl.State != null && isDataClean(lp_affl.State) ? lp_affl.State : ''); 
      Province = (lp_affl.Province != null && isDataClean(lp_affl.Province) ? lp_affl.Province : '');  //@AbhaS - related to Columbia Updates - 12/07/2012
      system.debug('lp_affl.Country>>>>'+lp_affl.Country); 
      Country= (lp_affl.Country != null && isDataClean(lp_affl.Country) ? lp_affl.Country : '');    //@AbhaS - related to Columbia Updates - 11/19/2012
      Zip= (lp_affl.Zip != null && isDataClean(lp_affl.Zip) ? lp_affl.Zip : '');  
      Phone1= (lp_affl.Phone1 != null && isDataClean(lp_affl.Phone1) ? lp_affl.Phone1 : '');  
      Phone2= (lp_affl.Phone2 != null && isDataClean(lp_affl.Phone2) ? lp_affl.Phone2 : '');  
      Email= (lp_affl.Email != null && isDataClean(lp_affl.Email) ? lp_affl.Email : '');
      LP_Email = lp_affl.Email;
      Email = validateEmail(lp_affl.Email);
      Gender= (lp_affl.Gender != null && isDataClean(lp_affl.Gender) ? lp_affl.Gender : ''); 
      BestTime= (lp_affl.BestTime != null && isDataClean(lp_affl.BestTime) ? lp_affl.BestTime : '');  
      Program= (lp_oppty.Program != null && isDataClean(lp_oppty.Program) ? lp_oppty.Program : '');  
      CourseInterest= (lp_oppty.CourseInterest != null && isDataClean(lp_oppty.CourseInterest) ? lp_oppty.CourseInterest : '');  
      HSGradYear= (lp_affl.HSGradYear != null && isDataClean(lp_affl.HSGradYear) ? lp_affl.HSGradYear : '');  
      DateCreated= (lp_oppty.DateCreated); 
      HighLevel= (lp_oppty.HighLevel != null && isDataClean(lp_oppty.HighLevel) ? lp_oppty.HighLevel : '');  
      newKey4= (lp_oppty.newKey4 != null && isDataClean(lp_oppty.newKey4) ? lp_oppty.newKey4 : '');  
      Company= (lp_oppty.Company != null && isDataClean(lp_oppty.Company) ? lp_oppty.Company : '');  
      Title= (lp_affl.Title != null && isDataClean(lp_affl.Title) ? lp_affl.Title : ''); 
      Source= (lp_oppty.Source != null && isDataClean(lp_oppty.Source) ? lp_oppty.Source : ''); 
      UModality= (lp_oppty.UModality != null && isDataClean(lp_oppty.UModality) ? lp_oppty.UModality : '');  
      UIMType= (lp_oppty.UIMType != null && isDataClean(lp_oppty.UIMType) ? lp_oppty.UIMType : '');  
      UIMName= (lp_oppty.UIMName != null && isDataClean(lp_oppty.UIMName) ? lp_oppty.UIMName : '');  
      RasId= (lp_pers.RasId != null && isDataClean(lp_pers.RasId) ? lp_pers.RasId : '');  
      OwnerId= (lp_oppty.OwnerId != null && isDataClean(lp_oppty.OwnerId) ? lp_oppty.OwnerId : ''); 
      referredByOpportunity= (lp_oppty.referredByOpportunity != null && isDataClean(lp_oppty.referredByOpportunity) ? lp_oppty.referredByOpportunity : ''); 
      referredByPerson= (lp_oppty.referredByPerson != null && isDataClean(lp_oppty.referredByPerson) ? lp_oppty.referredByPerson : ''); 
      TransferredFromOpportunity= (lp_oppty.TransferredFromOpportunity != null && isDataClean(lp_oppty.TransferredFromOpportunity) ? lp_oppty.TransferredFromOpportunity : ''); 
      System.Debug('LP - oppty --'+lp_oppty.IMSID);
      Integer imsid = lp_oppty.IMSID;
      
            // //Edited by Abha S. - 07/10/12 - Webscheduler related 
      Opportunity oppty_web = new Opportunity();
      System.debug('*************************OWNER ID (key4)= '+newKey4);
      System.debug('*************************OWNER ID = '+OwnerId);
      System.debug('*************************RAS ID = '+RasId);
      System.debug('*************************Key5 = '+Key5);
      //Using Key5 and RASId to check for duplicates
      if((Key5 != '') && (Key5 != null)){
          System.debug('Key5 _ LP');
          oppty_web = DuplicateOpportunityCheck.check_webSch(Key5, RasId, Phone1, Email);
      }
      
  /*    
      //Use Key4 to get the owner's id information if Ownerid is null then check if duplicate opportunity exists
        if((newKey4 instanceof Id) && ((OwnerId == null) || (OwnerId =='null') || (OwnerId=='') || (OwnerId.trim().length()<12))) {
          System.debug('KEY4 _ LP');
          oppty_web = DuplicateOpportunityCheck.check_webSch(newKey4, RasId);
      }
      //check if duplicate opportunity exists
      else if(OwnerId instanceof Id){
          System.debug('OwnerID _ LP');
          oppty_web = DuplicateOpportunityCheck.check_webSch(OwnerId, RasId);
      }*/
      //   // 

      /** commenting it out for Webscheduler testing purposes   
      List<Opportunity> oppty = [Select id from Opportunity where Gmid__c = :String.valueOf(GMId) limit 1];
      if(oppty != null && oppty.size() > 0){
        List<String> lr = new List<String>();
            lr.add('Success');
            lr.add(oppty[0].Id);
            return lr;
      }**/
      
      // //Edited by Abha S. - 07/10/12 - Webscheduler related 
      // if the source contains 'RFI' and the duplicate opportunity exists then set the Web Scheduler status to 'New'
      if(oppty_web != null){ 
        if(oppty_web.Source__c != null){ 
            if(oppty_web.Source__c.contains('RFI')==true){ 
                System.debug('Oppty_Web - LP '); 
                oppty_web.webschedulerstatus__c = 'New'; 

                update oppty_web; 

                List<String> lr = new List<String>(); 
                lr.add('Success'); 
                lr.add(oppty_web.Id); 
                return lr; 
            } 
        }
     }

       //    //
      
      /** Gender Logic START **/
      /** BUG Fix 641 VS START. Commenting the code that incorrectly sets the gender. The correct logic for Gender is available in the contact section of this class **/
      /**if(Gender.equalsIgnoreCase('m'))
          Gender = 'Male';
      else if(Gender.equalsIgnoreCase('f'))
          Gender = 'Female';
      else
          Gender = '';**/
          
           /** BUG Fix 641 VS START. Commenting the code that incorrectly sets the gender. The correct logic for Gender is available in the contact section of this class **/
      
      /** Gender Logic END **/
            Person__c pson = null;
            
            Savepoint sp = Database.setSavepoint();
            String linkedOppId = null;
            // Upsert Person if valid Ras Id returned - Otherwise insert Person
            Database.Saveresult oppId = null;
            boolean caseResult = null;
            String trimmedName = ContactName.trim();
            List<String> names = trimmedName.split(' ');
           
            String firstName = null;
            String lastName = null;
            Id PersonId = null;
             try{  
             
            Integer i;
            for (i=0; i < names.size() - 1; i++) {
                if (i == 0) {
                    firstName = names[i];
                } else {
                    firstName = firstName + ' ' + names[i];
                }
            }
             lastName = names[i];
            
            // Check if Ras ID Exist and update or insert Person record accordingly
             pson = new Person__c();
            Database.Upsertresult uPersonId = null;
            Database.Saveresult iPersonId = null;
           
            pson.Last_Name__c = lastName;
            pson.First_Name__c = firstName;
            
                if (RasId != '00000000-0000-0000-0000-000000000000' && RasId != null) {
                    pson.RasID__c = RasId;
                    System.Debug('Ras ID  --- '+pson.RASID__c);
                    uPersonId = Database.upsert(pson, Person__c.RasID__c);
                    System.Debug(' -- UPerson'+pson);
                } else {
                    iPersonId = Database.insert(pson);
                    System.Debug(' -- IPerson'+pson);
                }
                
                if (uPersonId != null)  {
                    personId = uPersonId.getId();
                } else {
                    personId = iPersonId.getId(); 
                }
            
            
            //Get Account for School
            List<Account> school = [select id, Name, Type, OwnerId
                                        from Account where Goldmine_key5__c = :Key5];
            System.Debug('After Calling School'+school);
            List<String> recordType = new List<String>();
            recordType.add('Deltak Student');
            recordType.add('Rasmussen Student');
            recordType.add('Student Opportunity'); /** Bug Fix 592 VS **/
            recordType.add('On-Ground Opportunity'); //SRP-308 change for Purdue on ground Opps
            recordType.add('Deltak: Student Event'); //SRP-309 change for JHU to create appointments
            recordType.add('Deltak: Student'); //SRP-309 change for JHU to create appointments
            List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordType ];
            System.debug('recordtypes debug = '+recordTypes);
            Map<String, Id> recordTypeNameToId = new Map<String, Id>();
            Map<Id, String> recordTypeIdToName = new Map<Id, String>();
            if(recordTypes != null && recordTypes.size() > 0){
                for(RecordType thisRecordType : recordTypes){
                    recordTypeNameToId.put(thisRecordType.Name, thisRecordType.Id);
                    recordTypeIdToName.put(thisRecordType.Id, thisRecordType.Name);
                }
            }
            System.Debug('After Record Type'+recordTypeNameToId);
            
                Opportunity pr_opp = null;
                Contact pr_contact = null;
            if (school.size() > 0) {
                //Check for Duplicate Affiliation - Use Email Address if present on input
                /** VS Replacing the old duplicate contact detemination with the following
                1. A Contact should exist for the Person record
                2. The Account Id on the contact should be of the school in context
                3. The record type on the contact should match the school in context
                **/
                String schoolType = school[0].Type;
                System.debug('School Type = '+school[0].Type);
                Id record = null;
                if(schoolType == 'Deltak Partner' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Deltak Student'))
                     record = recordTypeNameToId.get('Deltak Student');
                if(schoolType == 'Rasmussen Campus' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Rasmussen Student'))
                     record = recordTypeNameToId.get('Rasmussen Student');
                
                List<Contact> dupContacts = null;
                dupContacts = [Select c.RecordTypeId, 
                                      c.Person__c, 
                                      c.Id, 
                                      c.AccountId 
                                From Contact c
                                Where c.Person__c = :pson.id
                                And c.AccountId = :school[0].id
                                And c.RecordTypeId = :record
                                ];
                
                
             /**   List<Contact> dupContacts = new List<Contact>();
                String query = 'select Id, FirstName, LastName from Contact where FirstName ='+firstName+' and LastName = '+lastName;
                query  += 'and AccountId = '+school[0].id;
                if(Email.contains('@'))
                    query += 'and Email = '+Email;
                
                
                if (Email.contains('@')) {
                    dupContacts = [select Id, FirstName, LastName from Contact 
                        where FirstName = :firstName and LastName = :lastName 
                        and Email = :Email and AccountId = :school[0].id];
                } else {
                    dupContacts = [select Id, FirstName, LastName from Contact 
                        where FirstName = :firstName and LastName = :lastName and AccountId = :school[0].id];
                }**/
                
                //dupContacts = Database.query(query);
                    
                Id ContactId = null;
                System.Debug('In Between Dup Contacts');
                if (dupContacts != null && dupContacts.size() > 0) {
                    System.Debug('Dupe Contacts'+dupContacts);
                    String caseType = 'Goldmine Lead';
                    String caseSubtype = 'Duplicate Contact';
                    String caseSubject = 'Potential Duplicate Affiliation - ' +  Key5 
                        + ' ' + ContactName + ' ' + Email;
                    String caseDescription = 'A potential duplicate affiliation has been forwarded from the lead router:\n'
                        + 'Name: ' + ContactName + '\nSchool: ' + Key5 +  '\nProgram: ' + Program + '\nCourse Interest: ' + CourseInterest 
                        + '\nEmail: ' + Email + '\nAddress1: ' + Address1 + '\nAddress2: ' + Address2 + '\nCity: ' + City + '\nState: '
                        + State + '\nCountry: ' + '\nProvince: ' + Province + Country + '\nZip: ' + Zip + '\nPhone1: ' + Phone1 + '\nPhone2: ' + Phone2 + '\nBest Time: ' + BestTime;
                        //@AbhaS - related to Columbia Updates - 12/07/2012
                    
                    // VS 10-27-2010 Commenting the case creation for Duplicate Affiliation as we are not creating case for this scenario
                    //caseResult = DuplicateNotifier.createCaseBySchoolProgram(Key5, Program, caseType, caseSubtype, caseSubject, caseDescription, dupContacts[0].id, pson.id);
                    contactId = dupContacts[0].Id;  
                } else {
                    System.Debug(' -- Creating new Contact');
                    Contact newContact = new Contact();
                    newContact.FirstName = firstName;
                    newContact.LastName = lastName;
                    newContact.Email = Email;
                    newContact.AccountId = school[0].Id;
                    if(school[0].Type == 'Deltak Partner' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Deltak Student')){
                        newContact.RecordTypeId = recordTypeNameToId.get('Deltak Student');
                    }
                    if(school[0].Type == 'Rasmussen Campus' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Rasmussen Student')){
                        newContact.RecordTypeId = recordTypeNameToId.get('Rasmussen Student');
                    }
                    System.debug('newContact.RecordTypeId = '+newContact.RecordTypeId);
                    newContact.person__c = personId;
                    newContact.MailingStreet = Address1 + '\n' + Address2;
                    newContact.MailingCity = City;
                    newContact.MailingState = State;
                    newContact.Mailing_Province__c = Province;  //@AbhaS - related to Columbia Updates - 12/07/2012
                    newContact.MailingCountry = Country;   //@AbhaS - related to Columbia Updates - 11/19/2012
                    system.debug('country>>>>'+country);
                    newContact.MailingPostalCode = Zip;
                    newContact.Title = Title;
                    newContact.AccountId = school[0].id;
                    newContact.HomePhone = Phone2;
                    newContact.Work_Phone__c = Phone1;
                    System.Debug('VS -- UTEXTPERM---'+utextperm);
                    newContact.OK_to_Text__c = utextperm;
                    System.Debug('VS - Incoming UOPTINDT --'+uoptindt);
                    if('yes'.equals(utextperm) && uoptindt != null ){
                        //newContact.Original_Text_Opt_In_Date__c = datetime.valueOf(convertDateTime(uoptindt));
                        newContact.Original_Text_Opt_In_Date__c = uoptindt;
                    }
                    System.Debug('VS -- Opt In Date ----'+newContact.Original_Text_Opt_In_Date__c);
                    /** Preferred Phone Logic START **/
                    
                    if(Phone1 != null && Phone1 != '' && Phone1 != 'null'){
                        newContact.Preferred_Phone__c = 'Work';
                    }else if(Phone2 != null && Phone2 != '' && Phone2 != 'null'){
                        newContact.Preferred_Phone__c = 'Home';
                    }else{
                        newContact.Preferred_Phone__c = '';
                    }
                    
                    /** Preferred Phone Logic END **/
                    
                    
                    newContact.IM_Type__c = UIMType;
                    newContact.IM_Username__c = UIMName;
                    newContact.Best_Time_to_Contact__c = BestTime;
                    if(gender != null){
                        if (gender.equalsIgnoreCase('M') || gender.equalsIgnoreCase('Male')) {
                            newContact.Gender__c = 'Male';
                        } else if (gender.equalsIgnoreCase('F') || gender.equalsIgnoreCase('Femal') || gender.equalsIgnoreCase('Female')) {
                            newContact.Gender__c = 'Female';
                        }
                    }
                    if (Email.Contains('@')) {
                        newContact.Email = Email;
                    }
                    newContact.HS_Grad_Year__c = HSGradYear;
                     /** VS Adding functionality new Lead Processor Fields START **/
                    newContact.Employer_Company__c = Company;
                    /** VS Fixing bug 699. Mobile phone is empty. Phone3 was previously mapped to other phone. Now mapped to mobile phone **/
                    newContact.MobilePhone = phone3;
                     /** VS Adding functionality new Lead Processor Fields END **/
                    
                   
                    String CountryOfCitizenship;
                    List<String> splitString = new List<string>();
                    if(notes!=null && notes.length() > 0){
                        splitString = notes.split('\\|'); 
                        if(splitString.size()>0){
                            For(String s: splitstring){
                                if(s.contains('Country_Of_Citizenship')){
                                    List<String> slist = s.split('Country_Of_Citizenship: ');
                                    if(slist != null) countryofcitizenship = slist[1];
                                }
                            }
                        }else{
                            if(notes.contains('Country_Of_Citizenship')){
                                List<String> slist = notes.split('Country_Of_Citizenship: ');
                                if(slist != null) countryofcitizenship = slist[1];
                            }   
                        }   
                    }   
                     
                    if(countryofcitizenship != null) countryofcitizenship.trim();
                    
                    newcontact.country_of_citizenship__c = countryofcitizenship;

                    system.debug('newcontact.country_of_citizenship__c>>>>'+newcontact.country_of_citizenship__c);
                    
                    Database.Saveresult newContactId = Database.insert(newContact);
                    ContactId = newContactId.getId();
                  
                    pr_contact = newContact;
                    System.Debug('Completed Creating new contact'+pr_contact); 
                }
                
                System.Debug('Goldmin to salesforce program  ---');
                    List<Goldmine_to_Salesforce_Program__c> progs = [select Program_Id__c, Specialization_Id__c, Program_Id__r.Restricted_States__c, 
                    Program_Id__r.On_Ground_Only__c 
                    //List<Goldmine_to_Salesforce_Program__c> progs = [select Id
                        from Goldmine_to_Salesforce_Program__c where Goldmine_Key5__c = :Key5 
                        //from Goldmine_to_Salesforce_Program__c where Id = :Key5 
                        and Goldmine_Program__c = :CourseInterest];
                   System.Debug('Create a new Opportunity  '); 
                   
                   //added by George Abboud 09-18-2014
                    Goldmine_to_Salesforce_Program__c goldmineToSFProgram = null;
                    
                    Opportunity newOpp = new Opportunity();
                    if(progs.size() > 0) {
                        //added by George Abboud 09-18-2014
                        goldmineToSFProgram = progs[0];
                        newOpp.program__c = progs[0].Program_Id__c;
                        //newOpp.program__c = progs[0].Id;
                        newOpp.specialization__c = progs[0].Specialization_Id__c;
                        //newOpp.specialization__c = progs[0].Id;
                    }else{
                        newOpp.Other_Program__c = CourseInterest; 
                    }
                    newOpp.name = 'From Lead' + GMId;
                    System.Debug('IMS ID -- '+imsid);
                    newOpp.IMS_ID__c = imsid; // VS Added this code on 6/9/2011 for IMS Integration
                    newOpp.AccountId = school[0].id;
                    newOpp.student__c = contactId;
                    newOpp.person__c = personId;
                     
                    newOpp.CloseDate = date.newInstance(2100, 1, 1);
                    
                    if (referredByOpportunity != null && referredByOpportunity != '' && referredByOpportunity != ' ' && referredByOpportunity != '?' && referredByOpportunity instanceof id) { 
                        newOpp.Referred_by_Opportunity__c = referredByOpportunity;
                    }
                    if (referredByPerson != null && referredByPerson != '' && referredByPerson != ' ' && referredByPerson != '?' && referredByPerson instanceof id) { 
                        newOpp.Referred_by_Person__c = referredByPerson;
                    }
                    if (TransferredFromOpportunity != null && TransferredFromOpportunity instanceof Id && TransferredFromOpportunity != '' && TransferredFromOpportunity != ' ' && TransferredFromOpportunity != '?') { 
                        // START - Change Transferred_From_Opportunity Id from being stored in a text field to being stored in the Transferred_From_Opportunity__c look-up field -- CB
                        // newOpp.Transferred_From_Opportunity_Txt__c = TransferredFromOpportunity;
                        newOpp.Transferred_From_Opportunity__c = TransferredFromOpportunity;
                        // END - Change Transferred_From_Opportunity Id from being stored in a text field to being stored in the Transferred_From_Opportunity__c look-up field -- CB
                    }
                    System.Debug('Starting Campus COntact Process');
                    
     
                    /** VS Adding functionality new Lead Processor Fields START **/
                    // Campaign Logic Start
                    System.Debug(' -- lEad Date');
                    System.Debug('Date Created --- '+DateCreated);
                    Date leadDate = DateCreated.date();
                    System.Debug('Lead Date --'+leadDate);
                    System.Debug('Campaign Start'+leadDate);
                    List<Campaign> campList = [Select id, Bucket_Campaign__c, IsActive
                                                from Campaign 
                                                where (Campaign_Code__c = :R_Campaign
                                                AND Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < :leadDate 
                                                AND EndDate >= :leadDate
                                                And IsActive = true) 
                                                OR (Bucket_Campaign__c = true
                                                    And IsActive = true)
                                                ];
                    Campaign bucketCampaign = null; 
                    Campaign campaignCode = null;
                    if(campList != null & campList.size() > 0){
                        boolean firstCampaign = true;
                        for(Campaign camp : campList){
                            if(camp.isActive){
                                if(camp.Bucket_Campaign__c)
                                   bucketCampaign = camp; 
                                else{
                                    if(firstCampaign){
                                        campaignCode=camp;
                                        firstCampaign = false;
                                    }
                                }
                            }    
                        }
                    }
                    System.Debug('End Campaign Process');
                    /** Fix for bug 717. bucketcampaign.id and campaigncode.id START -- VS*/
                    if(campaignCode == null &&bucketCampaign != null)
                       newopp.CampaignId = bucketCampaign.Id;
                    if(campaignCode != null)
                       newOpp.CampaignId =campaignCode.Id;
                    /** Fix for bug 717. bucketcampaign.id and campaigncode.id END -- VS*/
                    newOpp.LP_Campaign__c = R_Campaign;
                    System.Debug('Campaing --  '+newOpp.Campaign);
                    //Campaign Logic End  
                    newOpp.LP_Program__c = Program1;
                    newOpp.LP_Program2__c = Program2;
                    newOpp.LP_KEY1__c = Key1;
                    
                    /** Sales Stage Logic **/
                    if(Key2 != null){
                        String startWith = Key2.subString(0, 2);
                        if(stageNameMap != null && stageNameMap.containsKey(startWith)){
                            newOpp.Interest_Timeframe__c = stageNameMap.get(startWith);
                        }
                    }
                    
                    /** Bug Fix 592 START VS **/
                    if(recordTypeNameToId.containsKey('Student Opportunity')){
                        newOpp.RecordTypeId = recordTypeNameToId.get('Student Opportunity');
                    }
                    /** Bug Fix 592 END VS **/
                    
                    newOpp.LP_Referral__c = Referal;
                    newOpp.LP_Urefkeyword__c  = UrefKeyWrd;
                    newOpp.LP_UREFMEDIATYPE__c  = UrefMediaType; //@AbhaS UTM field - 10/15/12
                    newOpp.LP_UREFPROMOTION__c  = UrefPromotion; //@AbhaS UTM field - 10/15/12
                    newOpp.LP_Uadcampaign__c = UADCAMPGN;
                    newOpp.LP_Uadgroup__c = UADGROUP;
                    newOpp.LP_intlead__c = UINTLEAD;
                    newOpp.LP_ureurl__c = urefurl;
                    //newOpp.LP_notes__c = notes;
                    
                    String typeOfLawDegree;
                    String CountryOfCitizenship;
                    List<String> splitString = new List<string>();
                    if(notes!=null && notes.length() > 0){
                            splitString = notes.split('\\|');
                            
                            //Added by George Abboud to default newOpp.LP_notes__c to what's in notes
                            newOpp.LP_notes__c = notes;
                            
                        if(splitString.size()>0){
                            For(String s: splitstring){
                                if(s.contains('Country_Of_Citizenship')){
                                List<String> slist = s.split('Country_Of_Citizenship: ');
                                if(slist != null && slist.size()>1) countryofcitizenship = slist[1];
                            }else{
                                if(s.contains('Type_Of_Law_Degree')){
                                    List<String> slist = s.split('Type_Of_Law_Degree: ');
                                    if(slist != null && slist.size()>1) typeoflawdegree = slist[1];
                                }
                                else{
                                    newOpp.LP_notes__c = s;
                                }
                            }
                            }
                        }   
                        else
                         {
                            newOpp.LP_notes__c = notes;
                         }
                     }
                     
                    if(countryofcitizenship != null) countryofcitizenship.trim();
                    if(typeoflawdegree != null) typeoflawdegree.trim();

                    newopp.type_of_law_degree__c = typeoflawdegree;
                    newopp.country_of_citizenship__c = countryofcitizenship;

                    system.debug('newopp.LP_notes__c>>>>'+newopp.LP_notes__c);
                    system.debug('newop.type_of_law_degree__c>>>>'+newopp.type_of_law_degree__c);
                    system.debug('newopp.country_of_citizenship__c>>>>'+newopp.country_of_citizenship__c);
                                    
                    newOpp.Source__c = Source;
                    newOpp.How_Heard_Detail__c = uhowheard;
                    newOpp.Modality__c = umodality;
                    newOpp.LP_Udescribe__c = udescribe;
                    newOpp.LP_Filename__c = filename;
                    newOpp.LP_uhscode__c = uhscode;
                    newOpp.LP_Uoptoutcam__c = UOptOutCam;
                    newOpp.LP_Ucampgntyp__c = UCAMPGNTYP;
                    newOpp.LP_utextperm__c = utextperm;
                    newOpp.LP_UCAMPUS__c = ucampus;
                    newOpp.LP_UREFRDBY__c = urefrdby;
                    newOpp.LP_OTHERCOLLEGES__c = Other_Colleges;
                    newOpp.LP_Email__c = LP_Email;
                    newopp.GmId__c = String.valueOf(GMId);
                    /*System.Debug('HighLevel -->'+ HighLevel);*/
                    newopp.Highest_Degree_Earned__c = HighLevel;
                    
                    // //Edited by Abha S. - 07/10/12 - Webscheduler related
                    if(Source.contains('RFI') == true){
                        newOpp.webschedulerstatus__c = 'New';
                        System.debug('New opp*********************** = '+newOpp.webschedulerstatus__c);
                    }
                    // //
                    
                    /** VS Adding functionality new Lead Processor Fields END **/
                           
                
                //Check for Duplicate Opportunity
                List<String> dupOps = DuplicateOpportunityCheck.check(ContactId, Key5);
                /**
                VS - 10-27-2010 Duplicate Opportunity gets a new Opportunity with Stage:Dormant; SubStage: Duplicate
                Duplicate Opportunity gets a Lead Failure record with Duplicate Opportunity Flag set to true
                GA - 09-18-2014 - SRP-335 Check for restricted states for queens university logic appended as outer IF
                statement.
                GA - 10-24-2014 - SRP-335 Fix for SRP-335...abbreviations were coming in and found in longer names in a faulty manner
                */
                
                List<String> stateList = new List<String>();
                Set<String> stateSet = new Set<String>();
                
                if(goldmineToSFProgram != null && goldmineToSFProgram.Program_Id__r.Restricted_States__c != null && 
                goldmineToSFProgram.Program_Id__r.Restricted_States__c != '')
                {
                    stateList = goldmineToSFProgram.Program_Id__r.Restricted_States__c.split(';');
                    
                    if(stateList.size() > 0)
                    {
                        for(String s : stateList)
                        {
                            stateSet.add(s.trim().toUpperCase());
                        }
                    }
                }
                
                if(State != null && State != '' && stateSet.size() > 0 && stateSet.contains(State.trim().toUpperCase()))
                { //SRP-335 logic - Restricted States programs to dormant/State Restricted
                    
                    if (school.size() > 0)
                    {
                        newOpp.OwnerId = school[0].OwnerId;
                    }
                    
                    newOpp.stageName = 'Dormant';
                    newOpp.Sub_Stage__c = 'State Restricted';
                    
                }
                else
                {
                    if (dupOps.size() > 0) {
                        newOpp.StageName = 'Dormant';
                        newOpp.Sub_Stage__c = 'Duplicate Record';
                        List<Opportunity> OppforOwner = [Select OwnerId from Opportunity where Id = :dupOps[0] and Owner.IsActive = true ];
                        
                            if(OppforOwner != null && OppforOwner.size() > 0){
                                newOpp.OwnerId = OppforOwner[0].OwnerId;
                                if(OwnerId != null){
                                if(OwnerId.contains('low'))
                                    newOpp.Inquiry_Rating__c = 'Low';
                                else if(OwnerId.contains('med'))
                                    newOpp.Inquiry_Rating__c = 'Medium';
                                else if(OwnerId.contains('hig'))
                                    newOpp.Inquiry_Rating__c = 'High';
                                }
                             }
                            else
                                newOpp = assignOwner(newKey4, School, newOpp, OwnerId);
                        
                        // Girija: added if-condition to check the if the oppty owner is PROspect engine, if so, then assign oppty to acct owner
              			//for ticket SRP: 1454       
                        Prospect_Setting__c setting = Prospect_Setting__c.getInstance();     
                        List<Opportunity> acctOwner = [Select Account.ownerid from Opportunity where Id = :dupOps[0]];
                        if(newOpp.OwnerId == setting.PROspect_User_ID__c)
                        {
                            if(acctOwner!= null && acctOwner.size() > 0)
                                newOpp.OwnerId = acctOwner[0].Account.ownerid;
                        }                        
                        
                        RasReportLeadFailure reportFailure = new RasReportLeadFailure();
                        Boolean duplicateOpportunity = true; 
                        LeadRouter_AdditionalFields addedFields = populateAddedFields(lp_pers, lp_affl, lp_oppty);
                        //@AbhaS - related to Columbia Updates 11/19/2012
                       if(Country != null){
                           LP_Failure lp_fail = new LP_Failure();
                           lp_fail.failureDescription = '';
                           lp_fail.failure = '';
                           Id failure1 = reportFailure.createFailureRecord(lp_pers, lp_affl, lp_oppty, lp_fail);
                       }//   //
                       else{
                        Id failure = reportFailure.createFailureRecord( String.valueOf(GMId),ContactName, Address1,Address2, City, State, Zip, Phone1, 
                                                          Phone2, Email,Gender,BestTime, Program, CourseInterest, 
                                                          HSGradYear, newKey5,String.valueOf(DateCreated), HighLevel, newKey4, 
                                                          Company, Title, Source, UModality, UIMType, UIMName, 
                                                          RasId, OwnerId, referredByOpportunity, referredByPerson, 
                                                          TransferredFromOpportunity, duplicateOpportunity, addedFields);
                          }                                
                      
                    } else {
                        newOpp.StageName = 'New Inquiry';
                        //If OwnerId passed from Lead Router,
                        newOpp = assignOwner(newKey4, School, newOpp, OwnerId);
                       
                        
                        
                    }
                
                }
                
                /**
                GA - 09-18-2014 - SRP-308 Purdue University On-Ground Opportunity
                */
                System.debug('>--->key5 ' + key5);
                System.debug('>--->goldmineToSFProgram ' + goldmineToSFProgram);
                if(goldmineToSFProgram != null && key5 == 'Purdue' && goldmineToSFProgram.Program_Id__r.On_Ground_Only__c)
                { //SRP-308 - Purdue University On-Ground Opportunity
                    System.debug('>--->in srp-308 logic');
                    newOpp.RecordTypeId = recordTypeNameToId.get('On-Ground Opportunity');
                    newOpp.OwnerId = UserInfo.getUserId();
                    
                }
                
                newOpp =  getWorkExpAndGpa(key5,notes,newOpp);    
                
                System.Debug('Opportunity Inserted -- VS -- '+newOpp);
                oppId = Database.Insert(newOpp);
                
                pr_opp = newopp;
                linkedOppId = oppId.getId(); 
                
                 /**
                GA - 09-19-2014 - SRP-309 JHU Appointment / Event
                */
                System.debug('>--->key5: ' + key5);
                System.debug('>--->notes: ' + notes);
                //notes should have smthg like "Event Date: 2014-11-01-16-30-00"
                if(key5 == 'JHUAAP' && notes != null && notes.length() > 0 && notes.contains('Event Date:'))
                {
                    String eventString = notes.replaceAll('Event Date:', '').Trim();
                    
                    //at this point we should have smthg like "2014-11-01-16-30-00"
                    List<String> eventList = eventString.split('-');
                    
                    List<Integer> eventInts = new List<Integer>();
                    
                    if(eventList.size() == 6)
                    {
                    
                        eventInts.add(Integer.valueOf(eventList[0]));   //year
                        eventInts.add(Integer.valueOf(eventList[1]));   //month
                        eventInts.add(Integer.valueOf(eventList[2]));   //day
                        eventInts.add(Integer.valueOf(eventList[3]));   //hour
                        eventInts.add(Integer.valueOf(eventList[4]));   //minute
                        eventInts.add(Integer.valueOf(eventList[5]));   //second
                        
                    }
                    
                    DateTime eventDTstart = null;
                    
                    if(eventInts.size() == 6)
                    {
                        
                        eventDTstart = DateTime.newInstance(eventInts[0],eventInts[1],eventInts[2],eventInts[3],eventInts[4],eventInts[5]); //in Eastern Timezone
                        eventDTstart = eventDTstart.addHours(-1);   //convert to Central Timezone
                        
                    }
                    
                    if(eventDTstart != null && eventDTstart > DateTime.now())
                    {
                        
                        DateTime eventDTend = eventDTstart.addMinutes(30);
                        
                        Event e = new Event();
                        e.RecordTypeId = recordTypeNameToId.get('Deltak: Student Event');
                        e.OwnerId = newOpp.OwnerId;
                        e.Subject = 'RFI Appointment';
                        e.Type = 'Call';
                        e.WhatId = linkedOppId;
                        e.WhoId = ContactId;
                        e.StartDateTime = eventDTstart;
                        e.EndDateTime = eventDTEnd;
                        
                        insert e;
                        Id eventId = e.Id;
                        
                        Task t = new Task();
                        t.RecordTypeId = recordTypeNameToId.get('Deltak: Student');
                        t.OwnerId = newOpp.OwnerId;
                        t.Subject = 'RFI Appointment';
                        t.Type = 'Call - Outbound';
                        t.WhatId = linkedOppId;
                        t.WhoId = ContactId;
                        t.Status = 'Not Started';
                        t.Priority = 'Normal';
                        t.ActivityDate = eventDTstart.date();
                        
                        Database.DMLOptions dmlo = new Database.DMLOptions();
                        dmlo.EmailHeader.triggerUserEmail = true;
                        database.insert(t, dmlo);
                        
                    }
                    
                }
                
                
            } else {
                throw new UserException('Key5 Value ' + Key5 + ' on lead ' + GMId + ' not mapped to Salesforce account.');
            }
            List<String> lr = new List<String>();
            lr.add('Success');
            lr.add(linkedOppId);
            if(pr_opp != null){
              lr.add(pr_opp.LP_Filename__c);
              lr.add(pr_opp.Interest_Timeframe__c);
            }
            
            lr.add('');
            lr.add('');
            lr.add(''); 
            return lr;
            } catch (Exception e) {
                Database.rollback(sp);
                
                //EmailUtils.sendTextEmail(emailRecepients, 'SFDC Lead Processor Error Occurred for '+ContactName, e.getMessage());
                RasReportLeadFailure reportFailure = new RasReportLeadFailure();
                /** 2/7/11 Added the following line as part of  CR59 -- CB **/
                reportFailure.errorMessage = e.getMessage();
                Boolean duplicateOpportunity = false;
                System.Debug('VS - Error Message-- '+e.getMessage());
                
                List <string> address = new List <string>();
                address.add(Address1);
                address.add(Address2);
                LeadRouter_AdditionalFields addedFields = populateAddedFields(lp_pers, lp_affl, lp_oppty); 
               
               //@AbhaS - related to Columbia Updates 11/19/2012
                   if(Country != null){
                       LP_Failure lp_fail = new LP_Failure();
                       lp_fail.failureDescription = e.getMessage();
                       Id failure1 = reportFailure.createFailureRecord(lp_pers, lp_affl, lp_oppty, lp_fail);
                   }//   //  
                else{
                Id failure = reportFailure.createFailureRecord(                 
                    String.valueOf(GMId),
                    ContactName,                    
                    Address1,
                    Address2,
                    City, State, Zip, Phone1, 
                      Phone2, Email,Gender,BestTime, Program, CourseInterest, 
                      HSGradYear, newKey5,String.valueOf(DateCreated), HighLevel, newKey4, 
                      Company, Title, Source, UModality, UIMType, UIMName, 
                      RasId, OwnerId, referredByOpportunity, referredByPerson, 
                      TransferredFromOpportunity,duplicateOpportunity, addedFields);
                    }
                
                /*
                 * CB  --  2/7/11 - 
                 * This method will no longer be called due to CR59 which states that we will not create cases when a Lead failure occurs
                 * Instead, a workflow rule will fire when a new Lead Failure record is created which notifies whoever supports the Lead Processor
                                                                       
                reportFailure.notifyFailure(e.getMessage(), failure);
                */
                
                if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                    return null;
                }
                List<String> lr = new List<String>();
                lr.add('Failure');
                lr.add('');
                lr.add(e.getTypeName() + ' - ' + e.getMessage()); 
                return lr;
            }
     }
      
     /** VS Adding functionality new Lead Processor Fields END **/
     webService static List<String> run(
     
     Integer GMId,
     String ContactName, 
     String Address1, 
     String Address2,
     String City, 
     String State, 
     String Country, 
     String Zip, 
     String Phone1, 
     String Phone2, 
     String Email, 
     String Gender,
     String BestTime, 
     String Program, 
     String CourseInterest, 
     String HSGradYear, 
     String newKey5,
     String DateCreated, 
     String HighLevel, 
     String newKey4, 
     String Company, 
     String Title,
     String Source, 
     String UModality, 
     String UIMType, 
     String UIMName, 
     String RasId, 
     String OwnerId, 
     String referredByOpportunity, 
     String referredByPerson, 
     String TransferredFromOpportunity,
     /**New Mappings Added by VS on 06/02 START **/
     LeadRouter_AdditionalFields addedFields
     /**New Mappings Added by VS on 06/02 END **/
     ) {
        
        Map<String, String> stageNameMap = new Map<String, String>();
        stageNameMap.put('06', '12+ months' );
        stageNameMap.put('07', '6-12  months' );
        stageNameMap.put('08', '3-6 months' );
        stageNameMap.put('09', '0-3 months' );
        stageNameMap.put('10', 'ASAP' );

      
       /** VS Adding functionality new Lead Processor Fields START **/
      String Program1= ''; 
      String Program2= '';
      String Key1= '';
      String Key2= '';
      String Key5 = '';
      String R_Campaign= '';
      String Referal= '';
      String UrefKeyWrd= '';
      String UrefMediaType = '';//@AbhaS UTM field - 10/15/12
      String UrefPromotion = '';//@AbhaS UTM field - 10/15/12
      String UADCAMPGN= '';
      String UADGROUP= '';
      String UINTLEAD= '';
      String urefurl= ''; 
      String notes= '';
      String uhowheard= '';
      String udescribe= '';
      String filename= '';
      String uhscode= '';
      String UOptOutCam= '';
      String UCAMPGNTYP= '';
      String utextperm= '';
      String phone3= '';
      String ucampus= ''; 
      String urefrdby= '';
      String Other_Colleges= '';
      String LP_Email = '';
      String uoptindt = '';
     if(addedFields != null){
        Program1 = (addedFields.Program != null && isDataClean(addedFields.Program) ? addedFields.Program : '');
        Program2 = (addedFields.Program2 != null && isDataClean(addedFields.Program2) ? addedFields.Program2 : '');
        Key1 = (addedFields.Key1 != null && isDataClean(addedFields.Key1) ? addedFields.Key1 : '');
        Key2 = (addedFields.Key2 != null && isDataClean(addedFields.Key2) ? addedFields.Key2 : '');
        Key5 = (addedFields.Key5 != null && isDataClean(addedFields.Key5) ? addedFields.Key5 : '');
        R_Campaign =(addedFields.R_Campaign != null && isDataClean(addedFields.R_Campaign) ? addedFields.R_Campaign : '');
        Referal = (addedFields.Referal != null && isDataClean(addedFields.Referal) ? addedFields.Referal : '');
        UrefKeyWrd = (addedFields.UrefKeyWrd != null && isDataClean(addedFields.UrefKeyWrd) ? addedFields.UrefKeyWrd : '');
        UrefMediaType = (addedFields.UrefMediaType != null && isDataClean(addedFields.UrefMediaType) ? addedFields.UrefMediaType : '');//@AbhaS UTM field - 10/15/12
        UrefPromotion = (addedFields.UrefPromotion != null && isDataClean(addedFields.UrefPromotion) ? addedFields.UrefPromotion : '');//@AbhaS UTM field - 10/15/12
        UADCAMPGN = (addedFields.UADCAMPGN != null && isDataClean(addedFields.UADCAMPGN) ? addedFields.UADCAMPGN : '');
        UADGROUP = (addedFields.UADGROUP != null && isDataClean(addedFields.UADGROUP) ? addedFields.UADGROUP : '');
        UINTLEAD = (addedFields.UINTLEAD != null && isDataClean(addedFields.UINTLEAD) ? addedFields.UINTLEAD : '');
        urefurl = (addedFields.urefurl != null && isDataClean(addedFields.urefurl) ? addedFields.urefurl : '');
        notes = (addedFields.notes != null && isDataClean(addedFields.notes) ? addedFields.notes : '');
        uhowheard = (addedFields.uhowheard != null && isDataClean(addedFields.uhowheard) ? addedFields.uhowheard : '');
        udescribe = (addedFields.udescribe != null && isDataClean(addedFields.udescribe) ? addedFields.udescribe : '');
        filename = (addedFields.filename != null && isDataClean(addedFields.filename) ? addedFields.filename : '');
        uhscode = (addedFields.uhscode != null && isDataClean(addedFields.uhscode) ? addedFields.uhscode : '');
        UOptOutCam = (addedFields.UOptOutCam != null && isDataClean(addedFields.UOptOutCam) ? addedFields.UOptOutCam : '');
        UCAMPGNTYP = (addedFields.UCAMPGNTYP != null && isDataClean(addedFields.UCAMPGNTYP) ? addedFields.UCAMPGNTYP : '');
        System.Debug('VS -- Incoming UTEXTPERM -- '+addedFields.utextperm);
        utextperm = (addedFields.utextperm != null && isDataClean(addedFields.utextperm) ? addedFields.utextperm : 'No');
        if(''.equals(utextperm))
            utextperm = 'No';
        phone3 = (addedFields.phone3 != null && isDataClean(addedFields.phone3) ? addedFields.phone3 : '');
        ucampus = (addedFields.ucampus != null && isDataClean(addedFields.ucampus) ? addedFields.ucampus : '');
        urefrdby = (addedFields.urefrdby != null && isDataClean(addedFields.urefrdby) ? addedFields.urefrdby : '');
        Other_Colleges = (addedFields.Other_Colleges != null && isDataClean(addedFields.Other_Colleges) ?  addedFields.Other_Colleges : '');
        uoptindt = (addedFields.uoptindt != null && isDataClean(addedFields.uoptindt) ?  addedFields.uoptindt : '');
     }
      /** VS Adding functionality new Lead Processor Fields END **/
      
       ContactName = (ContactName != null && isDataClean(ContactName) ? ContactName : ''); 
      Address1= (Address1 != null && isDataClean(Address1) ? Address1 : '');  
      Address2= (Address2 != null && isDataClean(Address2) ? Address2 : ''); 
      City= (City != null && isDataClean(City) ? City : '');  
      State= (State != null && isDataClean(State) ? State : ''); 
      Country = (Country != null && isDataClean(Country) ? Country : '');   //@AbhaS - related to Columbia Updates - 11/19/2012
      Zip= (Zip != null && isDataClean(Zip) ? Zip : '');  
      Phone1= (Phone1 != null && isDataClean(Phone1) ? Phone1 : '');  
      Phone2= (Phone2 != null && isDataClean(Phone2) ? Phone2 : '');  
      Email= (Email != null && isDataClean(Email) ? Email : '');
      LP_Email = Email;
      Email = validateEmail(Email);
      Gender= (Gender != null && isDataClean(Gender) ? Gender : ''); 
      BestTime= (BestTime != null && isDataClean(BestTime) ? BestTime : '');  
      Program= (Program != null && isDataClean(Program) ? Program : '');  
      CourseInterest= (CourseInterest != null && isDataClean(CourseInterest) ? CourseInterest : '');  
      HSGradYear= (HSGradYear != null && isDataClean(HSGradYear) ? HSGradYear : '');  
      DateCreated= (DateCreated != null && isDataClean(DateCreated) ? DateCreated : ''); 
      HighLevel= (HighLevel != null && isDataClean(HighLevel) ? HighLevel : '');  
      newKey4= (newKey4 != null && isDataClean(newKey4) ? newKey4 : '');  
      Company= (Company != null && isDataClean(Company) ? Company : '');  
      Title= (Title != null && isDataClean(Title) ? Title : ''); 
      Source= (Source != null && isDataClean(Source) ? Source : ''); 
      UModality= (UModality != null && isDataClean(UModality) ? UModality : '');  
      UIMType= (UIMType != null && isDataClean(UIMType) ? UIMType : '');  
      UIMName= (UIMName != null && isDataClean(UIMName) ? UIMName : '');  
      RasId= (RasId != null && isDataClean(RasId) ? RasId : '');  
      OwnerId= (OwnerId != null && isDataClean(OwnerId) ? OwnerId : ''); 
      referredByOpportunity= (referredByOpportunity != null && isDataClean(referredByOpportunity) ? referredByOpportunity : ''); 
      referredByPerson= (referredByPerson != null && isDataClean(referredByPerson) ? referredByPerson : ''); 
      TransferredFromOpportunity= (TransferredFromOpportunity != null && isDataClean(TransferredFromOpportunity) ? TransferredFromOpportunity : ''); 
      
      /** Gender Logic START **/
      /** BUG Fix 641 VS START. Commenting the code that incorrectly sets the gender. The correct logic for Gender is available in the contact section of this class **/
      /**if(Gender.equalsIgnoreCase('m'))
          Gender = 'Male';
      else if(Gender.equalsIgnoreCase('f'))
          Gender = 'Female';
      else
          Gender = '';**/
          
           /** BUG Fix 641 VS START. Commenting the code that incorrectly sets the gender. The correct logic for Gender is available in the contact section of this class **/
      
      /** Gender Logic END **/
            Person__c pson = null;
            
            Savepoint sp = Database.setSavepoint();
            String linkedOppId = null;
            // Upsert Person if valid Ras Id returned - Otherwise insert Person
            Database.Saveresult oppId = null;
            boolean caseResult = null;
            String trimmedName = ContactName.trim();
            List<String> names = trimmedName.split(' ');
           
            String firstName = null;
            String lastName = null;
            Id PersonId = null;
             try{  
             
            Integer i;
            for (i=0; i < names.size() - 1; i++) {
                if (i == 0) {
                    firstName = names[i];
                } else {
                    firstName = firstName + ' ' + names[i];
                }
            }
             lastName = names[i];
            
            // Check if Ras ID Exist and update or insert Person record accordingly
             pson = new Person__c();
            Database.Upsertresult uPersonId = null;
            Database.Saveresult iPersonId = null;
           
            pson.Last_Name__c = lastName;
            pson.First_Name__c = firstName;
            
                if (RasId != '00000000-0000-0000-0000-000000000000' && RasId != null) {
                    pson.RasID__c = RasId;
                    System.Debug('Ras ID  --- '+pson.RASID__c);
                    uPersonId = Database.upsert(pson, Person__c.RasID__c);
                    System.Debug(' -- UPerson'+pson);
                } else {
                    iPersonId = Database.insert(pson);
                    System.Debug(' -- IPerson'+pson);
                }
                
                if (uPersonId != null)  {
                    personId = uPersonId.getId();
                } else {
                    personId = iPersonId.getId(); 
                }
            
            
            //Get Account for School
            List<Account> school = [select id, Name, Type, OwnerId
                                        from Account where Goldmine_key5__c = :Key5];
            System.Debug('After Calling School'+school);
            List<String> recordType = new List<String>();
            recordType.add('Deltak Student');
            recordType.add('Rasmussen Student');
            recordType.add('Student Opportunity'); /** Bug Fix 592 VS **/
            List<RecordType> recordTypes = [select id, Name from RecordType where Name IN :recordType ];
            Map<String, Id> recordTypeNameToId = new Map<String, Id>();
            Map<Id, String> recordTypeIdToName = new Map<Id, String>();
            if(recordTypes != null && recordTypes.size() > 0){
                for(RecordType thisRecordType : recordTypes){
                    recordTypeNameToId.put(thisRecordType.Name, thisRecordType.Id);
                    recordTypeIdToName.put(thisRecordType.Id, thisRecordType.Name);
                }
            }
            System.Debug('After Record Type'+recordTypeNameToId);
            
                Opportunity pr_opp = null;
                Contact pr_contact = null;
            if (school.size() > 0) {
                //Check for Duplicate Affiliation - Use Email Address if present on input
                /** VS Replacing the old duplicate contact detemination with the following
                1. A Contact should exist for the Person record
                2. The Account Id on the contact should be of the school in context
                3. The record type on the contact should match the school in context
                **/
                String schoolType = school[0].Type;
                Id record = null;
                if(schoolType == 'Deltak Partner' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Deltak Student'))
                     record = recordTypeNameToId.get('Deltak Student');
                if(schoolType == 'Rasmussen Campus' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Rasmussen Student'))
                     record = recordTypeNameToId.get('Rasmussen Student');
                
                List<Contact> dupContacts = null;
                dupContacts = [Select c.RecordTypeId, 
                                      c.Person__c, 
                                      c.Id, 
                                      c.AccountId 
                                From Contact c
                                Where c.Person__c = :pson.id
                                And c.AccountId = :school[0].id
                                And c.RecordTypeId = :record
                                ];
                
                
             /**   List<Contact> dupContacts = new List<Contact>();
                String query = 'select Id, FirstName, LastName from Contact where FirstName ='+firstName+' and LastName = '+lastName;
                query  += 'and AccountId = '+school[0].id;
                if(Email.contains('@'))
                    query += 'and Email = '+Email;
                
                
                if (Email.contains('@')) {
                    dupContacts = [select Id, FirstName, LastName from Contact 
                        where FirstName = :firstName and LastName = :lastName 
                        and Email = :Email and AccountId = :school[0].id];
                } else {
                    dupContacts = [select Id, FirstName, LastName from Contact 
                        where FirstName = :firstName and LastName = :lastName and AccountId = :school[0].id];
                }**/
                
                //dupContacts = Database.query(query);
                    
                Id ContactId = null;
                System.Debug('In Between Dup Contacts');
                if (dupContacts != null && dupContacts.size() > 0) {
                    System.Debug('Dupe Contacts'+dupContacts);
                    String caseType = 'Goldmine Lead';
                    String caseSubtype = 'Duplicate Contact';
                    String caseSubject = 'Potential Duplicate Affiliation - ' +  Key5 
                        + ' ' + ContactName + ' ' + Email;
                    String caseDescription = 'A potential duplicate affiliation has been forwarded from the lead router:\n'
                        + 'Name: ' + ContactName + '\nSchool: ' + Key5 +  '\nProgram: ' + Program + '\nCourse Interest: ' + CourseInterest 
                        + '\nEmail: ' + Email + '\nAddress1: ' + Address1 + '\nAddress2: ' + Address2 + '\nCity: ' + City + '\nState: '
                        + State + '\nCountry: ' + Country + '\nZip: ' + Zip + '\nPhone1: ' + Phone1 + '\nPhone2: ' + Phone2 + '\nBest Time: ' + BestTime;
                    //@AbhaS - related to Columbia Updates - 11/19/2012
                    
                    // VS 10-27-2010 Commenting the case creation for Duplicate Affiliation as we are not creating case for this scenario
                    //caseResult = DuplicateNotifier.createCaseBySchoolProgram(Key5, Program, caseType, caseSubtype, caseSubject, caseDescription, dupContacts[0].id, pson.id);
                    contactId = dupContacts[0].Id;  
                } else {
                    System.Debug(' -- Creating new Contact');
                    Contact newContact = new Contact();
                    newContact.FirstName = firstName;
                    newContact.LastName = lastName;
                    newContact.Email = Email;
                    newContact.AccountId = school[0].Id;
                    if(school[0].Type == 'Deltak Partner' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Deltak Student')){
                        newContact.RecordTypeId = recordTypeNameToId.get('Deltak Student');
                    }
                    if(school[0].Type == 'Rasmussen Campus' && recordTypeNameToId != null && recordTypeNameToId.containsKey('Rasmussen Student')){
                        newContact.RecordTypeId = recordTypeNameToId.get('Rasmussen Student');
                    }
                    newContact.person__c = personId;
                    newContact.MailingStreet = Address1 + '\n' + Address2;
                    newContact.MailingCity = City;
                    newContact.MailingState = State;
                    newContact.MailingCountry = Country;   //@AbhaS - related to Columbia Updates - 11/19/2012
                    newContact.MailingPostalCode = Zip;
                    newContact.Title = Title;
                    newContact.AccountId = school[0].id;
                    newContact.HomePhone = Phone2;
                    newContact.Work_Phone__c = Phone1;
                    System.Debug('VS -- UTEXTPERM---'+utextperm);
                    newContact.OK_to_Text__c = utextperm;
                    System.Debug('VS - Incoming UOPTINDT --'+uoptindt);
                    if('yes'.equals(utextperm) && uoptindt != null && uoptindt != '')
                        newContact.Original_Text_Opt_In_Date__c = datetime.valueOf(convertDateTime(uoptindt));
                    System.Debug('VS -- Opt In Date ----'+newContact.Original_Text_Opt_In_Date__c);
                    /** Preferred Phone Logic START **/
                    
                    if(Phone1 != null && Phone1 != '' && Phone1 != 'null'){
                        newContact.Preferred_Phone__c = 'Work';
                    }else if(Phone2 != null && Phone2 != '' && Phone2 != 'null'){
                        newContact.Preferred_Phone__c = 'Home';
                    }else{
                        newContact.Preferred_Phone__c = '';
                    }
                    
                    /** Preferred Phone Logic END **/
                    
                    
                    newContact.IM_Type__c = UIMType;
                    newContact.IM_Username__c = UIMName;
                    newContact.Best_Time_to_Contact__c = BestTime;
                    if(gender != null){
                        if (gender.equalsIgnoreCase('M') || gender.equalsIgnoreCase('Male')) {
                            newContact.Gender__c = 'Male';
                        } else if (gender.equalsIgnoreCase('F') || gender.equalsIgnoreCase('Femal') || gender.equalsIgnoreCase('Female')) {
                            newContact.Gender__c = 'Female';
                        }
                    }
                    if (Email.Contains('@')) {
                        newContact.Email = Email;
                    }
                    newContact.HS_Grad_Year__c = HSGradYear;
                     /** VS Adding functionality new Lead Processor Fields START **/
                    newContact.Employer_Company__c = Company;
                    /** VS Fixing bug 699. Mobile phone is empty. Phone3 was previously mapped to other phone. Now mapped to mobile phone **/
                    newContact.MobilePhone = phone3;
                     /** VS Adding functionality new Lead Processor Fields END **/
                   
                    system.debug('in contact notes>>>>'+notes);
                    String CountryOfCitizenship;
                    List<String> splitString = new List<string>();
                    if(notes!=null && notes.length() > 0){
                        splitString = notes.split('\\|'); 
                        system.debug('splitstring>>>>'+splitstring);
                        if(splitString.size()>0){
                            For(String s: splitstring){
                                if(s.contains('Country_Of_Citizenship')){
                                    List<String> slist = s.split('Country_Of_Citizenship: ');
                                    if(slist != null) countryofcitizenship = slist[1];
                                    system.debug('slist>>>>'+slist);
                                }
                            }
                        }else{
                            if(notes.contains('Country_Of_Citizenship')){
                                List<String> slist = notes.split('Country_Of_Citizenship: ');
                                if(slist != null) countryofcitizenship = slist[1];
                                system.debug('slist2>>>>'+slist);
                            }   
                        }   
                    }   
                     
                    if(countryofcitizenship != null) countryofcitizenship.trim();
                    
                    newcontact.country_of_citizenship__c = countryofcitizenship;

                    system.debug('newcontact.country_of_citizenship__c>>>>'+newcontact.country_of_citizenship__c);
                    
                    Database.Saveresult newContactId = Database.insert(newContact);
                    ContactId = newContactId.getId();
                  
                    pr_contact = newContact;
                    System.Debug('Completed Creating new contact'+pr_contact); 
                }
                
                System.Debug('Goldmin to salesforce program  ---');
                    List<Goldmine_to_Salesforce_Program__c> progs = [select Program_Id__c, Specialization_Id__c
                    //List<Goldmine_to_Salesforce_Program__c> progs = [select Id
                        from Goldmine_to_Salesforce_Program__c where Goldmine_Key5__c = :Key5 
                        //from Goldmine_to_Salesforce_Program__c where Id = :Key5 
                        and Goldmine_Program__c = :CourseInterest];
                   System.Debug('Create a new Opportunity  ');         
                    Opportunity newOpp = new Opportunity();
                    if(progs.size() > 0) {
                        newOpp.program__c = progs[0].Program_Id__c;
                        //newOpp.program__c = progs[0].Id;
                        newOpp.specialization__c = progs[0].Specialization_Id__c;
                        //newOpp.specialization__c = progs[0].Id;
                    }else{
                        newOpp.Other_Program__c = CourseInterest;
                    }
                    newOpp.name = 'From Lead' + GMId;
                    newOpp.AccountId = school[0].id;
                    newOpp.student__c = contactId;
                    newOpp.person__c = personId;
                    
                    newOpp.CloseDate = date.newInstance(2100, 1, 1);
                    
                    if (referredByOpportunity != null && referredByOpportunity != '' && referredByOpportunity != ' ' && referredByOpportunity != '?' && referredByOpportunity instanceof id) { 
                        newOpp.Referred_by_Opportunity__c = referredByOpportunity;
                    }
                    if (referredByPerson != null && referredByPerson != '' && referredByPerson != ' ' && referredByPerson != '?' && referredByPerson instanceof id) { 
                        newOpp.Referred_by_Person__c = referredByPerson;
                    }
                    if (TransferredFromOpportunity != null && TransferredFromOpportunity instanceof Id && TransferredFromOpportunity != '' && TransferredFromOpportunity != ' ' && TransferredFromOpportunity != '?') { 
                        // START - Change Transferred_From_Opportunity Id from being stored in a text field to being stored in the Transferred_From_Opportunity__c look-up field -- CB
                        // newOpp.Transferred_From_Opportunity_Txt__c = TransferredFromOpportunity;
                        newOpp.Transferred_From_Opportunity__c = TransferredFromOpportunity;
                        // END - Change Transferred_From_Opportunity Id from being stored in a text field to being stored in the Transferred_From_Opportunity__c look-up field -- CB
                    }
                    System.Debug('Starting Campus COntact Process');
                    
     
                    /** VS Adding functionality new Lead Processor Fields START **/
                    // Campaign Logic Start
                    System.Debug(' -- lEad Date');
                    
                    Date leadDate = Date.valueOf(DateCreated);
                    System.Debug('Campaign Start'+leadDate);
                    List<Campaign> campList = [Select id, Bucket_Campaign__c, IsActive
                                                from Campaign 
                                                where (Campaign_Code__c = :R_Campaign
                                                AND Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < :leadDate 
                                                AND EndDate >= :leadDate
                                                And IsActive = true) 
                                                OR (Bucket_Campaign__c = true
                                                    And IsActive = true)
                                                ];
                    Campaign bucketCampaign = null; 
                    Campaign campaignCode = null;
                    if(campList != null & campList.size() > 0){
                        boolean firstCampaign = true;
                        for(Campaign camp : campList){
                            if(camp.isActive){
                                if(camp.Bucket_Campaign__c)
                                   bucketCampaign = camp; 
                                else{
                                    if(firstCampaign){
                                        campaignCode=camp;
                                        firstCampaign = false;
                                    }
                                }
                            }    
                        }
                    }
                    System.Debug('End Campaign Process');
                    /** Fix for bug 717. bucketcampaign.id and campaigncode.id START -- VS*/
                    if(campaignCode == null &&bucketCampaign != null)
                       newopp.CampaignId = bucketCampaign.Id;
                    if(campaignCode != null)
                       newOpp.CampaignId =campaignCode.Id;
                    /** Fix for bug 717. bucketcampaign.id and campaigncode.id END -- VS*/
                    newOpp.LP_Campaign__c = R_Campaign;
                    System.Debug('Campaing --  '+newOpp.Campaign);
                    //Campaign Logic End  
                    newOpp.LP_Program__c = Program1;
                    newOpp.LP_Program2__c = Program2;
                    newOpp.LP_KEY1__c = Key1;
                    
                    /** Sales Stage Logic **/
                    if(Key2 != null){
                        String startWith = Key2.subString(0, 2);
                        if(stageNameMap != null && stageNameMap.containsKey(startWith)){
                            newOpp.Interest_Timeframe__c = stageNameMap.get(startWith);
                        }
                    }
                    
                    /** Bug Fix 592 START VS **/
                    if(recordTypeNameToId.containsKey('Student Opportunity')){
                        newOpp.RecordTypeId = recordTypeNameToId.get('Student Opportunity');
                    }
                    /** Bug Fix 592 END VS **/
                    
                    newOpp.LP_Referral__c = Referal;
                    newOpp.LP_Urefkeyword__c  = UrefKeyWrd;
                    newOpp.LP_UREFMEDIATYPE__c  = UrefMediaType;//@AbhaS UTM field - 10/15/12
                    newOpp.LP_UREFPROMOTION__c  = UrefPromotion;//@AbhaS UTM field - 10/15/12
                    newOpp.LP_Uadcampaign__c = UADCAMPGN;
                    newOpp.LP_Uadgroup__c = UADGROUP;
                    newOpp.LP_intlead__c = UINTLEAD;
                    newOpp.LP_ureurl__c = urefurl;
                   // newOpp.LP_notes__c = notes;
                   
                    String typeOfLawDegree = '';
                    String CountryOfCitizenship = '';
                    List<String>splitString = new List<string>();
                    if(notes!=null && notes.length() > 0){
                        splitString = notes.split('\\|'); 
                        system.debug('splitstring>>>>'+splitstring);
                        if(splitstring!=null && splitString.size()>0){
                            For(String s: splitstring){
                                if(s.contains('Country_Of_Citizenship')){
                                    List<String> slist = s.split('Country_Of_Citizenship: ');
                                    if(slist != null && slist.size()>1) countryofcitizenship = slist[1];
                                    system.debug('slist>>>>'+slist);
                                }else{
                                    if(s.contains('Type_Of_Law_Degree')){
                                        List<String> slist = s.split('Type_Of_Law_Degree: ');
                                        if(slist != null && slist.size()>1) typeoflawdegree = slist[1];
                                    }
                                    else{
                                        newOpp.LP_notes__c = s;
                                    }
                                }
                            }
                        }   
                        else
                         {
                            newOpp.LP_notes__c = notes;
                         }
                     }
                     
                    if(countryofcitizenship != null) countryofcitizenship.trim();
                    if(typeoflawdegree != null) typeoflawdegree.trim();

                    newopp.type_of_law_degree__c = typeoflawdegree;
                    newopp.country_of_citizenship__c = countryofcitizenship;

                    system.debug('newopp.LP_notes__c>>>>'+newopp.LP_notes__c);
                    system.debug('newop.type_of_law_degree__c>>>>'+newopp.type_of_law_degree__c);
                    system.debug('newopp.country_of_citizenship__c>>>>'+newopp.country_of_citizenship__c);
                    
                    newOpp.Source__c = Source;
                    newOpp.How_Heard_Detail__c = uhowheard;
                    newOpp.Modality__c = umodality;
                    newOpp.LP_Udescribe__c = udescribe;
                    newOpp.LP_Filename__c = filename;
                    newOpp.LP_uhscode__c = uhscode;
                    newOpp.LP_Uoptoutcam__c = UOptOutCam;
                    newOpp.LP_Ucampgntyp__c = UCAMPGNTYP;
                    newOpp.LP_utextperm__c = utextperm;
                    newOpp.LP_UCAMPUS__c = ucampus;
                    newOpp.LP_UREFRDBY__c = urefrdby;
                    newOpp.LP_OTHERCOLLEGES__c = Other_Colleges;
                    newOpp.LP_Email__c = LP_Email;
                    
                    /** VS Adding functionality new Lead ProcessoSystem.Debug('HighLevel -->'+ HighLevel);
                    newOpp.Highest_Degree_Earned__c = HighLevel;r Fields END **/
                           
                
                //Check for Duplicate Opportunity
                List<String> dupOps = DuplicateOpportunityCheck.check(ContactId, Key5);
                /**
                VS - 10-27-2010 Duplicate Opportunity gets a new Opportunity with Stage:Dormant; SubStage: Duplicate
                Duplicate Opportunity gets a Lead Failure record with Duplicate Opportunity Flag set to true
                */
                if (dupOps.size() > 0) {
                    newOpp.StageName = 'Dormant';
                    newOpp.Sub_Stage__c = 'Duplicate Record';
                    List<Opportunity> OppforOwner = [Select OwnerId from Opportunity where Id = :dupOps[0] and Owner.IsActive = true ];
                    System.debug('OppforOwner[0].OwnerId-->'+ OppforOwner[0].OwnerId);
                    
                    if(OppforOwner != null && OppforOwner.size() > 0)
                        newOpp.OwnerId = OppforOwner[0].OwnerId;
                    else
                        newOpp = assignOwner(newKey4, School, newOpp, OwnerId);
                        
              // Girija: added if-condition to check the if the oppty owner is PROspect engine, if so, then assign oppty to acct owner
              //for ticket SRP: 1454       
                    Prospect_Setting__c setting = Prospect_Setting__c.getInstance();     
                    List<Opportunity> acctOwner = [Select Account.ownerid from Opportunity where Id = :dupOps[0]];                    
                    if(newOpp.OwnerId == setting.PROspect_User_ID__c)
                    {
                        if(acctOwner!= null && acctOwner.size() > 0)
                            newOpp.OwnerId = acctOwner[0].Account.ownerid;                            
                    }
                    
                    RasReportLeadFailure reportFailure = new RasReportLeadFailure();
                    Boolean duplicateOpportunity = true; 
                    Id failure = reportFailure.createFailureRecord( String.valueOf(GMId),ContactName, Address1,Address2, City, State, Zip, Phone1, 
                                                      Phone2, Email,Gender,BestTime, Program, CourseInterest, 
                                                      HSGradYear, newKey5,DateCreated, HighLevel, newKey4, 
                                                      Company, Title, Source, UModality, UIMType, UIMName, 
                                                      RasId, OwnerId, referredByOpportunity, referredByPerson, 
                                                      TransferredFromOpportunity, duplicateOpportunity, addedFields);
                   //@AbhaS - related to Columbia Updates 11/19/2012
                   //if(Country != null){
                   //    LP_Failure lp_fail = null;
                   //    Id failure1 = reportFailure.createFailureRecord(lp_pers, lp_affl, lp_oppty, lp_fail);
                   //}//   //
                    
                } else {
                    newOpp.StageName = 'New Inquiry';
                    //If OwnerId passed from Lead Router,
                    newOpp = assignOwner(newKey4, School, newOpp, OwnerId);
                   
                    
                    
                }
                System.Debug('Opportunity Inserted -- VS -- '+newOpp);
                oppId = Database.Insert(newOpp);
                
                pr_opp = newopp;
                linkedOppId = oppId.getId(); 
            } else {
                throw new UserException('Key5 Value ' + Key5 + ' on lead ' + GMId + ' not mapped to Salesforce account.');
            }
            List<String> lr = new List<String>();
            lr.add('Success');
            lr.add(linkedOppId);
            if(pr_opp != null){
              lr.add(pr_opp.LP_Filename__c);
              lr.add(pr_opp.Interest_Timeframe__c);
            }
            
            lr.add('');
            lr.add('');
            lr.add(''); 
            return lr;
            } catch (Exception e) {
                Database.rollback(sp);
                
                //EmailUtils.sendTextEmail(emailRecepients, 'SFDC Lead Processor Error Occurred for '+ContactName, e.getMessage());
                RasReportLeadFailure reportFailure = new RasReportLeadFailure();
                /** 2/7/11 Added the following line as part of  CR59 -- CB **/
                reportFailure.errorMessage = e.getMessage();
                Boolean duplicateOpportunity = false;
                System.Debug('VS - Error Message-- '+e.getMessage());
                
                List <string> address = new List <string>();
                address.add(Address1);
                address.add(Address2);
                  
                Id failure = reportFailure.createFailureRecord(                 
                    String.valueOf(GMId),
                    ContactName,                    
                    Address1,
                    Address2,
                    City, State, Zip, Phone1, 
                      Phone2, Email,Gender,BestTime, Program, CourseInterest, 
                      HSGradYear, newKey5,DateCreated, HighLevel, newKey4, 
                      Company, Title, Source, UModality, UIMType, UIMName, 
                      RasId, OwnerId, referredByOpportunity, referredByPerson, 
                      TransferredFromOpportunity,duplicateOpportunity, addedFields);
               
                /*
                 * CB  --  2/7/11 - 
                 * This method will no longer be called due to CR59 which states that we will not create cases when a Lead failure occurs
                 * Instead, a workflow rule will fire when a new Lead Failure record is created which notifies whoever supports the Lead Processor
                                                                       
                reportFailure.notifyFailure(e.getMessage(), failure);
                */
                List<String> lr = new List<String>();
                lr.add('Failure');
                lr.add('');
                lr.add(e.getTypeName() + ' - ' + e.getMessage()); 
                return lr;
            }
     }

          public static LeadRouter_AdditionalFields populateAddedFields(LP_Person lp_pers, LP_Affiliaiton lp_affl, LP_Opportunity lp_oppty){
            LeadRouter_AdditionalFields addedFields = new LeadRouter_AdditionalFields();
            addedFields.Company = lp_oppty.Company;
            addedFields.filename = lp_oppty.filename;
            addedFields.Key1 = lp_oppty.Key1;
            addedFields.Key2 = lp_oppty.Key2;
            addedFields.Key5 = lp_oppty.Key5;
            addedFields.notes = lp_oppty.notes;
            addedFields.Other_Colleges = lp_oppty.Other_Colleges;
            addedFields.phone3 = lp_affl.phone3;
            addedFields.Program = lp_oppty.Program;
            addedFields.Program2 = lp_oppty.Program2;
            addedFields.R_Campaign = lp_oppty.R_Campaign;
            addedFields.Referal = lp_oppty.Referal;
            addedFields.Source = lp_oppty.Source;
            addedFields.UADCAMPGN = lp_oppty.UADCAMPGN;
            addedFields.UADGROUP = lp_oppty.UADGROUP;
            addedFields.UCAMPGNTYP = lp_oppty.UCAMPGNTYP;
            addedFields.ucampus = lp_oppty.ucampus;
            addedFields.udescribe = lp_oppty.udescribe;
            addedFields.uhowheard = lp_oppty.uhowheard;
            addedFields.uhscode = lp_oppty.uhscode;
            addedFields.UINTLEAD = lp_oppty.UINTLEAD;
            addedFields.uoptindt = String.valueOf(lp_oppty.uoptindt);
            addedFields.UOptOutCam = lp_oppty.UOptOutCam;
            addedFields.UrefKeyWrd = lp_oppty.UrefKeyWrd;
            addedFields.UrefMediaType = lp_oppty.UrefMediaType;//@AbhaS UTM field - 10/15/12
            addedFields.UrefPromotion = lp_oppty.UrefPromotion;//@AbhaS UTM field - 10/15/12
            addedFields.urefrdby = lp_oppty.urefrdby;
            addedFields.urefurl = lp_oppty.urefurl;
            addedFields.utextperm = lp_affl.utextperm;
            
            
            
            return addedFields;
        }
     
      public static  Opportunity assignOwner(String newKey4, List<Account> school, Opportunity newOpp, String OwnerId){
                      List<DataManagement__c> datamanagementList = new List<DataManagement__c>();
                      datamanagementList = DataManagement__c.getAll().values();
                      List<String> userIdList = new List<String>();
                     for (DataManagement__c e : datamanagementList ) {
                      if (e.Active__c) {
                            userIdList.add(e.SF_User_ID__c);
                            break;
                      }
                    }
                    if (OwnerId.length() < 12) {
                        List<User> oppOwners = null;
                        if(newKey4 != null && newKey4 != '' && newKey4 != 'null')
                            oppOwners = [select id from User where GM_Name__c = :newKey4];
                        if (oppOwners!= null && oppOwners.size() > 0) {
                            newOpp.OwnerId = oppOwners[0].Id;
                        } else {
                           // throw new UserException('PM (Key4) ' + newKey4 + ' on lead ' + GMId + ' does not have a matching user in Salesforce');
                           List<Campus_Contacts__c> campusList = [Select Id, 
                                                                    Employee__c, 
                                                                    Active_User__c, 
                                                                    Default_Owner__c 
                                                                From Campus_Contacts__c 
                                                                where Default_Owner__c = true 
                                                                and Organization__c = :School[0].id limit 1 ];
                            if(campusList != null && campusList.size() > 0 && campusList[0].Employee__c != null)
                                newOpp.OwnerId = campusList[0].Employee__c;
                            else
                                newOpp.OwnerId = school[0].OwnerId;
                            
                            
                            }
                            if(OwnerId.contains('low'))
                                newOpp.Inquiry_Rating__c = 'Low';
                            else if(OwnerId.contains('med'))
                                newOpp.Inquiry_Rating__c = 'Medium';
                            else if(OwnerId.contains('hig'))
                                newOpp.Inquiry_Rating__c = 'High';
                           if(ownerId.startswith('low') || ownerId.startswith('med'))
                               newOpp.OwnerId  = userIdList[0];
                            
                    } else {
                        /** Bug Fix 599 START VS **/
                        System.Debug('test Debug - 1'+ownerId);
                        if(ownerId instanceof Id && ownerId.startswith('005')){
                        System.Debug('test Debug -1a'+ownerId);
                            newOpp.OwnerId = OwnerId;
                        }
                        //Mass Lead Upload Enhancement 
                        else{
                        System.Debug('test dDebug --2');
                            List<String> ownerIdRating = getOwnerIdRating(ownerId);
                            System.Debug('ownerIdRating'+ownerIdRating);
                            String rating  = ownerIdRating [0];
                            String actualOwnerId = '';
                            if('Low'.equals(Rating) || 'Medium'.equals(Rating))
                                actualOwnerId =   userIdList[0];
                            else
                                actualOwnerId = ownerIdRating[1];
                            System.Debug('actualOwnerId'+actualOwnerId);
                            System.Debug('rating' +rating);
                            if(actualOwnerId instanceof Id)
                               newOpp.OwnerId = actualOwnerId;
                            newOpp.Inquiry_Rating__c = rating;
                        }
                        /** Bug Fix 599 END VS **/
                    }
                    System.Debug('End Campus Contacts Process');
                    return newOpp;
                 }
                 
                 public static List<String> getOwnerIdRating(String ownerId){
                     List<String> returnString = new List<String>();
                     String rating  = ownerId.subString(0,3);
                     
                            Integer len = ownerId.length();
                            String actualOwnerId = ownerId.subString(3, len);
                            if(rating.startswith('low'))
                                rating = 'Low';
                            else if(rating.startswith('med'))
                                rating = 'Medium';
                            else if(rating.startswith('hig'))
                                rating = 'High';
                            returnString.add(rating);
                            returnString.add(actualOwnerId);
                       return returnString;
                            
                 }
                 
               /*
               Girija: added this logic to support SRP-1273: adding work exp and gpa fields. 
               */ 
                 public static Opportunity getWorkExpAndGpa(String key5, String notes, Opportunity newOpp)
                 { 
                     if(key5 == 'JHUAAP' && notes != null && notes.length() > 0 && (notes.contains('workexp=') || notes.contains('gpa=')) )
                     {
                        if((notes.contains('workexp=') && notes.contains('gpa=')))
                        {
                            String workexpGpaString = notes.replaceAll('workexp=', '').Trim();                      
                            //If the actual string is "workexp=5#gpa=4.0 and above" , at this point we have "5#gpa=4.0 and above"
                            List<String> valueList = workexpGpaString.split('#');                       
                            String workexp = valueList[0];
                            newOpp.Yrs_Wrk_Exp__c = Integer.valueOf(workexp);
                            List<String> valueList2 = valueList[1].split('=');                      
                            String gpaValue = valueList2[1];
                            newOpp.GPA__c = assignGpaValue(gpaValue);                           
                        }
                        if((notes.contains('workexp=') && !(notes.contains('gpa='))))
                        {
                            String workexpGpaString = notes.replaceAll('workexp=', '').Trim();                  
                            newOpp.Yrs_Wrk_Exp__c = Integer.valueOf(workexpGpaString);
                        }
                        if(!((notes.contains('workexp=')) && notes.contains('gpa=')))
                        {
                            String gpaValue = notes.replaceAll('gpa=', '').Trim();
                            newOpp.GPA__c = assignGpaValue(gpaValue);
                        }
                    }
                    return newOpp;
                 }
                 
                 public static Double assignGpaValue(String gpaValue)
                 {
                    Double gpa= 0;
                    if(gpaValue == '4.0 and above')
                        gpa = 4.0;
                    if(gpaValue == '3.99 – 3.50')  // the length of '-' matters. If small - is used, the comparison fails. Hence used longer '–'.
                        gpa = 3.75;
                    if(gpaValue == '3.49 – 3.0') 
                        gpa = 3.25;
                    if(gpaValue == '2.99 – 2.50')
                        gpa = 2.75;
                    if(gpaValue == '2.49 or below')
                        gpa = 2.49; 
                    return gpa;
                 }
   
              
}