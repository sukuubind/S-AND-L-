@IsTest
public class GetOpportunitiesByViewControllerTest {
   public static testMethod void Test() {
       Test.startTest();
       List<Opportunity> ops = new List<Opportunity>();
       for(integer i = 0 ; i < 2100 ; i++){
           ops.add(new Opportunity());
       }
       new GetOpportunitiesByViewController(new ApexPages.StandardSetController(ops)); 
       Test.stopTest();
   }
}