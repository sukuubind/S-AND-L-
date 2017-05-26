global class SRPDeactivateOLAUserScheduler implements Schedulable {
	
	global String CRON_EXP = '0 0 0 15 3 ? 2022';
	
	 global void execute(SchedulableContext SC) {
	 	
	 	SRPDeactivateOLAUser d = new  SRPDeactivateOLAUser();
	    database.executebatch(d); 
	 } 
	 
}