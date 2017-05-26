@isTest
private class SE_TriggerTests{

    static testMethod void testValidateChangingStartDate() {
        
        Profile pro = [SELECT Id FROM profile WHERE name='Standard User'];
        
        User u2 = new User(alias = 'newUser', email='newuser@testorg.com',
                    emailencodingkey='UTF-8', lastname='Testing',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = pro.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='newuser11@testorg.com');
        System.runAs(u2) {
            Test.startTest();
            DateTime t=System.now();
            date d = Date.newInstance(t.year(),t.month(),t.day());
             
            Account a = new Account();
            a.Name = 'Test Account';
            insert a;
            
             Account a2 = new Account();
            a2.Name = 'Test Account 2';
            insert a2;
          
            Contact c = new Contact ();
            c.FirstName='Joe';
            c.LastName='Smith';
            c.Phone='2222222222';    
            c.AccountID = a.Id;    
            insert c;
            
            Contact c2 = new Contact ();
            c2.FirstName='Chris';
            c2.LastName='Baker';
            c2.Phone='2222222222';        
            insert c2;
            
            //set up a program and set the opportunity to it
             Academic_Program__c ap = new Academic_Program__c();
             ap.Name = 'Test Program';
             ap.School__c = a.Id;
             insert ap;
             
             //set up a program and set the opportunity to it
             Academic_Program__c ap2 = new Academic_Program__c();
             ap2.Name = 'Test Program 2';
             ap2.School__c = a2.Id;
             insert ap2;
             
             Academic_Start_Date__c startDate = new Academic_Start_Date__c ();
             startDate.Start_Date__c = d;
             startDate.Program__c = ap.Id;
             insert startDate;
            
            date sd = Date.newInstance(t.year(),t.month(),t.day()+1);
            
            Student_Enrollment__c se = new Student_Enrollment__c();
            
            
                se.Program__c = ap.Id;           

                se.Student_Affiliation__c = c.Id;   
                se.Start_Date__c = sd;
                se.Name = 'Test';
                    
            
            try {
                insert se;
            }
            catch (Exception e) {
                System.debug('Expecting the insert to fail because of a bad start date');
            }
            

            
            //now change it back to a valid one
            se.Start_Date__c = d;
            
            insert se;
            
            Student_Enrollment__c [] updated = 
                [SELECT Academic_Start_Date__c 
                FROM Student_Enrollment__c 
                WHERE Id = :se.Id];
            
            
            System.assertEquals(startDate.Id, updated[0].Academic_Start_Date__c);            
            
             
            Test.stopTest();
        }
    }
    
}