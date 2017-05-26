/***************************************************************************

Description : An Apex REST service to that supports the following 
operations, related to insertion and retrieval of Cases :

1. GET /CaseId - Return the Response as instance of custom class called ResponseClass
- Reponse class return customized information which is match Record, CustomMessage, Error (if any)

2. POST/Case - Creates a new Case and insert records in the database.

***************************************************************************/
 
@RestResource(urlMapping='/CherwellCaseIntegration/*')
global class CherwellCodeRestAPI {
    
    //**************************************************
    //Private methods 
    //**************************************************




    
    
    //Check if Object is NULL or Blank
    global static boolean isNotNullOrEmpty(string str)
    {
        return str!=null || !String.isBlank(str); 
    }
    
    // Create a Case 
    public static Case createCase(String Origin, String Status, String OwnerID , String CherwellID, String AffliationName, String CallerName, String CallerPhone, String CallerEmail, String Priority, String CaseCategory,String Type,String SubType,string Course, string Instructor,String Subject,String Description,Boolean EscalatedToCampus,String EscalationCode,String Resolution,String ActivityType,String CaseCreation)
    {
    
    // For custom settings for Recordtypeid    
String E;
String F;

CherwellSettings__c  Csettings = CherwellSettings__c.getInstance();

if (Csettings != null){
E = Csettings.DeltakPSCSupportID__c;
F = Csettings.DeltakPSCSupportReadOnlyID__c;

}
Schema.DescribeSObjectResult describe = Schema.SObjectType.Case;
Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
System.Debug('recordTypes -- '+recordTypes);   
RecordTypeInfo rt = recordTypes.get('Deltak PSC Support');
E = rt.getRecordTypeId();

rt = recordTypes.get('Deltak PSC Support Read Only');
F = rt.getRecordTypeId();


//CherwellPSCRecordTypeID__c  Csettings = CherwellPSCRecordTypeID__c.getInstance('Deltak PSC Support');

//if (Csettings != null){
//E = Csettings.RecordTypeID__c;
//}


//CherwellPSCRecordTypeID__c  Csettings1 = CherwellPSCRecordTypeID__c.getInstance('Deltak PSC Support Read Only');

//if (Csettings1 != null){
//F = Csettings1.RecordTypeID__c;
//}
    
    
    
        //check if the fields provided on not empty
        if(isNotNullOrEmpty(Origin) && isNotNullOrEmpty(Status))
        {
            Case newCase = new Case();
            newCase.Origin = Origin;
            newCase.Status = Status;
            newCase.ownerid = OwnerID;
            newCase.Cherwell_Case_ID__c = CherwellID;
            newCase.Contactid = AffliationName;
            newCase.Caller_Name__c = CallerName;
            newCase.Caller_Phone_Number__c = CallerPhone;
            newCase.Caller_Email__c = CallerEmail;
            newCase.Priority = Priority;
            newCase.Case_Category__c = CaseCategory;
            newCase.Type = Type;
            newCase.Sub_Type__c = SubType;
            newCase.Course__c = Course;
            newCase.Instructor__c = Instructor;
            newCase.subject = Subject;
            newCase.Description = Description;
            newCase.Escalated_to_Campus__c = EscalatedToCampus;
            newCase.Escalation_Code__c = EscalationCode;
            newCase.Resolution__c = Resolution;
            newCase.Activity_Type__c = ActivityType;
            newCase.recordtypeid = E;
            newCase.Case_Creation__c = CaseCreation;
            
            
            
            
            
            
            
            
            //newCase.Email = email;
           // newCase.Phone=phone;
            return newCase;         
        }
        else 
        {
            System.Debug('Required field values are not provided here');
            return null;
        }
    }
    
    
    //====================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a new Case
    //====================================================================================
    @HttpPost
    global static ResponseHandlerCherwell post(String Origin, String Status, String OwnerID , String CherwellID, String AffliationName, String CallerName, String CallerPhone, String CallerEmail, String Priority, String CaseCategory,String Type,String SubType,string Course, string Instructor,String Subject,String Description,Boolean EscalatedToCampus,String EscalationCode,String Resolution,String ActivityType,String CaseCreation)
    {
        Case  newCase =  createCase( Origin,  Status,  OwnerID ,  CherwellID,  AffliationName, CallerName,  CallerPhone,  CallerEmail, Priority,  CaseCategory, Type, SubType,Course,  Instructor, Subject, Description, EscalatedToCampus, EscalationCode, Resolution, ActivityType, CaseCreation);
        ResponseHandlerCherwell response = new ResponseHandlerCherwell();
        try
        {
            insert newCase;
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)newCase);
            response.Data = thesObjectList;
            response.Status = 'Success';
            response.ErrorCode = null;
            response.Message = null;
        } 
        catch(Exception e) 
        {
            //Add custom error code when you could not insert a record
            response.ErrorCode = 'Error : Record not inserted';
            response.Status = 'error';
            response.Message = e.getMessage();
        }
        return response;   
    }
    
    
    //==============================================================================================
    // *** REST GET *** :  Requires the id of Case and reutrn results as Response Type
    //===============================================================================================
    @HttpGet 
    global static ResponseHandlerCherwell GET()
    {
        ResponseHandlerCherwell response = new ResponseHandlerCherwell();
        Case  returnCase = getCase();
        
        if(returnCase!=null)
        {
            response.Status = 'Success';
            response.ErrorCode = '';
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)returnCase);
            response.Data = thesObjectList;
            response.Message = 'Success : Found Case';
        }
        
        else
        {
            response.ErrorCode = 'Error Case Not Found';
            response.Status = 'error';
            response.Message = 'Fail : Ahh, Case Not Found';
            
        }
        
        return response;
    }
    
    //Adding custom Exception sub-class 
    public class NoRecordMatchException extends Exception {}
    
    public static Case getCase()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String CaseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        Case result;
        try{
            result = [SELECT Id, Status,Origin FROM Case WHERE Id = :CaseId];
        }
        Catch(System.QueryException e)
        {
            //Add custom exception dynamically to the ErrorMap
            throw new NoRecordMatchException('Unable to find the record maching Id : '+CaseId);
        }
        return result;
    }
    
    
 // Update  a Case 
   public static Case UpdateCase(String Origin, String Status, String OwnerID , String CherwellID, String AffliationName, String CallerName, String CallerPhone, String CallerEmail, String Priority, String CaseCategory,String Type,String SubType,string Course, string Instructor,String Subject,String Description,Boolean EscalatedToCampus,String EscalationCode,String Resolution,String ActivityType,String CaseCreation)
    {
    
    
    // For custom settings for Recordtypeid    
String E;
String F;

CherwellSettings__c  Csettings = CherwellSettings__c.getInstance();

if (Csettings != null){
E = Csettings.DeltakPSCSupportID__c;
F = Csettings.DeltakPSCSupportReadOnlyID__c;

}

Schema.DescribeSObjectResult describe = Schema.SObjectType.Case;
Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
System.Debug('recordTypes -- '+recordTypes);   
RecordTypeInfo rt = recordTypes.get('Deltak PSC Support');
E = rt.getRecordTypeId();

rt = recordTypes.get('Deltak PSC Support Read Only');
F = rt.getRecordTypeId();
//System.Debug('E -- '+E);

//CherwellPSCRecordTypeID__c  Csettings = CherwellPSCRecordTypeID__c.getInstance('Deltak PSC Support');

//if (Csettings != null){
//E = Csettings.RecordTypeID__c;
//}


//CherwellPSCRecordTypeID__c  Csettings1 = CherwellPSCRecordTypeID__c.getInstance('Deltak PSC Support Read Only');

//if (Csettings1 != null){
//F = Csettings1.RecordTypeID__c;
//}
    
    
    
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String CaseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
    if(CaseId != null){
    Case newCase = new Case();
    newCase.id = CaseId;
    newCase.Origin = Origin;
            newCase.Status = Status;
            newCase.ownerid = OwnerID;
            newCase.Cherwell_Case_ID__c = CherwellID;
           newCase.Contactid = AffliationName;
            newCase.Caller_Name__c = CallerName;
            newCase.Caller_Phone_Number__c = CallerPhone;
            newCase.Caller_Email__c = CallerEmail;
            newCase.Priority = Priority;
            newCase.Case_Category__c = CaseCategory;
            newCase.Type = Type;
            newCase.Sub_Type__c = SubType;
            newCase.Course__c = Course;
            newCase.Instructor__c = Instructor;
            newCase.subject = Subject;
            newCase.Description = Description;
            newCase.Escalated_to_Campus__c = EscalatedToCampus;
            newCase.Escalation_Code__c = EscalationCode;
            newCase.Resolution__c = Resolution;
            newCase.Activity_Type__c = ActivityType;
            newCase.recordtypeid = E;
            newCase.Case_Creation__c = CaseCreation;
 
 
 // Code for attachment added here
    
    Attachment a = new Attachment();
    a.ParentID = newCase.id;
    a.Name = 'Test.png';
    a.Body = req.requestBody;
    
    if(req.requestBody != null){
    insert a;
    }
 // Code for attachment ends here   
    

    return newCase;
    }
     else
     {
      System.Debug('No matching ID found in the System');
            return null;     
        }
       
    }





