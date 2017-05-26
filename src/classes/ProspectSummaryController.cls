public without sharing class ProspectSummaryController {

	private final Account acct;  
	public List<Id> tIds {get; set; }
	public List<String> tNames {get; set; }
	public List<String> ruleIdsFromTeam {get; set; }
	public Map<Id,String> teamNametoId {get; set; }
	public Map<Id,String> ruletoTeam {get; set; }
	public String teamId {get; set; }
	public String accountId {get; set; }
	public String teamName {get; set; }
	public Map<String,List<String>> teamRuleSummary {get; set; }
	public Boolean teamExempt {get; set;}
	public String teamOrder {get;set;}
	
	
	public List<String> displayRuleSummary {get; set; }
	
	public Map<Id, List<Team_Member__c>> teamIdToMemberList {get; set; }
	public Map<Id, Team__c> teamIdToTeam = null;
	public Map<Id, PRO_Rule__c> ruleIdToRule = null;
	public Map<Id, List<PRO_Rule_Set__c>> ruleidToRuleSetList =  null;
	
	public ProspectSummaryController()
	{

	}
	
	public ProspectSummaryController(ApexPages.StandardController controller)
   	{
   		this.acct = (Account)controller.getRecord();
 		List<Team__c> teams = new List<Team__c>(); 
 		accountId = acct.id;
		teams = [Select t.id,t.Team_Name__c, t.Team_Rule__c
				  From Team__c t  
				  WHERE t.Team_Account__c = :acct.id
				  AND t.Active__c = true
				  ORDER BY t.Team_Order__c];
		
		tIds = new List<Id>();
		tNames = new List<String>();
		teamNametoId = new Map<Id,String>();
		ruletoTeam = new Map<Id,String>();
		ruleIdsFromTeam = new List<String>();
		for(Team__c tm : teams)
		{
			tIds.add(tm.id);
			tNames.add(tm.Team_Name__c);
			teamNametoId.put(tm.id,tm.Team_Name__c);
			ruleIdsFromTeam.add(tm.Team_Rule__c);
			ruleToTeam.put(tm.Team_Rule__c,tm.id);
		}
		
		System.debug('ruleIdsFromTeam!!!--->'+ruleIdsFromTeam);
		displayRuleSummary = new List<String>();
		teamRuleSummary = new Map<String,List<String>>();
		queryAndPopulateMap();
		teamDet = getTeamDet();
		
   	}
	
	public void queryAndPopulateMap(){
		teamIdToTeam = new Map<Id, Team__c> ([Select t.Team_Rule__c, t.id, t.Team_Name__c, t.ESC_Exempt__c, t.Team_Order__c,t.Default_Team__c From Team__c t where t.Team_Account__c = :accountId and t.Active__c = true ORDER BY t.Team_Order__c]);
		ruleIdToRule = new Map<Id, PRO_Rule__c>([SELECT p.Name, p.Id, p.Formula__c FROM PRO_Rule__c p WHERE p.Academic_Institution__c = :accountId]);
		List<Team_Member__c> tmDet = new List<Team_Member__c>([Select t.Which_Team__r.Team_Account__c, t.Which_Team__c, t.Which_Team__r.Active__c, t.id, t.Who_Id__r.Name, t.Allocation__c,t.Active__c From Team_Member__c t where t.Which_Team__r.Team_Account__c = :accountId and t.Which_Team__r.Active__c = true]);
		List<PRO_Rule_Set__c> ruleSet = [SELECT p.Value__c, p.Sequence__c, p.Rule__c, p.Operator__c, p.Object_Name__c, p.Name, p.Id, p.Field_Name__c FROM PRO_Rule_Set__c p WHERE p.Rule__r.Academic_Institution__c = :accountId ORDER BY p.Sequence__c];
		ruleidToRuleSetList = new Map<Id, List<PRO_Rule_Set__c>>();
		for(PRO_Rule_Set__c thisRuleSet : ruleSet){
			List<PRO_Rule_Set__c> tempRuleSetList = new List<PRO_Rule_Set__c>();
			if(ruleidToRuleSetList != null && ruleidToRuleSetList.containsKey(thisRuleSet.Rule__c)){
				tempRuleSetList = ruleidToRuleSetList.get(thisRuleSet.Rule__c);
			}
			tempRuleSetList.add(thisRuleSet);
			ruleidToRuleSetList.put(thisRuleSet.Rule__c, tempRuleSetList);
		}
		teamIdToMemberList = new Map<Id, List<Team_Member__c>>();
		for(Team_Member__c tm : tmDet){
			List<Team_Member__c> tempTeamMemberList = new List<Team_Member__c>();
			if(teamIdToMemberList != null && teamIdToMemberList.containsKey(tm.Which_Team__c)){
				tempTeamMemberList = teamIdToMemberList.get(tm.Which_Team__c);
			}
			tempTeamMemberList.add(tm);
			teamIdToMemberList.put(tm.Which_Team__c, tempTeamMemberList);
			
		}
	
	}
	
	public String getteamName(){
		System.debug('-->'+teamNametoId);
		System.debug('-->'+teamId);
    	return teamNametoId.get(teamId);
	}
	

	public class teamDetail
	{
		public String tId {get; set;}
		public String tNm {get; set;}
		public Team__c team {get; set;}
		public List<String> ruleDetail {get; set;}
		public Boolean excFlag {get; set;}
		public String tOrder {get; set;}
		public Boolean defTeam {get; set;}
		
		public Map<Id,String> mNameMap {get; set;}
		public Map<Id,String> mAllocMap {get; set;}
		public Map<Id,String> mStatusMap {get; set;}
		public ProspectSummaryController control {get; set;}
		
		public teamDetail(Team__c tm, ProspectSummaryController psc)
		{
			this.control = psc;
			team = tm;
			this.tId = tm.id;
			this.tNm = tm.Team_Name__c;
			this.ruleDetail = loadRuleSummary(tm.Id);
			this.excFlag = tm.ESC_Exempt__c;
			this.tOrder = String.valueOf(tm.Team_Order__c);
			this.defTeam = tm.Default_Team__c;
			
			List<Team_Member__c> tmDetails = getMemberDetails(tm.id);
			this.mNameMap = loadMemberNameMap(tmDetails);
			this.mAllocMap = loadMemberAllocMap(tmDetails);
			this.mStatusMap = loadMemberStatusMap(tmDetails);
		}
		
		public List<Team_Member__c> getMemberDetails(Id teamId)
		{
			List<Team_Member__c> tmDet = new List<Team_Member__c>();
			if(this.control != null && this.control.teamIdToMemberList != null && this.control.teamIdToMemberList.get(teamId) != null){
				tmDet = this.control.teamIdToMemberList.get(teamId);
			}
			 
			return tmDet;
		}
		
		public Map<Id,String> loadMemberNameMap(List<Team_Member__c> tmDet)
		{
			Map<Id,String> mNameMap = new Map<Id,String>();
			for(Team_Member__c tm: tmDet)
	    		{
	    			mNameMap.put(tm.id,tm.Who_Id__r.Name);
	    		}
 
    		return mNameMap;	
		}
		public Map<Id,String> loadMemberAllocMap(List<Team_Member__c> tmDet)
		{
			Map<Id,String> mAllocMap = new Map<Id,String>();
			for(Team_Member__c tm: tmDet)
	    		{
	    			mAllocMap.put(tm.id,String.valueOf((tm.Allocation__c*100).setScale(1)));
	    		}
 
    		return mAllocMap;	
		}
		public Map<Id,String> loadMemberStatusMap(List<Team_Member__c> tmDet)
		{
			Map<Id,String> mStatusMap = new Map<Id,String>();
			for(Team_Member__c tm: tmDet)
	    		{
	    			if(tm.Active__c)
	    			{
	    				mStatusMap.put(tm.id,'Active');
	    			}else
	    			{
	    				mStatusMap.put(tm.id,'Inactive');
	    			}
	    		}
 
    		return mStatusMap;	
		}
		
		
		 public List<String> loadRuleSummary(Id tm_Id)
		 {
		   		List<String> displayRuleSummary = new List<String>();
		   	// take rule Ids from Team__c object	
		   		List<Team__c> teamRuleIds = new List<Team__c>();
		   		if(this.control != null && this.control.teamIdToTeam != null && this.control.teamIdToTeam.get(tm_Id) != null){
		   			teamRuleIds.add(this.control.teamIdToTeam.get(tm_Id)); //[SELECT t.Team_Rule__c, t.Id,t.Team_Name__c FROM Team__c t WHERE t.Id =: tm_Id];
		   		}
		   		List<ID> ruleIdsFromTeam = new List<ID>();
		   		for(Team__c rid : teamRuleIds)
		   		{
		   			if(rid.Team_Rule__c!=null){
		   			ruleIdsFromTeam.add(rid.Team_Rule__c);
		   			}
		   		}
		   		
		   		if(ruleIdsFromTeam.size()>0)
		   		{
		   		
		   // fetch rule ids from PRO_Rule__c which belongs to particular team		
		   		List<PRO_Rule__c> proRuleInfo = new List<PRO_Rule__c>();
		   		for(Id thisRuleId : ruleIdsFromTeam){
		   			if(this.control != null && this.control.ruleidToRule != null && this.control.ruleidToRule.get(thisRuleId) != null){
		   				proRuleInfo.add(this.control.ruleidToRule.get(thisRuleId));
		   			}
		   		}
		   		/*proRuleInfo = [SELECT p.Name, p.Id, p.Formula__c 
		   					   FROM PRO_Rule__c p 
		   					   WHERE p.Id in :ruleIdsFromTeam];*/
		   					   
		   		List<ID> rIdFromPRORule = new List<ID>();
		   		for(PRO_Rule__c prc : proRuleInfo) 	
		   		{
		   			rIdFromPRORule.add(prc.Id);
		   		}
		   		Map<Id,String> ruleFormula = new Map<Id, String>();
		   		for(PRO_Rule__c prc : proRuleInfo) 	
		   		{
		   			ruleFormula.put(prc.Id,prc.Formula__c);
		   		}			   
		   		 		
		   		List<PRO_Rule_Set__c > ruleSet = new List<PRO_Rule_Set__c >();
		   		for(Id thisRuleId : rIdFromPRORule){
		   			if(this.control != null && this.control.ruleIdToRuleSetList != null && this.control.ruleIdToRuleSetList.get(thisRuleId) != null){
		   			    ruleSet.addAll(this.control.ruleIdToRuleSetList.get(thisRuleId));
		   			}
		   		}
		   		/*ruleSet = [SELECT p.Value__c, p.Sequence__c, p.Rule__c, p.Operator__c, 
		   						  p.Object_Name__c, p.Name, p.Id, p.Field_Name__c 
		   				   FROM PRO_Rule_Set__c p 
		   				   WHERE p.Rule__c in :rIdFromPRORule
		   				   ORDER BY p.Sequence__c];*/
		   		Map <Id,String> displayRuleMap = new Map<Id, String>();
		   		   		
		   		for(Integer i=0; i<ruleSet.size(); i++)
		   		{
		   			String display = '';
		   			// Logic to get Field Label
		   			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		    		Schema.SObjectType leadSchema = schemaMap.get(ProspectUtils.getObjectAPIName(ruleSet[i].Object_Name__c));
					Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
					String fieldLbl = fieldMap.get(ruleSet[i].Field_Name__c).getDescribe().getLabel();//It provides to get the object fields label.
					
		   			if(i==0)
		   			{
		   				display = ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
						displayRuleMap.put(ruleSet[i].Rule__c, display);
		
		   			}else
		   			{
		   				if(displayRuleMap.containsKey(ruleSet[i].Rule__c))
		   				{
		   					display = displayRuleMap.get(ruleSet[i].Rule__c) + ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
		   					displayRuleMap.remove(ruleSet[i].Rule__c);
		   					displayRuleMap.put(ruleSet[i].Rule__c, display);
		   				}else
		   				{
		   					display = ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
		   					displayRuleMap.put(ruleSet[i].Rule__c, display);
		   				}
		   				
		   			}
		   			
		   		}
		   		
		   		for(PRO_Rule__c prc : proRuleInfo) 	
		   		{
		   			String displayText = displayRuleMap.get(prc.Id);
		   			String formula = ruleFormula.get(prc.Id);
		   			displayRuleMap.remove(prc.Id);
		   			displayRuleMap.put(prc.Id, displayText + formula);
		   			
		   		}
		   		
		   		List<Id> ruleIds = new List<Id>();
		   		Set<Id> ruleIdSet = new Set<Id>();
		   		ruleIdSet = displayRuleMap.keySet();
		   		ruleIds.addAll(ruleIdSet);
		   		
		   		for(Integer i=0; i<ruleIds.size(); i++)
		   		{
		   			displayRuleSummary.add(displayRuleMap.get(ruleIds[i]));
		   	//		displayRuleSummary.add(ruleIds[i], displayRuleMap.get(ruleIds[i]));
		   		}
		   		
		     	
		  	 	
		   	
		   		}
		   		//teamRuleSummary.put(tm_Id, displayRuleSummary);
			return displayRuleSummary;
			
		}
		
		
	}
	
	public List<teamDetail> teamDet {get; set; }
	public List<teamDetail> getTeamDet() 
    {
    	if(teamDet==null)
    	{
    		teamDet = new List<teamDetail>();
    	}else
    	{
    		teamDet.clear();
    	}
    		
	    		for(Team__c tm: teamIdToTeam.values())
	    		{
	    			teamDet.add(new teamDetail(tm, this));
	    		}
    	
    	List<teamDetail> sortedTeamDet = new List<teamDetail>();
    	for(teamDetail tD: teamDet)
    	{
    		if(!tD.defTeam)
    		{
    			sortedTeamDet.add(tD);
    		}
    	}
    	for(teamDetail tD: teamDet)
    	{
    		if(tD.defTeam)
    		{
    			sortedTeamDet.add(tD);
    		}
    	}
    	return sortedTeamDet;

    }
  /* public List<String> getRuleSummary(Id tId)
   {

   		system.debug('teamRuleSummary-->123'+teamRuleSummary);
   		return teamRuleSummary.get(tId);
   }*/
	

    
}