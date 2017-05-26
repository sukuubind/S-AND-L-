/**
 * Created by sukumar.bindra1 on 2/22/2017.
 */

public with sharing class FormattedPhoneContactController {

    public Contact cont { get; set; }

    public FormattedPhoneContactController(ApexPages.StandardController stdController) {
        this.cont = [SELECT Id,Phone,DeltakSRP_Formatted_Phone__c FROM Contact WHERE Id = :stdController.getRecord().id];

    }

}