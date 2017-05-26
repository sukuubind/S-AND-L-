/**
 * Created by sukumar on 3/20/2017.
 */

public class StudentOnlineAppToLetterOfReference {
// Define variables
    List<DeltakSRP__Student_Letter_of_Reference_Selection__c> newList;
    Map<Id, DeltakSRP__Student_Letter_of_Reference_Selection__c> newMap;

    public StudentOnlineAppToLetterOfReference(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> newList, Map<Id, DeltakSRP__Student_Letter_of_Reference_Selection__c> newMap) {
        // Assign value to variables
        this.newList = newList;
        this.newMap = newMap;
    }

    public static Map<Id, DeltakSRP__Student_Letter_of_Reference__c> valuesFromSOAToSLRAfterInsert(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> newList, Map<Id, DeltakSRP__Student_Letter_of_Reference_Selection__c> newMap) {
        // Identify the records to be processed
        Set<Id> accountSetIds = new Set<Id>();
        Set<Id> sOASetIds = new Set<Id>();
        Set<Id> sLRSetIds = new Set<Id>();
        Map<Id, DeltakSRP__Student_Online_Application__c> sOAMap = new Map<Id, DeltakSRP__Student_Online_Application__c>();
        Map<Id, DeltakSRP__Student_Letter_of_Reference__c> sLRMapToUpdate = new Map<Id, DeltakSRP__Student_Letter_of_Reference__c>();

        // Forming the Dynamic query

        String queryFields = 'Select Id';

        for (StudentOnlineApplicationToSLR__c soaToslrQueryFields : StudentOnlineApplicationToSLR__c.getAll().values()) {
            queryFields = queryFields + ',' + soaToslrQueryFields.Field_Name__c;
        }
        queryFields = queryFields + ' , DeltakSRP__Affiliation__r.Account.Waiver_Options_Enabled__c FROM DeltakSRP__Student_Online_Application__c WHERE Id IN: sOASetIds';
        system.debug('queryFields  ############ ' + queryFields);

        for (DeltakSRP__Student_Letter_of_Reference_Selection__c slrs : newMap.values()) {
            sLRSetIds.add(slrs.DeltakSRP__Student_Letter_of_Reference__c);
            sOASetIds.add(slrs.DeltakSRP__Student_Online_Application__c);
        }

        if (sOASetIds.size() == 0) return null;
        for (DeltakSRP__Student_Online_Application__c soa : Database.query(queryFields)) {
            if (soa.DeltakSRP__Affiliation__r.Account.Waiver_Options_Enabled__c) {
                if (soa.I_waive_my_right_to_access_this_report__c != Null && soa.LOR_Attestation_Signature__c != Null && soa.LOR_Waive_Selection_Signature__c != Null) {
                    sOAMap.put(soa.Id, soa);
                } else {
                    throw new customException('Please fill Ferpa fields under Reference tab');
                }

            }
        }

        if (sOAMap.size() == 0) return Null;

        for (Id slrsId : newMap.keySet()) {
            DeltakSRP__Student_Letter_of_Reference_Selection__c slrs = newMap.get(slrsId);
            if (slrs.DeltakSRP__Student_Online_Application__c != null && slrs.DeltakSRP__Student_Letter_of_Reference__c != null) {
                DeltakSRP__Student_Letter_of_Reference__c slr = new DeltakSRP__Student_Letter_of_Reference__c(Id = slrs.DeltakSRP__Student_Letter_of_Reference__c);
                if (StudentOnlineApplicationToSLR__c.getAll() != null) {
                    for (StudentOnlineApplicationToSLR__c soaToslr : StudentOnlineApplicationToSLR__c.getAll().values()) {

                        slr.put(soaToslr.Field_Name__c, sOAMap.get(slrs.DeltakSRP__Student_Online_Application__c).get(soaToslr.Field_Value__c));
                        //  slr.Ferpa_Fields_On_SOA_Filled__c = true;
                        System.debug ('ssoaToslr.Field_Name__c is   ' + soaToslr.Field_Name__c);
                        System.debug('sOAMap.getslrs.DeltakSRP__Student_Online_Application__c.getsoaToslr.Field_Value__c ' + sOAMap.get(slrs.DeltakSRP__Student_Online_Application__c).get(soaToslr.Field_Value__c));
                        sLRMapToUpdate.put(slr.Id, slr);
                    }
                }
            }
        }

        Try {
            update sLRMapToUpdate.values();
        } catch (exception e) {
            System.debug('An error occured while updating the list &&&&&&&&&&&&  ' + e.getMessage());
        }
        return sLRMapToUpdate;
    }

