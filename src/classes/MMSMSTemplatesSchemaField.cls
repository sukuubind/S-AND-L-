public class MMSMSTemplatesSchemaField {
    private string name;
    private string label;
    private string type;
    public MMSMSTemplatesSchemaField() { }
    public MMSMSTemplatesSchemaField(string name, string label, string type) {
        this.name = name;
        this.type = type;
        this.label = label;
    }
    public string getName() { return this.name; }
    public void setName(string name) { this.name = name; }
    public string getLabel() { return this.label; }
    public void setLabel(string label) { this.label = label; }
    public string getType() { return this.type; }
    public void setType(string type) { this.type = type; }
}