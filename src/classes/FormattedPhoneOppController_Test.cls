/**
 * Created by sukumar.bindra1 on 2/27/2017.
 */

@IsTest
private class FormattedPhoneOppController_Test {
    static testMethod void testBehavior() {

        Contact cont = new Contact(FirstName = 'Test',LastName = 'Test',Phone = '2222222222');
        insert cont;

        Opportunity opp = new Opportunity(Name = 'Test',DeltakSRP__Student__c = cont.Id,StageName ='Prospecting',CloseDate = Date.today().addDays(3));
        insert opp;
        FormattedPhoneOppController Tes = new FormattedPhoneOppController(new ApexPages.StandardController(opp));


    }
}