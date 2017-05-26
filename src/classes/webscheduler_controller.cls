public class webscheduler_controller{

//variables

ID pmid ;

//date variables
datetime fromhere = datetime.now().addhours(2);
datetime threedays = fromhere.addDays(7);
datetime endtime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),23,59,59);
datetime starttime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),13,0,0);
datetime nextdaystart = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),0,0,0);
datetime nextdayend = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),0,30,0);

 //output the first day in text format
 public String dayone {get; set;}
 public Boolean biglist1 {get;set;}
 public Boolean notimes1 {get;set;}
 public List<String> dayoneparttwo {get;set;}
 
  //output the sec day in text format
 public String daytwo {get; set;}
 //set whether there are a lot of datestimes
 public Boolean biglist2 {get;set;}
 public Boolean notimes2 {get;set;}
 public List<String> daytwoparttwo {get;set;}
 
 
 //output the third day in text format
 public String daythree {get; set;}
 //set whether there are a lot of datestimes
 public Boolean biglist3 {get;set;}
 public Boolean notimes3 {get;set;}
 public List<String> daythreeparttwo {get;set;}
 
 //output the sec day in text format
 public String dayfour {get; set;}
 //set whether there are a lot of datestimes
 public Boolean biglist4 {get;set;}
 public Boolean notimes4 {get;set;}
 public List<String> dayfourparttwo {get;set;}
 

 
 
 //input of time for chosing time
  public String inTime {get;set;}
    public String inTime2 {get;set;}
      public String inTime3 {get;set;}
        public String inTime4 {get;set;}
//booleans for if no times available for day

public Boolean empty1 {get;set;} 
public Boolean empty2 {get;set;}
public Boolean empty3 {get;set;}
public Boolean empty4 {get;set;}       


private ID oppown;
private ID oppid;
private ID eventid;
private Opportunity opp;
public String oppfname {get;set;}
public String opplname {get;set;}
public datetime oppwsappt {get;set;}
public String googlecal {get;set;}
public String schoolphone {get;set;}

//page view 
public Boolean runningtest = false;
public Boolean errorsection {get;set;}
public String csspage {get;set;}

public datetime chosentime {get;set;}
public String pgmsg {get;set;}
public String wsStatus {get;set;}
public String pmname {get;set;}
public String pmphone {get;set;}
public String pmemail {get;set;}
private String stdemail1;
private String stdemail2;
private String stdemail3;
private String rectypeEvent;
public String program {get;Set;}
public Boolean movetonextday;

//page section changes 
public Boolean newtime {get;set;}
public Boolean someoneelsechosetime {get;set;}
public Boolean timehasbeenchosen {get;set;}
public Boolean chooseanothertime {get;set;}
public Boolean sorrypage {get;set;}
public Boolean nonepage {get;set;}
public Boolean notime{get;set;}

//time delineator variables
Time startofday = starttime.timeGMT();
Time endofday = endtime.timeGMT();
Time startnextday = nextdaystart.timeGMT();
Time endnextday = nextdayend.timeGMT();

public List <String> firstlistoftimes {get;set;}
public List <String> seclistoftimes {get;set;}
public List <String> thirdlistoftimes {get;set;}
public List <String> fourthlistoftimes {get;set;}
Map<date, List <datetime>> mapoftimesbydate = new Map<date, List <datetime>>();

public List <String> testfirsttimes {get;set;}


Map<datetime, List <String>> datetotimemap = new Map<datetime, List <String>>();

public String firstdaydisplayA {get;set;}
public String seconddaydisplayA {get;set;}
public String thirddaydisplayA {get;set;}
public String fourthdaydisplayA {get;set;}

public String schoolname {get;set;}

public String firstdaydisplay {get;set;}
public String seconddaydisplay {get;set;}
public String thirddaydisplay {get;set;}
public String fourthdaydisplay {get;set;}

public List<datetime> listdates;

public datetime firstdtdisplay {get;set;}
public datetime seconddtdisplay {get;set;}
public datetime thirddtdisplay {get;set;}
public datetime fourthdtdisplay {get;set;}

public List <String> firsttimes {get;set;}
public List <String> secondtimes {get;set;}
public List <String> thirdtimes {get;set;}
public List <String> fourthtimes {get;set;}

public string profileImageUrl    { get; set; }

public String emailtemplate1;
public String emailtemplate2;
public String defaultemail;
public String homepage {get;set;}
public String returntext{get;set;}

//Map of times
Map<datetime,boolean> temptimemap = new Map<datetime,boolean>();
Map<datetime,boolean> newmapping = new Map<datetime,boolean>();

public Integer convertTZ;
public datetime currenttime;

//add to calendar functionality
 public String dtstart {get; set;}
  public String dtimeend  {get; set;}

