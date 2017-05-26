public class MMSMSKeylinkUtil {
    public static long KEYWORD_BATCH_COUNT = 3;
    public static MMSMSKeylink__c getMMSMSKeylink(string keyword) {
        MMSMSKeylink__c rec = null;
        try {
            rec = [select Keyword__c, NotifyTo__c, IsActive__c, CreateAffliliation__c, CreateOpportunity__c from MMSMSKeylink__c where Keyword__c = :keyword limit 1];
        }
        catch(QueryException e) {
            rec = null;
        }
        return rec;
    }
    public static List<MMSMSKeylinkAttribute__c> getMMSMSKeylinkAttr(Id keyId) {
        List<MMSMSKeylinkAttribute__c> listAttr = null;
        try {
            listAttr = [select AttributeName__c, AttributeRecord__c, AttributeType__c, AttributeValue__c, MMSMSKeylink__c from MMSMSKeylinkAttribute__c where MMSMSKeylink__c = :keyId];
        }
        catch(QueryException e) {
            listAttr = null;
        }
        return listAttr;
    }
    public static long getKeywordCount(string keyword) {
        long cnt = 0;
        
        try {
            SObject obj = [select count(Id) countId from MM_SMS_Log__c
                                    where SMSType__c = 'Keylink' and
                                    KeylinkKeyword__c = :keyword];
            cnt = (long)obj.get('countId');
        }
        catch(Exception exp) {
        }
        
        return cnt;
    }
    public static string getZeroPrefixedNumber(string num, integer digit, long incrDecr) {
        long n = Long.valueOf(num) + incrDecr;
        string str = '' + n;
        
        while (str.length() < 4) {
            str = '0' + str;
        }
        
        return str;
    }
    public static string getAdjustedKeyword(string keyword) {
        string aKey = '';
        long cnt = 0;
        List<SObject> recs = null;
        SObject rec = null;
        string sNum = '';
    
        try {
            recs = [select KeylinkKeyword__c keyword, count(Id) countId from MM_SMS_Log__c
                                    where SMSType__c = 'Keylink' and
                                        KeylinkKeyword__c like :keyword + '%'
                                    group by KeylinkKeyword__c
                                    order by KeylinkKeyword__c ASC];
            if (recs != null && recs.size() > 0) {
                rec = recs[recs.size() - 1];
                cnt = (long)rec.get('countId');
                aKey = (string)rec.get('keyword');
                if (cnt >= KEYWORD_BATCH_COUNT) {
                    if (aKey.split('-').size() > 1) {
                        sNum = aKey.split('-')[1];
                        aKey = aKey.split('-')[0] + '-' + getZeroPrefixedNumber(sNum, 4, 1);
                    }
                    else {
                        aKey = aKey + '-0001';
                    }
                }
            }
            else {
                aKey = keyword;
            }
            
        }
        catch(Exception exp) {
            aKey = keyword;
        }
        
        return aKey;
    }
    public static List<Id> getContactByPhone(string ph) {
        string mPhone;
        string hPhone;
        string oPhone;
        string phone;
        string aPhone;
        List<Id> contactIds = new List<Id>();
        for (Contact cs : [select Id,MobilePhone_F__c,HomePhone_F__c,OtherPhone_F__c,Phone_F__c,
                                                AlternatePhone_F__c from Contact
                                                    where MobilePhone_F__c = :ph or
                                                        HomePhone_F__c = :ph or
                                                        OtherPhone_F__c = :ph or
                                                        Phone_F__c = :ph or
                                                        AlternatePhone_F__c = :ph]) {
            mPhone = MMUtils.stringEmptyNull(cs.MobilePhone_F__c) ? '' : cs.MobilePhone_F__c;
            hPhone = MMUtils.stringEmptyNull(cs.HomePhone_F__c) ? '' : cs.HomePhone_F__c;
            oPhone = MMUtils.stringEmptyNull(cs.OtherPhone_F__c) ? '' : cs.OtherPhone_F__c;
            phone = MMUtils.stringEmptyNull(cs.Phone_F__c) ? '' : cs.Phone_F__c;
            aPhone = MMUtils.stringEmptyNull(cs.AlternatePhone_F__c) ? '' : cs.AlternatePhone_F__c;
            if ((ph.indexOf(mPhone) >= 0 && !MMUtils.stringEmptyNull(mPhone)) || 
                (ph.indexOf(hPhone) >= 0 && !MMUtils.stringEmptyNull(hPhone)) || 
                (ph.indexOf(oPhone) >= 0 && !MMUtils.stringEmptyNull(oPhone)) || 
                (ph.indexOf(phone) >= 0 && !MMUtils.stringEmptyNull(phone)) ||
                (ph.indexOf(aPhone) >= 0 && !MMUtils.stringEmptyNull(aPhone))) {
                contactIds.add(cs.Id);
            }
            if(contactIds.size() > 0) break;
        }
        return contactIds;
    }
    public static Contact createDefaultAffiliation(string ph, string keywordMessage) {
        Contact c = new Contact();
        string country = MMUtils.getCountryByPhone(ph);
        string keyword = keywordMessage.split(' ').get(0);
        c.FirstName = String.valueOf(Datetime.now().getTime());
        c.LastName = keyword;
        c.Preferred_Phone__c = 'Mobile';
        c.Ok_To_Text__c = 'Yes';
        if (!MMUtils.stringEmptyNull(country)) {
            c.Country__c = country;
        }
        c.MobilePhone = ph;
        insert c;
        return c;
    }
    public static Contact createDefaultAffiliation(string ph, string keywordMessage, User usr) {
        Contact c = new Contact();
        string country = MMUtils.getCountryByPhone(ph);
        string keyword = keywordMessage.split(' ').get(0);
        c.FirstName = String.valueOf(Datetime.now().getTime());
        c.LastName = keyword;
        c.OwnerId = usr.Id;
        c.CreatedById = usr.Id;
        c.Preferred_Phone__c = 'Mobile';
        c.Ok_To_Text__c = 'Yes';
        if (!MMUtils.stringEmptyNull(country)) {
            c.Country__c = country;
        }
        c.MobilePhone = ph;
        insert c;
        return c;
    }
    public static Opportunity createDefaultOpportunity(Id contactId, string name, string stageName, Date closeDate, User usr) {
        List<RecordType> recTypeList = [Select Id from RecordType where Name = 'Student Opportunity'];
       Opportunity o = new Opportunity(RecordTypeId = recTypeList[0].Id, Student__c = contactId, ownerId = usr.Id,
                                   Name = name, StageName = stageName, CloseDate = closeDate, College_or_School_at_Institution__c = 'Business', Curriculum_Structure__c = 'Fixed - No flexibility');
       insert o;
       return o;
    }
    public static User getUserByEmail(string email) {
        User u = [select Id, FirstName, LastName, email from User where email = :email limit 1];
        return u;
    }
    public static User getUserById(Id i) {
        User u = [select Id, FirstName, LastName, email from User where Id = :i];
        return u;
    }
    public static string getDefaultKeylinkEmail() {
        return MMKeylinkSettings__c.getAll().values().get(0).NotifyTo__c;
    }
    public static void storeNonExistentKeylink(List<Id> ids, string message, string phone, User usr, ReplySMSController cntrl) {
        List<Contact> cRecs = null;
        Contact cRec = null;
        List<MM_SMS_Log__c> lgs = new List<MM_SMS_Log__c>();
        MM_SMS_Log__c lg = null;
        Task t = null;
        string emlMsg = null;
        if (ids.size() > 0) {
           cRecs = [select Id, FirstName, LastName from Contact where Id in :ids];
           for (Contact c : cRecs) {
               t = cntrl.createTask(c.Id, 'af', usr.Id, message, 'Keylink: ');
               lgs.add(MMUtilLog.createSMSLog(c.Id, 'af', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id));
           }
           insert lgs;
           emlMsg = cntrl.getEmailMessage(cRecs.get(0).LastName, cRecs.get(0).FirstName,
               usr.LastName, usr.FirstName, cRecs.get(0).Id, 'af', message, 'Keylink');
       }
       else {
           cRec = createDefaultAffiliation(phone, message, usr);
           t = cntrl.createTask(cRec.Id, 'af', usr.Id, message, 'Keylink: ');
           emlMsg = cntrl.getEmailMessage(cRec.LastName, cRec.FirstName, 
                                           usr.LastName, usr.FirstName, cRec.Id, 'af', message, 'Keylink');
           lg = MMUtilLog.createSMSLog(cRec.Id, 'af', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id);
           insert lg;
        }
        MMUtils.sendSingleEmail(usr.email, usr.FirstName + ' ' + usr.LastName, 'SMS Keylink Received', emlMsg, usr.Id);                           
    }
    public static void storeExistentKeylink(List<Id> ids, string message, string phone, User usr, ReplySMSController cntrl, MMSMSKeylink__c keylink) {
        List<Contact> cRecs = null;
        Contact cRec = null;
        Opportunity opRec = null;
        List<MM_SMS_Log__c> lgs = new List<MM_SMS_Log__c>();
        MM_SMS_Log__c lg = null;
        Task t = null;
        string emlMsg = null;
        if (ids.size() > 0) {
           cRecs = [select Id, FirstName, LastName from Contact where Id in :ids];
           for (Contact c : cRecs) {
               t = cntrl.createTask(c.Id, 'af', usr.Id, message, 'Keylink: ');
               lgs.add(MMUtilLog.createSMSLog(c.Id, 'af', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id));
           }
           insert lgs;
           emlMsg = cntrl.getEmailMessage(cRecs.get(0).LastName, cRecs.get(0).FirstName,
               usr.LastName, usr.FirstName, cRecs.get(0).Id, 'af', message, 'Keylink');
       }
       else {
           if (!keylink.IsActive__c) {
               cRec = createDefaultAffiliation(phone, message, usr);
               t = cntrl.createTask(cRec.Id, 'af', usr.Id, message, 'Keylink: ');
               emlMsg = cntrl.getEmailMessage(cRec.LastName, cRec.FirstName, 
                                               usr.LastName, usr.FirstName, cRec.Id, 'af', message, 'Keylink');
               lg = MMUtilLog.createSMSLog(cRec.Id, 'af', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id);
               insert lg;
            }
            else {
                if (keylink.CreateAffliliation__c) {
                    if (!MMUtils.stringEmptyNull(keylink.NotifyTo__c)) {
                        User usr1 = getUserById(keylink.NotifyTo__c);
                        if (usr1 != null) usr = usr1;
                    }
                    cRec = createDefaultAffiliation(phone, message, usr);
                    if (keylink.CreateOpportunity__c) {
                        opRec = createDefaultOpportunity(cRec.Id, cRec.FirstName + ' - op:' + cRec.LastName, 'New Inquiry', System.now().addDays(30).date(), usr);
                        t = cntrl.createTask(opRec.Id, 'op', usr.Id, message, 'Keylink: ');
                        emlMsg = cntrl.getEmailMessage(cRec.LastName, cRec.FirstName, 
                                               usr.LastName, usr.FirstName, cRec.Id, 'af', message, 'Keylink');
                        lg = MMUtilLog.createSMSLog(opRec.Id, 'op', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id);
                        insert lg;
                        updateContactAttribute(cRec, keylink.Id);
                        updateOpportunityAttribute(opRec, keylink.Id);
                    }
                    else {
                        t = cntrl.createTask(cRec.Id, 'af', usr.Id, message, 'Keylink: ');
                        emlMsg = cntrl.getEmailMessage(cRec.LastName, cRec.FirstName, 
                                               usr.LastName, usr.FirstName, cRec.Id, 'af', message, 'Keylink');
                        lg = MMUtilLog.createSMSLog(cRec.Id, 'af', null, null, phone, '0_a', false, null, 'Keylink', message, null, t.Id);
                        insert lg;
                        updateContactAttribute(cRec, keylink.Id);
                    }
                }
            }
        }
        MMUtils.sendSingleEmail(usr.email, usr.FirstName + ' ' + usr.LastName, 'SMS Keylink Received', emlMsg, usr.Id);                           
    }
    public static void updateContactAttribute(Contact c, Id keylinkId) {
        List<MMSMSKeylinkAttribute__c> attrs = null;
        attrs = getMMSMSKeylinkAttr(keylinkId);
        if (attrs != null && attrs.size() > 0) {
            for (MMSMSKeylinkAttribute__c attr : attrs) {
                if (attr.AttributeRecord__c == 'Contact') {
                    if (attr.AttributeType__c == 'boolean') {
                        c.put(attr.AttributeName__c, attr.AttributeValue__c == 'true' ? true : false);
                    }
                    else if (attr.AttributeType__c == 'integer') {
                        c.put(attr.AttributeName__c, Integer.valueOf(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'double') {
                        c.put(attr.AttributeName__c, Double.valueOf(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'date') {
                        c.put(attr.AttributeName__c, Date.parse(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'datetime') {
                        c.put(attr.AttributeName__c, Datetime.parse(attr.AttributeValue__c));
                    }
                    else {
                        c.put(attr.AttributeName__c, attr.AttributeValue__c);
                    }
                }
            }
            update c;
        }
    }
    public static void updateOpportunityAttribute(Opportunity c, Id keylinkId) {
        List<MMSMSKeylinkAttribute__c> attrs = null;
        attrs = getMMSMSKeylinkAttr(keylinkId);
        if (attrs != null && attrs.size() > 0) {
            for (MMSMSKeylinkAttribute__c attr : attrs) {
                if (attr.AttributeRecord__c == 'Opportunity') {
                    if (attr.AttributeType__c == 'boolean') {
                        c.put(attr.AttributeName__c, attr.AttributeValue__c == 'true' ? true : false);
                    }
                    else if (attr.AttributeType__c == 'integer') {
                        c.put(attr.AttributeName__c, Integer.valueOf(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'double') {
                        c.put(attr.AttributeName__c, Double.valueOf(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'date') {
                        c.put(attr.AttributeName__c, Date.parse(attr.AttributeValue__c));
                    }
                    else if (attr.AttributeType__c == 'datetime') {
                        c.put(attr.AttributeName__c, Datetime.parse(attr.AttributeValue__c));
                    }
                    else {
                        c.put(attr.AttributeName__c, attr.AttributeValue__c);
                    }
                }
            }
            update c;
        }
    }
    public static long getKeywordLogCount(string keyword) {
        long cnt = [select count() from MM_SMS_Log__c where KeylinkKeyword__c like :keyword];
        return cnt;
    }
}