public class WebSchedulerUtils {

    public static Opportunity sendOpportunityData(ID pmid){
        List<Opportunity> opp = new List<Opportunity>();
        opp = [Select id,webschedulerstatus__c,cwschedappt__c, Program__r.Program_Title__c, ownerid, owner.name ,owner.Admissions_Email__c,owner.Admissions_Extension__c, accountid, account.name, account.Admissions_Phone__c ,Student_First_Name__c,Student_Last_Name__c,WebScheduler_Email__c, Email__c,Email_from_Student__c from Opportunity where id = :pmid Limit 1];
        System.debug('@asha web schedule utils : opportunity size is ' + opp.size() );
        return opp[0];
    }
    
    public static String userphoto(ID oppown){
        List<User> pmphoto = [select SmallPhotoUrl from User where Id =:oppown];
        
        return pmphoto[0].SmallPhotoUrl;
    }
    
    //added for deleting appointments through trigger
    public static void bulkCancelAppointment(List<Opportunity> opplist){
    Datetime enddt = datetime.now();
    List<Event> eventlist = [Select id, WhatID, StartDateTime, Event_Status__c from Event where  StartDateTime >= :enddt  and  type = 'Web Appointment' and WhatID in :opplist];
    System.debug('@asha: WebSchedulerUtils - Events pulled: '+eventlist.size()+' Opportunity list size: '+ opplist.size());
    if(eventlist.size() > 0){

         List<Event> removelist = new List<Event>();
         for(Integer i = 0; i < opplist.size(); i++){
             Opportunity newRecord = opplist[i];
                  for(Event e: eventlist){
                     if((e.StartDateTime == newRecord.cwschedappt__c) && (newRecord.id == e.WhatID)){
                   //      System.debug('@asha: WebSchedulerUtils - adding to events to remove: ' + newRecord.cwschedappt__c);
                         removelist.add(e);
                         newRecord.cwschedappt__c = null;
                     }
                 }
         }        
         
         System.debug('@asha: WebSchedulerUtils - removing Events - list size :' + removelist.size());
         if( removelist.size() > 0 ){
             delete removelist;
         }
     }
    }
    
    public static Boolean cancelAppointment(Datetime sdt, ID oppid, ID oppown){
    
    //pull the list of events for that particular opportunity at that date & time to cancel
      List<Event> cancellist = [Select id,StartDateTime, Event_Status__c, subject, Successful__c, ShowAs, Result__c from Event where  StartDateTime = :sdt and  type = 'Web Appointment' and WhatID = :oppid And ownerid = :oppown];   
      if(cancellist.size() >0){
      /*for(Event cancelthis :cancellist){
      cancelthis.ShowAs = 'Free';
      cancelthis.Result__c = 'Canceled via Web Scheduler';
      cancelthis.Event_Status__c = 'Completed';
      cancelthis.subject = 'Web Scheduled Appointment - Canceled';
      
      //sdt = cancelthis.StartDateTime;
      }
      update cancellist;*/
      delete cancellist;
      }
      else{
        //show error page if issue cancelling
         System.debug('@asha: Web scheduler :: Issue finding event to cancel. ');
         return false;
      }
      return true;
    
    }
    
    public static Boolean updateOpportunity(ID oppid, String wsStatus, datetime d){
    
    try{
        Opportunity thisopp = [select id,webschedulerstatus__c,cwschedappt__c from Opportunity where id =: oppid ];
        thisopp.webschedulerstatus__c = wsStatus;
        thisopp.cwschedappt__c = d;
        update thisopp;
    } catch (Exception e) {
        //show error page if issue cancelling
          System.debug('@asha: Web scheduler ::  Issue finding updating appointment status. ');
           return false;
        }
        
        return true;    
    
    }
    
