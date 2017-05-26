public with sharing class SessionController {


 public String apiSessionId {get;set;} 
 public String apiServerURL {get;set;} 
 
 public PageReference doLogin(){ 
  System.debug('apiSessionId: ' + apiSessionId); 
  System.debug('apiServerURL: ' + apiServerURL); 
  return null; 
 }


}