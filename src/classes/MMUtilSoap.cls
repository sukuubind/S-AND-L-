public class MMUtilSoap {
    public static string sendSMS(List<MMUtilSMSObject> receipientList, string messageArg) {
        boolean isOneMessage = (messageArg == null)?false:true;        
        string sendStatus = '';
        long seqNum = 1;
        string entityId = null;
        long receiptNumber = 0;
        string selectedPhone = null;
        boolean isTrack = false;
        string country = null;
        string reqXML = '';
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        req.setEndpoint(MMUtilConstants.smsURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', MMUtilConstants.xmlContentType);
        
        if (receipientList != null && receipientList.size() > 0) {
            reqXML += getHeadXML() + getAuthXML(MMUtilConstants.mm_userid, MMUtilConstants.mm_password);
            reqXML += '<ns:messages>';
            for(MMUtilSMSObject smsObject : receipientList) {
                String message = isOneMessage?messageArg:smsObject.getMessage();
                entityId = smsObject.getEntityId();
                receiptNumber = smsObject.getReceiptNumber();
                selectedPhone = smsObject.getSelectedPhone();
                isTrack = smsObject.getIsTrack();
                country = smsObject.getCountry();
                if (MMUtils.stringEmptyNull(selectedPhone)) {
                    selectedPhone = getEntityAvailablePhone(entityId);
                }
                if (MMUtils.stringEmptyNull(country)) {
                    country = getDefaultCountry();
                }
                
                message = resolveAnyTemplate(message, entityId);
                if (!MMUtils.stringEmptyNull(selectedPhone) && !MMUtils.stringEmptyNull(entityId)) {
                    reqXML += '<ns:message format="SMS" sequenceNumber="' + String.valueOf(seqNum) + '">' +
                            '<ns:recipients>' +
                                '<ns:recipient uid="' + String.valueOf(receiptNumber) + '">' + MMUtils.fixPhoneNumber(selectedPhone, country) + '</ns:recipient>' +
                            '</ns:recipients>' +
                            (isTrack ? '<ns:deliveryReport>true</ns:deliveryReport>' : '') +
                            '<ns:validityPeriod>0</ns:validityPeriod>' +
                            '<ns:content>' + message + '</ns:content>' +
                            '</ns:message>';
                    seqNum++;
                }
            }
            
            reqXML += '</ns:messages>' + getFootXML();
            req.setBody(reqXML);
            try {
               if (!System.Test.isRunningTest()) {  
                HTTPResponse res = http.send(req);
               }
               
                /*MMDebug__c dbg = new MMDebug__c();
                dbg.message__c = 'Request : \n ' + '\n Response : \n' +res.getBody();
                insert dbg;*/
                sendStatus = 'Successful';
                //return res.getBody();
            }
            catch(System.CalloutException e) {
                /*MMDebug__c dbg = new MMDebug__c();
                dbg.message__c = 'Request : \n ' + reqXML + '\n Response Error : \n' + e.getMessage();
                insert dbg;*/
                sendStatus = 'Failed';
            }
        }
        return sendStatus;
    }
    public static string sendSMS(List<MMUtilSMSObject> receipientList, string messageArg, string userId) {
        boolean isOneMessage = (messageArg == null)?false:true;
        string sendStatus = '';
        long seqNum = 1;
        string entityId = null;
        long receiptNumber = 0;
        string selectedPhone = null;
        boolean isTrack = false;
        string country = null;
        string reqXML = '';
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        MMSettings settings = null;

        if (userId != null) {
            settings = MMUtils.getMMSettings(userId);
        }
        else {
            if (receipientList != null && receipientList.size() > 0) {
                settings = MMUtils.getMMSettings(receipientList[0].getReceiptOwnerId());
            }
        }

        req.setEndpoint(MMUtilConstants.smsURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', MMUtilConstants.xmlContentType);
        
        if (receipientList != null && receipientList.size() > 0) {
            reqXML += getHeadXML() + getAuthXML(settings.getUserId(), settings.getPassword());
            reqXML += '<ns:messages>';
            for(MMUtilSMSObject smsObject : receipientList) {
                String message = isOneMessage?messageArg:smsObject.getMessage();
                entityId = smsObject.getEntityId();
                receiptNumber = smsObject.getReceiptNumber();
                selectedPhone = smsObject.getSelectedPhone();
                isTrack = smsObject.getIsTrack();
                country = smsObject.getCountry();
                if (MMUtils.stringEmptyNull(selectedPhone)) {
                    selectedPhone = getEntityAvailablePhone(entityId);
                }
                if (MMUtils.stringEmptyNull(country)) {
                    country = getDefaultCountry(settings.getDialCode());
                }
                message = resolveAnyTemplate(message, entityId);
                if (!MMUtils.stringEmptyNull(selectedPhone) && !MMUtils.stringEmptyNull(entityId)) {
                    reqXML += '<ns:message format="SMS" sequenceNumber="' + String.valueOf(seqNum) + '">' +
                            '<ns:recipients>' +
                                '<ns:recipient uid="' + String.valueOf(receiptNumber) + '">' + MMUtils.fixPhoneNumber(selectedPhone, country) + '</ns:recipient>' +
                            '</ns:recipients>' +
                            (isTrack ? '<ns:deliveryReport>true</ns:deliveryReport>' : '') +
                            '<ns:validityPeriod>0</ns:validityPeriod>' +
                            '<ns:content>' + message + '</ns:content>' +
                            '</ns:message>';
                    seqNum++;
                }
            }
            
            reqXML += '</ns:messages>' + getFootXML();
            req.setBody(reqXML);
            try { 
            	
            	if (!System.Test.isRunningTest()) {  
                	HTTPResponse res = http.send(req);
               	}               
                            
                /*MMDebug__c dbg = new MMDebug__c();
                dbg.message__c = reqXML + '\n\n\n' + res.getBody();
                insert dbg;*/

                sendStatus = 'Successful';                
            }
            catch(System.CalloutException e) {
                /*MMDebug__c dbg = new MMDebug__c();
                dbg.message__c = 'Request : \n ' + reqXML + '\n Response Error : \n' + e.getMessage();
                insert dbg;*/
                sendStatus = 'Failed';
            }
        }
        return sendStatus;
    }
    public static string resolveAnyTemplate(string message, string entityId) {
        return message;
    }
    public static string getEntityAvailablePhone(string entityId) {
        string phone = null;
        
        return phone;
    }
    public static string getDefaultCountry() {
        string country = null;
        
        return country;
    }
    public static string getDefaultCountry(string dialCode) {
        string country = null;
        country = MMUtils.getCountryByDialCode(dialCode);
        return country;
    }
    public static string getHeadXML() {
        string headXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://xml.m4u.com.au/2009">' +
                    '<soapenv:Header/>' +
                    '<soapenv:Body>';
        return headXML;
    }
    public static string getFootXML() {
        string footXML = '</ns:requestBody>' +
                    '</ns:sendMessages>' +
                    '</soapenv:Body>' +
                    '</soapenv:Envelope>';
        return footXML;
    }
    public static string getAuthXML(string mmUserId, string mmPassword) {
        string authXML = '<ns:sendMessages>' +
                    '<ns:authentication>' +
                    '<ns:userId>' + mmUserId + '</ns:userId>' +
                    '<ns:password>' + mmPassword + '</ns:password>' +
                    '</ns:authentication>' +
                    '<ns:requestBody>';
        return authXML;
    }
}