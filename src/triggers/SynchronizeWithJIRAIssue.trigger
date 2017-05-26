trigger SynchronizeWithJIRAIssue on Case (after update) {
   
    // Check whether current user is not JIRA agent so that we don't create an infinite loop.
    if (JIRA.currentUserIsNotJiraAgent()) {
        for (Case c : Trigger.new) {  
            String objectType ='CASE'; //Please change this according to the object type
            String objectId = c.id;
            if (c.JIRA_Ticket_Exists__c)
            {
                // Calls the actual callout to synchronize with the JIRA issue.
                JIRAConnectorWebserviceCalloutSync.synchronizeWithJIRAIssue(JIRA.baseUrl, Label.JIRA_System_ID, objectType, objectId);
            }
        }
    }
 
}