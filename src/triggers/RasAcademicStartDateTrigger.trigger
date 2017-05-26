trigger RasAcademicStartDateTrigger on Academic_Start_Date__c (after insert, after update) {
	
	String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
	
    User loggedInUser = [SELECT Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
    if (!loggedInUser.Profile.Name.contains('Integration')) {
    
    if (trigger.isInsert) {
        System.debug('--- RasAcademicStartDateTrigger insert ---');
    }
    
    if (trigger.isUpdate) {
        System.debug('--- RasAcademicStartDateTrigger update ---');
    }
    
    System.debug('Trigger record details: ' + trigger.new);
    
    Set<id> acadStartDateList = new Set<id>();
    Map<Id, Date> idToStartDate = new Map<Id, Date>();
    List<Opportunity> opptyToPersist = new List<Opportunity>();
    
    integer i=0;
    
    for(Academic_Start_Date__c thisDate : Trigger.new){
        
        // Bug fix 816 CB START
        //If the 2 roll-up summarie fields have not changed, only then will this record be added to the list of updates
        if (trigger.isInsert || 
            (thisDate.Total_Actual_Starts__c == trigger.old[i].Total_Actual_Starts__c &&
            thisDate.Total_Start_Goal__c == trigger.old[i].Total_Start_Goal__c)
            ) {
        // Bug fix 816 CB END
                
            acadStartDateList.add(thisDate.id);
            idToStartDate.put(thisDate.id, thisDate.Start_Date__c);
        }
        i++;
    }
    // Bug Fix 657 VS START Making the updates batchable 
    if(acadStartDateList != null && acadStartDateList.size() > 0){
        BatchUpdateSObject batchAPex = new BatchUpdateSObject(acadStartDateList, idToStartDate);
        ID batchprocessid = Database.executeBatch(batchApex);
    }
    
    /**List<Opportunity> opptyList = [Select id,
                                          Start_Date__c,
                                          Academic_Start_Date__c
                                    From Opportunity
                                    Where Academic_Start_Date__c in :acadStartDateList
                                    ];
    for(Opportunity thisOppty : opptyList){
        Date startDate = idToStartDate.get(thisOppty.Academic_Start_Date__c);
        thisOppty.Start_Date__c = startDate;
        opptyToPersist.add(thisOppty);
    }
    System.Debug('VS -- OpptyToPersistSize -- '+opptyToPersist.size());
    
    
    try{
        
        if(opptyToPersist != null && opptyToPersist.size() > 0){
            System.Debug('VS -- Oppty to Persist'+opptyToPersist);
            update opptyToPersist;
        }
    }catch(Exception e){
        System.Debug(e);
    }**/
    // Bug Fix 657 END Making the updates batchable
   }
}