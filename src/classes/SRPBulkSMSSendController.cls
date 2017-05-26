public with sharing class SRPBulkSMSSendController {
	public LIST<Map<String,String>> smsObjectList = new List<Map<String,String>>();
    public LIST<sObject> smsObjects = new List<sObject>();
    public List<string> recordIdList = new List<string>();
    public string objectType;
    public String senderId{get;set;}
    public string returnURL;
    public String smsText {get;set;}
    public String template {get;set;}
    public integer numberOfSentSMS{get;set;}
    public static integer noMobile = 0;
    public integer selectedContacts = 0;
    public String mobilePhoneField {get;set;}
    public String parentObject {get;set;}
    public String parentObjectReferenceField {get;set;}
    public String inboundNumberField {get;set;}
    public String nameField {get;set;}
    public String sendToOptout {get;set;}
    public boolean isOptOut {get;set;}
    public String optOutField = '';
    public String optOutFieldValue {get;set;}
    public String packagePrefix {get;set;}
    public smagicschedule__SMS_Schedule__c  startDateObj {set;get;}
    public smagicschedule__SMS_Schedule__c  endDateObj {set;get;}
    
    public String jobName {set;get;}
    public String jobIDForMapping = '';
    public List<SelectOption> hoursList {set;}
    public List<SelectOption> minutesList {set;}
    
    public String timeInHours {set;get;}
    public String timeInMinutes {set;get;}
    public String timeInSeconds {set;get;}
    public String recordIds = '';
    public Map<String, String> fieldNameValueMap = new Map<String, String>();
    
    public sObject tplObject;
    Schema.SObjectType sObjType; 
    Transient Schema.DescribeSObjectResult describeResult;
    public Map<string, Schema.Sobjectfield> tplObjectFieldMap;
    public String tempNameField = ''; 
    public String tempTextFieldName = '';
    public String tempObjectTypeFieldName = '';
    public String tplTxt = '';
    public String templateObjName = '';
    public List<String> fieldList = new List<String>();
    public boolean disableMe {set; get;}
    
    public Id userId {get;set;}
    public boolean showUserDropDown {get;set;}
    public String showDropDownVal = '';
    public boolean disabledDropDown {get;set;}
    public boolean displayPopup {get; set;} 
    public boolean showCancel {get; set;}
    public String popupMessage {get; set;}
    public String smsStats {get; set;}
    public integer totalRecords = 0;
    
    public static boolean isApexTest = false;

    public SRPBulkSMSSendController(){
        
        showUserDropDown = false;
        disabledDropDown = false;
        numberOfSentSMS = 0;
        PageReference pageRef = ApexPages.currentPage();
        returnURL = pageRef.getParameters().get('retURL');
        recordIds = pageRef.getParameters().get('recordIds');
        recordIdList = recordIds.split(',');
        objectType = pageRef.getParameters().get('objectType');
        mobilePhoneField = pageRef.getParameters().get('phoneField');
        nameField  = pageRef.getParameters().get('nameField');
        optOutField = pageRef.getParameters().get('optOutField');
        showDropDownVal = pageRef.getParameters().get('showUserDropDown');
        sendToOptout = pageRef.getParameters().get('sendToOptout');
        parentObject = pageRef.getParameters().get('parentObject');
        inboundNumberField = pageRef.getParameters().get('inboundNumberField');
        parentObjectReferenceField = pageRef.getParameters().get('parentObjectReferenceField');
        try{
            if(showDropDownVal != null && showDropDownVal.length() > 0)
                showUserDropDown = Boolean.valueOf(showDropDownVal);
        }catch(Exception e){
            showUserDropDown = false;   
        }
        
        smsText = '';
        disableMe =  false;
        
        if(parentObject == null || parentObject.trim().length() == 0){
            parentObject = 'Account'; 
        }
        if(inboundNumberField == null || inboundNumberField.trim().length() == 0){
            inboundNumberField = 'Phone'; 
        }
        if(parentObjectReferenceField == null || parentObjectReferenceField.trim().length() == 0){
            parentObjectReferenceField = 'AccountId'; 
        }
        if(optOutField == null || optOutField.trim().length() == 0){
            optOutField = 'smagicinteract__SMSOptOut__c'; 
        }        
        if(mobilePhoneField == null || mobilePhoneField.trim().length() == 0){
            mobilePhoneField = 'MobilePhone';
        }
        if(nameField == null || nameField.trim().length() == 0){
            nameField  = 'Name';
        }
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            isOptOut = true; 
        }
        else{
            isOptOut = false;
        }
        
        jobName = 'My Schedule';
        
        startDateObj = new smagicschedule__SMS_Schedule__c();
        //endDateObj = new SMS_Schedule__c();
        
        smsObjects = SRPSMSUtility.loadSMSObjects(recordIdList, objectType, nameField, mobilePhoneField, isOptOut, optOutField);
        selectedContacts = smsObjects.size();
        noMobile = 0;
        getTotalCount();
        if(selectedContacts > 0)
            this.createMapOfRecords(smsObjects);
        string message = '';
        
        if (selectedContacts > 0 && noMobile > 0){
          popupMessage = noMobile + ' ' + objectType + '\'s ' +'doesn\'t have mobile number';
          if(noMobile == 1)
            popupMessage = noMobile + ' ' + objectType + ' '+ 'doesn\'t have mobile number';
          showPopup();
        }
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public PageReference getTotalCount(){
        
        List<String> args = new List<String>{};
        boolean isOptOuted = false;
        
        if(!SRPSMSUtility.checkForAlphaNumeric(objectType) || !SRPSMSUtility.checkForAlphaNumeric(optOutField) || !SRPSMSUtility.checkForAlphaNumeric(mobilePhoneField)) 
            return null;
        if(!SRPSMSUtility.checkObjectAccessibility(objectType))
            return null;
        if(!SRPSMSUtility.checkFieldAccessibility(objectType,optOutField) || !SRPSMSUtility.checkFieldAccessibility(objectType,mobilePhoneField))
            return null;
            
        args.add(String.escapeSingleQuotes(optOutField));
        args.add(String.escapeSingleQuotes(objectType));
        args.add(String.escapeSingleQuotes(mobilePhoneField));
        String query = 'select id, {0} from {1} where id in :recordIdList and {2} != null';
        query = String.format(query, args);
        List<sObject> sObjectList = Database.query(query);
        integer optOutCount = 0;
        for(sObject sObj :sObjectList){
            if(Boolean.valueOf(sObj.get(optOutField)))
                optOutCount++;
        }
        this.totalRecords = sObjectList.size();
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            this.totalRecords = sObjectList.size() - optOutCount;
        }
        String smsStatMsg = 'SMS will be sent to the'+ ' ' +this.totalRecords+' '+objectType;
        if(this.totalRecords > 1)
            smsStatMsg += 's.';
        this.smsStats = smsStatMsg;
        return null;
    }
    
    public void createMapOfRecords(List<sObject> sObjectList){
        
        Schema.SObjectType s; 
        Schema.DescribeSObjectResult r;
        s = sObjectList[0].getSObjectType();
        r = s.getDescribe() ; 
        String nameField = '';
        String mobileField = '';
        Map<string, Schema.Sobjectfield> objectFieldMap = SRPSMSUtility.getObjectFieldMap(r.getName());
        Map<String, String> fieldNameVal = new Map<String, String>();
        for(String fName :objectFieldMap.keySet()){
            
            if(fName.contains('name__c')){
                nameField = fName;
                continue;
            }
            if(fName.contains('phonenumber__c')){
                mobileField = fName;
                continue;
            }
        }
       
        for(sObject sObj :sObjectList){
                Schema.Sobjectfield sObjField = null;
                fieldNameValueMap = new Map<String, String>();
                
                fieldNameValueMap.put('Name',String.valueOf(sObj.get(nameField)));
                fieldNameValueMap.put('Phone', String.valueOf(sObj.get(mobileField)));
                fieldNameValueMap.put('ObjectType', objectType);
                smsObjectList.add(fieldNameValueMap);
        }               
    }
    
    public List<SelectOption> getSenderList(){
        
        List<SelectOption> options = new List<SelectOption>();
        String loggedInUserName = Userinfo.getName();
        Id loggedInUserId = Userinfo.getUserId();
        List<User> userList = [select Id, Name from User where Id != :loggedInUserId and IsActive = true];
        options.add(new SelectOption(loggedInUserId,loggedInUserName));
        if(userList.size() > 0){
            for(User user :userList){
                options.add(new SelectOption(user.Id,user.Name));
            }
        }
        return options;
    }
    
    public String getDefaultSenderId(){
        
        String senderIdVar = ''; 
        
        if(objectType != null && objectType.equalsIgnoreCase('Contact') && recordIdList.size() == 1){
            List<sObject> conList = null;
            List<Id> ids = new List<Id>(); 
            
            if(!SRPSMSUtility.checkForAlphaNumeric(objectType) || !SRPSMSUtility.checkForAlphaNumeric(parentObjectReferenceField) || !SRPSMSUtility.checkForAlphaNumeric(parentObject) || !SRPSMSUtility.checkForAlphaNumeric(inboundNumberField)) 
                return senderIdVar;
            if(!SRPSMSUtility.checkObjectAccessibility(objectType) || !SRPSMSUtility.checkObjectAccessibility(parentObject))
                return senderIdVar;
            if(!SRPSMSUtility.checkFieldAccessibility(objectType,parentObjectReferenceField) || !SRPSMSUtility.checkFieldAccessibility(parentObject,inboundNumberField))
                return senderIdVar;

            String contactQuery = 'select Id, Name, '+parentObjectReferenceField+' from Contact where Id in :recordIdList' ;
            conList = Database.query(contactQuery);
            if(conList != null && conList.size() > 0){
                for(sObject con :conList){
                    Object obj = con.get(parentObjectReferenceField);
                    if(obj == null) continue;
                    Id recordId = Id.valueOf(String.valueOf(obj));
                    if(recordId != null)
                        ids.add(recordId);
                }
            }
            if(ids != null && ids.size() > 0){
                String queryStr = 'select Id, '+inboundNumberField+' from '+parentObject+' where Id in :ids';
                List<sObject> paraentObjectList = Database.query(queryStr);
                if(paraentObjectList != null && paraentObjectList.size() > 0){
                    senderIdVar = String.valueOf(paraentObjectList[0].get(inboundNumberField));
                }
            }
        }
        return senderIdVar;
    }
    
    public List<SelectOption> getSenderIds(){
        
        List<SelectOption> options = new List<SelectOption>();
        List<String> senderIdsSortedList = new List<String>();
        
        // Fetch the sender ID from database
        String senderId = this.getDefaultSenderId();
        if(senderId != null && senderId.trim().length() > 0){
            options.add(new SelectOption(senderId, senderId));
            disabledDropDown = true;
            return options; 
        }

        List<smagicinteract__SMS_SenderId__c> senderIdList = [select Id, smagicinteract__senderid__c from smagicinteract__SMS_SenderId__c limit 3];
        if(senderIdList.size() > 0 ){
            for(smagicinteract__SMS_SenderId__c senderIdObj :senderIdList){
                senderIdsSortedList.add(senderIdObj.smagicinteract__senderid__c);
            }
            senderIdsSortedList.sort();
            for(String senderIdVal :senderIdsSortedList){
                options.add(new SelectOption(senderIdVal, senderIdVal));
            }
        }
        
        if(options.size() == 0){
            options.add(new SelectOption('smsMagic', 'smsMagic'));
        }
        return options;
    }
    
    public LIST<Map<String,String>> getSmsObjectList(){
        if (smsObjectList.size() <= 0){
            popupMessage = 'One or more of the selected records will not be a sent a text message for one of the following reasons: A mobile number has not been specified or opt out has been selected for the record. Please review the details of the selected records and try again.';
            showCancel = true;
            showPopup();
            return null;
        }
        return smsObjectList;
    }
    
    public PageReference send(){
        SObject a  = null;
        
        if(SRPSMSUtility.validateEmptyString(smsText)){
            popupMessage = 'SMS text Missing. Please enter SMS text for sending';
            showPopup();
            return null;
        }
        try{
            
            if(!isApexTest){
                boolean optoutSend = false;
                Id scheduleJobId = null;
                numberOfSentSMS = SRPSMSUtility.sendBulk(recordIdList, objectType, nameField, mobilePhoneField, smsText, senderId, isOptOut, optOutField, optoutSend, scheduleJobId);
            }else{
                numberOfSentSMS = 1;
            }
            
        } catch(Exception e){
            if (ApexPages.currentPage() != null ){
                string eMsg = e.getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, eMsg));
            }
            return null;
        }
        Boolean done = false;
        if(recordIdList.size() > 0){ 
            if(returnURL == null || returnURL.equals('')){
                returnURL = '/apex/smagicinteract__SMHome?messageId=2&numberOfSentSMS='+numberOfSentSMS;
            }
            SRPSMSUtility.verifyUrl(returnURL);
            PageReference pageRef = new PageReference(returnURL);
            return pageRef;
        }
        return null;
    }
    
    public PageReference cancelSMS()
    {
        PageReference pageRef = this.cancel();
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel(){
        Boolean done = false;
        
        if(returnURL == null || returnURL.equals('')){
            returnURL = recordIdList[0];
        }
        else{
            do{
                if(returnURL.startsWith('/')){
                    returnURL = returnURL.substring(1);
                }
                else{
                    done = true;
                }
            }while(done = false);
        }
        SRPSMSUtility.verifyUrl(returnURL);
        PageReference pageRef = new PageReference('/'+returnURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference schedule(){
        
        if(SRPSMSUtility.validateEmptyString(jobName)){
            popupMessage = 'Please enter the Scheduler Name';
            showPopup();
            return null;
        }
        
        if(SRPSMSUtility.validateEmptyString(smsText)){
            popupMessage = 'SMS text Missing. Please enter SMS text for Scheduling';
            showPopup();
            return null;
        }
        if(SRPSMSUtility.checkNullField(startDateObj, 'smagicschedule__Date__c')){
            popupMessage = 'Please enter the date & time for Schedule';
            showPopup();
            return null;
        }
        Date startDate = startDateObj.smagicschedule__Date__c;
        Date endDate = startDate;
        
        if(!SRPSMSUtility.validateScheduleHour(startDate, timeInHours)){
            popupMessage = 'The date & time entered has already passed. Please enter new date & time';
            showPopup();
            return null;
        }
        else if(!SRPSMSUtility.validateScheduleMinutes(startDate, timeInHours, timeInMinutes)){
            popupMessage = 'The date & time entered has already passed. Please enter new date & time';
            showPopup();
            return null;
        }
        
        String condition = '';
        boolean optoutSend = true;
        Id scheduleJobId = smagicschedule.ApexAPI.scheduleSMS(jobName, smsText, startDate, endDate, timeInHours, timeInMinutes, recordIds, objectType, optOutField, nameField, mobilePhoneField, senderId, sendToOptout, condition);
        
        // create record in sms history with status schedule.
        if(scheduleJobId != null)
            SRPSMSUtility.sendBulk(recordIdList, objectType, nameField, mobilePhoneField, smsText, senderId, isOptOut, optOutField, optoutSend, scheduleJobId);
        
        Boolean done = false;
        if(returnURL == null || returnURL.equals('')){
            returnURL = recordIdList[0];
        }
        else{
            do{
                if(returnURL.startsWith('/')){
                    returnURL = returnURL.substring(1);
                }
                else{
                    done = true;
                }
            }while(done = false);
        }
        SRPSMSUtility.verifyUrl(returnURL);
        PageReference pageRef = new PageReference('/'+returnURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        String extraField = '';
        Map<String, Id> templateNameAndIdMap = new Map<String, Id>();
        List<String> templateNameList = new List<String>();
          
        options.add(new SelectOption('None','I dont need template'));
        
        // Create Template List
        if(templateObjName != null && tempNameField != null){
            List<smagicinteract__SMS_Template__c> tplList = [select Id, smagicinteract__name__c, smagicinteract__objectname__c, smagicinteract__text__c from smagicinteract__SMS_Template__c where smagicinteract__objectname__c =:objectType];
            if(tplList.size() > 0){
                for(smagicinteract__SMS_Template__c sObj :tplList){
                    templateNameAndIdMap.put(sObj.smagicinteract__name__c, sObj.Id);
                    templateNameList.add(sObj.smagicinteract__name__c);
                }
                templateNameList.sort();
                
                for(String tName :templateNameList){
                    options.add(new SelectOption(templateNameAndIdMap.get(tName),tName));
                }
            }
        }
        options.add(new SelectOption('NewTp','Create New Template'));
        return options;
    }
    
    public PageReference changeTemplateText(){
        String extraField = '';
        smsText = '';
        if(template == 'NewTp'){
            returnURL = '/apex/smagicinteract__NewSMSTemplate?retURL=/apex/smagicinteract__SMHome';
            SRPSMSUtility.verifyUrl(returnURL);
            PageReference pageRef = new PageReference(returnURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            
            // Fetch the Template text
            if(template != null){
                List<smagicinteract__SMS_Template__c> sObjects = [select Id, smagicinteract__name__c, smagicinteract__objectname__c, smagicinteract__text__c from smagicinteract__SMS_Template__c where id =:template];
                if(sObjects.size() > 0){
                    smsText = sObjects[0].smagicinteract__text__c;
                }
            }
        }
        return null;
    }
    
    public List<SelectOption> getHoursList(){
        
        List<SelectOption> hoursDropDownList = new List<SelectOption>();
        
        for(integer i=0; i<24;i++){
            
            hoursDropDownList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return hoursDropDownList;
    }
    
    public List<SelectOption> getMinutesList(){
        
        List<SelectOption> minutesDropDownList = new List<SelectOption>();
        integer j = 0;
        for(integer i=0;  ;i++){
            j = i*5;
            if(j == 60)
                break;
            minutesDropDownList.add(new SelectOption(String.valueOf(j), String.valueOf(j)));
        }
        return minutesDropDownList;
    }
}