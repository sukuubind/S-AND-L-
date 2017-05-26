trigger SRPCourseEnrollmentTriggerTemp on DeltakSRP__Course_Enrollment__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 

Boolean bypassTrigger = triggerOverride != null && 
       (triggerOverride.Override_All__c || triggerOverride.SRPCourseEnrollmentTriggerTemp__c); 



if(bypassTrigger)
  return;



if(Trigger.IsBefore && Trigger.IsInsert)
{   Try{
        List<DeltakSRP__Course_Enrollment__c> cenrolls = new List<DeltakSRP__Course_Enrollment__c>();
        for(DeltakSRP__Course_Enrollment__c c: Trigger.New){
            system.debug('c.deltaksrp__final_grade__c>>>>'+c.deltaksrp__final_grade__c);
            if(c.DeltakSRP__SIS_External_Id__c != null && c.DeltakSRP__SIS_External_Id__c.startswith('UOB'))
                cenrolls.add(c);
        }
        if(cenrolls.size()>0)
        {
            SRPCourseEnrollmentTriggerHelper.updateFieldsFromIntegration(cenrolls);
            
        }
    }catch(Exception e){
         DeltakSRP__Error_Log__c el = new DeltakSRP__Error_Log__c();
         el.DeltakSRP__Partner_Name__c = 'University of Birmingham';
         el.DeltakSRP__Object__c = 'Course Enrollment';
         el.DeltakSRP__Type__c = 'Integration';
         if(e.getmessage().length()>254)
            el.DeltakSRP__Detail__c = e.getmessage().substring(0,254);
         else
            el.DeltakSRP__Detail__c = e.getmessage();
         insert el;
    }
	SRPCourseEnrollmentHandlerTemp.handleBeforeUpsert(Trigger.new);
}    

else if(Trigger.IsBefore && Trigger.IsUpdate)
{
    List<DeltakSRP__Course_Enrollment__c> cenrolls = new List<DeltakSRP__Course_Enrollment__c>();
        for(DeltakSRP__Course_Enrollment__c c: Trigger.New){
            system.debug('c.deltaksrp__final_grade__c>>>>'+c.deltaksrp__final_grade__c);
            if(c.DeltakSRP__SIS_External_Id__c != null && c.DeltakSRP__SIS_External_Id__c.startswith('UOB'))
                cenrolls.add(c);
        }
        if(cenrolls.size()>0)
        SRPCourseEnrollmentHandlerTemp.handleBeforeUpsert(Trigger.new);
}
/*
else if(Trigger.IsBefore && Trigger.IsDelete)
{
  handler.handleBeforeDelete();
}
*/
else if(Trigger.IsAfter && Trigger.IsInsert)
{
  SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(Trigger.newMap, Trigger.oldMap, 'Insert');
}

else if(Trigger.IsAfter && Trigger.IsUpdate)
{
  SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(Trigger.newMap, Trigger.oldMap, 'Update');
}

else if(Trigger.IsAfter && Trigger.IsDelete)
{
  SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(Trigger.newMap, Trigger.oldMap, 'Delete');
}

else if(Trigger.IsAfter && Trigger.IsUndelete)
{
  SRPCourseEnrollmentHandlerTemp.handleAfterTrigger(Trigger.newMap, Trigger.oldMap, 'UnDelete');
}

}