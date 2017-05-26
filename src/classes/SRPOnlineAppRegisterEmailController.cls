public with sharing class SRPOnlineAppRegisterEmailController {
 public Id OppId {get; set;}
 public Opportunity opp {get;set;}
 
 public void getOpportunityData(){
 	opp = new Opportunity();
 	system.debug('OppId>>>>'+oppid);
 	opp = [Select owner.name, owner.email, deltaksrp__student__r.name from Opportunity where Id =: OppId];
 }
 
}