    public static Blob pullinEmailText(String x,String opp, datetime dt,String school, String pmname){
        String d = dt.format('EEE, MMMMM d, yyyy h:mm a');
        String pginfo = '/apex/'+x+'?dt='+d+'&pm='+pmname+'&s='+school+'&opp='+opp;
        PageReference p = new PageReference(pginfo);
        Blob emailcontent = p.getContent();

        return emailcontent;            
    }
    
    public static String findRecTypeID(){


    Schema.DescribeSObjectResult describeE = Schema.SObjectType.Event;
        List<Schema.RecordTypeInfo> eventInfos = describeE.getRecordTypeInfos();
        for(Schema.RecordTypeInfo eventInfo : eventInfos ) {
            // walk through the map to determine the correct record type
            if(eventInfo.getName() == 'Deltak_Student_Event') {
                // find the id for the deltak std event rectype
                System.debug('@asha: The RecordType :' +eventInfo.getName() + ' and the id: ' + eventInfo.getRecordTypeId() +' is available');
                return eventInfo.getRecordTypeID();
            }
        }
        
       return null; 
}

public static Boolean checkTimeAgain(datetime dt, ID oppown, ID opp){
    Datetime startarea = dt.adddays(-14);
 if(dt != null){  
    Datetime endarea = dt.adddays(14);
    
//first check to see that user did not wait more than 1 hours 30 mins to click on time.
//catch for past time and allows for some time to pass before user clicks the earliest available time
// but not enough so that user can let the time expire - 30 min window    
    Datetime timeout = datetime.now().addhours(1).addminutes(15);   
    if(dt < timeout ){
        //time has either passed or user waited too long to choose a time
        return true;
    }
    
    //delay query by 2 milliseconds
     Integer start = System.Now().millisecond();
        while(System.Now().millisecond()< start+2){ 
        }
//pull all events for to check and see if something got scheduled during that time period
    List<Event> newcheck = [Select ID, Type,WhatID,CreatedDate, ActivityDate, DurationInMinutes, EndDateTime, ISALLDAYEVENT, StartDateTime from Event
    Where EndDateTime >= :startarea and EndDateTime <= :endarea and ShowAs != 'Free' And ownerid = :oppown ];

    if(newcheck.size() > 0 ){
    Event earliest = newcheck[0];
    Integer flag = 0;
        //if there is an event in this time slot then check the eventtimes
        for(Event e: newcheck){
    //Datetime startevent = roundtofifteen(e.startdatetime);
    //Datetime endevent = roundtofifteen(e.enddatetime);
       Datetime startevent = e.startdatetime;
    Datetime endevent = e.enddatetime;
    if(e.IsAllDayEvent){
    //add 5 hours because that allows for daylight saving and actually starts the all day event during the day and doesnt
    //block off time before the day
        startevent = startevent.addhours(5);
        endevent = startevent.addhours(24);
    }
    //allow for 15 mins before event to 15 mins after event
   // Datetime actualevent = startevent;
   // startevent = startevent.addminutes(-30);
   // endevent = endevent.addminutes(15);
    System.debug('@asha: Event start= '+startevent+' end= '+ endevent);
       //cancel if a non-web appt was created while waiting
       if(e.Type != 'Web Appointment'){
            if(( (dt >= startevent) && (dt < endevent)) || ((dt.addminutes(30) > startevent) && (dt.addminutes(30) < endevent))){
                System.debug('@asha: chosen time is in Event slot: '+dt );
                return true;
            }
        }
       
       if(e.Type == 'Web Appointment'){
           if(( (dt >= startevent) && (dt < endevent)) || ((dt.addminutes(30)> startevent) && (dt.addminutes(30) < endevent))){
                System.debug('@asha: chosen time is in web appt Event slot: '+ e.startdatetime );
               if(flag == 0){
                   earliest = e;
                   flag++;
               }
               else{
                   //set the one that was created earliest to the earliest event stored variable
                   if(earliest.CreatedDate > e.CreatedDate){
                       earliest = e;
                   }
               }
               
          }
       } 
        
            
            
        }
        
        //check to see if the earliest event is the same one created now
        if((flag >0) && (earliest.WhatID != opp)){
            return true;
        }
        
        //return true;
    }
     //nothing found in that time period so time slot is available
    return false;
}
    //if dt is null then send user to sorry page
    return true;
}    
 
public static boolean addEvent(Datetime dt, Id oppid, ID oppown){
   String rectype = findRecTypeID();
    Event addthis = new Event();
     
   addthis.subject = 'Web Scheduled Appointment';
   addthis.WhatID = oppid;
   system.debug('@asha: Opportunity id '+ oppid );
   addthis.ActivityDate = dt.date(); //dont know if this really needs to be dateGMT or just date
   addthis.DurationInMinutes = 30; 
   addthis.EndDateTime = dt.addminutes(30);
   addthis.StartDateTime = dt;
   addthis.ShowAs = 'Busy';
   addthis.ownerid = oppown;
   addthis.Event_Status__c = 'Not Started';
   addthis.Type = 'Web Appointment';
   if(recType != null){
       addthis.RecordTypeId = rectype ;
       system.debug('@asha: record type id '+ rectype  );
   }
   
 //add event
   try{
       insert addthis;
   }catch (Exception e) {
        //show error page if issue scheduling
          System.debug('@asha: Web scheduler ::  Issue inserting appointment ');
          return false;   
        }
        
    return true;
} 


public static Attachment createICSFile(String icstext, ID oppid){


Blob icalfile = Blob.valueof('');
    icalfile = Blob.valueof(icstext);
  
            
 // create attachment with ics as body
Attachment icsAttachment = new Attachment( Body = icalfile
                                                     , Name = 'webappt.ics'
                                                     , ContentType = 'application/octet-stream'
                                                     , ParentId = oppid
                                                     );


   //insert icsAttachment;
   
   return icsAttachment;
   
   
   
   
   
}


public static datetime roundtofifteen(Datetime d){
//grab the minute of the date 
Integer currentmin = d.minute();

//round down to the 15 min periods

    //round to 0 if btw 0 and 14
    if(currentmin >= 0 && currentmin <= 14){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),0,0);

    }

