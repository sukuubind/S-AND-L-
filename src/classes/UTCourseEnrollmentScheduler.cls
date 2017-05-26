global class UTCourseEnrollmentScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
		
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.UT_Course_Enrollment__c.fields.getMap();
		List<String> fieldList = new List<String>();
		for(String s : schemaFieldMap.keySet())
		{
			fieldList.add(s);
		}
		
		String q = 'SELECT ' + String.join(fieldList,',') + 
		' FROM UT_Course_Enrollment__c WHERE Status__c = \'New\'';
		Id batchInstanceId = Database.executeBatch(new UTCourseEnrollmentBatchProcess(q), 200);  
      
   }
}