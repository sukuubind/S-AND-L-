public class MMSMSTemplateListController {
    public Integer pageNumber = 0;
    public Integer pageSize = 0;

    public MMSMSTemplateListController() {
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
    
    private List<MMSMSTemplate__c> getListRecords() {
        Integer offset = pageNumber * pageSize;
        String query = 'select Id, TemplateName__c, Template__c from MMSMSTemplate__c order by LastModifiedDate DESC LIMIT ' +
                        pageSize + ' OFFSET ' + offset;
        return (List<MMSMSTemplate__c>) Database.query(query);
    }
    
    public List<MMSMSTemplate__c> getTemplateList() {
        List<MMSMSTemplate__c> listTemplates = null;
        try {
            listTemplates = getListRecords();
            if (listTemplates == null || listTemplates.size() == 0) {
                if (pageNumber > 0) pageNumber--;
                    listTemplates = getListRecords();                
            }
        }
        catch(Exception exp) {
            ApexPages.addMessages(exp);
        }
        return listTemplates;
    }
    
    public PageReference newSMSTemplate(){
        PageReference pr = new PageReference('/apex/mmsmstemplate');
        pr.setRedirect(true);
        return pr;
    }
}