//round to 15 if btw 15 and 29
    if(currentmin >= 15 && currentmin <= 29){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),15,0);

    }
    
    //round to 30 if btw 30 and 44
    if(currentmin >= 30 && currentmin <= 44){
        return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),30,0);

    }
    

    //otherwise at the end of the hr and round to 45 mins
    return datetime.newinstanceGMT(d.year(),d.month(),d.day(),d.hour(),45,0);

        
}

public static Map<datetime,boolean> findTheMapping(Integer c, Datetime fromhere, Datetime threedays, ID oppown){
//create a new map
Map<datetime,boolean> temptimemap = new Map<datetime,boolean>();

//create the start times and end times for the days    
//8 pm + 4 or 5 runs into the next day so must account for times from 0am to 1am
Integer overtime = (20 + c )- 24;
//multiday events span 14 days tops so search back 14 days from today for a possible end date
//and 14 days in future
datetime startarea = fromhere.adddays(-14);
datetime endarea = fromhere.adddays(14);
datetime endtime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(), 23,59,59);
datetime starttime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),fromhere.hour(),0,0);
datetime nextdaystart = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),9+c,0,0);
datetime nextdayend = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(), overtime,30,0);
Time startofday = starttime.timeGMT();
Time endofday = endtime.timeGMT();
Time startnextday = nextdaystart.timeGMT();
Time endnextday = nextdayend.timeGMT();
Time mdnight = time.newInstance(00,00,00, 00);
     //query all the events for the month
   List<Event> eventsfornext3days = [Select ID, IsAllDayEvent, WhatID, ActivityDate, DurationInMinutes, EndDateTime, StartDateTime, ShowAs from Event
    Where EndDateTime  >= :startarea and EndDateTime <= :endarea And ownerid = :oppown Order by StartDateTime ASC];
    
    //create a map of the available times in 15 min intervals for the day starting with 6a ending 4p
    //for the next 3 days 
    
    for(Datetime d = starttime; d <= threedays; d = d.addminutes(15)){

        if(d < fromhere){
            temptimemap.put(d,false);
        }
        else{
        
       //startnextday = 9am + conversion time to bring to gmt
       //endofday = 7.59p of that current day in edt/est because 8.30 gmt conversion is either 1.30a or 12.30a the next day
           if((d.timeGMT() >= startnextday && d.timeGMT() <= endofday) || (d.timeGMT() >= mdnight && d.timeGMT() <= endnextday )){
                temptimemap.put(d,true);
                System.debug('@asha: adding time slots datetime as true: ' +  d.format('MM.dd.yyyy h:mm a z'));
            }else{
                temptimemap.put(d,false);
                System.debug('@asha: adding time slots datetime as false: ' + d.format('MM.dd.yyyy h:mm a z'));
            }
        }
    }
   
   //go through the list of events for the next 3 days 
    for(Event e: eventsfornext3days){

    if(e.ShowAs != 'Free'){
    //round the dates down to the fifteen minute period
    Datetime startevent = roundtofifteen(e.startdatetime);
    Datetime endevent = roundtofifteen(e.enddatetime);
    if(e.IsAllDayEvent){
        endevent = startevent.addhours(24);
    }
    

    //check to make sure the end of the event is greater than the 15 min period
   //     if(startevent != endevent){
        
        // block out the time in the map - false is if the time is not available
            for (datetime de = startevent; de <= endevent; de = de.addminutes(15)){
                if(temptimemap.containskey(de)){
                    temptimemap.put(de,false);
                }
            }
        }
      }
  //  }



 return temptimemap;
}


