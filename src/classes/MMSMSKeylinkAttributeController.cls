public class MMSMSKeylinkAttributeController {
    private List<MMSMSTemplatesSchema> tables;
    private string defaultResponse;
    private MMSMSKeylinkAttribute__c currRec;
    public string keyLink { get; set; }
    public string keyword { get; set; }
    public string attributeRecord { get; set; }
    public string attributeName { get; set; }
    
    public string attributeValue { get; set; }
    public boolean attributeBooleanValue { get; set;}
    public string attributeDateValue { get; set; }
    public string attributePickList { get; set; }
    
    public string attributeType { get; set; }
    public string btnDeleteDisabled { get; set; }
    public string selectedTable { get; set; }
    public string selectedField { get; set; }
    public MMSMSKeylinkAttributeController(ApexPages.StandardController stdController) {
    }
    public string getDefaultResponse() {
        return this.defaultResponse;
    }
    public void initPage() {
        defaultResponse = '';
        PageReference pr = null;
        string id = null;
        string keyId = null;
        string type = null;
        MMSMSKeylink__c masterRec = null;
        try {
            tables = MMSMSTemplates.getSchema();
            pr = System.currentPageReference();
            keyId = pr.getParameters().get('keyId');
            id = pr.getParameters().get('id');
            if (!MMUtils.stringEmptyNull(id)) {
                loadRecord(id);
                masterRec = loadMasterRecord(currRec.MMSMSKeylink__c);
                this.keyLink = currRec.MMSMSKeylink__c;
                this.keyword = masterRec.Keyword__c;
                this.attributeRecord = currRec.AttributeRecord__c;
                this.attributeName = currRec.AttributeName__c;
                this.attributeType = currRec.AttributeType__c;
                setAttributeValueByType(currRec);
            }
            else {
                this.btnDeleteDisabled = 'true';
                masterRec = loadMasterRecord(keyId);
                this.keyLink = keyId;
                this.keyword = masterRec.Keyword__c;
            }

        }
        catch(Exception e) {
            defaultResponse = 'NO';
        }
    }
    public void loadRecord(string id) {
        this.currRec = [select Id, MMSMSKeylink__c, AttributeRecord__c, AttributeName__c, AttributeValue__c, AttributeType__c from MMSMSKeylinkAttribute__c where Id = :id];
    }
    public MMSMSKeylink__c loadMasterRecord(string id) {
        return [select Id, Keyword__c, NotifyTo__c, IsActive__c, CreateAffliliation__c, CreateOpportunity__c from MMSMSKeylink__c where Id = :id];
    }
    public PageReference pageLoad() {
        PageReference pr = System.currentPageReference();
        
        return pr;
    }
    public PageReference saveKeylinkAttribute() {
        PageReference pr = System.currentPageReference();
        string id = pr.getParameters().get('id');
        string keyId = pr.getParameters().get('keyId');
        string retUrl = pr.getParameters().get('retURL');
        if (!MMUtils.stringEmptyNull(this.attributeName) && (!MMUtils.stringEmptyNull(this.attributeValue) ||
                        !MMUtils.stringEmptyNull(this.attributeDateValue) ||
                        !MMUtils.stringEmptyNull(this.attributePickList) ||
                        (!MMUtils.stringEmptyNull(this.attributeType) && this.attributeType == 'boolean')
                    )) {
            if (!MMUtils.stringEmptyNull(id)) {
                loadRecord(id);
                currRec.AttributeRecord__c = this.attributeRecord;
                currRec.AttributeName__c = this.attributeName;
                currRec.AttributeValue__c = this.getAttributeValueByType(this.attributeType);
                currRec.AttributeType__c = this.attributeType;
                update currRec;
            }
            else {
                MMSMSKeylinkAttribute__c currRec = new MMSMSKeylinkAttribute__c();
                currRec.MMSMSKeylink__c = keyId;
                currRec.AttributeRecord__c = this.attributeRecord;
                currRec.AttributeName__c = this.attributeName;
                currRec.AttributeValue__c = this.getAttributeValueByType(this.attributeType);
                currRec.AttributeType__c = this.attributeType;
                insert currRec;
            }
            if (MMUtils.stringEmptyNull(retUrl)) {
                retUrl = '/apex/mmsmskeylinkattrlist?id=' + keyId + '&type=edit';
            }
            pr = new PageReference(retUrl);
            pr = pr.setRedirect(true);
            return pr;
        }
        else {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.WARNING, 'Attribute Name / Value could not be left blank'));
            return pr;
        }
    }
    
    public string getAttributeValueByType(string type) {
        string val = '';
        if (type == 'datetime' || type == 'date') {
            val = this.attributeDateValue;
        }
        else if (type == 'picklist') {
            val = this.attributePickList;
        }
        else if (type == 'boolean') {
            val = this.attributeBooleanValue ? 'true' : 'false';
        }
        else {
            val = this.attributeValue;
        }
        return val;
    }

    public void setAttributeValueByType(MMSMSKeylinkAttribute__c currRec) {
        if (currRec.AttributeType__c == 'datetime' || currRec.AttributeType__c == 'date') {
            this.attributeDateValue = currRec.AttributeValue__c;
        }
        else if (currRec.AttributeType__c == 'picklist') {
            this.attributePickList = currRec.AttributeValue__c;
        }
        else if (currRec.AttributeType__c == 'boolean') {
            this.attributeBooleanValue = currRec.AttributeValue__c == 'true' ? true : false;
        }
        else {
            this.attributeValue = currRec.AttributeValue__c;
        }
    }
    
    public PageReference cancel() {
        PageReference pr = System.currentPageReference();
        string retUrl = pr.getParameters().get('retURL');
        string keyId = pr.getParameters().get('keyId');
        if (MMUtils.stringEmptyNull(retUrl)) {
            retUrl = '/apex/mmsmskeylinkattrlist?id=' + keyId + '&type=edit';
        }
        pr = new PageReference(retUrl);
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
                       fieldOptions.add(new SelectOption(field.getName() + '___' + field.getType(),field.getLabel()));
                   }
               }
            }
        }
        
        return fieldOptions;
    }
    public List<SelectOption> getPickList() {
        List<SelectOption> pickListOptions = null;
        string id = null;
        PageReference pr = System.currentPageReference();

        pickListOptions = MMSMSTemplates.getTableFieldPickList(this.attributeRecord, this.attributeName);
        
        return pickListOptions;
    }
    public PageReference getFieldListJson() {
        string json = '[';
        
        json += '';
        
        json += ']';
        return null;
    }
    public PageReference getPickListJson() {
        this.attributeRecord = Apexpages.currentPage().getParameters().get('tableNameParam');
        this.attributeName = Apexpages.currentPage().getParameters().get('fieldNameParam');        
        return null;
    }
}