global without sharing class webmailSyncedOpportunityEmailReceiver implements Messaging.InboundEmailHandler {
    
    //TODO: remove comment below before PROD push
    //synced_opportunity_emails@1h7bcui0d5ui0e7k9qw8ldtsp5szr7xwjcupg35wdbzofw7i6d.g-6r6baeac.cs17.apex.sandbox.salesforce.com
    
    Public static boolean booTestForFailure = false;
    
    //-- Main
    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        // REQUIREMENTS
        // 
        // 1. System must find the correct opportunity for the email synced from the partner email address 
        // 2. System must create a task and set the fields on the task object appropriately for the email synced from the partner email address. 
        // 3. (OUTSIDE SFDC SCOPE) An auto forward rule should be set up for the email received from the student in the partner email server. 
        // 4. (OUTSIDE SFDC SCOPE) An auto forward rule should be set up for any outbound email sent from the partner email server. 
        // 5. System must hold any email that is unable to be matched with an opportunity. 
        // 6. System must provide the ability to create a task and associate to an opportunity by click of a button for emails held without automatic association through interception. 
        // 7. System must be able to report on all emails synced from the partner email server. 
        // 8. System must be secure to not show the held emails to other users. Only the owner of the emails, the managers of the owners and system admins should have the ability to see the held emails.
        //  
        // NOTE: Inbound Email Services are always single context. This is a rare instance where bulkification practices are not appropriate.
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //TODO: Remove or comment out ALL System.debug statements before PROD push

        String strError = '';
        ID idSender;
        ID idInstitution;
        ID idOpportunity;
        ID idContact;
        
        Set<ID> setAllContactIDs = new Set<ID>();
        //in the unlikely event there is no from address on the email we will just end up adding the synced mail record without an owner
        List<String> emailFromAddressList = new List<String>();
        If (envelope.fromAddress != null){
            emailFromAddressList.add(envelope.fromAddress);
            String[] splitEmail = String.valueOf(envelope.fromAddress).split('=');
            if(splitEmail != null && splitEmail.size() > 0){
                try{
                    String thirdPartEmail = splitEmail[2];
                    emailFromAddressList.add(thirdPartEmail);
                }catch(Exception e){
                    System.Debug('It is okay to have the exception. Look at the Email, it looks correct - '+envelope.fromAddress);
                }
            }
            //Check custom webamil User Email object for email associated with user in case it is not the main user email
            //If there are no matches, Sender not found, and idSender will not be populated, and record type will be needs reconciliation
            System.debug('envelope.fromAddress-->'+envelope.fromAddress);
            System.Debug('emailFromAddressList -- '+emailFromAddressList);
            List<WebmailUserEmail__c> lstWUESendingUser = [SELECT ID, Academic_Institution__c, User__c, EmailAddress__c, User__r.UserName FROM WebmailUserEmail__c WHERE EmailAddress__c IN :emailFromAddressList];
            System.debug('lstWUESendingUser: ' + lstWUESendingUser);
            If (lstWUESendingUser.size() > 0){
               
                //Field on object is set to unique so there should only ever be 1 SOQL result, use first list position
                idSender = lstWUESendingUser[0].User__c;
                //We have the sender, now we need to find the Organization (Account)
                //via Campus_Contacts__c junction object
                List<Campus_Contacts__c> lstCampusContacts = [SELECT id, Organization__c FROM Campus_Contacts__c WHere Employee__c =: idSender and Organization__c =: lstWUESendingUser[0].Academic_Institution__c];
                If (lstCampusContacts.size() < 1 || lstCampusContacts[0].Organization__c == null){
                    //The sending user is not associated as a campus contact, EXIT
                    
                    return result;
                }
                idInstitution = lstCampusContacts[0].Organization__c;
                
                //Get ALL email addresses in the email body to be used for opportunity match search
                Set<String> setEmailMatches = New Set<String>();
                
                If (email.plainTextBody != null){
                    setEmailMatches = webmail_Utilities.extractEmailAddresses(email.plainTextBody);
                }else if(email.htmlBody != null && email.plainTextBody == null){
                    setEmailMatches = webmail_Utilities.extractEmailAddresses(email.htmlBody);
                } else {
                    //no body, nothing to do
                    return result;
                } 
                
                //we also need to get To addresses in the set for when bcc is used.
                if (email.toAddresses != null) {
                     for(String strTO: email.toAddresses)   {
                         setEmailMatches.add(strTO); 
                     }
                }
                
                //Create a lowercase Map and use it in place of setEmailMatches SET- VR-SRP-2015
                Map<String,String> setEmailMap = new Map<String,String>();
                for(String sem: setEmailMatches)
                {
                    setEmailMap.put(sem.toLowerCase(),sem);
                }
                
                //remove the email used by the service in case it is in the communication via replies / forwards
                //setEmailMatches.remove(webmail_Utilities.getCSWebmailReceieverAddress()); VR-SRP-2015
                setEmailMap.remove((webmail_Utilities.getCSWebmailReceieverAddress()).toLowerCase());
                //remove the from Address - VR -SRP-2015
                system.debug('envelope.fromAddress: ' + envelope.fromAddress);
                system.debug('setEmailMap Before: ' + setEmailMap);
                system.debug('setEmailMap Contains: '+setEmailMap.containsKey((envelope.fromAddress).toLowerCase()));
                if(setEmailMap.containsKey((envelope.fromAddress).toLowerCase()))
                    setEmailMap.remove((envelope.fromAddress).toLowerCase());
                //Query extracted emails to find contact / opp
                //Look up possible opps, Contact will be in either DeltakSRP__Student__c or Student__c - VR-SRP-2015
                system.debug('setEmailMap: ' + setEmailMap);
                System.debug('idInstitution: ' + idInstitution);
                List<Opportunity> lstOpps =[SELECT id, Name, DeltakSRP__Student__c, Student__c, DeltakSRP__Active_Inquiry__c, Active_Inquiry__c,
                                            Days_Since_Last_Attempt__c, DeltakSRP__Days_Since_Last_Attempt__c, Days_Since_Last_Contact__c, DeltakSRP__Days_Since_Last_Contact__c
                                            FROM Opportunity WHERE (Email__c IN: setEmailMap.values() OR DeltakSRP__Student__r.Email IN: setEmailMap.values() OR Student__r.Alternate_Email__c IN :setEmailMap.values()
                                            OR Student__r.Assistant_Email__c IN :setEmailMap.values() OR DeltakSRP__Student__r.DeltakSRP__Other_Email__c IN :setEmailMap.values() 
                                            OR DeltakSRP__Student__r.DeltakSRP__Student_Email__c IN :setEmailMap.values() 
                                            OR Student__r.Student_Email__c IN :setEmailMap.values() OR DeltakSRP__Student__r.DeltakSRP__Work_Email__c IN :setEmailMap.values()) AND AccountID =: idInstitution];
                System.debug('lstOpps: ' + lstOpps);
                //If only one opportunity we want to include it in the Synced Webmail Insert
                If(lstOpps.size()==1){
                    idOpportunity = lstOpps[0].id;
                    if (lstOpps[0].DeltakSRP__Student__c != null){
                        setAllContactIDs.add(lstOpps[0].DeltakSRP__Student__c);
                    }
                    if (lstOpps[0].Student__c != null){
                        setAllContactIDs.add(lstOpps[0].Student__c);
                    }
                            
                } else if (lstOpps.size()>1) {
                    //If > 1 opps, seek active Opp, If > 1 Active Opp, find most recent one
                    Integer intActiveCount = 0;
                    Decimal decBestLastContactOrAttemptDays = -1;
                    Decimal decLoopLastContactOrAttemptDays = -1;
                    Decimal decInactiveBestLastContactOrAttemptDays = -1;
                    Decimal decInactiveLoopLastContactOrAttemptDays = -1;
                    //First pass, populate Contact Set and determine if there are ANY active opps
                    for(Opportunity o : lstOpps){
                        //store contacts
                        if (o.DeltakSRP__Student__c != null){
                            setAllContactIDs.add(o.DeltakSRP__Student__c);
                        }
                        if (o.Student__c != null){
                            setAllContactIDs.add(o.Student__c);
                        }
                        If(o.DeltakSRP__Active_Inquiry__c == 'TRUE' || o.Active_Inquiry__c == 'TRUE'){
                            intActiveCount++;
                        }
                    }
                    
                    for(Opportunity o : lstOpps){
                        If(intActiveCount > 0 && (o.DeltakSRP__Active_Inquiry__c == 'TRUE' || o.Active_Inquiry__c == 'TRUE')){
                            //-- ACTIVE OPPS
                            //If there is more than one active, we need to determine which one has the most recent activity
                            //Any of the four "since" fields may have data, so first figure out which is the youngest of the four in this iteration,
                            //then compare against the best from previous iterations
                            if (o.Days_Since_Last_Attempt__c != null && (decLoopLastContactOrAttemptDays > o.Days_Since_Last_Attempt__c || decLoopLastContactOrAttemptDays == -1)){
                                decLoopLastContactOrAttemptDays = o.Days_Since_Last_Attempt__c;
                            }
                            if (o.DeltakSRP__Days_Since_Last_Attempt__c != null && (decLoopLastContactOrAttemptDays > o.DeltakSRP__Days_Since_Last_Attempt__c || decLoopLastContactOrAttemptDays == -1)){
                                decLoopLastContactOrAttemptDays = o.DeltakSRP__Days_Since_Last_Attempt__c;
                            }
                            if (o.Days_Since_Last_Contact__c != null && (decLoopLastContactOrAttemptDays > o.Days_Since_Last_Contact__c || decLoopLastContactOrAttemptDays == -1)){
                                decLoopLastContactOrAttemptDays = o.Days_Since_Last_Contact__c;
                            }
                            if (o.DeltakSRP__Days_Since_Last_Contact__c != null && (decLoopLastContactOrAttemptDays > o.DeltakSRP__Days_Since_Last_Contact__c || decLoopLastContactOrAttemptDays == -1)){
                                decLoopLastContactOrAttemptDays = o.DeltakSRP__Days_Since_Last_Contact__c;
                            }    
                            if(decLoopLastContactOrAttemptDays < decBestLastContactOrAttemptDays || decBestLastContactOrAttemptDays == -1){
                                decBestLastContactOrAttemptDays = decLoopLastContactOrAttemptDays;
                                //we have found an active opp that is so far the youngest, store it for insertion
                                idOpportunity = o.id;
                            } 
                        } else if (intActiveCount == 0 && o.DeltakSRP__Active_Inquiry__c == 'FALSE' && o.Active_Inquiry__c == 'FALSE') {
                            //same process as above but for INACTIVE OPPS
                            if (o.Days_Since_Last_Attempt__c != null && (decInactiveLoopLastContactOrAttemptDays > o.Days_Since_Last_Attempt__c || decInactiveLoopLastContactOrAttemptDays == -1)){
                                decInactiveLoopLastContactOrAttemptDays = o.Days_Since_Last_Attempt__c;
                            }
                            if (o.DeltakSRP__Days_Since_Last_Attempt__c != null && (decInactiveLoopLastContactOrAttemptDays > o.DeltakSRP__Days_Since_Last_Attempt__c || decInactiveLoopLastContactOrAttemptDays == -1)){
                                decInactiveLoopLastContactOrAttemptDays = o.DeltakSRP__Days_Since_Last_Attempt__c;
                            }
                            if (o.Days_Since_Last_Contact__c != null && (decInactiveLoopLastContactOrAttemptDays > o.Days_Since_Last_Contact__c || decInactiveLoopLastContactOrAttemptDays == -1)){
                                decInactiveLoopLastContactOrAttemptDays = o.Days_Since_Last_Contact__c;
                            }
                            if (o.DeltakSRP__Days_Since_Last_Contact__c != null && (decInactiveLoopLastContactOrAttemptDays > o.DeltakSRP__Days_Since_Last_Contact__c || decInactiveLoopLastContactOrAttemptDays == -1)){
                                decInactiveLoopLastContactOrAttemptDays = o.DeltakSRP__Days_Since_Last_Contact__c;
                            }    
                            if((decInactiveLoopLastContactOrAttemptDays < decInactiveBestLastContactOrAttemptDays || decInactiveBestLastContactOrAttemptDays == -1) && intActiveCount == 0){
                                decInactiveBestLastContactOrAttemptDays = decInactiveLoopLastContactOrAttemptDays;
                                //we have found an inactive opp that is so far the youngest, store it for insertion, but only if we have not found active opps
                                idOpportunity = o.id;
                            }
                        }
                    }
                }
            } else {
                strError += 'Sender\'s email: '+ envelope.fromAddress +' is missing in WebmailUserEmail__c (Webmail User Emails). Sender\'s email needs to be associated in WebmailUserEmail__c to prevent this from happening again.';
            }
           
        }else{
            strError += 'Email sender was empty, this record needs to be connected with the correct opportunity.';
        }
        
        System.debug('idOpportunity: ' + idOpportunity);
        
        //Create Task Description from Email Body        
        String strTaskDescription;
        If (email.plainTextBody != null){
            //Plain text should not need edits
            strTaskDescription = email.plainTextBody;
        }else{
            strTaskDescription = webmail_Utilities.stripHTML(email.htmlBody);
        }
        //Truncate Email body if necessary
        if(strTaskDescription.length()>32000){
            System.debug('Body Truncation Happened');
            strTaskDescription = strTaskDescription.left(32000);
        }
        
        String strSubject;
        if(email.subject.length() > 255){
            strSubject = email.subject.left(255);
        } else if(email.subject.length() <1) {
            strSubject = 'No Subject';
        } else {
            strSubject = email.subject;
        }
        
        //Create Task If Oppotunity is defined
        Task taskNew = new Task();
        if(idOpportunity != null && setAllContactIDs.size()==1){
            taskNew.OwnerId = idSender;
            taskNew.WhoId = new list<ID>(setAllContactIDs)[0];
            taskNew.WhatId = idOpportunity;
            if(booTestForFailure){
                taskNew.subject = 'cqh0oERuHQQUmybliwaTimm9UO1ZkXtLfBDHHGDDPtkEgndV3ayeVoNKECPHL2CUFKTo4SVA0iOf2AE9QMeGGogqpqJAZmXFqqStDveZ86qyF2tG6XJcbj66rxjKUUPScKgxBJZKlGvt35ml6Tu83SOloRFuclzVaRzmzT28v2ALZQXwSn4PvHfnlzIs5kbvTuRthZumk2x2LRAaCodMrxcwWmgJHHDp2i0EHr97IUFkevj62APDC0MqhNXR6VmCm';
            }else{
                taskNew.Subject = strSubject;
            }
            taskNew.Description = strTaskDescription;
            taskNew.Status = 'Completed';
            taskNew.Completed_Date__c = System.now(); 
            taskNew.DeltakSRP__Completed_Date__c = System.now();
            taskNew.ActivityDate = Date.Today();
            taskNew.Result__c = 'Successful';
            taskNew.DeltakSRP__Result__c = 'Successful';
            taskNew.Asked_for_Referral__c = 'No';
            taskNew.Type = 'Email';
            try{
                insert taskNew;
            }catch(Exception e) {
                strError += 'Error occurred inserting Task: ' + e.getMessage();
            }
        }
        
        //Populate and insert Webmail Synced Mail object
        Webmail_Synced_Emails__c objSyncedEmail = new Webmail_Synced_Emails__c();
        if(idSender == null){ 
            objSyncedEmail.OwnerId = webmail_Utilities.getCSReconciliationUserID();
        }else{
            objSyncedEmail.OwnerId = idSender;
        }
        objSyncedEmail.Subject__c = strSubject;
        objSyncedEmail.EmailBody__c = strTaskDescription;
        if(idInstitution != null){
            objSyncedEmail.Organization__c = idInstitution;
        }
        //To be Successful, we must have a clear opportunity AND only a single contact match across all found opportunities
        if(idOpportunity !=null && setAllContactIDs.size()==1){
            objSyncedEmail.Opportunity__c = idOpportunity;
            objSyncedEmail.Contact__c = new list<ID>(setAllContactIDs)[0];
            objSyncedEmail.RecordTypeId = webmail_Utilities.getSuccessfulRecordType();
        } else{
            objSyncedEmail.RecordTypeId = webmail_Utilities.getNeedsReconciliationRecordType();
        }
        if(strError !=''){
           objSyncedEmail.ErrorMessage__c = strError;
        }
        insert objSyncedEmail;

        return result;
    }
    
}