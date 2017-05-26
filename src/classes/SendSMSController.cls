public class SendSMSController {

    public String schedule { get; set; }

    public String startTime { get; set; }

    public String endDate { get; set; }

    public String startDate { get; set; }

    Boolean errPhoneNumber = false;
    Boolean errMessageText = false;

    public String delivery { get; set; }
    public String saveHF { get; set; }
    public String selectedPhoneNumber { get; set; }
    public String selectedTimeZone { get; set; }
    public String messageText { get; set; }
    public List<SelectOption> templateList { get; set; }
    public String smsSendDisabled { get; set; }
    public String footerText { get; set; }
    public String headerText { get; set; }
    public boolean dayLightSaving { get; set; }
    public string entityJson { get; set; }
    public string isMultiPart { get; set; }
    
    public String templateText { get; set; }
    public String prefilledCount { get; set; }
    
    public string entityId { get; set; }
    public string entityType { get; set; }
    public boolean isDeliveryTrackOption { get; set; }

    public void initPage() {
        Id opId = System.currentPageReference().getParameters().get('oid');
        string src = System.currentPageReference().getParameters().get('src');
        string okToText;

        this.entityId = opId;
        this.entityType = src;
        templateList = new List<SelectOption>();        
        List<MMSMSTemplate__c> templates = MMSMSTemplates.getAvailableTemplates();
        for(MMSMSTemplate__C tmp : templates){
            templateList.add(new SelectOption(tmp.Id, tmp.TemplateName__c));
        }
        this.entityJson = '[]';
        
        if(src == 'op'){
            okToText = [select Ok_To_Text__c from opportunity where Id = :opId].Ok_To_Text__c;
        } else {
            okToText = [select Ok_To_Text__c from contact where Id = :opId].Ok_To_Text__c;
        }
        
        if(okToText == 'No'){
            smsSendDisabled = 'true';    
            MMUtils.addMessage(Apexpages.Severity.WARNING, 'SMS sending not allowed because the user has disabled receiving SMS');
            return;
        }
        
        smsSendDisabled = 'false';
        
        setDeliveryTrackOption();
    }
    
    public void setDeliveryTrackOption() {
        if (!MMSMSUIPermission.isDirectorAdmissions(null) && !MMSMSUIPermission.isDirectorAdmissionsPTemplate(null) && !MMSMSUIPermission.isSystemAdministrator(null)) {
            this.isDeliveryTrackOption = true;
        }
        else {
            this.isDeliveryTrackOption = false;
        }
    }
    
    public PageReference cancel() {
       Id opId = System.currentPageReference().getParameters().get('oid');
       PageReference pr = new PageReference('/' + opId);
       pr = pr.setRedirect(true);       
       return pr;
    }

    public Boolean getErrMessageText() {
        return errMessageText;
    }

    public Boolean getErrPhoneNumber(){
        return errPhoneNumber;
    }
    
    public String getClassPhoneNumber(){    
        return (errPhoneNumber)? 'error' : '';
    }
    
    public String getClassMessageText(){
        return (errMessageText)? 'error' : '';
    }

    public List<SelectOption> getTimeZone() {
        string[] arrTimeZone = MMUtilTimeZone.timeZone;
        List<SelectOption> tzList = new List<SelectOption>();
        tzList.add(new SelectOption('0_a',''));
        
        for(integer x=0;x<arrTimeZone.size();x+=2) {
            tzList.add(new SelectOption(arrTimeZone[x],arrTimeZone[x+1]));
        }
        
        return tzList;
    }
    
    public void getTemplateContent(){
        String templateId = ApexPages.CurrentPage().getParameters().get('templateId');              
        String message = ApexPages.CurrentPage().getParameters().get('messageText');
        templateText = MMSMSTemplates.getTemplateContent(templateId).replaceAll('\n', '###');
        prefilledCount = String.valueOf(getPrefilledCount(message + templateText));
    }
    
    public Integer getPrefilledCount(String message){
        String[] extractedFields = new List<String>();
        String query = MMSMSTemplates.getTemplateQuery(message, extractedFields, new string[] { this.entityId }, this.entityType);
        SObject[] tObjects = null;
        string txt = '';
        if(query != null){
            try{
                tObjects = Database.Query(query);
            }
            catch(Exception e){
                tObjects = null;
            }
        }
        txt = MMSMSTemplates.getTemplateMessage(String.valueOf(this.entityId), MMUtils.filterNull(message), tObjects, extractedFields, this.entityType);
        if (txt != null) {
            setEntityFieldValuePairs(this.entityType, this.entityId, MMUtils.filterNull(message));
            return txt.length();
        }
        else {
            this.entityJson = '[]';
            return 0;
        }
    }
    
    public void setEntityFieldValuePairs(string entityType, string entityId, string message) {
        List<SelectOption> pairs = MMSMSTemplates.getFieldValuePairs(entityType, entityId, message);
        this.entityJson = '[';
        for(SelectOption option : pairs) {
            if (this.entityJson.length() > 1) this.entityJson += ',';
            this.entityJson += '{"name":"' + option.getLabel() + '","value":"' + option.getValue() + '"}';
        }
        this.entityJson += ']';
    }
    public List<SelectOption> getPhoneNumbers(){
        SMSHeaderFooter__c hf = MMUtils.getHeaderFooter('single', UserInfo.getUserId());    
        if (hf != null) {
            headerText = MMUtils.stringEmptyNull(hf.Header__c) ? '' : hf.Header__c.replace('_-_','\n');
            footerText = MMUtils.stringEmptyNull(hf.Footer__c) ? '' : hf.Footer__c;//.replace('_-_','\n');
            selectedTimeZone = hf.Time_Zone__c;
        }

        Id opId = System.currentPageReference().getParameters().get('oid');
        String src = System.currentPageReference().getParameters().get('src');
        List<SelectOption> pNums = new List<SelectOption>();

        if(src == 'op'){
            Opportunity op = [select  Mobile_Phone__c, Preferred_Phone__c, Home_Phone__c, Work_Phone__c from opportunity where Id=:opId];
            
            if (MMUtils.stringEmptyNull(selectedPhoneNumber)) {
                if (op.Preferred_Phone__c == 'Mobile') selectedPhoneNumber = op.Mobile_Phone__c;
                else if (op.Preferred_Phone__c == 'Home') selectedPhoneNumber = op.Home_Phone__c;
                else if (op.Preferred_Phone__c == 'Work') selectedPhoneNumber = op.Work_Phone__c;
            }
                       
            if(op.Mobile_Phone__c != null) pNums.add(new SelectOption(op.Mobile_Phone__c, op.Mobile_Phone__c + ' - Mobile ' + ((op.Preferred_Phone__c == 'Mobile')? '(Preferred)' : '')));
            if(op.Home_Phone__c != null) pNums.add(new SelectOption(op.Home_Phone__c, op.Home_Phone__c + ' - Home ' + ((op.Preferred_Phone__c == 'Home')? '(Preferred)' : '')));
            if(op.Work_Phone__c != null) pNums.add(new SelectOption(op.Work_Phone__c, op.Work_Phone__c + ' - Work ' + ((op.Preferred_Phone__c == 'Work')? '(Preferred)' : '')));
        } else {
            Contact c = [select MobilePhone, Preferred_Phone__c, HomePhone, Work_Phone__c from contact where Id=:opId];
            if (MMUtils.stringEmptyNull(selectedPhoneNumber)) {
                if (c.Preferred_Phone__c == 'Mobile') selectedPhoneNumber = c.MobilePhone;
                else if (c.Preferred_Phone__c == 'Home') selectedPhoneNumber = c.HomePhone;
                else if (c.Preferred_Phone__c == 'Work') selectedPhoneNumber = c.Work_Phone__c;
            }
                   
            if(c.MobilePhone != null) pNums.add(new SelectOption(c.MobilePhone, c.MobilePhone + ' - Mobile ' + ((c.Preferred_Phone__c == 'Mobile')? '(Preferred)' : '')));
            if(c.HomePhone != null) pNums.add(new SelectOption(c.HomePhone, c.HomePhone + ' - Home ' + ((c.Preferred_Phone__c == 'Home')? '(Preferred)' : '')));
            if(c.Work_Phone__c != null) pNums.add(new SelectOption(c.Work_Phone__c, c.Work_Phone__c + ' - Work ' + ((c.Preferred_Phone__c == 'Work')? '(Preferred)' : '')));
        }
        return pNums;
    }
    
    public PageReference sendSMS() {
        return sendSMS(false);
    }
    
    public PageReference sendSMS(boolean isTest) { 
    
       // messageText = String.valueOfGMT(DateTime.now());
       // return null;
        
        //messageText = String.valueOf(DateTime.newInstance(2011, 10, 17, 4, 0, 0));return null;
      //  messageText = String.valueOf(MMUtilTimeZone.convertToGMT(DateTime.newInstance(2011, 10, 17,4, 0, 0) , '5_a'));
      // return null;
       string tempMessage = '';
       string accountErrorMessage = '';
       MMAccountStatus mmStatus = MMUtils.getUserAccountStatus(UserInfo.getUserId(), false);
       if (mmStatus != null && mmStatus.getError().length() == 0) {
           if (integer.valueOf(mmStatus.getSmsRemaining()) < 1) {
               accountErrorMessage = 'Required SMS: 1, SMS Remaining: ' + 
                                                               mmStatus.getSmsRemaining() + ' out of ' + mmStatus.getSmsLimit();
           }
       }
       else {
           if (mmStatus == null) {
               accountErrorMessage = 'Invalid status returned from Message Media';
           }
           else {
               accountErrorMessage = mmStatus.getError();
           }
       }
        
       if (isTest) accountErrorMessage = '';
        
       if (accountErrorMessage.length() > 0) {
           MMUtils.addMessage(ApexPages.Severity.ERROR, accountErrorMessage);
           return null;
       }

       string sendStatus = null;
       List<MMUtilSMSObject> receipientList = new List<MMUtilSMSObject>();
       Id opId = System.currentPageReference().getParameters().get('oid');
       String src = System.currentPageReference().getParameters().get('src');
       errPhoneNumber = (selectedPhoneNumber == null)? true: false;
       errMessageText = (messageText == '')? true: false;
       MMSMSReceipt__c receipt = null;
       long receiptNumber = MMUtils.getReceiptNumber();
       
       string country = '';

       Boolean isError = false;
       
       system.debug('receiptNumber>>>>'+receiptNumber);
       
       if(receiptNumber == 0){
       	MMUtils.addMessage(ApexPages.Severity.ERROR, Label.ErrorSMSFewMinutes);
       	if(!test.isrunningtest())
       		isError = true;
       }	
       		

       if ((delivery == 'true') && selectedTimeZone == '0_a') {
           MMUtils.addMessage(ApexPages.Severity.ERROR, (delivery == 'true')?'TimeZone is required because Delivery Tracking is requested':'Timezone is requried because the message is being scheduled');           
           isError = true;
       }
       
       if(schedule == 'true'){
           if(selectedTimeZone == '0_a'){
               MMUtils.addMessage(ApexPages.Severity.ERROR, 'TimeZone is Required for Scheduling');
               isError = true;
           }
           
           if(MMUtils.stringEmptyNull(startDate)){
               MMUtils.addMessage(ApexPages.Severity.ERROR, 'Start Date is Required for Scheduling');
               isError = true;
           }
           if(MMUtils.stringEmptyNull(startTime)){
               MMUtils.addMessage(ApexPages.Severity.ERROR, 'Start Time is Required for Scheduling');
               isError = true;
           }
       }
       
       
       if(isError){
           return System.currentPageReference();
       }
       try {
           country = (src == 'op')? [select Country__c from contact where Id in (select Student__c from opportunity where Id = : opId)][0].Country__c
                                         : [select Country__c from contact where Id = : opId].Country__c;
       }
       catch ( Exception e) {
           country = '';
       }
       
       if(errMessageText || errPhoneNumber) {
           MMUtils.addMessage(Apexpages.Severity.ERROR, 'Invalid Data - Review all error messages below to correct your data');
           return null;
       }
       
       //Resolving Template if any
       String[] extractedFields = new List<String>();
       String query = MMSMSTemplates.getTemplateQuery(messageText, extractedFields, new string[] { this.entityId }, this.entityType);
       SObject[] tObjects = null;
       if(query != null){
            try{
                tObjects = Database.Query(query);
            }
            catch(Exception e){
                tObjects = null;
            }
       }
       messageText = MMSMSTemplates.getTemplateMessage(String.valueOf(this.entityId), MMUtils.filterNull(messageText), tObjects, extractedFields, this.entityType);
       //Resolving Template ends if any   
       messageText = MMUtilSch.clearMergedFields(messageText);     
       tempMessage = (headerText + messageText + footerText);
       tempMessage = tempMessage.replace('\r\n', '\n');
       if (this.isMultiPart != 'true' && tempMessage.length() > 160) tempMessage = tempMessage.substring(0, 160);
       if(schedule == 'false') {
           receipientList.add(new MMUtilSMSObject(opId, selectedPhoneNumber, receiptNumber, ((delivery == 'true') ? true : false), country, tempMessage));
           sendStatus = MMUtilSoap.sendSMS(receipientList, tempMessage, UserInfo.getUserId());
       } else {
           sendStatus = 'Successfull';
       }
       
       PageReference pr = null;
       try {
           if(saveHF == 'true') MMUtils.saveHeaderFooter(headerText, footerText, 'single', selectedTimeZone);
           pr = new PageReference('/' + opId);       
           pr = pr.setRedirect(true);       
       }
       catch(Exception exp) {
           MMUtils.addMessage(Apexpages.Severity.ERROR, 'Not able to save header/footer/timezone at this time, please retry later, reason: ' + exp.getMessage());
       }
       
       Integer truncateLen = headerText.length() + messageText.length() + footerText.length(); 
       truncateLen = (truncateLen > 20)? 20 : truncateLen;
       
       Task t = MMUtils.createTask(opId, src, ('SMS: ' + tempMessage), sendStatus, (delivery == 'true'), schedule == 'true');
       insert t;
       
       DateTime schDateTime;
       if(schedule == 'true'){
           String[] dt = startDate.split('/');           
           schDateTime = DateTime.newInstanceGmt(Integer.valueOf(dt[2]),Integer.valueOf(dt[0]),Integer.valueOf(dt[1]),Integer.valueOf(startTime), 0, 0);           
           schDateTime = MMUtilTimeZone.convertToGMT(schDateTime,selectedTimeZone, daylightSaving);           
       }
        
       receipt = MMUtils.createSMSReceipt(opId, src, receiptNumber, schedule == 'true', delivery == 'true', t.Id, null, '', selectedTimeZone, dayLightSaving,
                                               (tempMessage), schDateTime, selectedPhoneNumber, country);
       insert receipt;
                                                     
       t.MMSMSReceiptId__c = receipt.Id;
       update t;
       
       insert MMUtilLog.createSMSLog(UserInfo.getUserId(), UserInfo.getUserType(), opId, src, selectedPhoneNumber,
                                selectedTimeZone, dayLightSaving, null, 'Outbound', 
                               (tempMessage), receipt.Id, t.Id);
       //Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.CONFIRM, 'After send - Message has been sent ' + opId));
       return pr;
    }

    public List<SelectOption> getTimeoptions(){
        return MMUtils.getTimeOptions();
    }
    
    public List<SelectOption> getYearOptions(){
        List<SelectOption> years = new List<SelectOption>();
        for(integer year = 2011; year <= 2015 ; year ++){
           years.add(new SelectOption(String.valueOf(year),String.valueOf(year)));
        }
        return years;
    }
    
    public List<SelectOption> getMonthOptions(){
        List<SelectOption> months = new List<SelectOption>();
        integer monthNum = 1;
        months.add(new SelectOption(String.valueOf(monthNum++),'January')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'February')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'March')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'April')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'May')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'June')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'July')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'August')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'September')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'October')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'November')); 
        months.add(new SelectOption(String.valueOf(monthNum++),'December'));         
        return months;
    }

    public List<SelectOption> getDayOptions(){
        List<SelectOption> days = new List<SelectOption>();
        for(integer day = 2011; day <= 2015 ; day ++){
           days.add(new SelectOption(String.valueOf(day),String.valueOf(day)));
        }
        return days;
    }
    public PageReference resetPage(){        
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }
}