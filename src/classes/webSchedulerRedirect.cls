global without sharing class webSchedulerRedirect {
	public String pmId {get;set;}
	
	public webSchedulerRedirect()
	{
		pmId = Apexpages.currentPage().getParameters().get('pmid');
	}
	
}