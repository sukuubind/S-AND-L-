global class scheduleBatchUpdateCaseEmailCounter implements Schedulable {
global void execute(SchedulableContext SC) {
BatchCaseEmailCounter M = new BatchCaseEmailCounter();
Database.executeBatch(M);
}}