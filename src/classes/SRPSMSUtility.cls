public with sharing class SRPSMSUtility {
    
    public static Map<String, Schema.SObjectType> gobalDescribeMap = null;
    
    public static List<sObject> loadSMSObjects(List<String> recordIds, String objectType, String nameField, String mobilePhoneField, boolean isOptOut, String optOutFieldValue){
        
        Integer selectedContacts = 0;
        List<String> args = new List<String>{};
        String optOutField = '';
        List<sObject> smsObjects = new List<sObject>{};
        string query = '';
        string mobilePhone  = '';
        string name='';
        optOutField = optOutFieldValue;
        SObject a  = null;
        Integer noMobile = 0;
        String smsText = '';
        String senderId = '';
        Schema.SObjectType s; 
        Schema.DescribeSObjectResult r;
        Map<string, Schema.Sobjectfield> objectFieldMap;

        if (recordIds.isEmpty()) return smsObjects;
        if(!SRPSMSUtility.checkForAlphaNumeric(objectType) || !SRPSMSUtility.checkForAlphaNumeric(nameField) || !SRPSMSUtility.checkForAlphaNumeric(mobilePhoneField) || !SRPSMSUtility.checkForAlphaNumeric(optOutField)) 
            return smsObjects;
        if(!SRPSMSUtility.checkObjectAccessibility(objectType))  return smsObjects;
        if(!SRPSMSUtility.checkFieldAccessibility(objectType,nameField) || !SRPSMSUtility.checkFieldAccessibility(objectType,mobilePhoneField))
            return smsObjects;
        if(!SRPSMSUtility.checkFieldAccessibility(objectType,optOutField))
            isOptOut = false;
        args.add(String.escapeSingleQuotes(objectType));
        args.add(String.escapeSingleQuotes(mobilePhoneField));
        if(nameField== null || namefield.length() == 0){
            query ='select id,  {1} from {0} where id in :recordIds';
        }
        else{
            args.add(String.escapeSingleQuotes(nameField));
            query ='select id, {2}, {1} from {0} where id in :recordIds';
        }
        if(isOptOut != null && isOptOut == true){
            args.add(String.escapeSingleQuotes(optOutField));
            query += ' and {3} =false';
        }
        query = String.format(query, args);
        List<sObject> sObjects = Database.query(query);
        selectedContacts = sObjects.size();
        
        for (sObject c :sObjects){
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            mobilePhone = String.valueOf(c.get(mobilePhoneField));
            if(nameField == null || namefield.length() == 0){
                name = 'Guest';
            } else{            
                name = String.valueOf(c.get(nameField));
            }
            if (mobilePhone == '' || mobilePhone == null){
                 noMobile += 1;
                 continue;
            }
            smsObject.smagicinteract__PhoneNumber__c = mobilePhone;
            smsObject.smagicinteract__Name__c = name ;
            smsObject.smagicinteract__ObjectType__c = objectType; 
            smsObjects.add(smsObject);
        }
        return smsObjects;
    }
    
    public static Integer sendBulk(List<String> recordIds, String objectType, String nameField, String mobilePhoneField, String smsText, String senderId, boolean isOptOut, String optOutFieldValue, boolean optOutSend, Id scheduledJobId){
         
        if(recordIds.size() == 0 ) return recordIds.size();
        if(!checkForAlphaNumeric(objectType) || !checkForAlphaNumeric(nameField) || !checkForAlphaNumeric(mobilePhoneField) || !checkForAlphaNumeric(optOutFieldValue)) 
            return 0;
        if(!checkFieldAccessibility(objectType,nameField) || !checkFieldAccessibility(objectType,mobilePhoneField))
            return 0;  
        if(!checkFieldAccessibility(objectType,optOutFieldValue))
            isOptOut = false;
                
        string mobilePhone = '';
        string name = '';
        List<sObject> sObjects = null;
        
        List<string> fields;
        string extraFieldText;
        List<String> args ;
        String eMsg = null;
        Schema.SObjectType s; 
        Schema.DescribeSObjectResult r;
        Map<string, Schema.Sobjectfield> objectFieldMap;
        Map<sObject, String> sobjectSMSTextMap = new Map<sObject, String>();
        List<sObject> smsObjects = new List<sObject>();
        
        String tplText = String.escapeSingleQuotes(smsText);
        smagicinteract.TemplateEngine TEngine = new smagicinteract.TemplateEngine(tplText);
        
        evalTemplateForUser(TEngine);
        evalTemplateForOrganization(TEngine);
        sobjectSMSTextMap = evalTemplateForSObject(TEngine, recordIds, objectType, nameField, mobilePhoneField, isOptOut, optOutFieldValue);
        for (sObject c :sobjectSMSTextMap.keySet()){
            name = '';
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            mobilePhone = String.valueOf(c.get(mobilePhoneField));
            if(nameField != null && nameField.length() != 0 ){
                name = String.valueOf(c.get(nameField));
            }
            if (mobilePhone == '' || mobilePhone == null) continue;
            smsObject.smagicinteract__PhoneNumber__c = mobilePhone;
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
                
            try{
                smsObject.smagicinteract__SenderId__c = senderId;
                smsObject.smagicinteract__SMSText__c = TEngine.getReplacedTextForObject(c, 0);
            } catch(Exception e){
                eMsg = 'Error in replacing custom field ' + e.getMessage();
                smsObject.smagicinteract__SMSText__c = TEngine.smsText;
            }        
            
            // change
            /*try{
                if(showUserDropDown && senderUserId != null)
                    smsObject.smagicinteract__Sent_By__c = senderUserId;
            } catch(Exception e){
                //pass
            }
            */
            
            try{
                if(objectType.endsWith('__c')){
                    String str = objectType.substring(0,objectType.lastIndexOf('__'));
                    if(str.contains('__')){
                        String tempObjectType = objectType.substring(str.indexOf('__')+2);
                        smsObject.put(tempObjectType, c.Id);
                    }else{
                        smsObject.put(objectType, c.Id);
                    }
                }else{
                    smsObject.put('smagicinteract__' + objectType + '__c', c.Id);
                }       
            }catch(Exception e){
                 //system.debug(Logginglevel.info, 'Exception :'+e);
            }   
            System.debug('CH: stop spot one');   
            smsObject.smagicinteract__Name__c = name;
            //smsObject.smagicinteract__sentStatus__c = 'sent';
            if(optOutSend != null && optOutSend)
                smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
            else
                smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
            if(scheduledJobId != null){
                smsObject.smagicinteract__sentStatus__c = 'Scheduled';
                smsObject.DeltakSRPSMS__SMS_Schedule__c = scheduledJobId;
            }
            System.debug('CH: stop spot two');
            smsObjects.add(smsObject);
        }
        insert smsObjects;
        System.debug('CH: stop spot three');
        return smsObjects.size();
    }
    
    public static void evalTemplateForUser(smagicinteract.TemplateEngine TEngine){
        
        List<string> fields;
        string extraFieldText;
        List<String> args ;
        String eMsg = null;
        string userId = UserInfo.getUserId();
        String query = '';
        
        // get field values for loggedin user
        try{
            fields = TEngine.getFieldsFromSMSTextOfObjectType('$User');
            extraFieldText = combineFields(fields);
            args = new List<String>{};
            args.add(extraFieldText);
            query = 'select Id, Name {0} from User where id = :userId limit 1';
            query = String.format(query, args);
            User u = Database.query(query);
            TEngine.getFieldMap(u);
            TEngine.smsText = TEngine.getReplacedTextForObject(u, 1);
        } catch(QueryException e){
            system.debug(Logginglevel.info, 'QueryException for User :'+e);
        }
    }
    
    public static void evalTemplateForOrganization(smagicinteract.TemplateEngine TEngine){
        
        List<string> fields;
        string extraFieldText;
        List<String> args ;
        String eMsg = null;
        string orgId = UserInfo.getOrganizationId();
        String query = '';
        
        // get field values for organization
        try{
             
            fields = TEngine.getFieldsFromSMSTextOfObjectType('$Organization');
            extraFieldText = combineFields(fields);
            args = new List<String>{};
            args.add(extraFieldText);
            query = 'select Id, Name {0} from Organization where id = :orgId limit 1';
            query = String.format(query, args);
            Organization o = Database.query(query);
            TEngine.getFieldMap(o);
            TEngine.smsText = TEngine.getReplacedTextForObject(o, 1);
        } catch(QueryException e){
            system.debug(Logginglevel.info, 'QueryException for Organization :'+e);
        }
    }
    
    public static Map<sObject, String> evalTemplateForSObject(smagicinteract.TemplateEngine TEngine, List<String> recordIds, String objectType, String nameField, String mobilePhoneField, boolean isOptOut, String optOutFieldValue){
        
        List<string> fields;
        string extraFieldText;
        List<String> args ;
        String eMsg = null;
        String query = '';
        String optOutField = optOutFieldValue;
        List<sObject> sObjects = null;
        Map<sObject, String> sobjectSMSTextMap = new Map<sObject, String>(); 
        
        // get field values for Contact/Leads/Cases/custom object   
        try{
            fields = TEngine.getFieldsFromSMSTextOfObjectType(objectType);
            extraFieldText = combineFields(fields);
            args = new List<String>{};
            args.add(String.escapeSingleQuotes(extraFieldText));
            args.add(String.escapeSingleQuotes(objectType));
            args.add(String.escapeSingleQuotes(mobilePhoneField));
            if(nameField == null || nameField.length() == 0){
                query ='select id, {2} {0} from {1} where id in :recordIds';
            }else{
                args.add(String.escapeSingleQuotes(nameField));
                query ='select id, {3}, {2} {0} from {1} where id in :recordIds';
            }
            
            if(isOptOut){
                args.add(String.escapeSingleQuotes(optOutField));
                query += ' and {4} =false';
            }
            query = String.format(query, args);
            sObjects = Database.query(query);
            TEngine.getFieldMap(sObjects[0]);
            
            for (sObject c :sObjects){
                sobjectSMSTextMap.put(c,TEngine.getReplacedTextForObject(c, 0));
            }
        } catch(ListException le){
             system.debug(Logginglevel.info, 'ListException for object :'+le);
        } 
        catch(QueryException e){
            if(fields.size() > 0){
                throw e;        
            }
        }
        return sobjectSMSTextMap;
    }
    
    public static String combineFields(List<string> fields){

        String extraFieldText = '';
        for(string x: fields){
            if(x.equalsIgnoreCase('Name'))
                continue;
            if(!extraFieldText.contains(x))
                extraFieldText = extraFieldText + ', '+x;
        }
        extraFieldText = String.escapeSingleQuotes(extraFieldText);
        return extraFieldText;
    }
    
    public static boolean checkForAlphaNumeric(String str){
        
        boolean b = false;
        String ObjectType = '';
        if(str != null)
            ObjectType = str; 
        Pattern MyPattern = Pattern.compile('^[a-zA-Z0-9_.$]+$');
        Matcher m = MyPattern.matcher(ObjectType);
        b = m.matches();
        return b;
    }
    
    public static boolean checkObjectAccessibility(string objectName){
        
        boolean hasAccessible = false;
        if(objectName.startsWith('$')) objectName = objectName.substring(1);
        //Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
        Map<String, Schema.SObjectType> m = SRPSMSUtility.getGlobalDescribe() ;
        if(m == null) return hasAccessible;
        Schema.SObjectType s = m.get(objectName) ;   
        if(s == null) return hasAccessible;
        Schema.DescribeSObjectResult r = s.getDescribe() ; 
        if(r == null) return hasAccessible;
        hasAccessible = r.isAccessible();
        return hasAccessible;
    }
    
    public static boolean checkFieldAccessibility(string objectName, string fieldName){
        
        boolean hasAccessible = false;
        if(objectName == null || fieldName == null) return hasAccessible;
        Map<string, Schema.Sobjectfield> fieldMap;
        if(objectName.startsWith('$')) objectName = objectName.substring(1);
        //Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
        Map<String, Schema.SObjectType> m = SRPSMSUtility.getGlobalDescribe() ;
        if(m == null) return hasAccessible;
        Schema.SObjectType s = m.get(objectName) ;   
        if(s == null) return hasAccessible;
        Schema.DescribeSObjectResult r = s.getDescribe() ; 
        if(r == null) return hasAccessible;
        fieldMap = r.fields.getMap();
        if(fieldMap == null) return hasAccessible;
        Schema.DescribeFieldResult F ;
        sObjectField b;
        for(string key: fieldMap.keySet()){
            b = fieldMap.get(key);
            F = b.getDescribe();
            if(fieldName.equalsIgnoreCase(F.getName())){
                hasAccessible = F.isAccessible();
            }
        }
        return hasAccessible;
    }
    
    public static Map<String, Schema.SObjectType> getGlobalDescribe(){
        if(gobalDescribeMap == null)
            gobalDescribeMap = Schema.getGlobalDescribe();
        return gobalDescribeMap;
    }

    public static Map<string, Schema.Sobjectfield> getObjectFieldMap(String sObjName){
        
        Map<string, Schema.Sobjectfield> M;
        /*Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.sObjectType A = gd.get(sObjName);
        Schema.DescribeSObjectResult D = A.getDescribe();
        */
        Map<String, Schema.SObjectType> gd = SRPSMSUtility.getGlobalDescribe();
        Schema.sObjectType A = gd.get(sObjName);
        Schema.DescribeSObjectResult D = A.getDescribe();
        M = D.fields.getMap();
        return M;
    }
    
    public static boolean validateScheduleHour(Date startDate, String hourString){
        
        boolean isValidate = true;
        Date todaysDate = system.today();
        Integer currentHour = Datetime.now().hour();
        
        if (startDate < todaysDate){
            isValidate = false;
            return isValidate;
        }
        if (startDate == todaysDate && Integer.valueOf(hourString) < currentHour)
            isValidate = false;
        return isValidate;
    }
    
    public static boolean validateScheduleMinutes(Date startDate, String hourString, String minuteString){
        
        boolean isValidate = true;
        Date todaysDate = system.today();
        Integer currentMinutes = Datetime.now().minute();
        Integer currentHour = Datetime.now().hour();
        
        if (startDate < todaysDate){
            isValidate = false;
            return isValidate;
        }
        if(startDate == todaysDate && Integer.valueOf(hourString) == currentHour  && Integer.valueOf(minuteString) <= currentMinutes)
            isValidate = false;
        return isValidate;
    }
    
    public static boolean validateEmptyString(String stringToCheck){
        
        boolean isEmpty = false;
        if (stringToCheck==null || stringToCheck.trim() == '')
            isEmpty = true;
        return isEmpty;
    }
    
    public static boolean checkNullField(sObject obj, String fieldName){
        
        boolean isNull = false;
        fieldName = fieldName.toLowerCase();
        if (obj.get(fieldName) == null)
            isNull = true;
        return isNull;
    }
    
    public static void verifyUrl(String urlString){

        boolean isValidUrl = true;
        try{
            Url newUrl = new Url(urlString);
            String hostName = newUrl.getHost();
            if(!(hostName.endsWith('.force.com') || hostName.endsWith('.salesforce.com'))){
                isValidUrl = false;
            }
        }catch(Exception e){
            system.debug(Logginglevel.info, 'Exception :'+e);
        }
        if(!isValidUrl){
           system.debug('***not a valid url');
        }
    }
    
    public static void updateScheduleStatus(List<Id> scheduleRecordsIdList){
        
        String query = 'select id from smagicinteract__smsMagic__c where SMS_Schedule__c in :scheduleRecordsIdList';
        try{
            for(List<smagicinteract__smsMagic__c> smsList :Database.query(query)){
                Database.delete(smsList);
            }
        }catch(Exception e){
            system.debug(Logginglevel.info, 'Exception in updateScheduleStatus :'+e);
        }
    } 
}