global class scheduleTaskUpdateOpportunity implements Schedulable {
    static String CRON_EXP = '0 0 0 3 9 ? 2022';
    static Integer BATCH_SIZE = 2000;
    global void execute(SchedulableContext ctx) {
                             
        batchjobupdaterecords taskBatch = new batchjobupdaterecords ();
        ID batchId = Database.executeBatch(taskBatch, BATCH_SIZE); 
        System.debug('Batch Job executed - ID = ' + batchId);
   
    } 
}