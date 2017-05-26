public class CampaignAdministrationController {

    public String searchText { get; set; }
    public  Campaign [] campaigns{ get; set; }
    
    public  Campaign_Picklist__c [] pickListValues { get; set; }
    
     
    
    public PageReference campaignSearch() {
            string search = searchText + '%';
        campaigns = [SELECT Id, Campaign_Code__c, Name FROM Campaign WHERE Name LIKE :search AND  isActive = True AND Lowest_Level_in_Hierarchy__c = True];
        return null;
    }
    
    public PageReference campaignsExisting() {
        pickListValues = [SELECT Name, Campaign_Code__c, Page__c FROM Campaign_Picklist__c];
        return null;
    }
	
	

    static testMethod void myUnitTest() {
    	CampaignAdministrationController campaignAdmin = new  CampaignAdministrationController();
    	campaignAdmin.campaignSearch();
    	campaignAdmin.campaignsExisting();
    
    }
}