trigger SRMLead on Lead (before insert,after insert) {
    
    SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRMLead__c);
    
    if(bypassTrigger)   return;
    
        RecordType rt = [Select Id from RecordType where name= 'SRP Lead' LIMIT 1];
        
        List<Lead> SRPLeads = new List<Lead>();
        for(Lead l: Trigger.New){
        		system.debug('l.firstname>>>>'+l.firstname);
        		system.debug('l.lastname>>>>'+l.lastname);
        		system.debug('l.email>>>>'+l.email);
        		system.debug('l.DeltakSRP__AcademicInstitution__c>>>>'+l.DeltakSRP__AcademicInstitution__c);
                if(l.RecordTypeId == rt.Id && l.LeadSource != 'Mass Upload Lead')
                  SRPLeads.add(l);
        }
        system.debug('SRPLeads>>>>'+SRPLeads+'>>>>'+srpleads.size());
        if(Trigger.isInsert && Trigger.isBefore){
            Set<Lead> uniqueLeads = new Set<Lead>();
            for(Lead l : SRPLeads){ 
                if(l != null){         
                  uniqueLeads.add(l);
                }
            }
            SRPLeads.clear();
            SRPLeads.addAll(uniqueLeads); 
        }   
        
        List<Id> leadsToDelete = new List<ID>();
        if(Trigger.isInsert && Trigger.isAfter){
            Set<Lead> uniqueLeads = new Set<Lead>();
            for(Lead l : SRPLeads){  
                if(l != null && !(SRPLEadTriggerHandler.isDuplicateLead(l,uniqueleads))){         
                  uniqueLeads.add(l); 
                }else{
                    leadsToDelete.add(l.id);
                } 
            }
            SRPLeads.clear();
            SRPLeads.addAll(uniqueLeads); 
            if(leadsToDelete.size()>0){
                delete [Select Id from Lead where Id in: leadstodelete];
            } 
        }

            list<Lead> lstLeads = new list<Lead>();
            if (Trigger.isBefore && Trigger.isInsert) {
                
                system.debug('SRPLeads.size()>>>>'+ SRPLeads.size());
                SRPLeads = SRPLeadTriggerHandler.prefixPhoneNumbers(SRPLeads);
                system.debug('SRPLeads>>>>'+SRPLEads);
                SRPLeadTriggerHandler.onBeforeInsert(SRPLeads);
                }
            else if(Trigger.isAfter && Trigger.isInsert){
               system.debug('after SRPLeads.size()>>>>'+ SRPLeads.size());
               if(SRPLeads.size()==1){ 
               		SRPLeadTriggerHandler.onAfterInsert(SRPLeads);
               }		
               else{	
               		if(SRPLeads.size()>1)
               			SRPLeadTriggerHandlerBulk.onAfterInsert(SRPLeads);
               }		
            }
}