public webscheduler_controller(){
    //pull in parameters and find the associated opportunity
    pmid = ApexPages.currentPage().getParameters().get('pmid');
    Opportunity opp = WebSchedulerUtils.sendOpportunityData(pmid);
    
    convertTZ = convertFromGMT();
    
    if(opp !=null){
        oppown = opp.Ownerid;
        pmname = opp.owner.name;
        pmemail = opp.owner.Admissions_Email__c;
        schoolphone = opp.account.Admissions_Phone__c;
        pmphone = opp.account.Admissions_Phone__c + ' x'+ opp.owner.Admissions_Extension__c;
        stdemail1 = opp.Email__c;
        stdemail2 = opp.Email_from_Student__c;
        stdemail3 = opp.WebScheduler_Email__c;
        chosentime = opp.cwschedappt__c;
        oppfname = opp.Student_First_Name__c;
        opplname = opp.Student_Last_Name__c;
        program = opp.Program__r.Program_Title__c;
        wsstatus = opp.webschedulerstatus__c; 
        oppwsappt = opp.cwschedappt__c; 
        oppid = opp.id;
        schoolname = opp.account.name;
    
        profileImageUrl = WebSchedulerUtils.userphoto(oppown);

       }
       
    //record type for event for deltak students
    recTypeEvent = WebSchedulerUtils.findRecTypeID();   
       
    //separate panel to display error message if issue with displaying page
       errorsection = false;
    notime = false;   
    currenttime = datetime.now();
    movetonextday = findFirstDay(currenttime, convertTZ);
   /*     //check the status of the webscheduler status
        //wsStatus = opp.webschedulerstatus__c;
    Datetime afterfourpm = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),20,00,00);  
       
    if(fromhere > afterfourpm && fromhere < endtime){
        afterfourpm = fromhere.addhours(10);
        fromhere = afterfourpm;
        afterfourpm = threedays.addhours(10);
        threedays = afterfourpm;
        movetonextday = true;
    }
   */

     //display times chosen by user set as empty at start
     intime = '';
               intime3 = '';
          intime2 = '';
          intime4 = '';
    //based on status what page to return
    //if in status rescheduled or new then student receives the same page
    if(wsStatus == 'New' ){
        newTime();

     //888888888888888 handles the four day layout with m-th (9a-4:30p) f(9-4:30) sat(10-3:30)8888888888888888888

          intime = '';
          intime3 = '';
          intime2 = '';
          intime4 = '';
          
   Map<datetime,boolean>   firstnewmapping = WebSchedulerUtils.findtheMap(currenttime, threedays, oppown);
        newmapping = findTheDayToStartFrom(firstnewmapping,currenttime);
List<datetime> listdates = determineDaysDisplayed(currenttime, convertTZ );
      empty1 = true;
      empty2 = true;
      empty3 = true;      
      empty4 = true;

List<String> opts = new List<String>();
Set<datetime> newset = newmapping.keyset();
List<datetime> daytemp = new List<datetime>();
if(newset.size() > 0){
Integer i = 0;
daytemp.addAll(newset);
daytemp.sort();
datetime thefirstday = daytemp[0];
              for(datetime d : daytemp){
                if( newmapping.get(d) && i == 0){
                    thefirstday = d;
                     i++;
                }
                //date has to be the same as the first day or btw 0 and 2am of the next day and the time slot needs to be available
                  if( newmapping.get(d) && ( i > 0) ){
                         if( i == 1 && ( d.format('EEEEE') == thefirstday.format('EEEEE'))){
                            opts.add(d.format('h:mm a'));
                         }
                         if( d.format('EEEEE') != thefirstday.format('EEEEE') && i == 1 ){
                            i++;
                         }
                  }
                  
              }
              
      if(opts.size() > 0){
          testfirsttimes = opts;
      }        
}   


datetotimemap = settheorder(newmapping, listdates);
if(!datetotimemap.isEmpty()){
Set<datetime> thedtset = datetotimemap.keyset();
List<datetime> thedtlist = new List<datetime>();
    if(thedtset.size() > 0){
        thedtlist.addAll(thedtset);
        thedtlist.sort();
        if(thedtlist[0] != null){ 
        
         firsttimes = datetotimemap.get(thedtlist[0]);
              if(firsttimes.size() > 0){ empty1 = false; }

         firstdaydisplayA = thedtlist[0].format('EEEEE').toUpperCase();
         firstdaydisplay = thedtlist[0].format('MMMM d, yyyy');
         firstdtdisplay = thedtlist[0];
        }
        if(thedtlist[1] != null){ 
         secondtimes = datetotimemap.get(thedtlist[1]);
              if(secondtimes.size() > 0){ empty2 = false; }

         seconddaydisplayA = thedtlist[1].format('EEEEE').toUpperCase();
         seconddaydisplay = thedtlist[1].format('MMMM d, yyyy');
         seconddtdisplay = thedtlist[1];
        }
        if(thedtlist[2] != null){ 
         thirdtimes = datetotimemap.get(thedtlist[2]);
               if(thirdtimes.size() > 0){empty3 = false; }     
         thirddaydisplayA = thedtlist[2].format('EEEEE').toUpperCase();
         thirddaydisplay = thedtlist[2].format('MMMM d, yyyy');
         thirddtdisplay = thedtlist[2];
        }
        if(thedtlist[3] != null){ 
         fourthtimes = datetotimemap.get(thedtlist[3]);
              if(fourthtimes.size() > 0){ empty4 = false; }
         fourthdaydisplayA = thedtlist[3].format('EEEEE').toUpperCase();
         fourthdaydisplay = thedtlist[3].format('MMMM d, yyyy');
         fourthdtdisplay = thedtlist[3];
        }
        
    }
}
        //888888888888888   handles time for 4 days in m-s (9a-5p)8888888888888888888888888

        Map<datetime,boolean> timemap = WebSchedulerUtils.findTheMapping(convertTZ,fromhere,threedays,oppown);
        if(timemap != null){
        temptimemap = timemap;
        mapoftimesbydate = dayTimeListing(timemap);
        Integer count = 0;
        
        //clear the lists
           dayoneparttwo = new List<String>();
           daytwoparttwo = new List<String>();
           daythreeparttwo = new List<String>();
           dayfourparttwo = new List<String>();  
      
     //set it so that panel is hidden first
      biglist1 = false;
      biglist2 = false;
      biglist3 = false;
      biglist4 = false;
      
      notimes1 = true;
      notimes2 = true;
      notimes3 = true;      
      notimes4 = true;
      
      if(movetonextday){
          dayone = datetime.now().addhours(10).format('EEEEE, MMMM d z');
          daytwo = datetime.now().addhours(10).adddays(1).format('EEEEE, MMMM d z');
          daythree = datetime.now().addhours(10).adddays(2).format('EEEEE, MMMM d z');
          dayfour = datetime.now().addhours(10).adddays(3).format('EEEEE, MMMM d z');
      }
      else{
      //format the date with week day, month and day  (ex. Wed, May 23)
      dayone = datetime.now().format('EEEEE, MMMM d z');
      daytwo = datetime.now().adddays(1).format('EEEEE, MMMM d z');
      daythree = datetime.now().adddays(2).format('EEEEE, MMMM d z');
      dayfour = datetime.now().adddays(3).format('EEEEE, MMMM d z');
       }
      //instantiate the first list of times           
     firstlistoftimes  = new List<String>();
      firstlistoftimes = getfirstList();
      list<String> templist = new list<string>();
   if(firstlistoftimes.size() > 1){
   notimes1 = false;
      if(firstlistoftimes.size() > 4){
          dayoneparttwo.clear();
          biglist1 = true; // more than four dates so unhide panel
          for(String s : firstlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      dayoneparttwo.add(s);
                 }
          } 
          firstlistoftimes.clear();                  
          firstlistoftimes.addAll(templist);    
      }
     }
     
     //instantiate the second date list of times 
        seclistoftimes = new List<String>();
        seclistoftimes = getsecondList();
        templist.clear();
        count = 0;
   if(seclistoftimes.size() > 1){
   notimes2 = false;
     if(seclistoftimes.size() > 4){
          biglist2 = true;
          daytwoparttwo.clear();
          for(String s : seclistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      daytwoparttwo.add(s);
                 }
          } 
          seclistoftimes.clear();                  
          seclistoftimes.addAll(templist);    
      }
    }

     //instantiate the third date list of times 
        thirdlistoftimes = new List<String>();
        thirdlistoftimes = getthirdList();
        templist.clear();
        count = 0;
   if(thirdlistoftimes.size() > 1){
   notimes3 = false;
     if(thirdlistoftimes.size() > 4){
          biglist3 = true;
          daythreeparttwo.clear();
          for(String s : thirdlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      daythreeparttwo.add(s);
                 }
          } 
          thirdlistoftimes.clear();                  
          thirdlistoftimes.addAll(templist);    
      }
     } 
     
        //instantiate the fourth date list of times 
        fourthlistoftimes = new List<String>();
        fourthlistoftimes = getfourthList();
        templist.clear();
          count = 0;
   if(fourthlistoftimes.size() > 1){
   notimes4 = false;
     if(fourthlistoftimes.size() > 4){
     dayfourparttwo.clear();
          biglist4 = true;
          for(String s : fourthlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      dayfourparttwo.add(s);
                 }
          } 
          fourthlistoftimes.clear();                  
          fourthlistoftimes.addAll(templist);    
      }
    }
    }
    }//end new section setup
  
  
  
    
    if(wsStatus == 'Scheduled' || wsStatus == 'Rescheduled'){
    //options to change the time
    //displays the current time chosen
        
    displaydate = oppwsappt.format('EEEEE, MM/dd/yyyy');
    displaytime = oppwsappt.format('h:mm a') + ' EST';
     //create google link for calendar addition
 String spacereplace = '%20';
dtstart = oppwsappt.formatGMT('yyyyMMdd')+'T'+ oppwsappt.formatGMT('HHmmss')+'Z';
Datetime dtend = oppwsappt.addminutes(15);
 dtimeend = dtend.formatGMT('yyyyMMdd')+'T'+ dtend.formatGMT('HHmmss')+'Z';
 String tempstr = 'http://www.google.com/calendar/event?action=TEMPLATE&text=&dates='+dtstart+'/'+dtimeend+'&details=&location=&trp=true&sprop=&sprop=name:';
 googlecal = tempstr.replaceAll(' ',spacereplace);
        rescheduleTime();
        

    
    }
    
    if(wsStatus == 'Canceled'){
    //show that the previous time has been canceled
    //give the option of selecting a new time
    //displaydate = oppwsappt.format('MM.dd.yyyy');
   // displaytime = oppwsappt.format('h:mm a z');
        cancelTime();

    }    
    
    if(wsStatus == null || wsStatus == 'Completed'){
        
        nopagestatus();
        wsStatus = 'New';
    }
     
    //pull the name of the css from the static resources , pulls from the custom settings    
    csspage = getCSSResource(opp.account.name);
    emailtemplate1 = gettemplateCancel(opp.account.name);
    emailtemplate2 = gettemplateSchedule(opp.account.name);
    defaultemail = getDefaultEmail(opp.account.name);
    homepage = getHomepageLink(opp.account.name);
    returntext = getLinkText(opp.account.name);
    
    //if unable to find then display error page
    
    if(csspage == null){
         System.debug('@asha: Web scheduler :: unable to find css page');
         pgmsg = 'ERROR: Issue finding page data.';
         csspage = 'blankcss';
         errorsection = true;
    }
    
   


    //
    

 }
  /* -------------------------------------------------------------------------------------
   * Method for displaying the dates and times for each of the days
   * 
   *
   * 
   * ------------------------------------------------------------------------------------- */
