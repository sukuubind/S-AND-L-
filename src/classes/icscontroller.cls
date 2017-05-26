public class icscontroller{

public String dtstart {get;set;}
public String dtend {get;set;}
public String pmname {get;set;}
public string nospacename {get;set;}
public String pmemail {get;set;}
public String icstext {get;set;}

public icscontroller(){
    dtstart = ApexPages.currentPage().getParameters().get('dt');
    pmname = ApexPages.currentPage().getParameters().get('pm');
    pmemail = ApexPages.currentPage().getParameters().get('pme');
    dtend = ApexPages.currentPage().getParameters().get('dte');
    
    if(pmname != null){
       if(pmname != ''){ 
         nospacename = pmname.replace(' ','_');
       } 
    }
    //if(dtstart != null){
    //if(dtstart != ''){ 
    //Datetime newdt = datetime.newInstanceGMT(integer.valueOf(dtstart.substring(0,3)),integer.valueOf(dtstart.substring(4,5)),integer.valueOf(dtstart.substring(6,7)),integer.valueOf(dtstart.substring(9,10)),integer.valueOf(dtstart.substring(11,12)),integer.valueOf(dtstart.substring(12,13)));
    //Datetime newdtend = newdt.addminutes(30);
    //dtend = newdtend.formatGMT('yyyyMMdd')+'T'+ newdtend.formatGMT('HHmmss')+'Z\n';
    //}
    //}
    
String icstext = 'BEGIN:VCALENDAR\n';
icstext += 'VERSION:2.0\n'; 
icstext += 'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\n';
icstext += 'BEGIN:VEVENT\n';
icstext += 'UID:'+dtstart+pmemail+'\n';
icstext += 'DTSTAMP:'+dtstart +'\n';
icstext += 'ORGANIZER:'+pmname+':MAILTO:'+pmemail+'\n';
icstext += 'DTSTART:' +dtstart +'\n';
icstext += 'DTEND:' + dtend+'\n';
icstext += 'SUMMARY:Web Scheduled appointment with '+pmname+' \n';
icstext += 'END:VEVENT\n';
icstext += 'END:VCALENDAR\n';

    
    
}

public static testmethod void sampleTest(){
    PageReference p = new PageReference('/apex/WebAppt?dt=20120523T080000Z&dte=20120524T080000Z&pm=AshaCalderon&pme=asha.calderon@test.edu');
    Test.setCurrentPage(p);
    icscontroller e = new icscontroller();
    System.assert(e.pmemail == 'asha.calderon@test.edu', '@asha: icsontroller: variable pmemail not as expected');
}

}