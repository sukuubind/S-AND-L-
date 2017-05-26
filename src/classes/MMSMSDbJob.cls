global class MMSMSDbJob implements Database.Batchable<sObject>{
   global final String query;
   global final DateTime sdt;
   global final DateTime edt;
   global final string op;
   global MMSMSDbJob(String q, string startDate, string endDate, string operation){
             sdt = DateTime.parse(startDate);
             edt = DateTime.parse(endDate);
             query = q + ' where CreatedDate >= :sdt and CreatedDate <= :edt';
             op = operation;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       MMUtilBatchJob.upsertBatchCount (0);
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       long cnt = scope.size();
       if (op == 'd') {
           delete scope;
       }
       MMUtilBatchJob.upsertBatchCount (cnt);
   }

   global void finish(Database.BatchableContext BC){
       MMUtilBatchJob.stopBatchCount();
   }
}