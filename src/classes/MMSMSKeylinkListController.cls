public class MMSMSKeylinkListController {
    public MMSMSKeylinkListController() {
    }
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select Id, Keyword__c, CreateAffliliation__c, CreateOpportunity__c, NotifyTo__c, IsActive__c from MMSMSKeylink__c]));
            }
            return setCon;
        }
        set;
    }
    
    public List<MMSMSKeylink__c> getKeylinkList() {
        List<MMSMSKeylink__c> recs = (List<MMSMSKeylink__c>) setCon.getRecords();
        for (MMSMSKeylink__c obj : recs) {
            obj.NotifyTo__c = MMUtils.stringEmptyNull(obj.NotifyTo__c) ? '-' : obj.NotifyTo__c;
            obj.Keyword__c = MMUtils.stringEmptyNull(obj.Keyword__c) ? '-' : obj.Keyword__c;            
        }
         return recs;
    }
}