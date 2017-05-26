@isTest (SeeAllData=true)
public class webscheduler_controller_test{
 
    static testMethod void testtimegenerator() {
    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    String currentProfileId = ((String) (pr.Id)).substring(0, 15);
	/*	
		upsert new SRP_Profiles_List__c(
  		  Name = 'Standard User',
   		  ProfileId__c = currentProfileId
		);
		*/
    
    User u = new User();
    u.alias = 'thisUser';
    u.email='thisuser@test.com';
    u.emailencodingkey='UTF-8';
    u.lastname = 'Calderon';
    u.firstname = 'Tester';
    u.languagelocalekey = 'en_US';
    u.localesidkey='en_US'; 
    u.profileid = pr.Id;
    u.timezonesidkey='America/New_York';
    u.username='thisuser@test.com';
    u.Admissions_Extension__c = '0777';     
    
    insert u;
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.firstname = 'Tester';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    
    
    insert upm;
    
    System.runAs(upm){
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

     WebSchedulerInfo__c theCSS = WebSchedulerInfo__c.getValues(a.name);
               if(theCSS == null) {
                    theCSS = new WebSchedulerInfo__c( Name = a.name);
                    theCSS.CSS_Resource__c  = 'sjuwebschedcss';
                    theCSS.EmailTemplateCancel__c = 'SJUEmailCancel';
                    theCSS.EmailTemplateSchedule__c = 'SJUEmailSchedule';
                    theCSS.DefaultEmail__c = 'online@sju.edu';
                    theCSS.return_link_text__c = 'Return to SJU Homepage'; 
                    theCSS.schoolurl__c = 'http://www.sju.edu';//this must be in url format
                    }
                


    

    
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.Employer_Company__c = 'Test Company';
    newcontact.accountid = a.id;
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.Email_from_Student__c = 'teststd@test.com';
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    
    PageReference p = new Pagereference('/apex/WebSchedulerPage?pmid=' + theopp.id);
     Test.setCurrentPage(p);
    
        // create the controller
        webscheduler_controller con = new webscheduler_controller();
        
        Test.startTest(); 
        
        //test creating the email templates
       Datetime d=datetime.now();
       String o = '006W0000002RWG4IAO';
       String thepm='Asha+Calderon';
       String sch='Saint+Joseph%27s+University';
     

        
        //Test out the Monday time periods edt
        /****************************************
        * Test Starting time from Monday 
        * 6am EDT 
        *
        *****************************************/   
        
        
        
        //look for the next monday, start time is 6 am, conversion is for edt +4 hrs
        Datetime testdate = generateDay('Monday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Monday');
        Datetime testdatecheck = testdate.adddays(1);
        Datetime testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
        Datetime aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //create a map of times using the utility class
        Map<datetime,boolean> timemap = WebSchedulerUtils.findTheMapping(4,testdate,testdateend,upm.id);
        System.assertequals(timemap.get(aftertime), false);
        
        //date times for monday after the start
        Datetime monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        Map<datetime,boolean> timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Mondays time period should be from 9am to 8.30 since start time is at 6am
        Map<datetime,boolean> timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        Map<datetime,boolean> timemap3 = WebSchedulerUtils.startFromMonday(timemap2, 4 , testdate);
        
        //9am should show as true
       // System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 9am to 8:30 edt to gmt and verify they are true       
        Datetime eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        Datetime twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        //for(Datetime thetestdate = twohrafterstarttime; thetestdate <= eightthirtypm; thetestdate = thetestdate.addminutes(15)){
        //  for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          Datetime thetestdate2 = twohrafterstarttime.addminutes(15);
            //System.debug('@asha:checking time map after start from Monday : ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate2), true);        
       //}
        
        /****************************************
        * Test Starting time from Monday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next monday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Monday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Monday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //date times for monday after the start at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        system.debug('@sean testDate = '+testdate);
        system.debug('@sean testDateEnd = '+testdateend);
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Mondays time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromMonday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map after start from Monday : ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),14,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map before start time from Monday : ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
        
         /****************************************
        * Test Starting time from Monday 
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next monday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Monday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Monday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //monday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        //Mondays time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromMonday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for next day from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),13,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            //System.debug('@asha:checking time map after start from Monday : ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 4pm to 9am next day edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),12,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map before start time from Monday : ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
        
     
     
             //Test out the Tuesday time periods edt
        /****************************************
        * Test Starting time from Tuesday 
        * 6am EDT 
        *
        *****************************************/   
        
        
        //look for the next Tuesday, start time is 6 am, conversion is for edt +4 hrs
        testdate = generateDay('Tuesday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Tuesday');
        testdatecheck = testdate.adddays(1);
       testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
      
        //9am for Tuesday
        Datetime afterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create map and check times 
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        
        timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Tuesday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
         timemap3 = WebSchedulerUtils.startFromTuesday(timemap2, 4 , testdate);
        //6am should be false
        System.assertequals(timemap2.get(aftertime), false);
        //9am should show as true
        System.assertequals(timemap3.get(afterstarttime), true);
        
        //check all times in 15 time periods from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Tuesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
     
      
      
        /****************************************
        * Test Starting time from Tuesday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Tuesday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Tuesday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Tuesday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //date times for Tuesday after the start at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Tuesday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromTuesday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map after start from Tuesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm( 2hrs after start time 11a ) edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),13,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map before start time from Tuesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
      
         /****************************************
        * Test Starting time from Tuesday
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next Tuesday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Tuesday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Tuesday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //monday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        //Mondays time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromTuesday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for next day from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),13,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
         //   System.debug('@asha:checking time map after start from Tuesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 4pm to 9am next day edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),12,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map before start time from Tuesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }         
      
              //Test out the  Wednesday time periods edt
        /****************************************
        * Test Starting time from Wednesday
        * 6am EDT 
        *
        *****************************************/   
        
        
        //look for the next Wednesday start time is 6 am, conversion is for edt +4 hrs
        testdate = generateDay('Wednesday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Wednesday');
        testdatecheck = testdate.adddays(1);
       testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
      
        //9am for Wednesday
        afterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create map and check times 
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        
        //Wednesday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
         timemap3 = WebSchedulerUtils.startFromWednesday(timemap2, 4 , testdate);
        //6am should be false
        System.assertequals(timemap2.get(aftertime), false);
        //9am should show as true
        System.assertequals(timemap3.get(afterstarttime), true);
        
        //check all times in 15 time periods from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
         //   System.debug('@asha:checking time map after start from Wednesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
     
      
      
        /****************************************
        * Test Starting time from Wednesday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Wednesday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Wednesday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Wednesday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //date times for Wednesday after the start at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
         timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Wednesday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromWednesday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
         //   System.debug('@asha:checking time map after start from Wednesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm( 2hrs after start time 11a ) edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),13,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
         //   System.debug('@asha:checking time map before start time from Wednesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
      
         /****************************************
        * Test Starting time from Wednesday
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next Wednesday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Wednesday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Wednesday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //monday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        //Mondays time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromWednesday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for next day from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),13,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map after start from Wednesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 4pm to 9am next day edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),12,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map before start time from Wednesday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        } 
      
      
      
         //Test out the  Thursday time periods edt
        /****************************************
        * Test Starting time from Thursday
        * 6am EDT 
        *
        *****************************************/   
        
        
        //look for the next Thursday start time is 6 am, conversion is for edt +4 hrs
        testdate = generateDay('Thursday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Thursday');
        testdatecheck = testdate.adddays(1);
       testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
      
        //9am for Thursday
        afterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create list of four dates
        List<datetime> thelist = con.determineDaysDisplayed(testdate, 4);
        System.assert(thelist.size() == 4,'@asha: Error, the dates given do not equate to four days out');  
        thelist.sort();
        System.assertequals(thelist[0].date(),testdate.date());
        //verify that sunday does not appear
        for(datetime thisdt: thelist){
        System.assertnotequals(thisdt.format('EEEEE'),'Sunday');
        
        }
          
        //create map and check times 
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        
        //Thursday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
         timemap3 = WebSchedulerUtils.startFromThursday(timemap2, 4 , testdate);
        //6am should be false
        System.assertequals(timemap2.get(aftertime), false);
        //9am should show as true
        System.assertequals(timemap3.get(afterstarttime), true);
        
        //check all times in 15 time periods from 9am to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map after start from Thursday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
     
      
      
        /****************************************
        * Test Starting time from Thursday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Thursday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Thursday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Thursday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //date times for Thursday after the start at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Thursday time period should be from 9am to 8.30 since start time is at 6am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromThursday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm to 8:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            //System.debug('@asha:checking time map after start from Thursday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm( 2hrs after start time 11a ) edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),13,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map before start time from Thursday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
      
         /****************************************
        * Test Starting time from Thursday
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next Thursday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Thursday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Thursday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 4.30pm thursday
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //thursday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        
         timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Thurs time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromThursday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for next day from 9am to 4:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),20,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),14,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Thursday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 4pm to 9am next day edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),12,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map before start time from Thursday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        } 
      
      
      
        //Test out the  Friday time periods edt
        /****************************************
        * Test Starting time from Friday
        * 6am EDT 
        *
        *****************************************/   
        
        
        //look for the next Friday start time is 6 am, conversion is for edt +4 hrs
        testdate = generateDay('Friday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Friday');
        testdatecheck = testdate.adddays(1);
       testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 4.30pm friday
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
      
        //9am for Friday
        afterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create map and check times 
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        
         timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Friday time period should be from 9am to 4.30 since start time is at 6am
        timemap3.clear();
         timemap3 = WebSchedulerUtils.startFromFriday(timemap2, 4 , testdate);
        //6am should be false
        System.assertequals(timemap2.get(aftertime), false);
        //9am should show as true
        System.assertequals(timemap3.get(afterstarttime), true);
        
        //check all times in 15 time periods from 9am to 4:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Friday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
     
      
      
        /****************************************
        * Test Starting time from Friday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Friday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Friday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Friday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //create list of four dates
        thelist.clear();
        thelist = con.determineDaysDisplayed(testdate, 4);
        System.assert(thelist.size() == 4,'@asha: Error, the dates given do not equate to four days out');  
        thelist.sort();
        System.assertequals(thelist[0].date(),testdate.date());
        //verify that sunday does not appear
        for(datetime thisdt: thelist){
        System.assertnotequals(thisdt.format('EEEEE'),'Sunday');
        
        }
        
        //6 am (6 +4hrs) the next day should not be true since start times are from 9am to 4.30pm friday
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //Friday at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Friday time period should be from start time to 4.30 since start time is at 11am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromFriday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm (2hrs after 11a) to 4:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Friday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm( 2hrs after start time 11a ) edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),13,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map before start time from Friday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
    //verify that 5pm edt is false
    datetime fivepm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),21,0,0);
    System.assertequals(timemap3.get(fivepm), false);  

      
         /****************************************
        * Test Starting time from Friday
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next Friday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Friday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Friday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //9 am (6 +4hrs) the next day should not be true since start times are from 10a to 3.30p sat
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 12 ,0,0);
        
        //Friday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        //Friday time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromFriday(timemap2, 4 , testdate);
        
        //9am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for next day from 10am to 3:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),19,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),14,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map after start from Friday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 4.30pm to 10am next day edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,30,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),13,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map before start time from Friday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
         //Test out the  Saturday time periods edt
        /****************************************
        * Test Starting time from Saturday
        * 6am EDT 
        *
        *****************************************/   
        
        
        //look for the next Saturday start time is 6 am, conversion is for edt +4 hrs
        testdate = generateDay('Saturday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Saturday');
        testdatecheck = testdate.adddays(1);
       testdateend = testdate.adddays(5);
        
        //six am (6 +4hrs) the next day should not be true since Sunday is all
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
      
        //9am for Saturday - changed to work with dst
        afterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 12 ,0,0);
          
        //create map and check times 
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        
        //Saturday time period should be from 10am to 3.30p 
        timemap3.clear();
         timemap3 = WebSchedulerUtils.startFromSaturday(timemap2, 4 , testdate);
        //6am should be false
        System.assertequals(timemap2.get(aftertime), false);
        //9am should show as false
        System.assertequals(timemap3.get(afterstarttime), false);
        
        //check all times in 15 time periods from 10am to 3:30p edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 19 ,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Saturday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
     
      
      
        /****************************************
        * Test Starting time from Saturday 
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Saturday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Saturday', 11,4);
        System.assertequals(testdate.format('EEEEE'),'Saturday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //6 am (6 +4hrs) the next day should not be true since Sunday is skipped
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        //Saturday at 2pm edt or 6pm gmt
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 18 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Saturday time period should be from start time to 3.30 since start time is at 11am
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromSaturday(timemap2, 4 , testdate);
        
        //6am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //2pm should show as true
        System.assertequals(timemap3.get(monafterstarttime), true);
        
        //check all times in 15 time periods from 1pm (2hrs after 11a) to 3:30 edt to gmt and verify they are true       
        eightthirtypm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),19,30,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),17,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map after start from Saturday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }
        
         //check times in 15 time periods from 9am to 1pm( 2hrs after start time 11a ) edt to gmt and verify they are false     
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),13,0,0);
        eightthirtypm  = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16,59,59);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
          //  System.debug('@asha:checking time map before start time from Saturday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }       
      
      
    //verify that 4pm edt is false
    datetime fourpm = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),20,0,0);
    System.assertequals(timemap3.get(fourpm), false);  

      
         /****************************************
        * Test Starting time from Saturday
        * 5pm EDT 
        *
        *****************************************/   
        
        //look for the next Saturday, start time is 5 pm, conversion is for edt +4 hrs
        testdate = generateDay('Saturday', 17, 4);
        System.assertequals(testdate.format('EEEEE'),'Saturday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
        //create list of four dates
        thelist.clear();
        thelist = con.determineDaysDisplayed(testdate, 4);
        System.assert(thelist.size() == 4,'@asha: Error, the dates given do not equate to four days out');  
        thelist.sort();
        //since the start time is from saturday after 5pm it should skip to monday as the start date
        datetime testsatafterfive = testdate.adddays(2);
        System.assertequals(thelist[0].date(),testsatafterfive.date());
        //verify that sunday does not appear
        for(datetime thisdt: thelist){
        System.assertnotequals(thisdt.format('EEEEE'),'Sunday');
        
        }
        
        //9 am (6 +4hrs) the next day should be false since sun is skipped
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 14 ,0,0);
        
        //Saturday should all be false if start time is after 4p
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), false);
        
        timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Saturday time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromSaturday(timemap2, 4 , testdate);
        
        //9am should show as false
        System.assertequals(timemap3.get(aftertime), false);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods for sunday and verify they are false
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),2,0,0);
        twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),0,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            //System.debug('@asha:checking time map after start from Saturday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }
        
         //check times in 15 time periods for monday (9am to 8.30pm) and verify they are true    
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(3).year(),testdate.adddays(3).month(), testdate.adddays(3).day(),0,30,0);
         twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),14,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
            //System.debug('@asha:checking time map before start time from Saturday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }        
      
      /************************
      * test one of the times from just after midnight
      *  Mon 0am 
      *
      ************************/
      
      testdate = generateDay('Monday',0,5);
      System.assertequals(testdate.format('EEEEE'),'Monday');
      
        //create list of four dates
        thelist.clear();
        thelist = con.determineDaysDisplayed(testdate, 4);
        System.assert(thelist.size() == 4,'@asha: Error, the dates given do not equate to four days out');  
        thelist.sort();
        //dates should still start from monday since before 1.30am 
        //method adds 10 hrs to the time to verify that date remains the same
        
        System.assertequals(thelist[0].date(),testdate.date());
        //verify that sunday does not appear
        for(datetime thisdt: thelist){
        System.assertnotequals(thisdt.format('EEEEE'),'Sunday');
        
        }
        
         
         /****************************************
        * Test Starting time from Sunday
        * 11am EDT 
        *
        *****************************************/   
        
        //look for the next Sunday, start time is 11 am, conversion is for edt +4 hrs
        testdate = generateDay('Sunday', 11, 4);
        System.assertequals(testdate.format('EEEEE'),'Sunday');
        testdatecheck = testdate.adddays(1);
        testdateend = testdate.adddays(5);
        
                //create list of four dates
        thelist.clear();
        thelist = con.determineDaysDisplayed(testdate, 4);
        System.assert(thelist.size() == 4,'@asha: Error, the dates given do not equate to four days out');  
        thelist.sort();
        //the first day should not equal sunday
        System.assertnotequals(thelist[0].date(),testdate.date());

        
        //9 am (6 +4hrs) the next day should be true 
         aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 14 ,0,0);
        
        //Sunday should all be false 
        monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 20 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        timemap2.clear();
        timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        

        
                 timemap4.clear();
         timemap4 = con.findTheDayToStartFrom(timemap2,testdate);
        System.assert(timemap4.size() > 0, '@asha: webscheduler test - timemap size not as expected');
        
        //Sunday time period should be all false since starting after 4pm
        timemap3.clear();
        timemap3 = WebSchedulerUtils.startFromSunday(timemap2, 4 , testdate);
        
        //9am should show as false
        System.assertequals(timemap3.get(aftertime), true);
         //4pm should show as false
        System.assertequals(timemap3.get(monafterstarttime), false);
        
        //check all times in 15 time periods created for sunday and verify they are false
        twohrafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),14,0,0);
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),1,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map after start from Sunday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), false);        
        }
        
         //check times in 15 time periods for monday (9am to 8.30pm) and verify they are true    
        eightthirtypm = datetime.newInstanceGMT(testdate.adddays(2).year(),testdate.adddays(2).month(), testdate.adddays(2).day(),0,30,0);
         twohrafterstarttime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),14,0,0);
          

        for(Datetime thetestdate = twohrafterstarttime; thetestdate <= twohrafterstarttime.addhours(1); thetestdate = thetestdate.addminutes(15)){
           // System.debug('@asha:checking time map before start time from Sunday: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate), true);        
        }        
        
        //test the creating of the display times by date
        Map<datetime,list<string>> thistestmap = con.settheorder(timemap3, thelist);
        list<string> listofdisplaytimes = thistestmap.get(thelist[0]);
        System.assert(listofdisplaytimes.size() > 0, '@asha: map of times to display size is not as expected'); 
        
    //test datetimechosen method    
    //set the display variables and verify that the chosen time corresponds with the expected date
    con.firstdaydisplay =  eightthirtypm.format('MMMM d, yyyy');
    con.firstdaydisplayA = eightthirtypm.format('EEEEE').toUpperCase();
    con.firstdtdisplay = eightthirtypm;
    con.inTime = eightthirtypm.format('h:mm a');
    String displayconfirmation = eightthirtypm.format('EEEEE').toUpperCase() +', '+ eightthirtypm.format('MMMM d, yyyy') + ' @ '+ eightthirtypm.format('h:mm a');

