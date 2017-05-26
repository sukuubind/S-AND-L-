@IsTest
private class Test_FormattedPhoneOppController {

    static testMethod void testBehavior() {


        Opportunity opp = new Opportunity(Name = 'Test',StageName ='New Inquiry',CloseDate = Date.today().addDays(3));
        insert opp;


       FormattedPhoneOppController Tes = new FormattedPhoneOppController(new ApexPages.StandardController(opp));

    }

  }