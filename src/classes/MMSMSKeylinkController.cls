public class MMSMSKeylinkController {
    private List<MMSMSTemplatesSchema> tables;
    private string defaultResponse;
    private MMSMSKeylink__c currRec;
    public boolean createAffiliation { get; set; }
    public boolean createOpportunity { get; set; }
    public string keyword { get; set; }
    public string notifyTo { get; set; }
    public boolean isActive { get; set; }
    public string btnDeleteDisabled { get; set; }
    public boolean btnAttrList { get; set; }
    public boolean attrList { get; set; }
    public string keylinkUrl { get; set; }
    public string keylinkAttrUrl { get; set; }
    public string getDefaultResponse() {
        return this.defaultResponse;
    }
    public void initPage() {
        defaultResponse = '';
        PageReference pr = null;
        string id = null;
        string type = null;
        try {
            tables = MMSMSTemplates.getSchema();
            pr = System.currentPageReference();
            id = pr.getParameters().get('id');
            type = pr.getParameters().get('type');
            if (!MMUtils.stringEmptyNull(id) && !MMUtils.stringEmptyNull(type)) {
                loadRecord(id);
                if (type == 'edit') {
                    this.createAffiliation = currRec.CreateAffliliation__c;
                    this.createOpportunity = currRec.CreateOpportunity__c;
                    this.keyword = currRec.Keyword__c;
                    this.notifyTo = currRec.NotifyTo__c;
                    this.isActive = currRec.IsActive__c;
                }
            }
            else {
                this.btnDeleteDisabled = 'true';
            }
            
        }
        catch(Exception e) {
            defaultResponse = 'NO';
        }
        this.keylinkUrl = '/apex/mmsmskeylink?id=' + id + '&type=edit';
        this.keylinkAttrUrl = '/apex/mmsmskeylinkattrlist?id=' + id + '&type=edit';        
    }
    public string selectedTable { get; set; }
    public string selectedField { get; set; }
    public void loadRecord(string id) {
        this.currRec = [select Id, CreateAffliliation__c, CreateOpportunity__c, Keyword__c, NotifyTo__c, IsActive__c from MMSMSKeylink__c where Id = :id];
    }
    public PageReference pageLoad() {
        PageReference pr = System.currentPageReference();
        
        return pr;
    }
    public PageReference saveKeylink() {
        PageReference pr = System.currentPageReference();
        string id = pr.getParameters().get('id');
        string type = pr.getParameters().get('type');
        if (!MMUtils.stringEmptyNull(type) && !MMUtils.stringEmptyNull(id)) {
            if (type == 'edit') {
                loadRecord(id);
                currRec.CreateAffliliation__c = this.createAffiliation;
                currRec.CreateOpportunity__c = this.createOpportunity;
                currRec.Keyword__c = this.keyword;
                currRec.NotifyTo__c = this.notifyTo;
                currRec.IsActive__c = this.isActive;
                update currRec;
            }
        }
        else {
            MMSMSKeylink__c currRec = new MMSMSKeylink__c();
            currRec.CreateAffliliation__c = this.createAffiliation;
            currRec.CreateOpportunity__c = this.createOpportunity;
            currRec.Keyword__c = this.keyword;
            currRec.NotifyTo__c = this.notifyTo;
            currRec.IsActive__c = this.isActive;
            insert currRec;
        }
        pr = new PageReference('/apex/mmsmskeylinklist');
        pr = pr.setRedirect(true);
        return pr;
    }
    public PageReference onCancel() {
        MMUtilSch.logMessage('cancel');
        PageReference pr = new PageReference('/apex/mmsmskeylinklist');
        pr = pr.setRedirect(true);
        return pr;
    }
    public PageReference deleteKeylink() {
        PageReference pr = System.currentPageReference();
        string id = pr.getParameters().get('id');
        loadRecord(id);
        delete this.currRec;
        pr = new PageReference('/apex/mmsmskeylinklist');
        pr = pr.setRedirect(true);
        return pr;
    }

    public List<SelectOption> getUserList() {
        List<SelectOption> userList = new List<SelectOption>();
        userList.add(new SelectOption('','-Select-'));
        for(User u : [select Id, Name, UserName from User order by Name]) {
            userList.add(new SelectOption(u.Id,u.UserName));
        }
        return userList;
    }
    public PageReference getFieldListJson() {
        string json = '[';
        
        json += this.selectedTable;
        
        json += ']';
        return null;
    }
}