public static Map<datetime,boolean> findTheMap(Datetime fromhere, Datetime threedays, ID oppown){
//create a new map
Map<datetime,boolean> temptimemap = new Map<datetime,boolean>();
//multiday events span 14 days tops so search back 14 days from today for a possible end date
//and 14 days in future
datetime startarea = fromhere.adddays(-14);
datetime endarea = fromhere.adddays(14);
//create the start times and end times for the days    
datetime endtime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),23,59,59);
datetime starttime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),fromhere.hour(),0,0);
datetime nextdaystart = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),0,0,0);
datetime nextdayend = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),0,30,0);
Time startofday = starttime.timeGMT();
Time endofday = endtime.timeGMT();
Time startnextday = nextdaystart.timeGMT();
Time endnextday = nextdayend.timeGMT();

     //query all the events for the month
   List<Event> eventsfornext3days = [Select ID, IsAllDayEvent, WhatID, ActivityDate, DurationInMinutes, EndDateTime, StartDateTime, ShowAs from Event
    Where EndDateTime  >= :startarea and EndDateTime <= :endarea And ownerid = :oppown Order by StartDateTime ASC];
     
    //create a map of the available times in 15 min intervals for the day starting with 6a ending 4p
    //for the next 5 days 
    
    for(Datetime d = starttime; d <= threedays; d = d.addminutes(15)){

        if(d < fromhere){
            temptimemap.put(d,false);
           System.debug('@asha: adding time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
        }
        else{
            temptimemap.put(d,true);
                System.debug('@asha: adding time slots datetime as true: ' + d.format('MM.dd.yyyy h:mm a z'));
        }
    }
   
   //go through the list of events for the next 3 days 
    for(Event e: eventsfornext3days){

    if(e.ShowAs != 'Free'){
    //round the dates down to the fifteen minute period
    //Datetime startevent = roundtofifteen(e.startdatetime);
    //Datetime endevent = roundtofifteen(e.enddatetime);
    //allow for 30 before and after event so that accounts for 30 min blocks
    //so that the time slot available before the event is 30mins before the start of the event
    Datetime startevent = e.startdatetime.addminutes(-15);
    Datetime endevent = e.enddatetime;
    
    if(e.IsAllDayEvent){
        startevent = startevent.addhours(5);
        endevent = startevent.addhours(24);
    }
    
    //check to make sure the end of the event is greater than the 15 min period
     //   if(startevent != endevent){
        
        // block out the time in the map - false is if the time is not available
            for (datetime de = startevent; de <= endevent; de = de.addminutes(15)){
                if(temptimemap.containskey(de)){
                    temptimemap.put(de,false);
                }
            }
        }
      }
   // }



 return temptimemap;
}

