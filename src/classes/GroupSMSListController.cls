public class GroupSMSListController {
    public Integer pageNumber = 0;
    public Integer pageSize = 0;
    
    public GroupSMSListController() {
         pageSize = Integer.valueOf(MMUtilConstants.getPageSize());
    }
    
    public GroupSMSListController(boolean isTest) {
        if (isTest)
            pageSize = 10;
        else
            pageSize = Integer.valueOf(MMUtilConstants.getPageSize());
    }
    
     public PageReference previous() {
        pageNumber--;
        if (pageNumber < 0) {
            pageNumber = 0;
        }
        return null;
    }
    
    public PageReference next() {
        pageNumber++;
        return null;
    }
    
    private List<MMGroupSMS__c> getListRecords() {
        Integer offset = pageNumber * pageSize;
        String query = 'select Id, Name, Subject__c, isScheduled__c, ids__c, TimeZone__c, StartTime__c, StartDate__c, Multipart__c, ' +
                        'Message__c, IsTrackDelivery__c, Header__c, Footer__c, EntityType__c from MMGroupSMS__c order by LastModifiedDate desc LIMIT ' +
                        pageSize + ' OFFSET ' + offset;
        return (List<MMGroupSMS__c>) Database.query(query);
    }
    
    public List<MMGroupSMS__c> getGroupSMSList() {
        List<MMGroupSMS__c> listGroups = null;
        try {
            listGroups = getListRecords();
            if (listGroups == null || listGroups.size() == 0) {
                if (pageNumber > 0) pageNumber--;
                    listGroups = getListRecords();                
            }
        }
        catch(Exception exp) {
            ApexPages.addMessages(exp);
        }
        return listGroups;
    }
    
    public PageReference newGroupSMS(){
        PageReference pr = new PageReference('/apex/batchsms?id=&src=new');
        pr.setRedirect(true);
        return pr;
    }
}