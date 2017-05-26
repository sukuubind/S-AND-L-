@isTest  //(seealldata=true)
public class TestBatchCaseEmailCounter {

public static testMethod void testBatch() {
// create 200 Contacts and 200 Opportunities - this simulates one execute
//Important - the Salesforce.com test framework only allows you to execute one execute

//insert custom setting
Id RecDeltakPSCReadOnlyId = [Select Id from RecordType where SobjectType='Case' and DeveloperName = 'Deltak_PSC_Support_Read_Only'].Id;
Id RecDeltakPSCSupportID = [Select Id from RecordType where SobjectType='Case' and DeveloperName = 'Deltak_PSC_Support'].Id;
insert new CherwellSettings__c(SetupOwnerId  = System.UserInfo.getOrganizationId(), Email_Limit__c = '3', DeltakPSCSupportReadOnlyID__c=RecDeltakPSCReadOnlyId,  DeltakPSCSupportID__c= RecDeltakPSCSupportID );    

    
List<Case> Cont = new List<Case>();


for (Integer i = 0; i<200;i++){
Case C = new Case();
C.status = 'New';
C.ownerid = '00560000001VnHv';
C.Cherwell_Case_ID__c = 'T1234';
C.Case_Creation__c = 'Cherwell';
C.Description = 'Test';
C.RecordTypeId = RecDeltakPSCSupportID; 
    if(i==0){
    C.sendAttachment__c = True;
    //C.Email_Counter__c = ;
    }
Cont.add(C);

}
Insert(Cont);
System.debug(Cont.size());

Attachment attach=new Attachment();   	
attach.Name='Unit Test Attachment';
Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
attach.body=bodyBlob;
attach.parentId=Cont[0].id;
insert attach;
    	
List<Attachment> attachments=[select id, name from Attachment where parent.id=:Cont[0].id];
System.assertEquals(1, attachments.size());

update Cont[0];
    
Test.StartTest();

BatchCaseEmailCounter BU = new BatchCaseEmailCounter();
//BU.query='Select ID,Name,Stop_Eloqua_Sync__c,Stop_Eloqua_Sync_Date__c from Contact where createddate = today()'
Database.executeBatch(BU);
Test.StopTest();

List<Case> CList = [Select ID,Email_Counter__c from Case where Email_Counter__c != 0 AND Case_Creation__c = 'Cherwell'];
System.AssertEquals(CList.size(),0);
}}