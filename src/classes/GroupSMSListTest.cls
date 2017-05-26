@isTest
public class GroupSMSListTest {
    public static testMethod void test() {
        GroupSMSListController smsList = new GroupSMSListController(true);
        smsList.getGroupSMSList();
        smsList.previous();
        smsList.next();
        smsList.newGroupSMS();
    }
}