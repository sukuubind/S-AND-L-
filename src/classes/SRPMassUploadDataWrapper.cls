public with sharing class SRPMassUploadDataWrapper {
	   public String isSRPRecord {get; set;}                    
	   public String RFICampaigncode {get; set;}   
	   public String inquiryrating {get; set;}                 
	   public String Source {get; set;}  
	   public String leadSource {get; set;}     
	   public String AccountID {get; set;} 
	   public String lastname {get; set;} 
	   public String firstname {get; set;} 
	   public String title {get; set;}  
	   public String company {get; set;} 
	   public String street {get; set;} 
	   public String city {get; set;} 
	   public String state {get; set;} 
	   public String country {get; set;} 
	   public String postalcode {get; set;}
	   public String homephone {get; set;} 
	   public String workphone {get; set;} 
	   public String email {get; set;} 
	   public String AcademicProgram {get; set;} 
	   public String ownerid {get; set;} 
	   public String mobilephone {get; set;}
	   
	   public SRPMassUploadDataWrapper(String isSRPRec, String RFICampCode, String src, String leadSrc,
	   	String AcctId, String lname, String fname, String tit, String comp, string strt, string cty, string stt,
	   	String ctry, string postcode, string hphone, string wphone, string em, string acadprog, string oid, string iqrat,
	   	String mphone
	   	){
	   		isSRPRecord = isSRPRec;
	   		RFICampaigncode = RFICampCode;
	   		source = src;
	   		leadSource = leadsrc;
	   		accountid = acctid;
	   		lastname = lname;
	   		firstname = fname;
	   		title = tit;
	   		company = comp;
	   		street = strt;
	   		city = cty;
	   		state = stt;
	   		country = ctry;
	   		postalcode = postcode;
	   		homephone = hphone;
	   		workphone = wphone;
	   		mobilephone = mphone;
	   		email = em;
	   		academicprogram = acadprog;
	   		ownerid = oid;
	   		inquiryrating = iqrat;
	   }
}