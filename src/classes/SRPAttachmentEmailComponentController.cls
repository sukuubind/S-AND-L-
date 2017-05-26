global without sharing class SRPAttachmentEmailComponentController {

	global Id aId {get; set;}
	global List<DeltakSRP__Student_Online_Application__c> soa {
		get{
		List<DeltakSRP__Student_Online_Application__c>soalist = new List<DeltakSRP__Student_Online_Application__c>();
		soalist = [Select Name
			 from DeltakSRP__Student_Online_Application__c where Id =:pId];
		system.debug('soa[0]>>>>'+soalist[0]);		 
		return soalist;
		}}
	global Id pId {get; set;}
	global Id oid {get;set;}
	global String oname {get; set;}
	
	
	global SRPAttachmentEmailComponentController(){
		
	}
}