Global class SRPProgramEnrollmentFindDropSch implements Schedulable {
    Global void execute(SchedulableContext sc){
        /*List<DeltakSRP__Program_Enrollment__c> lstTemp = [SELECT id, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c 
            FROM DeltakSRP__Program_Enrollment__c 
            WHERE DeltakSRP__Enrollment_Status__c !='Graduate' AND DeltakSRP__Enrollment_Status__c !='Drop'];
        Set<ID> setPEIDs = new set<ID>();
        for(DeltakSRP__Program_Enrollment__c pe : lstTemp){
            setPEIDs.add(pe.id);
        }
        SRPEnrollmentHistoryTriggerHelper.findDropProgramEnrollments(setPEIDs);*/
        
        SRPProgramEnrollmentDropBatch b = new SRPProgramEnrollmentDropBatch('SELECT id, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Program__c FROM DeltakSRP__Program_Enrollment__c WHERE DeltakSRP__Enrollment_Status__c !=\'Graduate\' AND DeltakSRP__Enrollment_Status__c !=\'Drop\'');
        database.executebatch(b);
    }
}