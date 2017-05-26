global without sharing class II_ProcessManualIntegrationTransactions {


webservice static String processUTX_Course_Enrollments(List<Id> itIdList) {
	
	String result = 'none';
	
	Map<String, Schema.SObjectField> iiSchemaFieldMap = Schema.SObjectType.Integration_Interface__c.fields.getMap();
	List<String> iiFieldList = new List<String>();
	for(String s : iiSchemaFieldMap.keySet())
	{
		iiFieldList.add(s);
	}
			
	String iiQuery = 'SELECT ' + String.join(iiFieldList,',') + 
	' FROM Integration_Interface__c WHERE Interface_Identifier__c = \'UTX Course Enrollments\'';
		
	List<Integration_Interface__c> iiList = Database.query(iiQuery);
	
	Integration_Interface__c ii = null;
	
	if(iiList.size() > 0)
	{
		ii = iiList[0];	
		
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
		
		if(itIdList.size() > 0)
		{
			q += ' AND Id IN :itIdList';
		}
		
		q += ' LIMIT ' + ii.Records_Per_Batch__c;
		
		List<Integration_Transaction__c> itList = Database.query(q);
		
		
		if(itList.size() > 0)
		{
			result = 'complete';
			itList = II_ProcessUTCourseEnrollments.processIntegrationTransactions(ii, itList);
			
			for(Integration_Transaction__c it : itList)
			{
				if(it.Processing_Status__c == 'Errored')
				{
					result = 'errors';
				}
				else
				{
					it.Processing_Status__c = 'Completed';
					it.Last_Error__c = '';
				}
			}
			
			update itList;
		}
		
	}
	else
	{
		result = 'missingii';
	}
	
	
	return result;
	
}

}