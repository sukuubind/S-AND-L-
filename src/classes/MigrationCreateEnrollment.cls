public class MigrationCreateEnrollment {
	
	public static void run() {
		
		List<Opportunity> startOpps = [select Id, Student__c, Program__c, Start_Date__c
			from Opportunity where StageName = 'Start'];
			
		List<Student_Enrollment__c> newEnrolls = new List<Student_Enrollment__c>();
		List<Id> opportunityIdList = new List<Id>();
			
		for (Opportunity newRecord : startOpps) {
			Student_Enrollment__c enrollment = new Student_Enrollment__c();
			enrollment.Student_Affiliation__c = newRecord.Student__c;
            enrollment.Program__c = newRecord.Program__c;
            enrollment.Start_Date__c = newRecord.Start_Date__c;
            enrollment.Opportunity__c = newRecord.Id;
            opportunityIdList.add(newRecord.id);
            newEnrolls.add(enrollment);
            System.Debug('ENROLLMENT ID'+enrollment.id);
           
		}
		if (newEnrolls.size() > 0) {
			insert newEnrolls;
			
		}
		
		
		List<Student_Enrollment__c> studentEnrollment = [select Id, Opportunity__c From Student_Enrollment__c
			 where Opportunity__c IN :opportunityIdList];
		Map<Id, Id> opportunityToEnrollment = new Map<Id, Id>();
			for(Student_Enrollment__c newRecord : studentEnrollment){
				opportunityToEnrollment.put(newRecord.Opportunity__c, newRecord.id);
			}
			
		List<Opportunity> opportunityList = [Select id,  Student_Enrollment__c
													From Opportunity
													Where id in :opportunityIdList];
		for(Opportunity opp : opportunityList){
			opp.Student_Enrollment__c = opportunityToEnrollment.get(opp.id);
		}
		
		
		if(opportunityList != null && opportunityList.size() > 0){
			update opportunityList;
		}
						
		
		
	}
}