public without sharing class Pre_Chat_Form_Controller {

public String errorMessages {get; set;}
public Boolean renderErrorMessages {get; set;}
public Boolean renderPreChatForm {get; set;}
public String endpoint {get; set;}

public String firstName {get; set;}
public String lastName {get; set;}
public String email {get; set;}
public String organization {get; set;}
public String organizationId {get; set;}
public String opportunityId {get; set;}

/** SRP-1512 to show modality and academic program for JHU AAP only **/
public String modality {get; set; }
public String academicProgram {get; set; }
public static final String PROGRAM_OF_INTEREST = 'Program of Interest'; 
public static final String MODALITY_CONSTANT = 'Modality'; 
public static final String ON_GROUND = 'On-Ground';
public static final String UNSURE = 'Unsure';
public static final String ONLINE = 'Online';

public List<selectOption> modalityList {get; set; }

 public PageReference refreshModalityList(){
     modalityList.clear();
        List<Academic_Specialization__c> specList = [Select Id, name, Spec_Title__c from Academic_Specialization__c where Academic_Program__c = :this.academicProgram];
    Set<String> modalitytoShow = new Set<String>();
    modalitytoShow.add(MODALITY_CONSTANT);
    for(Academic_Specialization__c thisSpec : specList){
        if(thisSpec.Name.contains('-G')){
            modalitytoShow.add(ON_GROUND);
        }else if(thisSpec.Name.contains('-NS')){
            modalitytoShow.add(UNSURE);
        }else if(thisSpec.Name.contains('-O')){
            modalitytoShow.add(ONLINE);
        }
    }
    for(String thisModality : modalitytoShow){
        modalityList.add(new SelectOption(thisModality, thisModality));
    }
     return null;
     }
     
     
     

/*
public List<SelectOption> getModalityList(){
    List<Academic_Specialization__c> specList = [Select Id, name, Spec_Title__c from Academic_Specialization__c where Academic_Program__c = :this.academicProgram];
    List<SelectOption> returnList = new List<SelectOption>();
    Set<String> modalitytoShow = new Set<String>();
    for(Academic_Specialization__c thisSpec : specList){
        if(thisSpec.Name.contains('-G')){
            modalitytoShow.add('Hybrid');
        }else if(thisSpec.Name.contains('-NS')){
            modalitytoShow.add('Unsure');
        }else if(thisSpec.Name.contains('-O')){
            modalitytoShow.add('Online');
        }
    }
    for(String thisModality : modalitytoShow){
        returnList.add(new SelectOption(thisModality, thisModality));
    }
    return returnList;
}*/

public Pre_Chat_Form_Controller() {
    modalityList   = new List<selectOption>();
    modalityList.add(new SelectOption(MODALITY_CONSTANT, MODALITY_CONSTANT));
    this.renderErrorMessages = false;
    this.endpoint = ApexPages.currentPage().getParameters().get('endpoint');
    this.renderPreChatForm = false;
}
public List<SelectOption> getAcademicPrograms(){ 
    this.organization = Label.JHU_Account_Name;
    List<SelectOption> returnList = new List<SelectOption>();
    List<Academic_Program__c> apList = [Select Id, Name,Program_Title__c from Academic_Program__c where School__r.Name = :this.organization and Active__c = true order by Program_Title__c Asc];
    returnList.add(new SelectOption(PROGRAM_OF_INTEREST, PROGRAM_OF_INTEREST));
    for(Academic_Program__c thisAp : apList){
        returnList.add(new SelectOption(thisAp.id, thisAp.Program_Title__c));
    }
    return returnList;
}

public PageReference checkInputs() {
    if(academicProgram != null && academicProgram == PROGRAM_OF_INTEREST){
        this.errorMessages = System.Label.Live_Chat_Program_of_Interest_Error;
        this.renderErrorMessages = true;
        return null;
    }
    if(modality != null && modality == MODALITY_CONSTANT){
        this.errorMessages = System.Label.Live_Chat_Modality_Error;
        this.renderErrorMessages = true;
        return null;
    }
    
    if(modality != null && modality == ON_GROUND){
        PageReference pg = Page.Ground_Johns_Hopkins_University_AAP; //new PageReference('http://google.com');
        pg.setRedirect(true);
        return pg;
    }
    if(this.email != null)
    {
        this.email = this.email.trim();
    }
    
    if(this.firstName == null || this.firstName == '' || this.firstName.trim().toLowerCase().replaceAll(' ','') == 'firstname' 
    || this.lastName == null || this.lastName == '' || this.lastName.trim().toLowerCase().replaceAll(' ','') == 'lastname' 
    || this.email == null || this.email.trim().toLowerCase().replaceAll(' ','') == 'email' || this.email == '')
    {
        this.errorMessages = System.Label.LiveChat_PreChat_Error;
        this.renderErrorMessages = true;
    }
    else if(!validateEmail(this.email))
    {
        this.errorMessages = System.Label.LiveChat_PreChat_Email_Error;
        this.renderErrorMessages = true;
    }
    else
    {
        System.debug('>--->' + this.organization);
        if(this.organization != null)
        {
            List<Opportunity> oppList = [SELECT Id, stageName, AccountId FROM Opportunity 
            WHERE Account.Abbreviation__c = :this.organization AND (Email__c = :this.email OR DeltakSRP__Email__c = :this.email OR DeltakSRP__Student__r.Email = :this.email) ORDER BY LastModifiedDate DESC];
            System.debug('>--->' + oppList);
            if(oppList.size() == 1)
            {
                this.opportunityId = ((String)oppList[0].Id).substring(0,((String)oppList[0].Id).length()-3);
                this.organizationId = oppList[0].AccountId;
                System.debug('>--->' + this.opportunityId);
            }
            else if(oppList.size() > 0 && oppList.size() > 1)
            {
                for(Opportunity currOpp : oppList)
                {
                    if((this.opportunityId == null || this.opportunityId == '') && currOpp.stageName != 'Dormant')
                    {
                        this.opportunityId = ((String)currOpp.Id).substring(0,((String)currOpp.Id).length()-3);
                        this.organizationId = currOpp.AccountId;
                    }
                }
                
                if(this.opportunityId == null || this.opportunityId == '')
                {
                    this.opportunityId = ((String)oppList[0].Id).substring(0,((String)oppList[0].Id).length()-3);
                    this.organizationId = oppList[0].AccountId;
                }
                
            }
            
        }
        
        
        this.renderPreChatForm = true;
        this.renderErrorMessages = false;
        
    }
    return null;
}

private static Boolean validateEmail(String email) {
    Boolean res = true;
        
    
    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>
    Pattern MyPattern = Pattern.compile(emailRegex);
    Matcher MyMatcher = MyPattern.matcher(email);

    if (!MyMatcher.matches()) 
        res = false;
    return res; 
    }

}