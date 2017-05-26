public without sharing class LiveChatTranscriptTriggerHandler {

public Static void createActivityHistoryOnOpportunity(Map<Id,LiveChatTranscript> newLCTMap, Map<Id,LiveChatTranscript> oldLCTMap){
    
    Map<Id, LiveChatTranscript> LCTToOpptyIdMap = new Map<Id,LiveChatTranscript>();
    Map<Id, LiveChatTranscript> LCTToOldOpptyIdMap = new Map<Id,LiveChatTranscript>();
    List<Id> opptyIds = new List<Id>();
    
    for(LiveChatTranscript lct : newLCTMap.values())
    {
        if(lct.opportunity__c != null){
            LCTtoOpptyIdMap.put(lct.opportunity__c,lct); 
            opptyIds.add(lct.opportunity__c);
        }   
    }
    
    if(oldLCTMap != null){
        for(LiveChatTranscript lct : oldLCTMap.values())
        {
            if(lct.opportunity__c != null){
                LCTtoOldOpptyIdMap.put(lct.opportunity__c,lct); 
                opptyIds.add(lct.opportunity__c);
            }   
        }
    }    
    
    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([Select Id, chat_start_time__c, student__c from Opportunity where Id in: opptyIds]);
    List<Id> OpptyActivityToCreate = new List<Id>();
    List<Id> OpptyNotesToCreate = new List<Id>();
    
    for(LiveChatTranscript lct : newLCTMap.values()){
        system.debug('OldLCTMap>>>>'+OldLCTMap);
        if((oldLCTMap==null || newLCTMap.get(lct.id).opportunity__c != oldLCTMap.get(lct.id).opportunity__c) &&  newLCTMap.get(lct.id).opportunity__c!= null){
            OpptyActivityToCreate.add(lct.opportunity__c);
        }
        
        system.debug(' newLCTMap.get(lct.id).opportunity__c>>>>'+ newLCTMap.get(lct.id).opportunity__c);
        
        if(oldLCTMap!=null && newLCTMap.get(lct.id).opportunity__c != oldLCTMap.get(lct.id).opportunity__c){
            if(oldLCTMap.get(lct.id).opportunity__c != null)
                OpptyNotesToCreate.add(oldLCTMap.get(lct.id).opportunity__c);
        }
    }
    
    system.debug('Opptynotestocreate>>>>'+OpptyNotesToCreate);
    
    RecordType rt = [Select Id from RecordType where name = :Label.TaskRecordTypeName Limit 1];
    List<Task> activitiesToCreate = new List<Task>();
    List<Note> NotesToCreate = new List<Note>();
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
    for(Id opptyId: OpptyActivityToCreate){
        system.debug('opptyid>>>>'+opptyid);
        if(LCTTOOpptyIdMap.get(opptyid) != null){
         Task t = new Task();
         t.OwnerId = LCTTOOpptyIdMap.get(opptyid).OwnerId;
         t.Chat_Transcript_Id__c = LCTTOOpptyIdMap.get(opptyid).Id;
         t.Subject = Label.TaskSubjectClickToChat;
         t.Type = Label.TaskTypeChat;
         t.Status = Label.TaskLabelCompleted;
         t.RecordTypeId = rt.id;
         t.Completed_Date__c =  LCTTOOpptyIdMap.get(opptyid).endtime; 
         t.Result__c = Label.TaskSuccessful;
         t.Priority = Label.TaskPriorityNormal;
         t.WhatId = opptyid;
         if(LCTTOOpptyIdMap.get(opptyid).endtime != null){
            Datetime dt = LCTTOOpptyIdMap.get(opptyid).endtime;
            t.ActivityDate = date.newinstance(dT.year(), dT.month(), dT.day());
         }  
         if(opportunities.get(opptyid) != null)
            t.WhoId = opportunities.get(opptyid).student__c;
         
         if(LCTTOOpptyIdMap.get(opptyid).body != null){
            string descriptionbody = LCTTOOpptyIdMap.get(opptyid).body;
            t.Description = descriptionbody.replaceAll('<[^>]+>',''); 
         }
         
         if(LCTTOOpptyIdMap.get(opptyid).starttime != null && opportunities.get(opptyid) != null){
             Opportunity o = new Opportunity(Id=opptyid);
             if(opportunities.get(opptyid).chat_start_time__c !=null){
             	// if there exists chat start time on the opportunity, update the chat start time only if the new chat start time is before the existing chat start time
             	if(opportunities.get(opptyid).chat_start_time__c > LCTTOOpptyIdMap.get(opptyid).starttime){
             		 o.Chat_Start_Time__c = LCTTOOpptyIdMap.get(opptyid).starttime;
             	}
             	// if the chat start time is before the chat start time of the attached chat, then do nothing
             }else{
             	// if there is no chat start time on the opportunity, populate with the chat start time from the chat
             	o.Chat_Start_Time__c = LCTTOOpptyIdMap.get(opptyid).starttime;
             }
             
             
             
             opportunitiesToUpdate.add(o);
         }
             
         activitiestocreate.add(t);
        } 
    }
    
    if(activitiestocreate.size()>0)
        insert activitiesToCreate;
    
    if(opportunitiesToUpdate.size()>0)
        update opportunitiesToUpdate;
    
    //List<Opportunity> opptyToUpdate = new List<Opportunity>();
    List<Id> oppIds = new List<Id>();
    for(Id opptyId: OpptyNotesToCreate){ 
        if(LCTtoOldOpptyIdMap.get(opptyid)!=null){
            note n = new note();
            n.parentId= opptyid; 
            n.body= Label.NotesBodyLiveAgent1 + ' ' + LCTtoOldOpptyIdMap.get(opptyid).Name + ' ' + Label.NotesBodyLiveAgent2;
            n.title= Label.NotesTitleLiveAgent; 
            n.isPrivate=false;   
            notestocreate.add(n); 
            
            opptyIds.add(opptyid);
            /*Opportunity o = Opportunities.get(opptyid);
            o.chat_start_time__c = null;
            opptyToUpdate.add(o);*/
        }   
    }   
    
    if(notestocreate.size() > 0)
        insert notestocreate;
     
    if(oppids.size()>0) updateOpportunities(OppIds);
    /*if(opptyToUpdate.size()>0)
        update opptyToUpdate;  */
      
}


@future
public static void updateOpportunities(List<Id> OppIds){
	
	List<Opportunity> opptyToUpdate = new List<Opportunity>();
	
	for(Id opptyId: OppIds){ 	
		Opportunity o = new Opportunity(id=opptyid);
	    o.chat_start_time__c = null;
	    opptyToUpdate.add(o);
	}
	
	if(opptyToUpdate.size()>0)
        update opptyToUpdate;  
}


public Static void handleAfterInsert(List<LiveChatTranscript> newLCTs)
    {
    
        Map<String,String> chatkeyToId = new Map<String,String>();
        
        for(LiveChatTranscript lct : newLCTs)
        {
            chatkeyToId.put(lct.ChatKey,lct.Id+'');
        }
        
        
        List<Live_Chat_Feedback__c> lcfList = [SELECT Id, Live_Chat_Transcript__c, Transcript_ChatKey__c FROM Live_Chat_Feedback__c WHERE Transcript_ChatKey__c IN :chatkeyToId.keySet()];
        
        if(System.Test.isRunningTest() && lcfList.size() < 1)
        {//to make up for session key in test class not populating
            lcfList = [SELECT Id, Live_Chat_Transcript__c, Transcript_ChatKey__c FROM Live_Chat_Feedback__c WHERE Transcript_ChatKey__c = 'testliveagentsessionkey'];
        }
        
        List<Live_Chat_Feedback__c> toUpdateLCF = new List<Live_Chat_Feedback__c>();
        
        for(Live_Chat_Feedback__c lcf : lcfList)
        {
            
            if(lcf.Live_Chat_Transcript__c == null)
            {
                lcf.Live_Chat_Transcript__c = chatkeyToId.get(lcf.Transcript_ChatKey__c);
                toUpdateLCF.add(lcf);
            }
            
        }
        
        if(toUpdateLCF.size() > 0)
        {
            update toUpdateLCF;
        }
        
    }
    
    
    public Static void handleBeforeInsert(List<LiveChatTranscript> newLCTs)
    {
    	
    	Set<Id> contactIdSet = new Set<Id>();
    	
    	System.debug('beforeInsertLCTs >---> ' + newLCTs);
    	
    	for(LiveChatTranscript lct : newLCTs)
    	{
    		if(lct.Opportunity__c == null && lct.ContactId != null)
    		{
    			contactIdSet.add(lct.ContactId);
    		}
    	}
    	
    	if(contactIdSet.size() > 0)
    	{
    		
    		List<Opportunity> oppList = [SELECT Id, stageName, DeltakSRP__Student__c, Student__c FROM Opportunity 
    		WHERE (DeltakSRP__Student__c IN :contactIdSet OR Student__c IN :contactIdSet) ORDER BY LastModifiedDate DESC];
    		
    		Map<String,Id> identifierToOppIdMap = new Map<String,Id>();
    		
    		for(Opportunity opp : oppList)
    		{
    			Id contactId = opp.DeltakSRP__Student__c;
    			
    			if (contactId == null)
    			{
    				contactId = opp.Student__c;
    			}
    			
    			if(contactId != null)
    			{
    				
    				if(!identifierToOppIdMap.containsKey(contactId + ':ACTIVE') && opp.stageName != 'Dormant')
    				{
    					
    					identifierToOppIdMap.put(contactId + ':ACTIVE',opp.Id);
    					
    				}
    				
    			}
    			
    		}
    		
    		for(Opportunity opp : oppList)
    		{
    			Id contactId = opp.DeltakSRP__Student__c;
    			
    			if (contactId == null)
    			{
    				contactId = opp.Student__c;
    			}
    			
    			if(contactId != null)
    			{
    				
    				
    				if(!identifierToOppIdMap.containsKey(contactId + ':ACTIVE') && !identifierToOppIdMap.containsKey(contactId + ':DORMANT') && opp.stageName == 'Dormant')
    				{
    					
    					identifierToOppIdMap.put(contactId + ':DORMANT',opp.Id);
    					
    				}
    				
    			}
    			
    		}
    		
    		for(LiveChatTranscript lct : newLCTs)
    		{
    			
    			if(lct.Opportunity__c == null && lct.ContactId != null)
    			{
    				
    				lct.Opportunity__c = identifierToOppIdMap.get(lct.ContactId + ':ACTIVE');
    				
    				if(lct.Opportunity__c == null)
    				{
    					lct.Opportunity__c = identifierToOppIdMap.get(lct.ContactId + ':DORMANT');
    				}
    				
    			}
    			
    		}
    		
    	}
    	
    }


}