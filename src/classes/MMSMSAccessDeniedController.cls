public class MMSMSAccessDeniedController {
    public void initPage() {
        MMUtils.addMessage(ApexPages.Severity.ERROR, 'You do not have permission to access this resource.');
    }
}