public without sharing class SRPEventRFIController {
    public Boolean infoerroronly {get;set; }
    public Boolean newLead {get; set; }
    public Integer numberOfAttendees {get; set; }
    
    public String eventId {get;set;}
    public String eventType {get;set;}
    public String formattedEventType {get;set;}
    public List<DeltakSRP__Event__c> eventNameList = null;
    public List<DeltakSRP__Event__c> eventListPerType = null;
    public String eventName {get; set;}
    public Id eID {get; set;}
    public Boolean hasAddlQtns {get; set;}
    public Boolean eventTypeMode {get; set;}
    
    public static final String RFI_PREFIX = 'Prefix';
    public static final String RFI_FIRST_NAME = 'First Name';
    public static final String RFI_MID_INITIAL = 'Middle Initial';
    public static final String RFI_LAST_NAME = 'Last Name';
    public static final String RFI_ADDRESS1 = 'Street Address';
    public static final String RFI_CITY = 'City';
    public static final String RFI_STATE = 'State';
    public static final String RFI_ZIP = 'Zip';
    public static final String RFI_PHONE = 'Phone';
    public static final String RFI_INTENDED_MAJOR = 'Intended Major';
    public static final String RFI_INTENDED_ST = 'Intended Start Term';
    public static final String RFI_PREV_INST_NAME = 'I am Currently in:';
    public static final String RFI_SEND_ME_LIST = 'Please send me:';
    public static final String RFI_OTHER_INTENDED_MAJOR = 'Other Major';
    public static final String RFI_OTHER_INST_NAME = 'Other Institution';
    public static final String RFI_OTHER_SEND_ME = 'Other Send me List';
    public static final String RFI_EMAIL = 'Email';
    public static final String DEFAULT_NONE_PL = 'Please Select One:';
    public static final String DEFAULT_OTHER_PL = 'Other';
    public static String RFI_LEAD_RT = 'SRP Lead';
    public static String RFI_LEAD_COMPANY_DEFAULT = 'Not specified in RFI';//Used in SRPLEadRFIController
    public static String LEAD_RFI_INQUIRY_SOURCE = 'RFI';
    public static String INTERNATIONAL_RFI_SOURCE = 'International RFI';
    public static String RFI_PL_HIGH_SCHOOL = 'High School';
    public static String RFI_PL_COLLEGE = 'College';
    public static String RFI_PL_NEITHER = 'Neither';
    public static String RFI_SUFFIX = 'Suffix';
    public static String RFI_STUDENT_TYPE = 'type';
    public static String RFI_VISA_YES = 'Yes';
    public static String RFI_INTERNATIONAL = 'international';
    
    //Event RFI Additions
    public static String EVENT_RFI_NUMBER_ATTENDING = 'Number Attending';
    public static String EVENT_RFI_GUEST1_FULL_NAME = 'Guest 1 Full Name';
    public static String EVENT_RFI_GUEST2_FULL_NAME = 'Guest 2 Full Name';
    public static String EVENT_RFI_SPECIAL_NEEDS = 'Special Needs';
    public static String EVENT_RFI_EVENT_ID = 'eventId';
    public static String EVENT_RFI_EVENT_MEMBER_TYPE_DEFAULT = 'Attendee';
    public static String EVENT_RFI_INQUIRY_SOURCE = 'Event RFI';
    public static String EVENT_RFI_STUDENT_RT = 'SRP Student';
    public static String EVENT_RFI_COMMENTS = 'comments'; 

    public static String EVENT_RFI_EVENT_TYPE = 'eventType';
    public static String EVENT_RFI_LOCATION   = 'Location';
    public static String EVENT_RFI_EVENTDATE  = 'Event Date';
    public static String EVENT_RFI_STUDENT_BEVERAGE = 'Student Beverage';
    public static String EVENT_RFI_GUEST1_BEVERAGE = 'Guest 1 Beverage';
    public static String EVENT_RFI_GUEST2_BEVERAGE = 'Guest 2 Beverage';
    public static String EVENT_TYPE_RFI_FULLY_CAFF_TOUR = 'Fully_Caffeinated_Tour';
    
    public class EventRFIField{
        public String fieldValue {get; set; }
        public String[] fieldValueList {get; set; }
        public Boolean fieldRequired {get; set; }
        public Boolean fieldRendered {get; set; }
        public EventRFIField(String fieldVal, Boolean fieldReq, Boolean fieldRend){
            this.fieldValue = fieldVal;
            this.fieldRequired = fieldReq;
            this.fieldRendered = fieldRend;
        }
    }
    
    public Id accountid;
    public Boolean validated {get; set; }
    public EventRFIField firstName {get; set; }
    public EventRFIField lastName {get; set; }
    public EventRFIField phone {get; set; }
    public EventRFIField email {get; set; }
    public EventRFIField venueType {get; set; }
    public EventRFIField eventDate {get; set; }

    public EventRFIField intendedMajor {get; set; }


    public List<selectOption> numberOfAttendingList {get; set;}
    public List<selectOption> expectedTermOfEntryList {get; set; }
    public List<selectOption> intendedMajorList {get; set;}
    public List<selectOption> venueTypeList {get; set;}
    public List<selectOption> eventDateList {get; set;}
    
    
    public class ObjectsToCreate{
        public Boolean contact_object;
        public Boolean lead_object;
        String contactId;
        public ObjectsToCreate(Boolean contact_object, Boolean lead_object, String contactId){
            this.contact_object = contact_object;
            this.lead_object = lead_object;
            this.contactId = contactId;
        }
    }
    
    public class AdditionalQuestions{
        public String qtn_text {get; set; }
        public Boolean qtn_required {get; set; }
        public Boolean qtn_rendered {get; set; }
        public String eventMem_field {get; set; }
        public Double qtn_order {get; set;}
        public String fld_Type {get; set;}
        public List<SelectOption> inputOptions {get; set; }
        public Boolean checkbox_Option {get; set;}
        public String qtn_response {get; set; }
        public AdditionalQuestions(String qText, Boolean qRequired, Boolean qRendered, String evMemFld, Decimal qOrder, String fType, List<SelectOption> inpOpt, Boolean cbOption, String qResponse){
            this.qtn_text = qText;
            this.qtn_required = qRequired;
            this.qtn_rendered = qRendered;
            this.eventMem_field = evMemFld;
            this.qtn_order = qOrder;
            this.fld_Type = fType;
            this.inputOptions = inpOpt;
            this.checkbox_Option = cbOption;
            this.qtn_response = qResponse;
        }
    }
    
    public List<AdditionalQuestions> addlQtnList {get; set; }
     
     public SRPEventRFIController() {
        DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance(); 
        accountid = setting.DeltakSRP__Partner_Account_Id__c;
        system.debug('Account Id-->'+accountId);
        numberOfAttendees = 1;
        initiateEventRFIFields();
        renderEventRFIfields();
        infoerroronly = false;
        newLead = true;
        eventTypeMode = false;
        eventId = Apexpages.currentPage().getParameters().get(EVENT_RFI_EVENT_ID);
        system.debug('eventid>>>>'+eventid);
        if (eventID != null)
        {
            eventTypeMode = false;
            system.debug('eventid>>>>'+eventid);
            eventNameList = [Select Name, Id from DeltakSRP__Event__c Where DeltakSRP__Event__c.DeltakSRP__Registration_Code__c =: eventID limit 1];
            if (eventNameList != null && !eventNameList.isEmpty())
            {
                eventName = eventNameList.get(0).Name;
                eID = eventNameList.get(0).Id;
            }
        }
        hasAddlQtns = false;
        eventType = Apexpages.currentPage().getParameters().get(EVENT_RFI_EVENT_TYPE);
        system.debug('eventType>>>>'+eventType);
        if (eventType != null)
        {
            eventTypeMode = true;
            formattedEventType = eventType.replaceAll('_',' ');
            Schema.DescribeFieldResult fR = Schema.sObjectType.DeltakSRP__Event__c.fields.DeltakSRP__Venue_Type__c;
            venueTypeList =  constructSRPPickLists(fR, true);

        }
        intendedMajorList = new List<selectOption>();
        expectedTermOfEntryList = new List<selectOption>();

        loadIntendedMajors();
        //loadExpectedTermOfEntry();
        
    } 
    
    public List<SelectOption> constructSRPPickLists(Schema.DescribeFieldResult fieldResult, Boolean showNone){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(showNone)
            options.add(new SelectOption('', 'Select One'));
        for( Schema.PicklistEntry f : ple)
        {
           options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
     }
     
     

    public void initiateEventRFIFields(){
        validated = true;
        
        firstName = new EventRFIField('',false,false);
        lastName = new EventRFIField('',false,false);
        phone = new EventRFIField('',false,false);
        email = new EventRFIField('',false,false);
        venueType = new EventRFIField('',false,false);
        eventDate = new EventRFIField('',false,false);
       
        intendedMajor = new EventRFIField('',false, false);

    }
   
    public void setRenderedAndRequired(EventRFIField thisField, Boolean required, Boolean rendered ){
    thisField.fieldRequired = required;
    thisField.fieldRendered = rendered;
    }
     
    public void renderEventRFIfields(){
        //initiateRFIfields();
       
        setRenderedAndRequired(firstname, true, true);
        setRenderedAndRequired(lastName, true, true);
        setRenderedAndRequired(email, true, true);
        setRenderedAndRequired(phone, true, true);
        setRenderedAndRequired(venueType, true, true);
        setRenderedAndRequired(eventDate, true, true);
        setRenderedAndRequired(intendedMajor, true, true);
              
     }
     
     
     public PageReference loadEventDates(){
        
        List<DeltakSRP__Event__c> eventDates = new List<DeltakSRP__Event__c>([Select Name, Id, DeltakSRP__Start__c from DeltakSRP__Event__c Where DeltakSRP__Event__c.DeltakSRP__Type__c =: formattedEventType and DeltakSRP__Venue_Type__c =: venueType.fieldValue and DeltakSRP__Start__c >=: system.now() order by DeltakSRP__Start__c]);
        eventDateList = new List<SelectOption>();
        eventDateList.add(new SelectOption(DEFAULT_NONE_PL,DEFAULT_NONE_PL));
        for(DeltakSRP__Event__c eDt: eventDates)
        {
            eventDateList.add(new SelectOption(String.valueOf(eDt.DeltakSRP__Start__c), (eDt.DeltakSRP__Start__c).format('MMM dd @ hh:mm a','America/Chicago')));
        }
        return null;
     }
     

     public PageReference saveLead(){
        Boolean success = true;
        if(validateEventRFI())
        {
            
            System.debug('Here inside saveLead');
            try{    
                Id contactid;
                if(eventTypeMode)
                    {
                        //Find Event Id
                        system.debug('eventType-->'+eventType);
                        system.debug('venueType-->'+venueType.fieldValue);
                        system.debug('eventDate-->'+eventDate.fieldValue);
                        system.debug('eventDate formatted-->'+dateTime.valueOf(eventDate.fieldValue));
                        
                        
                        eventNameList = [Select Name, Id from DeltakSRP__Event__c Where DeltakSRP__Type__c = :formattedEventType and DeltakSRP__Start__c =: dateTime.valueOf(eventDate.fieldValue)];
                        if (eventNameList != null && !eventNameList.isEmpty())
                        {
                            system.debug('Event Name-->'+eventNameList.get(0).Name);
                            eventName = eventNameList.get(0).Name;
                            eID = eventNameList.get(0).Id;
                        }
                        
                    }
                if(eID != null){
                    ObjectsToCreate otc = performEventRFIBasedChecks(); 
                    if(otc.contact_object){
                        contactid = insertcontact();
                    }else{
                        contactid = otc.contactId;
                    }
                    String leadId = null;
                    if(otc.lead_object){
                        leadId = insertlead(contactid);
                    }
                    system.debug('leadId>>>>'+leadId);  
                    createEventMember(contactid, eID, leadId);
                }else{
               
                    contactid = insertcontact();
                    system.debug('contactid>>>>'+contactid);
                    insertlead(contactid);
                                
               
                }
            }catch(exception e){
                success=false;
                apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.Error,e.getmessage()));
                System.Debug('Exception -- e'+e);
                infoerroronly=true;
                return null;
            }

        
        }else{
            success = false;
            apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,'Please correct the errors !'));
            
            return null;
        }   
        if(success)
        {
             newLead = false;
                apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.confirm, 'Information Request Received.'));
                apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.confirm, 'Thank you for your interest in Loyola University (New Orleans). You will be receiving more information very soon.'));
                apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.confirm, 'If you have any questions or need any additional information in the meantime, please contact our Admissions Department at (630) 123-8900 ext. 1234. We look forward to working with you!'));
                
                infoErrorOnly = true;
        }
        return null;
        
     }
     
      public Id insertContact(){
        
        Id rt = [Select Id from RecordType where name = :EVENT_RFI_STUDENT_RT].Id;
        
        Contact c = new Contact();
        c.RecordTypeId = rt;
        c.FirstName = firstname.fieldValue;
        c.LastName = lastName.fieldValue;
        
        c.Email = email.fieldValue;
        
        c.Phone = phone.fieldValue;
       
        c.AccountId = accountid;    
        System.Debug('to be inserted contact -- '+c);   
        insert c;

        return c.id;
     }
     
      String guestCount = '';
      String guest1FName = '';
      String guest2FName = '';
      String studentBev = '';
      String guest1Bev = '';
      String guest2Bev = '';
      String specNeeds = '';
    //  String otherReq = '';
      String comment = '';
      public Boolean validateEventRFI(){
        
        validated = true;
       
        validated = validateThisField(validated, firstname.fieldRequired, firstname.fieldValue, '', 'First Name is Required');
        validated = validateThisField(validated, lastname.fieldRequired, lastname.fieldValue, '', 'Last Name is Required');   
        validated = validateThisField(validated, phone.fieldRequired, phone.fieldValue, DEFAULT_NONE_PL, 'Phone is Required');
        validated = validateThisField(validated, email.fieldRequired, email.fieldValue, '', 'Email is Required');
        validated = validateEmail(validated, email.fieldValue, 'Provided email is not valid');
        if(phone.fieldValue!=''){
            String unformattedph = unformattedphone(phone.fieldValue);
            if(!(unformattedph!=null && unformattedph.length() >=10 && unformattedph.isnumeric())){
                apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,'Phone number is not in correct format'));
                validated = false;
            }       
        }
        if(eventTypeMode)
        {
            validated = validateThisField(validated, venueType.fieldRequired, venueType.fieldValue, DEFAULT_NONE_PL, 'Please choose a type');
            validated = validateThisField(validated, eventDate.fieldRequired, eventDate.fieldValue, DEFAULT_NONE_PL, 'Please choose an event date');
        }
        if(intendedMajor == null || intendedMajor.fieldValue == null || intendedMajor.fieldValue == DEFAULT_NONE_PL){
            validated = false;
            apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,'Please choose at least one intended major'));
        }
        
       
        system.debug('validated-->'+validated); 
        return validated; 
     }
     
     public Boolean validateThisField(Boolean currentValidation, Boolean fieldRequired, String fieldName, String checkFor, String errorMessage){
        
        if(fieldRequired && (fieldName == '' || fieldName == checkFor || fieldName == null)){
            currentValidation = false;
            apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,errorMessage));
        }
        return currentValidation;
     }
     public Boolean validateEmail(Boolean currentValidation, String email, String errorMessage){
        if(email != null && email != ''){
            String regex = '^([a-z0-9+._-]+@)([a-z0-9-]+\\.)+(a(?:[cdefgilmnoqrstuwxz]|ero|(rp|si)a)$|(b([abdefghijmnorstvwyz]|iz))$|(c([acdfghiklmnoruvxyz]|at|o(m|op)))$|(d[ejkmoz])$|(e([ceghrstu]|du))$|(f[ijkmor])$|(g([abdefghilmnpqrstuwy]|ov))$|(h[kmnrtu])$|(i([delmnoqrst])|(n(fo|t)))$|(j([emop]|obs))$|(k[eghimnprwyz])$|(l[abcikrstuvy])$|(m([acdeghklmnopqrstuvwxyz]|il|obi|useum))$|(n([acefgilopruz]|ame|et))$|o(m|rg)$|(p([aefghklmnrstwy]|ro))$|(qa)$|(r[eosuw])$|(s[abcdeghijklmnortuvyz])$|(t([cdfghjklmnoprtvwz]|(rav)?el))$|(u[agkmsyz])$|(v[aceginu])$|(w[fs])$|(y[etu])$|(z[amw])$)+';
            //if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', email))
            if(!Pattern.matches(regex, email.toLowerCase()))
            {
                currentValidation = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errorMessage)); 
            }
        }
     return currentValidation;
     }
     public static String unformattedPhone(String pnumber){
          if(pnumber == null)
            return null;
          String phonenumber = pnumber;
          phonenumber = phonenumber.replace('-','');
          phonenumber = phonenumber.replace('.','');
          phonenumber=phonenumber.replace(')','');
          phonenumber=phonenumber.replace('(','');
          phonenumber=phonenumber.replace(' ','');
          phonenumber=phonenumber.replace('x','');
          system.debug('phonenumber>>>>'+phonenumber);
          phonenumber.trim();
          return phonenumber;  
     }
    
    public ObjectsToCreate performEventRFIBasedChecks(){
        List<Contact> contactList = [Select id from Contact where FirstName = :firstname.fieldValue and
                                                                LastName = :lastname.fieldValue and
                                                                (Email = :email.fieldValue or Phone = :phone.fieldValue)];
        ObjectsToCreate otc = null;
        Id contactid;
        if(contactList != null && contactList.size() > 0)
        {
            contactid = contactlist[0].id;
            List<Lead> leadList = [Select Id, DeltakSRP__Academic_Term_Lookup__c  from Lead where 
                                    DeltakSRP__Contact__c = :contactid];
            if(leadList != null && leadList.size() > 0)
            {
                for(Lead l : leadList)
                {
                    otc = new ObjectsToCreate(false, true, contactId);
                }
            }else
            {
                // Found a contact with the given information but did not find a lead. This case is rare but possible and when happens create a new lead and associate to the existing contact
                otc = new ObjectsToCreate(false, true, contactId);
            }
        }else
        {
            //Did not find a contact with the dupe check. Create new lead and new contact
            otc = new ObjectsToCreate(true, true, null);
        }
        
        
        return otc; 
     }
    
    public void createEventMember(Id contactID, String eID, String leadId){
        if (eID != null)
        {
            DeltakSRP__Event_Member__c eventMember = new DeltakSRP__Event_Member__c();
            eventMember.DeltakSRP__Event__c = eID;
            eventMember.DeltakSRP__Contact__c = contactId;
            eventMember.DeltakSRP__Role__c = EVENT_RFI_EVENT_MEMBER_TYPE_DEFAULT;
            eventMember.DeltakSRP__Registered__c = true;
            eventMember.DeltakSRP__Registration_Date__c = System.today();
            eventMember.DeltakSRP__Contact__c = contactID;
            //eventMember.DeltakSRP__Lead__c = leadId;
            eventMember.DeltakSRP__External_Id__c = String.valueOf(System.now().getTime());
            Database.upsert(eventMember, DeltakSRP__Event_Member__c.DeltakSRP__External_Id__c);
        }
     }
     

     
     public PageReference loadIntendedMajors(){
        
        intendedMajorList.clear();
        intendedMajorList.add(new SelectOption(DEFAULT_NONE_PL,DEFAULT_NONE_PL));
        
        
            List<DeltakSRP__Academic_Program__c> academicPrograms = [Select d.Id, d.DeltakSRP__Program_Title__c, d.DeltakSRP__School__c From DeltakSRP__Academic_Program__c d where d.DeltakSRP__School__r.Name = 'Loyola University - New Orleans' and d.DeltakSRP__Active__c = true order by d.DeltakSRP__Program_Title__c Asc];
            for(DeltakSRP__Academic_Program__c ap: academicPrograms){
                intendedMajorList.add(new SelectOption(ap.Id, ap.DeltakSRP__Program_Title__c));
                accountId = ap.DeltakSRP__School__c;
            }
        
        renderEventRFIfields();
        
        return null;
     }
     
     public id insertlead(Id contactid){
        
        Id rt = [Select Id from RecordType where name = :RFI_LEAD_RT].id;
        List<Lead> leadsToInsert = new List<Lead>();
        List<String> programIds = new List<String>();       
        
        if(intendedMajor != null && intendedMajor.fieldValue != null){

            programIds.add(intendedMajor.fieldValue);
            
        }

          if(intendedMajor != null && intendedMajor.fieldValue != null){
            String programsList = intendedMajor.fieldValue;
            
        
        
                Lead l = new Lead();
//                l.Academic_Area_of_Interest_from_RFI__c = programsList;
                l.RecordTypeId = rt;
                l.FirstName = firstname.fieldValue;
                l.LastName = lastName.fieldValue;
                //accountid = '001m000000HHdqj';
                if(accountid != null)
                    l.DeltakSRP__Academic_Institution_Lookup__c = accountid; 
                
                 l.DeltakSRP__Academic_Program_Lookup__c = programsList;
               //     l.Academic_Major_from_RFI__c = programsList;
                
                
                
                if(contactid != null)
                    l.DeltakSRP__Contact__c = contactid;
                
                system.debug('Email>>>'+email.fieldValue);
                l.Email = email.fieldValue;
       
                l.Phone = phone.fieldValue;
                l.Company = RFI_LEAD_COMPANY_DEFAULT;
                l.LeadSource = EVENT_RFI_INQUIRY_SOURCE;
                
                 Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule= true;
                    l.setOptions(dmo);
                leadsToInsert.add(l);
            
        }
        Database.SaveResult[] srList = Database.insert(leadsToInsert, false);
        String leadId = null;
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
            System.debug('sr.getId()-->'+sr.getId());
            leadId = sr.getId();
        }
        else
        {
            for(Database.Error err : sr.getErrors()) {
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug(err.getStatusCode() + ': ' + err.getFields());
            }
 
        }
       }
        return leadId;
     }
     
     
}