public class warningBarContactController {
    private final Contact affiliation;
    public boolean doNotCall {get;set;}
    public boolean okToText {get;set;}
    public boolean emailOptOut {get;set;}  
    public boolean doNotRegister {get;set;}
    public boolean recordedCall {get;set;}
    public string barWidth {get;set;}
    
    
    public warningBarContactController(ApexPages.StandardController stdController) {
        //this.oppty = (Opportunity)stdController.getRecord();
        integer numTrue = 0;
        this.affiliation = [SELECT DoNotCall, Ok_To_Text__c, HasOptedOutOfEmail, Do_Not_Register__c, Recorded_Call__c FROM Contact WHERE Id = :stdController.getRecord().id];
        if(affiliation.DoNotCall == True){
            doNotCall = true;
            numTrue++;
        }else{
            doNotCall = false;
            numTrue++;
        }
        if(affiliation.OK_To_Text__c == 'Yes'){
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
            
        }
        if(affiliation.Recorded_Call__c == 'Yes'){
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