/*  public List<SelectOption> getDayList2() {
            List<SelectOption> options = new List<SelectOption>();

                Set<datetime> firsttimes = datetotimemap.keyset();
                if(firsttimes.size() > 0){
                    List<datetime> templist = new list<datetime>();
                    List<string> temptimelist = new list<string>();

                    templist.addAll(firsttimes);
                    templist.sort();
                    temptimelist.addAll(datetotimemap.get(templist[0]));
                    for(string t : temptimelist){
                    options.add(new SelectOption(t, templist[0].format('MM.dd.yyyy')+' - '+t) );
                    
                    }
                
                
                }
                else{
                // state no times available for that date
                     options.add(new SelectOption('','None Available', true));
                }
            //}

            return options;
 }
 */
 
 public List<SelectOption> getDayList() {
            List<SelectOption> options = new List<SelectOption>();

                Set<datetime> firsttimes = newmapping.keyset();
                if(firsttimes.size() > 0){
                    List<datetime> templist = new list<datetime>();
                    templist.addAll(firsttimes);
                    templist.sort();
                    for(datetime t : templist){
                    options.add(new SelectOption(t.format(), t.format('MM.dd.yyyy h:mm a z') + ' ' + newmapping.get(t)));
                    
                    }
                
                
                }
                else{
                // state no times available for that date
                     options.add(new SelectOption('','None Available', true));
                }
            //}

            return options;
 }
 
 
 /* -------------------------------------------------------------------------------------
   * Returns a date Collection of Start/End dates for US Daylight Saving Time
   * for the specified year.
   *
   * Based on code from: http://www.webexhibits.org/daylightsaving/b2.html
   * ------------------------------------------------------------------------------------- */
   public Date[] getDSTDates(Integer theYear) {
      Long thisYear;
      Long AprilDate;
      Long OctoberDate;
      Long MarchDate;
      Long NovemberDate;
      Long longSeven = 7;
      thisYear = Math.round(theYear);
      
      AprilDate = Math.mod(2+6 * thisYear - Math.floor(thisYear / 4).longValue(), longSeven) + 1;
      OctoberDate=  Math.mod(31-( Math.floor(thisYear * 5 / 4).longValue() + 1), longSeven);
      
      MarchDate = 14 - Math.mod(Math.floor(1 + thisYear * 5 / 4).LongValue(), longSeven);
      NovemberDate = 7 - Math.mod(Math.floor (1 + thisYear * 5 / 4).LongValue(), longSeven);
      
      string startDate = (thisYear > 2006 ? ('03/'+MarchDate) : ('04/'+AprilDate)) + '/' + thisYear;
      string endDate = (thisYear > 2006 ? ('11/'+NovemberDate):('10/'+OctoberDate))+ '/' + thisYear;
      
      Date[] rtnDates = new List<Date>();
      rtnDates.add(Date.parse(startDate));
      rtnDates.add(Date.parse(endDate));
      return rtnDates;
   }
 
 // used to determine what to convert the times to based on whether daylight Saving time is active or not
    public Integer convertFromGMT(){
      Date theDate = date.today();        
      Date[] dstDates = getDSTDates(theDate.year()); // [0]=startDate, [1]=endDate
      boolean isDSTOn = (theDate >= dstDates[0] && theDate <= dstDates[1]);
   
      if(isDSTOn){
        return 4;
      } 
    
      return 5; 
   
   }
   
 public PageReference cancelAppointment(){
 
 Datetime sdt = oppwsappt; 
 PageReference pg = new PageReference('/webapptscheduler?pmid='+oppid);

//pull all events for the next 30 mins to check and see if something got scheduled during that time period
    Boolean updated = WebSchedulerUtils.cancelAppointment(sdt,oppid,oppown);
     if(!updated){
        //show error page if issue cancelling
         pgerr( 'ERROR: Issue finding event to cancel. Please try refreshing the page.');

        //  return pg;
         return null;
        }
    
    //set the web sched picklist to cancelled
    wsStatus = 'Canceled';
    
    Boolean successful =  WebSchedulerUtils.updateOpportunity(oppid, wsStatus, null);

    if(!successful){
        //show error page if issue cancelling
         pgerr( 'ERROR: Issue finding updating appointment status. Please try refreshing the page.');
         return null;
        }
    
       generateEmail(sdt);
     //change the page
     cancelTime();
     return null;
     
 }
 
 
 //returns the select options list for the student to choose on the vf page

 public List<SelectOption> getFirstDayList() {
            List<SelectOption> options = new List<SelectOption>();
            
            //first day shown will be today so pull the times for today
           // date firstday = date.today();
           // if(mapoftimesbydate.containsKey(firstday)){
               // List<datetime> firsttimes = mapoftimesbydate.get(firstday);
                //check to make sure there are times available
                
                Set<datetime> firsttimes = temptimemap.keyset();
                if(firsttimes.size() > 0){
                    List<datetime> templist = new list<datetime>();
                    templist.addAll(firsttimes);
                    templist.sort();
                    for(datetime t : templist){
                    options.add(new SelectOption(t.format(), t.format('MM.dd.yyyy h:mm a z') + ' ' + temptimemap.get(t)));
                    
                    }
                
                
                }
                else{
                // state no times available for that date
                     options.add(new SelectOption('','None Available', true));
                }
            //}

            return options;
 }

 
 //return the list of the first links
  public List<String> getfirstList() {
            List<String> options = new List<String>();
            LIst<datetime> day1temp = new list<datetime>();
          
            //first day shown will be today so pull the times for today
            datetime newstart = datetime.now();
           
            date firstday = newstart.dateGMT();
            date tempday = newstart.adddays(1).dateGMT();
            
            //datetime earlygmt = datetime.newInstanceGmt(tempday.

            //format the date with week day, month and day  (ex. Wed, May 23)
             //dayone = datetime.now().format('EEE, MMMM d');
            //(temptimemap.containsKey(firstdatetime)){
            Set<datetime> newset = temptimemap.keyset();
            day1temp.addAll(newset);
              day1temp.sort();
              
              for(datetime d : day1temp){
                  //date has to be the same as the first day or btw 0 and 2am of the next day and the time slot needs to be available
                  if( temptimemap.get(d) && ( d.dateGMT() == firstday)){
                         options.add(d.format('h:mm a'));
                  }
              
                  if( temptimemap.get(d) && (d.dateGMT() == tempday) && ( (d.timeGMT() >= startnextday) && (d.timeGMT()<= endnextday ))){
                         options.add(d.format('h:mm a'));
                  }
              
              }
              

            return options;
 }

  public List<String> getsecondList() {
            List<String> options = new List<String>();
            List<datetime> day2temp = new list<datetime>();
          
            //sec day shown will be today so pull the times for today
            
            datetime newstart = datetime.now();
            if(movetonextday){
                newstart.addhours(10);
            }
            date secday = newstart.adddays(1).dateGMT();
            date tempday = newstart.adddays(2).dateGMT();
            //datetime earlygmt = datetime.newInstanceGmt(tempday.

            //format the date with week day, month and day  (ex. Wed, May 23)
           //  daytwo = datetime.now().adddays(1).format('EEE, MMMM d');
            //(temptimemap.containsKey(firstdatetime)){
            Set<datetime> newset = temptimemap.keyset();
            day2temp.addAll(newset);
              day2temp.sort();
              
              for(datetime d : day2temp){
                  //date has to be the same as the day or btw 0 and 2am of the next day and the time slot needs to be available
                  if( temptimemap.get(d) && (d.dateGMT() == secday) && ( (d.timeGMT() >= startofday) && (d.timeGMT()<= endofday))){
                         options.add(d.format('h:mm a'));
                  }
              
                  if( temptimemap.get(d) && (d.dateGMT() == tempday) && ( (d.timeGMT() >= startnextday) && (d.timeGMT()<= endnextday ))){
                         options.add(d.format('h:mm a'));
                  }
              
              }

            return options;
 }




 //return the list of the first links
  public List<String> getthirdList() {
          List<String> options = new List<String>();
            List<datetime> day3temp = new list<datetime>();
          
            //sec day shown will be today so pull the times for today
            
                        datetime newstart = datetime.now();
            if(movetonextday){
                newstart.addhours(10);
            }
            date thirdday = newstart.adddays(2).dateGMT();
            date tempday = newstart.adddays(3).dateGMT();
            //datetime earlygmt = datetime.newInstanceGmt(tempday.


            //(temptimemap.containsKey(firstdatetime)){
            Set<datetime> newset = temptimemap.keyset();
            day3temp.addAll(newset);
              day3temp.sort();
              
              for(datetime d : day3temp){
                  //date has to be the same as the day or btw 0 and 2am of the next day and the time slot needs to be available
                  if( temptimemap.get(d) && (d.dateGMT() == thirdday) && ( (d.timeGMT() >= startofday) && (d.timeGMT()<= endofday))){
                         options.add(d.format('h:mm a'));
                  }
              
                  if( temptimemap.get(d) && (d.dateGMT() == tempday) && ( (d.timeGMT() >= startnextday) && (d.timeGMT()<= endnextday ))){
                         options.add(d.format('h:mm a'));
                  }
              
              }


            return options;
 }

 //return the list of the first links
  public List<String> getfourthList() {
             List<String> options = new List<String>();
            List<datetime> day4temp = new list<datetime>();
          
            //sec day shown will be today so pull the times for today
                        datetime newstart = datetime.now();
            if(movetonextday){
                newstart.addhours(10);
            }
            date fourthday = newstart.adddays(3).dateGMT();
            date tempday = newstart.adddays(4).dateGMT();
            //datetime earlygmt = datetime.newInstanceGmt(tempday.

            //format the date with week day, month and day  (ex. Wed, May 23)
            // daythree = datetime.now().adddays(3).format('EEE, MMMM d');
            //(temptimemap.containsKey(firstdatetime)){
            Set<datetime> newset = temptimemap.keyset();
            day4temp.addAll(newset);
              day4temp.sort();
              
              for(datetime d : day4temp){
                  //date has to be the same as the day or btw 0 and 2am of the next day and the time slot needs to be available
                  if(((d.dateGMT() == fourthday) || (d.dateGMT() == tempday && (d.timeGMT()>= startnextday && d.timeGMT() <= endnextday)) ) && temptimemap.get(d)){
                         options.add(d.format('h:mm a'));

                  }
              
              }


            return options;
 }


 
 public PageReference firstdatechosen(){
     
     date theday = datetime.now().date();
     if(movetonextday){
         theday = datetime.now().addhours(10).date();
     }
     
     String fulldate = theday.month()+ '/' + theday.day() + '/' +theday.year()+ ' ' + inTime;
     Datetime d = Datetime.parse(fulldate);
     Datetime newdatetime  = datetime.newInstanceGmt(d.dateGMT(),d.timeGMT());
     system.debug('@asha: websched :: time in gmt = '+ newdatetime);
    return makeAppointment(newdatetime);
     
     
     
 }
 
  public PageReference seconddatechosen(){
     date theday = datetime.now().adddays(1).date();
     if(movetonextday){
         theday = datetime.now().adddays(1).addhours(10).date();
     }
     String fulldate = theday.month()+ '/' + theday.day() + '/' + theday.year()+ ' ' + inTime;
     Datetime d = Datetime.parse(fulldate);
     Datetime newdatetime  = datetime.newInstanceGmt(d.dateGMT(),d.timeGMT());
     system.debug('@asha: websched :: time in gmt = '+ newdatetime);
    return makeAppointment(newdatetime);
     
     
     
 }
 
 
  public PageReference thirddatechosen(){
     
          date theday = datetime.now().adddays(2).date();
     if(movetonextday){
         theday = datetime.now().adddays(2).addhours(10).date();
     }
     
     String fulldate = theday.month()+ '/' + theday.day() + '/' + theday.year()+ ' ' + inTime;
     Datetime d = Datetime.parse(fulldate);
     Datetime newdatetime  = datetime.newInstanceGmt(d.dateGMT(),d.timeGMT());
     system.debug('@asha: websched :: time in gmt = '+ newdatetime);
    return makeAppointment(newdatetime);
     
     
 }
 
  public PageReference fourthdatechosen(){
     date theday = datetime.now().adddays(3).date();
     if(movetonextday){
         theday = datetime.now().adddays(3).addhours(10).date();
     }
     
     String fulldate = theday.month()+ '/' + theday.day() + '/' + theday.year()+ ' ' + inTime;
     Datetime d = Datetime.parse(fulldate);
     Datetime newdatetime  = datetime.newInstanceGmt(d.dateGMT(),d.timeGMT());
     system.debug('@asha: websched :: time in gmt = '+ newdatetime);
     return makeAppointment(newdatetime);
     
     
 }
 
 

 
