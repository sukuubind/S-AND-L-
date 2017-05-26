trigger ProspectUserTrigger on User (after insert, after update, before insert, 
before update) {
	if(Trigger.isInsert && Trigger.isBefore){
		ProspectUserTriggerHandler.handleBeforeInsert(Trigger.new);
	}else if(Trigger.isInsert && Trigger.isAfter){
		ProspectUserTriggerHandler.handleAfterInsert(Trigger.new);
	}else if(Trigger.isUpdate && Trigger.isBefore){
		ProspectUserTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.old);
	}else if(Trigger.isUpdate && Trigger.isAfter){
		
	}
}