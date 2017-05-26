public with sharing class UticaReportOpportunityPagination {
    private final Opportunity oppty;
    
    public UticaReportOpportunityPagination(ApexPages.Standardsetcontroller controller)
    {
        this.oppty = (Opportunity)controller.getRecord();
        controller.setPageSize(50);
        
    }
    public UticaReportOpportunityPagination(){
        
    }
    
    public ApexPages.Standardsetcontroller opptyappRecords{
        get{
            if(opptyappRecords==null){
                opptyappRecords= new ApexPages.Standardsetcontroller(Database.getQueryLocator(
       /*         [Select o.Student__c,o.Program_Abbrev__c, o.Date_Accepted__c,o.Start_Date__c, o.StageName,  o.File_Complete__c, 
        o.Date_Submitted__c,o.Days_Since_Booked_Application__c   From Opportunity o where account.name like '%Utica%' and
        recordtype.name='Student Opportunity' and start_date__c=NEXT_N_DAYS:120 order by o.Program_Abbrev__c ASC])); */
                
        [Select o.DeltakSRP__Student__c,o.SRP_Program_Abbreviation__c, o.DeltakSRP__Date_Accepted__c,o.DeltakSRP__Start_Date__c, o.StageName,  o.DeltakSRP__File_Complete__c, 
        o.DeltakSRP__Date_Submitted__c,o.SRP_Days_Since_Booked_Application__c   From Opportunity o where account.name like '%Utica%' and
        recordtype.name='SRP Opportunity' and DeltakSRP__Start_Date__c=NEXT_N_DAYS:120 order by o.SRP_Program_Abbreviation__c ASC]));
            opptyappRecords.setPageSize(50);
            }
            return opptyappRecords;
        }
        private set;
    }
    
    public ApexPages.Standardsetcontroller opptyInqRecords{
        get{
            if(opptyInqRecords==null){
                opptyInqRecords =  new ApexPages.Standardsetcontroller(Database.getQueryLocator([Select o.DeltakSRP__Student__c, o.SRP_Program_Abbreviation__c ,o.DeltakSRP__Source__c, 
                CreatedDate From Opportunity o where account.name like '%Utica%' and
        recordtype.name='SRP Opportunity' and CreatedDate=LAST_N_DAYS:120]));
        opptyInqRecords.setPageSize(50);
            }
            return opptyInqRecords;
        }
        private set;
    }
    public void previousInq(){
    opptyInqRecords.previous();
    }
    public void nextInq(){
    opptyInqRecords.next();
    }
    public void previousApp(){
    opptyAppRecords.previous();
    }
    public void nextApp(){
    opptyAppRecords.next();
    }
    public list<Opportunity> getOpportunityAppPagination(){
        return(List<Opportunity>) opptyappRecords.getRecords();
    }
    public list<opportunity> getOpportunityInqPagination(){
            return(List<Opportunity>) opptyInqRecords.getRecords();
    }
}