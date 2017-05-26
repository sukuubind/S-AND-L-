public class MMSMSUIPermission {
    private static string SYSTEM_ADMINISTRATOR = '%System Administrator%';
    private static string DIRECTOR_ADMISSIONS = '%Directors of Admissions%';
    private static string DIRECTOR_ADMISSIONS_PTEMPLATE = '%Directors of Admissions w/program templates creation%';
   
    public static boolean isDirectorAdmissions(string profileId) {
        boolean status = false;
        try {
            if (MMUtils.stringEmptyNull(profileId)) {
                profileId = UserInfo.getProfileId();
            }
            SObject p = [select count(Id) profileCount from Profile 
                            where Id = :profileId and
                                  Name like :DIRECTOR_ADMISSIONS];
            if (((long)p.get('profileCount')) > 0) {
                status = true;
            }
        }
        catch(Exception exp) { }
        return status;
    }
    
    public static boolean isDirectorAdmissionsPTemplate(string profileId) {
        boolean status = false;
        try {
            if (MMUtils.stringEmptyNull(profileId)) {
                profileId = UserInfo.getProfileId();
            }
            SObject p = [select count(Id) profileCount from Profile 
                            where Id = :profileId and
                                  Name like :DIRECTOR_ADMISSIONS_PTEMPLATE];
            if (((long)p.get('profileCount')) > 0) {
                status = true;
            }
        }
        catch(Exception exp) { }
        return status;
    }    
    
    public static boolean isSystemAdministrator(string profileId) {
        boolean status = false;
        try {
            if (MMUtils.stringEmptyNull(profileId)) {
                profileId = UserInfo.getProfileId();
            }
            SObject p = [select count(Id) profileCount from Profile 
                            where Id = :profileId and
                                  Name like :SYSTEM_ADMINISTRATOR];
            if (((long)p.get('profileCount')) > 0) {
                status = true;
            }
        }
        catch(Exception exp) { }
        return status;
    }    
}