//public List<datetime> availabledt {get;set;}
//returns all the available times in a map of the dates paired with a list of times
public Map<date, List <datetime>>  dayTimeListing(Map<datetime,boolean> dtmap){
Map<date, List <datetime>> maptimebydays = new Map<date, List <datetime>>();
Set <datetime> dateset = new Set<datetime>();
dateset = dtmap.keySet();
 List<datetime> availabledt = new  List<datetime>();


if(!dateset.isEmpty()){
//iterate through the set of datetimes
    for(datetime d: dateset){
        //if the value in the map is true the time is available. Add it to the new set of available datetimes
        
        if(dtmap.get(d)){
             availabledt.add(d);           
        }
    
    }
 
    
 //   check that there are date values
    if(availabledt.size() >0){
        //with the list of actual available datetimes separate it out by date and create lists of just the times
        date thedate = availabledt[0].dateGMT();
        List <datetime> thetimes = new List<datetime>();
        //add the first date / time list to the map
        thetimes.add(availabledt[0]);
        maptimebydays.put(thedate,thetimes);
        
        for(datetime dts: availabledt){
            //same day as the date select add to the times list    
            //if(dts.isSameDay(thedate)){
             if(maptimebydays.containsKey(dts.dateGMT())){
                thetimes.clear(); 
                thetimes = maptimebydays.get(dts.dateGMT());
                thetimes.add(dts);
                maptimebydays.put(dts.dateGMT(),thetimes);
           }else{
                // then add the new list for that date and set the date and list of times  to the new date         
   
               thedate = dts.date();
               thetimes.clear();
               //thetimes.add(dts.time());
               thetimes.add(dts);
               //add the new date to the map
               maptimebydays.put(thedate,thetimes);
               
                
            }
        
        }
        
        
    
    }
}



return maptimebydays ;
}


 //view if the nothing is set for the web status field or the field is set as completed
public void nopagestatus(){
 newtime = false;
 someoneelsechosetime = false;
 timehasbeenchosen = false;
 chooseanothertime = false;
 sorrypage = false;
 nonepage = true;
} 


public void newTime(){
 newtime = true;
 someoneelsechosetime = false;
 timehasbeenchosen = false;
 chooseanothertime = false;
 sorrypage = false;
 nonepage = false;
} 

public void rescheduleTime(){
 newtime = false;
 someoneelsechosetime = false;
 timehasbeenchosen = true;
 chooseanothertime = false;
 sorrypage = false;
 nonepage = false;
}

public void cancelTime(){

        //notime = true;
 newtime = false;
 someoneelsechosetime = false;
 timehasbeenchosen = false;
 chooseanothertime= true;
 sorrypage = false;
 nonepage = false;
} 
 
public void notavailableAnymore(){
 newtime = false;
 someoneelsechosetime = true;
 timehasbeenchosen = false;
 chooseanothertime= false;
 sorrypage = false;
 nonepage = false;
} 
 
 public void cancelsorry(){
 newtime = false;
 someoneelsechosetime = false;
 timehasbeenchosen = false;
 chooseanothertime= false;
 sorrypage = true;
 nonepage = false;
 }
 
public PageReference nothankspageview(){
    cancelsorry();
    return null;
}
 

    
private String getCSSResource(String acctname){

    String thecss;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.CSS_Resource__c != null){
                thecss = theCampusCS.CSS_Resource__c ;        
            }
        }


    return thecss;
}

private String getDefaultEmail(String acctname){

    String theemail;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.DefaultEmail__c != null){
                theemail = String.valueOf(theCampusCS.DefaultEmail__c) ;        
            }
        }


    return theemail;
}



private String getHomepageLink(String acctname){

    String theurl;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.schoolurl__c != null){
                theurl = String.valueOf(theCampusCS.schoolurl__c) ;        
            }
        }


    return theurl;
}


private String getLinkText(String acctname){

    String thetxt;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.return_link_text__c != null){
                thetxt = theCampusCS.return_link_text__c ;        
            }
        }


    return thetxt;
}
private String getTemplateSchedule(String acctname){

    String thetemplate;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.EmailTemplateSchedule__c != null){
                thetemplate = theCampusCS.EmailTemplateSchedule__c;        
            }
        }


    return thetemplate;
}

public PageReference returnHome(){

PageReference thehome = new PageReference('/webapptscheduler?pmid='+oppid); 
if(homepage != null){

     thehome = new PageReference(homepage);
}
 return thehome;
 
}

private String gettemplateCancel(String acctname){

    String thetemplate;

    //pull the name of the static resource from the custom settings
        WebSchedulerInfo__c theCampusCS = WebSchedulerInfo__c.getValues(acctname);
        if(theCampusCS != null){
            if(theCampusCS.EmailTemplateCancel__c != null){
                thetemplate = theCampusCS.EmailTemplateCancel__c;        
            }
        }


    return thetemplate;
}

public datetime roundtofifteen(Datetime d){
//grab the minute of the date 
Integer currentmin = d.minute();

//round down to the 15 min periods

    //round to 0 if btw 0 and 14
    if(currentmin >= 0 && currentmin < 14){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),0,0);

    }

//round to 15 if btw 15 and 29
    if(currentmin >= 15 && currentmin < 29){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),15,0);

    }
    
    //round to 30 if btw 30 and 44
    if(currentmin >= 30 && currentmin < 44){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),30,0);

    }
    

    //otherwise at the end of the hr and round to 45 mins
    return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),45,0);

        
}



