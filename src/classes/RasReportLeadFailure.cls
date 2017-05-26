public with sharing class RasReportLeadFailure {
    
    public string errorMessage {get;set;}
    
    public RasReportLeadFailure(){
         errorMessage = '';
    }
    public Id createFailureRecord(LeadProcessor.LP_Person lp_pers, 
                                  LeadProcessor.LP_Affiliaiton lp_affl, 
                                  LeadProcessor.LP_Opportunity lp_oppty, 
                                  LeadProcessor.LP_Failure lp_fail
                                  ){
        Lead_Failure__c lead_fail = new Lead_Failure__c();
        lead_fail.Program__c = lp_oppty.Program;
        lead_fail.Program2__c = lp_oppty.Program2;
        lead_fail.Key1__c = lp_oppty.Key1;
        lead_fail.Key2__c = lp_oppty.Key2;
        lead_fail.Key5__c = lp_oppty.Key5;
        lead_fail.R_Campaign__c = lp_oppty.R_Campaign;
        lead_fail.Source__c = lp_oppty.Source;
        lead_fail.Company__c = lp_oppty.Company;
        lead_fail.Referal__c = lp_oppty.Referal;
        lead_fail.UrefKeyWrd__c = lp_oppty.UrefKeyWrd;
        lead_fail.UADCampgn__c = lp_oppty.UADCAMPGN;
        lead_fail.UINTLead__c = lp_oppty.UINTLEAD;
        lead_fail.urefurl__c = lp_oppty.urefurl;
        lead_fail.errorMessage__c = lp_fail.failureDescription;
        lead_fail.Lead_Failure_Type__c = lp_fail.failure;
       // lead_fail.notes__c = addedFields.notes;        
        lead_fail.uhowheard__c = lp_oppty.uhowheard;
        lead_fail.udescribe__c = lp_oppty.udescribe;
        lead_fail.filename__c = lp_oppty.filename;
        lead_fail.uhscode__c = lp_oppty.uhscode;
        lead_fail.UOptOutCam__c = lp_oppty.UOptOutCam;
        lead_fail.UCAMPGNTYP__c = lp_oppty.UCAMPGNTYP;
        lead_fail.utextperm__c = lp_affl.utextperm;
        lead_fail.phone3__c = lp_affl.phone3;
        lead_fail.ucampus__c = lp_oppty.ucampus;
        lead_fail.urefrdby__c = lp_oppty.urefrdby;
        lead_fail.Other_Colleges__c = lp_oppty.Other_Colleges;
        
        lead_fail.GMId__c =String.valueOf(lp_oppty.GMId);
        lead_fail.ContactName__c= lp_Pers.ContactName;
        lead_fail.Address1__c= lp_affl.Address1;
        lead_fail.Address2__c=lp_affl.Address2;
        lead_fail.City__c= lp_affl.City;
        lead_fail.State__c= lp_affl.State;
        lead_fail.Province__c= lp_affl.Province;    //@AbhaS - related to Columbia Updates - 12/07/2012
        lead_fail.Country__c= lp_affl.Country;      //@AbhaS - related to Columbia Updates - 11/19/2012
        lead_fail.Zip__c= lp_affl.Zip;
        lead_fail.Phone1__c= lp_affl.Phone1;
        lead_fail.Phone2__c= lp_affl.Phone2;
        lead_fail.Email__c= lp_affl.Email;
        lead_fail.Gender__c=lp_affl.Gender;
        lead_fail.BestTime__c= lp_affl.BestTime;
        lead_fail.Program__c= lp_oppty.Program;
        lead_fail.CourseInterest__c=lp_oppty.CourseInterest; 
        lead_fail.HSGradYear__c= lp_affl.HSGradYear;
        lead_fail.newKey5__c=lp_affl.newKey5;
        lead_fail.DateCreated__c= String.valueOf(lp_oppty.DateCreated);
        lead_fail.HighLevel__c= lp_oppty.HighLevel;
        lead_fail.newKey4__c= lp_oppty.newKey4;
        lead_fail.Company__c= lp_oppty.Company;
        lead_fail.Title__c=lp_affl.Title;
        lead_fail.Source__c= lp_oppty.Source;
        lead_fail.UModality__c= lp_oppty.UModality;
        lead_fail.UIMType__c= lp_oppty.UIMType;
        lead_fail.UIMName__c= lp_oppty.UIMName;
        lead_fail.RasId__c= lp_pers.RasId;
        lead_fail.OwnerId__c= lp_oppty.OwnerId;
        lead_fail.referredByOpportunity__c= lp_oppty.referredByOpportunity;
        lead_fail.referredByPerson__c= lp_oppty.referredByPerson;
        lead_fail.TransferredFromOpportunity__c=lp_oppty.TransferredFromOpportunity;
        lead_fail.Duplicate_Opportunity__c = false;
        insert lead_fail;
        
        return lead_fail.id;
    }
    public Id createFailureRecord(
     
     String GMId,String ContactName, String Address1, 
     String Address2,String City, String State,
     String Zip, String Phone1, String Phone2, 
     String Email,String Gender,String BestTime, 
     String Program, String CourseInterest,String HSGradYear, 
     String newKey5,String DateCreated, String HighLevel, 
     String newKey4, String Company, String Title,
     String Source, String UModality,String UIMType, 
     String UIMName, String RasId, String OwnerId, 
     String referredByOpportunity, String referredByPerson, 
     String TransferredFromOpportunity,Boolean duplicateOpportunity,
     LeadProcessor.LeadRouter_AdditionalFields addedFields
     ){
        Lead_Failure__c lead_fail = new Lead_Failure__c();
        lead_fail.Program__c = addedFields.Program;
        lead_fail.Program2__c = addedFields.Program2;
        lead_fail.Key1__c = addedFields.Key1;
        lead_fail.Key2__c = addedFields.Key2;
        lead_fail.Key5__c = addedFields.Key5;
        lead_fail.R_Campaign__c = addedFields.R_Campaign;
        lead_fail.Source__c = addedFields.Source;
        lead_fail.Company__c = addedFields.Company;
        lead_fail.Referal__c = addedFields.Referal;
        lead_fail.UrefKeyWrd__c = addedFields.UrefKeyWrd;
        lead_fail.UADCampgn__c = addedFields.UADCAMPGN;
        lead_fail.UINTLead__c = addedFields.UINTLEAD;
        lead_fail.urefurl__c = addedFields.urefurl;
        lead_fail.errorMessage__c = errorMessage;
       // lead_fail.notes__c = addedFields.notes;        
        lead_fail.uhowheard__c = addedFields.uhowheard;
        lead_fail.udescribe__c = addedFields.udescribe;
        lead_fail.filename__c = addedFields.filename;
        lead_fail.uhscode__c = addedFields.uhscode;
        lead_fail.UOptOutCam__c = addedFields.UOptOutCam;
        lead_fail.UCAMPGNTYP__c = addedFields.UCAMPGNTYP;
        lead_fail.utextperm__c = addedFields.utextperm;
        lead_fail.phone3__c = addedFields.phone3;
        lead_fail.ucampus__c = addedFields.ucampus;
        lead_fail.urefrdby__c = addedFields.urefrdby;
        lead_fail.Other_Colleges__c = addedFields.Other_Colleges;
        
        lead_fail.GMId__c =GMId;
        lead_fail.ContactName__c= ContactName;
        lead_fail.Address1__c= Address1;
        lead_fail.Address2__c=Address2;
        lead_fail.City__c= City;
        lead_fail.State__c= State;
        //lead_fail.Country__c = Country;//@AbhaS - related to Columbia Updates - 11/19/2012
        lead_fail.Zip__c= Zip;
        lead_fail.Phone1__c= Phone1;
        lead_fail.Phone2__c= Phone2;
        lead_fail.Email__c= Email;
        lead_fail.Gender__c=Gender;
        lead_fail.BestTime__c= BestTime;
        lead_fail.Program__c= Program;
        lead_fail.CourseInterest__c=CourseInterest; 
        lead_fail.HSGradYear__c= HSGradYear;
        lead_fail.newKey5__c=newKey5;
        lead_fail.DateCreated__c= DateCreated;
        lead_fail.HighLevel__c= HighLevel;
        lead_fail.newKey4__c= newKey4;
        lead_fail.Company__c= Company;
        lead_fail.Title__c=Title;
        lead_fail.Source__c= Source;
        lead_fail.UModality__c= UModality;
        lead_fail.UIMType__c= UIMType;
        lead_fail.UIMName__c= UIMName;
        lead_fail.RasId__c= RasId;
        lead_fail.OwnerId__c= OwnerId;
        lead_fail.referredByOpportunity__c= referredByOpportunity;
        lead_fail.referredByPerson__c= referredByPerson;
        lead_fail.TransferredFromOpportunity__c=TransferredFromOpportunity;
        lead_fail.Duplicate_Opportunity__c = duplicateOpportunity;
        insert lead_fail;
        
        return lead_fail.id;
    }
    
    public Id notifyFailure(String errorType, String message, Id lead_failure){
        Case thisCase  = new Case();
        thisCase.Status = 'New';
        thisCase.Type = errorType;
        thisCase.Subject = 'Lead Processor Error';
        thisCase.Description = message;
        thisCase.OwnerId = UserInfo.getUserId();
        if(lead_FAILURE != null)
            thisCase.Lead_Failure__c = lead_failure;
        insert thisCase;
        
        return thisCase.Id;
        
    }
    /**public void notifyCIFailure(List<String> message, List<Id> ci_failure){
       List<Case> caseList = new List<Case>();  
       Integer i = 0;
        for(Id thisCiFailure : ci_failure){
            Case thisCase  = new Case();
            thisCase.Status = 'New';
            thisCase.Type = 'Goldmine Lead';
            thisCase.Subject = 'Class Integration Error in Salesforce';
            thisCase.Description = message.get(i);
            thisCase.OwnerId = UserInfo.getUserId();
            if(ci_failure != null)
               thisCase.Class_Integration_Aux__c = thisCiFailure;
            caseList.add(thisCase);
            i++;
        }
        insert caseList;
    }
    public List<Id> createCIFailureRecord(List<String> outputList, 
                                          List<RasClassIntegration.Person> personList,
                                          List<RasClassIntegration.ContactRecord> contactList,
                                          List<RasClassIntegration.RSI> rsiList){
        List<Id> ciFailure = new List<Id>();
        List<Class_Integration_Aux__c> classAuxList = new List<Class_Integration_Aux__c>();
        Integer count = 0;
        for(String thisString : outputList){
            if(!(thisString instanceof id)){
                RasClassIntegration.ContactRecord thisContactRecord = contactList.get(count);
                RasClassIntegration.Person thisPerson = personList.get(count);
                RasClassIntegration.RSI thisRSI = rsiList.get(count);
                
                Class_Integration_Aux__c ciaux = new Class_Integration_Aux__c();
                ciaux.Contact_AccountId__c = thisContactRecord.AccountId;
                ciaux.Contact_Birthdate__c = thisContactRecord.Birthdate;
                ciaux.Contact_Department__c = thisContactRecord.Department;
                ciaux.Contact_Email__c = thisContactRecord.Email;
                ciaux.Contact_FirstName__c = thisContactRecord.FirstName;
                ciaux.Contact_Gender__c = thisContactRecord.Gender;
                ciaux.Contact_LastName__c = thisContactRecord.LastName;
                ciaux.Contact_Mailing_City__c = thisContactRecord.Mailing_City;
                ciaux.Contact_Mailing_PostalCode__c = thisContactRecord.Mailing_PostalCode;
                ciaux.Contact_Mailing_State__c = thisContactRecord.Mailing_State;
                ciaux.Contact_Mailing_Street__c = thisContactRecord.Mailing_Street;
                ciaux.Contact_Mobile_Phone__c = thisContactRecord.Mobile_Phone;
                ciaux.Contact_OwnerId__c = thisContactRecord.OwnerId;
                ciaux.Contact_Phone__c = thisContactRecord.Phone;
                ciaux.Contact_RecordTypeId__c = thisContactRecord.RecordTypeId;
                ciaux.Contact_SSN__c = thisContactRecord.SSN;
                ciaux.Contact_SSN_Last_4__c = thisContactRecord.SSN_Last_4;
                ciaux.Contact_Student_Id__c = thisContactRecord.Student_Id;
                ciaux.Contact_Title__c = thisContactRecord.Title;
                ciaux.Contact_Work_Phone__c = thisContactRecord.Work_Phone;
                ciaux.External_Id__c = thisContactRecord.External_Id;
                
                ciaux.Person_FirstName__c = thisPerson.FirstName;
                ciaux.Person_LastName__c = thisPerson.LastName;
                ciaux.Person_RasId__c = thisPerson.RasId;
                
                ciaux.RSI_Application_Received__c = thisRSI.Application_Received;
                ciaux.RSI_Campus__c = thisRSI.Campus;
                ciaux.RSI_Course_Code__c = thisRSI.Course_Code;
                ciaux.RSI_Cumulative_GPA__c = thisRSI.Cumulative_GPA;
                ciaux.RSI_Drop_Date__c = thisRSI.Drop_Date;
                ciaux.RSI_Graduation_Date__c = thisRSI.Graduation_Date;
                ciaux.RSI_LDA__c = thisRSI.LDA;
                ciaux.RSI_Modality__c = thisRSI.Modality;
                ciaux.RSI_Program__c = thisRSI.Program;
                ciaux.RSI_Revised_Start_Date__c = thisRSI.Revised_Start_Date;
                ciaux.RSI_Schedule__c = thisRSI.Schedule;
                ciaux.RSI_Start_Date__c = thisRSI.Start_Date;
                ciaux.RSI_Student_Status__c = thisRSI.Student_Status;
                ciaux.RSI_UserName__c = thisRSI.UserName;
                
                classAuxList.add(ciaux);
                
            }
        count++;
        }
        Database.Upsertresult[] resultsList = Database.upsert(classAuxList, Class_Integration_Aux__c.External_Id__c, false);
        
        for(Database.Upsertresult thisResult : resultsList){
            ciFailure.add(thisResult.getId());
        }
        
        return ciFailure;
                                          }**/
    
    
}