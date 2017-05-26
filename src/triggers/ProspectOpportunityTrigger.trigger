trigger ProspectOpportunityTrigger on Opportunity (after insert, after update, before insert, 
before update) {
    if(Trigger.isInsert && Trigger.isAfter){
        
        ProspectLogHandler prospectLog = new ProspectLogHandler();
        prospectLog.createProspectLogRecordForOpportunity(Trigger.new, false);
        
    } 
    if(Trigger.isAfter && Trigger.isUpdate){
        ProspectLogHandler prospectLog = new ProspectLogHandler();
        prospectLog.createProspectLogRecordForOpportunity(Trigger.old, Trigger.new); 
    }
    // SRP-1482 - VR - START
    // Commenting Owner Update logic based on direction from Ed Hildy-Refer SRP-1482 Comments
    if(Trigger.isBefore && Trigger.isUpdate){
       // ProspectLogHandler prospectLog = new ProspectLogHandler();
       // prospectLog.updateOpportunityOwner(Trigger.old, Trigger.new); 
    }
    // SRP-1482 - VR - END
}