public void generateEmail(Datetime dt){
    if(dt != null){
    if(wsStatus == 'Canceled'){
            Integer intname = pmname.indexof(' ');
            String shortername = pmname;
            if(intname > 0){
                shortername = pmname.substring(0,intname);
            }
            String bodymsg = '';
            bodymsg = '<html><body style=\"font-family:Corbel,Arial,Helvetica,sans-serif;font-size:14px;color:#575757;\">';
            bodymsg +='<table cellpadding=\"0\" width=\"600\" cellspacing=\"0\" border=\"0\"><tr><td colspan=\"3\">';
            bodymsg += schoolname;
            bodymsg +='</td></tr><tr><td width=\"59\" height=\"228\" style=\"background-color:#ffffff\"> ';
            bodymsg +='</td><td height=\"228\" width=\"485\"><h2 style=\"font-size:14px;text-align:center;\">';
            bodymsg +='The following appointment time with <b>'+shortername+'</b><br/> has been canceled.';
            bodymsg +='</h2><h1 style=\"font-size:24px;text-align:center;\"> '+dt.format('EEE, MMMMM d, yyyy h:mm a')+ ' EST';
            bodymsg +='</h1><br/><br/><h3 style=\"font-size:14px;text-align:center;\">To reschedule an appointment click below.</h3>';
            bodymsg +='<center><a style=\"text-align:center;\" href=\"http://learntoday.ashadev.login.force.com/webscheduler?pmid='+oppid+'\" >';
            bodymsg +='Change Appointment</a></center></td><td width=\"65\" height=\"228\" style=\"background-color:#ffffff\"> </td>';
            bodymsg +='</tr><tr><td colspan=\"3\"></td></tr></table></body></html>';
            
             if(emailtemplate1 !=  null){
                 Blob eblob = WebSchedulerUtils.pullinEmailText(emailtemplate1,oppid,dt,schoolname,pmname) ;
                 if(eblob != null){
                      bodymsg = eblob.toString();
                 }
             }

            String ereply = pmemail; //this may need a default value
            String esender = pmemail;
            
            if(pmemail == null){
                if(defaultemail != null){
                ereply = defaultemail;
                esender = defaultemail;
                }
                else{
                    //if no default then use psc address
                    //this should not happen
                    ereply = 'help@personalsupportcenter.com';
                    esender = 'help@personalsupportcenter.com';
                }
            }

            String sub = oppfname +' '+opplname +' : Your appointment has been canceled';
            List <String> emailAddresses = new List <String>();

            System.debug('ownerid='+oppown);
            //User pmrep = [select Email FROM User WHERE Id=:opp.owner.name LIMIT 1];
            
            
            emailAddresses.add(stdemail1);
            //check to see if the same email and doesnt add twice if so
            if(stdemail1 != stdemail2){
                emailAddresses.add(stdemail2);
            }
            if(stdemail3 != null){
                if((stdemail3 != stdemail1) && (stdemail3 != stdemail2)){
                    emailAddresses.add(stdemail3);
                }
            }

            
         List <String> bccAddresses = new List <String>();
       
            bccAddresses.add(ereply);
   
            
            

           MailerUtils.sendMail(bodymsg,sub, emailAddresses, bccAddresses, ereply, esender);
   

    }
    
    if(wsStatus == 'Scheduled' || wsStatus == 'Rescheduled'){
            Integer intname2 = pmname.indexof(' ');
            String shortername2 = pmname;
            if(intname2 > 0){
                shortername2 = pmname.substring(0,intname2);
            }
            String bodymsg = '';
            bodymsg = '<html><body style=\"font-family:Corbel,Arial,Helvetica,sans-serif;font-size:14px;color:#575757;\">';
            bodymsg +='<table cellpadding=\"0\" width=\"600\" cellspacing=\"0\" border=\"0\"><tr><td colspan=\"3\">'+ schoolname;
            bodymsg +='</td></tr><tr><td height=\"228\" width=\"59\" style=\"background-color:#ffffff;\">';
            bodymsg +='</td><td height=\"228\" width=\"485\"><h2 style=\"font-size:14px;text-align:center;\">';
            bodymsg +='Thank you! Your appointment with <b>'+shortername2+'</b><br/> has been scheduled for:';
            bodymsg +='</h2><h1 style=\"font-size:24px;text-align:center;\"> '+dt.format('EEE, MMMMM d, yyyy h:mm a')+ ' EST';
            bodymsg +='</h1><br/><br/><h3 style=\"font-size:14px;text-align:center;\">To change or cancel your appointment time click below.</h3>';
            bodymsg +='<center><a style=\"text-align:center;\" href=\"http://learntoday.ashadev.login.force.com/webscheduler?pmid='+oppid+'\" >';
            bodymsg +='Change Appointment</a></center></td><td height=\"228\" width=\"65\" style=\"background-color:#ffffff;"> </td>';
            bodymsg +='</tr><tr><td colspan=\"3\"></td></tr></table></body></html>';
            
            if(emailtemplate2 !=  null){
            Blob eblob = WebSchedulerUtils.pullinEmailText(emailtemplate2,oppid,dt,schoolname,pmname) ;
                if(eblob != null){
                    bodymsg = eblob.toString();    
                }
            }

                  
            String ereply = pmemail;
            String esender = pmemail;
            
            if(pmemail == null){
                if(defaultemail != null){
                ereply = defaultemail;
                esender = defaultemail;
                }
                else{
                    //if no default then use psc address
                    //this should not happen
                    ereply = 'help@personalsupportcenter.com';
                    esender = 'help@personalsupportcenter.com';
                }
            }
            Integer intname3 = pmname.indexof(' ');
            String shortername3 = pmname;
            if(intname3 > 0){
                shortername3 = pmname.substring(0,intname3);
            }
            String sub = wsStatus + ' Email Confirmation for '+ oppfname +' '+ opplname +' :  Your appointment with ' + shortername3 + ' ';
            List <String> emailAddresses = new List <String>();
            System.debug('ownerid='+oppown);
            //User pmrep = [select Email FROM User WHERE Id=:opp.owner.name LIMIT 1];
            
            emailAddresses.add(stdemail1);
                //add if email not the same
            if(stdemail1 != stdemail2){
                emailAddresses.add(stdemail2);
            }
            if(stdemail3 != null){
                if((stdemail3 != stdemail1) && (stdemail3 != stdemail2)){
                    emailAddresses.add(stdemail3);
                }
            }
            
         List <String> bccAddresses = new List <String>();
            bccAddresses.add(ereply);
            
            Messaging.EmailFileAttachment mailAttachment;
            mailAttachment = new Messaging.EmailFileAttachment();
            
            if(dt != null){
            mailAttachment = createICSAttachment(dt);
            }
           // MailerUtils.sendMail(bodymsg,sub, emailAddresses, bccAddresses, ereply, esender);
           MailerUtils.sendMailwAttachments(bodymsg,sub, emailAddresses, bccAddresses, ereply, esender,new Messaging.EmailFileAttachment[]{mailAttachment});
    
    
    }
    }else{
          pgerr( 'ERROR: Issue sending email. Please try again by clicking on the link below: ');
        
    }
    
    
    
}

public PageReference returntoPage(){
PageReference pg = new PageReference('/webapptscheduler?pmid='+oppid);
return pg;
}

public PageReference icsfile(){

PageReference pgRef = new PageReference('/apex/WebAppt?dt='+dtstart+'&pm='+pmname+'&pme='+pmemail+'&dte='+dtimeend);
return pgRef;
}


public String icsx {get;set;}

public Messaging.EmailFileAttachment createICSAttachment(datetime dt){
String dtstmp =  dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z';
String icstext = 'BEGIN:VCALENDAR\n';
icstext += 'VERSION:2.0\n'; 
icstext += 'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\n';
icstext += 'BEGIN:VEVENT\n';
icstext += 'UID:'+dtstmp+pmemail+'\n';
icstext += 'DTSTAMP:'+ dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z\n';
icstext += 'ORGANIZER:'+pmname+':MAILTO:'+pmemail+'\n';
icstext += 'DTSTART:' + dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z\n';
datetime dtend = dt.addminutes(30);
icstext += 'DTEND:' + dtend.formatGMT('yyyyMMdd')+'T'+dtend.formatGMT('HHmmss')+'Z\n';
icstext += 'SUMMARY:Web Scheduled appointment with '+pmname+' \n';
icstext += 'END:VEVENT\n';
icstext += 'END:VCALENDAR\n';

Blob icalfile = Blob.valueof(icstext);
 
         
            
 // create attachment with ics as body
 /* Attachment icsAttachment = new Attachment( Body = icalfile
                                                     , Name = 'webappt.ics'
                                                     , ContentType = 'application/octet-stream'
                                                     , ParentId = oppid
                                                     );

            insert icsAttachment;
*/

Attachment icsfile = WebSchedulerUtils.createICSFile(icstext,oppid);
icsx = icsfile.id;

            Messaging.EmailFileAttachment mailAttachment;
            mailAttachment = new Messaging.EmailFileAttachment();

          
            mailAttachment.setFileName('webappt.ics');
            mailAttachment.setBody(icalfile);

  return mailAttachment;
}


public void changeStatus(){
    
    if(wsStatus == 'Canceled'){
               wsStatus = 'Rescheduled';
   
    }
    
    if(wsStatus == 'Scheduled'){
               wsStatus = 'Canceled';    
    }
    
    if(wsStatus == 'New'){

           wsStatus = 'Scheduled';

    }

    if(wsStatus == 'Completed' ){

           wsStatus = 'Scheduled';

    }
    

}

public boolean blockouttime(Datetime dt){
 
 Boolean successful =  WebSchedulerUtils.addEvent(dt,oppid,oppown);
  if(!successful){
        //show error page if issue scheduling
        pgerr( 'ERROR: Issue adding new appointment. Please try again by clicking on the link below. ');

        }
        
    return successful;
}

public Boolean updateOpp(String wstatus, Datetime d){

   Boolean successful =  WebSchedulerUtils.updateOpportunity(oppid, wsStatus, d);
   if(successful){
        displaydate = d.format('EEEEE, MM/dd/yyyy');
        displaytime = d.format('h:mm a');
    }
   if(!successful){
        //show error page if issue cancelling
        pgerr( 'ERROR: Issue updating appointment status. Please try again by clicking on the link below.');
        }
        
        return successful;
}

