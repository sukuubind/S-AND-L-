@IsTest
public class GetContactsByViewControllerTest {
   public static testMethod void Test() {
       Test.startTest();
       List<Contact> contacts = new List<Contact>();
       for(integer i = 0 ; i < 2100 ; i++){
           contacts.add(new Contact());
       }
       new GetContactsByViewController(new ApexPages.StandardSetController(contacts)); 
       Test.stopTest();
   }
}