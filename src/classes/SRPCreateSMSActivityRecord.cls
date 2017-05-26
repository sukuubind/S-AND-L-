global class SRPCreateSMSActivityRecord {
	webservice static String createActivity(String recordId, String operation){
		 if(operation != null && operation.equalsIgnoreCase('outgoing'))
		 {
		   return SRPSMSActivityProcessor.createSMSHistoryActivity(recordId, false); 
		 	
		 }else if(operation != null && operation.equalsIgnoreCase('incoming'))
		 {
		   return SRPSMSActivityProcessor.createIncomingSMSActivity(recordId, false);
		 	
		 }else if(operation != null && operation.equalsIgnoreCase('allOppty'))
		 {
		   return SRPSMSActivityProcessor.createAllSMSActivity(recordId, false, 'Oppty'); 
		 	
		 }else if(operation != null && operation.equalsIgnoreCase('allAffl'))
		 {
		   return SRPSMSActivityProcessor.createAllSMSActivity(recordId, false, 'Affl'); 
		 	
		 }else
		 {
		 	return Label.Create_SMS_Activity_Failure;
		 }
		 
		
	}

}