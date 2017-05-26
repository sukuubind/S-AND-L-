/**
 * Created by sukumar.bindra1 on 2/15/2017.
 */

public  class FieldsFromProgramAdmissionDocToOppty {

    Map<Id,DeltakSRP__Program_Admission_Document__c> newMap;
    Map<Id,DeltakSRP__Program_Admission_Document__c> oldMap;

    public static Map<Id,DeltakSRP__Program_Admission_Document__c>updateFields(Map<Id,DeltakSRP__Program_Admission_Document__c> newMap,Map<Id,DeltakSRP__Program_Admission_Document__c> oldMap)
    {
        Map<Id,Opportunity> opportunityMapToUpdate = new Map<Id,Opportunity>();
        // Identify the records to be processed
        Set<Id> programAdmissionDocSetIds = new Set<Id>();
        Set<Id> opportunitySetIds = new Set<Id>();

        for(DeltakSRP__Program_Admission_Document__c progDoc : newMap.values())
        {
            if(progDoc.DeltakSRP__Opportunity__c != null)
            {
                opportunitySetIds.add(progDoc.DeltakSRP__Opportunity__c);
                programAdmissionDocSetIds.add(progDoc.Id);
            }
        }

        if(programAdmissionDocSetIds.size() == 0) return null;

        for(Id progDocId : programAdmissionDocSetIds){
            DeltakSRP__Program_Admission_Document__c progAdmissDoc = newMap.get(progDocId);
            DeltakSRP__Program_Admission_Document__c oldProgAdmissDoc = oldMap.get(progDocId);
           Opportunity opportunity = new Opportunity(Id = progAdmissDoc.DeltakSRP__Opportunity__c);
            if(opportunity != null)
            {
                if(ProgramAdmissionDocumentToOpptyMapping__c.getAll() != null )
                {
                    for(ProgramAdmissionDocumentToOpptyMapping__c progAdminToOppMapping : ProgramAdmissionDocumentToOpptyMapping__c.getAll().values())
                    {
                        System.debug('programAdminToOppMapping is  @@@@@@@@@@ ' + progAdminToOppMapping);
                        System.debug('Opportunity Id from Program Admission Document  is @@@@@@@@@@@@@@@@ ' + progAdmissDoc.DeltakSRP__Opportunity__c);
                        System.debug('progAdmissDoc.DeltakSRP__Opportunity__r.AccountId@@@@@ ' + progAdmissDoc.DeltakSRP__Opportunity__r.AccountId);
                        System.debug('progAdminToOppMapping.OrganizationId__c  @@@@@@@@ ' + progAdminToOppMapping.OrganizationId__c);
                        System.debug('progAdminToOppMapping.RecordTypeId__c @@@@@@@@@@ ' +  progAdminToOppMapping.RecordTypeId__c);
                        System.debug('progAdmissDoc.RecordTypeId ' +  progAdmissDoc.RecordTypeId);

                        if( progAdminToOppMapping.RecordTypeId__c == progAdmissDoc.RecordTypeId){
                              if(progAdmissDoc.DeltakSRP__Waived__c == oldProgAdmissDoc.DeltakSRP__Waived__c )
                                continue;
                            System.debug('Program Admission Document Value  @@@@@@@@@@ ' + progAdmissDoc.get(progAdminToOppMapping.ProgramAdmissionDocumentField__c));
                            System.debug(('Old Program Admission Document values @@@@@@@@@@@ ' + oldProgAdmissDoc.get(progAdminToOppMapping.ProgramAdmissionDocumentField__c)));
                            {
                                opportunity.put(progAdminToOppMapping.OpportunityField__c, progAdmissDoc.get(progAdminToOppMapping.ProgramAdmissionDocumentField__c));
                            }
                            opportunityMapToUpdate.put(opportunity.Id,opportunity);
                        }
                    }
                }
            }
            System.debug('Opportunity Map in the loop is  @@@@@@@@@@@@@ ' + opportunityMapToUpdate.values().size());

        }
        try
        {
            if(opportunityMapToUpdate.values().size() > 0){
                System.debug('opps map size in the try catch block is  @@@@@@@@@@@@@@@ ' + opportunityMapToUpdate.values().size());
                update opportunityMapToUpdate.values();
            }
        }
        catch (exception e)
        {
            System.debug('Error occured while updating the map values for the Opportunity  @@@@@@@@@@@ ' + e.getMessage());
        }



        return null;
    }

}