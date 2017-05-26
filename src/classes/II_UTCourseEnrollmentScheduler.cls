global class II_UTCourseEnrollmentScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
		
		try {
			kickoffBatch();
		}catch(Exception e) {
			logException(e);
		}
		
   }
   
   global void kickoffBatch()
   {
   	
   		Map<String, Schema.SObjectField> iiSchemaFieldMap = Schema.SObjectType.Integration_Interface__c.fields.getMap();
		List<String> iiFieldList = new List<String>();
		for(String s : iiSchemaFieldMap.keySet())
		{
			iiFieldList.add(s);
		}
			
		String iiQuery = 'SELECT ' + String.join(iiFieldList,',') + 
		' FROM Integration_Interface__c WHERE Interface_Identifier__c = \'UTX Course Enrollments\' AND Status__c != \'Deactivated\'';
		
		List<Integration_Interface__c> iiList = Database.query(iiQuery);
		
		Integration_Interface__c ii = null;
	
		if(iiList.size() > 0)
		{
			ii = iiList[0];	
			ii.Status__c = 'Queued';
		}
		
		
		
		Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Integration_Transaction__c.fields.getMap();
		List<String> fieldList = new List<String>();
		for(String s : schemaFieldMap.keySet())
		{
			fieldList.add(s);
		}
			
		fieldList.add('Integration_Interface__r.Interface_Identifier__c');
		fieldList.add('Integration_Interface__r.Raw_Header__c');
			
		String q = 'SELECT ' + String.join(fieldList,',') + 
		' FROM Integration_Transaction__c WHERE Processing_Status__c = \'Queued\' AND Integration_Interface__c = \'' + ii.Id + '\'';
		
		Id batchInstanceId = Database.executeBatch(new II_UTCourseEnrollmentBatchProcess(q,ii), Integer.valueOf(ii.Records_Per_Batch__c)); 
		
   }
   
   global void logException(Exception e)
   {
   		
   		Map<String, Schema.SObjectField> iiSchemaFieldMap = Schema.SObjectType.Integration_Interface__c.fields.getMap();
		List<String> iiFieldList = new List<String>();
		for(String s : iiSchemaFieldMap.keySet())
		{
			iiFieldList.add(s);
		}
			
		String iiQuery = 'SELECT ' + String.join(iiFieldList,',') + 
		' FROM Integration_Interface__c WHERE Interface_Identifier__c = \'UTX Course Enrollments\' AND Status__c != \'Deactivated\'';
		
		List<Integration_Interface__c> iiList = Database.query(iiQuery);
		
		Integration_Interface__c ii = null;
	
		if(iiList.size() > 0)
		{
			ii = iiList[0];	
		}
		
		ii.Status__c = 'Ready';
		ii.Last_Error__c = 'Apex Class: UTCourseEnrollmentScheduler.cls Line Number: ' + e.getLineNumber() + '\r\nMessage: ' + e;
		
		update ii;
   }
   
}