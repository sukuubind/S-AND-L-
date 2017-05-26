trigger webmail_Synced_Email_Triggers on Webmail_Synced_Emails__c (before update) {
	
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            webmail_Synced_Email_TriggerHandler.ReconcileWebmailSyncedMail_After(Trigger.New, Trigger.OldMap);
            //Saved Cached objects
            webmail_Synced_Email_TriggerHandler.SaveAllUpdatedObjects(Trigger.New);
        }
    }
 
}