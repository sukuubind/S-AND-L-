@IsTest
public class MMSMSKeylinkTest {
    public static testMethod void Test() {
        Test.startTest();
        
        Contact c1 = createAffiliation('john', 'murphy', '1245245245');
        Opportunity o1 = createOpportunity(c1.Id, 'jop1', 'New Inquiry', System.now().addDays(2000).date());
        MMSMSKeylink__c keyword = createKeyword('test1');
        MMSMSKeylink__c keyword1 = createKeyword('test2');
        MMSMSKeylinkAttribute__c attr1 = createAttribute('tbl1','fld1','type1','val1',keyword.Id);
        MMSMSKeylinkAttribute__c attr2 = createAttribute('tbl2','fld2','type2','val2',keyword.Id);
        
        System.assertEquals('test1',MMSMSKeylinkUtil.getMMSMSKeylink('test1').Keyword__c);
        System.assertEquals(true, MMSMSKeylinkUtil.getMMSMSKeylinkAttr(keyword.Id).size() == 2);
        
        //KeyLink list controller
        MMSMSKeylinkListController cntrl1 = new MMSMSKeylinkListController();
        List<MMSMSKeylink__c> keyList = cntrl1.getKeylinkList();
        System.assertEquals(true, keyList.size() > 0);

        //Keylink controller
        //Template Controller
        MMSMSKeylinkController cntrl2 = new MMSMSKeylinkController();
        PageReference pageRef = Page.mmsmskeylink;
        Test.setCurrentPage(pageRef);
        string url = '';
    
        cntrl2.initPage();
        url = cntrl2.pageLoad().getUrl();
        System.assertEquals('/apex/mmsmskeylink',url);
        
        ApexPages.currentPage().getParameters().put('id',keyword.Id);
        ApexPages.currentPage().getParameters().put('type','edit');
        cntrl2.initPage();
        url = cntrl2.pageLoad().getUrl();
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit',url);
        
        ApexPages.currentPage().getParameters().put('id',keyword.Id);
        ApexPages.currentPage().getParameters().put('type','edit');
        cntrl2.initPage();
        cntrl2.keyword = 'test123';
        System.assertEquals('/apex/mmsmskeylinklist', cntrl2.saveKeylink().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('type','');
        cntrl2.initPage();
        cntrl2.keyword = 'test1234';
        System.assertEquals('/apex/mmsmskeylinklist', cntrl2.saveKeylink().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('type','');
        cntrl2.initPage();
        cntrl2.keyword = '';
        System.assertEquals(true, cntrl2.getUserList().size() > 0);
        System.assertEquals(true,cntrl2.getFieldListJson() == null);
        System.assertEquals('/apex/mmsmskeylinklist', cntrl2.onCancel().getUrl());

        ApexPages.currentPage().getParameters().put('id',keyword1.Id);
        cntrl2.initPage();
        System.assertEquals('', cntrl2.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylinklist', cntrl2.deleteKeylink().getUrl());
    
        //Keylink attribute controller
        ApexPages.StandardController sc = new ApexPages.StandardController(attr1);
        MMSMSKeylinkAttributeController cntrl3 = new MMSMSKeylinkAttributeController(sc);
        pageRef = Page.mmsmskeylinkattribute;
        Test.setCurrentPage(pageRef);

        cntrl3.initPage();
        url = cntrl3.pageLoad().getUrl();
        System.assertEquals('/apex/mmsmskeylinkattribute',url);
        
        ApexPages.currentPage().getParameters().put('id',attr1.Id);
        cntrl3.initPage();
        url = cntrl3.pageLoad().getUrl();
        System.assertEquals('/apex/mmsmskeylinkattribute?id=' + attr1.Id,url);
        
        ApexPages.currentPage().getParameters().put('id',attr1.Id);
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        cntrl3.initPage();
        System.assertEquals(true, cntrl3.getTableList().size() > 0);
        cntrl3.selectedTable = 'Contact';
        System.assertEquals(true, cntrl3.getFieldList().size() > 0);
        System.assertEquals(true, cntrl3.getFieldListJson() == null);
        ApexPages.currentPage().getParameters().put('tableNameParam','Contact');
        ApexPages.currentPage().getParameters().put('fieldNameParam','Country__c');
        System.assertEquals(true, cntrl3.getPickListJson() == null);
        System.assertEquals(true, cntrl3.getPickList().size() > 0);
        System.assertEquals('/apex/mmsmskeylinkattrlist?id=' + keyword.Id + '&type=edit',cntrl3.cancel().getUrl());
        
        ApexPages.currentPage().getParameters().put('id',attr1.Id);
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Contact';
        cntrl3.attributeName = 'Country__c';
        cntrl3.attributeType = 'picklist';
        cntrl3.attributePickList = 'Argentina';
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Contact';
        cntrl3.attributeName = 'Country__c';
        cntrl3.attributeType = 'picklist';
        cntrl3.attributePickList = 'Argentina';
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Opportunity';
        cntrl3.attributeName = 'IsPrivate';
        cntrl3.attributeType = 'boolean';
        cntrl3.attributeBooleanValue = true;
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());

        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Opportunity';
        cntrl3.attributeName = 'Probability';
        cntrl3.attributeType = 'double';
        cntrl3.attributeValue = '20';
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Opportunity';
        cntrl3.attributeName = 'CloseDate';
        cntrl3.attributeType = 'date';
        cntrl3.attributeDateValue = '1/1/2020';
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Opportunity';
        cntrl3.attributeName = 'TotalOpportunityQuantity';
        cntrl3.attributeType = 'integer';
        cntrl3.attributeValue = '1';
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());

        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('keyId',keyword.Id);
        ApexPages.currentPage().getParameters().put('retURL','/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit');
        cntrl3.initPage();
        cntrl3.attributeRecord = 'Opportunity';
        cntrl3.attributeName = 'Description';
        cntrl3.attributeType = 'string';
        cntrl3.attributeValue = 'test';
        System.assertEquals('', cntrl3.getDefaultResponse());
        System.assertEquals('/apex/mmsmskeylink?id=' + keyword.Id + '&type=edit', cntrl3.saveKeylinkAttribute().getUrl());
        
        MMSMSKeylinkUtil.updateOpportunityAttribute(o1, keyword.Id);
        
        
        System.assertEquals(true, MMSMSKeylinkUtil.getKeywordCount('xyz123xyz') == 0);
        System.assertEquals(true, MMSMSKeylinkUtil.getZeroPrefixedNumber('1',4,1) == '0002');
        
        Test.stopTest(); 
    }
    public static Opportunity createOpportunity(Id contactId, string name, string stageName, Date closeDate) {
        List<RecordType> recTypeList = [Select Id from RecordType where Name = 'Student Opportunity'];
       Opportunity o = new Opportunity(RecordTypeId = recTypeList[0].Id, Student__c = contactId, ownerId = UserInfo.getUserId(),
                                   Name = name, StageName = stageName, CloseDate = closeDate, College_or_School_at_Institution__c = 'Business', Curriculum_Structure__c = 'Fixed - No flexibility');
       insert o;
       return o;
    }
    
    public static MMSMSKeylink__c createKeyword(string keyword) {
        MMSMSKeylink__c c = new MMSMSKeylink__c();
        c.Keyword__c = keyword;
        insert c;
        return c;
    }
    public static MMSMSKeylinkAttribute__c createAttribute(string table, string field, string type, string val, Id id) {
        MMSMSKeylinkAttribute__c c = new MMSMSKeylinkAttribute__c();
        c.AttributeRecord__c = table;
        c.AttributeName__c = field;
        c.AttributeType__c = type;
        c.AttributeValue__c = val;
        c.MMSMSKeylink__c = id;
        insert c;
        return c;
    }
    public static Contact createAffiliation(string fname, string lname, string phone) {
       Contact c = new Contact(FirstName = fname, LastName = lname, MobilePhone = phone);
       insert c;
       return c;
    }
}