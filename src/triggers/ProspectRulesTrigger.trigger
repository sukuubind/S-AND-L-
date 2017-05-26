trigger ProspectRulesTrigger on PRO_Rule__c (after insert
                                ,after update
                                ,after delete
                                ,before update
                                ,before insert
                                ,before delete) {
        List<PRO_Rule__c> newRecords = Trigger.new;
        List<PRO_Rule__c> oldRecords = Trigger.old;
        if(trigger.isInsert && trigger.isBefore){
            ProspectRulesHandler.doBeforeInsertRule(newRecords);
        }else if(trigger.isUpdate && trigger.isBefore){
            ProspectRulesHandler.doBeforeUpdateRule(newRecords); 
        }                                                               
}