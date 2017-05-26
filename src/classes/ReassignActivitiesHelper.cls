public class ReassignActivitiesHelper {
	
	//this boolean keeps track of whether the Opp_StudentChanged class has occured
	//this was needed to stop a recurrsive loop from occuring
	private static boolean changingStudentLookupOnOpportunity = false;
	
	public static boolean isChangingStudentLookupOnOpportunity() {
        return changingStudentLookupOnOpportunity;
    }
    
    public static void setChangingStudentLookupOnOpportunity() {
    	changingStudentLookupOnOpportunity = true;
    }
}