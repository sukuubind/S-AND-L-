@isTest(SeeAllData=true) 
private class Test_CherwellCodeRestAPI {

static {

Account a = new Account();
        a.Name = 'Test Account';
        insert a;




RecordType crecord = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
          Contact c1 = new Contact ();
          c1.AccountId = a.Id;
          c1.FirstName='Joe';
          c1.LastName='Smith';
          c1.Phone='2222222222';
          c1.AccountId = a.Id;   
          c1.Employer_Company__c = '';
          c1.RecordTypeId = crecord.id;
          
          
          insert c1;


ResponseHandlerCherwell response = CherwellCodeRestAPI.post('Phone','New','00560000001VnHvAAK','This is Cherwell ID',c1.id,'CallerName','111-111-1111','CallerEmail@mail.com','Normal','Issue','Mechanical','Admissions','Test Course','James Bond','This is the Subject for the case created by Rest Services','This is the Description for the case created by Rest Services',true,'EscalationCode','Resolution for the case created thru Web Services Rest', 'Create','Cherwell');
 // Case C = new Case();
   // C.Status = 'New';
    //C.Origin = 'Cherwell';
    //C.recordtypeID = '012j0000000zTQKAA2';
    //C.Case_Creation__c = 'Cherwell';
    //insert C;
    
    System.assertEquals('Success',response.Status);
System.assertEquals(null, response.ErrorCode);
System.assertEquals(null, response.message);

}

static testMethod void testGET() {

RestRequest req = new RestRequest(); 
RestResponse res = new RestResponse();

List<Case> C = [Select id from Case where Status = 'New' limit 1];
String url = 'https://' + System.URL.getSalesforceBaseUrl().getHost();

req.requestURI = url+'/services/apexrest/CherwellCaseIntegration/'+C[0].ID;  
req.httpMethod = 'GET';
RestContext.request = req;
RestContext.response = res;

ResponseHandlerCherwell response = CherwellCodeRestAPI.GET();

System.assertEquals('Success',response.Status);
System.assertEquals('', response.ErrorCode);
System.assertEquals('Success : Found Case', response.message);

}

static testMethod void testput() {


Account a = new Account();
        a.Name = 'Test Account';
        insert a;




RecordType crecord = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
          Contact c1 = new Contact ();
          c1.AccountId = a.Id;
          c1.FirstName='Joe';
          c1.LastName='Smith';
          c1.Phone='2222222222';
          c1.AccountId = a.Id;   
          c1.Employer_Company__c = '';
          c1.RecordTypeId = crecord.id;
          
          
          insert c1;

RestRequest req = new RestRequest(); 
RestResponse res = new RestResponse();

List<Case> C = [Select id from Case where Status = 'New' limit 1];

String url = 'https://' + System.URL.getSalesforceBaseUrl().getHost();

req.requestURI = url+'/services/apexrest/CherwellCaseIntegration/'+C[0].ID;  
req.httpMethod = 'GET';
RestContext.request = req;
RestContext.response = res;

ResponseHandlerCherwell response = CherwellCodeRestAPI.put('Phone','Closed','00560000001VnHvAAK','This is Cherwell ID',c1.id,'CallerName','111-111-1111','CallerEmail@mail.com','Normal','Issue','Mechanical','Admissions','Test Course','James Bond','This is the Subject for the case created by Rest Services','This is the Description for the case created by Rest Services',true,'EscalationCode','Resolution for the case created thru Web Services Rest', 'Create','Cherwell');

 System.assertEquals('Success',response.Status);
System.assertEquals(null, response.ErrorCode);
System.assertEquals(null, response.message);


}



}