    public static Map<Id, DeltakSRP__Student_Letter_of_Reference__c> valuesFromSOAToSLRAfterInsertForAll(List<DeltakSRP__Student_Letter_of_Reference_Selection__c> newList, Map<Id, DeltakSRP__Student_Letter_of_Reference_Selection__c> newMap) {
        // Identify the records to be processed
        Set<Id> accountSetIds = new Set<Id>();
        Set<Id> sOASetIds = new Set<Id>();
        Set<Id> sLRSetIds = new Set<Id>();
        Map<Id, DeltakSRP__Student_Online_Application__c> sOAMap = new Map<Id, DeltakSRP__Student_Online_Application__c>();
        Map<Id, DeltakSRP__Student_Letter_of_Reference__c> sLRMapToUpdate = new Map<Id, DeltakSRP__Student_Letter_of_Reference__c>();

        // Forming the Dynamic query

        String queryFields = 'Select Id';

        for (StudentOnlineApplicationToSLRForAll__c soaToslrQueryFields : StudentOnlineApplicationToSLRForAll__c.getAll().values()) {
            queryFields = queryFields + ',' + soaToslrQueryFields.Field_Name__c;
        }
        queryFields = queryFields + '   FROM DeltakSRP__Student_Online_Application__c WHERE Id IN: sOASetIds';
        system.debug('queryFields  ############ ' + queryFields);

        for (DeltakSRP__Student_Letter_of_Reference_Selection__c slrs : newMap.values()) {
            sLRSetIds.add(slrs.DeltakSRP__Student_Letter_of_Reference__c);
            sOASetIds.add(slrs.DeltakSRP__Student_Online_Application__c);
        }

        if (sOASetIds.size() == 0) return null;
        for (DeltakSRP__Student_Online_Application__c soa : Database.query(queryFields)) {

            if (soa.Program_Id__c != null) {
                sOAMap.put(soa.Id, soa);
            } else {
                return null;
            }

        }
        if (sOAMap.size() == 0) return Null;

        for (Id slrsId : newMap.keySet()) {
            DeltakSRP__Student_Letter_of_Reference_Selection__c slrs = newMap.get(slrsId);
            if (slrs.DeltakSRP__Student_Online_Application__c != null && slrs.DeltakSRP__Student_Letter_of_Reference__c != null) {
                DeltakSRP__Student_Letter_of_Reference__c slr = new DeltakSRP__Student_Letter_of_Reference__c(Id = slrs.DeltakSRP__Student_Letter_of_Reference__c);
                if (StudentOnlineApplicationToSLRForAll__c.getAll() != null) {
                    for (StudentOnlineApplicationToSLRForAll__c soaToslr : StudentOnlineApplicationToSLRForAll__c.getAll().values()) {

                        slr.put(soaToslr.Field_Name__c, sOAMap.get(slrs.DeltakSRP__Student_Online_Application__c).get(soaToslr.Field_Value__c));
                        //  slr.Ferpa_Fields_On_SOA_Filled__c = true;
                        System.debug ('ssoaToslr.Field_Name__c is   ' + soaToslr.Field_Name__c);
                        System.debug('sOAMap.getslrs.DeltakSRP__Student_Online_Application__c.getsoaToslr.Field_Value__c ' + sOAMap.get(slrs.DeltakSRP__Student_Online_Application__c).get(soaToslr.Field_Value__c));
                        sLRMapToUpdate.put(slr.Id, slr);
                    }
                }
            }
        }

        Try {
            update sLRMapToUpdate.values();
        } catch (exception e) {
            System.debug('An error occured while updating the list &&&&&&&&&&&&  ' + e.getMessage());
        }
        return sLRMapToUpdate;
    }
}