global class ProcessUTCourseEnrollments implements Messaging.InboundEmailHandler {

global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    
    List<UT_Course_Enrollment__c> utCEList = new List<UT_Course_Enrollment__c>();
    System.debug('Number of Binary Attachments: ' + email.binaryAttachments.size());
    if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) 
    {
    	System.debug('Number of Binary Attachments: ' + email.binaryAttachments.size());
    	
    	for(Messaging.InboundEmail.BinaryAttachment btt : email.binaryAttachments)
    	{
    		System.debug('Attachment Name: ' + btt.filename);
    		
    		if(btt.filename.toLowerCase().endsWith('.csv'))
    		{
				utCEList.addAll( UTCourseEnrollmentCSVToSObject.csvToSobject( btt.body.toString(), btt.filename )  );
			}
    	}	
    	
    	if(utCEList.size() > 0)
    	{
    		insert utCEList;
    	}
    }
    
    return result;
    
    }

}