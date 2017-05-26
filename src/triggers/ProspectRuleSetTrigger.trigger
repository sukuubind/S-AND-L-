trigger ProspectRuleSetTrigger on PRO_Rule_Set__c (after delete, after insert, 
									    after undelete, after update, 
									    before delete, before insert, 
									    before update) {
	List<PRO_Rule_Set__c> newRecords = Trigger.new;
    	List<PRO_Rule_Set__c> oldRecords = Trigger.old;
		if(trigger.isInsert && trigger.isBefore){
            ProspectRulesHandler.doBeforeInsertRuleSet(newRecords);
        }else if(trigger.isUpdate && trigger.isBefore){
        	ProspectRulesHandler.doBeforeUpdateRuleSet(newRecords); 
        }											
}