public static Map<datetime,boolean> startFromTuesday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for gmt
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Tuesday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //after 4pm mark as false
                      if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm )){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Tuesday'){
                  //before the current time+ 2 hrs mark as false
                      if(d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  if(theday == 'Saturday'){
                              newdtmap.put(d,false);
                  } 
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Tuesday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  }  
            
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromWednesday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       //if( theday == 'Monday' || theday == 'Saturday' || theday == 'Wednesday' || theday == 'Thursday' || theday == 'Friday'){
         if(theday != 'Sunday'){
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Wednesday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }                   
                   if(theday == 'Monday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Wednesday'){
                      if( d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }     
                  }       

                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                  
                  }
                   //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  } 
                  if(theday == 'Monday'){
                              newdtmap.put(d,false);
                  } 
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Wednesday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }     
                  }       
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  } 
                   if(theday == 'Monday'){
                       if(d.timeGMT() < nineam ) {
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }   
                  }      
                  if(theday == 'Tuesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }  
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}


public static Map<datetime,boolean> startFromThursday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
      // if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Thursday' || theday == 'Friday'){
        if(theday != 'Sunday'){  
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Thursday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
     
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }            
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                        
                   if(theday == 'Tuesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }   
                  if( theday == 'Wednesday'){
                      newdtmap.put(d,false);
                  }
                  
                               
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Thursday'){
                      if(d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
    

                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                   //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  } 
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                        
                   if(theday == 'Tuesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Thursday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
     
                  if(theday == 'Friday'){
                 //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam ) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  } 
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }         
                  if(theday == 'Wednesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }  
                
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromFriday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
      // if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Friday'){
        if(theday != 'Sunday'){  
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
           
                  if( theday == 'Friday'){
                      if((d.timeGMT() < nineam) || (d.timeGMT() < currenttime.addhours(2))|| (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }        
           
           
           
               //fridays are from 9a to 4.30p
               /*   if( theday == 'Friday'){
                  //before 9am mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam ) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                   */ 
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }  
                        
                   if(theday == 'Thursday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 1.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < twopm){
                  if( theday == 'Friday'){
                      if(d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > fourpm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
    

                  //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  } 
                //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }       
                   if(theday == 'Thursday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           
           }
           
           
           
           //after 1.30pm mark all times for Friday not available
            if(currenttime >= twopm){
            
                  if( theday == 'Friday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
     
                           //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  } 
                //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  } 
                  if(theday == 'Thursday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }  
                             
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}



public static Map<datetime,boolean> startFromSaturday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
   Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       //if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday'){
         if(theday != 'Sunday'){ 
           
            //before 10am then hours shown should be btw 10 and 3.30pm
           if(currenttime < tenam){

                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                      if( d.timeGMT() < tenam || d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > threepm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                      if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }
                  if(theday == 'Friday'){
                        newdtmap.put(d,false);
                                  
                  }  
                                  
           }
           
                    
           
           //btw 10am and 1.30pm mark  2hrs from current time as available
           if(currenttime >= tenam && currenttime < onepm){
                  if( theday == 'Saturday'){
                      if( d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > threepm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }
   
 
             //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                      if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }  
                  if(theday == 'Friday'){
                        newdtmap.put(d,false);
                                  
                  }         
           
           }
           
           
           
           //after 1.30pm mark all times for Saturday not available
            if(currenttime >= onepm){
            
                  if( theday == 'Saturday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }

                 //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                       if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }  
                 if(theday == 'Friday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }         
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromSunday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
   Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
  
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
      // if( theday == 'Monday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday'){
       if( theday != 'Sunday'){ 
                     //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                       if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }     
                  if(theday == 'Friday'){
                      if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }   
                


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromMonday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  
  //convert to gmt 
  Integer otime = (20 + convert) - 24;
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 - convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time mnight = Time.newInstance(0,0,0,0);
  Time endtime = time.newInstance(otime,30,0,0);
  Time morn = time.newInstance(23,59,59,59);
  
  //make negative to su
  convert = -convert;

    //get the current users time gmt
  Time currenttime = dt.timeGMT();
         System.debug('@asha: Start from Monday - The current time of the user is: ' + dt.format('EEEEE MM.dd.yyyy h:mm a z'));
       

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       System.debug('@asha: Start from Monday - The day is : ' +  d.format('EEEEE MM.dd.yyyy h:mm a z'));
       if( theday == 'Monday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Monday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                              System.debug('@asha:before 9am updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                      }
                  }
                  if(theday == 'Tuesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                               System.debug('@asha:before 9amupdating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                     
                      }
                  }       
                  if(theday == 'Wednesday'){
                       if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                               System.debug('@asha:before 9am updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                     
                      }                 
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                               System.debug('@asha:before 9am updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                     
                      }                 
                  }
                   if(theday == 'Friday'){
                       if(d.timeGMT() > endtime){
                              newdtmap.put(d,false);
                              System.debug('@asha:before 9am updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                     
                       }                                       
                  }
                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           //4pm est/edt is the cut off time for the days current time
           //if past 4pm send to the next day time period
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Monday'){
                  //set all the times up to 2 hrs after the current time as false
                      if(d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                   System.debug('@asha: btw 9-8.30 updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                     
                      }
                  }
                  if(theday == 'Tuesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                                                 System.debug('@asha: btw 9-8.30 updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                    
                      }
                  }       
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                                       System.debug('@asha:btw 9-8.30 updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                    
                      }               
                  }
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                                 System.debug('@asha:btw 9-8.30 updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                          
                      }                 
                  }
                  //if after 0.30am/ 1.30am then mark it as false
                  if(theday == 'Friday'){
                    if(d.timeGMT() > endtime){
                              newdtmap.put(d,false);
                            System.debug('@asha: btw 9-8.30 updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                              
                    }
                  }

           
           }
           
           
           
           //after 4pm mark all mon as not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Monday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);     
                             System.debug('@asha: after 4p updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                                                                       
                  }
                  if(theday == 'Tuesday'){
                      if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                       System.debug('@asha: after 4p updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                           
                      } 
                  }       
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                             System.debug('@asha: after 4p updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                                                         
                      }                
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                             System.debug('@asha: after 4p updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                                                         
                      }                
                  }
                  if(theday == 'Friday'){
                      if((d.timeGMT() < nineam && d.timeGMT() > endtime)|| (d.timeGMT()> fourpm )){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                              System.debug('@asha: after 4p updating time slots datetime as false: ' +  d.format('MM.dd.yyyy h:mm a z'));
                                                        
                      }                 
                  }
            
            }

       
           //       if(d.format('EEEEE') == 'Monday'){}
           //       if(d.format('EEEEE') == 'Tuesday'){}       
           //       if(d.format('EEEEE') == 'Wednesday'){}
           //       if(d.format('EEEEE') == 'Thursday'){}
         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}
    
/*public static Map<datetime,boolean> startFromTuesday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for gmt
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Tuesday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //after 4pm mark as false
                      if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm )){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Tuesday'){
                  //before the current time+ 2 hrs mark as false
                      if(d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  if(theday == 'Saturday'){
                              newdtmap.put(d,false);
                  } 
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Tuesday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
                  if(theday == 'Wednesday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  if(theday == 'Thursday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  }  
            
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromWednesday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Monday' || theday == 'Saturday' || theday == 'Wednesday' || theday == 'Thursday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Wednesday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }       
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }                   
                   if(theday == 'Monday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Wednesday'){
                      if( d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }     
                  }       

                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                  
                  }
                   //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  } 
                  if(theday == 'Monday'){
                              newdtmap.put(d,false);
                  } 
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Wednesday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
                  if(theday == 'Thursday'){
                      if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }     
                  }       
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  } 
                   if(theday == 'Monday'){
                       if(d.timeGMT() < nineam ) {
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }   
                  }      
            
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}


public static Map<datetime,boolean> startFromThursday(Map<datetime,boolean> dtmap, Integer convert,datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
   
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Thursday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
                  if( theday == 'Thursday'){
                      if(d.timeGMT() < nineam || d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
     
                  //fridays are from 9a to 4.30p
                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }            
                  }
                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                        
                   if(theday == 'Tuesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }                
           }
           
                    
           
           //btw 9am and 8.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < fourpm){
                  if( theday == 'Thursday'){
                      if(d.timeGMT() < currenttime.addhours(2)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
    

                  if(theday == 'Friday'){
                  //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam && d.timeGMT() > endtime) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                   //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  } 
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                        
                   if(theday == 'Tuesday'){
                   //blk out the times that dont correspond to mon est
                   //anything after 1.30/0.30am on Tues
                       if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }
           
           }
           
           
           
           //after 4pm mark all tues not available
            if(currenttime >= fourpm){
            
                  if( theday == 'Thursday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
     
                  if(theday == 'Friday'){
                 //if between (0.30am / 1.30a) to 9am then mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam ) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }               
                  }
                  if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  } 
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }         
            
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromFriday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
  Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Friday'){
          
           
            //before 9am then hours shown should be btw 9 and 8.30pm
           if(currenttime < nineam){
               //fridays are from 9a to 4.30p
                  if( theday == 'Friday'){
                  //before 9am mark as false
                  //if after 4 pm mark as false
                       if((d.timeGMT() < nineam ) || (d.timeGMT() > fourpm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }

                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                 
                  }
                  //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                        
                   if(theday == 'Wednesday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           }
           
                    
           
           //btw 9am and 1.30pm mark  2hrs from current time as available
           if(currenttime >= nineam && currenttime < twopm){
                  if( theday == 'Friday'){
                      if(d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > fourpm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
    

                  //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  } 
                //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                        
                   if(theday == 'Wednesday'){
                 
                              newdtmap.put(d,false);
                                  
                  }                
           
           }
           
           
           
           //after 1.30pm mark all times for Friday not available
            if(currenttime >= twopm){
            
                  if( theday == 'Friday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }
     
                           //saturdays are from 10a to 3.30p
                 if(theday == 'Saturday'){
                  //if less than 10am then mark as false
                  //if after 3 pm mark as false
                       if((d.timeGMT() < tenam ) || (d.timeGMT() > threepm)){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                   
                  } 
                //skip over Sun
                  if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }            
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}



public static Map<datetime,boolean> startFromSaturday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
   Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Monday' || theday == 'Saturday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday'){
          
           
            //before 10am then hours shown should be btw 10 and 3.30pm
           if(currenttime < tenam){

                  //saturdays are from 10a to 3.30p
                   if(theday == 'Saturday'){
                      if( d.timeGMT() < tenam || d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > threepm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }                
                  }
                  //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                      if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }                
           }
           
                    
           
           //btw 10am and 1.30pm mark  2hrs from current time as available
           if(currenttime >= tenam && currenttime < onepm){
                  if( theday == 'Saturday'){
                      if( d.timeGMT() < currenttime.addhours(2) || d.timeGMT() > threepm){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }    
                  }
   
 
             //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                      if(d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }           
           
           }
           
           
           
           //after 1.30pm mark all times for Saturday not available
            if(currenttime >= onepm){
            
                  if( theday == 'Saturday'){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);                    
                  }

                 //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                       if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }           
            }


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}

public static Map<datetime,boolean> startFromSunday(Map<datetime,boolean> dtmap, Integer convert, datetime dt){

  Map<datetime,boolean> newdtmap = dtmap;
  if(!dtmap.isEmpty()){
  Set<datetime> timeset = newdtmap.keySet();
   Time nineam = Time.newInstance(9 + convert, 0, 0, 0);
  Time tenam = Time.newInstance(10 + convert, 0, 0, 0);
  Time eightpm = Time.newInstance(20 + convert, 30, 0, 0);
  Time fourpm = Time.newInstance(16 + convert, 30, 0, 0);
  Time threepm = Time.newInstance(15 + convert, 30, 0, 0);
   Integer otime = (20 + convert) - 24;
   Time endtime = time.newInstance(otime,30,0,0);  
  
  Time onepm = Time.newInstance(13 + convert, 30, 0, 0);
  Time twopm = Time.newInstance(14 + convert, 30, 0, 0);
    
  
    //get the current users time for est
  Time currenttime = dt.timeGMT();

   for(datetime d : timeset){
       String theday = d.formatGMT('EEEEE');
       if( theday == 'Monday' || theday == 'Tuesday' || theday == 'Wednesday' || theday == 'Thursday'){
                     //skip over Sun
                       if( theday == 'Monday'){
                  //before 9am mark as false since no sun times should show
                       if(d.timeGMT() < nineam ){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      } 
                  }
                  if(theday == 'Tuesday'){
                  //mark btw 0.30/1.30am to 9am as not available
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }
                  if(theday == 'Wednesday'){
                      if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }
                  }      
                        
                   if(theday == 'Thursday'){
                       if(d.timeGMT() < nineam && d.timeGMT() > endtime){
                              //block out the time as not available in the map
                              newdtmap.put(d,false);
                      }             
                  }     
                   
    


         }else{
             newdtmap.put(d,false);         
         }
       
    } 
   } 
    
    
    return newdtmap;

}
*/
/*
public static Map<datetime,boolean> mapAllTimes(Datetime fromhere, Datetime threedays, ID oppown){
//create a new map
Map<datetime,boolean> temptimemap = new Map<datetime,boolean>();

//start time for creating the time map
datetime starttime = datetime.newInstanceGmt(fromhere.year(),fromhere.month(),fromhere.day(),fromhere.hour(),0,0);

     //query all the events for the next 3 days
   List<Event> eventsfornext3days = [Select ID, WhatID, ActivityDate, DurationInMinutes, EndDateTime, StartDateTime, ShowAs from Event
    Where Event_Status__c = 'Not Started' and StartDateTime  >= :fromhere and StartDateTime <= :threedays And ownerid = :oppown Order by StartDateTime ASC];
    
    //create a map of the available times in 15 min intervals for the day starting with 6a ending 4p
    //for the next 3 days 
    
    for(Datetime d = starttime; d <= threedays; d = d.addminutes(15)){
           temptimemap.put(d,true);
    }
   
   //go through the list of events for the next 3 days 
    for(Event e: eventsfornext3days){

    if(e.ShowAs != 'Free'){
    //round the dates down to the fifteen minute period
    Datetime startevent = roundtofifteen(e.startdatetime);
    Datetime endevent = roundtofifteen(e.enddatetime);

    //check to make sure the end of the event is greater than the 15 min period
        if(startevent != endevent){
        
        // block out the time in the map - false is if the time is not available
            for (datetime de = startevent; de <= endevent; de = de.addminutes(15)){
                if(temptimemap.containskey(de)){
                    temptimemap.put(de,false);
                }
            }
        }
      }
    }




 return temptimemap;
}*/
     
}