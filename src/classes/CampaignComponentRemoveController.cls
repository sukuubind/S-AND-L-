public class CampaignComponentRemoveController {
    public string campaignId {get; set;}
    
    public PageReference remove() {
        try {
            Campaign_Picklist__c campaignToRemove = [select id from Campaign_Picklist__c Where Id = :campaignId LIMIT 1];
        
            delete campaignToRemove;
        }
        
        catch(Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
     static testMethod void myUnitTest() {
    	CampaignComponentRemoveController c = new CampaignComponentRemoveController();
    	Campaign_Picklist__c cp = new Campaign_Picklist__c();
    	cp.Name = 'Test';
    	cp.Campaign_Code__c = 'TestCode';
    	cp.Page__c = 'New Inquiry';
    	insert cp;
    	c.campaignId = cp.Id;    	
    	c.remove();
    	
    	//try to remove it again to cause the catch() to happen
    	c.remove();
    	
    }
}