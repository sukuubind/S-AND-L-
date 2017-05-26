trigger SRPProgramEnrollmentTriggerTemp on DeltakSRP__Program_Enrollment__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 

Boolean bypassTrigger = triggerOverride != null && 
        (triggerOverride.Override_All__c || triggerOverride.SRPProgramEnrollmentTriggerTemp__c); 


//system.debug('trigger.new().size()>>>>'+trigger.new.size());	

if(bypassTrigger)
{
  return;
}   

else if(Trigger.IsBefore && Trigger.IsInsert)
{
  system.debug('trigger.new().size()>>>>'+trigger.new.size());
  Try{	
  	List<DeltakSRP__Program_Enrollment__c> penrolls = new List<DeltakSRP__Program_Enrollment__c>();
	for(DeltakSRP__Program_Enrollment__c p: Trigger.New){
		if(p.DeltakSRP__SIS_External_Id__c != null && (p.DeltakSRP__SIS_External_Id__c.startswith('UOB')))
			penrolls.add(p);
	}
	if(penrolls.size()>0)
  		SRPProgramEnrollmentHandlerTemp.handleBeforeInsert(penrolls); 
  }Catch(Exception e){
  	 SRPAcademicSectionTriggerHandler.insertErrorLog(e.getmessage(), 'Program Enrollment', 'SRPProgramEnrollmentTriggerTemp');
  }	
}    


else if(Trigger.IsBefore && Trigger.IsUpdate)
{
  SRPProgramEnrollmentHandlerTemp.handleBeforeUpdate(Trigger.old, Trigger.new);
}
/*
else if(Trigger.IsBefore && Trigger.IsDelete)
{
  handler.handleBeforeDelete();
}
*/
else if(Trigger.IsAfter && Trigger.IsInsert)
{
  SRPProgramEnrollmentHandlerTemp.handleAfterInsert(Trigger.New);
}

else if(Trigger.IsAfter && Trigger.IsUpdate)
{
  SRPProgramEnrollmentHandlerTemp.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
}
/*
else if(Trigger.IsAfter && Trigger.IsDelete)
{
  handler.handleAfterDelete();
}

else if(Trigger.IsAfter && Trigger.IsUndelete)
{
  handler.handleAfterUndelete();
}
*/

}