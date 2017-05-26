global class SRPBatchUpdateFiscalCalendar implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    private DeltakSRP__Fiscal_Calendar__c [] fiscalCalendar;
    private List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    global SRPbatchUpdateFiscalCalendar(String q, String e, String f, String v){
        fiscalCalendar = [select Id, deltaksrp__Start_Date__c, deltaksrp__End_Date__c 
                          FROM DeltakSRP__Fiscal_Calendar__c];
        Query=q; Entity=e; Field=f;Value=v;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
    
        oppsToUpdate = null;
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('Find the fiscal calendar lookups for this batch...');
        
        for(sObject s : scope){
             if(s.getsObjectType() == Opportunity.sObjectType) {                
                updateOpportunity((Opportunity)s);
             }
        }
        
        System.debug('Update the opportunities for this batch...');
        
        try {
            update oppsToUpdate;
        }
        
        catch(Exception e){
            System.Debug('Error' + e);
        }
    }
    
     
    global void finish(Database.BatchableContext BC){
    }
    
    private void updateOpportunity(Opportunity o) {     
        boolean fiscalCalendarRecordfound = false;
        boolean marketingGoalsRecordfound = false;
        
        //********************************************************  
        //First set the Opportunity lookup to the correct Fiscal Calendar
        //********************************************************          
        for (DeltakSRP__Fiscal_Calendar__c fc : fiscalCalendar) {
            System.debug('Looking at Fiscal Calendar record: ' + fc + 'for Opportunity ' + o);
            
            //see if this fiscal calendar record is within the opportunity's Create Date
            if (o != null && 
                fc != null &&
                o.CreatedDate >= fc.deltaksrp__Start_Date__c &&
                o.CreatedDate <= fc.deltaksrp__End_Date__c) {
                    System.debug('Opportunity ' + o +' will have a lookup to ' + fc);
                    
                    //update Fiscal_Calendar__c lookup to the Financial Calendar record 
                    o.deltaksrp__Fiscal_Calendar__c = fc.Id;
                    
                    //no need to look any further. There will only be one record at most that fits this criteria
                    fiscalCalendarRecordfound = true;
                    break;
            } //end if 
        } //end for 
        
        //If no FC record found, set the lookup to NULL
        if (!fiscalCalendarRecordfound) {
            System.debug('Finscal Calendar record not found. Set Fiscal_Calendar__c to NULL');
                    
            //update Fiscal_Calendar__c lookup to NULL
            o.deltaksrp__Fiscal_Calendar__c = null;
        }
        
        //********************************************************             
        //add the opportunity to the list to be updated
        oppsToUpdate.add(o);
                    
        System.debug('Next opportunity...');
    }
    
    
    
    static testMethod void test_BatchUpdateFiscalCalendar() {
    
        Test.startTest();
        
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
                  
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;   
        /*
        Contact c = new Contact();
        c.AccountID = a.Id;    
        c.FirstName = 'FirstName';
        c.LastName = 'LastName';    
        c.Email = 'test@test.com';
        insert c;
        */
        
        deltaksrp__Academic_Program__c ap = new deltaksrp__Academic_Program__c();
        ap.Name = 'Test Program1028';
        ap.DeltakSRP__School__c = a.Id;
        insert ap;
        
        Schema.DescribeSObjectResult describe = Schema.SObjectType.Opportunity;
        Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
        RecordTypeInfo rt = recordTypes.get('Student Opportunity');
        Id recTypeId = rt.getRecordTypeId();
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        //o.ForecastCategoryName='Pipeline';
        o.Name='Test';
        o.AccountID=a.Id;
        o.DeltakSRP__Academic_Program__c = ap.Id;
        //o.Student__c = c.Id;
        o.RecordTypeId = recTypeId;
        insert o;
        /*
        Opportunity o2 = new Opportunity();
        o2.CloseDate=d;
        o2.StageName='New Inquiry';        
        o2.Name='Test2';
        o2.AccountID=a.Id; 
        o2.Student__c = c.Id;
        insert o2;
        */
        deltaksrp__Fiscal_Calendar__c  fiscalCal = new deltaksrp__Fiscal_Calendar__c();
        fiscalCal.Name = 'FC1028';
        insert fiscalCal;
         
        Campaign camp = new Campaign();
        camp.Name = 'Test campaign';
        camp.Lowest_Level_in_Hierarchy__c = true;
        insert camp;
        
        string query = 
            'SELECT CreatedDate, fiscal_calendar__c, deltaksrp__Academic_Program__c FROM Opportunity LIMIT 100';         
        batchUpdateFiscalCalendar updateFiscalJob = new batchUpdateFiscalCalendar (query, '', '', '');
        //ID batchUpdateFiscalCalendarID = Database.executeBatch(updateFiscalJob); 
         
        Test.stopTest();
        
    }
}