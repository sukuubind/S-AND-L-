/**
 * Created by sukumar.bindra1 on 2/27/2017.
 */

@IsTest
private class FormattedPhoneContactController_Test {
    static testMethod void testBehavior() {

        Contact cont = new Contact(FirstName = 'Test',LastName = 'Test',Phone = '2222222222');
        insert cont;

        FormattedPhoneContactController Tes = new FormattedPhoneContactController(new ApexPages.StandardController(cont));
    }
}