/*
public void icsAttachmentLink(datetime dt){
String dtstmp =  dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z';
String icstext;
icstext = 'BEGIN:VCALENDAR\n';
icstext += 'VERSION:2.0\n'; 
icstext += 'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\n';
icstext += 'BEGIN:VEVENT\n';
icstext += 'UID:'+dtstmp+pmemail+'\n';
icstext += 'DTSTAMP:'+ dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z\n';
icstext += 'ORGANIZER:'+pmname+':MAILTO:'+pmemail+'\n';
icstext += 'DTSTART:' + dt.formatGMT('yyyyMMdd')+'T'+dt.formatGMT('HHmmss')+'Z\n';
datetime dtend = dt.addminutes(30);
icstext += 'DTEND:' + dtend.formatGMT('yyyyMMdd')+'T'+dtend.formatGMT('HHmmss')+'Z\n';
icstext += 'SUMMARY:Web Scheduled appointment with '+pmname+' \n';
icstext += 'END:VEVENT\n';
icstext += 'END:VCALENDAR\n';

//if using this method keep this section block until the end
Blob icalfile = Blob.valueof('');
            if(!runningtest){
             icalfile = Blob.valueof(icstext);
             }
            else { 
            String testString2 = 'This is for testing.';
            icalfile = Blob.valueof(testString2);
            }          
            
 // create attachment with ics as body
  Attachment icsAttachment = new Attachment( Body = icalfile
                                                     , Name = 'webappt.ics'
                                                     , ContentType = 'application/octet-stream'
                                                     , ParentId = oppid
                                                     );

            insert icsAttachment;
//end block

Attachment icsfile = WebSchedulerUtils.createICSFile(icstext,oppid);
icsx = icsfile.id;
}
*/

public PageReference chooseANewTime(){

//change the page view
        newTime();
        //pull a new list of times for events
        Map<datetime,boolean> timemap = WebSchedulerUtils.findTheMapping(convertTZ ,fromhere,threedays,oppown);
        temptimemap = timemap;
        mapoftimesbydate = dayTimeListing(timemap);
        Integer count = 0;
     //888888888888888 handles the four day layout with m-th (9a-4:30p) f(9-4:30) sat(10-3:30)8888888888888888888
firsttimes = new List<String>();
secondtimes = new List<String>();
thirdtimes = new List<String>();
fourthtimes = new List<String>();

          beforeconfirm = '';
          intime = '';
          intime3 = '';
          intime2 = '';
          intime4 = '';
      currenttime = datetime.now();    
   Map<datetime,boolean>   firstnewmapping = WebSchedulerUtils.findtheMap(currenttime, threedays, oppown);
        newmapping = findTheDayToStartFrom(firstnewmapping,currenttime);
List<datetime> listdates = determineDaysDisplayed(currenttime, convertTZ );
      empty1 = true;
      empty2 = true;
      empty3 = true;      
      empty4 = true;

List<String> opts = new List<String>();
Set<datetime> newset = newmapping.keyset();
List<datetime> daytemp = new List<datetime>();
if(newset.size() > 0){
Integer i = 0;
daytemp.addAll(newset);
daytemp.sort();
datetime thefirstday = daytemp[0];
              for(datetime d : daytemp){
                if( newmapping.get(d) && i == 0){
                    thefirstday = d;
                     i++;
                }
                //date has to be the same as the first day or btw 0 and 2am of the next day and the time slot needs to be available
                  if( newmapping.get(d) && ( i > 0) ){
                         if( i == 1 && ( d.format('EEEEE') == thefirstday.format('EEEEE'))){
                            opts.add(d.format('h:mm a'));
                         }
                         if( d.format('EEEEE') != thefirstday.format('EEEEE') && i == 1 ){
                            i++;
                         }
                  }
                  
              }
              
      if(opts.size() > 0){
          testfirsttimes = opts;
      }        
}   


datetotimemap = settheorder(newmapping, listdates);
if(!datetotimemap.isEmpty()){
Set<datetime> thedtset = datetotimemap.keyset();
List<datetime> thedtlist = new List<datetime>();
    if(thedtset.size() > 0){
        thedtlist.addAll(thedtset);
        thedtlist.sort();
        if(thedtlist[0] != null){ 
        
         firsttimes = datetotimemap.get(thedtlist[0]);
              if(firsttimes.size() > 0){ empty1 = false; }

         firstdaydisplayA = thedtlist[0].format('EEEEE').toUpperCase();
         firstdaydisplay = thedtlist[0].format('MMMM d, yyyy');
         firstdtdisplay = thedtlist[0];
        }
        if(thedtlist[1] != null){ 
         secondtimes = datetotimemap.get(thedtlist[1]);
              if(secondtimes.size() > 0){ empty2 = false; }

         seconddaydisplayA = thedtlist[1].format('EEEEE').toUpperCase();
         seconddaydisplay = thedtlist[1].format('MMMM d, yyyy');
         seconddtdisplay = thedtlist[1];
        }
        if(thedtlist[2] != null){ 
         thirdtimes = datetotimemap.get(thedtlist[2]);
               if(thirdtimes.size() > 0){empty3 = false; }     
         thirddaydisplayA = thedtlist[2].format('EEEEE').toUpperCase();
         thirddaydisplay = thedtlist[2].format('MMMM d, yyyy');
         thirddtdisplay = thedtlist[2];
        }
        if(thedtlist[3] != null){ 
         fourthtimes = datetotimemap.get(thedtlist[3]);
              if(fourthtimes.size() > 0){ empty4 = false; }
         fourthdaydisplayA = thedtlist[3].format('EEEEE').toUpperCase();
         fourthdaydisplay = thedtlist[3].format('MMMM d, yyyy');
         fourthdtdisplay = thedtlist[3];
        }
        
    }
}
        
if(movetonextday){
            dayone = datetime.now().addhours(10).format('EEE, MMMM d z');
          daytwo = datetime.now().addhours(10).adddays(1).format('EEE, MMMM d z');
          daythree = datetime.now().addhours(10).adddays(2).format('EEE, MMMM d z');
          dayfour = datetime.now().addhours(10).adddays(3).format('EEE, MMMM d z');
      }
      else{
      //format the date with week day, month and day  (ex. Wed, May 23)
      dayone = datetime.now().format('EEE, MMMM d z');
      daytwo = datetime.now().adddays(1).format('EEE, MMMM d z');
      daythree = datetime.now().adddays(2).format('EEE, MMMM d z');
      dayfour = datetime.now().adddays(3).format('EEE, MMMM d z');
       }
        //clear the lists
           dayoneparttwo = new List<String>();
           daytwoparttwo = new List<String>();
           daythreeparttwo = new List<String>();
           dayfourparttwo = new List<String>();  
      
     //set it so that hidden panels are hidden first
      biglist1 = false;
      biglist2 = false;
      biglist3 = false;
      biglist4 = false;
      
      notimes1 = true;
      notimes2 = true;
      notimes3 = true;      
      notimes4 = true;
    
      //instantiate the first list of times           
      firstlistoftimes = getfirstList();
      list<String> templist = new list<string>();
   if(firstlistoftimes.size() > 1){
   notimes1 = false;
      if(firstlistoftimes.size() > 4){
          biglist1 = true; // more than four dates so unhide panel
          for(String s : firstlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      dayoneparttwo.add(s); //add to the hidden panel dates
                 }
          } 
          firstlistoftimes.clear();                  
          firstlistoftimes.addAll(templist);    
      }
     }
     //instantiate the second date list of times 
        seclistoftimes = getsecondList();
        templist.clear();
        count = 0;
   if(seclistoftimes.size() > 1){
   notimes2 = false;
     if(seclistoftimes.size() > 4){
          biglist2 = true;
          for(String s : seclistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      dayoneparttwo.add(s);
                 }
          } 
          seclistoftimes.clear();                  
          seclistoftimes.addAll(templist);    
      }
    }

     //instantiate the third date list of times 
        thirdlistoftimes = getthirdList();
        templist.clear();
        count = 0;
   if(thirdlistoftimes.size() > 1){
   notimes3 = false;
     if(thirdlistoftimes.size() > 4){
          biglist3 = true;
          for(String s : thirdlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      daythreeparttwo.add(s);
                 }
          } 
          thirdlistoftimes.clear();                  
          thirdlistoftimes.addAll(templist);    
      }
     } 
     
        //instantiate the fourth date list of times 
        fourthlistoftimes = getfourthList();
        templist.clear();
          count = 0;
   if(fourthlistoftimes.size() > 1){
   notimes4 = false;
     if(fourthlistoftimes.size() > 4){
          biglist4 = true;
          for(String s : fourthlistoftimes){
     
              if(count < 4 ){
                    templist.add(s);
                    count++;
                 }
                  else{                  
                      dayfourparttwo.add(s);
                 }
          } 
          fourthlistoftimes.clear();                  
          fourthlistoftimes.addAll(templist);    
      }
    }
        
        
        
        
        
    return null;
}

