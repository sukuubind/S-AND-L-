public with sharing class AdmissionsDocsController {
	
	//
	public string OpptyId {get; set;}
	
	public List <Program_Admission_Document__c> missingDocsList {
		get {
			System.debug ('!!!!!! AdmissionsDocsController - get missingDocsList !!!!!!!');
			
			Program_Admission_Document__c [] docsList;
			
			docsList = [
				SELECT Detail__c, RecordType.Name, Date_Received__c, Order__c, Status__c, Status_Boolean__c, Comments__c 
				FROM Program_Admission_Document__c
				WHERE Opportunity__c = : OpptyId
				AND Received__c = 'FALSE'
				ORDER BY Order__c];
			
			return docsList;
		}
		 
		set;
	}
	
	public List <Program_Admission_Document__c> receivedDocsList {
		get {
			System.debug ('!!!!!! AdmissionsDocsController - get receivedDocsList !!!!!!!');
			
			Program_Admission_Document__c [] docsList;
			
			docsList = [
				SELECT Detail__c, RecordType.Name, Date_Received__c, Order__c, Status__c, Status_Boolean__c, Comments__c 
				FROM Program_Admission_Document__c
				WHERE Opportunity__c = : OpptyId
				AND Received__c = 'TRUE'
				ORDER BY Order__c];
			
			return docsList;
		}
		
		set;
	}
	
	public AdmissionsDocsController() {
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