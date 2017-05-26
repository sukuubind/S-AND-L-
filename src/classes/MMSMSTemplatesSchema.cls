public class MMSMSTemplatesSchema {
    private string tableName;
    private string tableLabel;
    private List<MMSMSTemplatesSchemaField> fields;
    public MMSMSTemplatesSchema() {
        fields = new List<MMSMSTemplatesSchemaField>();
    }
    public MMSMSTemplatesSchema(string tableName, string tableLabel, List<MMSMSTemplatesSchemaField> fields) {
        this.tableName = tableName;
        this.tableLabel = tableLabel;
        this.fields = fields;
    }
    public void setTableName(string tableName) {
        this.tableName = tableName;
    }
    public string getTableName() {
        return this.tableName;
    }
    public void setTableLabel(string tableLabel) {
        this.tableLabel = tableLabel;
    }
    public string getTableLabel() {
        return this.tableLabel;
    }
    public void setFields(List<MMSMSTemplatesSchemaField> fields) {
        this.fields = fields;
    }
    public List<MMSMSTemplatesSchemaField> getFields() {
        return this.fields;
    }
    public void initFields() {
        fields = new List<MMSMSTemplatesSchemaField>();
    }
    public void addField(MMSMSTemplatesSchemaField field) {
        this.fields.add(field);
    }
    public void addField(DescribeFieldResult dfr) {
        MMSMSTemplatesSchemaField field = new MMSMSTemplatesSchemaField();
        string rName = dfr.getRelationshipName();
        field.setName(rName == null ? dfr.getName() : (rName + '->Name'));
        field.setLabel(dfr.getLabel());
        field.setType(String.valueOf(dfr.getType()));
        this.fields.add(field);
    }
    public static List<MMSMSTemplatesSchema> sortTables(List<MMSMSTemplatesSchema> tables) {
        MMSMSTemplatesSchema[] tbl;
        MMSMSTemplatesSchema temp;
        integer index = 0;
        if (tables.size() > 0) {
            tbl = new MMSMSTemplatesSchema[tables.size()];
            for (MMSMSTemplatesSchema t : tables) {
                tbl[index] = t;
                index++;
            }
            for (integer j=0;j<tbl.size() - 1;j++) {
                for (integer k=j+1;k<tbl.size();k++) {
                    if (tbl[j].getTableLabel().toLowerCase() > tbl[k].getTableLabel().toLowerCase()) {
                        temp = tbl[j];
                        tbl[j] = tbl[k];
                        tbl[k] = temp;
                    }
                }
            }
            tables = new List<MMSMSTemplatesSchema>();
            for (MMSMSTemplatesSchema t : tbl) {
                tables.add(t);
            }
        }
        return tables;
    }
    public static MMSMSTemplatesSchema sortTableFields(MMSMSTemplatesSchema table) {
        List<MMSMSTemplatesSchemaField> origFields = null;
        MMSMSTemplatesSchemaField []arrField = null;
        MMSMSTemplatesSchemaField temp;
        integer index = 0;
        if (table != null && table.getFields() != null) {
            origFields = table.getFields();
            arrField = new MMSMSTemplatesSchemaField[origFields.size()];
            for (MMSMSTemplatesSchemaField m : origFields) {
                arrField[index] = m;
                index++;
            }
            for (integer j=0;j<arrField.size() - 1;j++) {
                for (integer k=j+1;k<arrField.size();k++) {
                    if (arrField[j].getName().toLowerCase() > arrField[k].getName().toLowerCase()) {
                        temp = arrField[j];
                        arrField[j] = arrField[k];
                        arrField[k] = temp;
                    }
                }
            }
            table.initFields();
            table.addField(new MMSMSTemplatesSchemaField('','--Select--',''));
            for (MMSMSTemplatesSchemaField m : arrField) {
                table.addField(m);
            }
        }
        return table;
    }
}