@HttpPut
    global static ResponseHandlerCherwell put(String Origin, String Status, String OwnerID , String CherwellID, String AffliationName, String CallerName, String CallerPhone, String CallerEmail, String Priority, String CaseCategory,String Type,String SubType,string Course, string Instructor,String Subject,String Description,Boolean EscalatedToCampus,String EscalationCode,String Resolution,String ActivityType, String CaseCreation)
    {
    
    ResponseHandlerCherwell response = new ResponseHandlerCherwell();
     Case  newCase =  UpdateCase( Origin,  Status,  OwnerID ,  CherwellID,  AffliationName, CallerName,  CallerPhone,  CallerEmail, Priority,  CaseCategory, Type, SubType, Course,  Instructor, Subject, Description, EscalatedToCampus, EscalationCode, Resolution, ActivityType,CaseCreation);
        
        if(newCase != null) {
        try
        
        {
            update newCase;
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)newCase);
            response.Data = thesObjectList;
            response.Status = 'Success';
            response.ErrorCode = null;
            response.Message = null;
        } 
        catch(DmlException e) 
        {
            //Add custom error code when you could not insert a record
            response.ErrorCode = 'Error : Record not inserted';
            response.Status = 'error';
            response.Message = e.getMessage();
        
        
        }}
        return response; 
  }
    
   }