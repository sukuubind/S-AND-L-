global class ProspectScheduler implements Schedulable{
	static String CRON_EXP = '0 0 0 3 9 ? 2022';
    Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
    Integer BATCH_SIZE = Integer.valueOf(setting.Prospect_Batch_Size__c);
    global void execute(SchedulableContext ctx) {
        String query = ProspectConstants.PROLOG_SCHEDULE_QUERY;
        Datetime currentStamp = System.now();
        Time t = currentStamp.timeGMT();
        String month = (String.valueOf(currentStamp.month()).length()==1 ? '0'+String.valueOf(currentStamp.month()) : String.valueOf(currentStamp.month()));
        String thisDate = ((String.valueOf(currentStamp.day())).length() == 1 ? '0'+String.valueOf(currentStamp.day()) : String.valueOf(currentStamp.day()));
        String hour = (String.valueOf(t.hour()).length() == 1 ? '0'+String.valueOf(t.hour()) : String.valueOf(t.hour()));
        String minute = (String.valueOf(t.minute()).length() == 1 ? '0'+String.valueOf(t.minute()) : String.valueOf(t.minute()));
        String timeStamp = String.valueOf(currentStamp.year())+'-'+month+'-'+thisDate+'T'+hour+':'+minute+':00.000Z';
        ProspectScheduleBatch proBatch = new ProspectScheduleBatch(query+timestamp);
        ID batchId = Database.executeBatch(proBatch, BATCH_SIZE); 
        System.debug('Batch Job executed - ID = ' + batchId);
   
    } 
	
}