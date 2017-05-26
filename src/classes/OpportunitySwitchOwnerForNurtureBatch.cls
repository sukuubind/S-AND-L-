global class OpportunitySwitchOwnerForNurtureBatch implements Database.Batchable<sObject> { 
	
    Public String query;

    global OpportunitySwitchOwnerForNurtureBatch(){
        //TODO: Get Eloqua Marketing User ID
        //idNurtureUser = [Select Id FROM USER WHERE]
        
        //TODO: Get record Types IDs for query
        
        //TODO: Select ALL Opportunities that 
        //	- were created 60+ days ago
        //	- Current Stage is 'dormant'
        //	- substage or *substage is 'unable to contact'
        //	- owner is NOT Eloqua Marketing
        //	- Record type is 'Student opportunity' OR 'SRP Opportunity'

        Datetime dateTimetemp = System.now().adddays(-60);   
        query = 'SELECT id, OwnerID FROM Opportunity WHERE OwnerId != \''+ OpportunityUtilities.getNurtureUserID() +'\' AND Account.Nurture_Unable_To_Contact__c = True AND (DeltakSRP__File_Complete__c =null OR DeltakSRP__File_Complete__c <= 1) AND CreatedDate < ' + dateTimetemp.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND StageName=\'Dormant\' AND DeltakSRP__Sub_Stage__c = \'Unable to Contact\' AND RecordTypeID = \'' + OpportunityUtilities.getSRPOppRecordType() + '\'';
    	//query = 'SELECT id, OwnerID FROM Opportunity WHERE CreatedDate < ' + dateTimetemp.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND StageName=\'Dormant\' AND  (Sub_Stage__c = \'Unable to Contact\' OR DeltakSRP__Sub_Stage__c = \'Unable to Contact\') AND OwnerID =\'00560000001VigCAAS\' AND (RecordTypeID = \'' + OpportunityUtilities.getStudentOppRecordType() + '\' OR RecordTypeID = \'' + OpportunityUtilities.getSRPOppRecordType() + '\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> lstOppsToUpdate){
    	
        
        for (Opportunity o : lstOppsToUpdate){
            o.OwnerId = OpportunityUtilities.getNurtureUserID();
        }
        Database.update(lstOppsToUpdate, false);
        //System.debug('lstOppsToUpdate.size(): ' + lstOppsToUpdate.size());
    }
 	
    global void finish(Database.BatchableContext BC){
    }
    
}