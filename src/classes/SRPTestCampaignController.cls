public with sharing class SRPTestCampaignController {

    public String campaignName {set;}
    public String contactTextContent;
    public String leadTextContent;
    public smagicinteract__SMS_Template__c smsTemplate {set;get;}
    public List<SelectOption> contactTemplateDropDown {set;}
    public List<SelectOption> leadTemplateDropDown {set;}
    public List<SelectOption> senderIdDropDown {set;}
    public List<String> contactTemplates = new List<String>();
    public List<String> leadTemplates = new List<String>();
    public String contactTemplateName {set;get;}
    public String leadTemplateName {set;get;}
    
    public String senderId {set;get;}
   // public String textContent = '';
    public String returnURL = '';
    public String recordIds = '';
    public String objectType = '';
    public String name = ''; 
    
    
    public boolean isOptOut {set;get;}
    public String optOutField = '';
    public String sendToOptout = '';
    public String optOutFieldValue {get;set;}
    
    
    public String contactTemplateText = '';
    public String leadTemplateText = '';
    public String mobilePhoneField = '';
    public String nameField = '';
    
    public set<String> selectedStatus = new set<String>();
    public String[] statusFieldValues { get; set; } {statusFieldValues = new String[]{};}
    public List<cStatus> statusFieldDropDown {set;}
    public List<cStatus> statusList {set; get;}
    public Integer totalMembers {get;set;}
    
    
    public Integer totalContacts {get;set;}
    public Integer totalLeads {get;set;}
    
    public smagicschedule__SMS_Schedule__c  startDateObj {set;get;}
    public smagicschedule__SMS_Schedule__c  endDateObj {set;get;}
    
    public String jobName {set;get;}
    public String jobIDForMapping = '';
    public List<SelectOption> hoursList {set;}
    public List<SelectOption> minutesList {set;}
    public List<SelectOption> secondsList {set;}
    
    public String timeInHours {set;get;}
    public String timeInMinutes {set;get;}
    public String timeInSeconds {set;get;}
    
    public boolean displayPopup {get; set;} 
    public boolean displayStats {get; set;}
    public String popupMessage {get; set;}
    public boolean showCancel {get; set;}
    public boolean showSend {get; set;}
    public boolean showSchedule {get; set;}
    public boolean isContinue = false;
    public boolean isSend = false;
    public boolean showOk {get; set;}
    
    public boolean havingValues {get; set;}
    public boolean havingContactValues {get; set;}
    public boolean havingLeadValues {get; set;}
    public String filteringCondition {get; set;}
    public List<CampaignMember> campMemList {get; set;}
    public List<Contact> contactList {get; set;} 
    public List<Lead> leadList {get; set;}
    
    public List<CampaignMember> campContactList {get; set;}
    public List<CampaignMember> campLeadList {get; set;}
    public List<CampaignMember> filteredContactList {
    	get{
    		filteredContactList = new List<CampaignMember>{};
    		List<cStatus> cStatusList = getStatusFieldDropDown();
	        for(cStatus cStatusObj : cStatusList){
	            if(cStatusObj.selected == true) {
	                selectedStatus.add(cStatusObj.status);
	            }
	        }
	        
	        for(CampaignMember cMem : campContactList){
	        	if(selectedStatus.contains(cMem.Status)){
	        		filteredContactList.add(cMem);
	        	}
	        }
	        
    		return filteredContactList;
    	} 
    	set;
    }
    public List<CampaignMember> filteredLeadList {    	
    	get{
    		filteredLeadList = new List<CampaignMember>{};
    		List<cStatus> cStatusList = getStatusFieldDropDown();
    		System.debug('CH: cStatusList = ' + cStatusList);
	        for(cStatus cStatusObj : cStatusList){
	            if(cStatusObj.selected == true) {
	            	System.debug('CH: cStatusObj = ' + cStatusObj);
	                selectedStatus.add(cStatusObj.status);
	            }
	        }
	        
	        for(CampaignMember cMem : campLeadList){
	        	if(selectedStatus.contains(cMem.Status)){
	        		System.debug('CH: selectedStatus = ' + selectedStatus);
	        		filteredLeadList.add(cMem);
	        	}
	        }
	        
    		return filteredLeadList;
    	}  
    	set;
    }
        
    public SRPTestCampaignController()
    {
        this.fetchTemplateNames();
        mobilePhoneField = 'MobilePhone';
        nameField = 'Name';
        showOk = false;
        showCancel = false;
        showSend = false;
        havingValues = false;
        havingContactValues = false;
        havingLeadValues = false;
        filteringCondition = '';
        PageReference pageRef = ApexPages.currentPage();
        returnURL = pageRef.getParameters().get('retURL');
        recordIds = pageRef.getParameters().get('recordIds');
        objectType = pageRef.getParameters().get('objectType');
        sendToOptout = pageRef.getParameters().get('sendToOptout');
        
        optOutField = pageRef.getParameters().get('optOutField');
        if(optOutField == null || optOutField.length() == 0){
            optOutField = 'smagicinteract__SMSOptOut__c';
        }
        if(sendToOptout != null || sendToOptout.equalsIgnoreCase('no')){
            isOptOut = true; 
        }
        else{
            isOptOut = false;
        }
        totalContacts = 0;
        totalLeads = 0;
        
        jobName = 'My Schedule';
        startDateObj = new smagicschedule__SMS_Schedule__c();
        endDateObj = new smagicschedule__SMS_Schedule__c();                
        
        Boolean hasOptouted;
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            hasOptouted = true;
        }
        else{
            hasOptouted = false;
        }
        
        List<cStatus> cStatusList = getStatusFieldDropDown();
        for(cStatus cStatusObj : getStatusFieldDropDown()){
        	cStatusObj.selected = true;
        }
        
        for(cStatus cStatusObj :cStatusList){
            if(cStatusObj.selected == true) {
                selectedStatus.add(cStatusObj.status);
            }
        }
        
        String campContactQuery = 'select Id, ContactId, Contact.Name, Contact.MobilePhone, Status, CampaignId from CampaignMember where CampaignId =:recordIds and ContactId != null and Contact.'+mobilePhoneField+' != null';
        String campLeadQuery = 'select Id, LeadId, Lead.Name, Lead.MobilePhone, Status, CampaignId from CampaignMember where CampaignId =:recordIds and LeadId != null and Lead.IsConverted = false and Lead.'+mobilePhoneField+' != null';
        if(hasOptouted){            
             campContactQuery += ' and Contact.smagicinteract__SMSOptOut__c = false';
             campLeadQuery += ' and Lead.smagicinteract__SMSOptOut__c = false';
        }
        
        system.debug('campcontactquery>>>>'+campcontactquery);
        
        campContactList = Database.query(campContactQuery); 
        campLeadList = Database.query(campLeadQuery);
    }
    
    public Pagereference changeTemplateText(){
        return null;
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public void closeStats() {        
        displayStats = false;    
    }
    
    /* CH 4/8/2013: Don't need this method any more since we're not using the
    *   popup list of contacts and leads
    public void showStats() {
        
        boolean hasOptouted = false;
        boolean fieldNotAccessibleforContact = false;
        boolean fieldNotAccessibleforLead = false;
        set<Id> contactIdSet = new set<Id>();
        set<Id> leadIdSet = new set<Id>();
        displayStats = true;
        
        if(!SMSUtility.checkForAlphaNumeric(optOutField)) 
            return;
        if(!SMSUtility.checkFieldAccessibility('Contact',optOutField) || !SMSUtility.checkFieldAccessibility('Lead',optOutField))
            return;
        
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            hasOptouted = true;
        }
        else{
            hasOptouted = false;
        }
        
        for(String str :selectedStatus){
            if(filteringCondition.contains(str))
                continue;
            filteringCondition += ', ' + str;
        }
        if(filteringCondition.startsWith(',')){
            filteringCondition = filteringCondition.substring(1);
            filteringCondition = filteringCondition.trim();
        }
        
        String campMemberQuery = 'select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name from CampaignMember where CampaignId =:recordIds and Status = :selectedStatus';
        campMemList = Database.query(campMemberQuery);
        
        for(CampaignMember campaignMember :campMemList){
            if(campaignMember.ContactId != null){
                contactIdSet.add(campaignMember.ContactId);
            }
            if(campaignMember.LeadId != null){
                leadIdSet.add(campaignMember.LeadId);
            }                           
        }
        
        
        optOutField = String.escapeSingleQuotes(optOutField);
        String querytStringForContact = 'select Id, MobilePhone, Name, '+optOutField+' from Contact where Id in :contactIdSet and MobilePhone != null';
        String querytStringForLead = 'select Id, MobilePhone, Name, '+optOutField+' from Lead where Id in :leadIdSet and IsConverted = false and MobilePhone != null';
        
        if(hasOptouted){
            
            if(!SMSUtility.checkForAlphaNumeric(optOutField)) return;
                
            if(SMSUtility.checkFieldAccessibility('Contact',optOutField))
                querytStringForContact += ' and '+optOutField+' = false';
            else
                fieldNotAccessibleforContact = true;
                
                
            if(SMSUtility.checkFieldAccessibility('Lead',optOutField))
                querytStringForLead += ' and '+optOutField+' = false';
            else
                fieldNotAccessibleforLead = true;
        }
        
        if(!fieldNotAccessibleforContact)
            this.contactList = Database.query(querytStringForContact);
        if(!fieldNotAccessibleforLead)
            this.leadList = Database.query(querytStringForLead);
        
        if(contactList.size() > 0)
            havingContactValues = true;
        if(leadList.size() > 0)
            havingLeadValues = true;
        if(havingContactValues || havingLeadValues)
            havingValues = true;
    }
    */
    
    public String getCampaignName(){
        Campaign campaignObj = [select Id, Name from Campaign where Id =:recordIds limit 1];
        String campName = '';
        if(campaignObj != null)
            campName = campaignObj.Name;
             
        return campName;
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
        for(integer i=0; ;i++){
            j = i*5;
            if(j == 60)
                break;
            minutesDropDownList.add(new SelectOption(String.valueOf(j), String.valueOf(j)));
        }
        return minutesDropDownList;
    }
    
    public List<SelectOption> getContactTemplateDropDown()
    {
        List<SelectOption> tempList = new List<SelectOption>();
        if(contactTemplates.size() > 0)
        {
        for(String name : contactTemplates)
                tempList.add(new SelectOption(name,name));
        }
        return tempList;
    }
    
    public List<SelectOption> getLeadTemplateDropDown()
    {
        List<SelectOption> tempList = new List<SelectOption>();
        if(leadTemplates.size() > 0){
            for(String name : leadTemplates)
                tempList.add(new SelectOption(name,name));
        }
        return tempList;
    }
    
    public List<SelectOption> getSenderIdDropDown()
    {
        List<SelectOption> tempList = new List<SelectOption>();
        List<smagicinteract__SMS_SenderId__c> senderIdList = [select smagicinteract__senderId__c from smagicinteract__SMS_SenderId__c limit 100];
        if(senderIdList.size() > 0)
        {
            for(smagicinteract__SMS_SenderId__c senderIdObj : senderIdList)
                tempList.add(new SelectOption(senderIdObj.smagicinteract__senderId__c,senderIdObj.smagicinteract__senderId__c));
        }
        else
            tempList.add(new SelectOption('smsMagic','smsMagic'));
        return tempList;
    }
    
    public List<cStatus> getStatusFieldDropDown()
    {
        List<String> tempList = new List<String>();
        if(statusList == null) {
        
            statusList = new List<cStatus>();
            
            Schema.DescribeFieldResult resultSet = CampaignMember.Status.getDescribe();
            List<Schema.PicklistEntry> pickList =  resultSet.getPicklistValues();
            
            for(PicklistEntry statusObj : pickList){
                tempList.add(String.valueOf(statusObj.getValue()));
            }
            if(tempList.size() > 0)
            {
                for(String name : tempList){
                    statusList.add(new cStatus(name));
                }
            }
        }
        return statusList;
    }
    
    public void fetchTemplateNames()
    {
        List<smagicinteract__SMS_Template__c> objList  =  null;
        objList = [select Id, smagicinteract__Name__c, smagicinteract__Text__c, smagicinteract__ObjectName__c from smagicinteract__SMS_Template__c where smagicinteract__ObjectName__c = 'Contact'];
        for(smagicinteract__SMS_Template__c smsTemp : objList){
            contactTemplates.add(String.valueOf(smsTemp.smagicinteract__Name__c));  
        }
        contactTemplates.sort();
        objList= [select Id, smagicinteract__Name__c, smagicinteract__Text__c, smagicinteract__ObjectName__c from smagicinteract__SMS_Template__c where smagicinteract__ObjectName__c = 'Lead'];
        for(smagicinteract__SMS_Template__c smsTemp : objList){
            leadTemplates.add(String.valueOf(smsTemp.smagicinteract__Name__c)); 
        }
        leadTemplates.sort();   
    }
    
    public void setContactTextContent(String txt){
        this.contactTextContent = txt;
    }
    
    public String getContactTextContent()
    {
        List<smagicinteract__SMS_Template__c> obj = null;
        //String textContent = '';
                
        if(contactTemplateName != null && !String.isBlank(contactTemplateName) ){
            obj = [select smagicinteract__Text__c from smagicinteract__SMS_Template__c where smagicinteract__Name__c = :contactTemplateName];
             this.contactTextContent = String.valueOf(obj[0].smagicinteract__Text__c);
        }
        //else 
         //  textContent = ''; 
            
        return  this.contactTextContent; 
    }
    
    public void setLeadTextContent(String txt){
        this.leadTextContent  = txt;
    }
    
    public String getLeadTextContent()
    {
        List<smagicinteract__SMS_Template__c> obj = null;
            
        if(leadTemplateName != null &&  !String.isBlank(leadTemplateName)) {
            obj = [select smagicinteract__Text__c from smagicinteract__SMS_Template__c where smagicinteract__Name__c = :leadTemplateName];
            this.leadTextContent = String.valueOf(obj[0].smagicinteract__Text__c);
        }
       // else
       //     textContent = '';
        return this.leadTextContent ;
    }
    
    public PageReference getStatusSelections(){
    	selectedStatus.clear();
        List<cStatus> cStatusList = getStatusFieldDropDown();
        for(cStatus cStatusObj : cStatusList){
            if(cStatusObj.selected == true) {
                selectedStatus.add(cStatusObj.status);
            }
        }
        
        return null;
    }
    
    /* CH 4/8/2013: Various sections deactivated because
     *   they're no longer necessary 
    public PageReference getTotalCount(){
        
        Integer leadCounter = 0;
        Integer contactCounter = 0;
        boolean hasOptouted = false;
        String campContactQuery = '';
        String campLeadQuery = '';
        
        List<CampaignMember> campContactList = new List<CampaignMember>();
        List<CampaignMember> campLeadList = new List<CampaignMember>();
        
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            hasOptouted = true;
        }
        else{
            hasOptouted = false;
        }
        
        Map<String, Integer> statusContactCountMap = new Map<String, Integer>();
        Map<String, Integer> statusLeadCountMap = new Map<String, Integer>();

        for(String statusStr : selectedStatus){
                
            campContactQuery = 'select Id, ContactId, Status, CampaignId from CampaignMember where CampaignId =:recordIds and Status = :statusStr and ContactId != null and Contact.'+mobilePhoneField+' != null';
            campLeadQuery = 'select Id, LeadId, Status, CampaignId from CampaignMember where CampaignId =:recordIds and Status = :statusStr and LeadId != null and Lead.IsConverted = false and Lead.'+mobilePhoneField+' != null';
            if(hasOptouted){            
                 campContactQuery += ' and Contact.smagicinteract__SMSOptOut__c = false';
                 campLeadQuery += ' and Lead.smagicinteract__SMSOptOut__c = false';
            }
            
            campContactList = Database.query(campContactQuery); 
            campLeadList = Database.query(campLeadQuery);
            statusContactCountMap.put(statusStr, campContactList.size());
            statusLeadCountMap.put(statusStr, campLeadList.size());
        }

        for(String statusStr :selectedStatus){
            
            Integer contactCount = 0; 
            Integer leadCount = 0;
            
            contactCount = statusContactCountMap.get(statusStr);
            leadCount = statusLeadCountMap.get(statusStr);
            
            leadCounter += leadCount;
            contactCounter += contactCount;
             
            for(cStatus cStatusObj :cStatusList){
                if(statusStr.equalsIgnoreCase(cStatusObj.status)){  
                    CampaignSMSSendController.cStatus innerClassInstance = new CampaignSMSSendController.cStatus();
                    innerClassInstance.setCount(cStatusObj, contactCount, leadCount);
                    break;
                }
            }
        }
        
        this.totalContacts = contactCounter;
        this.totalLeads = leadCounter;
        return null;
    }
    */
    
    public PageReference sendSMS() {        
        /*
        if(!isContinue){
            if(DeltakSRP__DeltakSRPSMS__SMSUtility.validateEmptyString(contactTextContent) && DeltakSRP__DeltakSRPSMS__SMSUtility.validateEmptyString(leadTextContent)){
                popupMessage = '';//Label.SMS_Popup_Message_7;
                showPopup();
                return null;
            }
            if(SMSUtility.validateEmptyString(contactTextContent)){
                popupMessage = /*Label.SMS_Status_Message_8;'';
                showCancel = true;
                showSchedule = false;
                showSend = true;
                showOk = true;
                showPopup();
                return null;
            }
            if(SMSUtility.validateEmptyString(leadTextContent)){
                popupMessage = '';//Label.SMS_Popup_Message_9;
                showCancel = true;
                showSchedule = false;
                showSend = true;
                showOk = true;
                showPopup();
                return null;
            }
        }
        
        
        //this.getTotalCount();
        //this.totalMembers = this.totalContacts + this.totalLeads; 
        
        if (filteredContactList.size() < 1 && filteredLeadList.size() < 1){
            popupMessage = Label.SMS_Popup_Message_10;
            showPopup();
            return null;
        }
        
        List<cStatus> cStatusList = getStatusFieldDropDown();
        for(cStatus cStatusObj :cStatusList){
            if(cStatusObj.selected == true) {
                selectedStatus.add(cStatusObj.status);
            }
        }
        
        if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
            isOptOut = true;
        }
        else{
            isOptOut = false;
        }
        
        if(selectedStatus.size() > 0)
        {
            boolean optoutSend = false;
            Id scheduleJobId = null;
            //DeltakSRPSMS__CampaignSMSBatch campaignBatch = new DeltakSRPSMS__CampaignSMSBatch(senderId, selectedStatus, objectType, contactTextContent, leadTextContent ,recordIds, isOptOut, optOutField, optoutSend, scheduleJobId);
            //Database.executeBatch(campaignBatch, 50);   
        } */
        String url = '/'+recordIds;
        //SMSUtility.verifyUrl(url);
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel()
    { 
        String url = '/'+recordIds;
        
      //  SMSUtility.verifyUrl(url);*/
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancelSMSScheduling(){
        closePopup();
        String url = '/'+recordIds;
        
        //SMSUtility.verifyUrl(url);
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
   	/* CH 4/8/2013: Various sections deactivated because
     *   they're no longer necessary 
    public PageReference continueSMSScheduling(){
        closePopup();
        showCancel = false;
        showSchedule = false;
        showSend = false;
        showOk = false;
        isContinue = true;
        PageReference pageRef = this.schedule();
        if(pageRef != null){
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    */
    
    public PageReference continueSMSSending(){
        closePopup();
        showCancel = false;
        showSchedule = false;
        showSend = false;
        showOk = false;
        isContinue = true;
        PageReference pageRef = this.sendSMS();
        if(pageRef != null){
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    /* CH 4/8/2013: Various sections deactivated because
     *   they're no longer necessary 
    public PageReference schedule(){
        
        String url = '/'+recordIds;
        if(!isContinue){
            if(SMSUtility.validateEmptyString(contactTextContent) && SMSUtility.validateEmptyString(leadTextContent)){
                popupMessage = 'SMS text Missing. Please enter SMS text for Scheduling';
                showPopup();
                return null;
            }
            if(SMSUtility.validateEmptyString(contactTextContent)){
                popupMessage = 'SMS text Missing for Contact. Schedule message anyway ?';
                showCancel = true;
                showSchedule = true;
                showSend = false;
                showOk = true;
                showPopup();
                return null;
            }
            if(SMSUtility.validateEmptyString(leadTextContent)){
                popupMessage = 'SMS text Missing for Lead. Schedule message anyway ?';
                showCancel = true;
                showSchedule = true;
                showSend = false;
                showOk = true;
                showPopup();
                return null;
            }
        }
        
        this.getTotalCount();
        this.totalMembers = this.totalContacts + this.totalLeads; 
        
        if (totalMembers <= 0){
            popupMessage = 'No records selected for sending. Please use the "Member status" field to select campaign members.';
            showPopup();
            return null;
        }
        
        if(SMSUtility.validateEmptyString(jobName)){
            popupMessage = 'Please enter the Scheduler Name';
            showPopup();
            return null;
        }
        
        if(SMSUtility.checkNullField(startDateObj, 'smagicschedule__Date__c')){
            popupMessage = 'Please enter the date & time for Schedule.';
            showPopup();
            return null;
        }
        
        
        Date startDate = startDateObj.smagicschedule__Date__c;
        Date endDate = startDate;
        
        if(!SMSUtility.validateScheduleHour(startDate, timeInHours)){
            popupMessage = 'The date & time entered has already passed. Please enter new date & time';
            showPopup();
            return null;
        }
        else if(!SMSUtility.validateScheduleMinutes(startDate, timeInHours, timeInMinutes)){
            popupMessage = 'The date & time entered has already passed. Please enter new date & time';
            showPopup();
            return null;
        }
        
        String condition = '';
        for(String c :selectedStatus){
            condition += ', '+c;
        }       
        condition = condition.substring(1);
        Id scheduleJobId = smagicschedule.ApexAPI.scheduleSMSFromCampaign(jobName, leadTextContent, contactTextContent, startDate, endDate, timeInHours, timeInMinutes, recordIds, objectType, optOutField, nameField, mobilePhoneField, senderId, sendToOptout, condition);
        
        // create record in sms history with status schedule.
        if(scheduleJobId != null){
            boolean optoutSend = true;
            if(sendToOptout != null && sendToOptout.equalsIgnoreCase('no')){
                isOptOut = true;
            }
            else{
                isOptOut = false;
            }
        
            CampaignSMSBatch campaignBatch = new CampaignSMSBatch(senderId, selectedStatus, objectType, contactTextContent,leadTextContent ,recordIds, isOptOut, optOutField, optoutSend, scheduleJobId);
            Database.executeBatch(campaignBatch, 50);
        }
        
        SMSUtility.verifyUrl(url);
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    */
    
    public class cStatus {
        
        public String status {get; set;}
        public boolean selected {get; set;}
        public Integer totalContact {get; set;}
        public Integer totalLead {get; set;}
        
        public cStatus(){
            
        }
        
        public cStatus(String statusStr){
            
            status = statusStr;
            selected = false;
            totalContact = 0;
            totalLead = 0;
        }
        
        public void setCount(cStatus cStatusObject, Integer contactCount, Integer leadCount){
            
            if(cStatusObject.selected){
                cStatusObject.totalContact = contactCount;
                cStatusObject.totalLead = leadCount;
            }
        }
    }
}