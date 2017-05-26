@IsTest
public class MMGroupsImmediateSchedulerTest {
    public static testMethod void Test() {    
        Test.startTest();
        DateTime now = DateTime.newInstance(2011, 10, 24, 6, 0, 0);
        long rcNum = MMUTils.getReceiptNumber();
        Contact c1 = createAffiliation('test','a');
        Contact c2 = createAffiliation('test','b');
        Contact c3 = createAffiliation('test','c');                
        
        Task t = MMUtils.createTask(c1.Id, 'af', 'schedule test', 'Successfull', false, true);
        insert t;      
        MMSMSReceipt__c rc = MMUtils.createSMSReceipt(c1.Id, 'af', rcNum, true, false, t.Id, null, null, '5_a', false, 'schedule test', now, '03003610420', 'Pakistan');
        insert rc;
        
        MMGroupSMS__c g = new MMGroupSMS__c();
        g.isTrackDelivery__c = false;
        g.Message__c = 'test message';
        g.Multipart__c = false;
        g.SelectedIds__c = c1.Id + '###af,' + c2.Id + '###af,' + c3.Id + '###af';
        g.ids__c = '';
        g.startDate__c = '2011-20-10';
        g.StartTime__c = 4;
        g.TimeZone__c = '5_a';
        g.isScheduled__c = false;
        g.isImmediate__c = true;
        g.schDateTime__c = Datetime.newInstance(2011,10,20,4,0,0);
        insert g;
        
        MMGroupSMSJob__c job = MMUtilSch.insertJob(g.Id, g.SelectedIds__c.split(','),true,1);
        insert job;
    
        MMGroupsImmediateScheduler.sendScheduledSMSNew('',true);
        
        g.isImmediate__c = true;
        update g;
        job.isScheduled__c = true;
        update job;
        
        DateTime dtNow = DateTime.now().addSeconds(1);
        String nextJobHH = String.valueOf(dtNow.hour());
        String nextJobMM = String.valueOf(dtNow.minute());
        String nextJobSS = String.valueOf(dtNow.second()); 
        String nextJobFireTime = nextJobSS + ' ' + nextJobMM + ' 0-23 * * ?';
        System.schedule('MM Job Immediate Started At ' + String.valueOf(Datetime.now()), nextJobFireTime, new MMGroupsImmediateScheduler());
        
        Test.stopTest();
    }
    public static Contact createAffiliation(string fname, string lname) {
       Contact c = new Contact(FirstName = fname, LastName = lname);
       insert c;
       return c;
    }
    public static Opportunity createOpportunity(Id contactId, string name, string stageName, Date closeDate) {
       Opportunity o = new Opportunity(Student__c = contactId, ownerId = UserInfo.getUserId(),
                                   Name = name, StageName = stageName, CloseDate = closeDate);
       insert o;
       return o;
    }
}