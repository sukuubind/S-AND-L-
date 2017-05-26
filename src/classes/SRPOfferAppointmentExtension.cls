public with sharing class SRPOfferAppointmentExtension {

	ApexPages.StandardController stdController;
	private Opportunity stdopp;
	
	public SRPOfferAppointmentExtension(ApexPages.StandardController stdController){
	this.stdopp =  (Opportunity)stdController.getRecord();
	
	 
	}

    public PageReference updateWebSchedulerStatus() {
 
        String theId = ApexPages.currentPage().getParameters().get('id');
        String cId;
        
        system.debug('stdopp>>>'+stdopp);
 		cId = ApexPages.currentPage().getParameters().get('cid');
        
 		system.debug('theID>>>>'+theID);
 		system.debug('cid>>>>'+cid);
 		
        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }
 
         stdopp = [Select id, webschedulerstatus__c, webscheduler_user__c FROM Opportunity where ID = :theId limit 1];
         stdopp.DeltakSRP__webschedulerstatus__c = 'New';
         stdopp.webscheduler_user__c = userinfo.getuserid();
        update stdopp;
      
        // Redirect the user back to the original page
        if(cid != null){
      		PageReference pageRef = new PageReference('/' + cId);
	        pageRef.setRedirect(true);
	        return pageRef;
      	}else{
	        // Redirect the user back to the original page
	        PageReference pageRef = new PageReference('/' + theId);
	        pageRef.setRedirect(true);
	        return pageRef;
      	}
 
    }

}