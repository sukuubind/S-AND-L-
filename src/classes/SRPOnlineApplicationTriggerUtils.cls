public without sharing class SRPOnlineApplicationTriggerUtils { 
	public static void copyAdmissionsDocumentsToOpportunity(Opportunity oppty){
		system.debug('copying admission docs>>>>');
		List<Id> acIdList = new List<Id>();
        List <DeltakSRP__Program_Admission_Document__c> opportunityDocs = new  List<DeltakSRP__Program_Admission_Document__c> ();
        List<Id> oppIdList = new List<Id>();
        Set<String> recTypesStr = new Set<String>();
        List <Opportunity> existingOpportunityDocs = new  List<Opportunity> ();
        
        //for(Opportunity o : opptyList){
            acIdList.add(oppty.DeltakSRP__Academic_Program__c);
            oppIdList.add(oppty.Id);
        //}
        
         existingOpportunityDocs = [SELECT  Id, (Select Id from DeltakSRP__Program_Admission_Documents__r)
            FROM    Opportunity
            WHERE   Id IN :oppIdList]; 
        
        Map<Id, Integer> existingPADMap = new Map<Id, Integer>();
        
        
        for(Opportunity o: existingOpportunityDocs){
        	Integer i = 0;
        	for(DeltakSRP__Program_Admission_Document__c pad: o.DeltakSRP__Program_Admission_Documents__r){
        		i++;
        	}
        	existingPADMap.put(o.Id, i);
        	system.debug('o.Id>>>>'+o.Id+'>>>>i>>>>'+i);
        }
        
        List<String> extIdList = new List<String>();
        List<DeltakSRP__Program_Admission_Template_Selection__c> junctionList = [
            SELECT  DeltakSRP__Academic_Program__c
                    ,DeltakSRP__Ext_Program_Admission_Template__c
            FROM    DeltakSRP__Program_Admission_Template_Selection__c
            WHERE   DeltakSRP__Academic_Program__c IN :acIdList
        ];
        for(DeltakSRP__Program_Admission_Template_Selection__c pats : junctionList){
            extIdList.add(pats.DeltakSRP__Ext_Program_Admission_Template__c);
        }
        List<DeltakSRP__Program_Admission_Template__c> templateList = [
            select  Name
                    ,DeltakSRP__Type__c
                    ,DeltakSRP__Comments__c
                    ,DeltakSRP__Order__c
                    ,DeltakSRP__Required__c
                    ,DeltakSRP__Application_Fee__c
                    ,DeltakSRP__Matching_ID__c
            from    DeltakSRP__Program_Admission_Template__c
            where   DeltakSRP__Matching_ID__c IN :extIdList
            order by DeltakSRP__Order__c
        ];
                                                                        
        Map<DeltakSRP__Program_Admission_Template_Selection__c, DeltakSRP__Program_Admission_Template__c> junctionMap = new Map<DeltakSRP__Program_Admission_Template_Selection__c, DeltakSRP__Program_Admission_Template__c>();
        for(DeltakSRP__Program_Admission_Template_Selection__c objJunction : junctionList){
            for(DeltakSRP__Program_Admission_Template__c objTemplate : templateList){
                recTypesStr.add(objTemplate.DeltakSRP__Type__c);
                if(objJunction.DeltakSRP__Ext_Program_Admission_Template__c == objTemplate.DeltakSRP__Matching_ID__c)
                    junctionMap.put(objJunction, objTemplate);
            }
        }
        
    
        String sobjecttype = 'DeltakSRP__Program_Admission_Document__c';
        RecordType[] recTypes = [select Id,Name from RecordType WHERE SobjectType = :sobjecttype AND Name IN :recTypesStr];
    
        Map<String, Id> RecTypesMap = new Map<String, Id > ();
        for (RecordType r : recTypes) {
          recTypesMap.put(r.Name, r.Id);
        }
        
        //Map of opportunity id to template ids
        Map<Id, Set<String>> opportunityTemplateMap = new Map<Id, Set<String>>();
        List<DeltakSRP__Program_Admission_Document__c> existingDocList = [
            select  Id
                    ,DeltakSRP__Opportunity__c
                    ,DeltakSRP__Ext_Program_Admission_Template__c
            from    DeltakSRP__Program_Admission_Document__c
            where   DeltakSRP__Opportunity__c IN :oppIdList
        ];
        for(DeltakSRP__Program_Admission_Document__c doc : existingDocList){
            Set<String> docSet = (opportunityTemplateMap.get(doc.DeltakSRP__Opportunity__c )!= null) ? opportunityTemplateMap.get(doc.DeltakSRP__Opportunity__c) : new Set<String>();
            docSet.add(doc.DeltakSRP__Ext_Program_Admission_Template__c);
            opportunityTemplateMap.put(doc.DeltakSRP__Opportunity__c, docSet);
        }
    
        //copy the tempaltes to the opportunityDocs list  
        for(DeltakSRP__Program_Admission_Template_Selection__c objJunction : junctionMap.keySet()) {
            DeltakSRP__Program_Admission_Template__c template = junctionMap.get(objJunction);
           // for(Opportunity o : opptyList){
                //if(opportunityTemplateMap.get(o.Id) != null && opportunityTemplateMap.get(o.Id).contains(template.DeltakSRP__Matching_ID__c)){
                   // continue;
                //}
               /* else */if(oppty.DeltakSRP__Academic_Program__c == objJunction.DeltakSRP__Academic_Program__c)
                {
                	//if(existingPADMap.get(o.Id) == 0)
                    	opportunityDocs.add(createAdmissionDocument(RecTypesMap, oppty, template));
                }   
           // }
        }
        //insert the docs
        system.debug('opportunitydocs>>>>'+opportunitydocs);
        insert opportunityDocs;
	}
	
	 public static DeltakSRP__Program_Admission_Document__c createAdmissionDocument(Map<String, Id> RecTypesMap, Opportunity o, DeltakSRP__Program_Admission_Template__c template){
         system.debug('template.DeltakSRP__Type__c>>>>'+template.DeltakSRP__Type__c);
         DeltakSRP__Program_Admission_Document__c doc = new DeltakSRP__Program_Admission_Document__c();          
          doc.DeltakSRP__Document_Name__c  = template.Name;
          doc.DeltakSRP__Comments__c      = template.DeltakSRP__Comments__c;
          //doc.Type__c       = template.Type__c;
          doc.DeltakSRP__Required__c     = true;
          doc.RecordTypeId     = recTypesMap.get(template.DeltakSRP__Type__c);
          doc.DeltakSRP__Opportunity__c     = o.Id;
          doc.DeltakSRP__Order__c       = template.DeltakSRP__Order__c;
          doc.DeltakSRP__Fee_Amount__c     = template.DeltakSRP__Application_Fee__c; 
          doc.DeltakSRP__Ext_Program_Admission_Template__c = template.DeltakSRP__Matching_ID__c;
          doc.SRP_Academic_Program__c = o.DeltakSRP__Academic_program__c;
          doc.SRP_Academic_Specialization__c = o.DeltakSRP__Academic_Specialization__c;
          doc.SRP_Academic_Term__c = o.DeltakSRP__Academic_Start_Date__c;
          return doc;
    }		
}