global class PartnerProgamMaturity  implements Schedulable{
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	global void execute(SchedulableContext ctx){
		List<Academic_Program__c> acad_ProgramList = [Select id, Mature_Program__c, Maturity_Status__c 
														From Academic_Program__c
														where Mature_Program__c = 'TRUE'
														];
		List<Academic_Program__c> updateProgramList = new List<Academic_Program__c>();
		for(Academic_Program__c thisProgram : acad_ProgramList){
			thisProgram.Maturity_Status__c = 'Mature';
			updateProgramList.add(thisProgram);
		}
		try{
			update updateProgramList;
		}catch(Exception e){
			System.Debug(e);
		}
	}
}