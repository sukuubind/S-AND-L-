public class MMSMSTemplateController {
    private List<MMSMSTemplatesSchema> tables;
    private string defaultResponse;
    private MMSMSTemplate__c currRec;
    public string templateNameField { get; set; }
    public string templateField { get; set; }
    public string btnDeleteDisabled { get; set; }
    public boolean isErrorTemplateName { get; set; }
    public boolean isErrorTemplateField { get; set; }
    public string getDefaultResponse() {
        return this.defaultResponse;
    }
    public PageReference initPage() {
        if (!MMSMSUIPermission.isDirectorAdmissions(null) && !MMSMSUIPermission.isDirectorAdmissionsPTemplate(null) && !MMSMSUIPermission.isSystemAdministrator(null)) {
            PageReference pageRef = new PageReference('/apex/mmsmsaccessdenied');
            pageRef.setRedirect(true);
            return pageRef;
        }
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
                    this.templateNameField = currRec.TemplateName__c;
                    this.templateField = currRec.Template__c;
                    this.btnDeleteDisabled = 'false';
                }
            }
            else {
                this.btnDeleteDisabled = 'true';
            }

        }
        catch(Exception e) {
            defaultResponse = 'NO';
        }
        return null;
    }
    public string selectedTable { get; set; }
    public string selectedField { get; set; }
    public void loadRecord(string id) {
        this.currRec = [select Id, TemplateName__c, Template__c from MMSMSTemplate__c where Id = :id];
    }
    public PageReference pageLoad() {
        PageReference pr = System.currentPageReference();
        
        return pr;
    }
    public boolean validate() {
        boolean status = true;
        if (MMUtils.stringEmptyNull(this.templateNameField)) {
            this.isErrorTemplateName = true;
            status = false;
        }
        else {
            this.isErrorTemplateName = false;
        }
        if (MMUtils.stringEmptyNull(this.templateField)) {
            this.isErrorTemplateField = true;
            status = false;
        }
        else {
            this.isErrorTemplateField = false;
        }
        if (!status) {
            MMUtils.addMessage(ApexPages.Severity.ERROR, 'Invalid Data - Review all error messages below to correct your data');
        }
        return status;
    }
    public PageReference saveTemplate() {
        PageReference pr = System.currentPageReference();
        string type = pr.getParameters().get('type');
        string id = pr.getParameters().get('id');
        
        if (!validate()) return null;
        
        if (!MMUtils.stringEmptyNull(type) && !MMUtils.stringEmptyNull(id)) {
            if (type == 'edit') {
                loadRecord(id);
                currRec.Template__c = this.templateField;
                currRec.TemplateName__c = this.templateNameField;
                update currRec;
            }
        }
        else {
            MMSMSTemplate__c currRec = new MMSMSTemplate__c();
            currRec.Template__c = this.templateField;
            currRec.TemplateName__c = this.templateNameField;
            insert currRec;
        }
        pr = new PageReference('/apex/mmsmstemplatelist');
        pr = pr.setRedirect(true);
        return pr;
    }
    public PageReference cancel() {
        PageReference pr = new PageReference('/apex/mmsmstemplatelist');
        pr = pr.setRedirect(true);
        return pr;
    }
    public PageReference deleteTemplate() {
        PageReference pr = System.currentPageReference();
        string id = pr.getParameters().get('id');
        loadRecord(id);
        delete this.currRec;
        pr = new PageReference('/apex/mmsmstemplatelist');
        pr = pr.setRedirect(true);
        return pr;
    }

    public List<SelectOption> getTableList() {
        List<SelectOption> tableOptions = new List<SelectOption>();
        tableOptions.add(new SelectOption('',''));
        for (MMSMSTemplatesSchema table : tables) {
            tableOptions.add(new SelectOption(table.getTableName(), table.getTableLabel()));
        }
        return tableOptions;
    }
    public List<SelectOption> getFieldList() {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        
        if (this.selectedTable != null) {
            MMSMSTemplatesSchema table = null;
            List<MMSMSTemplatesSchemaField> fields = null;
            if (!MMUtils.stringEmptyNull(this.selectedTable)) {
               table = MMSMSTemplates.getTableFields(this.selectedTable);
               if (table != null && table.getFields() != null) {
                   fields = table.getFields();
                   for(MMSMSTemplatesSchemaField field : fields) {
                       fieldOptions.add(new SelectOption(field.getName(),field.getLabel()));
                   }
               }
            }
        }
        
        return fieldOptions;
    }
    public PageReference getFieldListJson() {
        string json = '[';
        
        json += this.selectedTable;
        
        json += ']';
        return null;
    }
}