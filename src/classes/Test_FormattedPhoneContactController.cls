/**
 * Created by sukumar.bindra1 on 2/22/2017.
 */

@IsTest
private class Test_FormattedPhoneContactController {
    static testMethod void testBehavior() {

        Contact cont = new Contact(LastName = 'Test',FirstName = 'Test',Phone = '2222222222');
        insert cont;

        FormattedPhoneContactController  Tes = new FormattedPhoneContactController (new ApexPages.StandardController(cont));
    }
}