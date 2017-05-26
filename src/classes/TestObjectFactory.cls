@isTest
public class TestObjectFactory {
    
    Public static List<DeltakSRP__Academic_Program__c> CreateAcademicProgram(Integer intCount, ID idInstitution){
        List<DeltakSRP__Academic_Program__c>  results = New List<DeltakSRP__Academic_Program__c> ();
        for (integer i=0; i<intCount; i++){
            results.add(new DeltakSRP__Academic_Program__c(Name = 'Test Program ' + i, DeltakSRP__School__c = idInstitution,DeltakSRP__SIS_External_Id__c='XYZ123'));
        }
        return results;
    }
    
    Public static List<DeltakSRP__Academic_Start_Date__c> CreateAcademicTerm(Integer intCount, ID idAcademicProgram, Date dateStartDate){
        List<DeltakSRP__Academic_Start_Date__c>  results = New List<DeltakSRP__Academic_Start_Date__c> ();
        for (integer i=0; i<intCount; i++){
            results.add(new DeltakSRP__Academic_Start_Date__c(DeltakSRP__Academic_Program__c = idAcademicProgram, DeltakSRP__Start_Date__c = dateStartDate,DeltakSRP__SIS_External_Id__c='SISEXTID123'+String.valueOf(dateStartDate)));
        }
        return results;
    }
    
    Public static List<DeltakSRP__Program_Enrollment__c> CreateProgramEnrollment(Integer intCount, ID idAcademicProgram, ID idContact, ID idAcademicTerm, String strEnrollmentStatus){
        List<DeltakSRP__Program_Enrollment__c>  results = New List<DeltakSRP__Program_Enrollment__c> ();
        for (integer i=0; i<intCount; i++){
            results.add(new DeltakSRP__Program_Enrollment__c(DeltakSRP__Academic_Program__c = idAcademicProgram,
                                                            DeltakSRP__SIS_External_Id__c = 'UOB1-123450-XYZ123', 
                                                             DeltakSRP__Enrolled_Student__c = idContact, DeltakSRP__Enrollment_Start__c = idAcademicTerm,
                                                             DeltakSRP__Enrollment_Status__c = strEnrollmentStatus));
        }
        return results;
    }
    
    Public static List<DeltakSRP__Enrollment_History__c> CreateEnrollmentHistory(Integer intCount, ID idAcademicProgram, ID idAcademicTerm ,ID idProgramEnrollment, ID studentID){
        List<DeltakSRP__Enrollment_History__c>  results = New List<DeltakSRP__Enrollment_History__c> ();
        for (integer i=0; i<intCount; i++){
            results.add(new DeltakSRP__Enrollment_History__c(DeltakSRP__Program__c = idAcademicProgram, 
                                                             DeltakSRP__Academic_Term2__c = idAcademicTerm, 
                                                             DeltakSRP__Program_Enrollment__c = idProgramEnrollment,
                                                             DeltakSRP__Student__c = studentID
                                                             ));
        }
        return results;
    }
    
    
    
    Public static List<Account> CreateAccount(Integer intCount){
        List<Account> results = New List<Account>();
        for (integer i=0; i<intCount; i++){
            results.add(new Account(Name = 'XYZ ' + i, Abbreviation__c='UOB'+i));
        }
        return results;
    }
    
    Public static List<Contact> CreateContact(Integer intCount){
        List<Contact> results = New List<Contact>();
        for (integer i=0; i<intCount; i++){
            results.add(new Contact(FirstName = 'Testy' + i, LastName = 'Testerson' + i,DeltakSRP__Student_Id__c='12345'+i));
        }
        return results;
    }
    
    
    
    public static List<Contact> CreateContact(Integer intCount, ID idAccount){
        List<Contact> results = New List<Contact>();
        for (integer i=0; i<intCount; i++){
            results.add(new Contact(FirstName = 'Contacty', 
                                 LastName = 'Contacterson' + String.valueOf(intCount),
                                 AccountID = idAccount,
                                 email = 'contacttest' + i + '@gmail.com',
                                 DeltakSRP__Student_Id__c='12345'+i));
        }
        return results;
    }
    
    Public static List<Opportunity> CreateOpportunity(Integer intCount, ID idAccount){
        List<Opportunity> results = new List<Opportunity>();
        for (integer i=0; i<intCount; i++){
            results.add(new Opportunity(Name = 'Opp' + 1, Description = 'Desc', StageName = 'New Inquiry', CloseDate = Date.Today(), AccountId = idAccount));
        }
        return results;
    }
}