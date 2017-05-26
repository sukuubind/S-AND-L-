trigger ProspectTeamTrigger on Team__c (after insert, after update, before insert, 
before update) {
	if(Trigger.isInsert && Trigger.isBefore){
		ProspectTeamTriggerHandler.handleBeforeInsert(Trigger.new);
	}else if(Trigger.isInsert && Trigger.isAfter){
		ProspectTeamTriggerHandler.handleAfterInsert(Trigger.new);
	}else if(Trigger.isUpdate && Trigger.isBefore){
		ProspectTeamTriggerHandler.handleBeforeUpdate(Trigger.old, Trigger.new);
	}else if(Trigger.isUpdate && Trigger.isAfter){
		System.Debug('Insider Prospect Team Trigger After Update');
		ProspectTeamTriggerHandler.handleAfterUpdate(Trigger.old, Trigger.new);
	}
}