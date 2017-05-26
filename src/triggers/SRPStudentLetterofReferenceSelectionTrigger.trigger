trigger SRPStudentLetterofReferenceSelectionTrigger on DeltakSRP__Student_Letter_of_Reference_Selection__c (before insert,after insert, before delete) {        
    
    if(trigger.isafter && trigger.isinsert){
        SRPStudentLORHandler.handleAfterInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isinsert){
        SRPStudentLORHandler.handleBeforeInsert(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isDelete){
        SRPStudentLORHandler.handleBeforeDelete(trigger.old);
    }
    
}