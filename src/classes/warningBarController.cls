public class warningBarController {
    private final Opportunity oppty;
    public boolean doNotCall {get;set;}
    public boolean okToText {get;set;}
    public boolean emailOptOut {get;set;} 
    public boolean recordedCall {get;set;} 
    public string barWidth {get;set;}
    
    
    public warningBarController(ApexPages.StandardController stdController) {
        //this.oppty = (Opportunity)stdController.getRecord();
        integer numTrue = 0;
        this.oppty = [SELECT Do_Not_Call__c, OK_To_Text__c, Email_Opt_Out__c, Recorded_Call__c FROM Opportunity WHERE Id = :stdController.getRecord().id];
        if(oppty.Do_Not_Call__c == 'True'){
            doNotCall = true;
            numTrue++;
        }else{
            doNotCall = false;
            numTrue++;
        }
        if(oppty.OK_To_Text__c == 'Yes'){
            okToText = true;
            numTrue++;
        }else{
            okToText = false;
            numTrue++;
        }
        if(oppty.Email_Opt_Out__c == 'True'){
            emailOptOut = true;
            numTrue++;
        }else{
            emailOptOut = false;
            numTrue++;
        }
        
        if(oppty.Recorded_Call__c == 'Yes'){
            recordedCall = true;
            numTrue++;
        }else{
            recordedCall = false;
            numTrue++;
        }
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