trigger SRPOpportunitybeforeUpdate on Opportunity (before update) {
    
	SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityBeforeUpdateTrigger__c); 
    
    if(bypassTrigger)   return; 
	    
    
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
    
    if (!loggedInUser.Profile.Name.contains('Integration')) {
        
        List <Opportunity> updateOppsSDChangeOLD = new List <Opportunity>();
        List <Opportunity> updateOppsSDChangeNEW = new List <Opportunity>();
                
        List <Opportunity> updateOppsSDChangedToNullNEW = new List <Opportunity>();
        
        List <Opportunity> updateOppsReferredByOLD = new List <Opportunity>();
        List <Opportunity> updateOppsReferredByNEW = new List <Opportunity>();
        
        List <Opportunity> updateOppsContactChangedOLD = new List <Opportunity>();
        List <Opportunity> updateOppsContactChangedNew = new List <Opportunity>();
        
        List <Opportunity> updateOppsSalesStageChangedOLD = new List <Opportunity>();
        List <Opportunity> updateOppsSalesStageChangedNEW = new List <Opportunity>();
        
        List <Opportunity> updateOppsProgramChangedOLD = new List <Opportunity>();
        List <Opportunity> updateOppsProgramChangedNEW = new List <Opportunity>();
 
        //added for webscheduler opportunity update        
        List <Opportunity> updateOppsWebSchedulerStatusNEW = new List <Opportunity>();
        
        //-----------------------------------------------------------------------
        // Go through the Trigger.new records and put them into lists to be 
        // updated based on what fields have changed 
        //-----------------------------------------------------------------------       
          //get the record types and put them in a map
        Map<string, id> recordTypeName_to_recordTypeId = new Map<string, id>();
        Set<Id> TriggerIds = new Set<Id>();
        Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();             
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();                
        for (Schema.RecordTypeInfo rtInfo : RT) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }
        
        //get the new WhatIDs pulled in trhough the trigger
        for(Opportunity c : Trigger.new) {
            ID RecTtype = c.RecordTypeId;
            if (recordTypeName_to_recordTypeId.get('SRP Opportunity') == RecTtype) {
                TriggerIds.add(c.Id);      
            }           
        }
        for (integer record = 0; record < Trigger.new.size(); record++) { 
            Opportunity newRecord = Trigger.new[record];
            Opportunity oldRecord = Trigger.old[record];  
            if(TriggerIds.contains(newRecord.Id)){
                if (newRecord.deltaksrp__Start_Date__c != oldRecord.deltaksrp__Start_Date__c && newRecord.deltaksrp__Start_Date__c != null) {
                    updateOppsSDChangeOLD.add(oldRecord);
                    updateOppsSDChangeNEW.add(newRecord);
                }
                 
                if (newRecord.deltaksrp__Start_Date__c != oldRecord.deltaksrp__Start_Date__c && newRecord.deltaksrp__Start_Date__c == null) {                
                    updateOppsSDChangedToNullNEW.add(newRecord);
                }
                
                if (newRecord.Referred_By_opportunity__c != oldRecord.Referred_By_opportunity__c) {
                    updateOppsReferredByOLD.add(oldRecord);
                    updateOppsReferredByNEW.add(newRecord);
                }
                
                if (newRecord.deltaksrp__Student__c != oldRecord.deltaksrp__Student__c ) {
                    updateOppsContactChangedOLD.add(oldRecord);
                    updateOppsContactChangedNEW.add(newRecord);
                }
                
                if (newRecord.DeltakSRP__Academic_Program__c != oldRecord.DeltakSRP__Academic_Program__c ) {
                    updateOppsProgramChangedOLD.add(oldRecord);
                    updateOppsProgramChangedNEW.add(newRecord);
                }
                
                if (newRecord.StageName != oldRecord.StageName &&
                newRecord.StageName == 'Start' && 
                newRecord.AccountId != null && 
                newRecord.DeltakSRP__Academic_Program__c != null && 
                newRecord.deltaksrp__Start_Date__c != null) {
                    updateOppsSalesStageChangedOLD.add(oldRecord);
                    updateOppsSalesStageChangedNEW.add(newRecord);
                }
                
                //added for webscheduler if status updated to new - remove previous event
                if(newRecord.DeltakSRP__webschedulerstatus__c == 'New'){ 
                 if((oldRecord.DeltakSRP__webschedulerstatus__c == 'Scheduled') || (oldRecord.DeltakSRP__webschedulerstatus__c == 'Rescheduled')){
                     updateOppsWebSchedulerStatusNEW.add(newRecord);
                 }
                }
            }
        }
        
        
        System.debug('------ OpportunityBeforeUpdate - Lists of opportunities to update based on what fields changed:');  
        System.debug('------ OpportunityBeforeUpdate - updateOppsSDChangeOLD : ' +  updateOppsSDChangeOLD);
        System.debug('------ OpportunityBeforeUpdate - updateOppsSDChangeNEW : ' +  updateOppsSDChangeNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsSDChangedToNullNEW : ' +  updateOppsSDChangedToNullNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsReferredByOLD : ' +  updateOppsReferredByOLD);
        System.debug('------ OpportunityBeforeUpdate - updateOppsReferredByNEW : ' +  updateOppsReferredByNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsContactChangedOLD : ' +  updateOppsContactChangedOLD);
        System.debug('------ OpportunityBeforeUpdate - updateOppsContactChangedNEW : ' +  updateOppsContactChangedNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsSalesStageChangedOLD : ' +  updateOppsSalesStageChangedOLD);
        System.debug('------ OpportunityBeforeUpdate - updateOppsSalesStageChangedNEW : ' +  updateOppsSalesStageChangedNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsProgramChangedOLD : ' +  updateOppsProgramChangedOLD);
        System.debug('------ OpportunityBeforeUpdate - updateOppsProgramChangedNEW : ' +  updateOppsProgramChangedNEW);
        System.debug('------ OpportunityBeforeUpdate - updateOppsWebSchedulerStatusNEW : ' +  updateOppsWebSchedulerStatusNEW);        
              
         
        
        //--------------------------------------
        //Do the opportunity updates 
        //--------------------------------------        
        System.debug('Do the opportunity updates ...');
        
        //if Start Date changed     
        if (updateOppsSDChangeOLD.size() > 0 && updateOppsSDChangeNEW.size() > 0) {
            System.debug('------ OpportunityBeforeUpdate - Start Date changed------');                        
            SRPOpp_StartDateChanged.findAcademicStartDateRecords(updateOppsSDChangeNEW);
        }
        
        //if Start Date changed to NULL     
        if (updateOppsSDChangedToNullNEW.size() > 0) {
            System.debug('--- OpportunityBeforeUpdate - Start Date changed to NULL------');
            SRPOpp_StartDateChanged.startDateChangedToNull(updateOppsSDChangedToNullNEW);
        }
         
        //if Referred By changed to something or changed to NULL
       /* if (updateOppsReferredByOLD.size() > 0 && updateOppsReferredByNEW.size() > 0) {
            System.debug('--- OpportunityBeforeUpdate - Referred By changed to something or changed to NULL------');
            Opp_ReferredByChanged.referredByChanged(updateOppsReferredByOLD, updateOppsReferredByNEW);
        }*/
        
        //if contact changed to something or changed to NULL
        if (updateOppsContactChangedOLD.size() > 0 && updateOppsContactChangedNEW.size() > 0) {
            System.debug('--- OpportunityBeforeUpdate - Referred By changed to something or changed to NULL------');
            SRPOpp_StudentChanged.studentChanged(updateOppsContactChangedOLD, updateOppsContactChangedNEW);
        }
        
        //if sales stage changed to 'Start'
       /* if (updateOppsSalesStageChangedOLD.size() > 0 && updateOppsSalesStageChangedNEW.size() > 0) {
            System.debug('--- OpportunityBeforeUpdate - sales stage changed to Start ------');            
            //Opp_SalesStageChanged.salesStageChanged(updateOppsSalesStageChangedNEW);
            
        }*/
        
        //if program changed to NULL
        if (updateOppsProgramChangedOLD.size() > 0 && updateOppsProgramChangedNEW.size() > 0) {
            System.debug('--- OpportunityBeforeUpdate - program changed to NULL ------');            
            SRPOpp_ProgramChanged.programChangedToNull(updateOppsProgramChangedOLD, updateOppsProgramChangedNEW);
            
        }
        
        //if webscheduler status changed to New
        /*if(updateOppsWebSchedulerStatusNEW.size() > 0){
            System.debug('--- OpportunityBeforeUpdate - WebScheduler Status changed to New -');
            WebSchedulerUtils.bulkCancelAppointment(updateOppsWebSchedulerStatusNEW);
            
        }*/
        
        //Corporate Partner Enhancement Related
        //By: AbhaS
        Map<string, id> recordTypeName_to_recordTypeId_Opps = new Map<string, id>();
        
        Map<id, Opportunity> OppId_to_AccountId = new Map<id, Opportunity>();
        Set<Id> TriggerOppIds = new Set<Id>(); //Holds Ids of Opportunities of Record Type: Corporate
        Set<Id> TriggerAccountIds = new Set<Id>();
        
        
        Schema.DescribeSObjectResult R_Opps = Opportunity.SObjectType.getDescribe();         
        List<Schema.RecordTypeInfo> RT_Opps = R_Opps.getRecordTypeInfos(); 
                   
        for (Schema.RecordTypeInfo rtInfo : RT_Opps) {
            System.debug(rtInfo.getName());
            System.debug(rtInfo.getRecordTypeId());
            recordTypeName_to_recordTypeId_Opps.put(rtInfo.getName(),rtInfo.getRecordTypeId() );         
        }   
        
        for (Opportunity opps : trigger.new) {
            ID RecTtype = opps.RecordTypeId;
            ID recTypeNameToId = recordTypeName_to_recordTypeId.get('Deltak Corporate Opportunity');
            
            //AAC updated to check for stage to reduce number for query
          
                if ((recTypeNameToId == RecTtype) && (opps.StageName == 'Closed Won')) {
                    System.debug('populating the set and map');
                    TriggerOppIds.add(opps.Id);  
                    TriggerAccountIds.add(opps.AccountId);
                    OppId_to_AccountId.put(opps.AccountId,opps);
                    System.debug('Account associated with Opp '+opps.Id+'  is  '+opps.AccountId);    
                }
                     
        }
        
        /*Map<Id, List<Opportunity>> AccountId_To_ListOpps = new Map<Id, List<Opportunity>>();*/
        Opportunity oppHolder;
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Account> accsToUpdate = new List<Account>();
        
        //AAC check to see if the size is greater than zero to skip query if not needed
        if(TriggerAccountIds.size() >0){
            //Query to get the value of the 'Corporate Partner' field from the Account record
            List<Account> accountValues = [SELECT Id, Corporate_Partner__c
                                            FROM Account
                                            WHERE Id IN : TriggerAccountIds ];
            
            
                                            
            for (Account acc : accountValues){ 
           
                System.debug('Corporate_Partner__c = '+acc.Corporate_Partner__c);
                
                //loop through all the Opportunities for that Account record and find an Opportunity where stage = 'Closed/Won'
                if(acc.Corporate_Partner__c == false){
                
                oppHolder = OppId_to_AccountId.get(acc.Id);
                System.debug('OppID = '+oppHolder.StageName+' AccID = '+acc.Id);
                
                if(oppHolder.StageName == 'Closed Won'){
                    oppsToUpdate.add(oppHolder);
                    acc.Corporate_Partner__c = true;
                    accsToUpdate.add(acc);
                }
            } 
            
           
            } 
            System.debug('Updating the following accounts');
            System.debug(accsToUpdate);
            update accsToUpdate;
        
        //Corporate User Enahancement ends - AbhaS
        }
}
}