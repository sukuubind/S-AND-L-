public class emailtemplatecontroller{

public String dt {get;set;}
public String school {get;set;}
public String pmname {get;set;}
public String shortpmname {get;set;}
public String firstpmname {get;set;}
public String opp {get;set;}

public emailtemplatecontroller(){
    dt = '';
    school = '';
    pmname = '';
    shortpmname = '';
    firstpmname = '';
    opp = '';

    dt = ApexPages.currentPage().getParameters().get('dt');
    pmname = ApexPages.currentPage().getParameters().get('pm');
    school = ApexPages.currentPage().getParameters().get('s');
    opp=ApexPages.currentPage().getParameters().get('opp');
    Integer intspace = pmname.indexOf(' ');
    Integer lenname = pmname.length()- 1;
    shortpmname = pmname.substring(0,1) + '.'+ pmname.substring(intspace,lenname);
    firstpmname = pmname.substring(0,intspace);
    
}

public static testmethod void sampleTest(){
    PageReference p = new PageReference('/apex/SJUEmailCancel?dt=Thu%2C+July+26%2C+2012+3%3A30+PM&opp=006W0000002RWG4IAO&pm=Asha+Calderon&s=Saint+Joseph%27s+University');
    Test.setCurrentPage(p);
    emailtemplatecontroller e = new emailtemplatecontroller();
    System.assert(e.opp == '006W0000002RWG4IAO', '@asha: emailtemplatecontroller: variable opp not as expected');
}

}