public String displaydate {get;set;}
public String displaytime {get;set;}

 public PageReference makeAppointment(Datetime c){
 String oldwsStatus = wsStatus;
 
 //create google link for calendar addition
 String spacereplace = '%20';
 dtstart = c.formatGMT('yyyyMMdd')+'T'+ c.formatGMT('HHmmss')+'z';
 datetime dtend = c.addminutes(15);
dtimeend = dtend.formatGMT('yyyyMMdd')+'T'+dtend.formatGMT('HHmmss')+'z';
 String tempstr = 'http://www.google.com/calendar/event?action=TEMPLATE&text=Appointment%20with'+pmname+'&dates='+dtstart+'/'+dtimeend+'&details=your%20scheduled%20appointment&location=Phone%20Appointment&trp=true&sprop=&sprop=name:';
 googlecal = tempstr.replaceAll(' ',spacereplace);
  //pull the time chosen
  if(c != null){
 Datetime sdt = c;
 system.debug('@asha: websched: time has been selected ' +sdt);
 //change the page view
 
 //insert the time
     Boolean successful = blockouttime(sdt);
     
     //check to see if another was scheduled or if an event coinicides with time 
     if(WebSchedulerUtils.checkTimeAgain(sdt,oppown,oppid)){
        notavailableAnymore();
        successful = false;
       // notime = true;
        WebSchedulerUtils.cancelAppointment(sdt,oppid,oppown);
         system.debug('@asha: websched: time not available' +sdt);
        return null;
    
    }

    

    system.debug('@asha: websched: schedule of time is successful: ' + successful);
    if(successful){
       changeStatus(); 
       successful = updateOpp(wsStatus,sdt);
       system.debug('@asha: websched: update to opportunity was succesful: ' +successful);
       if(successful){
              
           rescheduleTime();
           system.debug('@asha: websched: time officially booked. sending to next page');
               
            if(sdt != null){
            generateEmail(sdt);
            oppwsappt = sdt;

    displaydate = sdt.format('EEEEE, MM/dd/yyyy');
    displaytime = sdt.format('h:mm a') + ' EST';
             }
       }
    }
    }else{
        //error finding event
         System.debug('@asha: Web scheduler ::  Issue finding the currently scheduled appointment. ');
         pgerr( 'ERROR: Issue selecting the currently scheduled appointment. Please try again.');
         wsStatus = oldwsStatus;
        }
    

    return null;

      }
      
  /* -------------------------------------------------------------------------------------
   * Method for error page display 
   *
   * 
   * ------------------------------------------------------------------------------------- */      
  public void pgerr(String pmsg){
         pgmsg = pmsg;
         chooseanothertime = false;    
         newtime = false;
         someoneelsechosetime = false;
         timehasbeenchosen = false;
         errorsection = true;  
         sorrypage = false;
  }    
      
      
      
      
      
  /* -------------------------------------------------------------------------------------
   * Method for determining which day to display first based on the time of day the 
   * student goes to the webscheduler
   * M-Th 9am - 4pm same day; after 4pm display next day
   * Fri,Sat - before 1:30p same day ; after 1:30pm display the next day
   * Sun - display the next day
   * ------------------------------------------------------------------------------------- */
public Boolean findFirstDay(datetime ct, Integer tz){
  String theday = ct.addhours(-tz).format('EEEEE'); 
  Time thetime = ct.timeGMT().addhours(-tz);
 Time fourpm = Time.newInstance(16, 30, 0, 0);
  Time onepm = Time.newInstance(13, 30, 0, 0);
  
    if(theday == 'Sunday'){
        return true;
    }
 
    if(theday == 'Friday' || theday == 'Saturday'){
       if(thetime >= onepm){
            return true;
        }
    }
 
    if(theday == 'Monday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday'){
       if(thetime >= fourpm){
            return true;
        }
    }
 
    return false;
 }

  /* -------------------------------------------------------------------------------------
   * Method to find out what day of the week it is
   * convertTZ is the current conversion for either EDT or EST 
   * Blocks out the times based on the day of the week
   * 
   *
   * ------------------------------------------------------------------------------------- */
public Map<datetime,boolean> findTheDayToStartFrom(Map<datetime,boolean> dtmap,datetime dt){

    Map<datetime,boolean> newmap = dtmap;
    Integer thistz = -convertTZ;
    String thedayStr =  dt.formatGMT('EEEEE');
    if(thedayStr == 'Monday'){
        newmap = WebSchedulerUtils.startFromMonday(dtmap,convertTZ,dt);
    } 
    if(thedayStr == 'Tuesday'){
        newmap = WebSchedulerUtils.startFromTuesday(dtmap,convertTZ,dt);
    } 
    if(thedayStr == 'Wednesday'){
        newmap =  WebSchedulerUtils.startFromWednesday(dtmap,convertTZ,dt);  
    } 
    if(thedayStr == 'Thursday'){
        newmap =  WebSchedulerUtils.startFromThursday(dtmap,convertTZ,dt);  
    }
    if(thedayStr == 'Friday'){
        newmap =  WebSchedulerUtils.startFromFriday(dtmap,convertTZ,dt);  
    }
    if(thedayStr == 'Saturday'){
         newmap =  WebSchedulerUtils.startFromSaturday(dtmap,convertTZ,dt); 
    }
    if(thedayStr == 'Sunday'){
        newmap =   WebSchedulerUtils.startFromSunday(dtmap,convertTZ,dt); 
    }

    return newmap;
    
}

// method to determine the four days that will be shown on the site
public List<datetime> determineDaysDisplayed(datetime ct, Integer z){
  list<datetime> listofdt = new list<datetime>();
  
  Time nineam = Time.newInstance(9 + z, 0, 0, 0);
  Time onepm = Time.newInstance(13 + z, 0, 0, 0);
  Time twopm = Time.newInstance(14 + z, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + z, 30, 0, 0);
  Time threepm = Time.newInstance(15 + z, 30, 0, 0);
  // Integer otime = (20 + z) - 24;
  //anything before midnight of the day which is 4 or 5 hrs ahead GMT time depending on Daylight Savings
   Time endtime = time.newInstance(z,30,0,0); 
   
   Time c = ct.TimeGMT();
   
//default datetimes
datetime dayone = datetime.newInstanceGMT(ct.year(),ct.month(), ct.day(), 10 ,0,0);   
    
if ( c < endtime){
    dayone = datetime.newInstanceGMT(ct.addhours(10).year(),ct.addhours(10).month(), ct.addhours(10).day(), 10 ,0,0);
    if(dayone.format('EEEEE') == 'Sunday'){
        dayone = dayone.adddays(1);
    }
}
if( c >= endtime && c < fourpm){
    if(((dayone.format('EEEEE') == 'Friday')&&(c>=twopm))||((dayone.format('EEEEE') == 'Saturday')&&(c>=onepm))){
        dayone = dayone.adddays(1);
    }
    if(dayone.format('EEEEE') == 'Sunday'){
        dayone = dayone.adddays(1);
    }
    

}
if( c > fourpm){
    dayone = datetime.newInstanceGMT(ct.adddays(1).year(),ct.adddays(1).month(), ct.adddays(1).day(), 10 ,0,0);
    if(dayone.format('EEEEE') == 'Sunday'){
        dayone = dayone.adddays(1);
    }
}

   datetime daytwo = dayone.adddays(1);
        if(daytwo.format('EEEEE') == 'Sunday'){
        daytwo = daytwo.adddays(1);
    }
   datetime daythree = daytwo.adddays(1); 
        if(daythree.format('EEEEE') == 'Sunday'){
        daythree = daythree.adddays(1);
    }
   datetime dayfour = daythree.adddays(1);
    if(dayfour.format('EEEEE') == 'Sunday'){
        dayfour= dayfour.adddays(1);
    }
    
    listofdt.add(dayone);
    listofdt.add(daytwo);
    listofdt.add(daythree);
    listofdt.add(dayfour);

return listofdt;
}

// string that is shown to the user in the confirmation box when they select a time 
public String beforeconfirm {get;set;}


public datetime newdatetime {get;set;}

//method that changes the time to the full date time display for display to user
 public PageReference datetimechosen(){
     system.debug('@asha: websched :: time has been chosen');
     if(inTime != null){
      system.debug('@asha: websched :: time has been chosen, not null');
     if(firstdaydisplay != null){
     system.debug('@asha: websched :: time has been chosen, date is not null');
     if(firstdaydisplayA != null){   
             if(firstdtdisplay != null){
         beforeconfirm = firstdaydisplayA +', '+firstdaydisplay + ' @ '+ inTime;
       // String theday = firstdtdisplay;
       // beforeconfirm = theday.month()+ '/' + theday.day() + '/' +theday.year()+ ' @ ' + inTime2;
   
  String fulldate = firstdtdisplay.month()+ '/' + firstdtdisplay.day() + '/' + firstdtdisplay.year() + ' ' + inTime;
    Datetime d = Datetime.parse(fulldate);
    newdatetime  = datetime.newInstance(d.date(),d.time());
     system.debug('@asha: websched :: time in = '+ newdatetime);
               notime = false;
     }
     }
     }
     }
    return null;
     
     
     
 }
 
