public class AdmissionsGoal {
	public Decimal //totalCalls, 
				   //weeklyCalls, 
				   weeklyLeads, 
				   totalLeads, 
				   totalAppointments, 
				   weeklyAppointments,
				   //weeklySuccessfulCalls,
				   weeklyReferrals,
				   weeklyUnContactedLeads,
				   weeklyApplications,
				   totalApplicationsReceived,
				   totalUnContactedLeads,
				   totalStart;
	
	public AdmissionsGoal() {
		//totalCalls = 0;
		totalLeads = 0;
		weeklyLeads = 0;
		//weeklyCalls = 0;
		totalAppointments = 0;
		weeklyAppointments = 0;
		//weeklySuccessfulCalls = 0;
		weeklyReferrals = 0;
		weeklyUnContactedLeads = 0;
		weeklyApplications = 0;
		totalApplicationsReceived = 0;
		totalUnContactedLeads = 0;
		totalStart = 0;
	}
	
	public void updateValues (Decimal tLeads, 
							  Decimal wLeads, 
							  /*Decimal tCalls, 
							  Decimal wCalls, */
							  Decimal tappointments,
							  Decimal wAppointments,
							  /*Decimal wSuccessfulCalls,*/
							  Decimal wReferrals,
							  Decimal wUnContactedLeads,
							  Decimal wApplications,
							  Decimal tApplicationsReceived,
							  Decimal tUnContactedLeads,
							  Decimal tStart) {
		totalLeads = tLeads;
		weeklyLeads = wLeads;
		//totalCalls = tCalls;
		//weeklyCalls = wCalls;
		totalAppointments = tappointments;
		weeklyAppointments = wAppointments;
		//weeklySuccessfulCalls = wSuccessfulCalls;
		weeklyReferrals = wReferrals;
		weeklyUnContactedLeads = wUnContactedLeads;
		weeklyApplications = wApplications;
		totalApplicationsReceived = tApplicationsReceived;
		totalUnContactedLeads = tUnContactedLeads;
		totalStart = tStart;
	}
}