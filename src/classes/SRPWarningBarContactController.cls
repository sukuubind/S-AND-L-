public with sharing class SRPWarningBarContactController {
private final Contact affiliation;
    public boolean doNotCall {get;set;}
    public boolean okToText {get;set;}
    public boolean emailOptOut {get;set;}  
    public boolean doNotRegister {get;set;}
    public string barWidth {get;set;}
    public boolean recordedcall {get; set;}
    
    public SRPwarningBarContactController(ApexPages.StandardController stdController) {
        //this.oppty = (Opportunity)stdController.getRecord();
        integer numTrue = 0;
        this.affiliation = [SELECT DeltakSRPSMS__Ok_To_Text__c, DoNotCall, Ok_To_Text__c, HasOptedOutOfEmail, Do_Not_Register__c, recorded_call__c FROM Contact WHERE Id = :stdController.getRecord().id];
        if(affiliation.DoNotCall == True){
            doNotCall = true;
            numTrue++;
        }else{
            doNotCall = false;
            numTrue++;
        }
        if(affiliation.DeltakSRPSMS__Ok_To_Text__c == true){
            okToText = true;
            numTrue++;
        }else{
            okToText = false;
            numTrue++;
        }
        if(affiliation.HasOptedOutOfEmail == true){
            emailOptOut = true;
            numTrue++;
        }else{
            emailOptOut = false;
            numTrue++;
        }
        if(affiliation.Do_Not_Register__c == true){
            doNotRegister = true;
            numTrue++;
        }else{
            doNotRegister = false;
            numTrue++;
            
        }
        if(affiliation.recorded_call__c == 'Yes'){
            recordedcall = true;
            numTrue++;
        }else{
            recordedcall = false;
            numTrue++;
            
        }
        system.debug('affiliation.Do_Not_Register__c>>>>'+affiliation.Do_Not_Register__c);
        system.debug('numtrue');
        
        if(numTrue == 1){
            barWidth = 'width:100%;';
        }else if(numTrue == 2){
            barWidth = 'width:50%;';
        }else if(numTrue == 3){
            barWidth = 'width:33.333%;';
        }else if(numTrue == 4){
            barWidth = 'width:25%;';
        }else if(numTrue == 5){
            barWidth = 'width:20%;';
        }
    }
}