public without sharing class ProspectTeamMemberTriggerHandler {
    public static void handleBeforeInsert(List<Team_Member__c> newList){
        setAllocationCounter(newList, null);
    }
    public static void handleAfterInsert(List<Team_Member__c> newList){
        setFieldHistoryTracking(newList, null);
    }
    public static void handleBeforeUpdate(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        setAllocationCounter(newList, oldList);
        setFieldHistoryTracking(newList, oldList);
    }
    public static void handleAfterUpdate(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        distributeAllocationCounterToOthers(newList, oldList);
    }
    public static void handleAfterDelete(List<Team_Member__c> oldList){
        distributeAllocationCounterToOthers_DeleteFlow(oldList);
    }
    
    
    public static void setAllocationCounter(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        Set<Id> teamids = new Set<id>();
        if(oldList != null){
            //Update Flow
            for(Integer i =0;i<newList.size(); i++){
                Team_Member__c newMemberRecord = newList[i];
                Team_Member__c oldMemberRecord = oldList[i];
                if(oldMemberRecord.Allocation__c != newMemberRecord.Allocation__c){
                    newMemberRecord.Allocation_Counter__c = newMemberRecord.Allocation__c*10;
                    teamids.add(newMemberRecord.Which_Team__c);
                }
            }
            List<Team__c> teamstoUpdate = new List<Team__c>();
            for(Id thisTeamid : teamids){
                Team__c thisTeam = new Team__c(id=thisTeamid);
                thisTeam.Allocation_Override__c = true;
                teamstoUpdate.add(thisTeam);
            }
            if(teamstoUpdate != null && teamstoUpdate.size() > 0){
                Database.update(teamstoUpdate, false);
            }
        }else{
            //Insert Flow
            for(Integer i =0;i<newList.size(); i++){
                Team_Member__c newMemberRecord = newList[i];
                newMemberRecord.Allocation_Counter__c = newMemberRecord.Allocation__c*10;
                
            }
        }
    }
    public static void distributeAllocationCounterToOthers_DeleteFlow(List<Team_Member__c> oldList){
        
        Map<id, id> teamMemberIdToTeamId = new Map<Id, Id>();
        for(Team_Member__c thisTeamMember : oldList){
            teamMemberIdToTeamId.put(thisTeamMember.id, thisTeamMember.Which_Team__c);
        }
        List<Team__c> accountsList = [Select Id, Team_Account__c from Team__c where Id in :teamMemberIdToTeamId.values()];
        Set<Id> accountIds = new Set<Id>();
        for(Team__c thisTeam : accountsList){
            accountIds.add(thisTeam.Team_Account__c);
        }
        
        List<Campus_Contacts__c> campusContactsList = [Select Id, Employee__c from Campus_Contacts__c where Organization__c IN :accountIds];
        Set<Id> campusContactExists = new Set<id>();
        for(Campus_Contacts__c thisCC : campusContactsList){
            campusContactExists.add(thisCC.Employee__c);
        }

        Set<id> impactedTeams = new Set<id>();
        Map<Id, Double> percentToDistribute = new Map<id, Double>();
        for(Integer i =0;i<oldList.size(); i++){
            Team_Member__c oldMemberRecord = oldList[i];
            if(campusContactExists != null && campusContactExists.size() > 0 && campusContactExists.contains(oldMemberRecord.Who_Id__c)){
                continue;
            }
            impactedTeams.add(oldMemberRecord.Which_Team__c);
            Double thisDouble = Double.valueOf(0);
            if(percentToDistribute != null && percentToDistribute.containsKey(oldMemberRecord.Which_Team__c)){
                thisDouble = percentToDistribute.get(oldMemberRecord.Which_Team__c);
            }
            System.Debug('thisDouble -- '+thisDouble);
            thisDouble = thisDouble + (oldMemberRecord.Allocation__c != null ? oldMemberRecord.Allocation__c : 0);
            percentToDistribute.put(oldMemberRecord.Which_Team__c, thisDouble);
            
        }
        if(percentToDistribute != null && percentToDistribute.size() > 0){
            distributeAllocations(percentToDistribute, true);
        }
        
        
    }
    
    public static void distributeAllocationCounterToOthers(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        Set<id> impactedTeams = new Set<id>();
        Map<Id, Double> percentToDistribute = new Map<id, Double>();
        Map<id, Double> percentToTakeBack = new Map<Id, Double>();
        Map<Id, Set<Id>> teamIdToActivatedMembers = new Map<Id, Set<Id>>();
        Set<Id> activatedMemberIds = new Set<Id>();
        for(Integer i =0;i<newList.size(); i++){
            Team_Member__c newMemberRecord = newList[i];
            Team_Member__c oldMemberRecord = oldList[i];
            System.Debug('newMemberRecord.Active__c -- '+newMemberRecord.Active__c);
            System.Debug('oldMemberRecord.Active__c -- '+oldMemberRecord.Active__c);
            if(newMemberRecord.Active__c == false && newMemberRecord.Active__c != oldMemberRecord.Active__c){
                impactedTeams.add(newMemberRecord.Which_Team__c);
                Double thisDouble = Double.valueOf(0);
                if(percentToDistribute != null && percentToDistribute.containsKey(newMemberRecord.Which_Team__c)){
                     thisDouble = percentToDistribute.get(newMemberRecord.Which_Team__c);
                }
                System.Debug('thisDouble -- '+thisDouble);
                
                thisDouble = thisDouble + (newMemberRecord.Allocation_Counter__c != null ? newMemberRecord.Allocation_Counter__c : 0);
                percentToDistribute.put(newMemberRecord.Which_Team__c, thisDouble);
            }
            if(newMemberRecord.Active__c == true && newMemberRecord.Active__c != oldMemberRecord.Active__c){
                Double thisDouble = Double.valueOf(0);
                if(percentToTakeBack != null && percentToTakeBack.containsKey(newMemberRecord.Which_Team__c)){
                     thisDouble = percentToTakeBack.get(newMemberRecord.Which_Team__c);
                }
                thisDouble = thisDouble + (newMemberRecord.Allocation_Counter__c != null ? newMemberRecord.Allocation_Counter__c : 0);
                percentToTakeBack.put(newMemberRecord.Which_Team__c, thisDouble);
                activatedMemberIds.add(newMemberRecord.Id);
            
            }
        }
        System.Debug('percentToTakeBack -- '+percentToTakeBack);
        System.Debug('percentToDistribute -- '+percentToDistribute);
        System.Debug('activatedMemberIds -- '+activatedMemberIds);
        if(percentToDistribute != null && percentToDistribute.size() > 0){
            distributeAllocations(percentToDistribute, false);
        }
        if(percentToTakeBack != null && percentToTakeBack.size() > 0){
            redistributeAllocations(percentToTakeBack, activatedMemberIds);
        }
        
    }
    @future
    public static void redistributeAllocations(Map<Id, Double> teamToAllocationCounter, Set<Id> activatedMembers ){
        List<Team_Member__c> teamMemberList = [Select Id, Allocation_Counter__c, 
                                                      Active__c, Which_Team__c 
                                                 from Team_Member__c 
                                                 where Which_Team__c IN :teamToAllocationCounter.keySet()
                                                 and Active__c = true];
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberList = new Map<id, List<Team_Member__c>>();
        for(Team_Member__c thisTeamMember : teamMemberList){
            if(activatedMembers.contains(thisTeamMember.Id)){
                continue;
            }
            List<Team_Member__c> teamMemberTemp = new List<Team_Member__c>();
            if(teamIdToTeamMemberList != null && teamIdToTeamMemberList.containsKey(thisTeamMember.Which_Team__c)){
                teamMemberTemp = teamIdToTeamMemberList.get(thisTeamMember.Which_Team__c);
            }
            teamMemberTemp.add(thisTeamMember);
            teamIdToTeamMemberList.put(thisTeamMember.Which_Team__c, teamMemberTemp);
        }
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        for(Id teamId : teamToAllocationCounter.keySet()){
            Double splitTheAllocationCounter = teamToAllocationCounter.get(teamId);
            List<Team_Member__c> activeMembersForTeam = teamIdToTeamMemberList.get(teamId);
            if(activeMembersForTeam!=null)
            {
                Integer remainingTeamMembersSize = activeMembersForTeam.size();
                Decimal splitForEachMember = splitTheAllocationCounter / remainingTeamMembersSize;
                for(Team_Member__c thisMember : activeMembersForTeam){
                    if(thisMember.Allocation_Counter__c != null){
                        thisMember.Allocation_Counter__c = thisMember.Allocation_Counter__c -  splitForEachMember;
                    }
                    teamMembersToUpdate.add(thisMember);
                }
                Team__c thisTeam = new Team__c(id=teamId);
                thisTeam.Allocation_Override__c = true;
                teamsToUpdate.add(thisTeam);
            }
        }
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            Database.update(teamMembersToUpdate, false);
        }
        if(teamsToUpdate != null && teamsToUpdate.size() > 0){
            Database.update(teamsToUpdate, false);
        }
    }
    
    
    @future
    public static void distributeAllocations(Map<id, Double> teamToAllocationCounter, boolean allocation){
        List<Team_Member__c> teamMemberList = [Select Id, Allocation_Counter__c, 
                                                      Active__c, Which_Team__c , Allocation__c
                                                 from Team_Member__c 
                                                 where Which_Team__c IN :teamToAllocationCounter.keySet() 
                                                 and Active__c = true];
        system.debug('teamMemberList-->'+teamMemberList);                                        
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberList = new Map<id, List<Team_Member__c>>();
        for(Team_Member__c thisTeamMember : teamMemberList){
            List<Team_Member__c> teamMemberTemp = new List<Team_Member__c>();
            if(teamIdToTeamMemberList != null && teamIdToTeamMemberList.containsKey(thisTeamMember.Which_Team__c)){
                teamMemberTemp = teamIdToTeamMemberList.get(thisTeamMember.Which_Team__c);
            }
            teamMemberTemp.add(thisTeamMember);
            teamIdToTeamMemberList.put(thisTeamMember.Which_Team__c, teamMemberTemp);
        }
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        for(Id teamId : teamToAllocationCounter.keySet()){
            Double splitTheAllocationCounter = teamToAllocationCounter.get(teamId);
            List<Team_Member__c> activeMembersForTeam = teamIdToTeamMemberList.get(teamId);
            if(activeMembersForTeam!=null)
            {
                Integer remainingTeamMembersSize = activeMembersForTeam.size();
                Decimal splitForEachMember = splitTheAllocationCounter / remainingTeamMembersSize;
                for(Team_Member__c thisMember : activeMembersForTeam){
                    if(thisMember.Allocation_Counter__c != null && !allocation){
                        thisMember.Allocation_Counter__c = thisMember.Allocation_Counter__c + splitForEachMember;
                        system.debug('alloc1-->'+thisMember.Allocation_Counter__c + splitForEachMember);
                    }
                    if(thisMember.Allocation__c != null && allocation){
                        thisMember.Allocation__c = thisMember.Allocation__c+ splitForEachMember;
                        system.debug('alloc2-->'+thisMember.Allocation__c+ splitForEachMember);
                    }
                    
                    teamMembersToUpdate.add(thisMember);
                    
                }
            
                Team__c thisTeam = new Team__c(id=teamId);
                thisTeam.Allocation_Override__c = true;
                teamsToUpdate.add(thisTeam);
            }           
        }
        system.debug('teamMembersToUpdate-->'+teamMembersToUpdate);
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            Database.update(teamMembersToUpdate, false);
        }
        if(teamsToUpdate != null && teamsToUpdate.size() > 0){
            Database.update(teamsToUpdate, false);
        }
    }
    public static void setFieldHistoryTracking(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Team_Member__c.fields.getMap();
        List<PRO_FIeld_History__c> proFieldHistoryList = new List<PRO_FIeld_History__c>();
        for(Integer i =0;i<newList.size(); i++){
            Team_Member__c newMemberRecord = newList[i];
            Team_Member__c oldMemberRecord = (oldList != null ? oldList[i] : null);
        
            for (String fieldName: schemaFieldMap.keySet()) {
                if(fieldName == 'Allocation_Counter__c' || !fieldName.endsWith('__c')){
                    continue;
                }
                if(oldMemberRecord == null || (newMemberRecord != null && oldMemberRecord != null && newMemberRecord.get(fieldName) != oldMemberRecord.get(fieldName))){
                    PRO_FIeld_History__c thisProFieldHistory = new PRO_FIeld_History__c();
                    thisProFieldHistory.Team_Member__c = newMemberRecord.Id;
                    if(oldMemberRecord != null){
                        thisProFieldHistory.Old_Value__c = String.valueOf(oldMemberRecord.get(fieldName));
                        thisProFieldHistory.New_Value__c = String.valueOf(newMemberRecord.get(fieldName));
                        thisProFieldHistory.Field_Name__c = String.valueOf(schemaFieldMap.get(fieldName).getDescribe().getLabel());
                        proFieldHistoryList.add(thisProFieldHistory);
                    }else{
                        boolean okayToInsert = false;
                        if(fieldName == 'Allocation__c'){
                            continue;
                        }
                        if(String.valueOf(newMemberRecord.get(fieldName)) != null){
                            thisProFieldHistory.New_Value__c = String.valueOf(newMemberRecord.get(fieldName));
                            okayToInsert = true;
                        }
                        if(String.valueOf(schemaFieldMap.get(fieldName).getDescribe().getLabel()) != null){
                            thisProFieldHistory.Field_Name__c = String.valueOf(schemaFieldMap.get(fieldName).getDescribe().getLabel());
                            okayToInsert = true;
                        }
                        if(okayToInsert)
                            proFieldHistoryList.add(thisProFieldHistory);
                    }
                
                }
            }
            
        }
        System.Debug('proFieldHistoryList -- '+proFieldHistoryList);
            if(proFieldHistoryList != null && proFieldHistoryList.size() > 0){
                insert proFieldHistoryList;
            }
    }
    
    public static void createTeamforNewAccounts(List<Account> newList){
        List<Team__c> defaultTeamsToInsert = new List<Team__c>();
        for(Account thisAccount : newList){
            Team__c thisTeam = new Team__c();
            thisTeam.Team_Account__c = thisAccount.Id;
            thisTeam.Active__c = true;
            thisTeam.Default_Team__c = true;
            //thisTeam.Team_Order__c = 100;
            thisTeam.Team_Name__c = 'Catch All Team';
            defaultTeamsToInsert.add(thisTeam);
        }
        if(defaultTeamsToInsert != null && defaultTeamsToInsert.size() > 0){
            insert defaultTeamsToInsert;
        }
    }
    
    public static void handleCampusContactAfterInsert(List<Campus_Contacts__c> newList){
        
        //INCLUDE ONLY PROGRAM MANAGERS
        List<Prospect_Profiles__c> profList = Prospect_Profiles__c.getAll().values();
        List<Id> profileIds = new List<Id>();
        if(profList != null && profList.size() > 0)
        {
            for(Prospect_Profiles__c pid : profList)
            {
                profileIds.add(pid.ProfileId__c);
            }       
        }
        
        List<DOA_Profiles__c> doaProfileList = DOA_Profiles__c.getAll().values(); 
        List<Id> doaProfileIds = new List<Id>();
        if(doaProfileList != null && doaProfileList.size() > 0)
        {
            for(DOA_Profiles__c pid : doaProfileList)
            {
                doaProfileIds.add(pid.DOAProfileId__c);
            }       
        }
        
        List<Campus_Contacts__c> onlyDOAProfileUsers = new List<Campus_Contacts__c>();
        Map<Id,Id> doaProfileMap = new Map<Id,Id>();
        
        List<Campus_Contacts__c> onlyProspectProfileUsers = new List<Campus_Contacts__c>();
        List<Id> usersToVerify = new List<Id>();
        Map<Id,Id> userProfileMap = new Map<Id,Id>();
        
        for(Campus_Contacts__c thisCampusContact : newList){
            usersToVerify.add(thisCampusContact.Employee__c);
        }
        List<User> usrProfile = new List<User>();
        List<User> doaProfile = new List<User>();
        usrProfile = [select id, ProfileId, prospect_inactive__c from User where id in: usersToVerify and ProfileId in: profileIds];
        doaProfile = [select id, ProfileId, prospect_inactive__c from User where id in: usersToVerify and ProfileId in: doaProfileIds];
        system.debug('usrProfile'+usrProfile);
        system.debug('doaProfile'+doaProfile);
        List<Id> pmUsrIds = new List<Id>();
        List<Id> doaUsrIds = new List<Id>();
        Map<String, Boolean> userProspectInactiveMap = new Map<String, Boolean>();
        Map<String, Boolean> doaProspectInactiveMap = new Map<String, Boolean>();
        for(User usr: usrProfile)
        {
            pmUsrIds.add(usr.ProfileId);
            userProfileMap.put(usr.id,usr.ProfileId);
            userProspectInactiveMap.put(usr.id, usr.prospect_inactive__c);
        }
        for(User usr: doaProfile)
        {
            doaUsrIds.add(usr.ProfileId);
            doaProfileMap.put(usr.id,usr.ProfileId);
            doaProspectInactiveMap.put(usr.id, usr.prospect_inactive__c);
        }
        for(Campus_Contacts__c thisCampusContact : newList){
            if(userProfileMap.get(thisCampusContact.Employee__c)!=null)
            {
                onlyProspectProfileUsers.add(thisCampusContact);
            }
            if(doaProfileMap.get(thisCampusContact.Employee__c)!=null)
            {
                onlyDOAProfileUsers.add(thisCampusContact);
            }
        }
        
        //INCLUDE ONLY PROGRAM MANAGERS
        if(onlyProspectProfileUsers!=null && onlyProspectProfileUsers.size()>0)
        {
            Set<Id> accountIds = new Set<Id>();
            for(Campus_Contacts__c thisCampusContact : onlyProspectProfileUsers){
                accountIds.add(thisCampusContact.Organization__c);
            }
            List<Team__c> defaultTeams = [Select Id, Default_Team__c, Team_Account__c, Member_Count__c from Team__c where Default_Team__c = true and Team_Account__c IN :accountIds];
            Map<Id, Team__c> defaultTeamForAccount = new Map<Id, Team__c>();
            Map<Id, List<Team_Member__c>> teamToTeamMembers = new Map<Id, List<Team_Member__c>>();
            List<Id> teamIds = new List<Id>();
            for(Team__c thisTeam : defaultTeams){
                defaultTeamForAccount.put(thisTeam.Team_Account__c, thisTeam);
                teamIds.add(thisTeam.Id);
            }
            List<Team_Member__c> teamMembersList = [Select id, Which_Team__c, Allocation__c from Team_Member__c where Which_Team__c iN :teamIds];
            System.Debug('teamMembersList -- '+teamMembersList);
                
            for(Team_Member__c thisTeamMember : teamMembersList){
                List<Team_Member__c> tempTeamMembers = new List<Team_Member__c>();
                if(teamToTeamMembers != null && teamToTeamMembers.containsKey(thisTeamMember.Which_Team__c)){
                    tempTeamMembers = teamToTeamMembers.get(thisTeamMember.Which_Team__c);
                }
                tempTeamMembers.add(thisTeamMember);
                teamToTeamMembers.put(thisTeamMember.Which_Team__c, tempTeamMembers);
            }
            
            List<Team_Member__c> teamMembersListToInsert = new List<Team_Member__c>();
            List<Team_Member__c> teamMembersListToUpdate = new List<Team_Member__c>();
            List<Team_Member_Availability__c> teamMemberAvblToInsert = new List<Team_Member_Availability__c>();
            for(Campus_Contacts__c thisCampusContact : onlyProspectProfileUsers){
                System.Debug('defaultTeamForAccount -- '+defaultTeamForAccount);
                System.Debug('thisCampusContact.Organization__c -- '+thisCampusContact.Organization__c);
                Team__c defaultTeam = defaultTeamForAccount.get(thisCampusContact.Organization__c);
                System.Debug('defaultTeam -- '+defaultTeam);
                Team_Member__c thisMember = new Team_Member__c();
                thisMember.Active__c = true;
                thisMember.Allocation__c = 1/(defaultTeam.Member_Count__c+1);
                thisMember.Who_Id__c = thisCampusContact.Employee__c;
                thisMember.Which_Team__c = defaultTeam.id;
                teamMembersListToInsert.add(thisMember);
                System.Debug('defaultTeam.id -- '+defaultTeam.id);
                System.Debug('teamToTeamMembers -- '+teamToTeamMembers);
                //System.Debug('teamToTeamMembers.get(defaultTeam.id) -- '+teamToTeamMembers.get(defaultTeam.id));
                List<Team_Member__c> teamMembersForTeam = teamToTeamMembers.get(defaultTeam.id);
                
                if(teamMembersForTeam != null){
                    for(Team_Member__c thisMem : teamMembersForTeam){
                        Team_Member__c tempThisMem = thismem;
                        tempThisMem.Allocation__c = 1/(defaultTeam.Member_Count__c+1);
                        teamMembersListToUpdate.add(tempThisMem);
                        
                    }
                }
                
                Team_Member_Availability__c tmAvbl = new Team_Member_Availability__c();
                tmAvbl.Which_user__c = thisCampusContact.Employee__c;
                //t.user_available__c, t.Widget_Override__c, t.Which_user__c, t.Which_Account__c, t.Process_this_availability__c, t.Is_Team_Member_Available__c
                tmAvbl.Which_Account__c = thisCampusContact.Organization__c;
                tmAvbl.Is_Team_Member_Available__c = !(userProspectInactiveMap.get(thisCampusContact.Employee__c));
                teamMemberAvblToInsert.add(tmAvbl);
            }   
            if(teamMembersListToInsert != null && teamMembersListToInsert.size() > 0){
                    insert teamMembersListToInsert;
            }
            if(teamMembersListToUpdate != null && teamMembersListToUpdate.size() > 0){
                    Database.update(teamMembersListToUpdate, false);
            }
            if(teamMemberAvblToInsert !=null && teamMemberAvblToInsert.size() > 0){
                    insert teamMemberAvblToInsert;
            }
        }
        
        
        
        //ADD DOAs to Team Availability
        if(onlyDOAProfileUsers!=null && onlyDOAProfileUsers.size()>0)
        {
            List<Team_Member_Availability__c> teamMemberAvblToInsert = new List<Team_Member_Availability__c>();
            for(Campus_Contacts__c thisCampusContact : onlyDOAProfileUsers){
                
                Team_Member_Availability__c tmAvbl = new Team_Member_Availability__c();
                tmAvbl.Which_user__c = thisCampusContact.Employee__c;
                //t.user_available__c, t.Widget_Override__c, t.Which_user__c, t.Which_Account__c, t.Process_this_availability__c, t.Is_Team_Member_Available__c
                tmAvbl.Which_Account__c = thisCampusContact.Organization__c;
                tmAvbl.Is_Team_Member_Available__c = !(doaProspectInactiveMap.get(thisCampusContact.Employee__c));
                teamMemberAvblToInsert.add(tmAvbl);
            }
            if(teamMemberAvblToInsert !=null && teamMemberAvblToInsert.size() > 0){
                    insert teamMemberAvblToInsert;
            }
        }
        
                    
    }

