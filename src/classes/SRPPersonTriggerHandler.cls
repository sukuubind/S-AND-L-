public with sharing class SRPPersonTriggerHandler {

	public static void onBeforeInsert(List<DeltakSRP__Person__c> persons){
		for(DeltakSRP__Person__c p: persons){
			if(p.DeltakSRP__First_Name__c!=null && p.DeltakSRP__First_Name__c.length() > 1)
          	  p.DeltakSRP__First_Name__c = p.DeltakSRP__First_Name__c.substring(0,1).toUpperCase()+p.DeltakSRP__First_Name__c.substring(1,p.DeltakSRP__First_Name__c.length()).toLowerCase();
            if(p.DeltakSRP__Last_Name__c!=null && p.DeltakSRP__Last_Name__c.length() > 1)
          	  p.DeltakSRP__Last_Name__c = p.DeltakSRP__Last_Name__c.substring(0,1).toUpperCase()+p.DeltakSRP__Last_Name__c.substring(1,p.DeltakSRP__Last_Name__c.length()).toLowerCase();
          	
          	p.name = p.DeltakSRP__First_Name__c + ' ' + p.DeltakSRP__Last_Name__c;
          	  
		}          
	}

}