// public boolean setdate {get;set;}

  public PageReference datetimechosen2(){
     system.debug('@asha: websched :: time has been chosen');
     if(inTime2 != null){
      system.debug('@asha: websched :: time has been chosen, not null');
     if(seconddaydisplay != null){
     system.debug('@asha: websched :: time has been chosen, date is not null');
     if(seconddaydisplayA != null){
    // String theday = firstdaydisplay;
     if(seconddtdisplay != null){
         beforeconfirm = seconddaydisplayA + ', ' + seconddaydisplay + ' @ '+ inTime2;
      String fulldate = seconddtdisplay.month()+ '/' + seconddtdisplay.day() + '/' + seconddtdisplay.year() + ' ' + inTime2;
    Datetime d = Datetime.parse(fulldate);
    newdatetime  = datetime.newInstance(d.date(),d.time());
              notime = false;
   // String fulldate = firstdaydisplay + ' ' + inTime2;
    // beforeconfirm = theday.month()+ '/' + theday.day() + '/' +theday.year()+ ' @ ' + inTime2;
    //Datetime d = Datetime.parse(fulldate);
    // newdatetime  = datetime.newInstance(d.date(),d.time());
    // system.debug('@asha: websched :: time in gmt = '+ newdatetime);
     }
     }
     }
     }
    return null;
     
     
     
 }

  public PageReference datetimechosen3(){

     if(inTime3 != null){
      system.debug('@asha: websched :: time has been chosen, not null ' + inTime3);
     if(thirddaydisplay != null){
     system.debug('@asha: websched :: time has been chosen, date is not null ' + thirddaydisplay);
      if(thirddaydisplayA != null){   
              if(thirddtdisplay != null){
         beforeconfirm = thirddaydisplayA + ', '+thirddaydisplay + ' @ '+ inTime3;
            String fulldate = thirddtdisplay.month()+ '/' + thirddtdisplay.day() + '/' + thirddtdisplay.year() + ' ' + inTime3;
            Datetime d = Datetime.parse(fulldate);
            newdatetime  = datetime.newInstance(d.date(),d.time());
                      notime = false;
     }
     }
     }
     }
    return null;
 
 }
 
  public PageReference datetimechosen4(){

     if(inTime4 != null){
      system.debug('@asha: websched :: time has been chosen, not null ' + inTime4);
     if(fourthdaydisplay != null){
     system.debug('@asha: websched :: time has been chosen, date is not null ' + fourthdaydisplay);
        if(fourthdaydisplayA != null){
        if(fourthdtdisplay != null){
         beforeconfirm = fourthdaydisplayA + ', '+ fourthdaydisplay + ' @ '+ inTime4;
            String fulldate = fourthdtdisplay.month()+ '/' + fourthdtdisplay.day() + '/' + fourthdtdisplay.year()  + ' ' + inTime4;
        Datetime d = Datetime.parse(fulldate);
        newdatetime  = datetime.newInstance(d.date(),d.time());
          notime = false;
      }
     }
     }
     }
    return null;
 
 }

public PageReference newchooser(){
 if(newdatetime != null){
    return makeAppointment(newdatetime);
   }
  notime = true;
  return null;     
}
 
public Map<datetime,list<string>> settheorder(Map<datetime,boolean> nmap, List<datetime> listdt){
List<String> opts = new List<String>();
List<String> opts2 = new List<String>();
List<String> opts3 = new List<String>();
List<String> opts4 = new List<String>();

//temp datetimes
datetime theday = datetime.now();
datetime theday2 = theday.adddays(1);
datetime theday3 = theday.adddays(2);
datetime theday4 = theday.adddays(3);

Set<datetime> newset = nmap.keyset();
List<datetime> daytemp = new List<datetime>();
if(listdt.size() >= 4 ){
theday = listdt[0];
theday2 = listdt[1];
theday3 = listdt[2];
theday4 = listdt[3];
}


Map<datetime,list<string>> thedtmap = new Map<datetime,list<string>>();
time mnight = time.newInstance(0,0,0,0);
time oneam = time.newInstance(1,30,0,0);
    if(newset.size() > 0){
        Integer i = 0;
        daytemp.addAll(newset);    
        daytemp.sort();
   /*     theday = daytemp[0];
            for(datetime d : daytemp){
                if( nmap.get(d)){
                    if( i == 0){
                        theday = d;
                        opts.add(d.format('h:mm a'));
                        i++;
                    }
                    else{
    */                 
                      /*  if((d.dateGMT() == theday.dateGMT()) || (d.dateGMT() == theday.adddays(1).dateGMT() && d.timeGMT() > mnight && d.timeGMT() < oneam)){
                           // if( d.formatGMT('EEEEE') == theday.formatGMT('EEEEE')){
                                opts.add(d.format('h:mm a'));
                                
                            }
                            else{
                                thedtmap.put(theday,opts);
                                opts.clear();
                                theday = d;
                                opts.add(d.format('h:mm a'));
                                i++;
                            }  
                     */      
      /*          if(i == 1){
                    if((d.dateGMT() == theday.dateGMT()) || (d.dateGMT() == theday.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                           // if( d.formatGMT('EEEEE') == theday.formatGMT('EEEEE')){
                                opts.add(d.format('h:mm a'));
                                
                            }
                            else{
                                theday2 = d;
                                opts2.add(d.format('h:mm a'));
                                i++;
                            }  
                }
                if(i == 2){
                    if((d.dateGMT() == theday.dateGMT()) || (d.dateGMT() == theday.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                           // if( d.formatGMT('EEEEE') == theday.formatGMT('EEEEE')){
                                opts.add(d.format('h:mm a'));
                                
                            }
                            else{
                                    if((d.dateGMT() == theday2.dateGMT()) || (d.dateGMT() == theday2.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                        opts2.add(d.format('h:mm a'));
                                    }
                                    else{
                                        theday3 = d;
                                        opts3.add(d.format('h:mm a'));
                                        i++;
                                    }  
                            }  
                }
                if(i == 3){
                    if((d.dateGMT() == theday.dateGMT()) || (d.dateGMT() == theday.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                           // if( d.formatGMT('EEEEE') == theday.formatGMT('EEEEE')){
                                opts.add(d.format('h:mm a'));                                
                            }
                            else{
                                    if((d.dateGMT() == theday2.dateGMT()) || (d.dateGMT() == theday2.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                        opts2.add(d.format('h:mm a'));
                                    }
                                    else{
                                        if((d.dateGMT() == theday3.dateGMT()) || (d.dateGMT() == theday3.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                            opts3.add(d.format('h:mm a'));
                                        }
                                        else{
                                            theday4 = d;
                                            opts4.add(d.format('h:mm a'));
                                            i++;
                                        }    
                                    }  
                            }  
                }
                if(i == 4){
                    if((d.dateGMT() == theday.dateGMT()) || (d.dateGMT() == theday.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                           // if( d.formatGMT('EEEEE') == theday.formatGMT('EEEEE')){
                                opts.add(d.format('h:mm a'));                                
                            }
                            else{
                                    if((d.dateGMT() == theday2.dateGMT()) || (d.dateGMT() == theday2.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                        opts2.add(d.format('h:mm a'));
                                    }
                                    else{
                                        if((d.dateGMT() == theday3.dateGMT()) || (d.dateGMT() == theday3.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                            opts3.add(d.format('h:mm a'));
                                        }
                                        else{
                                            opts4.add(d.format('h:mm a'));
                                        }    
                                    }  
                            }  
                }  
               }
              }
             }*/
      for(datetime d : daytemp){
                if( nmap.get(d)){ 
                
                
                 if((d.dateGMT() == theday.dateGMT()) || ((d.dateGMT() == theday.adddays(1).dateGMT()) && (d.timeGMT() >= mnight) && (d.timeGMT() <= oneam))){
                                opts.add(d.format('h:mm a'));                                
                            }
                 else{
                                    if((d.dateGMT() == theday2.dateGMT()) || ((d.dateGMT() == theday2.adddays(1).dateGMT()) && (d.timeGMT() >= mnight && d.timeGMT() <= oneam))){
                                        opts2.add(d.format('h:mm a'));
                                    }
                                    else{
                                        if((d.dateGMT() == theday3.dateGMT()) || ((d.dateGMT() == theday3.adddays(1).dateGMT()) && (d.timeGMT() >= mnight) && (d.timeGMT() <= oneam))){
                                            opts3.add(d.format('h:mm a'));
                                        }
                                        else{
                                        if((d.dateGMT() == theday4.dateGMT()) || (d.dateGMT() == theday4.adddays(1).dateGMT() && d.timeGMT() >= mnight && d.timeGMT() <= oneam)){
                                              opts4.add(d.format('h:mm a'));
                                              }
                                        }    
                                    }  
                     }  
                  
               }
       }                
             

    }
                                thedtmap.put(theday,opts);
                                thedtmap.put(theday2,opts2);
                                thedtmap.put(theday3,opts3);
                                thedtmap.put(theday4,opts4);
    return thedtmap;
    
} 
 
 

}