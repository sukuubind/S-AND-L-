public without sharing class ProspectOpportunityAssignment_CaseMgmt {
    
    // The method accepts a map of all cases to its corresponding team and return a lit of cases with the ownerid based on weighted round-robin logic within each team
    public static Map<Id, Id> performCaseAssignment(Map<Case, Team__c> caseTeamMap){
        System.Debug('caseTeamMap -- '+caseTeamMap);
        Map<ID, ID> caseIdToTeamMemberID = new Map<ID, ID>();
        List<Team__c> teams = new List<Team__c>();
        teams = [Select Id, allocation_override__c, (Select ID, Which_Team__c, Which_Team__r.allocation_override__c, who_id__c, allocation__c, allocation_counter__c from Team_Members__r where active__c = true ORDER BY allocation_counter__c desc) from Team__c where Id in :caseTeamMap.values()];
        system.debug('teams>>>'+teams);
        Map<Id, List<Team_Member__c>> teamIdToTeamMemberMap  = new Map<Id, List<Team_Member__c>>();
        Map<Team__c, Integer> teamToNumberOfTeamsMap  = new Map<Team__c, Integer>();
        List<Team__c> teamsToUpdateOverrideFlag = new List<Team__c>();
        //building a map of team to team members
        for(Team__c t: teams){
            List<Team_Member__c> members = new List<Team_Member__c>();
            
            if(t.allocation_override__c == true){
                teamsToUpdateOverrideFlag.add(new Team__c (id=t.id, allocation_override__c = false));
            }
            
            for(Team_Member__c tm: t.Team_Members__r){
                system.debug('teammember>>>'+tm);
                members.add(tm);
            }
            teamIdToTeamMemberMap.put(t.id, members);
        }
        
        if(teamsToUpdateOverrideFlag.size()>0)
            update teamsToUpdateOverrideFlag;
        
        system.debug('teamidToTeamMemberMap>>>>'+teamidToTeamMemberMap);
        
        Map<Team__c, List<Case>> teamToCases = new Map<Team__c, List<Case>> ();
        
        //building a map of team to correspoding cases 
        for(Case o: caseTeamMap.keyset()){
            Team__c t = caseTeamMap.get(o);
            List<Case> cases;
            
            if(teamToCases.get(t) == null)
                cases = new List<Case>();
            else    
                cases = teamToCases.get(t);
                
            cases.add(o);
            teamToCases.put(t, cases);
        }
        
        system.debug('teamToCases>>>>'+teamToCases);
        
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, Team_Member__c> teamMembersToUpdate;
        Set<Team_Member__c> allMembersToUpdate = new Set<Team_Member__c>();
        List<Team__c> teamsToUpdate = new List<Team__c>();
        // SRP-1482 - VR - START - Commenting this section for SRP-2017 - VR
        /*List<Id> caseListToLookup = new List<Id>();
        for(Team__c t: teamToCases.keyset()){
            for(Case o: teamToCases.get(t)){
                caseListToLookup.add(o.id);
            }
        }
        Set<Id> casesWithClosedLogRecs = new Set<Id>();
        List<PRO_Log__c> closedLogs = new List<PRO_Log__c>();
        closedLogs = [Select Id, Opportunity__c, Case__c from PRO_Log__c where Case__c in : caseListToLookup and Status__c = 'Closed'];
        if(closedLogs!=null && closedLogs.size()>0)
        {
            for(PRO_Log__c pL: closedLogs)
            {
                casesWithClosedLogRecs.add(pL.Case__c);
            }
        }*/
        
        // SRP-1482 - VR - END - Commenting this section for SRP-2017 - VR
        // For each team, the case allocation will run to get a team member of highest allocation counter value 
        //and assign the user associated with it to the owner of case 
        
        for(Team__c t: teamToCases.keyset()){
            
            teammembersToUpdate = new Map<Id, Team_Member__c>();
            Boolean allocationCountersReset = false;
            
            for(Case o: teamToCases.get(t)){
                // SRP-1482 - VR - START - Commenting this section for SRP-2017
                /*if(casesWithClosedLogRecs!=null && casesWithClosedLogRecs.size()>0 && casesWithClosedLogRecs.contains(o.id))
                continue;*/
                // SRP-1482 - VR - END - Commenting this section for SRP-2017
                system.debug('o>>>>'+o);
                
                Id previousOwnerid = o.ownerid;
                
                system.debug('teamToTeamMemberMap.get(t)>>>>'+teamIdToTeamMemberMap.get(t.id));
                Team_Member__c tm = getTeamMemberWithHighestAllocationCounter(teamidToTeamMemberMap.get(t.id), previousownerid);
                system.debug('tm>>>>'+tm);
                o.ownerid = tm.who_Id__c;
                o.team__c = tm.which_team__c;
                if(o.ownerid != previousownerid){
                    casesToUpdate.add(o);
                    caseIdToTeamMemberID.put(o.id, tm.id);
                }   
                else{
                    Team_Member__c tm2 = getTeamMemberWithSecondHighestAllocationCounter(teamidToTeamMemberMap.get(t.id), previousownerid);
                    if(tm2 == null)
                        o.ownerid = tm.who_id__c;
                    o.ownerid = tm2.who_id__c;
                    o.team__c = tm2.which_team__c;
                    casesToUpdate.add(o);
                    caseIdToTeamMemberID.put(o.id, tm2.id);
                }
                        
                // after the case is assigned, the allocation counter is subracted by one according to the algorithm
                tm.allocation_counter__c = tm.allocation_counter__c - 1;
                
                //after subtraction we check the allocation counters of all the team members
                Boolean allNonPositive = checkAllocationCountersOfTeam(teamidToTeamMemberMap.get(t.id));
                
                //if all the allocation counter values is less or equal to zero, the allocation counters are resetted,
                // if atleast one of the allocation counter is positive, they are simply updated with new values based
                if(allNonPositive) {
                    if(t.allocation_override__c == true){
                        system.debug('t>>>>'+t);
                        //Team__c t2 = t;
                        //t2.allocation_override__c = false;
                        //teamstoupdate.add(t2);
                    }else{
                        for(Team_Member__c tmem: teamidToTeamMemberMap.get(t.id)){
                            tmem.allocation_counter__c = tmem.allocation__c * 10;
                            system.debug('tmem.allocation__c>>>>'+tmem.allocation__c);
                            system.debug('tmem.allocation_counter__c>>>>'+tmem.allocation_counter__c);
                            TeamMembersToUpdate.put(tmem.id, tmem);
                        }
                    }   
                    allocationCountersReset = true;
                    //TeamMembersToUpdate.clear();
                }else{
                    TeamMembersToUpdate.put(tm.id, tm);
                }
                //teamToTeamMemberMap.put(teamToTeamMemberMap.get(t);
            }
            
            if(TeamMembersToUpdate.keyset().size() > 0)
                allMembersToUpdate.addall(teammembersToUpdate.values());
        }
        
        
        List<Team__c> teamsWithLatestValues = [Select ID, allocation_override__c from Team__c where Id in: teamToCases.keyset()];
        system.debug('teamsWithLatestValues>>>>'+teamsWithLAtestValues);
        for(Team__c t: teamsWithLatestValues){
            if(t.allocation_override__c == true){
                TeamsToUpdate.add(new Team__c(id=t.id, allocation_override__c = false));
            }
        }
        
        if(allMembersToUpdate.size()>0){
            system.debug('allMembersTOUpdate>>>>'+allMembersTOUpdate);
            List<Team_Member__c> finalteamMembersToUpdate = new List<Team_Member__c>();
            for(Team_Member__c tm: allMembersToUpdate){
                boolean flag = false;
                for(Team__c t: TeamsToUpdate){
                    if(tm.which_team__c == t.id)
                        flag = true;
                }
                
                if(flag == false)
                    finalteamMembersToUpdate.add(tm);
            }
            
            update finalteamMembersToUpdate;
        }   
        
        if(casesToUpdate.size() > 0)
            update casesToUpdate;
        
        if(teamsToUpdate.size() > 0)
            update teamsToUpdate;   
        
        return caseIdToTeamMemberID; 
    } 
    
    public static void resetAllocationCountersOfTeam(List<Team_Member__c> tmembers){
        
        List<Team_Member__c> tmembersToUpdate = new List<Team_Member__c>();
        
        for(Team_Member__c tm: tmembers){
            tm.allocation_counter__c = tm.allocation__c * 10;
            tmembersToUpdate.add(tm);
        }
        
        update tmembersToUpdate;
        
    }
    
    public static Boolean checkAllocationCountersOfTeam(List<Team_Member__c> tmembers){
        
        for(Team_Member__c tm: tmembers){
            if(tm.allocation_counter__c >0)
                return false;
        }
        
        return true;
    }
    
    public static Team_Member__c getTeamMemberWithHighestAllocationCounter(List<Team_Member__c> tmembers, id previousownerid){
        system.debug('tmembers>>>>'+tmembers); 
        Team_Member__c selectedTeamMember = new Team_Member__c();
        selectedTeamMember.allocation_counter__c = -100;
        
        for(Team_Member__c tm: tmembers){
            if(tm.allocation_counter__c > selectedTeamMember.allocation_counter__c && tm.allocation_counter__c > 0 && tm.id != previousownerid)
                selectedTeamMember = tm;
        }
        
        if(selectedTeamMember.id == null && tmembers!=null && tmembers.size()>0)
            selectedTeamMember = TMembers[0];
        
        system.debug('selectedTeamMember>>>>'+selectedTeamMember);
        return selectedTeamMember;
            
    }
    
    public static Team_Member__c getTeamMemberWithSecondHighestAllocationCounter(List<Team_Member__c> tmembers, id previousownerid){
        system.debug('tmembers>>>>'+tmembers); 
        Team_Member__c selectedTeamMember = new Team_Member__c();
        Team_Member__c selectedTeamMember2 = new Team_Member__c();
        selectedTeamMember = tmembers[0];
        selectedTeamMember2.allocation_counter__c = -100;
        
        for(Team_Member__c tm: tmembers){
            if(tm.allocation_counter__c > selectedTeamMember.allocation_counter__c && tm.allocation_counter__c > 0)  
                selectedTeamMember = tm;
        }
        
        for(Team_Member__c tm: tmembers){
            if(tm.allocation_counter__c > selectedTeamMember2.allocation_counter__c  && tm.allocation_counter__c < selectedTeamMember.allocation_counter__c && tm.allocation_counter__c > 0 && tm.id != previousownerid)
                selectedTeamMember2 = tm;
        }
        
        if(selectedTeamMember2.id == null && tmembers!=null && tmembers.size()>0)
            selectedTeamMember2 = tmembers[0];
        system.debug('selectedTeamMember2>>>>'+selectedTeamMember2);
        
        return selectedTeamMember;
        
    }

}