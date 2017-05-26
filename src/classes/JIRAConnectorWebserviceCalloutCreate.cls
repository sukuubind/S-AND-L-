global class JIRAConnectorWebserviceCalloutCreate {
 

    @future (callout=true) WebService static void createIssue(String baseUrl, String systemId, String objectType, String objectId, String projectKey, String issueType) {
        try {
            
            HttpRequest req = buildRequest(baseUrl, JIRA.username, JIRA.password, Label.JIRA_System_ID, objectType, objectId, projectKey, issueType);
            
            JIRA.sendRequest(req);
              
        } catch(System.CalloutException e) {
            System.debug(e);
        }
    }
 
    // Constructs request needed to create a JIRA issue from provided parameters.
    @testVisible private static HttpRequest buildRequest(String baseUrl, String username, String password,
                                           String systemId, String objectType, String objectId,
                                           String projectKey, String issueType) {
            
        HttpRequest req = new HttpRequest();
        String basicAuthHeader = JIRA.authHeader(username, password);
        String endpoint = getEndpoint(baseUrl, Label.JIRA_System_ID, objectType, objectId);
        req.setHeader('Authorization', basicAuthHeader);
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody('{"project":"' + projectKey + '", "issueType":"' + issueType + '"}');
        return req;
    }
 
    // Creates the endpoint to create the issue from provided parameters.
    private static String getEndpoint(String baseUrl, String systemId, String objectType, String objectId) {
        return baseUrl + '/rest/customware/connector/1.0/' + systemId + '/' + objectType + '/' + objectId + '/issue/create.json';
    }
 
}