public with sharing class MMUtils {
    
    public static String[] arrCountryCodes = new String[]{'Afghanistan','93','AF','Aland Islands','358','AX','Albania','355','AL','Algeria','213','DZ','American Samoa','1684','AS','Andorra','376','AD','Angola','244','AO','Anguilla','1264','AI','Antarctica','672','AQ','Antigua and Barbuda','1268','AG','Argentina','54','AR','Armenia','374','AM','Aruba','297','AW','Australia','61','AU','Austria','43','AT','Azerbaijan','994','AZ','Bahamas','1242','BS','Bahrain','973','BH','Bangladesh','880','BD','Barbados','1246','BB','Belarus','375','BY','Belgium','32','BE','Belize','501','BZ','Benin','229','BJ','Bermuda','1441','BM','Bhutan','975','BT','Bolivia','591','BO','Bosnia and Herzegovina','387','BA','Botswana','267','BW','Brazil','55','BR','British Indian Ocean Territory','246','IO','Brunei','673','BN','Bulgaria','359','BG','Burkina Faso','226','BF','Burundi','257','BI','Cambodia','855','KH','Cameroon','237','CM','Canada','1','CA','Canary Islands','34','IC','Cape Verde','238','CV','Cayman Islands','1345','KY','Central African Republic','236','CF','Ceuta and Melilla','34','EA','Chad','235','TD','Chile','56','CL','China','86','CN','Christmas Island','61','CX','Cocos (Keeling) Islands','61','CC','Colombia','57','CO','Comoros','269','KM','Congo, Democratic People"s Republic','243','CD','Congo, Republic of','242','CG','Cook Islands','682','CK','Costa Rica','506','CR','Cote d\'Ivoire','225','CI','Croatia','385','HR','Cuba','53','CU','Cyprus','357','CY','Czech Republic','420','CZ','Denmark','45','DK','Djibouti','253','DJ','Dominica','1767','DM','Dominican Republic','1809','DO','East Timor','670','TP','Ecuador','593','EC','Egypt','20','EG','El Salvador','503','SV','Equatorial Guinea','240','GQ','Eritrea','291','ER','Estonia','372','EE','Ethiopia','251','ET','Falkland Islands','500','FK','Faroe Islands','298','FO','Fiji','679','FJ','Finland','358','FI','France','33','FR','French Guiana','594','GF','French Polynesia','689','PF','French Southern Territories','689','TF','Gabon','241','GA','Gambia','220','GM','Georgia','995','GE','Germany','49','DE','Ghana','233','GH','Gibraltar','350','GI','Greece','30','GR','Greenland','299','GL','Grenada','1473','GD','Guam','1671','GU','Guatemala','502','GT','Guinea','224','GN','Guinea-Bissau','245','GW','Guyana','592','GY','Haiti','509','HT','Heard and McDonald Is.','','HM','Holy See (Vatican City)','39','VA','Honduras','504','HN','Hong Kong','852','HK','Hungary','36','HU','Iceland','354','IS','India','91','IN','Indonesia','62','ID','Iran','98','IR','Iraq','964','IQ','Ireland','353','IE','Israel','972','IL','Italy','39','IT','Jamaica','1876','JM','Japan','81','JP','Jordan','962','JO','Kazakhstan','7','KZ','Kenya','254','KE','Kiribati','686','KI','Korea, Democratic People?s Republic','850','KP','Korea, Republic of','82','KR','Kuwait','965','KW','Kyrgyzstan','996','KG','Laos','856','LA','Latvia','371','LV','Lebanon','961','LB','Lesotho','266','LS','Liberia','231','LR','Libya','218','LY','Liechtenstein','423','LI','Lithuania','370','LT','Luxembourg','352','LU','Macau','853','MO','Macedonia','389','MK','Madagascar','261','MG','Malawi','265','MW','Malaysia','60','MY','Maldives','960','MV','Mali','223','ML','Malta','356','MT','Marshall Islands','692','MH','Martinique','596','MQ','Mauritania','222','MR','Mauritius','230','MU','Mayotte','262','YT','Mexico','52','MX','Micronesia','691','FM','Moldova','373','MD','Monaco','377','MC','Mongolia','976','MN','Montenegro','382','ME','Montserrat','1664','MS','Morocco','212','MA','Mozambique','258','MZ','Namibia','264','NA','Nauru','674','NR','Nepal','977','NP','Netherlands','31','NL','Netherlands Antilles','599','AN','New Caledonia','687','NC','New Zealand','64','NZ','Nicaragua','505','NI','Niger','227','NE','Nigeria','234','NG','Niue','683','NU','Norfolk Island','672','NF','Northern Mariana Islands','1670','MP','Norway','47','NO','Oman','968','OM','Pakistan','92','PK','Palau','680','PW','Palestinian Territories','970','PS','Panama','507','PA','Papua New Guinea','675','PG','Paraguay','595','PY','Peru','51','PE','Philippines','63','PH','Pitcairn Islands','870','PN','Poland','48','PL','Portugal','351','PT','Puerto Rico','1','PR','Qatar','974','QA','Reunion Island','262','RE','Romania','40','RO','Russia','7','RU','Rwanda','250','RW','Saint Barthelemy','590','BL','Saint Helena','290','SH','Saint Kitts and Nevis','1869','KN','Saint Lucia','1758','LC','Saint Martin','1599','MF','Saint Vincent and the Grenadines','1784','VC','Samoa','685','WS','San Marino','378','SM','Sao Tome and Principe','239','ST','Saudi Arabia','966','SA','Senegal','221','SN','Serbia','381','CS','Seychelles','248','SC','Sierra Leone','232','SL','Singapore','65','SG','Slovakia','421','SK','Slovenia','386','SI','Solomon Islands','677','SB','Somalia','252','SO','South Africa','27','ZA','South Georgia','','GS','Spain','34','ES','Sri Lanka','94','LK','St. Pierre and Miquelon','508','PM','Sudan','249','SD','Suriname','597','SR','Svalbard','79','SJ','Swaziland','268','SZ','Sweden','46','SE','Switzerland','41','CH','Syria','963','SY','Taiwan','886','TW','Tajikistan','992','TJ','Tanzania','255','TZ','Thailand','66','TH','Togo','228','TG','Tokelau','690','TK','Tonga','676','TO','Trinidad and Tobago','1868','TT','Tunisia','216','TN','Turkey','90','TR','Turkmenistan','993','TM','Turks and Caicos Islands','1649','TC','Tuvalu','688','TV','Uganda','256','UG','Ukraine','380','UA','United Arab Emirates','971','AE','United Kingdom','44','GB','United States','1','US','Uruguay','598','UY','US Minor Outlying Islands','808','UM','Uzbekistan','998','UZ','Vanuatu','678','VU','Venezuela','58','VE','Vietnam','84','VN','Virgin Islands, British','1284','VG','Virgin Islands, USA','1340','VI','Wallis and Futuna','681','WF','Western Sahara','212','EH','Yemen','967','YE','Zambia','260','ZM','Zimbabwe','263','ZW'};
//  public static String[] arrCountryCodes = new String[]{'Afghanistan','93','Aland Islands','358','Albania','355','Algeria','213','American Samoa','1684','Andorra','376','Angola','244','Anguilla','1264','Antarctica','672','Antigua and Barbuda','1268','Argentina','54','Armenia','374','Aruba','297','Australia','61','Austria','43','Azerbaijan','994','Bahamas','1242','Bahrain','973','Bangladesh','880','Barbados','1246','Belarus','375','Belgium','32','Belize','501','Benin','229','Bermuda','1441','Bhutan','975','Bolivia','591','Bosnia and Herzegovina','387','Botswana','267','Brazil','55','British Indian Ocean Territory','246','Brunei','673','Bulgaria','359','Burkina Faso','226','Burundi','257','Cambodia','855','Cameroon','237','Canada','1','Canary Islands','34','Cape Verde','238','Cayman Islands','1345','Central African Republic','236','Ceuta and Melilla','34','Chad','235','Chile','56','China','86','Christmas Island','61','Cocos (Keeling) Islands','61','Colombia','57','Comoros','269','Congo, Democratic People"s Republic','243','Congo, Republic of','242','Cook Islands','682','Costa Rica','506','Cote d\'Ivoire','225','Croatia','385','Cuba','53','Cyprus','357','Czech Republic','420','Denmark','45','Djibouti','253','Dominica','1767','Dominican Republic','1809','East Timor','670','Ecuador','593','Egypt','20','El Salvador','503','Equatorial Guinea','240','Eritrea','291','Estonia','372','Ethiopia','251','Falkland Islands','500','Faroe Islands','298','Fiji','679','Finland','358','France','33','French Guiana','594','French Polynesia','689','French Southern Territories','689','Gabon','241','Gambia','220','Georgia','995','Germany','49','Ghana','233','Gibraltar','350','Greece','30','Greenland','299','Grenada','1473','Guam','1671','Guatemala','502','Guinea','224','Guinea-Bissau','245','Guyana','592','Haiti','509','Heard and McDonald Is.','','Holy See (Vatican City)','39','Honduras','504','Hong Kong','852','Hungary','36','Iceland','354','India','91','Indonesia','62','Iran','98','Iraq','964','Ireland','353','Israel','972','Italy','39','Jamaica','1876','Japan','81','Jordan','962','Kazakhstan','7','Kenya','254','Kiribati','686','Korea, Democratic People?s Republic','850','Korea, Republic of','82','Kuwait','965','Kyrgyzstan','996','Laos','856','Latvia','371','Lebanon','961','Lesotho','266','Liberia','231','Libya','218','Liechtenstein','423','Lithuania','370','Luxembourg','352','Macau','853','Macedonia','389','Madagascar','261','Malawi','265','Malaysia','60','Maldives','960','Mali','223','Malta','356','Marshall Islands','692','Martinique','596','Mauritania','222','Mauritius','230','Mayotte','262','Mexico','52','Micronesia','691','Moldova','373','Monaco','377','Mongolia','976','Montenegro','382','Montserrat','1664','Morocco','212','Mozambique','258','Namibia','264','Nauru','674','Nepal','977','Netherlands','31','Netherlands Antilles','599','New Caledonia','687','New Zealand','64','Nicaragua','505','Niger','227','Nigeria','234','Niue','683','Norfolk Island','672','Northern Mariana Islands','1670','Norway','47','Oman','968','Pakistan','92','Palau','680','Palestinian Territories','970','Panama','507','Papua New Guinea','675','Paraguay','595','Peru','51','Philippines','63','Pitcairn Islands','870','Poland','48','Portugal','351','Puerto Rico','1','Qatar','974','Reunion Island','262','Romania','40','Russia','7','Rwanda','250','Saint Barthelemy','590','Saint Helena','290','Saint Kitts and Nevis','1869','Saint Lucia','1758','Saint Martin','1599','Saint Vincent and the Grenadines','1784','Samoa','685','San Marino','378','Sao Tome and Principe','239','Saudi Arabia','966','Senegal','221','Serbia','381','Seychelles','248','Sierra Leone','232','Singapore','65','Slovakia','421','Slovenia','386','Solomon Islands','677','Somalia','252','South Africa','27','South Georgia','','Spain','34','Sri Lanka','94','St. Pierre and Miquelon','508','Sudan','249','Suriname','597','Svalbard','79','Swaziland','268','Sweden','46','Switzerland','41','Syria','963','Taiwan','886','Tajikistan','992','Tanzania','255','Thailand','66','Togo','228','Tokelau','690','Tonga','676','Trinidad and Tobago','1868','Tunisia','216','Turkey','90','Turkmenistan','993','Turks and Caicos Islands','1649','Tuvalu','688','Uganda','256','Ukraine','380','United Arab Emirates','971','United Kingdom','44','United States','1','Uruguay','598','US Minor Outlying Islands','808','Uzbekistan','998','Vanuatu','678','Venezuela','58','Vietnam','84','Virgin Islands, British','1284','Virgin Islands, USA','1340','Wallis and Futuna','681','Western Sahara','212','Yemen','967','Zambia','260','Zimbabwe','263'};
    
    public static void sendSingleEmail(string to, string displayName, string subject, string content, string stdName ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.  
            
        String[] toAddresses = new String[] {to};
            
        mail.setToAddresses(toAddresses);
        
        // Specify the name used as the display name.  
            
        mail.setSenderDisplayName(displayName);
        
        // Specify the subject line for your email address.  
            
        mail.setSubject(subject);
        
        
        mail.setHtmlBody('Dear ' + displayName + '<br/><br/>'
             + 'A new SMS Reply has been received from ' + stdName 
             + '<br/><br/>' + content
             + '<br/><br/>AUTO GENERATED EMAIL, PLEASE DO NOT REPLY ');
        
        // Send the email you have created.  
            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendSingleEmail(string to, string displayName, string subject, string message){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.  
            
        String[] toAddresses = new String[] {to};
            
        mail.setToAddresses(toAddresses);
        
        // Specify the name used as the display name.  
            
        mail.setSenderDisplayName(displayName);
        
        // Specify the subject line for your email address.  
            
        mail.setSubject(subject);
        
        mail.setHtmlBody(message);
        
        // Send the email you have created.  
            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendSingleEmail(string to, string displayName, string subject, string message, Id userId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Strings to hold the email addresses to which you are sending the email.  
            
        String[] toAddresses = new String[] {to};
            
        mail.setToAddresses(toAddresses);
        
        // Specify the name used as the display name.  
            
        mail.setSenderDisplayName(displayName);
        
        // Specify the subject line for your email address.  
            
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(userId);
        mail.setWhatId(null);
        
        mail.setHtmlBody(message);
        
        // Send the email you have created.  
            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static string fixPhoneNumber(string p, string country){
        if(p.startsWith('+')) return p;
        p = p.replaceAll('[^0-9]', ''); 
        p = removePrefixZeros(p);
        string ccode = getCountryCode(country);
        if(ccode == 'false') return '+' + p;
        if(!p.startsWith(ccode)) return '+' + ccode + p;        
        return '+' + p;   
    }
    
    public static string removePrefixZeros(string p) {
        while (p.indexOf('0') == 0) {
            p = p.substring(1);
        }
        return p;
    }
    
    public static string formatList(){
        string rs = ''; 
        integer size = arrCountryCodes.size();
        for(integer i = 0; i < size; i++ ){
            if(Math.mod((i+1),3) == 0) continue;
            rs += '\'' + arrCountryCodes[i] + '\',';
        }
        return rs;
    }
    
    public static void saveHeaderFooter(string headerText, string footerText, string type){
        SMSHeaderFooter__c hf;
        try{
            hf = [select Header__c, Footer__c from SMSHeaderFooter__c where type__c = : type  and User__c = : UserInfo.getUserId()];                
        }catch(Exception e){
            hf = new SMSHeaderFooter__c();
            hf.Type__c = type;
            hf.User__c  = UserInfo.getUserId();                     
        }
        
        hf.Header__c = headerText;
        hf.Footer__c = footerText;
        upsert hf;     
    }
    
    public static void saveHeaderFooter(string headerText, string footerText, string type, string timeZone){
        SMSHeaderFooter__c hf;
        try{
            hf = [select Header__c, Footer__c, Time_Zone__c from SMSHeaderFooter__c where type__c = : type  and User__c = : UserInfo.getUserId()];                
        }catch(Exception e){
            hf = new SMSHeaderFooter__c();
            hf.Type__c = type;
            hf.User__c  = UserInfo.getUserId();                     
        }
        
        hf.Header__c = headerText.replace('\n','_-_');
        hf.Footer__c = footerText.replace('\n','_-_');
        hf.Time_Zone__c = timeZone;
        upsert hf;     
    }
    
    public static SMSHeaderFooter__c getHeaderFooter(string type, string userId){
        SMSHeaderFooter__c hf = null;
        try{
            hf = [select Header__c, Footer__c, Time_Zone__c from SMSHeaderFooter__c where type__c = :type  and User__c = :userId];                
        }catch(Exception e){
            hf = null;
        }
        return hf;
    }
        
    public static void createSMSReceipt(string entityId, string entityType, long receiptNumber) {
        MMSMSReceipt__c receipt = new MMSMSReceipt__c();
        receipt.EntityId__c = entityId;
        receipt.EntityType__c = entityType;
        receipt.ReceiptNumber__c = receiptNumber;
        insert receipt;
    }
    
    public static void createSMSReceipt(string entityId, string entityType, long receiptNumber, boolean isSch, boolean isTrack,
                                        string taskId, DateTime trackDateTime, string trackStatus, string trackTimeZone) {
        MMSMSReceipt__c receipt = new MMSMSReceipt__c();
        receipt.EntityId__c = entityId;
        receipt.EntityType__c = entityType;
        receipt.ReceiptNumber__c = receiptNumber;
        receipt.IsScheduled__c = isSch;
        receipt.IsTrackDelivery__c = isTrack;
        receipt.TaskId__c = taskId;
        receipt.TrackDeliveryDateTime__c = trackDateTime;
        receipt.TrackDeliveryStatus__c = trackStatus;
        receipt.TrackDeliveryTimeZone__c = trackTimeZone;
        insert receipt;
    }
    
    public static void createSMSReceipt(string entityId, string entityType, long receiptNumber, boolean isSch, boolean isTrack,
                                        string taskId, DateTime trackDateTime, string trackStatus, string trackTimeZone, boolean dayLightSaving) {
        MMSMSReceipt__c receipt = new MMSMSReceipt__c();
        receipt.EntityId__c = entityId;
        receipt.EntityType__c = entityType;
        receipt.ReceiptNumber__c = receiptNumber;
        receipt.IsScheduled__c = isSch;
        receipt.IsTrackDelivery__c = isTrack;
        receipt.TaskId__c = taskId;
        receipt.TrackDeliveryDateTime__c = trackDateTime;
        receipt.TrackDeliveryStatus__c = trackStatus;
        receipt.TrackDeliveryTimeZone__c = trackTimeZone;
        receipt.IsDayLightSaving__c = dayLightSaving;
        insert receipt;
    }
    
    public static MMSMSReceipt__c createSMSReceipt(string entityId, string entityType, long receiptNumber, boolean isSch, boolean isTrack,
                                        string taskId, DateTime trackDateTime, string trackStatus, string trackTimeZone, boolean dayLightSaving,
                                        string message, DateTime schDateTime, String phoneNumber, String country) {
        MMSMSReceipt__c receipt = new MMSMSReceipt__c();
        receipt.EntityId__c = entityId;
        receipt.EntityType__c = entityType;
        receipt.ReceiptNumber__c = receiptNumber;
        receipt.IsScheduled__c = isSch;
        receipt.IsTrackDelivery__c = isTrack;
        receipt.TaskId__c = taskId;
        receipt.TrackDeliveryDateTime__c = trackDateTime;
        receipt.TrackDeliveryStatus__c = trackStatus;
        receipt.TrackDeliveryTimeZone__c = trackTimeZone;
        receipt.IsDayLightSaving__c = dayLightSaving;
        receipt.Message__c = message;
        //if(schDateTime != null){
        receipt.schDateTime__c = schDateTime;
        receipt.schPhoneNumber__c = phoneNumber;
        receipt.Country__c = country;
        //}
        //insert receipt;
        //return receipt.Id;
        return receipt;
    }
    
    public static long getReceiptNumber() {
        long receiptNo = 0;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(MMUtilConstants.getPublicUrl() + '/mmutilcommon?rq=getreceiptno');
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            receiptNo = Long.valueOf(res.getBody());
        }
        catch(Exception exp) {
        }
        return receiptNo;
    }
    
    public static Long[] getReceiptNumbers(Integer size, Boolean isTest) {
        if(isTest){
            Long[] testResult = new List<Long>();            
            for(Integer i = 0; i < size ; i ++){
                testResult.add(3000 + i);
            }        
            return testResult;
        }
        long receiptNo = 0;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(MMUtilConstants.getPublicUrl() + '/mmutilcommon?rq=getreceiptno&size='+ String.valueOf(size));
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Long[] rcNums =  new List<Long>();
            String[] rcNumsString = res.getBody().split(',');
            for(Integer i = 0; i < rcNumsString.size(); i++){
                rcNums.add(Long.valueOf(rcNumsString[i]));
            }
            return rcNums;
        }
        catch(Exception exp) {
            MMUtilSch.logMessage('Line:' + exp.getLineNumber() + ':' + exp.getMessage());   
        }
        return null;
    }
    
    private static string insertReceiptNumber() {
        string rid = '';
        MMSMS_ReceiptCount__c receiptNo = new MMSMS_ReceiptCount__c();
        Database.SaveResult sr = Database.insert(receiptNo);
        if (sr.isSuccess()) {
            rid = sr.getId();
        }
        return rid;
    }
    
    public static long generateReceiptNumber() {
       long retVal = -1;
       MMSMS_ReceiptCount__c receiptNo = null;
       string rid = insertReceiptNumber();
       if (rid != null && rid != '') {
           receiptNo = [select c.CurrentNumber__c, c.ReceiptNo__c from MMSMS_ReceiptCount__c c where c.Id = :rid limit 1];
           if (receiptNo != null) {
               retVal = receiptNo.ReceiptNo__c.longValue();
           }
       }
       return retVal;
    }
    
    public static void updateReceiptNumber(long receiptNumber, decimal dt){
        /*
        MMSMS_ReceiptCount__c receiptNo = [select c.Name, c.CurrentNumber__c, c.TimeStamp__c from MMSMS_ReceiptCount__c c limit 1];
        receiptNo.CurrentNumber__c = receiptNumber;
        receiptNo.TimeStamp__c = dt;
        update receiptNo;
        */
    }
    
    public static MMSMSReceipt__c getReceiptRecord(string receiptId) {
        MMSMSReceipt__c rec = null;
        rec = [select c.EntityId__c, c.EntityType__c, c.IsScheduled__c,
                      c.IsTrackDelivery__c, c.ReceiptNumber__c, c.TaskId__c,
                      c.TrackDeliveryDateTime__c, c.TrackDeliveryStatus__c, c.TrackDeliveryTimeZone__c,
                      c.IsDayLightSaving__c, c.Message__c, c.ownerId
               from MMSMSReceipt__c c where c.ReceiptNumber__c = :Long.valueOf(receiptId) and c.TaskId__c <> null
               order by c.Id desc limit 1];
        return rec;
    }
    
    public static MMSMSReceipt__c getReceiptRecord(Id receiptId) {
        MMSMSReceipt__c rec = null;
        rec = [select c.EntityId__c, c.EntityType__c, c.IsScheduled__c,
                      c.IsTrackDelivery__c, c.ReceiptNumber__c, c.TaskId__c,
                      c.TrackDeliveryDateTime__c, c.TrackDeliveryStatus__c, c.TrackDeliveryTimeZone__c,
                      c.IsDayLightSaving__c, c.Message__c, c.ownerId
               from MMSMSReceipt__c c where c.Id = :receiptId and c.TaskId__c <> null
               order by c.Name desc, c.Id desc limit 1];
        return rec;
    }
    
    public static Task createTask(string entityId, string entityType, string message, string sendStatus, boolean isTrack, boolean isSch ) {
       Id userId = UserInfo.getUserId();
       Task t = new Task();       
       t.Subject = message.substring(0, (message.length() > 20 ? 20 : message.length()));
       t.WhoId = (entityType == 'af') ? entityId : null;
       t.WhatId = (entityType == 'op')? entityId : null;
       t.Type = 'SMS';
       t.status = 'Completed';
       t.OwnerId = userId;  
       //if(sendStatus == null){sendStatus='failed';}
       t.Result__c = sendStatus;
       t.deltaksrp__result__c = sendStatus;
       t.MMSMSDeliveryStatus__c = isSch?'Scheduled':((isTrack)? 'SMS Pending' : 'Not Required');
       t.ActivityDate = System.today();
       //insert t;
       return t; 

    }
    
    public static Task createTask(string entityId, string entityType, string message, string sendStatus, boolean isTrack, boolean isSch, Id assignTo ) {
       Id userId = UserInfo.getUserId();
       Task t = new Task();       
       t.Subject = message.substring(0, (message.length() > 20 ? 20 : message.length()));
       t.WhoId = (entityType == 'af') ? entityId : null;
       t.WhatId = (entityType == 'op')? entityId : null;
       t.Type = 'SMS';
       t.status = 'Completed';
       t.OwnerId = assignTo != null ? assignTo : userId; 
   //    if(sendStatus == null){sendStatus='failed';} 
       t.Result__c = sendStatus;
       t.deltaksrp__result__c = sendStatus;
       t.MMSMSDeliveryStatus__c = isSch?'Scheduled':((isTrack)? 'SMS Pending' : 'Not Required');
       t.ActivityDate = System.today();
       //insert t;
       return t; 

    }
    
    public static Task updateTask(string taskId, string deliveryStatus, string deliveryTime) {
       Task t = null;
       t = [select Id from Task where Id = :taskId];
       
       if (deliveryStatus == 'd') t.MMSMSDeliveryStatus__c = 'SMS Delivered';
       else if(deliveryStatus == 'f') t.MMSMSDeliveryStatus__c = 'SMS Sending Failed';
       else if(deliveryStatus == 'p') t.MMSMSDeliveryStatus__c = 'SMS Pending';
       else t.MMSMSDeliveryStatus__c = 'Status Received: ' + deliveryStatus;
       
       t.MMSMSDeliveryDateTime__c = deliveryTime;
       update t;
       return t;
    }
    
    public static string getCountryCode(string country){
        integer size = arrCountryCodes.size();
        for(integer i = 0; i < size ; i ++) {
            if(arrCountryCodes[i] == country){
                if(Math.mod(i+1, 3) == 0) return arrCountryCodes[i-1];
                    else return arrCountryCodes[i+1];
            }
        }
        return 'false';
    }
    
    public static string getCountryByDialCode(string dialCode){
        string country = null;
        for(integer i = 0; i < arrCountryCodes.size(); i += 3) {
            if(arrCountryCodes[i + 1] == dialCode){
                country = arrCountryCodes[i];
                break;
            }
        }
        return country;
    }
    
    public static boolean stringEmptyNull(string s) {
        boolean status = false;
        if (s == null || s.length() == 0 || s.trim().length() == 0) {
            status = true;
        }
        return status;
    }
    
    public static MMSettings getMMSettings(string id) {
        MMSettings settings = new MMSettings();
        MMSMSSettings__c h = null;
        if (stringEmptyNull(id)) {
            h = MMSMSSettings__c.getInstance();
        }
        else {
            h = MMSMSSettings__c.getInstance(id);
        }
        settings.setUserId((h != null ? h.MessageMediaUserId__c : ''));
        settings.setPassword((h != null ? h.MessageMediaPassword__c : ''));
        settings.setDialCode((h != null ? h.DefaultIntDialingCode__c : ''));
        settings.setNotifyTo((h != null ? h.NotifyTo__c : ''));
        return settings;
    }
    
    public static String getLimitTrace(){
        String limitTrace = '';
        limitTrace += 'limits.getAggregateQueries - ' + limits.getAggregateQueries() + '/' + limits.getLimitAggregateQueries() + ' \n' ;
        limitTrace += 'limits.getCallouts - ' + limits.getCallouts() + '/' + limits.getLimitCallouts() + ' \n' ;
        limitTrace += 'limits.getChildRelationshipsDescribes - ' + limits.getChildRelationshipsDescribes() + '/' + limits.getLimitChildRelationshipsDescribes() + ' \n' ;
        limitTrace += 'limits.getCpuTime - ' + limits.getCpuTime() + '/' + limits.getLimitCpuTime() + ' \n' ;
        limitTrace += 'limits.getDMLRows - ' + limits.getDMLRows() + '/' + limits.getLimitDMLRows() + ' \n' ;
        limitTrace += 'limits.getDMLStatements - ' + limits.getDMLStatements() + '/' + limits.getLimitDMLStatements() + ' \n' ;
        limitTrace += 'limits.getEmailInvocations - ' + limits.getEmailInvocations() + '/' + limits.getLimitEmailInvocations() + ' \n' ;
        limitTrace += 'limits.getFieldsDescribes - ' + limits.getFieldsDescribes() + '/' + limits.getLimitFieldsDescribes() + ' \n' ;
        limitTrace += 'limits.getFindSimilarCalls - ' + limits.getFindSimilarCalls() + '/' + limits.getLimitFindSimilarCalls() + ' \n' ;
        limitTrace += 'limits.getFutureCalls - ' + limits.getFutureCalls() + '/' + limits.getLimitFutureCalls() + ' \n' ;
        Decimal heapPerc = Math.Round((Decimal.valueOf(limits.getHeapSize())/limits.getLimitHeapSize()) * 100); 
        heapPerc.setScale(2, System.RoundingMode.UP);
        limitTrace += 'limits.getHeapSize - ' + limits.getHeapSize() + '/' + limits.getLimitHeapSize() + ' (' + heapPerc + '%)' +' \n' ;
        limitTrace += 'limits.getQueries - ' + limits.getQueries() + '/' + limits.getLimitQueries() + ' \n' ;
        limitTrace += 'limits.getPicklistDescribes - ' + limits.getPicklistDescribes() + '/' + limits.getLimitPicklistDescribes() + ' \n' ;
        limitTrace += 'limits.getQueryLocatorRows - ' + limits.getQueryLocatorRows() + '/' + limits.getLimitQueryLocatorRows() + ' \n' ;
        limitTrace += 'limits.getQueryRows - ' + limits.getQueryRows() + '/' + limits.getLimitQueryRows() + ' \n' ;
        limitTrace += 'limits.getRecordTypesDescribes - ' + limits.getRecordTypesDescribes() + '/' + limits.getLimitRecordTypesDescribes() + ' \n' ;
        limitTrace += 'limits.getRunAs - ' + limits.getRunAs() + '/' + limits.getLimitRunAs() + ' \n' ;
        limitTrace += 'limits.getSavepointRollbacks - ' + limits.getSavepointRollbacks() + '/' + limits.getLimitSavepointRollbacks() + ' \n' ;
        limitTrace += 'limits.getSavepoints - ' + limits.getSavepoints() + '/' + limits.getLimitSavepoints() + ' \n' ;
        limitTrace += 'limits.getScriptStatements - ' + limits.getScriptStatements() + '/' + limits.getLimitScriptStatements() + ' \n' ;
        limitTrace += 'limits.getSoslQueries - ' + limits.getSoslQueries() + '/' + limits.getLimitSoslQueries() + ' \n' ;
        return limitTrace;
    }
    
    public static void addMessage(ApexPages.Severity type, String message){
           ApexPages.addMessage(new ApexPages.Message(type, message));
        
    }
      
    public Static List<SelectOption> getTimeOptions(){
        List<SelectOption> hours = new List<SelectOption>();
        String ampm = 'am';
        hours.add(new SelectOption('',''));
        hours.add(new SelectOption('0','12:00 am'));
        for(integer hour = 1; hour < 25 ; hour ++){
           integer mod = Math.mod(hour,13);
           if(mod + 1 == 0) { hour ++; continue; }
           if(mod == 0) continue;
           if(hour > 11) ampm = 'pm';
           String val = mod + ':00 ' + ampm;
           hours.add(new SelectOption(String.valueOf((hour>12)?hour-1:hour),val));
        }
        return hours;
    }
    public static string fixPhoneNumber(string p){
        p = p.replaceAll('[^0-9]', ''); 
        p = removePrefixZeros(p);
        return p;   
    }
    public static string getCountryByPhone(string p) {
        string country = '';
        integer i = 0;
        for (i=0;i<arrCountryCodes.size();i+=3) {
            if (!stringEmptyNull(arrCountryCodes[i + 1]) && p.indexOf(arrCountryCodes[i + 1]) == 0) {
                country = arrCountryCodes[i];
                break;
            }
        }
        return country;
    }
    
    public static String filterNull(String toFilter){
        if(toFilter == null) return '';
        return toFilter;
    }
    
    public static String filterNull(string header, String toFilter, string footer){
        return (
                 (header != null ? header.replace('_-_','\n') : '') +
                 (toFilter != null ? toFilter : '') +
                 (footer != null ? footer.replace('_-_','\n') : '')
                );
    }
    
    public static List<String> getContactsByView(String viewId) {        
        PageReference pr = new PageReference('/apex/getContactsByView?fcf=' + viewId);
        pr.setRedirect(true);
        String response = pr.getContent().toString();        
        return response == '' ? new List<String>() : response.split(',');        
    }
    
    public static List<String> getOpportunitiesByView(String viewId) {        
        PageReference pr = new PageReference('/apex/getOpportunitiesByView?fcf=' + viewId);
        pr.setRedirect(true);
        String response = pr.getContent().toString();        
        return response.contains(',') ? response.split(',') :new List<String>() ; 
    }

    public static MMAccountStatus getUserAccountStatus(string userId, boolean isTest) {
        MMAccountStatus status = new MMAccountStatus();
        string responseString = '';
        MMSettings settings = null;
        HttpRequest req = new HttpRequest();
        HTTPResponse res = null;
        Http http = new Http();
        DOM.Document doc = new DOM.Document();
        Dom.XmlNode node = null;

        settings = MMUtils.getMMSettings(userId);
        string reqXML = MMUtilSoap.getHeadXML() + '<ns:checkUser xmlns="http://xml.m4u.com.au/2009">' +
                    '<ns:authentication>' + 
                    '<ns:userId>' + settings.getUserId() + '</ns:userId>' +
                    '<ns:password>' + settings.getPassword() + '</ns:password>' +
                    '</ns:authentication>' +
                    '</ns:checkUser>' +
                    '</soapenv:Body>' +
                    '</soapenv:Envelope>';
        try {
            req.setEndpoint(MMUtilConstants.smsURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', MMUtilConstants.xmlContentType);
            req.setBody(reqXML);
            
            if (!isTest) {
                res = http.send(req);
                responseString = res != null ? res.getBody() : 'EMPTY RESPONSE FROM MESSAGE MEDIA';
            }
            else {
                responseString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                                 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' + 
                                 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body>' +
                                 '<checkUserResponse xmlns="http://xml.m4u.com.au/2009"><result>' +
                                 '<accountDetails type="daily" creditLimit="5000" creditRemaining="4995"/></result>' +
                                 '</checkUserResponse></soapenv:Body></soapenv:Envelope>';
            }
            if (responseString.toLowerCase().indexOf('<soap-env:body>') >= 0) {
                responseString = responseString.substring(responseString.toLowerCase().indexOf('<soap-env:body>') + 15);
                responseString = responseString.substring(0, responseString.toLowerCase().indexOf('</soap-env:body>'));
            }
            if (responseString.toLowerCase().indexOf('faultresponse') >= 0) {
                responseString = responseString.substring(responseString.toLowerCase().indexOf('<faultresponse'));
                responseString = responseString.substring(0, responseString.toLowerCase().indexOf('</faultresponse>') + 16);
                doc.load(responseString);
                node = doc.getRootElement().getChildElement('error','http://xml.m4u.com.au/2009');
                status.setError(node.getAttributeValue('code',''));
            }
            else if (responseString.toLowerCase().indexOf('checkuserresponse') >= 0) {
                if (!isTest) {
                    doc.load(responseString);
                    node = doc.getRootElement().getChildElement('result','http://xml.m4u.com.au/2009').getChildElement('accountDetails','http://xml.m4u.com.au/2009');
                    status.setResponseType(node.getAttributeValue('type',''));
                    status.setSmsLimit(node.getAttributeValue('creditLimit',''));
                    status.setSmsRemaining(node.getAttributeValue('creditRemaining',''));
                }
                else {
                    status.setError('');
                    status.setResponseType('daily');
                    status.setSmsLimit('500');
                    status.setSmsRemaining('450');
                }
            }
            else {
                status.setError('MessageMedia Server returned an invalid response tag which is neither faultResponse nor checkUserResponse');
            }
            status.setOriginalResponse(responseString);
        }
        catch(Exception exp) {
            status.setError(exp.getMessage());
        }
        return status;
    }
}