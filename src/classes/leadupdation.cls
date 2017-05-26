global class leadupdation implements Database.Batchable<sobject> {
 global final string query = 'Select id,institution_name__c,address__c,state_abbreviation__c,sector_of_institution__c,total_enrollment__c,full_time_graduate_enrollment__c, full_time_undergraduate_enrollment__c, full_time_retention_rate_2012__c, graduation_rate_total_cohort__c,city__c,zip_code__c, website_address__c from ipeds__c';
    
      
      global leadupdation() {
        //query=q;
        
        }
        
      global database.querylocator start(database.batchablecontext BC) {
        return Database.getquerylocator (query);
        }
        
      global void execute(database.batchablecontext BC, list<sobject> scope) {
        Set<String> institutionsName = new Set<String>();
        Map<String,sobject> newIpeds = new Map<String,sobject>();  
          
       
        for (sobject s :scope)
        {
            institutionsName.add(((ipeds__c)s).institution_name__c);
            newIpeds.put(((ipeds__c)s).institution_name__c, s);
        }
        
        system.debug('institutionsName>>>>'+institutionsName);
        
        List<lead> leads = [Select id,company, Full_time_graduate_enrollment__c,Full_time_retention_rate_2012__c,Full_time_undergraduate_enrollment__c,
        Graduation_rate_total_cohort__c, Sector_of_Institution__c, Total_enrollment__c,website_address__c
         from lead where isconverted = false AND company in :institutionsName AND RecordType.Name = 'Business Development'];
        
        for(Lead l : Leads)
        {
        
        	if(((ipeds__c)(newIpeds.get(l.company))) != null){
             l.Full_time_retention_rate_2012__c = ((ipeds__c)(newIpeds.get(l.company))).full_time_retention_rate_2012__c;
             l.Full_time_graduate_enrollment__c = ((ipeds__c)(newIpeds.get(l.company))).full_time_graduate_enrollment__c;
             l.Full_time_undergraduate_enrollment__c = ((ipeds__c)(newIpeds.get(l.company))).full_time_undergraduate_enrollment__c;
             l.Graduation_rate_total_cohort__c = ((ipeds__c)(newIpeds.get(l.company))).graduation_rate_total_cohort__c;
             l.Sector_of_Institution__c = ((ipeds__c)(newIpeds.get(l.company))).sector_of_institution__c;
             l.Total_enrollment__c = ((ipeds__c)(newIpeds.get(l.company))).total_enrollment__c;
             l.website_address__c = ((ipeds__c)(newIpeds.get(l.company))).website_address__c;
        	} 
             
        }
        update leads;
        
      }
        
      global void finish(database.batchablecontext bc)
      {
      }
     
     
    }