public class webmail_Synced_Email_TriggerHandler {
	
    Public static List<Task> taskForInsert = new List<Task>();
	Public Static List<ID> lstSyncedEmailToTaskInsert = new List<ID>();
    Public static boolean booTestForFailure = false;

    Public static void SaveAllUpdatedObjects(List<Webmail_Synced_Emails__c> listNewSyncedEmails){
        //All object updates in this handler will be cached and run at once to conserve DML
        If (taskForInsert.size()> 0){
            Map<ID, String> setSyncedEmailErrors = new Map<ID, String>();
            Database.SaveResult[] srList = Database.insert(taskForInsert, false);
            for(Integer i = 0; i < srList.size(); i++){
              	if (!srList[i].isSuccess()) {
                	String strError = '';
                    for(Database.Error err : srList[i].getErrors()) {
                        strError += 'An error occured during task insertion: ' + err.getStatusCode() + ': ' + err.getMessage();
                    }
                    setSyncedEmailErrors.put(lstSyncedEmailToTaskInsert[i], strError);
                }
            }
            
            if(setSyncedEmailErrors.size()>0){
                //loop through trigger elements to find a mactch and put error in
                for(Webmail_Synced_Emails__c se : listNewSyncedEmails){
                    if(setSyncedEmailErrors.get(se.ID) != null){
                        se.ErrorMessage__c = setSyncedEmailErrors.get(se.ID);
                        se.RecordTypeId = webmail_Utilities.getNeedsReconciliationRecordType(); 
                    }
                }
            }
        }
    }
    
    Public static void ReconcileWebmailSyncedMail_After(List<Webmail_Synced_Emails__c> listNewSyncedEmails, map<ID, Webmail_Synced_Emails__c> mapOldSyncedEmails){
        //This function will look for Synced Emails that have had a change in opportunity. 

        Set<ID> setSyncedEmailsToUpdate = new Set<ID>();
        Set<ID> setOppIDs = new Set<ID>();
        
        for (Webmail_Synced_Emails__c se: listNewSyncedEmails){
            //check for change in opportunity
            If (se.Opportunity__c != null && se.Opportunity__c != mapOldSyncedEmails.get(se.Id).Opportunity__c){
            	setOppIDs.add(se.Opportunity__c);
            } 
        }
        System.debug('setOppIDs: ' + setOppIDs);
        
        Map<ID, Opportunity> mapOpps = new Map<ID, Opportunity>([SELECT Id, OwnerID, DeltakSRP__Student__c, Student__c FROM Opportunity WHERE ID IN: setOppIDs]);
        
        for (Webmail_Synced_Emails__c se: listNewSyncedEmails){
            Boolean booReconciled = true;
            String strError = '';
            if (setOppIDs.contains(se.Opportunity__c)){
            	ID idContact;
            	Task taskNew = new task();
                //Owner of task should be same as opp owner
                taskNew.OwnerId = se.OwnerId;
                //Get contact from Opp
                if (mapOpps.get(se.Opportunity__c).Student__c != null){
                    idContact = mapOpps.get(se.Opportunity__c).Student__c;
                } else {
                    idContact = mapOpps.get(se.Opportunity__c).DeltakSRP__Student__c;
                }
                taskNew.WhoId = idContact;
                taskNew.WhatId = se.Opportunity__c;
                //force error for testing by putting too long a string in subject
                if(booTestForFailure){
                	taskNew.subject = 'cqh0oERuHQQUmybliwaTimm9UO1ZkXtLfBDHHGDDPtkEgndV3ayeVoNKECPHL2CUFKTo4SVA0iOf2AE9QMeGGogqpqJAZmXFqqStDveZ86qyF2tG6XJcbj66rxjKUUPScKgxBJZKlGvt35ml6Tu83SOloRFuclzVaRzmzT28v2ALZQXwSn4PvHfnlzIs5kbvTuRthZumk2x2LRAaCodMrxcwWmgJHHDp2i0EHr97IUFkevj62APDC0MqhNXR6VmCm';
                }else{
                	taskNew.Subject = se.Subject__c;
                }
                taskNew.Description = se.EmailBody__c;
                taskNew.Status = 'Completed';
                taskNew.Completed_Date__c = System.now(); 
                taskNew.DeltakSRP__Completed_Date__c = System.now();
                taskNew.ActivityDate = Date.Today();
                taskNew.Result__c = 'Successful';
                taskNew.DeltakSRP__Result__c = 'Successful';
                taskNew.Asked_for_Referral__c = 'No';
                taskNew.Type = 'Email';
                
                //keep track of Synced Email Id's to update record type
                if(booReconciled){
                    taskForInsert.add(taskNew);
                    lstSyncedEmailToTaskInsert.add(se.Id);
                    se.RecordTypeId = webmail_Utilities.getSuccessfulRecordType();
                    system.debug('-> 3');
                    se.Contact__c = idContact;
                }
                if(strError != '' || booReconciled){
                    se.ErrorMessage__c = strError;
                }    
            } else {
            	se.RecordTypeId = webmail_Utilities.getNeedsReconciliationRecordType(); 
            }
        } 
    }
        
}