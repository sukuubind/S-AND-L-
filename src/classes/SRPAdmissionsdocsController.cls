public with sharing class SRPAdmissionsdocsController {
	
	//
	public string OpptyId {get; set;}
	
	public List <DeltakSRP__Program_Admission_Document__c> missingDocsList {
		get {
			System.debug ('!!!!!! AdmissionsDocsController - get missingDocsList !!!!!!!');
			
			DeltakSRP__Program_Admission_Document__c [] docsList;
			
			docsList = [
				SELECT Detail__c, RecordType.Name, DeltakSRP__Date_Received__c, DeltakSRP__Order__c, DeltakSRP__Status__c, DeltakSRP__Status_Boolean__c, DeltakSRP__Comments__c 
				FROM DeltakSRP__Program_Admission_Document__c
				WHERE DeltakSRP__Opportunity__c = : OpptyId
				AND DeltakSRP__Received__c = 'NO'
				ORDER BY DeltakSRP__Order__c];
			
			return docsList;
		}
		 
		set;
	}
	
	public List <DeltakSRP__Program_Admission_Document__c> receivedDocsList {
		get {
			System.debug ('!!!!!! AdmissionsDocsController - get receivedDocsList !!!!!!!');
			
			DeltakSRP__Program_Admission_Document__c [] docsList;
			
			docsList = [
				SELECT Detail__c, RecordType.Name, DeltakSRP__Date_Received__c, DeltakSRP__Order__c, DeltakSRP__Status__c, DeltakSRP__Status_Boolean__c, DeltakSRP__Comments__c 
				FROM DeltakSRP__Program_Admission_Document__c
				WHERE DeltakSRP__Opportunity__c = : OpptyId
				AND DeltakSRP__Received__c = 'YES'
				ORDER BY DeltakSRP__Order__c];
			
			return docsList;
		}
		
		set;
	}
	
	public SRPAdmissionsDocsController() {
		System.debug ('!!!!!! AdmissionsDocsController() !!!!!!!');
		/*missingDocsList = new List <Program_Admission_Document__c>();
		receivedDocsList = new List <Program_Admission_Document__c>();
		
		docsList = [
			SELECT Detail__c, RecordType.Name, Date_Received__c, Order__c, Status__c, Status_Boolean__c, Comments__c 
			FROM Program_Admission_Document__c
			WHERE Opportunity__c = : OpptyId
			ORDER BY Order__c];
			
		System.debug('!!! AdmissionsDocsController.cls - number of documents for this student: ' + docsList.size());
		
		for (Program_Admission_Document__c d : docsList) {
			
			if (d.Status_Boolean__c == 'TRUE') {
				receivedDocsList.add(d);
			}
			
			else if (d.Status_Boolean__c == 'FALSE') {
				missingDocsList.add(d);
			}
			
			else {
				missingDocsList.add(d);
				System.debug('!!! The document\'s status is not valid. It must be either \'True\' or \'False\'');
			}
		}*/
	}
}