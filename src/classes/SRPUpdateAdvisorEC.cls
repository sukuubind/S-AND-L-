// Author : Girija for SRP-2232: Automatically update EC and Advisor field on Oppty and Contact respectively
public with sharing class SRPUpdateAdvisorEC {
    
    public static void updateAdvisorAndEC()
    {
    // Query all opportunity records that needs to be updated	
    // we need to modify this query depending on what all opportunities we want to update
    	List<Opportunity> opp = new List<Opportunity>();
    	
/*    	opp = [Select id, DeltakSRP__Academic_Program__c, DeltakSRP__Student__c
    			from Opportunity 
    			where DeltakSRP__Academic_Program__c != null AND Enrollment_Coordinator__c = null 
    			AND StageNAme != 'Test Lead' limit 2]; 
 */   			 
    	String query = 'SELECT '; 
        query += 'id, DeltakSRP__Academic_Program__c, DeltakSRP__Student__c FROM Opportunity ';
        query += Label.ECSSCQuery;
        System.debug('querySRP-->'+query); 
        
        opp = Database.query(query); 
    		
    //AND DeltakSRP__Academic_Program__r.DeltakSRP__Active__c = true 	
    	List<Id> thisprogIdList = new List<Id>();
    	Map<id,id> optopgmId = new Map<id,id>();
    	Map<id, id> oppContactIdMap = new Map<id,id>();
    	if(opp.size() > 0 && opp != null){
	    	for(Opportunity o : opp){
	    		thisprogIdList.add(o.DeltakSRP__Academic_Program__c);
	    		optopgmId.put(o.id, o.DeltakSRP__Academic_Program__c);
	    		oppContactIdMap.put(o.id, o.DeltakSRP__Student__c); 
	    		
	    	} 	
    	} 
    	List<DeltakSRP__Academic_Program__c> acadProgList = new List<DeltakSRP__Academic_Program__c>();
    	if(thisprogIdList != null && thisprogIdList.size() > 0){
	    	acadProgList = [Select d.Id, d.Enrollment_Coordinator__c, d.Student_Service_Coordinator__c 
	    					From DeltakSRP__Academic_Program__c d 
    						where id in :thisprogIdList];
    	}
		
		Map<id, id> progIdToCoordinatorId = new Map<id,Id>();
		Map<id, id> progIdToAdvisorId = new Map<id,Id>();     
    	if(acadProgList.size() > 0 && acadProgList != null){
	    	for(DeltakSRP__Academic_Program__c pg : acadProgList){
	    		progIdToCoordinatorId.put(pg.id, pg.Enrollment_Coordinator__c);
	    		progIdToAdvisorId.put(pg.id,pg.Student_Service_Coordinator__c);
	    	} 
    	} 
    	
    	// Girija: ECSSC is new record type that I created for purpose of SRP-2232 
    	List<RecordType> recordTypeList = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Batch_Job__c' and r.Name = 'ECSSC' limit 1];
	    
	    List<Batch_Job__c> bjList = new List<Batch_Job__c>();    
    	if(opp.size() > 0 && opp != null)
    	{
	    	for(Opportunity o : opp)
	    	{
	    	// bj will store opty related information	
	    		Batch_Job__c bj = new Batch_Job__c();
	    		bj.RecordTypeId = recordTypeList[0].Id;
	    		bj.RecordID__c = o.id;
	    		if(progIdToCoordinatorId != null && progIdToCoordinatorId.size() > 0){
	    	// Custom_Property_8__c represents Enrollment Coordinator field on oppty
	    			bj.Custom_Property_8__c = progIdToCoordinatorId.get(optopgmId.get(o.id));
	    		}
	    	// 	Createing other object of Batch Job bj2 to insert Contact information
	    		Batch_Job__c bj2 = new Batch_Job__c();
	    		if(oppContactIdMap != null && oppContactIdMap.size() > 0){
	    			bj2.RecordID__c = oppContactIdMap.get(o.id);
	    		}
	    		bj2.RecordTypeId = recordTypeList[0].Id;
	    		if(progIdToAdvisorId != null && progIdToAdvisorId.size() > 0){
	    	// Custom_Property_7__c represents Advisor field on Contact
	    			bj2.Custom_Property_7__c = progIdToAdvisorId.get(optopgmId.get(o.id));
	    		}
	    		bjList.add(bj);
	    		bjList.add(bj2);
	    	}
    	}
    	if(bjList!= null && bjList.size() > 0){
    		insert bjList;
    	}
    	   	
    }
    
    
}