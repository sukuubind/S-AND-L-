public class BatchSMSController {

    public Boolean daylightSaving { get; set; }
    public String subjectStyle { get; set; }
    public String selectedSavedSearch { get; set; }
    public Boolean selectAll { get; set; }    
    public String listSource { get; set; }
    public String templateText { get; set; }
    public String prefilledCount { get; set; }
    public List<SelectOption> templateList { get; set; }
    public String startTimeClass { get; set; }
    public String startDateClass { get; set; }    
    public String resultInfo { get; set; }
    public List<SelectOption> keylinkKeywordOptions { get; set; }
    public List<SelectOption> savedSearchesOptions { get; set; }    
    public String selectedKeylinkKeyword { get; set; }    
    public String groupSMSId { get; set; }
    public String txtSubject { get; set; }
    public String startTime { get; set; }
    public String startDate { get; set; }
    public String scheduled { get; set; }
    public String multipart { get; set; }
    public String txtNotes { get; set; }
    public String txtTitle { get; set; }
    public String saveHF { get; set; }
    public String tzClass { get; set; }
    public String trackClass { get; set; }
    public String messageClass { get; set; }
    public String pNumClass { get; set; }
    public Boolean showOmitWarning { get; set; }
    public String deliveryTrack { get; set; }
    public String headerText { get; set; }
    public String footerText { get; set; }
    public String selectedTimeZone { get; set; }
    public String messageText { get; set; }
    public List<SelectOption> candidateOptions { get; set;}
    public String[] selectedCandidates { get; set;}
    public String pageInfo { get; set; }
    public List<String> selectedCurrentCandidates { get; set; }
    public String traceBox { get; set; }
    public Boolean isNextVisible { get; set; }
    public Boolean isPreviousVisible { get; set; }
    public List<SelectOption> currentCandidateOptions { get; set; }
    public string firstEntryMergedText { get; set; }

    public integer pageSize = 1000;
    public integer currentPage = 0;
    public List<Integer> allSelected = new List<Integer>();
    public boolean isImmediate;
    public transient boolean isSendSMS;
    public String ids = '';
    public string src = '';
    public List<List<String>> entityContactMap = new List<List<String>>();
    public string accountErrorMessage = '';
    
    public boolean isKeyListDisabled { get; set; }
    public boolean isSearchListDisabled { get; set; }    

    public PageReference selectAllOnChange() {
        allSelected = new List<Integer>();
        if(selectAll){
            Integer index = 0;
            for(List<String> mp : entityContactMap){
                allSelected.add(index);
                index++;
            }
        }
        updateSelection();
        return null;
    }
    
    public string getMergedTemplateText(string message, string entityId, string entityType) {
        string txt = '';
        String[] extractedFields = new List<String>();
        SObject[] tObjects = null;
        String query = MMSMSTemplates.getTemplateQuery(MMUtils.filterNull(message), extractedFields, new String[] { entityId }, entityType);                
        if(query != null){
            try{
                tObjects = Database.Query(query);
            }
            catch(Exception e){
                tObjects = null;
            }
        }
        txt = MMSMSTemplates.getTemplateMessage(String.valueOf(entityId), MMUtils.filterNull(message), tObjects, extractedFields, entityType);  

        txt = MMUtilSch.clearMergedFields(txt);

        return txt;
    }

    public void setFirstEntryMergeFieldText() {
        if (allSelected != null && allSelected.size() > 0) {
            this.firstEntryMergedText = this.headerText + 
                                        getMergedTemplateText(this.messageText, this.entityContactMap[allSelected[0]][0], this.entityContactMap[allSelected[0]][3]) +
                                        this.footerText;
        }
        else {
            this.firstEntryMergedText = this.headerText + this.messageText + this.footerText;
        }
    }

    public PageReference getKeylinkCandidates() {
        resetPagination();
        String keyword = ApexPages.CurrentPage().getParameters().get('keyword');              
        entityContactMap = new List<List<String>>();
        List<String> afIds = new List<String>();
        List<String> opIds = new List<String>();
        if (keyword == null || keyword == '') keyword = selectedKeylinkKeyword;
        if (keyword != null && keyword != '') {
            for(MM_SMS_Log__C log : [select SenderId__c, SenderType__C from MM_SMS_Log__c where SMSType__c = 'keylink' and SenderType__c in ('af','op') and KeylinkKeyword__c= : keyword]){
                if(log.SenderType__c == 'af') afIds.add(log.SenderId__c);
                    else opIds.add(log.SenderId__c);            
            }
            createContactOptions(afIds, 'af');
            createContactOptions(opIds, 'op');
        }
        else {
            createContactOptions(afIds, '');        
        }
        resetPagination();
        showContacts();        
        selectedCandidates = new List<String>();
        selectedCurrentCandidates = new List<String>();        
        return null;
    }

    public PageReference getlistSourceOptions() {
        if(listSource == 'kk'){
            Set<String> keywordsSet = new Set<String>();
            for(MM_SMS_Log__c log : [select Message__c from MM_SMS_Log__c where SMSType__c = 'keylink']){
                String msg = log.Message__c;
                String keyword = msg.contains(' ')? msg.split(' ')[0] : msg;
                keywordsSet.add(keyword);
            }                    
            List<String> keywordList = new List<String>(keywordsSet);
            keylinkKeywordOptions = new List<SelectOption>();
            keyLinkKeywordOptions.add(new SelectOption('','-- Select Keyword --'));
            for(String keyword : keywordList){
                keyLinkKeywordOptions.add(new SelectOption(keyword,keyword));
            }
            this.isSearchListDisabled = true;
            this.isKeyListDisabled = false;
        } 
        else if(listSource == 'ss'){
            List<SelectOption> ss = new List<SelectOption>();
            ss.add(new SelectOption('','-- Select Search --'));                       
            PageReference pr = new PageReference('/apex/getViewsList');            
            List<String> options = pr.getContent().toString().split(',');
            for(String option : options){
                String[] opArr = option.split(';');
                ss.add(new SelectOption(opArr[0], opArr[1]));
            }            
            savedSearchesOptions = ss;
            this.isSearchListDisabled = false;
            this.isKeyListDisabled = true;
        }
        else {
            this.isSearchListDisabled = false;
            this.isKeyListDisabled = false;
        }        
        return null;
    }

    public PageReference getSavedSearchCandidates() {
        resetPagination();
        String viewId = ApexPages.CurrentPage().getParameters().get('viewId');              
        if(viewId == null) viewId = selectedSavedSearch;        
        entityContactMap = new List<List<String>>();
        List<String> ids = new List<String>(); 
        string type = '';
        string id = '';
        String[] arr = null;
        if (viewId != '' && viewId != null) {       
            arr = viewId.split(':');
            type = arr[0];
            id = arr[1];
            ids = (type == 'af') ? MMUtils.getContactsByView(id) : MMUtils.getOpportunitiesByView(id);        
        }
        createContactOptions(ids, type);        
        showContacts();       
        selectedCandidates = new List<String>();  
        selectedCurrentCandidates = new List<String>();              
        return null;
    }

    public PageReference sendSMS() {
        isSendSMS = true;
        return sendSMS(false);
    }
    
    public PageReference onCancel() {
        PageReference pr = new PageReference('/apex/groupsmslist');
        pr.setRedirect(true);
        return pr;
    }

    public PageReference groupSMSDel() {
        if (!MMSMSUIPermission.isDirectorAdmissions(null) && !MMSMSUIPermission.isDirectorAdmissionsPTemplate(null) && !MMSMSUIPermission.isSystemAdministrator(null)) {
            PageReference pageRef = new PageReference('/apex/mmsmsaccessdenied');
            pageRef.setRedirect(true);
            return pageRef;
        }
        String msgId = System.currentPageReference().getParameters().get('id');
        MMGroupSMS__c groupMsg = [select Id from MMGroupSMS__c where Id = : msgId];
        delete groupMsg; 
        PageReference pr = new PageReference('/apex/groupsmslist');
        pr = pr.setRedirect(true);  
        return pr;
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
    
    public PageReference sendSMS(Boolean isTest) {
        PageReference saveSMSRef = null;
        Boolean isError = false;
        
        if(messageText == ''){
            messageClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Please Enter a Message');
            isError = true;
        } else {
            messageClass = '';
        }
        
        if(allSelected.size() == 0){
            pNumClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Please Select at least one candidate');
            isError = true;
        } else {
            pNumClass = '';
        }
        
        if(deliveryTrack == 'true' && selectedTimeZone == '0_a'){        
            tzClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'TimeZone not selected as Delivery Tracking is required');        
            isError = true;
        } else {
            tzClass = '';
        }
        
        if(scheduled == 'true') isError = validateScheduleFields();
        if(isError) return null;        
            
        isImmediate = true;
        saveSMSRef = saveSMS(isTest);
        
        if( scheduled != 'true' && this.accountErrorMessage.length() == 0){
            MMBatchHelper__c bHelper = MMUtilSch.getPreviousBatchJobId();
            boolean toSchedule = false;
            
            if (bHelper != null) {
                if (!bHelper.InProcess__c) {
                    toSchedule = true;
                }
            }
            else {
                toSchedule = true;
            }
            if (toSchedule) {
                MMUtilSch.storePreviousBatchJobId(null, true);
                DateTime dtNow = DateTime.now().addSeconds(3);
                String nextJobHH = String.valueOf(dtNow.hour());
                String nextJobMM = String.valueOf(dtNow.minute());
                String nextJobSS = String.valueOf(dtNow.second()); 
                
                String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
                System.schedule('MM Immediate Job Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsImmediateScheduler());
                
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your Message Has Been Scheduled for Immediate Sending..'));
        }
        else {
            if (this.accountErrorMessage.length() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.accountErrorMessage));
            }
        }
        if(saveHF == 'true') MMUtils.saveHeaderFooter(headerText, footerText, 'group', selectedTimeZone);
        
        return saveSMSRef;
    }
    
    public Boolean validateScheduleFields(){
        Boolean isError = false;
        if(selectedTimeZone == '0_a'){
            tzClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'TimeZone is required to schedule a message');
            isError = true;
        } else {
            tzClass = '';
        }
        
        if(MMUtils.stringEmptyNull(startDate)){
            startDateClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Start Date is required to schedule a message');
            isError = true; 
        } else {
            startDateClass = '';
        }
        
        if(MMUtils.stringEmptyNull(startTime)){
            startTimeClass = 'error';
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Start Time is required to schedule a message');
            isError = true;
        } else {
            startTimeClass = '';
        }
        
        return isError;
    }
    
    public PageReference init(){
       if (!MMSMSUIPermission.isDirectorAdmissions(null) && !MMSMSUIPermission.isDirectorAdmissionsPTemplate(null) && !MMSMSUIPermission.isSystemAdministrator(null)) {
            PageReference pageRef = new PageReference('/apex/mmsmsaccessdenied');
            pageRef.setRedirect(true);
            return pageRef;
       }
       showOmitWarning = false;
       isImmediate = false;
       isSendSMS = false;
       String id = System.currentPageReference().getParameters().get('id');
       src = System.currentPageReference().getParameters().get('src');       
       Boolean isGroupMessage = (src == 'groupsms');              
       String[] selectedIds = new List<String>();
       String selectedIdsString; 
       if(src == 'groupsms'){          
            MMGroupSMS__c groupMsg = [select Id, Name, isScheduled__c, ids__c, TimeZone__c, StartTime__c, StartDate__c, Multipart__c, Message__c, IsTrackDelivery__c, isDaylightSaving__c, Header__c, Footer__c, EntityType__c,Subject__c, Notes__c, SelectedIds__c, listSource__c, listSourceSelected__c  from MMGroupSMS__c where Id =: id];
            ids = groupMsg.ids__c;           
            src = groupMsg.EntityType__c;
            messageText = groupMsg.Message__c;
            multipart = groupMsg.Multipart__c?'true':'false';
            headerText = MMUtils.stringEmptyNull(groupMsg.Header__c) ? '' : groupMsg.Header__c.replace('_-_','\n');
            footerText = MMUtils.stringEmptyNull(groupMsg.Footer__c) ? '' : groupMsg.Footer__c;//.replace('_-_','\r\n');
            scheduled = groupMsg.isScheduled__c? 'true' : 'false';
            startDate = groupMsg.StartDate__c;
            startTime = String.valueOf(groupMsg.startTime__c);
            deliveryTrack = groupMsg.isTrackDelivery__c?'true':'false';
            selectedTimeZone = groupMsg.TimeZone__c;
            daylightSaving = groupMsg.isDaylightSaving__c;
            groupSMSId = groupMsg.Id;
            txtSubject = groupMsg.Subject__c; 
            txtNotes = groupMsg.Notes__c;           
            selectedIdsString = MMUtilSch.getSelectedIdsforGroup(groupMsg.Id);
            selectedIds = selectedIdsString.split(',');//(groupMsg.SelectedIds__c == null)? new List<String>() : groupMsg.SelectedIds__c.split(',');             
            listSource = groupMsg.listSource__c;
            getlistSourceOptions();
            if (listSource == 'ss') {
                selectedSavedSearch = groupMsg.listSourceSelected__c;
                getSavedSearchCandidates();
            }
            else if (listSource == 'kk') {
                selectedKeylinkKeyword = groupMsg.listSourceSelected__c;
                getKeylinkCandidates();
            }
       } else {
           ids = id;           
           SMSHeaderFooter__c hf = MMUtils.getHeaderFooter('group', UserInfo.getUserId());    
           if (hf != null) {
               headerText = MMUtils.stringEmptyNull(hf.Header__c) ? '' : hf.Header__c.replace('_-_','\n');
               footerText = MMUtils.stringEmptyNull(hf.Footer__c) ? '' : hf.Footer__c.replace('_-_','\n');
               selectedTimeZone = hf.Time_Zone__c;
            }
       }
       selectedCandidates = new List<String>();
       if(ids != null){
           if(isGroupMessage){
               List<String> idsArr = ids.split(',');
               String idsAf = '';
               String idsOp = '';
               for(String eId : idsArr){
                   List<String> idDetail = eId.split('###');
                   if(idDetail[1] == 'af') idsAf += idDetail[0] + ',';                   
                       else  idsOp += idDetail[0] + ',';
               }
               if(idsAf != '') createContactOptions(idsAf.split(','), 'af');
               if(idsOp != '') createContactOptions(idsOp.split(','), 'op');               
           } else {
               ids = EncodingUtil.urlDecode(ids, 'UTF-8');
               createContactOptions(ids.split(','), src);
           }           
           showContacts();                     
       }
       
       if(isGroupMessage){
          //messageText = String.valueOf(entityContactMap[0][0] + ' ' + selectedIds[0]); return;          
           allSelected = new List<Integer>();
           Integer mapSize = entityContactMap.size();
           integer count = 0;
          
           for(Integer j = 0; j < mapSize; j ++){
                count++;
                String idToCompare =  entityContactMap[j][0];
                if(selectedIdsString.contains(idToCompare)){
                    allSelected.add(j);
                }
           }
           updateSelection();
       }
        templateList = new List<SelectOption>();        
        List<MMSMSTemplate__c> templates = MMSMSTemplates.getAvailableTemplates();
        if (templates != null && templates.size() > 0) {
            for(MMSMSTemplate__C tmp : templates){
                if (!MMUtils.stringEmptyNull(tmp.Id) && !MMUtils.stringEmptyNull(tmp.TemplateName__c)) {
                    templateList.add(new SelectOption(tmp.Id, tmp.TemplateName__c));
                }
            }
        } 
        if (entityContactMap != null && entityContactMap.size() == allSelected.size()) {
            selectAll = true;
        }
        else {
            selectAll = false;
        }
        return null;
    }

    public List<SelectOption> getListOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('ss','Saved Searches')); 
        options.add(new SelectOption('kk','Keylink Keyword')); 
        return options;
    }

    
    public List<SelectOption> createContactOptions(String[] idsArr, String type){
        if(idsArr == null || idsArr.size() == 0) return null;
        Contact[] contacts = new List<contact>();
        List<String> ops = new List<String>();
                
        if(type == 'af'){
            contacts = [SELECT Id, FirstName, LastName, Phone, HomePhone , MobilePhone, Work_Phone__c, Preferred_Phone__c, Country__c, OK_to_Text__c from contact where id in :idsArr];
        } else {
            contacts = new list<Contact>();
            for(Opportunity op : [Select Id, Student__r.Id, Student__r.FirstName, Student__r.LastName, Student__r.Phone, Student__r.HomePhone , Student__r.MobilePhone, Student__r.Work_Phone__c, Student__r.Preferred_Phone__c, Student__r.Country__c, Student__r.OK_to_Text__c from Opportunity where Id in : idsArr]){
                contacts.add(op.Student__r);
                ops.add(op.Id);
            }            
        }
        
        Integer mapExistingSize = entityContactMap.size();
        Integer size = contacts.size() + mapExistingSize;         
        Integer localIndex = 0;
        Integer mapIndex = mapExistingSize;
        Long maxHeapSize = 0;        
        
        for(integer i = mapExistingSize ; i < size; i++){            
            Contact c = contacts[localIndex];
            if(c == null || c.OK_to_Text__c == 'No'){
                showOmitWarning = true;                
                contacts.remove(localIndex);                
                continue;
            }
            string key = '';
            if(c.Phone != null && c.Phone != '') {
                key = c.Phone;                
            } else if( c.Preferred_Phone__c != '' & c.Preferred_Phone__c != null){
                key = (c.Preferred_Phone__c == 'Mobile')? c.MobilePhone : ((c.Preferred_Phone__c == 'Home')? c.HomePhone : c.Work_Phone__c);
                key = (key == null)?'None':key;
            } else if(c.MobilePhone != null && c.MobilePhone != ''){
                key = c.MobilePhone;
            } else if(c.HomePhone != null && c.HomePhone != ''){
                key = c.HomePhone;
            } else if(c.Work_Phone__c != null && c.Work_Phone__c != ''){
                key = c.Work_Phone__c;
            } else {
                key = 'None';
            }          
            string value = c.FirstName + ' ' + c.LastName + ' - ' + key;
            List<String> mapItem = new List<String>();
            mapItem.add(String.valueOf((type == 'af')?c.Id:ops[localIndex]));
            mapItem.add(key);
            mapItem.add(c.Country__c);
            mapItem.add(type);
            mapItem.add(value);
            entityContactMap.add(mapItem);            
            contacts.remove(localIndex);
            if(type == 'op') ops.remove(localIndex);
        }
        return null;
    }
    
    public PageReference saveSMS() {
        return saveSMS(false);
    }
    
    public PageReference saveSMS(boolean isTest) {
    
        // might need in in near future
        /*if(MMUtils.stringEmptyNull(txtSubject)){
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Subject is required to save Message');            
            subjectStyle = 'error';
            return null;
        } else {
            subjectStyle = '';
        }*/
        MMAccountStatus mmStatus = null;
        
        if (isSendSMS == null) isSendSMS = false;
        
        this.accountErrorMessage = '';
        
        if(scheduled == 'true' && validateScheduleFields()){
            return null;
        }
        else {
            mmStatus = MMUtils.getUserAccountStatus(UserInfo.getUserId(), false);
            if (mmStatus != null && mmStatus.getError().length() == 0) {
                if (integer.valueOf(mmStatus.getSmsRemaining()) < allSelected.size()) {
                    this.accountErrorMessage = 'Required SMS: ' + allSelected.size() + ', SMS Remaining: ' + 
                                                                    mmStatus.getSmsRemaining() + ' out of ' + mmStatus.getSmsLimit();
                }
            }
            else {
                if (mmStatus == null) {
                    this.accountErrorMessage = 'Invalid status returned from Message Media';
                }
                else {
                    this.accountErrorMessage = mmStatus.getError();
                }
            }
            
            if (isTest) this.accountErrorMessage = '';
            
            if (this.accountErrorMessage.length() > 0) {// && scheduled == 'true') {
                MMUtils.addMessage(ApexPages.Severity.ERROR, this.accountErrorMessage);
                return null;
            }
        }
            
        integer size = allSelected.size();
        String selectedIds = '';        
        List<string> jobIds = null;
        string strJobIds = null;
        integer jobIdIndex = 0;
        integer jobIndex = 0;        
        List<MMGroupSMSJob__c> jobsList = new List<MMGroupSMSJob__c>();
        for(integer i = 0; i < size; i++){
            selectedIds += entityContactMap[allSelected[i]][0] + '###' + entityContactMap[allSelected[i]][3] + ',';
        }
        
        MMGroupSMS__c m;         
        if(groupSMSId == ''){
            m = new MMGroupSMS__c();
        } else {
            m = [select Id, Name, isScheduled__c, ids__c, TimeZone__c, StartTime__c, StartDate__c, 
                    Multipart__c, Message__c, IsTrackDelivery__c, Header__c, Footer__c, EntityType__c, IsImmediate__c
                    from MMGroupSMS__c where Id =: groupSMSId];
        }
        
        DateTime schDateTime;
        if(startDate != null && startDate != '' && startTime != null && startTime != ''){
            String[] dt = startDate.split('-');
            schDateTime = DateTime.newInstanceGmt(Integer.valueOf(dt[0]),Integer.valueOf(dt[1]),Integer.valueOf(dt[2]),Integer.valueOf(startTime), 0, 0);
            schDateTime = MMUtilTimeZone.convertToGMT(schDateTime,selectedTimeZone, daylightSaving);
        }
        
        String allIds = '';
        for(List<String> mapItem : entityContactMap){
            if(mapItem.size() == 0) continue;
            allIds += mapItem[0] + '###' + mapItem[3] + ',';
        }
        
        m.isScheduled__c = (scheduled == 'true');        
        m.ids__c = listSource == null ? allIds : '';
        m.TimeZone__c = selectedTimeZone;        
        m.StartTime__c = (StartTime == null)? null : Decimal.valueOf(StartTime);
        m.StartDate__c = StartDate;
        m.schDateTime__c = schDateTime;      
        m.Multipart__c = (multipart == 'true');
        m.Message__c = messageText;
        m.IsTrackDelivery__c = (DeliveryTrack == 'true');
        m.isDaylightSaving__c = daylightSaving;
        m.Header__c = headerText.replace('\n', '_-_');
        m.Footer__c = footerText.replace('\n', '_-_');
        m.EntityType__c = src;
        //m.selectedIds__c = selectedIds;
        m.Subject__c = txtSubject;
        m.Notes__c = txtNotes;
        m.IsImmediate__c = (scheduled == 'true') ? false : (isImmediate && IsSendSMS);
        m.listSource__c = listSource;
        m.listSourceSelected__c = (listSource == 'ss')? selectedSavedSearch : ((listSource == 'kk')? selectedKeylinkKeyword : null);
        jobIds = selectedIds.split(',');
        m.SMSBatchSize__c = jobIds.size() > MMUtilConstants.batchSize ? MMUtilConstants.batchSize : jobIds.size();        
        upsert m;
        
        //Saving ids job wise
        jobIdIndex = 0;
        jobIndex = 1;
        strJobIds = '';
        MMUtilSch.deleteJobs(m.Id);
        for(string jId : jobIds) {
            //if (strJobIds.length() > 0) strJobIds = strJobIds + ',';
            strJobIds = strJobIds + jId + ',';
            jobIdIndex = jobIdIndex + 1;
            if (jobIdIndex >= MMUtilConstants.batchSize) {
                jobsList.add(MMUtilSch.insertJob(m.Id, strJobIds.split(','), m.isScheduled__c || m.IsImmediate__c, jobIndex));
                jobIndex++;
                jobIdIndex = 0;
                strJobIds = '';
            }
        }
         
        if (strJobIds.length() > 0) {
            jobsList.add(MMUtilSch.insertJob(m.Id, strJobIds.split(','), m.isScheduled__c || m.IsImmediate__c, jobIndex));
            jobIndex++;
        }
        insert jobsList;
        //End Saving ids job wise
        
        if (this.accountErrorMessage.length() == 0) {
            MMUtils.addMessage(ApexPages.Severity.CONFIRM, 'Message has been Saved');
        }
        else {
            MMUtils.addMessage(ApexPages.Severity.ERROR, this.accountErrorMessage);
        }
        /*
        MMDebug__c dbg = new MMDebug__c();
        dbg.Message__c = 'from groupsms \n' +
                         + 'total numbers = ' + selectedCandidates.size() 
                         + '\n' + MMUtils.getLimitTrace();
        insert dbg;
        */
        //return null;
        
        PageReference pr = new PageReference('/apex/batchsms?src=groupsms&id=' + m.Id);
        pr.setRedirect(true);
        return pr;
        
    }
    
    public List<SelectOption> getTimeoptions(){
        return MMUtils.getTimeOptions();
    }
    
    public void getRefreshedTemplateLength() {
        String message = ApexPages.CurrentPage().getParameters().get('messageText');
        prefilledCount = String.valueOf(getPrefilledCount(message));
    }
    
    public void getTemplateContent(){
        String templateId = ApexPages.CurrentPage().getParameters().get('templateId');              
        String message = ApexPages.CurrentPage().getParameters().get('messageText');
        templateText = MMSMSTemplates.getTemplateContent(templateId).replaceAll('\n', '###');
        prefilledCount = String.valueOf(getPrefilledCount(message + templateText));
    }
    
    public void getTemplateContentPreview() {
        setFirstEntryMergeFieldText();
    }
    
    public Integer getPrefilledCount(String message){
        
        String[] extractedFieldsAf = new List<String>();
        String[] extractedFieldsOp = new List<String>();
        
        if(allSelected.size() == 0) return 0;
        
        List<String> entityIdsAf = new List<String>();            
        List<String> entityIdsOp = new List<String>();            
        for(Integer cand : allSelected){
            List<String> mapItem = entityContactMap[cand];
            if(mapItem[3] == 'af') entityIdsAf.add(mapItem[0]);
                else entityIdsOp.add(mapItem[0]);
        }
        
        String queryAf = MMSMSTemplates.getTemplateQuery(message, extractedFieldsAf, entityIdsAf, 'af');
        String queryOp = MMSMSTemplates.getTemplateQuery(message, extractedFieldsOp, entityIdsOp, 'op');
        
        Integer maxLengthAf = 0;
        Integer maxLengthOp = 0;
        
        if(queryAf != null && entityIdsAf.size() > 0) {        
            SObject[] objectsAf = Database.Query(queryAf);            
            String type = 'af';
            List<string> fieldParts = null;
            for(SObject obj : objectsAf) {             
                integer len = 0;
                for(String field : extractedFieldsAf){
                    String fname = '';
                    if(field.contains('Contact.')){
                        if(type == 'op'){
                            fname = field.replace('Contact.','Student__r.');
                        } else {
                            fname = field.split('\\.')[1];
                        }
                    } else {
                        fname = field.split('\\.')[1];
                    }
                    if(fname.contains('Student__r.')){
                        fname = field.split('\\.')[1];
                        fieldParts = fname.split('->');
                        Contact c = ((Opportunity)(obj)).student__r;               
                        if (fname.indexOf('->') > 0) {
                            len += MMUtils.filterNull(String.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1]))).length();
                        }
                        else {
                            len += MMUtils.filterNull(String.valueOf(c.get(fname))).length();
                        }
                    } else {
                        //fname = field.split('\\.')[1];
                        fieldParts = fname.split('->');
                        if (fname.indexOf('->') > 0) {
                            len += MMUtils.filterNull(String.valueOf(obj.getSObject(fieldParts[0]).get(fieldParts[1]))).length();
                        }
                        else {
                            len += MMUtils.filterNull(String.valueOf(obj.get(fname))).length();
                        }
                    }
                }
                if(len > maxLengthAf) maxLengthAf = len;
            }
        }
        
        if(queryOp != null && entityIdsOp.size() > 0) {        
            SObject[] objectsOp = Database.Query(queryOp);            
            String type = 'op';
            List<string> fieldParts = null;
            for(SObject obj : objectsOp) {             
                integer len = 0;
                for(String field : extractedFieldsOp){
                    String fname = '';
                    if(field.contains('Contact.')){
                        if(type == 'op'){
                            fname = field.replace('Contact.','Student__r.');
                        } else {
                            fname = field.split('\\.')[1];
                        }
                    } else {
                        fname = field.split('\\.')[1];
                    }
                    if(fname.contains('Student__r.')){
                        fname = field.split('\\.')[1];
                        fieldParts = fname.split('->');
                        Contact c = ((Opportunity)(obj)).student__r;               
                        if (fname.indexOf('->') > 0) {
                            len += MMUtils.filterNull(String.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1]))).length();                        
                        }
                        else {
                            len += MMUtils.filterNull(String.valueOf(c.get(fname))).length();
                        }
                    } else {
                        //fname = field.split('\\.')[1];
                        fieldParts = fname.split('->');
                        if (fname.indexOf('->') > 0) {
                            len += MMUtils.filterNull(String.valueOf(obj.getSObject(fieldParts[0]).get(fieldParts[1]))).length();
                        }
                        else {
                            len += MMUtils.filterNull(String.valueOf(obj.get(fname))).length();
                        }
                    }
                }
                if(len > maxLengthOp) maxLengthOp = len;
            }
        }
        
        return maxLengthAf > maxLengthOp ? maxLengthAf : maxLengthOp;
    }
    
     public PageReference onSelectionChange() {       
        this.selectAll = false;
        allSelected.sort();
        Integer sIndex = 0;
        integer startIndex = currentPage * pageSize;
        integer endIndex = startIndex + pageSize < entityContactMap.size() ? startIndex + pageSize : entityContactMap.size();        
        while(sIndex < allSelected.size() && allSelected[sIndex] < startIndex){
            sIndex ++;
        }  
        if(sIndex < allSelected.size()){            
            while(sIndex < allSelected.size() && allSelected[sIndex] < endIndex){                
                allSelected.remove(sIndex);
            }
        }

        for(String candidate : selectedCurrentCandidates){
            allSelected.add(Integer.valueOf(candidate));
        }
        allSelected.sort();
        setFirstEntryMergeFieldText();
        return null;
    }

    public Integer getNumSelectedCandidates() { 
        return allSelected.size();
    }
    
    public PageReference getPrevCandidates() {        
        currentPage--;
        showContacts();   
        updateSelection();
        traceBox = String.valueOf(allSelected) + '\n' + String.valueOf(selectedCurrentCandidates);    
        return null;
    }
    
    public PageReference getNextCandidates() {        
        currentPage++;
        showContacts();
        updateSelection();
        traceBox = String.valueOf(allSelected) + '\n' + String.valueOf(selectedCurrentCandidates);
        return null;
    }

    public void updateSelection(){
        selectedCurrentCandidates = new List<String>();
        Integer sIndex = 0;
        integer startIndex = currentPage * pageSize;
        integer endIndex = startIndex + pageSize < entityContactMap.size() ? startIndex + pageSize : entityContactMap.size();        
        while(sIndex < allSelected.size() && allSelected[sIndex] < startIndex){
            sIndex ++;
        }  
        if(sIndex < allSelected.size()){
            while(sIndex < allSelected.size() && allSelected[sIndex] < endIndex){
                selectedCurrentCandidates.add(String.valueOf(allSelected[sIndex]));
                sIndex++;
            }
        }
        setFirstEntryMergeFieldText();
    }
    
    public void showContacts(){
        List<SelectOption> options = new List<SelectOption>();
        integer startIndex = currentPage * pageSize;
        integer endIndex = startIndex + pageSize < entityContactMap.size() ? startIndex + pageSize : entityContactMap.size();        
        for(integer i = startIndex ; i <  endIndex; i ++){
            options.add(new SelectOption(String.valueOf(i), entityContactMap[i][4]));
        }
        Integer totalPages = Integer.valueOf(Math.ceil(Decimal.ValueOf(entityContactMap.size())/pageSize));
        pageInfo = '(page ' + (currentpage + 1) + ' of ' + totalPages + ')';
        resultInfo = '(showing ' + (startIndex + 1) + ' - ' + endIndex + ' of ' + entityContactMap.size() + ')'; 
        if(currentPage == 0) isPreviousVisible = false;
            else isPreviousVisible = true;
            
        if(currentPage >= totalPages - 1) isNextVisible = false;
            else isNextVisible = true;
        
        currentCandidateOptions = options;
    }
    
    public void resetPagination(){    
        currentPage = 0;
        isNextVisible = false;
        isPreviousVisible = false;
        allSelected = new List<Integer>();
    }
    
    public boolean getIsCandidateInfoVisible(){
        return allSelected.size() > 0;
    }
    
    public PageReference resetPage(){        
        //return null;
        //return new PageReference(ApexPages.currentPage().getUrl());
        //return ApexPages.currentPage();    
        PageReference pr = ApexPages.currentPage();
        pr.setRedirect(true);
        return pr;
    }
}