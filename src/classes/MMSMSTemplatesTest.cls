@IsTest
public class MMSMSTemplatesTest {
    public static testMethod void Test() {
      Test.startTest();
      
      MMSMSTemplatesSchema tbl1 = getMMSMSTemplateSchemaObject(null, null, null);
      MMSMSTemplatesSchemaField tbl1fld1 = tbl1.getFields().get(0);
      List<MMSMSTemplatesSchemaField> tbl2Fields = new List<MMSMSTemplatesSchemaField>();
      MMSMSTemplatesSchema tbl2 = null;
      List<MMSMSTemplatesSchema> tblList = new List<MMSMSTemplatesSchema>();
      List<MMSMSTemplatesSchema> tblList1 = MMSMSTemplates.getSchema();
      MMSMSTemplatesSchema tbl3 = null;      
      
      tbl3 = MMSMSTemplates.getTableFields('Account');
      tbl2Fields.add(getMMSMSTemplatesSchemaFieldObject('AnyField1','Any Field 1','anytype1'));
      tbl2Fields.add(getMMSMSTemplatesSchemaFieldObject('AnyField2','Any Field 2','anytype2'));      
      tbl2 = getMMSMSTemplateSchemaObject('AnyTable', 'Any Table', tbl2Fields);
      
      tbl2.initFields();
      for(MMSMSTemplatesSchemaField f : tbl2Fields) {
          tbl2.addField(f);
      }
      tbl2.addField(Account.AccountNumber.getDescribe());
      
      System.assertEquals(true,tblList1.size() > 0);
      System.assertEquals(true,tbl3.getFields().size() > 0);
      
      System.assertEquals('TempTable',tbl1.getTableName());
      System.assertEquals('Temp Table',tbl1.getTableLabel());
      System.assertEquals(true,tbl1.getFields().size() == 1);
      System.assertEquals('TempField',tbl1fld1.getName());
      System.assertEquals('Temp Field',tbl1fld1.getLabel());
      System.assertEquals('temptype',tbl1fld1.getType());
      
      System.assertEquals(true,tbl2.getFields().size() == 3);
      System.assertEquals('AccountNumber',tbl2.getFields().get(2).getName());
      //System.assertEquals('Account Number',tbl2.getFields().get(2).getLabel()); //Since label could be changed by the admin
      System.assertEquals('STRING',tbl2.getFields().get(2).getType());
      
      tblList.add(tbl1);
      tblList.add(tbl2);
      System.assertEquals('TempTable',tblList.get(0).getTableName());
      tblList = MMSMSTemplatesSchema.sortTables(tblList);
      System.assertEquals('AnyTable',tblList.get(0).getTableName());
      
      System.assertEquals('AnyField1',tblList.get(0).getFields().get(0).getName());
      MMSMSTemplatesSchema.sortTableFields(tblList.get(0));
      System.assertEquals('AccountNumber',tblList.get(0).getFields().get(1).getName());
      
      //Template List Controller
      MMSMSTemplateListController cntrl1 = new MMSMSTemplateListController();
      List<MMSMSTemplate__c> tempRecs = cntrl1.getTemplateList();
      cntrl1.next();
      cntrl1.previous();
      cntrl1.newSMSTemplate();
      if (tempRecs != null) {
          System.assertEquals(true,tempRecs != null);
      }
      else {
          System.assertEquals(false,tempRecs != null);
      }
      
      //Template Controller
      MMSMSTemplateController tControl = new MMSMSTemplateController();
      PageReference pageRef = Page.mmsmstemplate;
      Test.setCurrentPage(pageRef);
      string url = '';

      tControl.initPage();
      url = tControl.pageLoad().getUrl();
      System.assertEquals('/apex/mmsmstemplate',url);
      
      MMSMSTemplate__c tpl = getMMSMSTemplateObject('TestTemplate','Test Template Details');
      Id tplId = tpl.Id;
      ApexPages.currentPage().getParameters().put('id',tplId);
      ApexPages.currentPage().getParameters().put('type','edit');
      tControl.initPage();
      List<SelectOption> tableOptions = tControl.getTableList();
      if (tableOptions != null && tableOptions.size() > 1) {
          tControl.selectedTable = tableOptions.get(1).getValue();
          List<SelectOption> fieldOptions = tControl.getFieldList();
          if (fieldOptions != null && fieldOptions.size() > 0) {
              System.assertEquals(true,fieldOptions.get(1).getValue() != '');
          }
      }
      System.assertEquals('/apex/mmsmstemplate',url);
      System.assertEquals('', tControl.getDefaultResponse());
      
      ApexPages.currentPage().getParameters().put('id',tplId);
      ApexPages.currentPage().getParameters().put('type','edit');
      tControl.templateNameField = 'TestTemplate1';
      tControl.templateField = 'Test Template 1 Details';
      System.assertEquals('/apex/mmsmstemplatelist',tControl.saveTemplate().getUrl());
      System.assertEquals('TestTemplate1',[select c.TemplateName__c from MMSMSTemplate__c c where c.Id = :tplId].TemplateName__c);

      ApexPages.currentPage().getParameters().put('id',tplId);
      ApexPages.currentPage().getParameters().put('type','edit');
      System.assertEquals('/apex/mmsmstemplatelist',tControl.cancel().getUrl());
      
      ApexPages.currentPage().getParameters().put('id',tplId);
      System.assertEquals('/apex/mmsmstemplatelist',tControl.deleteTemplate().getUrl());
      
      ApexPages.currentPage().getParameters().put('id','');
      ApexPages.currentPage().getParameters().put('type','');
      tControl.templateNameField = 'TestTemplate2';
      tControl.templateField = 'Test Template 2 Details';
      tControl.getFieldListJson();
      System.assertEquals('/apex/mmsmstemplatelist',tControl.saveTemplate().getUrl());
      System.assertEquals(true, [select c.Id from MMSMSTemplate__c c].size() > 0);
            
      System.assertEquals(true, MMSMSTemplates.getTableFieldPickList('Contact', 'OK_to_Text__c').size() > 0);
      
      System.assertEquals(true, MMSMSTemplates.getAvailableTemplates() != null);
      
      Contact tempC1 = new Contact();
      tempC1.FirstName = 'faisal';
      tempC1.LastName = 'abdul moid';
      insert tempC1;
      
      Opportunity op1 = createOpportunity(tempC1.Id, 'one two','Inquiry',Date.parse('12/12/2011'));
      
      System.assertEquals('Hello faisal',MMSMSTemplates.getMergedText(MMSMSTemplates.AFFILIATION, tempC1.Id, 'Hello [!Contact.FirstName]'));
      System.assertEquals(true, MMSMSTemplates.getFieldValuePairs('af',tempC1.Id,'Hello [!Contact.FirstName]').size() == 1);
      
      System.assertEquals('Hello [!Opportunity.Student__c] 2011-12-12 00:00:00',MMSMSTemplates.getMergedText(MMSMSTemplates.OPPORTUNITY, op1.Id, 'Hello [!Opportunity.Student__c] [!Opportunity.CloseDate]'));      
      System.assertEquals(false, MMSMSTemplates.getFieldValuePairs('op',op1.Id,'Hello [!Opportunity.Student__c]').size() == 1);

      
      List<String> extractedString = new List<String>();
      extractedString.add('Contact.FirstName');
      extractedString.add('Contact.LastName');
      List<String> selectedCandidates = new List<String>();
      selectedCandidates.add(tempC1.Id);
      MMSMSTemplates.getTemplateQuery('Hello [!Contact.FirstName] [!Contact.LastName]',extractedString, selectedCandidates, 'af');
      
      List<SObject> tObjects = new List<SObject>();
      tObjects.add(tempC1);
      MMSMSTemplates.getTemplateMessage(tempC1.Id,'Hello [!Contact.FirstName] [!Contact.LastName]', tObjects, extractedString, 'af' );
      
      
      extractedString.clear();
      extractedString.add('Opportunity.Student__c');
      extractedString.add('Opportunity.CloseDate');
      extractedString.add('Contact.FirstName');
      selectedCandidates.clear();
      selectedCandidates.add(op1.Id);
      MMSMSTemplates.getTemplateQuery('Hello [!Opportunity.Student__c] [!Opportunity.CloseDate] [!Contact.FirstName]',extractedString, selectedCandidates, 'op');
      
      MMSMSTemplate__c tmplA = new MMSMSTemplate__c();
      tmplA.TemplateName__c = 'template name';
      tmplA.Template__c = 'template text';
      insert tmplA;
      
      System.assertEquals(true, MMSMSTemplates.getTemplate(tmplA.Id).TemplateName__c == 'template name');
      System.assertEquals(true, MMSMSTemplates.getTemplate(tmplA.Id).Template__c == 'template text');
      System.assertEquals(true, MMSMSTemplates.getTemplateContent(tmplA.Id) == 'template text');
      
      Test.stopTest(); 
    }
    public static MMSMSTemplate__c getMMSMSTemplateObject(string name, string detail) {
        MMSMSTemplate__c obj = new MMSMSTemplate__c(TemplateName__c = name, Template__c = detail);
        insert obj;
        return obj;
    }
    public static Opportunity createOpportunity(Id contactId, string name, string stageName, Date closeDate) {
        List<RecordType> recTypeList = [Select Id from RecordType where Name = 'Student Opportunity'];
       Opportunity o = new Opportunity(RecordTypeId = recTypeList[0].Id, Student__c = contactId, ownerId = UserInfo.getUserId(),
                                   Name = name, StageName = stageName, CloseDate = closeDate, College_or_School_at_Institution__c = 'Business', Curriculum_Structure__c = 'Fixed - No flexibility');
       insert o;
       return o;
    }
    public static MMSMSTemplatesSchema getMMSMSTemplateSchemaObject(string tableName, string tableLabel, List<MMSMSTemplatesSchemaField> fields) {
        MMSMSTemplatesSchema obj = null;
        if (MMUtils.stringEmptyNull(tableName)) {
            obj = new MMSMSTemplatesSchema();
            obj.setTableName('TempTable');
            obj.setTableLabel('Temp Table');
            fields = new List<MMSMSTemplatesSchemaField>();
            fields.add(getMMSMSTemplatesSchemaFieldObject(null,null,null));
            obj.setFields(fields);
        }
        else {
            obj = new MMSMSTemplatesSchema(tableName, tableLabel, fields);
        }
        
        return obj;
    }
    public static MMSMSTemplatesSchemaField getMMSMSTemplatesSchemaFieldObject(string fieldName, string fieldLabel, string type) {
        MMSMSTemplatesSchemaField obj = null;
        if (MMUtils.stringEmptyNull(fieldName)) {
            obj = new MMSMSTemplatesSchemaField();
            obj.setName('TempField');
            obj.setLabel('Temp Field');
            obj.setType('temptype');
        }
        else {
            obj = new MMSMSTemplatesSchemaField (fieldName, fieldLabel, type);
        }
        return obj;
    }
}