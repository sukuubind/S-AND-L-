trigger SRPUserTrigger on User (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 

Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPUserTrigger__c) && !System.Test.IsRunningTest(); 

SRPUserTriggerHandler handler = new SRPUserTriggerHandler();

try {
	  
if(bypassTrigger)
{
	return;
}   
/*
else if(Trigger.IsBefore && Trigger.IsInsert)
{
	handler.handleBeforeInsert();
}    

else if(Trigger.IsBefore && Trigger.IsUpdate)
{
	handler.handleBeforeUpdate();
}

else if(Trigger.IsBefore && Trigger.IsDelete)
{
	handler.handleBeforeDelete();
}
*/
else if(Trigger.IsAfter && Trigger.IsInsert)
{
	handler.handleAfterInsert(Trigger.New);
}
/*
else if(Trigger.IsAfter && Trigger.IsUpdate)
{
	handler.handleAfterUpdate();
}

else if(Trigger.IsAfter && Trigger.IsDelete)
{
	handler.handleAfterDelete();
}

else if(Trigger.IsAfter && Trigger.IsUndelete)
{
	handler.handleAfterUndelete();
}
*/

}catch(Exception e){System.debug(e);}

}