public without sharing class ProspectAdminFlowControllerToggle {
    
    public class TeamAvailability{
        public id userId {get; set; }
        public String name {get; set; }
        public Boolean checkboxVF {get; set; }
    }
    
    public List<ProspectAdminFlowControllerToggle.TeamAvailability> teamAvailList {get; set; }
    public String loggedInuser {get; set; }
    public boolean inactive {get; set; }
    public boolean checkboxVF {get; set; }
    public Map<Id, Boolean> userIdToCheckboxVF {get; set;}
    public Map<Id, String> userIdToName {get; set;}
    
    public List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
    public Set<Id> profileIds = new Set<Id>();
    
    public ProspectAdminFlowControllerToggle(){
        teamAvailList = new List<ProspectAdminFlowControllerToggle.TeamAvailability>();
        userIdToCheckboxVF = new Map<Id, Boolean>();
        userIdToName = new Map<Id, String>();
        loggedInuser = UserInfo.getUserId();
        User u = [Select id, Prospect_Inactive__c from User where Id = :loggedInuser];
        
        checkboxVF = !u.Prospect_Inactive__c;
        System.Debug('ProspectAdminFlowControllerToggle -- '+checkboxVF);
        campusContactList();
            
    }
    public PageReference handleUser(){
        User u = new User(Id = loggedInuser);
        u.Prospect_Inactive__c = !checkboxVF;
        update u;
        //checkboxVF = !checkboxVF;
        System.Debug('handleUser -- '+checkboxVF);
        updateTeamMemebrs(loggedInuser, checkboxVF);
        return null;
    }
    public PageReference handleUserBulk(){
        System.Debug('loggedInuser -- '+loggedInuser);
        User u = new User(Id = loggedInuser);
        Boolean assignmentDone = false;
        
        System.Debug('teamAvailList -- '+teamAvailList);
        
        boolean vfcheckbox = false;
        for(ProspectAdminFlowControllerToggle.TeamAvailability thisAvail : teamAvailList){
            if(thisAvail.userId == loggedInuser){
                u.Prospect_Inactive__c = !thisAvail.checkboxVF;
                vfcheckbox = thisAvail.checkboxVF;
                assignmentDone = true;
                break;
            }
        }
        
        if(assignmentDone)
            update u;
        updateTeamMemebrs(loggedInuser, vfcheckbox );
        //checkboxVF = !checkboxVF;
        System.Debug('handleUser -- '+checkboxVF);
        return null;
    }
    public void updateTeamMemebrs(id loggedInuser, Boolean checkboxVF){
        List<Team_Member__c> teamMemberList = [Select Id, Active__c, Who_Id__c from Team_Member__c where Who_Id__c = :loggedInUser];
        List<Team_Member__c> teamMembersToUpdate = new List<Team_Member__c>();
        Map<Id, List<Team_Member__c>> whoIdToTeamMember = new Map<Id, List<Team_Member__c>>();
        for(Team_Member__c thisMember : teamMemberList){
            List<Team_Member__c> teamMemberTempList = new List<Team_Member__c>();
            if(whoIdToTeamMember != null && whoIdToTeamMember.containsKey(thisMember.Who_Id__c)){
                teamMemberTempList = whoIdToTeamMember.get(thisMember.Who_Id__c);
            }
            teamMemberTempList.add(thisMember);
            whoIdToTeamMember.put(thisMember.Who_Id__c, teamMemberTempList);
        }
        if(whoIdToTeamMember != null && whoIdToTeamMember.containsKey(loggedInuser)){
            List<Team_Member__c> teamMembersTemp = whoIdToTeamMember.get(loggedInuser);
            for(Team_Member__c thisMember : teamMembersTemp){
                thisMember.Active__c = checkboxVF;
                teamMembersToUpdate.add(thisMember);
            }
        }
        
        if(teamMembersToUpdate != null && teamMembersToUpdate.size() > 0){
            update teamMembersToUpdate;
        }
        
        
        
        
    }
    public void campusContactList(){
        
        profList = Prospect_Profiles__c.getall().values();          
            
            if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
            
            system.debug('profileIds'+profileIds);
        
        List<Campus_Contacts__c> allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id, c.Employee__r.FirstName, c.Employee__r.LastName,
                                                             c.Employee__c, c.Employee__r.Prospect_Inactive__c,  c.Email__c, c.Active_User__c,c.Employee__r.ProfileId 
                                                             From Campus_Contacts__c c 
                                                         where c.Active_User__c =: 'ACTIVE'
                                                         order by c.Employee__r.FirstName];
        
        system.debug('PROFILESIDS'+profileIds);
        system.debug('PROFILES'+allCampusContacts);                                              
                                                         
        Id loggedInuserAccountId = null;
        for(Campus_Contacts__c thisCampusContact : allCampusContacts){
            if(thisCampusContact.Employee__c == UserInfo.getUserId()){
                loggedInuserAccountId = thisCampusContact.Organization__c;
            }
        }
        if(loggedInuserAccountId != null){
            for(Campus_Contacts__c thisCampusContact : allCampusContacts){
                ProspectAdminFlowControllerToggle.TeamAvailability thisTeamAvail = new ProspectAdminFlowControllerToggle.TeamAvailability();
                if(thisCampusContact.Organization__c == loggedInuserAccountId){
                    if(thisCampusContact.Employee__c == UserInfo.getUserId() || !(profileIds.contains(thisCampusContact.Employee__r.ProfileId))){
                        continue;
                    }
                    thisTeamAvail.checkboxVF = !thisCampusContact.Employee__r.Prospect_Inactive__c;
                    thisTeamAvail.userId = thisCampusContact.Employee__c;
                    thisTeamAvail.name = thisCampusContact.Employee__r.FirstName + ' '+(thisCampusContact.Employee__r.LastName).substring(0, 1);
                    teamAvailList.add(thisTeamAvail);
                    /*
                    userIdToCheckboxVF.put(thisCampusContact.Employee__c, !thisCampusContact.Employee__r.Prospect_Inactive__c);
                    userIdToName.put(thisCampusContact.Employee__c, thisCampusContact.Employee__r.FirstName);*/
                }
            }
        }   
    }
    
    
}