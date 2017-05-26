@IsTest
public class MMSMSUIPermissionTest {
    public static testMethod void Test() {
      Test.startTest();
      
      MMSMSUIPermission.isDirectorAdmissions(null);
      MMSMSUIPermission.isDirectorAdmissionsPTemplate(null);
      MMSMSUIPermission.isSystemAdministrator(null);
      
      Test.stopTest();
   }
}