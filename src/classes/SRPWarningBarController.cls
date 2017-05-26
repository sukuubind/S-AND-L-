public with sharing class SRPWarningBarController {
	private final Opportunity oppty;
    public boolean doNotCall {get;set;}
    public boolean okToText {get;set;}
    public boolean emailOptOut {get;set;}  
    public string barWidth {get;set;}
    public boolean recordedcall {get; set;}
    public boolean relatedOpps {get; set;}
    
    public SRPWarningBarController(ApexPages.StandardController stdController) {
        //this.oppty = (Opportunity)stdController.getRecord();
        integer numTrue = 0;
        this.oppty = [SELECT Id, SRP_Do_Not_Call__c, SRP_OK_To_Text__c, SRP_Email_Opt_Out__c, SRP_Recorded_Call__c, DeltakSRP__Student__c, Student__c, RecordType.Name FROM Opportunity WHERE Id = :stdController.getRecord().id];
        
        Integer countRelOpps = 0;
        if(this.oppty.RecordType.Name == 'SRP Opportunity' && this.oppty.DeltakSRP__Student__c != null && this.oppty.DeltakSRP__Student__c + '' != '')
        {
        	countRelOpps = [SELECT COUNT() FROM Opportunity WHERE DeltakSRP__Student__c = :this.oppty.DeltakSRP__Student__c AND Id != :this.oppty.Id];
        }
        else if(this.oppty.RecordType.Name == 'Student Opportunity' && this.oppty.Student__c != null && this.oppty.Student__c + '' != '')
        {
        	countRelOpps = [SELECT COUNT() FROM Opportunity WHERE Student__c = :this.oppty.Student__c AND Id != :this.oppty.Id];
        }
        
        
        if(oppty.SRP_Do_Not_Call__c == true){
            doNotCall = true;
            numTrue++;
        }else{
            doNotCall = false;
            numTrue++;
        }
        if(oppty.SRP_OK_To_Text__c == true){
            okToText = true;
            numTrue++;
        }else{
            okToText = false;
            numTrue++;
        }
        if(oppty.SRP_Email_Opt_Out__c == true){
            emailOptOut = true;
            numTrue++;
        }else{
            emailOptOut = false;
            numTrue++;
        }
        
        if(oppty.SRP_Recorded_Call__c == 'Yes'){
            recordedCall = true;
            numTrue++;
        }else{
            recordedCall = false;
            numTrue++;
        }
        
        if(countRelOpps > 0){
        	relatedOpps = true;
        	numTrue++;
        }else{
        	relatedOpps = false;
        	numTrue++;
        }
        
        
        barWidth = 'width:' + (100.00/numTrue) +'%;';
        
    }
}