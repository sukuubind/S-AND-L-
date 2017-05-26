public class OpportunityUtilities {
    
	private static boolean cacheloaded = false;
    private static ID idStudentOppRecordType = null;
    private static ID idSRPOppRecordType = null;
    Public static ID idNurtureUser = null;
    
    Public static boolean IsStudentOppRecordTypeErrorTest = false;
    Public static boolean IsSRPOppRecordTypeErrorTest = false;
    
     
    public static ID getStudentOppRecordType(){
        If(cacheloaded){
            return idStudentOppRecordType;
        }
        cacheOppSettings();
        return idStudentOppRecordType;
    }
    
    public static ID getSRPOppRecordType(){
        If(cacheloaded){
            return idSRPOppRecordType;
        }
        cacheOppSettings();
        return idSRPOppRecordType;
    }
    
    public static ID getNurtureUserID(){
        If(cacheloaded){
            return idNurtureUser;
        }
        cacheOppSettings();
        return idNurtureUser;
    }
    
    public static void cacheOppSettings(){
        //This function queries and caches related record types
        if(cacheloaded){
            return;
        }
        //Cache Record Types
        List<RecordType> rtypes = [SELECT Name, DeveloperName, Id FROM RecordType WHERE sObjectType='Opportunity' AND isActive=true];
        for(RecordType rt: rtypes){
            if(rt.DeveloperName == 'Student_Opportunity'){
                idStudentOppRecordType = rt.Id;
            }
            if(rt.DeveloperName == 'SRP_Opportunity'){
                idSRPOppRecordType = rt.Id;
            }
        }
        //TODO: Create New customException Type
        
        if(idStudentOppRecordType == null || IsStudentOppRecordTypeErrorTest){
            throw new customException('Opportunity: Student_Opportunity Record Type could not be found');
        }
        if(idSRPOppRecordType == null || IsSRPOppRecordTypeErrorTest){
            throw new customException('Opportunity: SRP_Opportunity Record Type could not be found');
        }
        
        //Load custom settings
        Opportunity_Settings__c mcsOpp = Opportunity_Settings__c.GetInstance();
        //It can be set from outside for testing
        //system.debug('idNurtureUser: ' + idNurtureUser);
        if (idNurtureUser == null){
            if(mcsOpp.NurtureUserID__c == null){
                //mcsOpp = Opportunity_Settings__c.getOrgDefaults();
                //system.debug('mcsOpp: ' + mcsOpp);
                throw new customException('Custom Setting for "Opportunity_Settings__c.NurtureUserID__c" is not set.');
            }else{
                idNurtureUser = (ID)mcsOpp.NurtureUserID__c; 
            }
        }

        cacheloaded = true;

    }
    
}