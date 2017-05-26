public class webmail_Utilities {
	
    private static boolean webmailcacheloaded = false;
    private static ID idSuccesfulSyncRecordType = null;
    private static ID idNeedsReconciliationRecordType = null;
    private static String strServiceEmailAddress = null;
    private static ID idReconciliationUser = null;

    //-- Caching
    public static ID getSuccessfulRecordType(){
        If(webmailcacheloaded){
            return idSuccesfulSyncRecordType;
        }
        cacheWebmailSettings();
        return idSuccesfulSyncRecordType;
    }
    
    public static ID getNeedsReconciliationRecordType(){
        If(webmailcacheloaded){
            return idNeedsReconciliationRecordType;
        }
        cacheWebmailSettings();
        return idNeedsReconciliationRecordType;
    }
    
    public static String getCSWebmailReceieverAddress(){
        If(webmailcacheloaded){
            return strServiceEmailAddress;
        }
        cacheWebmailSettings();
        return strServiceEmailAddress;
    }
    
    public static ID getCSReconciliationUserID(){
        If(webmailcacheloaded){
            return idReconciliationUser;
        }
        cacheWebmailSettings();
        return idReconciliationUser;
    }
    
    public static void cacheWebmailSettings(){
        //This function queries and caches Webmail related record types
        if(webmailcacheloaded){
            return;
        }
        //Cache Record Types
        List<RecordType> rtypes = [SELECT Name, DeveloperName, Id FROM RecordType WHERE sObjectType='Webmail_Synced_Emails__c' AND isActive=true];
        for(RecordType rt: rtypes){
            if(rt.DeveloperName == 'Successful'){
                idSuccesfulSyncRecordType = rt.Id;
            }
            if(rt.DeveloperName == 'Needs_Reconciliation'){
                idNeedsReconciliationRecordType = rt.Id;
            }
        }
        if(idSuccesfulSyncRecordType == null){
            throw new webmailException('Webmail: Successful Sync Record Type could not be found');
        }
        if(idNeedsReconciliationRecordType == null){
            throw new webmailException('Webmail: Needs Reconciliation Record Type could not be found');
        }
        
        //Load custom settings
        webmailSettings__c mcsWebmail = webmailSettings__c.GetInstance();
        if(mcsWebmail.InboundServiceAddress__c == null){
            throw new webmailException('Custom Setting for "webmailSettings__c.InboundServiceAddress__c" is not set.');
        }else{
            strServiceEmailAddress = mcsWebmail.InboundServiceAddress__c; 
        }
        if(mcsWebmail.ReconciliationUserID__c == null){
            throw new webmailException('Custom Setting for "webmailSettings__c.ReconciliationUserID__c" is not set.');
        }else{
            idReconciliationUser = (ID)mcsWebmail.ReconciliationUserID__c; 
        }
        
        webmailcacheloaded = true;

    }
    
    //-- Utilities
    Public Static String stripHTML(String strInput){
        //This function will clean up HTML to make it human readable:
        //  Replace <br> with linebreaks
        //  Strip HTML tags out
        //  unescape HTML (ex: convert "&gt;" to ">")
        
        if(strInput == null){
            return '';
        }
        String strReturn = strInput.replaceAll('<br>', '\n');
        strReturn = strReturn.replaceAll('<br />', '\n');
        strReturn = strReturn.replaceAll('<br/>', '\n');
        //Regex to match all HTML tags
        string regex = '<.*?>';
        pattern htmlPattern = pattern.compile(regex);
        matcher htmlMatcher = htmlPattern.matcher(strReturn);
        strReturn = htmlMatcher.replaceAll('');
        //unescape HTML
        strReturn = strReturn.unescapeHtml4();
        return strReturn;
    }
    
    Public Static Set<String> extractEmailAddresses (String strInput){
        // This function will extract all email addresses from a 
        // provided string and return them as a set
        
        String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';      
        Pattern emailPattern = Pattern.compile(regex);   
        Matcher emailMatcher = emailPattern.matcher(strInput);
        Set<String> result = new Set<String>();
        
        //Find all matches
        if(emailMatcher.find()) {
        	do {
            	result.add(emailMatcher.group());
          	}while(emailMatcher.find());
		}
        return result;
    }
    
}