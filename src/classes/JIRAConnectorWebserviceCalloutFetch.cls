global class JIRAConnectorWebserviceCalloutFetch {

    public static String responseBody;
  

 @future (callout=true) WebService static void getResultJson(String objectType, String objectId, String projectKey, String issueType) {
     
        try {
            List<Case> myCase= new List<Case>();
            HttpRequest req = buildRequest(JIRA.baseUrl, JIRA.username, JIRA.password, Label.JIRA_System_ID, objectType, objectId);
            HttpResponse res = JIRA.sendRequest(req);
            responseBody = res.getBody();
            System.debug('response body>>>>'+responseBody);  
                      
            myCase = [Select Id, JIRA_Ticket_Exists__c From Case where Id =: objectId limit 1];
          
            for (Case mc: myCase){
                if (responseBody.contains('There are no associated issues'))
                {
                JIRAConnectorWebserviceCalloutCreate.createIssue(Label.JIRA_Base_URL, Label.JIRA_System_ID, objectType, mc.Id, projectKey, issueType);
                }
                	mc.JIRA_Ticket_Exists__c=true;
            }      
            
            
            if(!test.isrunningtest())       
             Database.update(myCase); 
             
        } catch(System.CalloutException e) {
            System.debug(e);
            
        }
    }
    
    // Constructs request needed to fetch JIRA issues from provided parameters.
    @testVisible private static HttpRequest buildRequest(String baseUrl, String username, String password,
                                     String systemId, String objectType, String objectId) {
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRA.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, Label.JIRA_System_ID, objectType, objectId);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        return req;
    }
 
    // Creates the endpoint to fetch the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        //return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/fetch.json';
        return baseUrl + '/plugins/servlet/customware/connector/issue/' + Label.JIRA_System_ID + '/' + objectType + '/fetch.action?id='+objectId;
    }
  
}