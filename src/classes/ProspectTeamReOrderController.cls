public without sharing class ProspectTeamReOrderController {
    
    public class TeamInfo{
        public Id teamId {get; set; }
        public String teamName {get; set; }
        public Decimal currentTeamOrder {get; set; }
        public Decimal prevTeamOrder {get; set; }
        public Id prevTeamId {get; set; }
        public Decimal nextTeamOrder {get; set; }
        public Id nextTeamId {get; set; }
    }
    
    
    public Id teamIdToWorkWith {get; set; }
    public List<ProspectTeamReOrderController.TeamInfo> teamInfoList {get; set; }
    public Map<Id, ProspectTeamReOrderController.TeamInfo> teamIdToTeamInfo = new Map<Id, ProspectTeamReOrderController.TeamInfo>();
    private final Account acct;    

    public ProspectTeamReOrderController(ApexPages.StandardController controller)
    {
        this.acct = (Account)controller.getRecord();
        
        getTeams();
    
    }    
    
    public PageReference getTeams()
    {
        teamInfoList = new List<ProspectTeamReOrderController.TeamInfo>();
        List<Team__c> teams = new List<Team__c>(); 
        teams = [Select t.id,t.Team_Name__c, Team_Order__c 
                  From Team__c t 
                  WHERE t.Team_Account__c = :acct.id and t.Active__c = true and Default_Team__c = false
                  ORDER BY t.Team_Order__c asc];
        
        List<Id> tIds = new List<Id>();
        List<String> tNames = new List<String>();
        
        Decimal teamOrder = 0;
        Integer teamsize = teams.size();
        for(Integer i = 0; i< teams.size(); i++)
        {
            Team__c currentTeam = null;// teams[i];
            Team__c prevTeam = null;
            Team__c nextTeam = null;
            currentTeam = teams[i];
            try{
                prevTeam = teams[i-1];
            }catch(Exception e){
                System.Debug('Previous Team does not exist');
            }
            try{
                nextTeam = teams[i+1];
            }catch(Exception e){
                System.Debug('Next Team does not exist');
            }
            
            
            
            ProspectTeamReOrderController.TeamInfo teamInfo = new ProspectTeamReOrderController.TeamInfo();
            teamInfo.currentTeamOrder = (currentTeam != null ? currentTeam.Team_Order__c : 0);
            teamInfo.prevTeamOrder = (prevTeam != null ? prevTeam.Team_Order__c : -1);
            teamInfo.prevTeamId = (prevTeam != null ? prevTeam.Id : null);
            teamInfo.nextTeamOrder = (nextTeam != null ? nextTeam.Team_Order__c : 100000);
            teamInfo.nextTeamId = (nextTeam != null ? nextTeam.Id : null);
            teamInfo.teamId = currentTeam.Id;
            teamInfo.teamName = currentTeam.Team_Name__c;
            teamInfoList.add(teamInfo);
            teamIdToTeamInfo.put(currentTeam.id, teamInfo);
            
        }
        
        return null;        
    }
    public PageReference moveTeamUp(){
        List<Team__c> updateThisTeam = new List<Team__c>();
        if(teamIdToTeamInfo != null && teamIdToTeamInfo.containsKey(teamIdToWorkWith)){
            ProspectTeamReOrderController.TeamInfo teamInfo = teamIdToTeamInfo.get(teamIdToWorkWith);
            Team__c thisTeam = new Team__c(id = teamIdToWorkWith);
            thisTeam.Team_Order__c = teamInfo.prevTeamOrder;
            updateThisTeam.add(thisTeam);
            if(teamInfo.prevTeamId != null){
                Team__c prevTeam = new Team__c(id = teamInfo.prevTeamId);
                prevTeam.Team_Order__c = teamInfo.currentTeamOrder;
                updateThisTeam.add(prevTeam);
            }
        }
        if(updateThisTeam != null && updateThisTeam.size() > 0){
            Database.update(updateThisTeam, false);
        }
        getTeams();
    return null;
    }
    public PageReference moveTeamDown(){
        List<Team__c> updateThisTeam = new List<Team__c>();
        if(teamIdToTeamInfo != null && teamIdToTeamInfo.containsKey(teamIdToWorkWith)){
            ProspectTeamReOrderController.TeamInfo teamInfo = teamIdToTeamInfo.get(teamIdToWorkWith);
            Team__c thisTeam = new Team__c(id = teamIdToWorkWith);
            thisTeam.Team_Order__c = teamInfo.nextTeamOrder;
            updateThisTeam.add(thisTeam);
            if(teamInfo.nextTeamId != null){
                Team__c nextTeam = new Team__c(id = teamInfo.nextTeamId);
                nextTeam.Team_Order__c = teamInfo.currentTeamOrder;
                updateThisTeam.add(nextTeam);
            }
        }
        if(updateThisTeam != null && updateThisTeam.size() > 0){
            Database.update(updateThisTeam, false);
        }
        getTeams();
    return null;
    }
    
}