public without sharing class SRPAcceptApplicationController {
	
	List<DeltakSRP__Student_Online_Application__c> soalist = new List<DeltakSRP__Student_Online_Application__c>();
	List<DeltakSRP__Student_Online_Application__c> soalist2Update = new List<DeltakSRP__Student_Online_Application__c>();
	public String returnUrl;
	
	public PageReference UpdateApplications(){
		system.debug('soalist2>>>>'+soalist);
		List<Opportunity> oppList = new List<Opportunity>();
		List<Opportunity> opps2Update = new List<Opportunity>();
		List<Id> oppIds = new List<Id>();
		DeltakSRP__Student_Online_Application__c app;
		List<Id> soaIds = new List<Id>();
		List<DeltakSRP__Student_Online_Application__c> soalist2 = new List<DeltakSRP__Student_Online_Application__c>();
		
		for(DeltakSRP__Student_Online_Application__c soa: soalist){
			soaIds.add(soa.Id);
		}
		
		soalist2 = [Select deltakSRP__Affiliation_Opportunity__c, OwnerId, DeltakSRP__Application_Status__c from
			DeltakSRP__Student_Online_Application__c where Id in: soaIds];
			
		for(DeltakSRP__Student_Online_Application__c soa: soalist2){
			oppIds.add(soa.deltakSRP__Affiliation_Opportunity__c);
			app = soa;
			app.OwnerId = Userinfo.getUserId();
			app.DeltakSRP__Application_Status__c = 'Under Review';
			soalist2Update.add(app);
		}
		
		
		oppList = [Select StageName from Opportunity where Id in: oppIds];
		
		for(Opportunity o: oppList){
			Opportunity o2 = o;
			o2.StageName = 'Booked Qualified Application';
			opps2Update.add(o2);
		}
		
		if(soalist2update.size() > 0)
			update soalist2Update;
		
		if(opps2Update.size()>0)
			update opps2Update;
		
		if(test.isrunningTest())
			returnurl = 'www.salesforce.com';
		PageReference p = new PageReference(returnUrl);
		return p;
	}
	
	public SRPAcceptApplicationController(ApexPages.StandardSetController standardSetController){
		soalist = (List<DeltakSRP__Student_Online_Application__c>) standardSetController.getSelected();
		system.debug('soalist>>>>'+soalist);
		system.debug('size>>>>'+soalist.size());
		returnUrl = Apexpages.currentPage().getParameters().get('retURL');
	}
}