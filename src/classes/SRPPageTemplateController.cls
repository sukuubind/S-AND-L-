public with sharing class SRPPageTemplateController {

  public String footerHtml{get;set;}
  public String styleOverride{get;set;}
  public String title{get;set;}
  public String accountName{get;set;}
  public String accountId{get;set;}

  public SRPPageTemplateController(){
    
        User currentUser = [Select Id, contactid from User where Id=: userinfo.getuserid()];
        
        if(currentUser.ContactId != null){
          Contact c = [SELECT accountid, Account.Name, Account.DeltakSRP__Footer_HTML__c, Account.DeltakSRP__Style_Override__c, Account.DeltakSRP__Title__c FROM Contact WHERE Id = :currentUser.ContactId];
          footerHtml = c.Account.DeltakSRP__Footer_HTML__c;
          styleOverride = c.Account.DeltakSRP__Style_Override__c;
          title = c.Account.DeltakSRP__Title__c;
          accountname = c.account.name;
          accountid = c.accountid;
        }
        
  }
}