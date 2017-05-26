public class CampaignComonentController {
    
    //public string campaignName {get; set}
    private boolean adding = false;
    public string campaignName {get; set; }
   
	
    public string campaignCode {get; set;}
    public string friendlyName {get; set;}
    
    public CampaignComonentController() {
    	
    }
    
    public PageReference  add() {
    	
    	    	
        Campaign_Picklist__c addition = new Campaign_Picklist__c();
        if (friendlyName == null || friendlyName == '') {
        	addition.Name = campaignName;
        }
        
        else {
        	addition.Name = friendlyName;
        }
        addition.Campaign_Code__c = campaignCode;
        addition.Page__c = 'New Inquiry';
        
        try {
            insert addition;
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }
        
        
        
        return null;
    }
    
     static testMethod void myUnitTest() {
    	CampaignComonentController c = new CampaignComonentController();
    	c.friendlyName = 'Test';
    	c.campaignName = 'Test';
    	c.campaignCode = 'TestCode';
    	
    	
    	c.add();
    	
    	//try to add it again to cause the catch() to happen
    	c.add();
    	
    	
    	CampaignComonentController c2 = new CampaignComonentController();
    	c2.friendlyName = '';    	
    	c2.campaignName = 'Test2';
    	c2.campaignCode = 'TestCode2';
    	c2.add();
    	
    }
}