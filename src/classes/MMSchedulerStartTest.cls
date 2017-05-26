@IsTest
public class MMSchedulerStartTest {
    public static testMethod void Test() {    
        Test.startTest();
        
        MMSchedulerStart schStart = new MMSchedulerStart();
        System.assertEquals(true, schStart.getMmResponse() == '');
        
        PageReference pageRef = Page.mmschedulerstart;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('optype','schstart');
        schStart.autoRun();
       
        pageRef.getParameters().put('optype','resetimsch');
        schStart.autoRun();
        
        Test.stopTest();
    }
}