/**
 * RecordDeltionHandler
 * @description Class for handling adding of sobjects to deletion record queue for SRP Integration
 * @author Sean Barenbrugge
 * @date 2/11/2013
 *
 * 03/04/2013 Update added Integration profile check to the createDeletionRecords(List<sObject> objectList,Map<Id,String> objIdToAccExtId)
 * method
 * @author Orhan Karzan
 */
public class SRPRecordDeletionHandler{
 
    /**
     * @description static helper method for iterating through a list of sobjects
     * and adding them as Deletion_Record__c objects for Integration purposes.
     * @param A list of sobjects retreived from a after delete trigger
     * @param The api name of the sobject type that fired the trigger
     * @param The api name of the External Id field used by the integration
     * @param The api name of the field to determine if its OK to delete these records
     */
    public static void createDeletionRecords(List<sObject> objectList, String objApiName, String extIdName, String okName, Map<Id,String> objIdToAccExtId){
        List<DeltakSRP__Deleted_Record__c> drList = new List<DeltakSRP__Deleted_Record__c>();
        for(sObject obj : objectList){
            Object okToDelete = obj.get(okName);
            Object extId = obj.get(extIdName);
            system.debug('objIdToAccExtId = '+objIdToAccExtId);
            system.debug('obj.id = '+obj.id);
            Object accExtId = objIdToAccExtId.get(obj.id);
            system.debug('accExtId = '+accExtId);
            if(okToDelete != null && extId != null && accExtId != null && ((Boolean)okToDelete)){
                drList.add(new DeltakSRP__Deleted_Record__c(
                    DeltakSRP__External_Id__c=(String)extId,
                    DeltakSRP__Object_Type__c = objApiName,
                    DeltakSRP__Account_External_Id__c = (String)accExtId));
            }
        }
        insert drList;
    }
    
    /**
     * @description static helper method for iterating through a list of sobjects
     * and adding them as Deletion_Record__c objects for Integration purposes.
     * This method utilizes describe calls and automatically renders the prefix of the namespace
     * based on the list of sobjects passed in. 
     * @param A list of sobjects retreived from a after delete trigger
     * @param The api name of the sobject type that fired the trigger
     */
    public static void createDeletionRecords(List<sObject> objectList,Map<Id,String> objIdToAccExtId){
        // skip the logic for the integration user
        DeltakSRP__SRP_Partner_Settings__c setting = DeltakSRP__SRP_Partner_Settings__c.getInstance();
        if(Userinfo.getProfileId() == setting.DeltakSRP__SRP_Integration_Profile_Id__c){
          return;
        }
        Id firstRecordId = objectList.get(0).Id;
        sObjectType stype = firstRecordId.getSobjectType();
        String objectApiName = stype.getDescribe().getName();
        String prefix = 'DeltakSRP__';
        createDeletionRecords(objectList,objectApiName,prefix+'External_Id__c',prefix+'OK_To_Delete__c',objIdToAccExtId);
    }
}