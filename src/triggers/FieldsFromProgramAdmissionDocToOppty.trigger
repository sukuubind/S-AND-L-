trigger FieldsFromProgramAdmissionDocToOppty on DeltakSRP__Program_Admission_Document__c (before update) {
  SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance();
    Boolean bypassTrigger = triggerOverride != null &&
            (triggerOverride.Override_All__c || triggerOverride.SRPProgAdmDoc__c);

    if(bypassTrigger)   return;

    FieldsFromProgramAdmissionDocToOppty.updateFields(Trigger.newMap,Trigger.oldMap);
}