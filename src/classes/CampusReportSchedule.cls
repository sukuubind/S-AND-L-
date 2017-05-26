global class CampusReportSchedule implements Schedulable{
	static String CRON_EXP = '0 0 1 ? * * 2022';
    
    global void execute(SchedulableContext ctx) {
        
        List<Email_Partner_Reports__c> partnerReportEmailList = Email_Partner_Reports__c.getAll().values();
        Map<String, String> partnerEmailIds = new Map<String, String>();
        List<Partner_Report__c> partnerReportList = new List<Partner_Report__c>();
        if(partnerReportEmailList!=null && partnerReportEmailList.size()>0)
        {
        	for(Email_Partner_Reports__c ePR: partnerReportEmailList)
        	{
        		if(ePR.Email_Address__c!=null)
        		{
        			partnerEmailIds.put(ePR.Email_Address__c, ePR.Account_Name__c);
        		}
        	}
        }
        
        if(partnerEmailIds!=null && partnerEmailIds.size()>0)
        {
        	for(String eml: partnerEmailIds.keySet())
        	{
        		Partner_Report__c pr = new Partner_Report__c();
        		pr.Which_Email__c = eml;
        		pr.Which_Partner__c = partnerEmailIds.get(eml);
        		partnerReportList.add(pr);
        	}
        	if(partnerReportList!=null && partnerReportList.size()>0)
        	{
        		Database.insert(partnerReportList, false);
        	}
        }
   
    } 
	
}