// Ticket SRP-1317  
    public static void handleCampusContactAfterDelete(List<Campus_Contacts__c> oldList){
        System.debug('oldList-->'+oldList);
        List<Id> empIds = new List<Id>();
        for(Campus_Contacts__c cc : oldList)
        {
            empIds.add(cc.Employee__c);
        }
        System.debug('empIds-->'+empIds); 
        List<Team_Member__c> tmMemId = new List<Team_Member__c>();
        tmMemId = [SELECT t.Id FROM Team_Member__c t WHERE t.Who_id__c IN :empIds];
        System.debug('tmMemId-->'+tmMemId);
        List<Id> idsToDelete = new List<Id>();
        for(Team_Member__c tm : tmMemId){
            idsToDelete.add(tm.id);
        }
        System.debug('idsToDelete-->'+idsToDelete);
        try{
            Database.delete(idsToDelete, true);
        /*for(Team_Member__c tm : tmMemId){     
            Database.delete(tm.id, true);
        }       */  
        }catch(Exception e)
        {
            System.debug('Exception-->'+e.getMessage());
        }
        List<Team_Member_Availability__c> tmAvblDelete = new List<Team_Member_Availability__c>();
        tmAvblDelete = [Select id from Team_Member_Availability__c where Which_User__c IN: empIds];
        List<Id> tmaDel = new List<Id>();
        for(Team_Member_Availability__c tma : tmAvblDelete){
            tmaDel.add(tma.id);
        }
        System.debug('tmaDel-->'+tmaDel);
        try{
            Database.delete(tmaDel, true);
         
        }catch(Exception e)
        {
            System.debug('Exception-->'+e.getMessage());
        }
    }
   
   // Girija: added logic for updateing team owner when DOA of the Account changes as a prt of
   // SRP-1451 
    public static void updateTeamOwner(List<Account> newList)
    {            
         List<Team__c> teamsToUpdate = new List<Team__c>(); 
         Map<Id,Id> acctIdToOwnerId = new Map<Id,Id>();
         List<id> acctIdList = new List<id>();
         for(Account acc : newList) 
         {
            acctIdToOwnerId.put(acc.id, acc.OwnerId);
            acctIdList.add(acc.id);
         }
         
        for(Team__c tm : [Select t.Team_Account__c, t.OwnerId, t.Active__c From Team__c t where t.Team_Account__c in :acctIdList])
        {        
            tm.OwnerId = acctIdToOwnerId.get(tm.Team_Account__c);
            teamsToUpdate.add(tm);           
        }
        if(teamsToUpdate.size() > 0 && teamsToUpdate != null)
            Database.update(teamsToUpdate, false);
    }
    
    // VR - Adding methods accessible from Batch for User Availability Update 
    public static void distributeAllocationCounterToOthersNonFuture(List<Team_Member__c> newList, List<Team_Member__c> oldList){
        Set<id> impactedTeams = new Set<id>();
        Map<Id, Double> percentToDistribute = new Map<id, Double>();
        Map<id, Double> percentToTakeBack = new Map<Id, Double>();
        Map<Id, Set<Id>> teamIdToActivatedMembers = new Map<Id, Set<Id>>();
        Set<Id> activatedMemberIds = new Set<Id>();
        for(Integer i =0;i<newList.size(); i++){
            Team_Member__c newMemberRecord = newList[i];
            Team_Member__c oldMemberRecord = oldList[i];
            System.Debug('newMemberRecord.Active__c -- '+newMemberRecord.Active__c);
            System.Debug('oldMemberRecord.Active__c -- '+oldMemberRecord.Active__c);
            if(newMemberRecord.Active__c == false && newMemberRecord.Active__c != oldMemberRecord.Active__c){
                impactedTeams.add(newMemberRecord.Which_Team__c);
                Double thisDouble = Double.valueOf(0);
                if(percentToDistribute != null && percentToDistribute.containsKey(newMemberRecord.Which_Team__c)){
                     thisDouble = percentToDistribute.get(newMemberRecord.Which_Team__c);
                }
                System.Debug('thisDouble -- '+thisDouble);
                
                thisDouble = thisDouble + (newMemberRecord.Allocation_Counter__c != null ? newMemberRecord.Allocation_Counter__c : 0);
                percentToDistribute.put(newMemberRecord.Which_Team__c, thisDouble);
            }
            if(newMemberRecord.Active__c == true && newMemberRecord.Active__c != oldMemberRecord.Active__c){
                Double thisDouble = Double.valueOf(0);
                if(percentToTakeBack != null && percentToTakeBack.containsKey(newMemberRecord.Which_Team__c)){
                     thisDouble = percentToTakeBack.get(newMemberRecord.Which_Team__c);
                }
                thisDouble = thisDouble + (newMemberRecord.Allocation_Counter__c != null ? newMemberRecord.Allocation_Counter__c : 0);
                percentToTakeBack.put(newMemberRecord.Which_Team__c, thisDouble);
                activatedMemberIds.add(newMemberRecord.Id);
            
            }
        }
        System.Debug('percentToTakeBack -- '+percentToTakeBack);
        System.Debug('percentToDistribute -- '+percentToDistribute);
        System.Debug('activatedMemberIds -- '+activatedMemberIds);
        if(percentToDistribute != null && percentToDistribute.size() > 0){
            distributeAllocationsNonFuture(percentToDistribute, false);
        }
        if(percentToTakeBack != null && percentToTakeBack.size() > 0){
            redistributeAllocationsNonFuture(percentToTakeBack, activatedMemberIds);
        }
        
    }
    
    public static void redistributeAllocationsNonFuture(Map<Id, Double> teamToAllocationCounter, Set<Id> activatedMembers ){
        List<Team_Member__c> teamMemberList = [Select Id, Allocation_Counter__c, 
                                                      Active__c, Which_Team__c 
                                                 from Team_Member__c 
                                                 where Which_Team__c IN :teamToAllocationCounter.keySet()
                                                 and Active__c = true];
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberList = new Map<id, List<Team_Member__c>>();
        for(Team_Member__c thisTeamMember : teamMemberList){
            if(activatedMembers.contains(thisTeamMember.Id)){
                continue;
            }
            List<Team_Member__c> teamMemberTemp = new List<Team_Member__c>();
            if(teamIdToTeamMemberList != null && teamIdToTeamMemberList.containsKey(thisTeamMember.Which_Team__c)){
                teamMemberTemp = teamIdToTeamMemberList.get(thisTeamMember.Which_Team__c);
            }
            teamMemberTemp.add(thisTeamMember);
            teamIdToTeamMemberList.put(thisTeamMember.Which_Team__c, teamMemberTemp);
        }
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        for(Id teamId : teamToAllocationCounter.keySet()){
            Double splitTheAllocationCounter = teamToAllocationCounter.get(teamId);
            List<Team_Member__c> activeMembersForTeam = teamIdToTeamMemberList.get(teamId);
            if(activeMembersForTeam!=null)
            {
                Integer remainingTeamMembersSize = activeMembersForTeam.size();
                Decimal splitForEachMember = splitTheAllocationCounter / remainingTeamMembersSize;
                for(Team_Member__c thisMember : activeMembersForTeam){
                    if(thisMember.Allocation_Counter__c != null){
                        thisMember.Allocation_Counter__c = thisMember.Allocation_Counter__c -  splitForEachMember;
                    }
                    teamMembersToUpdate.add(thisMember);
                }
                Team__c thisTeam = new Team__c(id=teamId);
                thisTeam.Allocation_Override__c = true;
                teamsToUpdate.add(thisTeam);
            }
        }
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            Database.update(teamMembersToUpdate, false);
        }
        if(teamsToUpdate != null && teamsToUpdate.size() > 0){
            Database.update(teamsToUpdate, false);
        }
    }
    
    public static void distributeAllocationsNonFuture(Map<id, Double> teamToAllocationCounter, boolean allocation){
        List<Team_Member__c> teamMemberList = [Select Id, Allocation_Counter__c, 
                                                      Active__c, Which_Team__c , Allocation__c
                                                 from Team_Member__c 
                                                 where Which_Team__c IN :teamToAllocationCounter.keySet() 
                                                 and Active__c = true];
        system.debug('teamMemberList-->'+teamMemberList);                                        
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberList = new Map<id, List<Team_Member__c>>();
        for(Team_Member__c thisTeamMember : teamMemberList){
            List<Team_Member__c> teamMemberTemp = new List<Team_Member__c>();
            if(teamIdToTeamMemberList != null && teamIdToTeamMemberList.containsKey(thisTeamMember.Which_Team__c)){
                teamMemberTemp = teamIdToTeamMemberList.get(thisTeamMember.Which_Team__c);
            }
            teamMemberTemp.add(thisTeamMember);
            teamIdToTeamMemberList.put(thisTeamMember.Which_Team__c, teamMemberTemp);
        }
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        for(Id teamId : teamToAllocationCounter.keySet()){
            Double splitTheAllocationCounter = teamToAllocationCounter.get(teamId);
            List<Team_Member__c> activeMembersForTeam = teamIdToTeamMemberList.get(teamId);
            if(activeMembersForTeam!=null)
            {
                Integer remainingTeamMembersSize = activeMembersForTeam.size();
                Decimal splitForEachMember = splitTheAllocationCounter / remainingTeamMembersSize;
                for(Team_Member__c thisMember : activeMembersForTeam){
                    if(thisMember.Allocation_Counter__c != null && !allocation){
                        thisMember.Allocation_Counter__c = thisMember.Allocation_Counter__c + splitForEachMember;
                        system.debug('alloc1-->'+thisMember.Allocation_Counter__c + splitForEachMember);
                    }
                    if(thisMember.Allocation__c != null && allocation){
                        thisMember.Allocation__c = thisMember.Allocation__c+ splitForEachMember;
                        system.debug('alloc2-->'+thisMember.Allocation__c+ splitForEachMember);
                    }
                    
                    teamMembersToUpdate.add(thisMember);
                    
                }
            
                Team__c thisTeam = new Team__c(id=teamId);
                thisTeam.Allocation_Override__c = true;
                teamsToUpdate.add(thisTeam);
            }           
        }
        system.debug('teamMembersToUpdate-->'+teamMembersToUpdate);
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            Database.update(teamMembersToUpdate, false);
        }
        if(teamsToUpdate != null && teamsToUpdate.size() > 0){
            Database.update(teamsToUpdate, false);
        }
    }
    
}