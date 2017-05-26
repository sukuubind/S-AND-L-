public class MMUtilConstants {
    public static string mm_userid = '';//'MessageUPtyLt128';
    public static string mm_password = '';//'folio1';
    
    public static string smsURL = 'https://soap.m4u.com.au/';
    public static string xmlContentType = 'text/xml; charset=utf-8';
    
    public static integer batchSize = 100;
    
    //public static string publicUrl = 'http://mm-sms.smsconfig1.cs13.force.com/mmsms';
    
    public static string getPublicUrl() {
        return MMKeylinkSettings__c.getAll().values().get(0).MM_Public_URL__c;
    }
    
    public static string getReplyUrl() {
        return MMKeylinkSettings__c.getAll().values().get(0).MM_Reply_URL__c;
    }
    
    public static string getPageSize() {
        return String.valueOf(MMKeylinkSettings__c.getAll().values().get(0).MM_Page_Size__c);
    }
    
    public static string getDefaultEmail() {
        return String.valueOf(MMKeylinkSettings__c.getAll().values().get(0).NotifyTo__c);
    }
    
    public static string getDefaultName() {
        return String.valueOf(MMKeylinkSettings__c.getAll().values().get(0).Notify_To_Name__c);
    }
}