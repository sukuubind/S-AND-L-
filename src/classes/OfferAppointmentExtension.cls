public class OfferAppointmentExtension{

ApexPages.StandardController stdController;
private Opportunity stdopp;

public OfferAppointmentExtension(ApexPages.StandardController stdController){
this.stdopp =  (Opportunity)stdController.getRecord();

 
}

    public PageReference updateWebSchedulerStatus() {
 
        String theId = ApexPages.currentPage().getParameters().get('id');
 
        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }
 
         stdopp = [Select id, webschedulerstatus__c FROM Opportunity where ID = :theId limit 1];
         stdopp.webschedulerstatus__c = 'New';
        update stdopp;
 
        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
 
    }

}