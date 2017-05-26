public with sharing class FormattedPhoneOppController {

    public Opportunity oppty { get; set; }

    public FormattedPhoneOppController(ApexPages.StandardController stdController) {
        this.oppty = [SELECT Id,Formatted_Phone__c FROM Opportunity WHERE Id = :stdController.getRecord().id];

    }

}