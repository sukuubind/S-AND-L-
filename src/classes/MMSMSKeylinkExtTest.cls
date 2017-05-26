@IsTest
public class MMSMSKeylinkExtTest {
    public static testMethod void Test() {
      
      /* FADI
        Test.startTest();
        
        Contact cnt = createAffiliation('f','m','03451231234');
        User usr = null;
        Id uId = null;
        List<Id> uIds = new List<Id>();
        string eml = null;
        MMSMSKeylink__c keyA = createKeywordA('folio123456');
        MMSMSKeylinkAttribute__c attrA = createAttribute('Contact', 'Country__c', 'picklist', 'Burma', keyA.Id);
        MMSMSKeylinkAttribute__c attrB = createAttribute('Contact', 'Birthdate', 'date', '01/01/2000', keyA.Id);
        MMSMSKeylinkAttribute__c attrD = createAttribute('Contact', 'Email', 'string', 'f@msn.com', keyA.Id);
        //System.assertEquals(true, MMSMSKeylinkUtil.getContactByPhone('3451231234').size() > 0);
        
        cnt = MMSMSKeylinkUtil.createDefaultAffiliation('923451212123','folio123456');
        System.assertEquals(true, cnt.MobilePhone == '923451212123');

        uId = UserInfo.getUserId();
        usr = MMSMSKeylinkUtil.getUserById(uId);
        eml = usr.Email;
        cnt = MMSMSKeylinkUtil.createDefaultAffiliation('923451212123','folio123456',usr);
        System.assertEquals(true, cnt.OwnerId == usr.Id);
        
        System.assertEquals(true, MMSMSKeylinkUtil.getUserByEmail(usr.Email).Id != null);
        
        MMSMSKeyLinkUtil.storeNonExistentKeylink(new List<Id>(), 'folio123456', '923451212122', usr, new ReplySMSController());
        uIds.add(cnt.Id);
        MMSMSKeyLinkUtil.storeNonExistentKeylink(uIds, 'folio123456', '923451212123', usr, new ReplySMSController());        
        
        //MMSMSKeyLinkUtil.storeExistentKeylink(uIds, 'folio123', '923451212123', usr, new ReplySMSController(), keyA);
        MMSMSKeyLinkUtil.storeExistentKeylink(new List<Id>(), 'folio123456', '923451212124', usr, new ReplySMSController(), keyA);
        //MMSMSKeyLinkUtil.storeExistentKeylink(new List<Id>(), 'folio123', '923451212125', usr, new ReplySMSController(), keyA);
        //MMSMSKeyLinkUtil.updateContactAttribute(cnt, keyA.Id);
        
        //MMSMSKeyLinkUtil.getDefaultKeylinkEmail();
        System.assertEquals(true, MMSMSKeylinkUtil.getKeywordLogCount('folio123456') > 0);
        
        Test.stopTest();  */
    }
    public static MMSMSKeylink__c createKeyword(string keyword) {
        MMSMSKeylink__c c = new MMSMSKeylink__c();
        c.Keyword__c = keyword;
        insert c;
        return c;
    }
    public static MMSMSKeylink__c createKeywordA(string keyword) {
        MMSMSKeylink__c c = new MMSMSKeylink__c();
        c.Keyword__c = keyword;
        c.IsActive__c = true;
        c.CreateAffliliation__c = true;
        c.CreateOpportunity__c = true;
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