con.datetimechosen();
//test that the displayed date and time corresponse with the chosen one
System.assertequals(con.beforeconfirm, displayconfirmation);
System.assertequals(eightthirtypm,con.newdatetime);
 
 
     //test datetimechosen2 method    
    //set the display variables and verify that the chosen time corresponds with the expected date
    con.seconddaydisplay =  eightthirtypm.format('MMMM d, yyyy');
    con.seconddaydisplayA = eightthirtypm.format('EEEEE').toUpperCase();
    con.seconddtdisplay = eightthirtypm;
    con.inTime2 = eightthirtypm.format('h:mm a');
     con.datetimechosen2();
    //test that the displayed date and time corresponse with the chosen one
        System.assertequals(con.beforeconfirm, displayconfirmation);
        System.assertequals(eightthirtypm,con.newdatetime);
     
     //test datetimechosen3 method
    con.thirddaydisplay =  eightthirtypm.format('MMMM d, yyyy');
    con.thirddaydisplayA = eightthirtypm.format('EEEEE').toUpperCase();
    con.thirddtdisplay = eightthirtypm;
    con.inTime3 = eightthirtypm.format('h:mm a');
     con.datetimechosen3();
    //test that the displayed date and time corresponse with the chosen one
    System.assertequals(con.beforeconfirm, displayconfirmation);
    System.assertequals(eightthirtypm,con.newdatetime);
    
    //test datetimechosen4 method
         //set the variables
    con.fourthdaydisplay =  eightthirtypm.format('MMMM d, yyyy');
    con.fourthdaydisplayA = eightthirtypm.format('EEEEE').toUpperCase();
    con.fourthdtdisplay = eightthirtypm;
    con.inTime4 = eightthirtypm.format('h:mm a');
    //call the method
     con.datetimechosen4();
    //test that the displayed date and time corresponse with the chosen one
    System.assertequals(con.beforeconfirm, displayconfirmation);
    System.assertequals(eightthirtypm,con.newdatetime);
   
        Test.stopTest();
    }
    }
    
  static testMethod void testusecases() {
    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    User u = new User();
    u.alias = 'thisUser';
    u.email='thisuser@test.com';
    u.emailencodingkey='UTF-8';
    u.lastname = 'Calderon';
    u.languagelocalekey = 'en_US';
    u.localesidkey='en_US'; 
    u.profileid = pr.Id;
    u.timezonesidkey='America/New_York';
    u.username='thisuser@test.com';
    u.Admissions_Extension__c = '0777';    
    
    insert u;
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    upm.Admissions_Email__c = 'thisuserpm@test.com';
    
    insert upm;
    
    System.runAs(upm){
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

     WebSchedulerInfo__c theCSS = WebSchedulerInfo__c.getValues(a.name);
               if(theCSS == null) {
                    theCSS = new WebSchedulerInfo__c( Name = a.name);
                    theCSS.CSS_Resource__c  = 'sjuwebschedcss';
                    theCSS.EmailTemplateCancel__c = 'SJUEmailCancel';
                    theCSS.EmailTemplateSchedule__c = 'SJUEmailSchedule';  
                    theCSS.DefaultEmail__c = 'online@sju.edu'; 
                    theCSS.return_link_text__c = 'Return to SJU Homepage'; 
                    theCSS.schoolurl__c = 'http://www.sju.edu';//this must be in url format
                }
                


    

    
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.accountid = a.id;
    newcontact.Employer_Company__c = 'Test Company';
    newcontact.Email = 'teststd@test.com'; 
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    //by setting the webschedulerstatus__c to New this test the New web scheduler feature
        
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.webschedulerstatus__c = 'New';
    theopp.Email_from_Student__c = 'teststd@test.com';
    
     
     
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    
    
     
    
    PageReference p = new Pagereference('/apex/WebSchedulerPage?pmid=' + theopp.id);
     Test.setCurrentPage(p);
    
        // create the controller
        webscheduler_controller con = new webscheduler_controller();
        
        Test.startTest(); 
        
        //Test out the Monday time periods edt

        //look for the next monday, start time is 6 am, conversion is for edt +4 hrs
        Datetime testdate = generateDay('Monday', 6, 4);
        System.assertequals(testdate.format('EEEEE'),'Monday');
        Datetime testdatecheck = testdate.adddays(1);
        Datetime testdateend = testdate.adddays(8);
        
        //six am (6 +4hrs) the next day should not be true since start times are from 9am to 8.30pm tues
        Datetime aftertime = datetime.newInstanceGMT(testdatecheck.year(),testdatecheck.month(), testdatecheck.day(), 10 ,0,0);
        
        
        //add an event to the pm calendar
        Datetime testdatenotfree = generateDay('Monday', 14, 4);
        WebSchedulerUtils.addEvent(testdatenotfree ,theopp.id,upm.id);
        
        //create a map of times using the utility class

        Map<datetime,boolean> timemap = WebSchedulerUtils.findTheMapping(4,testdate,testdateend,upm.id);
        System.assertequals(timemap.get(aftertime), false);
        
        //date times for monday after the start
        Datetime monafterstarttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 14 ,0,0);
          
        //create map and check times 
        //1 hour after start time should be false
        Map<datetime,boolean> timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
        System.assertequals(timemap2.get(monafterstarttime), true);
        
        //Mondays time period should be from 9am to 8.30 since start time is at 6am
        Map<datetime,boolean> timemap3 = WebSchedulerUtils.startFromMonday(timemap2, 4 , testdate);
        
        //verify that first page is showing
        System.assertequals(con.chooseanothertime,false);
        System.assertequals(con.newtime,true);        
        
        /*
        //this portion test the dates generated all 9am to 5pm
         List<String> testfirst = con.getfirstList();
         Datetime n = datetime.now();
         if(con.movetonextday){
             n = n.adddays(1);        
         }
         System.assert( testfirst.size() > 0 ,'@asha: test webscheduler first list of times not greater than 0');
         
        //full list of times
        List<SelectOption> opts = con.getDayList();
          System.assert( opts.size() > 0 ,'@asha: test webscheduler drop down list size not as expected');       
        
        List<SelectOption> opt2 = con.getFirstDayList();
        System.assert( opt2.size() > 0 ,'@asha: test webscheduler drop down list size not as expected');    
        
                    
        //choose a time          
         con.inTime = testfirst[0];
         con.firstdatechosen();
         System.assertequals(con.wsStatus , 'Scheduled');
         System.assertequals(con.timehasbeenchosen,true);
         System.assertequals(con.newtime,false);
         System.assertequals(con.displaytime, testfirst[0] + ' ' + 'EST');
         System.assertequals(con.displaydate, n.format('EEEEE, MM/dd/yyyy'));
         
        //download the ics file
        PageReference pg = con.icsfile();
        PageReference pgtest = new PageReference('/apex/WebAppt?dt='+con.dtstart+'&pm='+con.pmname+'&pme='+con.pmemail+'&dte='+con.dtimeend);
        System.assertequals(pg.getURL(),pgtest.getURL());


        
        //cancel time
        con.cancelAppointment();
        System.assertequals(con.wsStatus,'Canceled');
        System.assertequals(con.chooseanothertime,true);
        System.assertequals(con.newtime,false);
        
        
        //reschedule time
        con.chooseANewTime();
        System.assertequals(con.newtime,true);
        
        n = n.adddays(1);
        
        List<String> testsec = con.getsecondList();
        System.assert( testsec.size() > 0 ,'@asha: test webscheduler second list of times not greater than 0');
        con.inTime = testsec[0];
        con.seconddatechosen();
         System.assertequals(con.wsStatus , 'Rescheduled');
         System.assertequals(con.timehasbeenchosen,true);
         System.assertequals(con.newtime,false);
         System.assertequals(con.displaytime, testsec[0] + ' ' + 'EST');
         System.assertequals(con.displaydate, n.format('EEEEE, MM/dd/yyyy'));
        */
           Test.stopTest();
    }
    }     
          
       static testMethod void testtimegenerator2() {
    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    User u = new User();
    u.alias = 'thisUser';
    u.email='thisuser@test.com';
    u.emailencodingkey='UTF-8';
    u.lastname = 'Calderon';
    u.languagelocalekey = 'en_US';
    u.localesidkey='en_US'; 
    u.profileid = pr.Id;
    u.timezonesidkey='America/New_York';
    u.username='thisuser@test.com';
    u.Admissions_Extension__c = '0777';    
    
    insert u;
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    
    
    insert upm;
    
    System.runAs(upm){
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

     WebSchedulerInfo__c theCSS = WebSchedulerInfo__c.getValues(a.name);
               if(theCSS == null) {
                    theCSS = new WebSchedulerInfo__c( Name = a.name);
                    theCSS.CSS_Resource__c  = 'sjuwebschedcss';
                    theCSS.EmailTemplateCancel__c = 'SJUEmailCancel';
                    theCSS.EmailTemplateSchedule__c = 'SJUEmailSchedule';   
                    theCSS.DefaultEmail__c = 'online@sju.edu'; 
                     theCSS.return_link_text__c = 'Return to SJU Homepage'; 
                    theCSS.schoolurl__c = 'http://www.sju.edu';//this must be in url format          
                }
                


    

    
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.Employer_Company__c = 'Test Company';
    newcontact.accountid = a.id;
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    //by setting the w
    
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.Email_from_Student__c = 'teststd@test.com';
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    
    PageReference p = new Pagereference('/apex/WebSchedulerPage?pmid=' + theopp.id);
     Test.setCurrentPage(p);
    
        // create the controller
        webscheduler_controller con = new webscheduler_controller();
        
        Test.startTest(); 
        
        

        
        //test rounding times to fifteen
        //0-14 round down to 0
        //15 - 29 round down to 15
        //30-44 round down to 30
        //45-59 round down to 45
        Datetime testdt = datetime.newInstance(2012,7,27,5,12,0);
        Datetime expecteddt = datetime.newInstanceGMT(2012,7,27,5,0,0);
        Datetime actualdt = con.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);
        
        actualdt = WebSchedulerUtils.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);
        
        testdt = datetime.newInstance(2012,7,27,5,20,0);
        expecteddt = datetime.newInstanceGMT(2012,7,27,5,15,0);
        actualdt = con.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);        
        
        actualdt = WebSchedulerUtils.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);        
        
        
        testdt = datetime.newInstance(2012,7,27,5,41,0);
        expecteddt = datetime.newInstanceGMT(2012,7,27,5,30,0);
        actualdt = con.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);
         
        actualdt = WebSchedulerUtils.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);
               
        testdt = datetime.newInstance(2012,7,27,5,55,0);
        expecteddt = datetime.newInstanceGMT(2012,7,27,5,45,0);
        actualdt = con.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);
                 
        actualdt = WebSchedulerUtils.roundtofifteen(testdt);
        System.assertequals(expecteddt,actualdt);       
        
        
        
        

        /****************************************
        * Test Starting time from NOW()
        * 
        *
        *****************************************/   
        
 /*       
        //pull the current time from the controller
        Datetime testdate = con.currenttime;

    //pull the time zone conversion from the controller
    Integer tz = con.convertTZ;
   
    //end time for the time map
        Datetime testdateend = testdate.adddays(5);
        
    //time limitations
    Integer i = (20 + tz) - 24;
    Time t7a = Time.newInstance(7 + tz, 0, 0, 0);
    Time t4p = Time.newInstance(16 + tz, 30, 0, 0);
    Time t8a = Time.newInstance(8 + tz, 00, 0, 0);
    Time t2p = Time.newInstance(14 + tz,30,0,0);
    Time t1p = time.newInstance(13 + tz,30,0,0);

        Datetime endtime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),i,30,0);
        Datetime starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), 9+tz ,0,0); 
    Boolean b = true;


    //day of the week for start ie Monday, Tuesday, etc
    String dayofwk = testdate.formatGMT('EEEEE');
    
    //determine the times to check in the map
    String debugstr = 'before 9am';


    if( dayofwk == 'Monday' || dayofwk == 'Tuesday' || dayofwk == 'Wednesday' || dayofwk == 'Thursday'){
        if(testdate.timeGMT() < t7a){
            //do nothing to start and end time
        }
        if(testdate.timeGMT() >= t7a && testdate.timeGMT() < t4p ){
            //start time is from current time + 2 hrs , start the begining of the next hour because needs to be rounded to 15 mins periods
            debugstr = 'btw 9a and 8.30p';
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), testdate.addhours(3).hourGMT() ,0,0); 
    
        }

        if(testdate.timeGMT() >= t4p){
          //check that the entire day until 9am next day is false   
            b = false;
            endtime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),testdate.addhours(1).hour(),0,0);
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),testdate.hourGMT() ,0,0); 
            debugstr = 'after 4p';
        }
    }
    else{ 
     if( dayofwk == 'Friday'){
        if(testdate.timeGMT() < t7a){
            // friday end time is for 4.30p
                endtime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16 +tz,30,0);
                debugstr = 'btw 9a and 4.30p';
        }
        if(testdate.timeGMT() >= t7a && testdate.timeGMT() < t2p ){
            //start time is from current time + 2 hrs , start the begining of the next hour because needs to be rounded to 15 mins periods
            debugstr = 'btw 9a and 4p';
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), testdate.addhours(3).hourGMT() ,0,0); 
            endtime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),16 +tz,30,0);
    
        }

        if(testdate.timeGMT() >= t2p){
          //check that the entire day until 9am next day is false   
            b = false;
            debugstr = 'after 2.30p';
            endtime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),8+ tz,59,59);
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),testdate.hourGMT() ,0,0); 

        }
    }else{

    if( dayofwk == 'Saturday'){
        if(testdate.timeGMT() < t8a){
            // saturday end time is for 3.30p
                endtime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),15 +tz,30,0);
        }
        if(testdate.timeGMT() >= t8a && testdate.timeGMT() < t1p ){
            //start time is from current time + 2 hrs , start the begining of the next hour because needs to be rounded to 15 mins periods
         
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(), testdate.addhours(3).hourGMT() ,0,0); 
            endtime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),15 +tz,30,0);
    
        }

        if(testdate.timeGMT() >= t1p){
          //check that the entire day until 9am next day is false   
            b = false;
            endtime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),8,59,59);
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),testdate.hourGMT() ,0,0); 

        }
    }
    
    
    if( dayofwk == 'Sunday'){

          //check that the entire day until 9am next day is false   
            b = false;
            endtime = datetime.newInstanceGMT(testdate.adddays(1).year(),testdate.adddays(1).month(), testdate.adddays(1).day(),8,59,59);
            starttime = datetime.newInstanceGMT(testdate.year(),testdate.month(), testdate.day(),testdate.hourGMT() ,0,0); 

        
    }

    }
   }



        //create map and check times 
    Map<datetime,boolean> timemap2 = WebSchedulerUtils.findTheMap(testdate,testdateend,upm.id);
    Map<datetime,boolean> timemap3 = con.findTheDayToStartFrom(timemap2,testdate);

        System.debug('@asha:checking time map for current times starting from: ' +  testdate.format('EEE MM.dd.yyyy h:mm a z'));         

        for(Datetime thetestdate = starttime; thetestdate < endtime; thetestdate = thetestdate.addminutes(15)){
            System.debug('@asha:checking time map for current times: ' +  thetestdate.format('MM.dd.yyyy h:mm a z'));
            System.assertequals(timemap3.get(thetestdate),b);        
        }

        //test error message page        
        con.pgerr('Error test');
        System.assertequals(con.errorsection,true);  
 */
        
        
        
        
        
               Test.stopTest();
    }
    } 
        
    static testMethod void testusecases2() {
    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    User u = new User();
    u.alias = 'thisUser';
    u.email='thisuser@test.com';
    u.emailencodingkey='UTF-8';
    u.lastname = 'Calderon';
    u.languagelocalekey = 'en_US';
    u.localesidkey='en_US'; 
    u.profileid = pr.Id;
    u.timezonesidkey='America/New_York';
    u.username='thisuser@test.com';
    u.Admissions_Extension__c = '0777';    
    
    insert u;
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    upm.Admissions_Email__c = 'thisuserpm@test.com';
    
    insert upm;
    
    System.runAs(upm){
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

     WebSchedulerInfo__c theCSS = WebSchedulerInfo__c.getValues(a.name);
               if(theCSS == null) {
                    theCSS = new WebSchedulerInfo__c( Name = a.name);
                    theCSS.CSS_Resource__c  = 'sjuwebschedcss';
                    theCSS.EmailTemplateCancel__c = 'SJUEmailCancel';
                    theCSS.EmailTemplateSchedule__c = 'SJUEmailSchedule';
                    theCSS.DefaultEmail__c = 'online@sju.edu';
                    theCSS.return_link_text__c = 'Return to SJU Homepage'; 
                    theCSS.schoolurl__c = 'http://www.sju.edu';//this must be in url format
                }
                


    

    
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.accountid = a.id;
    newcontact.Employer_Company__c = 'Test Company';
    newcontact.Email = 'teststd@test.com'; 
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    //by setting the webschedulerstatus__c to New this test the New web scheduler feature
        
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    
    Datetime theoppdt = generateDay('Monday',14,4);
    theopp.cwschedappt__c = theoppdt;
    theopp.webschedulerstatus__c = 'Scheduled';
    theopp.Email_from_Student__c = 'teststd@test.com';
    
     
     
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    
    //add the event to the pm event calendar
    WebSchedulerUtils.addEvent(theoppdt,theopp.id,upm.id);
    
    PageReference p = new Pagereference('/apex/WebSchedulerPage?pmid=' + theopp.id);
     Test.setCurrentPage(p);
    
        // create the controller
        webscheduler_controller con = new webscheduler_controller();
        
        Test.startTest();         
       
        //verify that scheduled page is showing
        
        String testoptdtstart = theoppdt.formatGMT('yyyyMMdd')+'T'+ theoppdt.formatGMT('HHmmss')+'Z';
        System.assertequals(con.dtstart,testoptdtstart);
        System.assertequals(con.newtime ,false);
        System.assertequals(con.timehasbeenchosen ,true);                
        
       
        //cancel time
       // OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName = 'online@sju.edu' limit 1];
        con.defaultemail = 'online@sju.edu';
        con.cancelAppointment();
        System.assertequals(con.wsStatus,'Canceled');
        System.assertequals(con.chooseanothertime,true);
        System.assertequals(con.newtime,false);
        
        
        //reschedule time
        con.chooseANewTime();
        System.assertequals(con.newtime,true);
        
        Datetime n = datetime.now();
        List<String> testthird = con.getthirdList();
        System.assert( testthird.size() > 0 ,'@asha: test webscheduler third list size not as expected');
        con.inTime = testthird[0];
        con.thirddatechosen();
         System.assertequals(con.wsStatus , 'Rescheduled');
         System.assertequals(con.timehasbeenchosen,true);
         System.assertequals(con.newtime,false);
         System.assertequals(con.displaytime, testthird[0] + ' ' + 'EST');
        
        
         //cancel time
        con.cancelAppointment();
        
         //reschedule time
        con.chooseANewTime();
        System.assertequals(con.newtime,true);
        
        List<String> testfourth = con.getfourthList();
        System.assert( testfourth.size() > 0 ,'@asha: test webscheduler third list size not as expected');
        con.inTime = testfourth[0];
        con.fourthdatechosen();
        System.assertequals(con.displaytime, testfourth[0] + ' ' + 'EST');
        
         //cancel time
        con.cancelAppointment();        
        
        //no thanks test page
        con.nothankspageview();
        System.assertequals(con.someoneelsechosetime, false);
        System.assertequals(con.sorrypage, true);
        
        //not available anymore page view test
        con.notavailableAnymore();    
        System.assertequals(con.someoneelsechosetime, true);
        System.assertequals(con.sorrypage, false);
        
           Test.stopTest();
    }
    

    
    
    
    }     
    
 /*  public static testMethod void testBlob() {
    Profile pr = [SELECT Id FROM profile WHERE name='Standard User'];
    
    User u = new User();
    u.alias = 'thisUser';
    u.email='thisuser@test.com';
    u.emailencodingkey='UTF-8';
    u.lastname = 'Calderon';
    u.languagelocalekey = 'en_US';
    u.localesidkey='en_US'; 
    u.profileid = pr.Id;
    u.timezonesidkey='America/New_York';
    u.username='thisuser@test.com';
    u.Admissions_Extension__c = '0777';    
    
    insert u;
    
    User upm = new User();
    upm.alias = 'UserPM';
    upm.email='thisuserpm@test.com';
    upm.emailencodingkey='UTF-8';
    upm.lastname = 'CalderonPM';
    upm.languagelocalekey = 'en_US';
    upm.localesidkey='en_US'; 
    upm.profileid = pr.Id;
    upm.timezonesidkey='America/New_York';
    upm.username='thisuserpm@test.com';
    upm.Admissions_Extension__c = '0777';
    
    
    insert upm;
    
    System.runAs(upm){
    ID acctid = findAccountRecordType();
   
    
    //insert test objects
    Account a = new Account();
    a.Name = 'Test Account';
    a.recordTypeID = acctid;
    a.Admissions_Phone__c = '888-888-8888';
    insert a; 

     WebSchedulerInfo__c theCSS = WebSchedulerInfo__c.getValues(a.name);
               if(theCSS == null) {
                    theCSS = new WebSchedulerInfo__c( Name = a.name);
                    theCSS.CSS_Resource__c  = 'sjuwebschedcss';
                    theCSS.EmailTemplateCancel__c = 'SJUEmailCancel';
                    theCSS.EmailTemplateSchedule__c = 'SJUEmailSchedule';
                    theCSS.DefaultEmail__c = 'online@sju.edu';
                }
                


    

    
    Contact newcontact = new Contact();
    newcontact.recordtypeid = findContactRecordType();
    newcontact.firstname = 'Jane';
    newcontact.lastname = 'Doe';
    newcontact.accountid = a.id;
    System.assertnotequals(newcontact.recordtypeid, null);
   
    insert newcontact;
    
   Academic_Program__c acadprog = new Academic_Program__c();
   acadprog.name = 'MBA Program';
   acadprog.school__c = a.Id;
   
   insert acadprog;
         
   Academic_Specialization__c s = new Academic_Specialization__c();         
   s.Name = 'Test Specialization';
   s.Academic_Program__c = acadprog.Id;
    
    insert s;
    
    
    Opportunity theopp = new Opportunity();
    theopp.recordtypeid = findOpportunityRecordType();
    System.assertnotequals(theopp.recordtypeid, null);
    theopp.stagename = 'Start';
    theopp.student__c = newcontact.id;
    theopp.Program__c = acadprog.Id; 
    theopp.AccountID = a.Id;
    theopp.OwnerID = upm.id;
    theopp.name = 'Jane Doe';
    theopp.Email_from_Student__c = 'teststd@test.com';
     
    Date t = date.today().adddays(-2);
    theopp.CloseDate = t;
    
    insert theopp;
    
    PageReference p = new Pagereference('/apex/WebSchedulerPage?pmid=' + theopp.id);
     Test.setCurrentPage(p);
    
        // create the controller
        webscheduler_controller con = new webscheduler_controller();
        
        Test.startTest(); 
        
        //test creating the email templates
       Datetime d=datetime.now();
       String o = '006W0000002RWG4IAO';
       String thepm='Asha+Calderon';
       String sch='Saint+Joseph%27s+University';
    


    
        
        Blob theblob = WebSchedulerUtils.pullinEmailText('SJUEmailCancel',o,d,sch,thepm);
        System.assert(theblob != null, '@asha: test Email Blob to String: Blob is null');    
    
    Test.stopTest();
    }
    }*/
    
    
    
    //find the next date that is for the day of the week specified along with the start time and time zone 
    //integer s  must be btw 0 and 24
    //integer c is either 4(edt) or 5(est)
    public static datetime generateDay(String daystart, Integer s ,Integer c){
        //start the test datetime at 6am edt/est of the test run 
        datetime thisdate = datetime.now();
        datetime returndate = thisdate;
        datetime oneweek = thisdate.adddays(7);
        
       for(Datetime d = thisdate; d <= oneweek; d = d.adddays(1)){
            
            if(daystart == d.format('EEEEE')){
                returndate = d;
                System.debug('@asha webscheduler test: found day' + d);
            }    
            
        }
       returndate = datetime.newInstanceGMT(returndate.year(), returndate.month(), returndate.day(), s + c, 0, 0);
        System.debug('@asha webscheduler test: returning date and time of ' + returndate);
        return returndate;
    }
    
     private static ID findAccountRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Account;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Campus/Partner') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }    
    
     private static ID findContactRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Contact;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Deltak Student') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
    
     private static ID findOpportunityRecordType() {
      
        Schema.DescribeSObjectResult describeST = Schema.SObjectType.Opportunity;
        List<Schema.RecordTypeInfo> rtInfos = describeST.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            if(rtInfo.getName() == 'Student Opportunity') {
                
                System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                return rtInfo.getRecordTypeId();
            }
        }
        
        return null;
    }
}