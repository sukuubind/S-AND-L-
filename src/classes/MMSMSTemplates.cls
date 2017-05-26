public class MMSMSTemplates {
    public static integer AFFILIATION = 1;
    public static integer OPPORTUNITY = 2;
    public static List<MMSMSTemplatesSchema> getSchema() {
        List<MMSMSTemplatesSchema> tables = new List<MMSMSTemplatesSchema>();
        MMSMSTemplatesSchema table = null;
        Map<String, Schema.SObjectType> sch = null;
        Schema.DescribeSObjectResult descTable = null;
        DescribeFieldResult descField = null;
        Map<String, Schema.SObjectField> fields = null;
        boolean fdescStatus = false;
        try {
            sch = Schema.getGlobalDescribe();
            for(string key : sch.keySet()) {
                descTable = sch.get(key).getDescribe();
                if (descTable != null && descTable.isQueryable() && descTable.isSearchable() && !descTable.isCustomSetting()) {
                    table = new MMSMSTemplatesSchema();
                    if (descTable.getName() == 'Contact' || descTable.getName() == 'Opportunity') {
                        table.setTableName(descTable.getName());
                        table.setTableLabel(descTable.getLabel());
                        tables.add(table);
                    }
                }
            }
            tables = MMSMSTemplatesSchema.sortTables(tables);
        }
        catch(Exception e) {

        }
        return tables;
    }
    public static MMSMSTemplatesSchema getTableFields(string tableName) {
        MMSMSTemplatesSchema  table = new MMSMSTemplatesSchema();
        Map<String, Schema.SObjectType> sch = null;
        Schema.DescribeSObjectResult descTable = null;
        DescribeFieldResult descField = null;
        Map<String, Schema.SObjectField> fields = null;
        try {
            sch = Schema.getGlobalDescribe();
            for(string key : sch.keySet()) {
                descTable = sch.get(key).getDescribe();
                if (descTable != null && descTable.isQueryable() && descTable.isSearchable()) {
                    if (descTable.getName() == tableName) {
                        table.setTableName(descTable.getName());
                        table.setTableLabel(descTable.getLabel());
                        table.initFields();
                        fields = descTable.fields.getMap();
                        for (string kf : fields.keySet()) {
                            descField = fields.get(kf).getDescribe();
                            table.addField(descField);
                        }
                        table = MMSMSTemplatesSchema.sortTableFields(table);
                        break;
                    }
                }
            }
        }
        catch(Exception e) {

        }
        return table;
    }
    
    public static MMSMSTemplatesSchema getAfFields() {
        return getOpAfFields('af');        
    }
    
    public static MMSMSTemplatesSchema getOpFields() {
        return getOpAfFields('op');        
    }
    
    public static MMSMSTemplatesSchema getOpAfFields(String type) {
        MMSMSTemplatesSchema  table = new MMSMSTemplatesSchema();
        Map<String, Schema.SObjectField> fields = type == 'af' ? Schema.SObjectType.Contact.fields.getMap() : Schema.SObjectType.Opportunity.fields.getMap();
        DescribeFieldResult descField = null;
        for (string kf : fields.keySet()) {
            descField = fields.get(kf).getDescribe();
            table.addField(descField);
        }
        return table;
    }
    
    public static List<SelectOption> getTableFieldPickList(string tableName, string fieldName) {
        Map<String, Schema.SObjectType> sch = null;
        Schema.DescribeSObjectResult descTable = null;
        DescribeFieldResult descField = null;
        Map<String, Schema.SObjectField> fields = null;
        List<SelectOption> pickList = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = null;
        try {
            sch = Schema.getGlobalDescribe();
            for(string key : sch.keySet()) {
                descTable = sch.get(key).getDescribe();
                if (descTable != null && descTable.isQueryable() && descTable.isSearchable()) {
                    if (descTable.getName() == tableName) {
                        fields = descTable.fields.getMap();
                        for (string kf : fields.keySet()) {
                            descField = fields.get(kf).getDescribe();
                            if (descField.getName() == fieldName) {
                                ple = descField.getPicklistValues();
                                for(Schema.PicklistEntry f : ple) {
                                    pickList.add(new SelectOption(f.getLabel(), f.getValue()));
                                }   
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }
        catch(Exception e) {

        }
        return pickList;
    }
    public static List<MMSMSTemplate__c> getAvailableTemplates() {
        List<MMSMSTemplate__c> templates = [select Id, TemplateName__c, Template__c from MMSMSTemplate__c];
        return templates;
    }
    public static MMSMSTemplate__c getTemplate(Id templateId) {
        MMSMSTemplate__c template = [select Id, TemplateName__c, Template__c from MMSMSTemplate__c where Id = :templateId];
        return template;
    }
    
    public static String getTemplateContent(Id templateId) {
        MMSMSTemplate__c template = [select Id, TemplateName__c, Template__c from MMSMSTemplate__c where Id = :templateId];
        return template.Template__c;
    }
    
    public static string getMergedText(integer entityType, Id entityId, string message) {
        if (entityType == AFFILIATION) {
            string[] fieldParts = null;
            string fieldName = '';
            string queryString = 'select ';
            MMSMSTemplatesSchema tbl = getAfFields();
            List<MMSMSTemplatesSchemaField> fields = tbl.getFields();
            for (MMSMSTemplatesSchemaField field : fields) {
                if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Contact.' + field.getName() + ']') >= 0) {
                    if (queryString != 'select ') {
                        queryString = queryString + ', ';
                    }
                    queryString = queryString + field.getName().replace('->', '.');
                }
            }
            queryString = queryString + ' from Contact where Id = \'' + entityId + '\'';
            Contact c = Database.query(queryString);
            for (MMSMSTemplatesSchemaField field : fields) {
                fieldName = field.getName();
                if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Contact.' + field.getName() + ']') >= 0) {
                    if (fieldName.indexOf('->') > 0) {
                        fieldParts = fieldName.split('->');
                        message = message.replace('[!Contact.' + field.getName() + ']', string.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1])));
                    }
                    else {
                        message = message.replace('[!Contact.' + field.getName() + ']', string.valueOf(c.get(field.getName())));
                    }
                }
            }
        }
        else if (entityType == OPPORTUNITY) {
            string[] fieldParts = null;
            string fieldName = '';
            string queryString = 'select ';
            MMSMSTemplatesSchema tbl = getOpFields();
            List<MMSMSTemplatesSchemaField> fields = tbl.getFields();
            for (MMSMSTemplatesSchemaField field : fields) {
                if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Opportunity.' + field.getName() + ']') >= 0) {
                    if (queryString != 'select ') {
                        queryString = queryString + ', ';
                    }
                    queryString = queryString + field.getName().replace('->','.');
                }
            }
            queryString = queryString + ' from Opportunity where Id = \'' + entityId + '\'';
            Opportunity c = Database.query(queryString);
            for (MMSMSTemplatesSchemaField field : fields) {
                fieldName = field.getName();
                if (!MMUtils.stringEmptyNull(fieldName) && message.indexOf('[!Opportunity.' + fieldName + ']') >= 0) {
                    if (fieldName.indexOf('->') > 0) {
                        fieldParts = fieldName.split('->');
                        message = message.replace('[!Opportunity.' + field.getName() + ']', string.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1])));
                    }
                    else {
                        message = message.replace('[!Opportunity.' + field.getName() + ']', string.valueOf(c.get(fieldName)));
                    }
                }
            }
        }
        return message;
    }
    
    public static List<SelectOption> getFieldValuePairs(string entityType, Id entityId, string message) {
        List<SelectOption> pairs = new List<SelectOption>();
        string fvalue = '';
        if (entityType == 'af') {
            string queryString = 'select ';
            MMSMSTemplatesSchema tbl = getAfFields();
            List<MMSMSTemplatesSchemaField> fields = tbl.getFields();
            for (MMSMSTemplatesSchemaField field : fields) {
                if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Contact.' + field.getName() + ']') >= 0) {
                    if (queryString != 'select ') {
                        queryString = queryString + ', ';
                    }
                    queryString = queryString + field.getName().replace('->', '.');
                }
            }
            if (queryString.length() > 7) {
                String fieldName = '';
                List<string> fieldParts = null;
                queryString = queryString + ' from Contact where Id = \'' + entityId + '\'';
                Contact c = Database.query(queryString);
                for (MMSMSTemplatesSchemaField field : fields) {
                    if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Contact.' + field.getName() + ']') >= 0) {
                        fieldName = field.getName();
                        if (fieldName.indexOf('->') > 0) {
                            fieldParts = fieldName.split('->');
                            fvalue = string.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1]));
                        }
                        else {
                            fvalue = string.valueOf(c.get(fieldName));
                        }
                        fvalue = MMUtils.stringEmptyNull(fvalue) ? '' : fvalue;
                        pairs.add(new SelectOption(fvalue,'[!Contact.' + field.getName() + ']'));
                    }
                }
            }
        }
        else if (entityType == 'op') {
            string queryString = 'select ';
            MMSMSTemplatesSchema tbl = getOpFields();
            List<MMSMSTemplatesSchemaField> fields = tbl.getFields();
            for (MMSMSTemplatesSchemaField field : fields) {
                if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Opportunity.' + field.getName() + ']') >= 0) {
                    if (queryString != 'select ') {
                        queryString = queryString + ', ';
                    }
                    queryString = queryString + field.getName().replace('->', '.');
                }
            }
            if (queryString.length() > 7) {
                queryString = queryString + ' from Opportunity where Id = \'' + entityId + '\'';
                Opportunity c = Database.query(queryString);
                String fieldName = '';
                List<string> fieldParts = null;
                for (MMSMSTemplatesSchemaField field : fields) {
                    if (!MMUtils.stringEmptyNull(field.getName()) && message.indexOf('[!Opportunity.' + field.getName() + ']') >= 0) {
                        fieldName = field.getName();
                        if (fieldName.indexOf('->') > 0) {
                            fieldParts = fieldName.split('->');
                            fvalue = string.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1]));
                        }
                        else {
                            fvalue = string.valueOf(c.get(fieldName));
                        }
                        fvalue = MMUtils.stringEmptyNull(fvalue) ? '' : fvalue;
                        pairs.add(new SelectOption(fvalue,'[!Opportunity.' + fieldName + ']'));                
                    }
                }
            }
        }
        return pairs;
    }
    
    public Static String getTemplateQuery(String message, List<String> extractedFields, List<String> selectedCandidates, String type){
        boolean hasOp = false;
        boolean hasAf = false;  
        String[] fields = new List<String>();
        Integer startIndex = -1;
        List<MMSMSTemplatesSchemaField> contactFields = MMSMSTemplates.getAfFields().getFields();
        List<MMSMSTemplatesSchemaField> opportunityFields = MMSMSTemplates.getOpFields().getFields();
        
        String contactFieldsStr = '';
        String opFieldsStr = '';
        
        for(MMSMSTemplatesSchemaField fld : contactFields)
            contactFieldsStr += fld.getName() + ','; 
        
        for(MMSMSTemplatesSchemaField fld : opportunityFields)
            opFieldsStr += fld.getName() + ',';
        
        startIndex = message.indexOf('[!');
        //message.replaceFirst('\\[','#');        
        
        while( startIndex != -1 ){
            Integer endIndex = message.indexOf(']',startIndex);
            String field = endIndex >= 0 ? message.substring(startIndex+2,endIndex) : '';
            if(field.contains('Contact.')) hasAf = true;
            if(field.contains('Opportunity.')) hasOp = true; 
            if (field.length() > 0)
                fields.add(field);                             
            message = message.replaceFirst('\\[!','#');
            message = message.replaceFirst('\\]','#');
            startIndex = message.indexOf('[!');
        }        
        
        if(fields.size() == 0) return null;       
        
        String query = 'Select Id , ';
        Boolean isFirst = true;
        for(Integer i = 0; i < fields.size() ; i++){ 
            if((fields[i].contains('Opportunity.') && ( type == 'af' || !opFieldsStr.contains(fields[i].split('\\.')[1] + ',')))
                || ( fields[i].contains('Contact.') && !contactFieldsStr.contains(fields[i].split('\\.')[1] + ',')))
                         continue;
                         
            if(fields[i].contains('Opportunity.')){
                if(query.contains(fields[i])){
                    extractedFields.add(fields[i]);
                    continue;
                }
            } else {
                if(type == 'op'){
                    if(query.contains(fields[i].replace('Contact.','Student__r.'))){
                        extractedFields.add(fields[i]);
                        continue;
                    } else if(query.contains(fields[i])) {
                        extractedFields.add(fields[i]);
                        continue;
                    }
                } else {
                    if(query.contains(fields[i])) {
                        extractedFields.add(fields[i]);
                        continue;
                    }
                }
            }
            query += (isFirst)?'':' , ';
            if(isFirst) isFirst = false;
            query += (fields[i].contains('Opportunity.'))? fields[i].replace('->', '.')
                        :(type=='op'?fields[i].replace('Contact.','Student__r.').replace('->', '.') : fields[i].replace('->', '.'));            
            extractedFields.add(fields[i]);
        }
        
        if(isFirst) return null;
        
        query += type=='op'? ' from Opportunity' : ' from Contact';
        
        query += ' where Id in ( ';
        
        isFirst = true;
        
        for(String cand : selectedCandidates){
            query += isFirst? '' : ', ';
            isFirst = false;
            query += '\'' + cand + '\' ';
        }
        
        query += ' ) ';
        
        return query;
    }
    
    public static String getTemplateMessage(String id, String tMessage, List<SObject> tObjects, List<String> extractedFields, String src){        
        if(tObjects == null) return tMessage;
        //return tMessage;
        List<string> fieldParts = null;
        for(SObject obj : tObjects) {
            if(obj.get('Id') != id) continue;             
            integer len = 0;
            for(String field : extractedFields){
                String fname = '';
                if(field.contains('Contact.')){
                    if(src == 'op'){
                        fname = field.replace('Contact.','Student__r.');
                    } else {
                        fname = field.split('\\.')[1];
                    }
                } else {
                    fname = field.split('\\.')[1];
                }
                if(fname.contains('Student__r.')){
                    fname = field.split('\\.')[1];
                    Contact c = ((Opportunity)(obj)).student__r;               
                    //len += String.valueOf(c.get(fname)).length();
                    if (fname.indexOf('->') > 0) {
                        fieldParts = fname.split('->');
                        tMessage = tMessage.replace('[!' + field + ']', MMUtils.filterNull(String.valueOf(c.getSObject(fieldParts[0]).get(fieldParts[1]))));
                    }
                    else {
                        tMessage = tMessage.replace('[!' + field + ']', MMUtils.filterNull(String.valueOf(c.get(fname))));
                    }
                } else {
                    //fname = field.split('\\.')[1];
                    //len += filterNull(String.valueOf(obj.get(fname))).length();
                    if (fname.indexOf('->') > 0) {
                        fieldParts = fname.split('->');
                        tMessage = tMessage.replace('[!' + field + ']', MMUtils.filterNull(String.valueOf(obj.getSObject(fieldParts[0]).get(fieldParts[1]))));
                    }
                    else {
                        tMessage = tMessage.replace('[!' + field + ']', MMUtils.filterNull(String.valueOf(obj.get(fname))));
                    }
                }
            }
            break;
        }
        return tMessage;
    }
}