public without sharing class SRPStudentLORHandler {
    public static final String LOR_RT_NAME = 'Letter_of_Recommendation';
    public static final String STATUS_COMPLETE = 'Complete';
    public static Map<Id, String> referenceIdToReferenceName = new Map<id, String>();
    public static Map<Id, String> referenceIdToReferenceStatus = new Map<id, String>();
    public static void handleAfterUpdate(List<DeltakSRP__Student_Letter_of_Reference__c> old_lorList,
                                        List<DeltakSRP__Student_Letter_of_Reference__c> new_lorList){
        List<Id> lorToProcess = new List<Id>();
        Map<id, String> refIdToRefName = new Map<id, String>();
        for(integer i = 0;i<old_lorList.size(); i++){
            DeltakSRP__Student_Letter_of_Reference__c oldRecord = old_lorList.get(i);
            DeltakSRP__Student_Letter_of_Reference__c newRecord = new_lorList.get(i);
            if(oldRecord.DeltakSRP__Status__c != newRecord.DeltakSRP__Status__c && newRecord.DeltakSRP__Status__c == STATUS_COMPLETE){
                lorToProcess.add(newRecord.id);
                refIdToRefName.put(newRecord.Id, newRecord.name);
            }
            
        }
        List<DeltakSRP__Program_Admission_Document__c> padList = [Select Id, DeltakSRP__Date_Received__c, Letter_of_Reference_ID__c from DeltakSRP__Program_Admission_Document__c
                                                                    where Letter_of_Reference_ID__c IN :lorToProcess];
        for(DeltakSRP__Program_Admission_Document__c pad : padList){
            pad.DeltakSRP__Date_Received__c = Date.today();
            if(refIdToRefName != null && refIdToRefName.containsKey(pad.Letter_of_Reference_ID__c)){
                pad.DeltakSRP__Recommender_Name__c = refIdToRefName.get(pad.Letter_of_Reference_ID__c);
            }
            
        }
        if(padList != null && padList.size() > 0){
            Database.update(padList, false);
        }
        
            
            
            
    }
    public static void handleBeforeInsert(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> new_lorList){
        
        List<String> slorIdList = new List<String>();
        for(DeltakSRP__Student_Letter_of_Reference_Selection__c s: new_lorList){
        	slorIdList.add(s.DeltakSRP__Student_Online_Application__c);
        }
        
        List<DeltakSRP__Student_Online_Application__c> slorAccList = new List<DeltakSRP__Student_Online_Application__c>();
        slorAccList=[Select DeltakSRP__Affiliation__r.AccountId from DeltakSRP__Student_Online_Application__c where ID IN :slorIdList];
        
        Map<String, String> accountIdMap = new Map<String, String>();
        List<String> accountIDList = new List<String>();
        for(DeltakSRP__Student_Online_Application__c a: slorAccList){
        	accountIdMap.put(a.Id,a.DeltakSRP__Affiliation__r.AccountId);
        	accountIDList.add(a.DeltakSRP__Affiliation__r.AccountId);
        }
       
        List<Account> accountList = new List<Account>(); 
        accountList = [Select SLRS_Record_Type_Id__c from Account where Id IN :accountIdList];
        Map<String, String> recToAccMap = new Map<String, String>();
        for(Account a: accountList){
        	system.debug('check AccID assignment>>'+ a.ID);
        	system.debug('check SLRS assignment>>'+ a.SLRS_Record_Type_Id__c);
        	recToAccMap.put(a.ID,a.SLRS_Record_Type_Id__c);
        }
        
        List<DeltakSRP__Student_Letter_of_Reference__c> lorAccList = new List<DeltakSRP__Student_Letter_of_Reference__c>();
        
        Map<String, String> accToLors = new Map<String, String>();
         for(DeltakSRP__Student_Letter_of_Reference_Selection__c a: new_lorList){        	
        	DeltakSRP__Student_Letter_of_Reference__c lor = new DeltakSRP__Student_Letter_of_Reference__c();
        	lor.ID = a.DeltakSRP__Student_Letter_of_Reference__c;
        	system.debug('check SOA assignment>>'+ accountIDMap.get(a.DeltakSRP__Student_Online_Application__c));
        	system.debug('check record assignment>>'+ recToAccMap.get(accountIDMap.get(a.DeltakSRP__Student_Online_Application__c)));
        	//system.debug('check record assignment>>'+ recToAccMap.get(accountIDMap.get(a.DeltakSRP__Student_Letter_of_Reference__c)));
        	lor.RecordTypeId = recToAccMap.get(accountIDMap.get(a.DeltakSRP__Student_Online_Application__c));
        	lorAccList.add(lor);
         }
        
         try{
        	update lorAccList;
        }catch(DMLException e){
	        	system.debug('error after insert'+e);
	        }
        
    }
    
    public static void handleBeforeDelete(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> new_lorList){
        List<Id> lorToProcess = new List<Id>();
        Map<id, Id> referenceid_to_padid = new Map<id, id>();
        for(integer i = 0;i<new_lorList.size(); i++){
            DeltakSRP__Student_Letter_of_Reference_Selection__c newRecord = new_lorList.get(i);
            lorToProcess.add(newRecord.DeltakSRP__Student_Letter_of_Reference__c);
            // code to update program admission document
        }
        List<DeltakSRP__Program_Admission_Document__c> padList_To_Update = new List<DeltakSRP__Program_Admission_Document__c>();
        referenceid_to_padid = findPadForReference(lorToProcess, new_lorList, false);
        for(integer i = 0;i<new_lorList.size(); i++){
            DeltakSRP__Student_Letter_of_Reference_Selection__c newRecord = new_lorList.get(i);
            Id padidForReference = null;
            if(referenceid_to_padid != null && referenceid_to_padid.containsKey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                padidForReference = referenceid_to_padid.get(newRecord.DeltakSRP__Student_Letter_of_Reference__c);
            }
            if(padidForReference != null){
                    DeltakSRP__Program_Admission_Document__c padRecord = new DeltakSRP__Program_Admission_Document__c(id=padidForReference);
                    padRecord.Letter_of_Reference_ID__c = '';
                    if(referenceIdToReferenceName != null && referenceIdToReferenceName.containskey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                        padRecord.DeltakSRP__Recommender_Name__c = '';
                    }
                    if(referenceIdToReferenceStatus != null && referenceIdToReferenceStatus.containsKey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                        if(referenceIdToReferenceStatus.get(newRecord.DeltakSRP__Student_Letter_of_Reference__c) == STATUS_COMPLETE){
                            padRecord.DeltakSRP__Date_Received__c = null;
                        }
                    }
                    
                    padList_To_Update.add(padRecord);
            }
        }
        if(padList_To_Update != null && padList_To_Update.size() > 0){
            Database.update(padList_To_Update, false);
        }
        
        
    }
    public static void handleAfterInsert(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> new_lorList){
        List<Id> lorToProcess = new List<Id>();
        Map<id, Id> referenceid_to_padid = new Map<id, id>();
        for(integer i = 0;i<new_lorList.size(); i++){
            DeltakSRP__Student_Letter_of_Reference_Selection__c newRecord = new_lorList.get(i);
            lorToProcess.add(newRecord.DeltakSRP__Student_Letter_of_Reference__c);
            // code to update program admission document
        }
        
        List<DeltakSRP__Program_Admission_Document__c> padList_To_Update = new List<DeltakSRP__Program_Admission_Document__c>();
        referenceid_to_padid = findPadForReference(lorToProcess, new_lorList, true);
        for(integer i = 0;i<new_lorList.size(); i++){
            DeltakSRP__Student_Letter_of_Reference_Selection__c newRecord = new_lorList.get(i);
            Id padidForReference = null;
            if(referenceid_to_padid != null && referenceid_to_padid.containsKey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                padidForReference = referenceid_to_padid.get(newRecord.DeltakSRP__Student_Letter_of_Reference__c);
            }
            if(padidForReference != null){
                    DeltakSRP__Program_Admission_Document__c padRecord = new DeltakSRP__Program_Admission_Document__c(id=padidForReference);
                    padRecord.Letter_of_Reference_ID__c = newRecord.DeltakSRP__Student_Letter_of_Reference__c;
                    if(referenceIdToReferenceName != null && referenceIdToReferenceName.containskey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                        padRecord.DeltakSRP__Recommender_Name__c = referenceIdToReferenceName.get(newRecord.DeltakSRP__Student_Letter_of_Reference__c);
                    }
                    if(referenceIdToReferenceStatus != null && referenceIdToReferenceStatus.containsKey(newRecord.DeltakSRP__Student_Letter_of_Reference__c)){
                        if(referenceIdToReferenceStatus.get(newRecord.DeltakSRP__Student_Letter_of_Reference__c) == STATUS_COMPLETE){
                            padRecord.DeltakSRP__Date_Received__c = Date.today();
                        }
                    }
                    
                    padList_To_Update.add(padRecord);
            }
        }
        if(padList_To_Update != null && padList_To_Update.size() > 0){
            Database.update(padList_To_Update, false);
        }
        
        
    }
    public static Map<id, Id> findPadForReference(List<id> lorToProcess, List<DeltakSRP__Student_Letter_of_Reference_Selection__c> new_lorList, boolean isinsert){
        Map<id, Id> referenceIdToSOAId = new Map<id, Id>();
        Map<id, Id> referenceid_to_padid = new Map<id, id>();
        List<DeltakSRP__Student_Letter_of_Reference_Selection__c> lorSelectionList = [Select Id, DeltakSRP__Student_Letter_of_Reference__c, DeltakSRP__Student_Online_Application__c,
                                                                                        DeltakSRP__Student_Letter_of_Reference__r.Name, DeltakSRP__Student_Letter_of_Reference__r.DeltakSRP__Status__c from 
                                                                                        DeltakSRP__Student_Letter_of_Reference_Selection__c where DeltakSRP__Student_Letter_of_Reference__c in :lorToProcess];
        List<id> SOAidlist = new List<Id>();
        List<Id> referenceIdList = new List<Id>();
        for(DeltakSRP__Student_Letter_of_Reference_Selection__c thisLors : lorSelectionList){
            SOAidlist.add(thisLors.DeltakSRP__Student_Online_Application__c);
            referenceIdToSOAId.put(thisLors.DeltakSRP__Student_Letter_of_Reference__c, thisLors.DeltakSRP__Student_Online_Application__c);
            referenceIdToReferenceName.put(thisLors.DeltakSRP__Student_Letter_of_Reference__c, thisLors.DeltakSRP__Student_Letter_of_Reference__r.Name);
            referenceIdToReferenceStatus.put(thisLors.DeltakSRP__Student_Letter_of_Reference__c, thisLors.DeltakSRP__Student_Letter_of_Reference__r.DeltakSRP__Status__c);
            referenceIdList.add(thisLors.DeltakSRP__Student_Letter_of_Reference__c);
        }
        List<id> opptyIdlist = new List<id>();
        Map<Id, Id> soaid_to_opptyid = new Map<Id, Id>();
        List<DeltakSRP__Student_Online_Application__c> soalist = [Select Id, DeltakSRP__Affiliation_Opportunity__c  from DeltakSRP__Student_Online_Application__c where id in :SOAidlist];
        for(DeltakSRP__Student_Online_Application__c thissoa : soalist){
            opptyIdlist.add(thissoa.DeltakSRP__Affiliation_Opportunity__c);
            soaid_to_opptyid.put(thissoa.id, thissoa.DeltakSRP__Affiliation_Opportunity__c);
        }
        List<DeltakSRP__Program_Admission_Document__c> padlist =null;
        if(isinsert){
         padlist =[Select Id, DeltakSRP__Opportunity__c, Letter_of_Reference_ID__c, RecordType.DeveloperName, DeltakSRP__Date_Received__c from DeltakSRP__Program_Admission_Document__c where 
                                                                    DeltakSRP__Opportunity__c IN :opptyIdlist and Letter_of_Reference_ID__c = '' and
                                                                    RecordType.DeveloperName = :LOR_RT_NAME];
        }else{
            padlist =[Select Id, DeltakSRP__Opportunity__c, Letter_of_Reference_ID__c, RecordType.DeveloperName, DeltakSRP__Date_Received__c from DeltakSRP__Program_Admission_Document__c where 
                                                                    DeltakSRP__Opportunity__c IN :opptyIdlist and Letter_of_Reference_ID__c IN :referenceIdList and
                                                                    RecordType.DeveloperName = :LOR_RT_NAME];
        }
        Map<Id, Id> opptyid_padid = new Map<id, id>();
        for(DeltakSRP__Program_Admission_Document__c pad : padlist){
            opptyid_padid.put(pad.DeltakSRP__Opportunity__c, pad.id);
        }
        
        
        for(DeltakSRP__Student_Letter_of_Reference_Selection__c thisLor : new_lorList){
            Id soaIdForThisReference = null;
            if(referenceIdToSOAId != null && referenceIdToSOAId.containsKey(thisLor.DeltakSRP__Student_Letter_of_Reference__c)){
                soaIdForThisReference = referenceIdToSOAId.get(thisLor.DeltakSRP__Student_Letter_of_Reference__c);
            }
            Id opptyIdForThisSOA = null;
            if(soaIdForThisReference != null && soaid_to_opptyid != null && soaid_to_opptyid.containsKey(soaIdForThisReference)){
                opptyIdForThisSOA = soaid_to_opptyid.get(soaIdForThisReference);
            }
            Id padidForThisOppty = null;
            if(opptyIdForThisSOA != null && opptyid_padid != null && opptyid_padid.containsKey(opptyIdForThisSOA)){
                padidForThisOppty = opptyid_padid.get(opptyIdForThisSOA);
                referenceid_to_padid.put(thisLor.DeltakSRP__Student_Letter_of_Reference__c, padidForThisOppty);
            }
            //Id padidForThisReference = opptyid_padid.get(soaid_to_opptyid.get(referenceIdToSOAId.get(thisLor.id)));
            
        }
        return referenceid_to_padid;
    }
}