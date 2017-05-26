public without sharing class ProspectUserAvailabilityController {
    
    public class TeamAvailability{
        public id userId {get; set; }
        public String name {get; set; }
        public Boolean checkboxVF {get; set; }
    }
    
    public List<ProspectUserAvailabilityController.TeamAvailability> teamAvailList {get; set; }
    public String loggedInuser {get; set; }
    public boolean inactive {get; set; }
    public boolean checkboxVF {get; set; }
    public id orgId {get; set; }
    public Map<Id, Boolean> userIdToCheckboxVF {get; set;}
    public Map<Id, String> userIdToName {get; set;}
    public Map<Id, List<Team_Member_Availability__c>> orgIdToMemberAvail {get; set; }
    public Map<id,String> accIdToName {get; set; }
    public Map<id, List<ProspectUserAvailabilityController.TeamAvailability>> orgIdToTeamAvailList {get; set;}
    
    public List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
    public Set<Id> profileIds = new Set<Id>();
    
    public ProspectUserAvailabilityController(){
        teamAvailList = new List<ProspectUserAvailabilityController.TeamAvailability>();
        userIdToCheckboxVF = new Map<Id, Boolean>();
        userIdToName = new Map<Id, String>();
        loggedInuser = UserInfo.getUserId();
        User u = [Select id, Prospect_Inactive__c from User where Id = :loggedInuser];
        
        checkboxVF = !u.Prospect_Inactive__c;
        accIdToName = new Map<id,String> ();
        orgIdToMemberAvail = new Map<Id, List<Team_Member_Availability__c>>();
        orgIdToTeamAvailList = new Map<id, List<ProspectUserAvailabilityController.TeamAvailability>> ();
        system.Debug('ProspectUserAvailabilityController -- '+checkboxVF);
 //       campusContactList();
  		campusContactListMultipleAccounts();
 //       system.Debug('campusContactList -- '+teamAvailList);
        system.Debug('campusContactListMultipleAccounts -- '+teamAvailList);
        
            
    }
    public PageReference handleUser(){
        User u = new User(Id = loggedInuser);
        u.Prospect_Inactive__c = !checkboxVF;
        update u;
        List<Team_Member_Availability__c> tmaUpd = new List<Team_Member_Availability__c>();
        List<Team_Member_Availability__c> tma = new List<Team_Member_Availability__c>();
        tma = [Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c from Team_Member_Availability__c where Which_user__c = :loggedInuser limit 1];
        if(tma!=null && tma.size()>0)
        {
            tma[0].Is_Team_Member_Available__c = checkboxVF;
            tma[0].Process_this_availability__c = true;
            tma[0].Widget_Override__c = true;
            tmaUpd.add(tma[0]);
            System.Debug('handleUser -- '+checkboxVF);
            
            if(tmaUpd!=null && tmaUpd.size()>0)
            {
                update tmaUpd;
            }
        }
        return null;
    }
    public PageReference handleUserBulk(){
        System.Debug('loggedInuser -- '+loggedInuser);
        system.debug('in handleuserbulk-->>');
        User u = new User(Id = loggedInuser);
        Team_Member_Availability__c tma = [Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c from Team_Member_Availability__c where Which_user__c = :loggedInuser limit 1];
        Boolean assignmentDone = false;
        
        System.Debug('teamAvailList -- '+teamAvailList);
        if(teamAvailList!=null && teamAvailList.size()>0)
        {
            boolean vfcheckbox = false;
            for(ProspectUserAvailabilityController.TeamAvailability thisAvail : teamAvailList){
                if(thisAvail.userId == loggedInuser){
                    u.Prospect_Inactive__c = !thisAvail.checkboxVF;
                    tma.Is_Team_Member_Available__c = thisAvail.checkboxVF;
                    tma.Process_this_availability__c = true;
                    tma.Widget_Override__c = true;
                    assignmentDone = true;
                    break;
                }
            }
        }
        
        
        if(assignmentDone)
        {
            update tma;
            update u;
        }
           
        System.Debug('handleUser -- '+checkboxVF);
        return null;
    }
    
    public PageReference handleUserBulkMultiAccount(){
        System.Debug('loggedInuser -- '+loggedInuser);
        system.debug('in handleuserbulk-->>');
        User u = new User(Id = loggedInuser);
        Team_Member_Availability__c tma = [Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c,Which_Account__c from Team_Member_Availability__c where Which_user__c = :loggedInuser limit 1];
        Boolean assignmentDone = false;
        system.debug('tma-->>'+tma);
        system.debug('tma.Which_Account__c-->>'+tma.Which_Account__c);
        system.debug('orgIdToTeamAvailList.get(tma.Which_Account__c)-->>'+orgIdToTeamAvailList.get(tma.Which_Account__c));
        // null check and contains check
        
        if(tma !=null && orgIdToTeamAvailList.get(tma.Which_Account__c) != null)
        {
        	teamAvailList = orgIdToTeamAvailList.get(tma.Which_Account__c);
        }
     // sObject to update   
     	List<sObject> thisUpdate = new List<sObject>();
        System.Debug('teamAvailList -- '+teamAvailList);
        if(teamAvailList!=null && teamAvailList.size()>0)
        {
            boolean vfcheckbox = false;
            for(ProspectUserAvailabilityController.TeamAvailability thisAvail : teamAvailList){
                if(thisAvail.userId == loggedInuser){
                    u.Prospect_Inactive__c = !thisAvail.checkboxVF;
                    tma.Is_Team_Member_Available__c = thisAvail.checkboxVF;
                    tma.Process_this_availability__c = true;
                    tma.Widget_Override__c = true;
                    assignmentDone = true;
                    thisUpdate.add(tma);
                    thisUpdate.add(u);
                    break;
                }
            }
        }
        if(assignmentDone)
        {
        	if(thisUpdate != null && thisUpdate.size() > 0)
        	{ 
        		update thisUpdate;
        	}
        //    update tma;
        //    update u;
        }
           
        System.Debug('handleUser -- '+checkboxVF);
        return null;
    }
    
    
    public void campusContactListMultipleAccounts(){
        
        profList = Prospect_Profiles__c.getall().values();          
            
        if(profList != null && profList.size() > 0){
            for(Prospect_Profiles__c pid : profList){
                profileIds.add(pid.ProfileId__c);
            }       
        }
        system.debug('profileIds'+profileIds);
            
        System.Debug('loggedInuser -- '+loggedInuser);
        List<Campus_Contacts__c> allCampContactsList = [SELECT c.Title__c, c.Organization__c, c.Name, c.Id, c.Employee__r.FirstName, c.Employee__r.LastName,
                                                             	c.Employee__c, c.Employee__r.Prospect_Inactive__c,  c.Email__c, c.Active_User__c,c.Employee__r.ProfileId 
                                                        FROM Campus_Contacts__c c 
                                                        WHERE c.Active_User__c =: 'ACTIVE'];
                                                                                                                		
        System.Debug('allCampContactsList -- '+allCampContactsList);                                                 		
       // Store unique account ids in a set
        Set<id> acctIdSet = new Set<id>();   
        if(allCampContactsList != null && allCampContactsList.size() > 0)
        {                                              		
	        for(Campus_Contacts__c cc : allCampContactsList)
	        {
	        	if(cc.Employee__c == loggedInuser)
	        	{
	        		acctIdSet.add(cc.Organization__c);	
	        	}
	        }     
        }
        System.debug('acctIdSet-->>'+acctIdSet);
       // create map of account id to name for displaying purpose 
       // I created list of Account because I want map of account id to account name
       List<String> loggedInuserAccountId = new List<String>();
       if(acctIdSet.size() > 0)
       {
        	List<Account> loggedInuserAccountsList = [Select id,Name From Account Where id in :acctIdSet];
	        System.debug('loggedInuserAccountsList-->>'+loggedInuserAccountsList);
	        if(loggedInuserAccountsList != null && loggedInuserAccountsList.size() > 0)
	        {
		        for(Account acc: loggedInuserAccountsList)
		        {
		        	loggedInuserAccountId.add(acc.id);
		        	accIdToName.put(acc.id,acc.Name);
		        } 
	        }
       } 
       
       System.debug('loggedInuserAccountId-->>'+loggedInuserAccountId);
        system.debug('PROFILESIDS'+profileIds);
        system.debug('accIdToName-->>'+accIdToName);  
        if(allCampContactsList != null && allCampContactsList.size() > 0)
        {
        	for(Campus_Contacts__c thisCampusContact : allCampContactsList)
        	{
        		ProspectUserAvailabilityController.TeamAvailability thisTeamAvail = new ProspectUserAvailabilityController.TeamAvailability();
        	// null check map	
        		if(acctIdSet != null && acctIdSet.size() > 0)
        		{
	        		if(orgIdToTeamAvailList.containsKey(thisCampusContact.Organization__c) && acctIdSet.contains(thisCampusContact.Organization__c))
	        		{
	        			system.debug('in if-->>');
	        			system.debug('thisCampusContact.Organization__c-->>'+thisCampusContact.Organization__c);	
	        			// create a map of org id to list of teamAvailList
	        			if(thisCampusContact.Employee__c == loggedInuser || !(profileIds.contains(thisCampusContact.Employee__r.ProfileId))){
	                        continue;
	                    }
	                    thisTeamAvail.checkboxVF = !thisCampusContact.Employee__r.Prospect_Inactive__c;
	                    thisTeamAvail.userId = thisCampusContact.Employee__c;
	                    thisTeamAvail.name = thisCampusContact.Employee__r.FirstName + ' '+(thisCampusContact.Employee__r.LastName).substring(0, 1);
	           //         teamAvailList.add(thisTeamAvail);
	                    system.debug('teamAvailList-->>'+teamAvailList);
	               // ***create list first then add to list and then create a  map
		                teamAvailList = orgIdToTeamAvailList.get(thisCampusContact.Organization__c);
		                teamAvailList.add(thisTeamAvail);
	                  //  orgIdToTeamAvailList.get(thisCampusContact.Organization__c).add(thisTeamAvail);
	                    system.debug('orgIdToTeamAvailList.get(thisCampusContact.Organization__c)-->>'+orgIdToTeamAvailList.get(thisCampusContact.Organization__c));
	                    
	            //     orgIdToTeamAvailList.put(thisCampusContact.Organization__c,teamAvailList);
	                     system.debug('orgIdToTeamAvailList-->>'+orgIdToTeamAvailList);
	        		}
	        		else
	        		{
	        			system.debug('in else-->>');
	        	// null check		
	        			if(acctIdSet != null && acctIdSet.contains(thisCampusContact.Organization__c))
	        			{
	        				system.debug('thisCampusContact.Organization__c 2-->>'+thisCampusContact.Organization__c);
		        			if(thisCampusContact.Employee__c == loggedInuser || !(profileIds.contains(thisCampusContact.Employee__r.ProfileId))){
		                        continue;
		                    }
		                    thisTeamAvail.checkboxVF = !thisCampusContact.Employee__r.Prospect_Inactive__c;
		                    thisTeamAvail.userId = thisCampusContact.Employee__c;
		                    thisTeamAvail.name = thisCampusContact.Employee__r.FirstName + ' '+(thisCampusContact.Employee__r.LastName).substring(0, 1);
		            //        teamAvailList.add(thisTeamAvail);
		                    system.debug('teamAvailList 2-->>'+teamAvailList);
		                    orgIdToTeamAvailList.put(thisCampusContact.Organization__c,new List<ProspectUserAvailabilityController.TeamAvailability>{thisTeamAvail});
		                     system.debug('orgIdToTeamAvailList 2-->>'+orgIdToTeamAvailList);
	        			}
	        		}
        		}	
        		
        	}
        }
       	system.debug('teamAvailList final-->>'+teamAvailList);
   		system.debug('orgIdToTeamAvailList final-->>'+orgIdToTeamAvailList);
    }
    
   
 /*   public void getTeamMemberAvailList(){
         List<Campus_Contacts__c> loggedInCampusContact = [Select c.Title__c, c.Organization__c, c.Name, c.Id, c.Employee__r.FirstName, c.Employee__r.LastName,
                                                             c.Employee__c, c.Employee__r.Prospect_Inactive__c,  c.Email__c, c.Active_User__c,c.Employee__r.ProfileId 
                                                             From Campus_Contacts__c c 
                                                         where c.Active_User__c =: 'ACTIVE' and c.Employee__c =: UserInfo.getUserId() 
                                                         limit 1];
        Id loggedInuserAccountId = null;
        if(loggedInCampusContact!=null && loggedInCampusContact.size()>0)
        {
            for(Campus_Contacts__c thisCampusContact :loggedInCampusContact)
            {
                loggedInuserAccountId = thisCampusContact.Organization__c;
            }
        }
        if(loggedInuserAccountId!=null)
        {
            List<Team_Member_Availability__c> teamMemAvail = [Select t.id, t.user_available__c, t.Which_user__r.FirstName, t.Which_user__r.LastName, t.Which_user__c, t.Is_Team_Member_Available__c 
                                                                From Team_Member_Availability__c t where t.Which_account__c =: loggedInuserAccountId 
                                                                order by t.Which_user__r.FirstName];
            for(Team_Member_Availability__c tma: teamMemAvail)
            {
                ProspectUserAvailabilityController.TeamAvailability thisTeamAvail = new ProspectUserAvailabilityController.TeamAvailability();
                if(tma.Which_user__c == UserInfo.getUserId()){
                   continue;
                }
                    thisTeamAvail.checkboxVF = tma.Is_Team_Member_Available__c;
                    thisTeamAvail.userId = tma.Which_user__c;
                    thisTeamAvail.name = tma.Which_user__r.FirstName + ' '+(tma.Which_user__r.LastName).substring(0, 1);
                    teamAvailList.add(thisTeamAvail);
            }
        }
    }*/
    
    /*
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
                ProspectUserAvailabilityController.TeamAvailability thisTeamAvail = new ProspectUserAvailabilityController.TeamAvailability();
                if(thisCampusContact.Organization__c == loggedInuserAccountId){
                    if(thisCampusContact.Employee__c == UserInfo.getUserId() || !(profileIds.contains(thisCampusContact.Employee__r.ProfileId))){
                        continue;
                    }
                    thisTeamAvail.checkboxVF = !thisCampusContact.Employee__r.Prospect_Inactive__c;
                    thisTeamAvail.userId = thisCampusContact.Employee__c;
                    thisTeamAvail.name = thisCampusContact.Employee__r.FirstName + ' '+(thisCampusContact.Employee__r.LastName).substring(0, 1);
            //        thisTeamAvail.orgId = thisCampusContact.Organization__c; // Girija added
                    teamAvailList.add(thisTeamAvail);
					
                }
            }
        }   
    }  */
    
}