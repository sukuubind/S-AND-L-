public without sharing class ProspectAdminFlowController {
    Account account;
    Team__c team;
    Team_Member__c member;

    
    
    
    public Boolean step1 {get; set; }
    public Boolean step2 {get; set; }
    public Boolean step3 {get; set; }
    public Boolean step4 {get; set; }
    public Boolean createRule {get; set; }
    public Boolean editRule {get; set; }
    public Boolean createTeam {get; set; }
    public Boolean chooseTeam {get; set; }
    public Boolean cloneTeam {get; set; }
    public String acctName {get; set; }
    public String teamId {get; set; }
    public String teamName {get; set; }
    public Boolean teamExempt {get; set; }
    public Boolean teamAndMemSaved {get; set; }
    public Boolean isError { get; set; }
    public Boolean validated { get; set; }
    public Boolean verified { get; set; }
    public Boolean eqAlloc {get; set; }
    public Boolean memberListchanged {get; set;}
    
    public Integer rulesAdded {get; set; }
   
    public Boolean emptyRule {get; set; }
    public String ruleSetId {get; set; }
    public String RSToRem {get; set; }

    public List<selectOption> selectTeams {get; set;}
    public String selectedTeam {get; set;}
    
    public List<Campus_Contacts__c> allCampusContacts {get; set; }
    //All Campus Contacts under an Account
    public List<User> allAccUserList {get; set; }
    public List<selectOption> selectAccUsers {get; set;}
    public List<String> selectedUsers {get; set; }
    //All Members of a team
    public List<Team_Member__c> teamMemberList {get; set; }
    public List<selectOption> selectTeamMembers {get; set;}
    public List<String> selectedMembers {get; set; }
    // All Campus Contacts not part of a team
    public List<User> otherUserList {get; set; }
    public List<selectOption> selectOtherUsers {get; set;}
    public List<String> allOtherUsers {get; set; }
    //List of Team Members followed by other campoous contacts not part of the team
  
    //STEP 3
    public List<SelectOption> allRuleSets {get; set; }
    public List<String> ruleSets {get; set; }
    public List<String> selectedRule {get; set;}
    public List<String> displayRuleSummary {get; set; }
    public String selectedRuleSummary {get; set;}
    
    
    //CREATE RULE
    public Boolean isSRP {get; set; }
    public Id accountOwner {get; set;}
    public List<selectOption> objectTypes {get; set; }
    public List<selectOption> assocFieldSets {get; set; }
    public List<selectOption> operatorList {get; set; }
    public List<PRO_Rule_Set__c> ruleSetsToInsert {get; set; }
    public List<String> insertedRuleSets {get; set; }
    public String ruleId {get; set; }
    public Map<String,String> fieldAPILabelMap {get; set; }
    
    public List<Prospect_Profiles__c> profList = new List<Prospect_Profiles__c>();
    public List<Id> profileIds = new List<Id>();

    
    // WRAPPER 1
    public List<teamMember> members {get; set; }
 
    public class teamMember
    {
        public Team_Member__c tmMem {get; set;}
        public Boolean selected {get; set;}
        public String memberName {get; set;}
        public Id memId {get; set;}
        public Id memUsrId {get; set;}
        
        public teamMember(Team_Member__c tMem)
        {
            tmMem = tMem;
            this.selected = true;
            this.memberName = tMem.Who_Id__r.Name;
            this.memId = tMem.id;
            this.memUsrId = tMem.Who_Id__c;
        }
    }
    
    // WRAPPER 2
    public List<otherUser> otherUsers {get; set;}
    public List<otherUser> allUsers {get; set;}

    public class otherUser
    {
        public User user {get; set;}
        public Boolean selected {get; set;}
        public String usrName {get; set;}
        
        public Id usrId {get; set;}
        
        public otherUser(User usr)
        {
            user = usr;
            this.selected = false;
            this.usrName = usr.Name;
            this.usrId = usr.id;
        }
    }
    
    // CREATE RULE WRAPPER
    public class PRORuleSetField
    {
        public String fieldValue {get; set; }
        public String[] fieldValueList {get; set; }
        public Boolean fieldRequired {get; set; }
        
        public PRORuleSetField(String fieldVal, Boolean fieldReq){
            this.fieldValue = fieldVal;
            this.fieldRequired = fieldReq;
        }
    }
    
    public PRORuleSetField objType {get; set; }
    public PRORuleSetField sequenceNo {get; set; }
    public PRORuleSetField fieldName {get; set; }
    public PRORuleSetField operator {get; set; }
    public PRORuleSetField value {get; set; }
    public PRORuleSetField formula {get; set; }
    
    public void initiatePRORuleSetFields()
    {
        validated = true;
        objType = new PRORuleSetField('',false);
        sequenceNo = new PRORuleSetField('',false);
        fieldName = new PRORuleSetField('',false);
        operator = new PRORuleSetField('',false);
        value = new PRORuleSetField('',false);
        formula = new PRORuleSetField('',false);
    }
    
    public void setRequired(PRORuleSetField thisField, Boolean required){
    thisField.fieldRequired = required;
    }
    
    public void renderPRORuleSetFields()
    {
        setRequired(objType, true);
        setRequired(sequenceNo, true);
        setRequired(fieldName, true);
        setRequired(operator, true);
        setRequired(value, true);
        setRequired(formula,true);
    }
    // WRAPPER 3
    public class MemberAllocField
    {
        public String fieldValue {get; set; }
        public String[] fieldValueList {get; set; }
        public Boolean fieldRequired {get; set; }
        public Team_Member__c tmMem {get; set;}
        public String memberName {get; set; }
        public Decimal memberAllocation {get; set; }
        public Id memberId {get; set; }
        public String status {get; set; }
        public Boolean memberStatus {get; set; }
        
        public MemberAllocField(Team_Member__c tMem)
        {
            tmMem = tMem;
            this.memberName = tMem.Who_Id__r.Name;
            this.memberAllocation = ((tMem.Allocation__c)*100).setScale(1);
            this.memberId = tMem.id;
            if(tMem.Active__c)
            {
                this.Status = 'Active';
            }else
            {
                this.Status = 'Inactive';
            }
            this.memberStatus = tMem.Active__c;
            
        }
        public MemberAllocField(String fieldVal, Boolean fieldReq){
            this.fieldValue = fieldVal;
            this.fieldRequired = fieldReq;
        }
        public MemberAllocField(String memNm, String memAllocation)
        {
            tmMem = new Team_Member__c();
            
            tmMem.Allocation__c = Decimal.valueOf(memAllocation);
        }
    }
    
    
    public MemberAllocField memName {get; set; }
    public MemberAllocField memAlloc {get; set; }
    public List<MemberAllocField> memAllocList {get; set; }
   
    
    public void initiateMemberAllocFields()
    {
        verified = true;
        memName = new MemberAllocField('',false);
        memAlloc = new MemberAllocField('',false);
    }
    
    public void setMemRequired(MemberAllocField thisField, Boolean required){
    thisField.fieldRequired = required;
    }
    
    public void renderMemberAllocFields()
    {
        setMemRequired(memName, true);
        setMemRequired(memAlloc, true);

    }
    
    // WRAPPER 4 - RULES AND RULE SETS
    public List<ruleSets> addedRuleSets {get; set;}
    public List<ruleSets> chosenRuleSet {get; set;}

    public class ruleSets
    {
        public PRO_Rule_Set__c ruleSet {get; set;}
        public Boolean remove {get; set;}
        public String ruleSetDetail {get; set;}
        
        public Id rsId {get; set;}
        
        public ruleSets(PRO_Rule_Set__c rs)
        {
            ruleSet = rs;
            this.remove = false;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(ProspectUtils.getObjectAPIName(rs.Object_Name__c));
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            String fieldLbl = fieldMap.get(rs.Field_Name__c).getDescribe().getLabel();//It provides to get the object fields label.
            
            this.ruleSetDetail = rs.Sequence__c+'-'+rs.Object_Name__c+'.'+fieldLbl+' '+rs.Operator__c+' '+rs.Value__c;
            this.rsId = rs.id;
        }
    }
    public String defaultTeamName {get; set; }
    public Id defaultTeamId {get; set; }
    public Boolean isDefault {get; set; }
    public ProspectAdminFlowController(ApexPages.StandardController controller)
    {
            this.account = (Account)controller.getRecord();
            
            List<Account> acctNm = new List<Account>();

            acctNm = getAccountName();
            for(Account acc:acctNm)
            {
                acctName = acc.Name;
            }
            isSRP=ProspectUtils.getAccountType(account.Id);
            accountOwner=ProspectUtils.getAccountOwner(account.Id);
            teamAndMemSaved = false;
            List<Team__c> teamNames = new List<Team__c> ();
            teamNames = ProspectUtils.getTeamDetails(account.Id);
            List<selectOption> sortedSelectTeams = new List<selectOption>();
            selectTeams = new List<selectOption> ();
            for(Team__c teamNm: teamNames)
            {
                if(teamNm.Default_Team__c == true){
                    defaultTeamName = teamNm.Team_Name__c;
                    if(defaultTeamName==null)
                    {
                        defaultTeamName = 'EMPTY';
                    }
                    defaultTeamId = teamNm.Id;
                }
                String tName = teamNm.Team_Name__c;
                if (tName==null)
                {
                    tName = 'EMPTY';
                }
                if(!teamNm.Default_Team__c)
                {
                	sortedSelectTeams.add(new SelectOption(teamNm.Id, tName));
                }
                selectTeams.add(new SelectOption(teamNm.Id, tName));
            }
            sortedSelectTeams.add(new SelectOption(defaultTeamId, defaultTeamName));
            if(selectTeams.size()==sortedSelectTeams.size())
            {
            	selectTeams = sortedSelectTeams;
            }
           
            cloneTeam = false;
            isDefault = false;
            
            profList = Prospect_Profiles__c.getall().values();
            
            
            if(profList != null && profList.size() > 0)
            {
                for(Prospect_Profiles__c pid : profList)
                {
                    profileIds.add(pid.ProfileId__c);
                }       
            }
            system.debug('Profile List'+profileIds);
         
    }
       
 // Girija : Added this function to validate radio button . Also added if condition in step2Choose() function
    public Boolean validateRadio()
    {
        if(selectedTeam == null)
        {
             isError = true;
             return false;
        }
        else   
        {
            isError = false;
            return true;
        }   
        return false;   
    }
    
    public Account getAccount()
    {
        if(account == null) account = new Account();
        return account;
    }
    
    public Team__c getTeam()
    {
        if(team == null) team = new Team__c(id=teamId);
        return team;
    }
    
    public Team_Member__c getMember()
    {
        if(member == null) member = new Team_Member__c();
        return member;
    }
    
    

    public PageReference review() {
        
        step1 = false;
        step2 = false;
        step3 = false;
        step4 = false;
        createRule = false;
        editRule = false;
        
        
      return Page.ProspectAdminFlowReview;
    }

    public PageReference step1() {
        
        step1 = true;
        step2 = false;
        step3 = false;
        step4 = false;
        createRule = false;
        editRule = false;
        createTeam = false;
        chooseTeam = false;
        cloneTeam = false;
        selectedTeam = null;
        emptyRule = false;
        teamId = null;
        teamName = null;
        isDefault = false;
        List<Team__c> teamNames = new List<Team__c> ();
        teamNames = ProspectUtils.getTeamDetails(account.Id);
        List<selectOption> sortedSelectTeams = new List<selectOption>();
        selectTeams = new List<selectOption> ();
        for(Team__c teamNm: teamNames)
        {
            if(teamNm.Default_Team__c == true){
                defaultTeamName = teamNm.Team_Name__c;
                if(defaultTeamName==null)
                {
                    defaultTeamName = 'EMPTY';
                }
                defaultTeamId = teamNm.Id;
            }
            String tName = teamNm.Team_Name__c;
            if (tName==null)
            {
                tName = 'EMPTY';
            }
            if(!teamNm.Default_Team__c)
            {
                sortedSelectTeams.add(new SelectOption(teamNm.Id, tName));
            }
            selectTeams.add(new SelectOption(teamNm.Id, tName));
        }
        sortedSelectTeams.add(new SelectOption(defaultTeamId, defaultTeamName));
        if(selectTeams.size()==sortedSelectTeams.size())
        {
        	selectTeams = sortedSelectTeams;
        }
      return Page.ProspectAdminFlowStep1;
    }
    public PageReference selectDefault(){
        id oldDefaultId = defaultTeamId;
        isError = false;
        if(validateRadio()){
            List<Team__c> objs = new List<Team__c>();
            objs = [Select p.Id, p.Team_Name__c, p.Active__c From Team__c p where p.id =:selectedTeam];
            String tName = '';
            List<Team__c> teamsToUpdate = new List<Team__c>();
            for(Team__c r: objs){
                r.Default_Team__c = true;
                defaultTeamName = r.Team_Name__c;
                defaultTeamId = r.Id;
                if(oldDefaultId==defaultTeamId)
                {
                    isError = true;
                }else
                {
                    teamsToUpdate.add(r);
                }
            }
            if(!isError)
            {
                Team__c removeTeamAsDefault = new Team__c(id = oldDefaultId);
                removeTeamAsDefault.Default_Team__c = false;
                teamsToUpdate.add(removeTeamAsDefault);
            }
            if(teamsToUpdate != null && teamsToUpdate.size() > 0){
                Database.update(teamsToUpdate, false);
            }
            
        }else
        {
            System.debug('validateRadio False-->'+selectedTeam);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_Team_Error));
        }
    return null;
    }
    public PageReference deleteTeam()
    {
        if(validateRadio())
        {
            System.debug('validateRadio True-->'+selectedTeam);
            List<Team__c> objs = new List<Team__c>();
            objs = [Select p.Id, p.Team_Name__c, p.Active__c From Team__c p where p.id =:selectedTeam];
            String tName = '';
            List<Team__c> teamToDel = new List<Team__c>();
      
                for(Team__c r: objs){
                    tName = r.Team_Name__c;
                      Team__c r2 = r;
                      r2.Active__c = false;
                      teamToDel.add(r2);
                    
                  }
      
          if(teamToDel.size()>0)
          {
            try{
                    update(teamToDel);
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    isError = true;
                    
                }

          }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Team: '+tName+' has been deleted!'));
            isError = true;
            step1();
        }else
        {
            System.debug('validateRadio False-->'+selectedTeam);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_Team_Error));
            //return Page.ProspectAdminFlowStep1;
        }
        return null;
    }
    
    public PageReference step2Choose() {
        Boolean proceed = false;
        if(teamId==null)
        {
            proceed = validateRadio();
        }else
        {
            proceed = true;
            selectedTeam = teamId;
        }
        if(proceed)
        {
            step1 = false;
            step2 = true;
            step3 = false;
            step4 = false;
            createRule = false;
            editRule = false;
            emptyRule = false;
            isError = false;
            allAccUserList = new List<User>();
            selectAccUsers = new List<SelectOption>();
            selectedUsers = new List<String>();
            
            teamMemberList = new List<Team_Member__c>();
            selectTeamMembers = new List<SelectOption>();
            selectedMembers = new List<String>();
            
            otherUserList = new List<User>();
            selectOtherUsers = new List<SelectOption>();
            allOtherUsers = new List<String>();
            
            createTeam = false;
            chooseTeam = true;
            cloneTeam = false;
            System.debug('Team Id!!!--->'+selectedTeam);
            
            List<Team__c> teamSelected = new List<Team__c>();
            teamSelected = [SELECT t.Team_Name__c, t.Team_Account__r.Name, t.Name, t.Id, t.ESC_Exempt__c, t.Team_Rule__c FROM Team__c t WHERE t.Id=: selectedTeam];
        
            for(Team__c tm: teamSelected)
            {
                teamId = tm.id;
                teamName = tm.Team_Name__c;
                teamExempt = tm.ESC_Exempt__c;
                if(tm.Team_Rule__c==null)
                {
                    emptyRule = true;
                    ruleId = null;
                }
            }
            System.debug('Team Id!!!--->'+teamId);
            System.debug('Team Name!!!--->'+teamName);
            if(defaultTeamId == teamId)
            {
                isDefault = true;
            }
            
            allCampusContacts = new List<Campus_Contacts__c>();
            allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
            selectedUsers.clear();
            selectedMembers.clear();
            allOtherUsers.clear();
            
            if(members!=null)
            members.clear();
        
            if(otherUsers!=null)
            otherUsers.clear();
        
            if(allUsers!=null)
            allUsers.clear();
            
            getTeamMembers();
            getOtherUsers();
            System.debug('members-->'+members);
            System.debug('otherUsers-->'+otherUsers);
            //createFormattedList(teamId);
            
            isError = false;
            return Page.ProspectAdminFlowStep2;
        }   
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_Team_Error));
            return Page.ProspectAdminFlowStep1;
        }
       
        return null;
    }
    public PageReference step2Create() {
        step1 = false;
        step2 = true;
        step3 = false;
        step4 = false;
        createRule = false;
        editRule = false;
        createTeam = true;
        chooseTeam = false;
        isError = false;
        teamId = null;
        selectedTeam=null;
        teamName = null;
        ruleId=null;
        
        if(members!=null)
        members.clear();
        
        if(otherUsers!=null)
        otherUsers.clear();
        
        if(allUsers!=null)
        allUsers.clear();
        
        allAccUserList = new List<User>();
        selectAccUsers = new List<SelectOption>();
        selectedUsers = new List<String>();
        
        teamMemberList = new List<Team_Member__c>();
        selectTeamMembers = new List<SelectOption>();
        selectedMembers = new List<String>();
        
        otherUserList = new List<User>();
        selectOtherUsers = new List<SelectOption>();
        allOtherUsers = new List<String>();
        
        selectedUsers.clear();
        selectedMembers.clear();
        allOtherUsers.clear();
        
        allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        
        getAllUsers();
        
        //loadAllAccUserList();
        
      return Page.ProspectAdminFlowStep2;
    }
    /*
    public PageReference loadMembers()
    {
        if(createTeam && selectedUsers.size()>0)
        {
            List<Campus_Contacts__c> otherCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         and c.Id not in : selectedUsers];
            List<Id> campusContacts = new List<Id>(); 
            for(Campus_Contacts__c ap: otherCampusContacts){
                campusContacts.add(ap.Employee__c);
            }                                        
        
            allAccUserList = [Select u.id, u.Name From User u where u.Id in: campusContacts];
            for(User accUsr: allAccUserList)
            {
                selectAccUsers.add(new SelectOption(accUsr.Id, accUsr.Name));
            }
            List<User> teamUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: selectedUsers]);
            for(User tr: teamUsr)
            {
                selectTeamMembers.add(new SelectOption(tr.Id, tr.Name));
            }
            
        }
        List<SelectOption> membersToKeep = new List<SelectOption>();
        List<SelectOption> otherUsersToKeep = new List<SelectOption>();
        if(chooseTeam)
        {
            if(selectedMembers.size()<teamMemberList.size())
            {
                List<Campus_Contacts__c> otherCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         and c.Id not in : selectedMembers];
                List<Id> campusContacts = new List<Id>(); 
                for(Campus_Contacts__c ap: otherCampusContacts){
                    campusContacts.add(ap.Employee__c);
                }
                List<User> othrUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: campusContacts]);
                for(User otr: othrUsr)
                {
                    otherUsersToKeep.add(new SelectOption(otr.Id, otr.Name));
                }
                List<User> teamUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: selectedMembers]);
                for(User tr: teamUsr)
                {
                    membersToKeep.add(new SelectOption(tr.Id, tr.Name));
                }
                
            }
            if(selectedMembers.size()<teamMemberList.size())
            {
                List<Campus_Contacts__c> otherCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         and c.Id not in : selectedMembers];
                List<Id> campusContacts = new List<Id>(); 
                for(Campus_Contacts__c ap: otherCampusContacts){
                    campusContacts.add(ap.Employee__c);
                }
                List<User> othrUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: campusContacts]);
                for(User otr: othrUsr)
                {
                    otherUsersToKeep.add(new SelectOption(otr.Id, otr.Name));
                }
                List<User> teamUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: selectedMembers]);
                for(User tr: teamUsr)
                {
                    membersToKeep.add(new SelectOption(tr.Id, tr.Name));
                }
                
            }
            
        }
        /*List<Campus_Contacts__c> allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'];
        List<Id> campusContacts = new List<Id>(); 
        for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
         }
        if(createTeam)
        {
            
            List<User> chosenUser = new List<User>([Select u.id, u.Name From User u where u.Id in: selectedUsers and u.Id in: selectedMembers]);
            List<User> othrUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: campusContacts and u.Id not in: selectedUsers and u.Id not in: selectedMembers]);
            if(chosenUser.size()<0)
            {
                selectTeamMembers.clear();
                for(User tr: chosenUser)
                {
                    selectTeamMembers.add(new SelectOption(tr.Id, tr.Name));
                }
            }
            if(othrUsr.size()<0)
            {
                selectAccUsers.clear();
                for(User tr: othrUsr)
                {
                    selectAccUsers.add(new SelectOption(tr.Id, tr.Name));
                }
            }
            
            
        }
        if(chooseTeam)
        {
            
            List<User> chosenUser = new List<User>([Select u.id, u.Name From User u where u.Id in: allOtherUsers and u.Id in: selectedMembers]);
            List<User> othrUsr = new List<User>([Select u.id, u.Name From User u where u.Id in: campusContacts and u.Id not in: allOtherUsers and u.Id not in: selectedMembers]);
            if(chosenUser.size()<0)
            {
                selectTeamMembers.clear();
                for(User tr: chosenUser)
                {
                    selectTeamMembers.add(new SelectOption(tr.Id, tr.Name));
                }
            }
            if(othrUsr.size()<0)
            {
                selectOtherUsers.clear();
                for(User tr: othrUsr)
                {
                    selectOtherUsers.add(new SelectOption(tr.Id, tr.Name));
                }
            }
            
        }*/
        /*return null;
    }*/
    
    public Boolean validateSelection()
    {
        if(chooseTeam || cloneTeam)
        {
            if((selectedMembers == null) || (selectedMembers.size() ==0))
            {
                if((allOtherUsers == null) || (allOtherUsers.size() ==0))
                {
                    isError = true;
                    return false;
                }else
                {
                    isError = false;
                    return true;
                }
                
            }
            else
            {
                isError = false;
                return true;
            }
        }
        if(createTeam)
        {
            if ((selectedUsers == null) || (selectedUsers.size() ==0))
            {
                isError = true;
                return false;
            }
            else
            {
                isError = false;
                return true;
            }
        }
        return false;
    }
    
    public PageReference step3() {
        if(chooseTeam)
        {
            getSelectedMembers();
            getSelectedOtherUsers();
        }
        if(createTeam)
        {
            getSelectedUsers();
        }
        if(cloneTeam)
        {
            getSelectedMembers();
            getSelectedOtherUsers();
        }
        
        if(validateSelection())
        {
            if(teamName==null || teamName=='')
            {
                isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Empty_Team_Name));
                return Page.ProspectAdminFlowStep2;
            }else
            {
                step1 = false;
                step2 = false;
                step3 = true;
                step4 = false;
                createRule = false;
                editRule = false;
                isError = false;
                memberListChanged = false;
                
                saveTeamAndTeamMembers();//HAS to set isError based on Save Errors with proper Page Messages****
                System.debug('Account Id!!!--->'+account.id);
                System.debug('Team Id!!!--->'+teamId);
                System.debug('Selected Users!!!--->'+selectedUsers);
                System.debug('Selected Members!!!--->'+selectedMembers);
                System.debug('Other Users!!!--->'+allOtherUsers);
                
                displayRuleSummary = new List<String>(); 
                getRuleSummary(teamId);
                
                       
               //   allRuleSets = new List<SelectOption>();
               //   getAllRulesAndRuleSets(account.id,teamid);
                
                isError = false;
                return Page.ProspectAdminFlowStep3;
            }
      
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_User_Error));
            return Page.ProspectAdminFlowStep2;
        }
        return null;
    }
    
    public PageReference getSelectedMembers()
    {
        selectedMembers.clear();
        for(teamMember tmSel: members)
        {
            if(tmSel.selected == true) {
            selectedMembers.add(tmSel.memUsrId);
            }
        }
        System.debug('selectedMembers!-->'+selectedMembers);
        
        return null;
    }
    
    public PageReference getSelectedOtherUsers()
    {
        allOtherUsers.clear();
        for(otherUser oUsr: otherUsers)
        {
            if(oUsr.selected == true) {
            allOtherUsers.add(oUsr.usrId);
            }
        }
        System.debug('allOtherUsers!-->'+allOtherUsers);
        
        return null;
    }
    
    public PageReference getSelectedUsers()
    {
        selectedUsers.clear();
        for(otherUser oUsr: allUsers)
        {
            if(oUsr.selected == true) {
            selectedUsers.add(oUsr.usrId);
            }
        }
        System.debug('allUsers!-->'+allUsers);
        
        return null;
    }
    
   /* public Decimal getAllocation()
    {
        Decimal allocation = 0.0;
        Integer mCount = memAllocList.size();
        Integer tAlloc = 0;
        for(MemberAllocField mAlloc: memAllocList)
        {
            Integer rem = math.mod(100,mCount);
            Integer val = 100/mCount;
            if(rem>0)
            {
                
                tAlloc = tAlloc+val;
                if(100-tAlloc >rem)
                {
                    mAlloc.memberAllocation = val;
                }else if(100-tAlloc ==rem)
                {
                    mAlloc.memberAllocation = val+rem;
                }
            }
            
        }
        
        return allocation;
    }*/
    
    public PageReference saveTeamAndTeamMembers()
    {
        allCampusContacts = new List<Campus_Contacts__c>();
        allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
        
        if(createTeam)
            {
                Team__c team = new Team__c();
                team.Team_Name__c = teamName;
                team.Team_Account__c = account.Id;
                team.OwnerId = accountOwner;
                team.ESC_Exempt__c = teamExempt;
                Integer maxOrd = 0;
                List<AggregateResult> maxOrder = new List<AggregateResult>([Select t.Team_Account__c, MAX(t.Team_Order__c) From Team__c t where t.Team_Account__c = :account.id and t.Active__c = true group by t.Team_Account__c ]);
                if(maxOrder!=null && maxOrder.size()>0)
                {
                    for(AggregateResult res: maxOrder)
                    {
                        System.debug('MaxOrder-->'+Integer.valueOf(res.get('expr0')));
                        maxOrd = Integer.valueOf(res.get('expr0'));
                    }
                }
                team.Team_Order__c = (maxOrd != null ? maxOrd : 0) +1;
                insert team;
                teamId = team.id;
                //TEAM MEMBER ADDITION
                List<Team_Member__c> teamMembersToAdd = new List<Team_Member__c>();
                if(selectedUsers!=null && selectedUsers.size()>0)
                {
                    List<User> selUsr = new List<User>([Select u.id, u.Name From User u where u.Id in :selectedUsers]);
                    Integer usrCount = selUsr.size();
                    Integer tAlloc = 0;
                    Decimal allocShare = Decimal.valueOf(100)/usrCount;
                    Decimal rounded = allocShare.setScale(1, RoundingMode.HALF_UP);
                    Decimal roundedLast = (100-(rounded*(usrCount-1))).setScale(1);
                    System.debug('allocShare-->'+allocShare);
                    System.debug('rounded-->'+rounded);
                    Integer rem = math.mod(100,usrCount);
                    Integer val = 100/usrCount;
                    System.debug('val-->'+val);
                    System.debug('rem-->'+rem);
                    for(User u: selUsr)
                    {
                        Team_Member__c tm = new Team_Member__c();
                        tm.Who_Id__c = u.id;
                        tm.Which_Team__c = teamId;
                        Decimal allocation = 0.0;
                        if(rem>0)
                        {
                            tAlloc = tAlloc+val;
                            System.debug('tAlloc-->'+tAlloc);
                            if(100-tAlloc >rem)
                            {
                                allocation = ((rounded)/100).setScale(3);
                                System.debug('allocation-->'+allocation);
                            }else if(100-tAlloc ==rem)
                            {
                                allocation = ((roundedLast)/100).setScale(3);
                                System.debug('allocation1-->'+allocation);
                            }
                        }else if(rem==0)
                        {
                            allocation = (Decimal.valueOf(val)/100).setScale(3);
                            System.debug('allocation2-->'+allocation);
                        }
                        System.debug('Allocation-->'+allocation);
                        tm.Allocation__c = allocation;
                        
                        teamMembersToAdd.add(tm);
                    }
                    
                    //Select t.Who_Id__c, t.Which_Team__c, t.Allocation__c From Team_Member__c t
                }
                System.Debug('teamMembersToAdd-->'+teamMembersToAdd);
                if(teamMembersToAdd != null && teamMembersToAdd.size() > 0)
                {
                    try{
                        Database.insert(teamMembersToAdd, false);
                        teamAndMemSaved = true;
                        //RESET LISTS
                        getTeamMembers();
                        getOtherUsers();
                        getAllUsers();
                    }catch(Exception e){
                        System.Debug('Here - error!!!');
                        System.Debug(e);
                    }
                }
            }
            else if(chooseTeam)
            {

                Team__c team = new Team__c(id=teamId);
                team.Team_Name__c = teamName;
                team.ESC_Exempt__c = teamExempt;
                
                update team;
                
                List<Id> campusContacts = new List<Id>(); 
                for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
                }
                
                // TEAM MEMBER REMOVAL AND MEMBER ALLOCATION UPDATE
                List<Team_Member__c> teamMembersToDel = new List<Team_Member__c>();
                List<Team_Member__c> teamMembersToUpd = new List<Team_Member__c>();
                System.debug('Selected Members!!!--->'+selectedMembers);
                System.debug('Other Users!!!--->'+allOtherUsers);
                
                memberListchanged = false;
                if(selectedMembers.size()<teamMemberList.size())
                {
                    memberListchanged = true;
                    teamMembersToDel = [Select t.Id From Team_Member__c t where t.Which_Team__c = :teamId and t.Who_Id__c not in : selectedMembers and t.Who_Id__c in: campusContacts and t.Active__c = true];
                    
                    if(teamMembersToDel != null && teamMembersToDel.size() > 0)
                    {
                        try{
                            Database.delete(teamMembersToDel, false);
                            teamAndMemSaved = true;
                        }catch(Exception e){
                            System.Debug(e);
                        }
                    }
                    
                }
                
                //TEAM MEMBER ADDITION
                List<Team_Member__c> teamMembersToAdd = new List<Team_Member__c>();

                if(allOtherUsers!=null && allOtherUsers.size()>0)
                {
                    memberListchanged = true;
                    List<User> selUsr = new List<User>([Select u.id, u.Name From User u where u.Id in :allOtherUsers]);
                    for(User u: selUsr)
                    {
                        Team_Member__c tm = new Team_Member__c();
                        tm.Who_Id__c = u.id;
                        tm.Which_Team__c = teamId;
                        Decimal allocation = 0.0;
                        
                        tm.Allocation__c = allocation;
                        
                        teamMembersToAdd.add(tm);
                    }
                    
                    //Select t.Who_Id__c, t.Which_Team__c, t.Allocation__c From Team_Member__c t
                }
                if(teamMembersToAdd != null && teamMembersToAdd.size() > 0)
                {
                    try{
                        Database.insert(teamMembersToAdd, false);
                        teamAndMemSaved = true;
                    }catch(Exception e){
                        System.Debug(e);
                    }
                }
                teamMembersToUpd = [Select t.Id, t.Allocation__c From Team_Member__c t where t.Which_Team__c = : teamId];
                Integer totalMemCount = teamMembersToUpd.size();
                Decimal allocShare = Decimal.valueOf(100)/totalMemCount;
                Decimal rounded = allocShare.setScale(1, RoundingMode.HALF_UP);
                Decimal roundedLast = (100-(rounded*(totalMemCount-1))).setScale(1);
                System.debug('allocShare-->'+allocShare);
                System.debug('rounded-->'+rounded);
                Integer tAlloc = 0;
                Integer rem = math.mod(100,totalMemCount);
                Integer val = 100/totalMemCount;
                
                System.debug('val-->'+val);
                System.debug('rem-->'+rem);
                
                if(memberListChanged)
                {
                    
                    System.debug('teamMembersToUpd-->'+teamMembersToUpd);
                    if(teamMembersToUpd != null && teamMembersToUpd.size() > 0)
                    {
                        List<Team_Member__c> teamMemToUpdate = new List<Team_Member__c>();
                        for(Team_Member__c tm: teamMembersToUpd)
                        {
                            Team_Member__c tm2 = tm;
                            Decimal allocation = 0.0;
                        
                            if(rem>0)
                            {
                                tAlloc = tAlloc+val;
                                System.debug('tAlloc-->'+tAlloc);
                                if(100-tAlloc >rem)
                                {
                                    allocation = ((rounded)/100).setScale(3);
                                    System.debug('allocation-->'+allocation);
                                }else if(100-tAlloc ==rem)
                                {
                                    allocation = ((roundedLast)/100).setScale(3);
                                    System.debug('allocation1-->'+allocation);
                                }
                            }else if(rem==0)
                            {
                                allocation = (Decimal.valueOf(val)/100).setScale(3);
                                System.debug('allocation2-->'+allocation);
                            }
                            System.debug('Allocation-->'+allocation);
                            tm2.Allocation__c = allocation;
                            
                            teamMemToUpdate.add(tm2);
                        }
                        if(teamMemToUpdate.size()>0)
                            update(teamMemToUpdate);
                    }
                    //RESET LISTS
                        getTeamMembers();
                        getOtherUsers();
                        getAllUsers();
                }
                
                
                
            }else if(cloneTeam)
            {
                Team__c team = new Team__c();
                team.Team_Name__c = teamName;
                team.Team_Account__c = account.Id;
                team.OwnerId = accountOwner;
                team.ESC_Exempt__c = teamExempt;
                Integer maxOrd = 0;
                List<AggregateResult> maxOrder = new List<AggregateResult>([Select t.Team_Account__c, MAX(t.Team_Order__c) From Team__c t where t.Team_Account__c = :account.id group by t.Team_Account__c ]);
                if(maxOrder!=null && maxOrder.size()>0)
                {
                    for(AggregateResult res: maxOrder)
                    {
                        System.debug('MaxOrder-->'+Integer.valueOf(res.get('expr0')));
                        maxOrd = Integer.valueOf(res.get('expr0'));
                    }
                }
                if(maxOrd==null)
                {
                	maxOrd = 0;
                }
                team.Team_Order__c = maxOrd+1;
                insert team;
                teamId = team.id;
                //TEAM MEMBER ADDITION
                List<Team_Member__c> teamMembersToAdd = new List<Team_Member__c>();
                System.debug('Selected Members!!!--->'+selectedMembers);
                System.debug('Other Users!!!--->'+allOtherUsers);
                Integer totalMemCount = (selectedMembers.size()) + (allOtherUsers.size());
                Integer tAlloc = 0;
                Integer rem = math.mod(100,totalMemCount);
                Integer val = 100/totalMemCount;
                System.debug('val-->'+val);
                System.debug('rem-->'+rem);
                if(allOtherUsers!=null && allOtherUsers.size()>0)
                {
                    List<User> selUsr = new List<User>([Select u.id, u.Name From User u where u.Id in :allOtherUsers]);
                    
                    
                    for(User u: selUsr)
                    {
                        Team_Member__c tm = new Team_Member__c();
                        tm.Who_Id__c = u.id;
                        tm.Which_Team__c = teamId;
                        Decimal allocation = 0.0;
                        
                        tm.Allocation__c = allocation;
                        
                        teamMembersToAdd.add(tm);
                    }
                
                }
                if(selectedMembers!=null && selectedMembers.size()>0)
                {
                    List<User> selUsr = new List<User>([Select u.id, u.Name From User u where u.Id in :selectedMembers]);
                    for(User u: selUsr)
                    {
                        Team_Member__c tm = new Team_Member__c();
                        tm.Who_Id__c = u.id;
                        tm.Which_Team__c = teamId;
                        Decimal allocation = 0.0;
                        
                        
                        tm.Allocation__c = allocation;
                        
                        teamMembersToAdd.add(tm);
                    }
        
                }
                if(teamMembersToAdd != null && teamMembersToAdd.size() > 0)
                {
                    try{
                        Database.insert(teamMembersToAdd, false);
                        teamAndMemSaved = true;
                        
                    }catch(Exception e){
                        System.Debug(e);
                    }
                }
                List<Team_Member__c> teamMembersToUpd = new List<Team_Member__c>();
                teamMembersToUpd = [Select t.Id, t.Allocation__c From Team_Member__c t where t.Which_Team__c = : teamId];
                    System.debug('teamMembersToUpd-->'+teamMembersToUpd);
                Decimal allocShare = Decimal.valueOf(100)/totalMemCount;
                Decimal rounded = allocShare.setScale(1, RoundingMode.HALF_UP);
                Decimal roundedLast = (100-(rounded*(totalMemCount-1))).setScale(1);
                System.debug('allocShare-->'+allocShare);
                System.debug('rounded-->'+rounded);
                System.debug('roundedLast-->'+roundedLast);
                System.debug('roundedLast-->'+roundedLast);
                    if(teamMembersToUpd != null && teamMembersToUpd.size() > 0)
                    {
                        List<Team_Member__c> teamMemToUpdate = new List<Team_Member__c>();
                        for(Team_Member__c tm: teamMembersToUpd)
                        {
                            Team_Member__c tm2 = tm;
                            Decimal allocation = 0.0;
                        
                            if(rem>0)
                            {
                                tAlloc = tAlloc+val;
                                System.debug('tAlloc-->'+tAlloc);
                                if(100-tAlloc >rem)
                                {
                                    allocation = ((rounded)/100).setScale(3);
                                    System.debug('allocation-->'+allocation);
                                }else if(100-tAlloc ==rem)
                                {
                                    allocation = ((roundedLast)/100).setScale(3);
                                    System.debug('allocation1-->'+allocation);
                                }
                            }else if(rem==0)
                            {
                                allocation = (Decimal.valueOf(val)/100).setScale(3);
                                System.debug('allocation2-->'+allocation);
                            }
                            System.debug('Allocation-->'+allocation);
                            tm2.Allocation__c = allocation;
                            
                            teamMemToUpdate.add(tm2);
                        }
                        if(teamMemToUpdate.size()>0)
                            update(teamMemToUpdate);
                    }
                    //RESET LISTS
                        
                        getTeamMembers();
                        getOtherUsers();
                        getAllUsers();
            }
        return null;
    }
     
    public PageReference createRule() {
        
        if(chooseTeam)
        {
            getSelectedMembers();
            getSelectedOtherUsers();
        }
        if(createTeam)
        {
            getSelectedUsers();
        }
        if(cloneTeam)
        {
            getSelectedMembers();
            getSelectedOtherUsers();
        }
        
        if(validateSelection())
        {
            if(teamName==null || teamName=='')
            {
                isError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Empty_Team_Name));
                return Page.ProspectAdminFlowStep2;
            }else
            {
                step1 = false;
                step2 = false;
                step3 = false;
                step4 = false;
                createRule = true;
                memberListChanged = false;
                if(!editRule)
                {
                    ruleId = null;
                }

                System.debug('Account Id!!!--->'+account.id);
                System.debug('Team Id!!!--->'+teamId);
                saveTeamAndTeamMembers();
            }
        }else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_User_Error));
            return Page.ProspectAdminFlowStep2;
        }
        initiatePRORuleSetFields();
        renderPRORuleSetFields();
        isSRP=ProspectUtils.getAccountType(account.id);
        objectTypes = new List<selectOption>();
        getAllAssociatedObjectTypes(isSRP); 
        operatorList = new List<selectOption>();
        ruleSetsToInsert= new List<PRO_Rule_Set__c>();
        insertedRuleSets = new List<String>();
        getAllOperators();

        if(ruleid==null)
        {
            PRO_Rule__c rl = new Pro_Rule__c();
            rl.Active__c = true;
            rl.Academic_Institution__c = account.id;
            rl.Active__c = false;
            insert rl;
            ruleId = rl.id;
            //Default Rule Set
            PRO_Rule_Set__c defaultRuleSet = new PRO_Rule_Set__c();
            defaultRuleSet.Sequence__c = 1;
            defaultRuleSet.Object_Name__c = ProspectConstants.defaultObject; 
            defaultRuleSet.Field_Name__c = ProspectConstants.defaultField; 
            defaultRuleSet.Operator__c = ProspectConstants.defaultOperator;
            defaultRuleSet.Value__c = acctName;
            defaultRuleSet.Rule__c = ruleId;
            defaultRuleSet.Object_API_Name__c = ProspectUtils.getObjectAPIName(ProspectConstants.defaultObject);
            insert defaultRuleSet;
            System.debug('defaultRuleSet-->'+defaultRuleSet);
            getAddedRuleSets(ruleId);
        }else
        {
            if(addedRuleSets!=null)
            {
                addedRuleSets.clear();
            }
            getAddedRuleSets(ruleId);
        }
        
        allRuleSets = new List<SelectOption>();
        ruleSets = new List<String>();
        
        getAllRulesAndRuleSets(account.id,teamid);
        
        return Page.ProspectAdminFlowRuleCreate;
    }
    
        public PageReference editRule() {
            editRule = true;
            // SET RULE ID HERE
            
            return createRule();
        }
    
    public PageReference addRuleSet() {
        validateRuleSet();
        if(validated)
        {
            
            ruleSetsToInsert.clear();
            PRO_Rule_Set__c rs = new PRO_Rule_Set__c();

            rs.Sequence__c = Integer.valueOf(sequenceNo.fieldValue);
            rs.Object_Name__c = objType.fieldValue;
            rs.Field_Name__c = fieldName.fieldValue;
            rs.Operator__c = operator.fieldValue;
            rs.Value__c = value.fieldValue;
            rs.Rule__c = ruleId;
            rs.Object_API_Name__c = ProspectUtils.getObjectAPIName(objType.fieldValue);
            //insert rs;
            System.debug('rs-->'+rs);
            ruleSetsToInsert.add(rs);   
        }
        
        if(ruleSetsToInsert != null && ruleSetsToInsert.size()>0)
        {
                
                isError = false;
                Database.insert(ruleSetsToInsert, false);
                if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                {
                    isError = true;
            
                }
                
                if(!isError)
                {
                    
                    for(PRO_Rule_Set__c prs: ruleSetsToInsert)
                    {
                        String fieldLbl = prs.Field_Name__c;
                        if(fieldAPILabelMap!=null && fieldAPILabelMap.get(prs.Field_Name__c)!=null)
                        {
                            fieldLbl = fieldAPILabelMap.get(prs.Field_Name__c);
                        }
                        insertedRuleSets.add(prs.Sequence__c+'. '+prs.Object_Name__c+'.'+fieldLbl+' '+prs.Operator__c+' '+prs.Value__c+ ' <br/> ');
                        
                    }
                }
        }
        
        sequenceNo.fieldValue ='';
        objType.fieldValue ='Select One';
        fieldName.fieldValue ='Select One';
        operator.fieldValue ='Select One';
        value.fieldValue = '';
        getAddedRuleSets(ruleId);
                
        return null;
    }
    
    public PageReference getAddedRuleSets(Id ruleId)
    {
        addedRuleSets = new List<ruleSets>();
        addedRuleSets.clear();
        List<PRO_Rule_Set__c> rSets = [Select t.id, t.Sequence__c, t.Object_Name__c, t.Field_Name__c, t.Operator__c, t.Value__c, t.Rule__r.Formula__c 
                                       From PRO_Rule_Set__c t 
                                       where t.Rule__c =: ruleId
                                       order by t.Sequence__c];
        rulesAdded = rSets.size();
        System.debug('ruleAdded-->'+rulesAdded);
        for(PRO_Rule_Set__c rs: rSets)
        {
            addedRuleSets.add(new ruleSets(rs));
            formula.fieldvalue = rs.Rule__r.Formula__c;
        }
        
        return null;
    }
    
    
    public PageReference removeRuleSet()
    {
        ruleSetId = System.CurrentPageReference().getParameters().get('ruleSetid');
        System.debug('RuleSetId-->'+ruleSetId);
        System.debug('RuleSetId-->'+RSToRem);
        Id ruleIdUpd = null;
        if(ruleSetId!=null)
        {
            List<PRO_Rule_Set__c> rsToDel= new List<PRO_Rule_Set__c>([Select id,Rule__c from PRO_Rule_Set__c where id =: ruleSetId]);
            if(rsToDel!=null && rsToDel.size()>0)
            {
                ruleIdUpd = rsToDel.get(0).Rule__c;
                PRO_Rule__c ruleUpd = new PRO_Rule__c(id=ruleIdUpd);
                ruleUpd.Formula__c = '';
                
                try{
                        database.update(ruleUpd);
                        Database.delete(rsToDel, true);
                        //teamAndMemSaved = true;
                    }catch(Exception e){
                        System.Debug(e);
                    }
            }
            
            if(addedRuleSets!=null)
            addedRuleSets.clear();
            
            getAddedRuleSets(ruleId);
            System.debug('rulesAdded123-->'+rulesAdded);
            
        }
        return null;
    }
    
    public PageReference validateRuleSet(){
        isError=false;
        validated=true;
        
        validated = validateThisField(validated, true, sequenceNo.fieldValue, '', 'Sequence Number is Required');
        try{
            Integer sNo = Integer.valueOf(sequenceNo.fieldValue);
        }catch(Exception e)
        {
            validated=false;
            apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,e.getMessage()));
        }
        validated = validateThisField(validated, true, objType.fieldValue, 'Select One', 'Object Type is Required');
        validated = validateThisField(validated, true, fieldName.fieldValue, 'Select One', 'Field Name is Required');
        validated = validateThisField(validated, true, operator.fieldValue, 'Select One', 'Operator is Required');
        validated = validateThisField(validated, true, value.fieldValue, '', 'Value is Required');
        if(!validated)
        {
            isError=true;
        }
        return null;
    }
    
    public Boolean validateThisField(Boolean currentValidation, Boolean fieldRequired, String fieldName, String checkFor, String errorMessage){
        
        if(fieldRequired && (fieldName == '' || fieldName == checkFor || fieldName == null)){
            currentValidation = false;
            apexpages.addMessage( new Apexpages.Message (ApexPages.Severity.ERROR,errorMessage));
        }
        return currentValidation;
     }
     
     public PageReference getTeamMembers() 
    {
        if(members==null)
        {
            members = new List<teamMember>();
        }
        members.clear();
        teamMemberList = [Select t.id, t.Who_Id__r.Name, t.Who_Id__c From Team_Member__c t where t.Which_Team__c =: teamId and t.Active__c = true];
        for(Team_Member__c tm: teamMemberList)
        {
            members.add(new teamMember(tm));
        }
        return null;

    }
    
     public PageReference getOtherUsers() 
    {
        if(otherUsers==null)
        {
            otherUsers = new List<otherUser>();
        }
        otherUsers.clear();
        
        List<Id> campusContacts = new List<Id>(); 
            for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
            }
            List<Team_Member__c> allTeamMembers = new List<Team_Member__c>([Select t.id, t.Who_Id__r.Name, t.Who_Id__c From Team_Member__c t where t.Which_Team__c =: teamId]);
        List<Id> teamMembers = new List<Id>(); 
            for(Team_Member__c ap: allTeamMembers){
                teamMembers.add(ap.Who_Id__c);
                //selectTeamMembers.add(new SelectOption(ap.Who_Id__c, ap.Who_Id__r.Name));
            }
        for(User ur: [Select u.id, u.Name From User u where u.Id in:campusContacts and u.Id not in: teamMembers and u.Prospect_Inactive__c = false])
        {
            otherUsers.add(new otherUser(ur));
        }
        return null;

    }
    
     public PageReference getAllUsers() 
    {
        if(allUsers==null)
        {
            allUsers = new List<otherUser>();
        }
        allUsers.clear();
        
        List<Id> campusContacts = new List<Id>(); 
            for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
            }
        
        for(User ur: [Select u.id, u.Name From User u where u.Id in: campusContacts and u.Prospect_Inactive__c = false])
        {
            allUsers.add(new otherUser(ur));
        }
        return null;

    }
     
    public List<MemberAllocField> getMemberAlloc() 
    {
        if(memAllocList==null)
        {
            memAllocList = new List<MemberAllocField>();
        }else
        {
            memAllocList.clear();
        }
            
                for(Team_Member__c tm: [Select t.id, t.Who_Id__r.Name, t.Allocation__c,t.Active__c From Team_Member__c t where t.Which_Team__c =: teamId])
                {
                    memAllocList.add(new MemberAllocField(tm));
                }
            
        
        return memAllocList;

    }
    
    
    public PageReference step4() {
        
        step1 = false;
        step2 = false;
        step3 = false;
        step4 = true;
        eqAlloc = false;
        
        //editRule = true;
        
        if(isDefault)
        {
            if(chooseTeam&&isDefault)
            {
                getSelectedMembers();
                getSelectedOtherUsers();
            }
            
            if(validateSelection())
            {
                if(teamName==null || teamName=='')
                {
                    isError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Empty_Team_Name));
                    return Page.ProspectAdminFlowStep2;
                }else
                {
                    System.debug('Account Id!!!--->'+account.id);
                    System.debug('Team Id!!!--->'+teamId);
                    memberListChanged = false;
                    saveTeamAndTeamMembers();
                }
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_User_Error));
                return Page.ProspectAdminFlowStep2;
            }
        }
        if(createTeam||cloneTeam||(chooseTeam && memberListchanged))
        {
            eqAlloc = true;
        }
        initiateMemberAllocFields();
        renderMemberAllocFields();
        
        System.debug('Account Id!!!--->'+account.id);
        System.debug('Team Id!!!--->'+teamId);
        
        if(createRule)
        {
            System.debug('Rule Formula!!!--->'+formula.fieldValue);
            System.debug('RuleSetsAdded!!!--->'+rulesAdded);
            if(rulesAdded>1)
            {
                if(formula.FieldValue!=null && formula.FieldValue!='')
                {
                    try
                    {
                        updateRuleFormula();
                    }catch(Exception exc)
                    {
                        isError = true;
                        return Page.ProspectAdminFlowRuleCreate;
                    }
                    if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                    {
                        isError = true;
                        return Page.ProspectAdminFlowRuleCreate;
                    }
                }else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Invalid_Rule_Formula));
                    isError = true;
                    return Page.ProspectAdminFlowRuleCreate;
                }
                updateTeamRule();
                if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                {
                    isError = true;
                    return Page.ProspectAdminFlowRuleCreate;
                }
                isError = false;
            }else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Empty_Rule));
                isError = true;
                return Page.ProspectAdminFlowRuleCreate;
            }
            
        }

        System.debug('selectedMembers!--->'+selectedMembers.size());
        
        memAllocList = getMemberAlloc();
        
        cloneTeam=false;
        chooseTeam = true;
      return Page.ProspectAdminFlowStep4;
    }
    
    public PageReference updateRuleFormula()
    {
        List<PRO_Rule__c> rule = [Select Formula__c, Active__c from PRO_Rule__c where id =: ruleId];
        
      
        List<PRO_Rule__c> ruleToUpdate = new List<PRO_Rule__c>();
      
        for(PRO_Rule__c r: rule){
           
              PRO_Rule__c r2 = r;
              r2.Formula__c = formula.fieldvalue;
              r2.Active__c = true;
              ruleToUpdate.add(r2);
            
          }
      
      if(ruleToUpdate.size()>0)
      {
        
            update(ruleToUpdate);
        
      }
        return null;
    }
    
    public PageReference updateTeamRule()
    {
        List<Team__c> team = [Select Team_Rule__c from Team__c where id =: teamId];
      
        List<Team__c> teamToUpdate = new List<Team__c>();
      
        for(Team__c t: team){
           
              Team__c t2 = t;
              t2.Team_Rule__c = ruleId;
              teamToUpdate.add(t2);
            
          }
      
      if(teamToUpdate.size()>0)
        update(teamToUpdate);
        return null;
    }
    
    public PageReference userAllocation()
    {
        eqAlloc = false;
        system.debug('memAllocList1-->'+memAllocList);
        return null;
    }
    
    public PageReference setEqualAllocation()
    {
        eqAlloc = true;//List<MemberAllocField> eqAlloc = new List<MemberAllocField>();
        Integer mCount = memAllocList.size();
        Decimal allocShare = Decimal.valueOf(100)/mCount;
        Decimal rounded = allocShare.setScale(1, RoundingMode.HALF_UP);     
        Decimal roundedLast = (100-(rounded*(mCount-1))).setScale(1);
        System.debug('allocShare-->'+allocShare);
        System.debug('rounded-->'+rounded);
        Integer tAlloc = 0;
        Integer rem = math.mod(100,mCount);
        Integer val = 100/mCount;
        for(MemberAllocField mAlloc: memAllocList)
        {
            
            if(rem>0)
            {
                
                tAlloc = tAlloc+val;
                if(100-tAlloc >rem)
                {
                    mAlloc.memberAllocation = ((rounded)).setScale(1);
                }else if(100-tAlloc ==rem)
                {
                    mAlloc.memberAllocation = ((roundedLast)).setScale(1);
                }
            }else if(rem==0)
            {
                mAlloc.memberAllocation = (Decimal.valueOf(val)).setScale(1);
            }
            //Decimal divDec = (100).divide(mCount, 1, System.RoundingMode.UP);
            
            //mAlloc.memberAllocation = Integer.valueOf((Decimal.valueOf(100/mCount)).setScale(0, RoundingMode.HALF_UP));
            //eqAlloc.add(mAlloc.memberId,mAlloc.memberName,Integer.valueOf(100/mCount));
        }
        
        return null;
    }
    
    public PageReference verifyAllocation()
    {
        verified = true;
        System.debug('memAllocList-->'+memAllocList);
        List<Decimal> allocValues = new List<Decimal>();
        
        for(MemberAllocField mAlloc: memAllocList)
        {
            
            allocValues.add(mAlloc.memberAllocation);
        }
        System.debug('allocValues-->'+allocValues);
        if(allocValues.size()>0)
        {
             Integer memCount = 0;
             List<Team__c> memberCount = new List<Team__c>([Select Member_Count__c from Team__c where id =: teamId]);
             for(Team__c t: memberCount)
             {
                memCount = Integer.valueOf(t.Member_Count__c);
             }
             
            Decimal totalAlloc = 0.0;
            System.debug('memCount-->'+memCount);
            if(allocValues.size() == memCount)
            {
                for(Decimal alloc: allocValues)
                {
                    if(alloc==null || alloc==0)
                    {//verify if allocation is empty or 0 for any user
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Empty_Allocation));
                        verified = false;
                        break;
                    }
                    else
                    {
                        totalAlloc = totalAlloc+alloc;
                    }
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Empty_Allocation));
                verified = false;
            }
            if(totalAlloc!=100)
            {//verify if sum of allocation = 1 or 100%
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Invalid_Allocation));
                verified = false;
            }
        }
        else
        {// verify if allocation is empty
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Prospect_Empty_Allocation));
            verified = false;
        }
        
        return null;
    }
    
    public PageReference flipMemberStatus()
    {
        system.debug('memAllocList-->'+memAllocList);
        Map<Id, Boolean> memStatus = new Map<Id, Boolean>();
        
        for(MemberAllocField mAlloc: memAllocList)
        {
            memStatus.put(mAlloc.memberId, mAlloc.memberStatus);
        }
        system.debug('memStatus-->'+memStatus);
        List<Team_Member__c> teamMem = [Select Active__c from Team_Member__c where id in: memStatus.keySet()];
            List<Team_Member__c> teamMemToUpdate = new List<Team_Member__c>();
            for(Team_Member__c tm: teamMem)
            {
                Team_Member__c tm2 = tm;
                tm2.Active__c = memStatus.get(tm.id);
                teamMemToUpdate.add(tm2);
            }
        system.debug('teamMemToUpdate-->'+teamMemToUpdate);
            if(teamMemToUpdate.size()>0)
            update(teamMemToUpdate);
            
            getMemberAlloc();
            
        return null;
    }
    
    public PageReference step2Clone()
    {
        
        if(validateRadio())
        {
            
            step1 = false;
            step2 = true;
            step3 = false;
            step4 = false;
            createRule = false;
            editRule = false;
            emptyRule = false;
            cloneTeam = true;
            allAccUserList = new List<User>();
            selectAccUsers = new List<SelectOption>();
            selectedUsers = new List<String>();
            
            teamMemberList = new List<Team_Member__c>();
            selectTeamMembers = new List<SelectOption>();
            selectedMembers = new List<String>();
            
            otherUserList = new List<User>();
            selectOtherUsers = new List<SelectOption>();
            allOtherUsers = new List<String>();
            
            createTeam = false;
            chooseTeam = false;
            cloneTeam = true;
            System.debug('Team Id!!!--->'+selectedTeam);
            List<Team__c> teamSelected = new List<Team__c>();
            teamSelected = [SELECT t.Team_Name__c, t.Team_Account__r.Name, t.Name, t.Id, t.ESC_Exempt__c, t.Team_Rule__c FROM Team__c t WHERE t.Id=: selectedTeam];
        
            for(Team__c tm: teamSelected)
            {
                teamId = tm.Id;
                teamName = 'Copy of '+tm.Team_Name__c;
                teamExempt = false;
                emptyRule = true;
                ruleId=null;
            }
            System.debug('Team Id!!!--->'+teamId);
            System.debug('Team Name!!!--->'+teamName);
            
            allCampusContacts = new List<Campus_Contacts__c>();
            allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c =: 'ACTIVE'
                                                         AND c.Employee__r.ProfileId IN :profileIds];
            selectedUsers.clear();
            selectedMembers.clear();
            allOtherUsers.clear();
            
            if(members!=null)
            members.clear();
        
            if(otherUsers!=null)
            otherUsers.clear();
        
            if(allUsers!=null)
            allUsers.clear();
            
            getTeamMembers();
            getOtherUsers();
            System.debug('members-->'+members);
            System.debug('otherUsers-->'+otherUsers);
            //createFormattedList(teamId);
            
            isError = false;
            teamId = null;
            
            return Page.ProspectAdminFlowStep2;
        }   
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Lead_Router_Select_Team_Error));
            return Page.ProspectAdminFlowStep1;
        }
       
        return null;
    }
    
    // This method cancels the wizard, and returns the user to the
   // Account Page
    public PageReference cancel()
    {
        PageReference accountHome = new ApexPages.StandardController(account).view();
        accountHome.setRedirect(true);
        return accountHome;
    }
    
   

    public PageReference saveAll()
    {
        system.debug('memAllocList111-->'+memAllocList);
        verifyAllocation();
        if(verified)
        {
            //UPDATE MEMBER ALLOCATION
            Map<Id, Decimal> allocVal = new Map<Id, Decimal>();
            system.debug('memAllocList-->'+memAllocList);
            Map<Id, Boolean> memStatus = new Map<Id, Boolean>();
            for(MemberAllocField mAlloc: memAllocList)
            {
                allocVal.put(mAlloc.memberId, mAlloc.memberAllocation);
            }
            for(MemberAllocField mAlloc: memAllocList)
            {
                memStatus.put(mAlloc.memberId, mAlloc.memberStatus);
            }
            List<Team_Member__c> teamMem = [Select Allocation__c, Active__c from Team_Member__c where id in: allocVal.keySet()];
            List<Team_Member__c> teamMemToUpdate = new List<Team_Member__c>();
            for(Team_Member__c tm: teamMem)
            {
                Team_Member__c tm2 = tm;
                tm2.Allocation__c = ((allocVal.get(tm.id))/100).setScale(3);
                tm2.Active__c = memStatus.get(tm.id);
                teamMemToUpdate.add(tm2);
            }
            if(teamMemToUpdate.size()>0)
            update(teamMemToUpdate);
            //SHOW RULE INFO 
            System.debug('TeamId111-->'+teamId);
            //System.debug('TeamId-->'+teamId);
            displayRuleSummary = new List<String>(); 
            getRuleSummary(teamId);
            //GET MEMBER ALLOCATION DETAILS
            memAllocList = getMemberAlloc();
            PageReference reviewPage = Page.ProspectAdminFlowReview;
            //reviewPage.setRedirect(true);
        
            return reviewPage;
        }else
        {
            isError = true;
            return Page.ProspectAdminFlowStep4;
        }

        return null;
    
    }
    
    
     
     public List<Account> getAccountName()
     {
        List<Account> acctName = [SELECT Id, Name From Account WHERE id = :account.id];
        return acctName;   
     }
     
     
  /*  
    public PageReference loadAllAccUserList()
     {   
        allAccUserList.clear(); 
        selectAccUsers.clear();
        // ALL ACCOUNT CAMPUS CONTACTS 
        List<Campus_Contacts__c> allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c = 'ACTIVE'];
        List<Id> campusContacts = new List<Id>(); 
            for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
            }                                        
        
        allAccUserList = [Select u.id, u.Name From User u where u.Id in: campusContacts and u.Prospect_Inactive__c = false];
        for(User accUsr: allAccUserList)
        {
            selectAccUsers.add(new SelectOption(accUsr.Id, accUsr.Name));
        }
        
        
        return null;
        
        
     }
     
     public PageReference createFormattedList(Id teamId)
     {   
        teamMemberList.clear(); 
        selectTeamMembers.clear();

        // TEAM MEMBER LIST
        teamMemberList = [Select t.Who_Id__r.Name, t.Who_Id__r.Username, t.Who_Id__c, t.Which_Team__c, t.Team_Name__c, t.Id From Team_Member__c t where t.Which_Team__c =: teamId and t.Active__c = true];
        List<Id> teamMembers = new List<Id>(); 
            for(Team_Member__c ap: teamMemberList){
                teamMembers.add(ap.Who_Id__c);
                selectTeamMembers.add(new SelectOption(ap.Who_Id__c, ap.Who_Id__r.Name));
            }
        // ALL ACCOUNT CAMPUS CONTACTS    
        List<Campus_Contacts__c> allCampusContacts = [Select c.Title__c, c.Organization__c, c.Name, c.Id,
                                                             c.Employee__c, c.Email__c, c.Active_User__c 
                                                             From Campus_Contacts__c c 
                                                         where c.Organization__c = :account.Id and c.Active_User__c = 'ACTIVE'];
        List<Id> campusContacts = new List<Id>(); 
            for(Campus_Contacts__c ap: allCampusContacts){
                campusContacts.add(ap.Employee__c);
            }
        
        // CAMPUS CONTACTS WHO ARE NOT TEAM MEMBERS
        otherUserList.clear();
        selectOtherUsers.clear();
        otherUserList = [Select u.id, u.Name From User u where u.Id in:campusContacts and u.Id not in: teamMembers and u.Prospect_Inactive__c = false];
        for(User othrUsr: otherUserList)
        {
            selectOtherUsers.add(new SelectOption(othrUsr.Id, othrUsr.Name));
        }
        return null;
     }*/
     
    
    /* // ON CHANGE METHOD
     public PageReference getRuleDetails()
     {
        displayRuleSummary.clear();
        // fetch rule ids from PRO_Rule__c which belongs to particular team     
        List<PRO_Rule__c> proRuleInfo = new List<PRO_Rule__c>();
        proRuleInfo = [SELECT p.Name, p.Id, p.Formula__c 
                       FROM PRO_Rule__c p 
                       WHERE p.Id =: selectedRuleSummary];
                       
        List<ID> rIdFromPRORule = new List<ID>();
        for(PRO_Rule__c prc : proRuleInfo)  
        {
            rIdFromPRORule.add(prc.Id);
            ruleId = prc.Id;
        }
        Map<Id,String> ruleFormula = new Map<Id, String>();
        for(PRO_Rule__c prc : proRuleInfo)  
        {
            ruleFormula.put(prc.Id,prc.Formula__c);
        }              
                
        List<PRO_Rule_Set__c > ruleSet = new List<PRO_Rule_Set__c >();
        ruleSet = [SELECT p.Value__c, p.Sequence__c, p.Rule__c, p.Operator__c, 
                          p.Object_Name__c, p.Name, p.Id, p.Field_Name__c 
                   FROM PRO_Rule_Set__c p 
                   WHERE p.Rule__c in :rIdFromPRORule
                   ORDER BY p.Sequence__c];
        Map <Id,String> displayRuleMap = new Map<Id, String>();
                
        for(Integer i=0; i<ruleSet.size(); i++)
        {
            String display = '';
            if(i==0)
            {
                display = ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ ruleSet[i].Field_Name__c + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
                displayRuleMap.put(ruleSet[i].Rule__c, display);

            }else
            {
                if(displayRuleMap.containsKey(ruleSet[i].Rule__c))
                {
                    display = displayRuleMap.get(ruleSet[i].Rule__c) + ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ ruleSet[i].Field_Name__c + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
                    displayRuleMap.remove(ruleSet[i].Rule__c);
                    displayRuleMap.put(ruleSet[i].Rule__c, display);
                }else
                {
                    display = ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ ruleSet[i].Field_Name__c + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' <br/> ';
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
    //      displayRuleSummary.add(ruleIds[i], displayRuleMap.get(ruleIds[i]));
        }
        Integer length = displayRuleSummary.size();
        if(length <=0 )
            lenFlag = true;
     
        
        return null;
     }*/
     
     public PageReference getRuleSummary(Id teamId)
    {
        
    // take rule Ids from Team__c object    
        List<Team__c> teamRuleIds = new List<Team__c>();
        teamRuleIds = [SELECT t.Team_Rule__c, t.Id,t.Team_Name__c FROM Team__c t WHERE t.Id =: teamId];
        system.debug('RULEID:'+teamRuleIds);
        
        for(Team__c tm: teamRuleIds)
        {
            teamId = tm.id;
            teamName = tm.Team_Name__c;
            ruleId = tm.Team_Rule__c;
        }
        List<ID> ruleIdsFromTeam = new List<ID>();
        for(Team__c rid : teamRuleIds)
        {
            if(rid.Team_Rule__c!=null){
            ruleIdsFromTeam.add(rid.Team_Rule__c);
            }
        }
        system.debug('RULEIDFROMTEAM:'+ruleIdsFromTeam);
        if(ruleIdsFromTeam.size()>0)
        {
        
   // fetch rule ids from PRO_Rule__c which belongs to particular team      
        List<PRO_Rule__c> proRuleInfo = new List<PRO_Rule__c>();
        proRuleInfo = [SELECT p.Name, p.Id, p.Formula__c 
                       FROM PRO_Rule__c p 
                       WHERE p.Id in :ruleIdsFromTeam];
            system.debug('PRORULEINFO:'+proRuleInfo);          
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
        ruleSet = [SELECT p.Value__c, p.Sequence__c, p.Rule__c, p.Operator__c, 
                          p.Object_Name__c, p.Name, p.Id, p.Field_Name__c 
                   FROM PRO_Rule_Set__c p 
                   WHERE p.Rule__c in :rIdFromPRORule
                   ORDER BY p.Sequence__c];
        Map <Id,String> displayRuleMap = new Map<Id, String>();
                system.debug('RULESET:'+ruleSet);
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
        
        system.debug('RULEMAP:'+displayRuleMap);
        
        system.debug('RULEIDS:'+ruleIds);
        
        for(Integer i=0; i<ruleIds.size(); i++)
        {
            displayRuleSummary.add(displayRuleMap.get(ruleIds[i]));
    //      displayRuleSummary.add(ruleIds[i], displayRuleMap.get(ruleIds[i]));
        }
        Integer length = displayRuleSummary.size();
        
        }
        return null;
    
    }
    
     public PageReference getAllRulesAndRuleSets(Id accountId,Id teamId)
    {
        
        List<Team__c> teamRuleIds = new List<Team__c>();
        teamRuleIds = [SELECT t.Team_Rule__c,t.Team_Name__c, t.Id FROM Team__c t WHERE t.Team_Account__c =: accountId and t.Active__c = true];
        
        Map<Id,String> ruleToTeamName = new Map<Id,String>();
        
        List<ID> ruleIdsFromTeam = new List<ID>();
        for(Team__c rid : teamRuleIds)
        {
            ruleIdsFromTeam.add(rid.Team_Rule__c);
            ruleToTeamName.put(rid.Team_Rule__c,rid.Team_Name__c);
        }
        
    
   // fetch rule ids from PRO_Rule__c which belongs to particular account - latest on top-Edited: Vignesh R 
        List<PRO_Rule__c> proRuleInfo = new List<PRO_Rule__c>();
        proRuleInfo = [SELECT p.Name, p.Id, p.Formula__c,p.Academic_Institution__c,p.CreatedDate,p.Owner.Name 
                       FROM PRO_Rule__c p 
                       WHERE p.Academic_Institution__c =: accountId 
                       and p.Active__c = true 
                       and p.Id in: ruleIdsFromTeam
                       ORDER BY p.createdDate desc];
                       
        List<ID> rIdFromPRORule = new List<ID>();
        
        for(PRO_Rule__c prc : proRuleInfo)  
        {
            rIdFromPRORule.add(prc.Id);
        }   
        Map<Id,String> ruleFormula = new Map<Id, String>();
        for(PRO_Rule__c prc : proRuleInfo)  
        {
            ruleFormula.put(prc.Id,(prc.Formula__c + ' <br/> '));
        }              
                
        List<PRO_Rule_Set__c > ruleSet = new List<PRO_Rule_Set__c >();
        ruleSet = [SELECT p.Value__c, p.Sequence__c, p.Rule__c, p.Operator__c, 
                          p.Object_Name__c, p.Name, p.Id, p.Field_Name__c 
                   FROM PRO_Rule_Set__c p 
                   WHERE p.Rule__c in :rIdFromPRORule
                   ORDER BY p.Sequence__c];
        Map <Id,String> displayRuleMap = new Map<Id, String>();
        
        for(Integer i=0; i<ruleSet.size(); i++)
        {
            String display = '';
            //Logic to get Field Label for Field API Name
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(ProspectUtils.getObjectAPIName(ruleSet[i].Object_Name__c));
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            String fieldLbl = fieldMap.get(ruleSet[i].Field_Name__c).getDescribe().getLabel();//It provides to get the object fields label.
            
            if(i==0)
            {
                display = ruleSet[i].Sequence__c + '. ' + ruleSet[i].Object_Name__c+ '-'+fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' , ' + ' <br/> ';
                displayRuleMap.put(ruleSet[i].Rule__c, display);

            }else
            {
                if(displayRuleMap.containsKey(ruleSet[i].Rule__c))
                {
                    display = displayRuleMap.get(ruleSet[i].Rule__c) + '\r\n'+ ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' , ' + ' <br/> ';
                    displayRuleMap.remove(ruleSet[i].Rule__c);
                    displayRuleMap.put(ruleSet[i].Rule__c, display);
                }else
                {
                    display = ruleSet[i].Sequence__c + '. '  + ruleSet[i].Object_Name__c+ '-'+ fieldLbl + ' ' + ruleSet[i].Operator__c + ' ' + ruleSet[i].Value__c+ ' , ' + ' <br/> ';
                    displayRuleMap.put(ruleSet[i].Rule__c, display);
                }
                
            }
            
        }
        
        for(PRO_Rule__c prc : proRuleInfo)  
        {
            String displayText = displayRuleMap.get(prc.Id);
            String formula = ruleFormula.get(prc.Id);
            displayRuleMap.remove(prc.Id);
            displayRuleMap.put(prc.Id, (prc.Name + ' assigned to team '+ ruleToTeamName.get(prc.id)+ ' <br/>' + displayText + formula+prc.Owner.Name +' '+ prc.CreatedDate+'<br/>'));
            
        }
        
        List<Id> ruleIds = new List<Id>();
        Set<Id> ruleIdSet = new Set<Id>();
        ruleIdSet = displayRuleMap.keySet();
        ruleIds.addAll(ruleIdSet);
        
        for(Integer i=0; i<ruleIds.size(); i++)
        {
            allRuleSets.add(new SelectOption(ruleIds[i], displayRuleMap.get(ruleIds[i])));
            ruleSets.add(displayRuleMap.get(ruleIds[i]));
    
        }
        
        
    
        return null;
    
    }
   
    public PageReference getAllAssociatedObjectTypes(Boolean srpAcc)
    {
        
        System.debug('srpAcc-->'+srpAcc);
        objectTypes = getObjectTypeList(srpAcc);
        
        return null;
    }
    
    public PageReference getAllOperators()
    {
        operatorList = getOperatorList();
        
        return null;
    }
    
    public PageReference loadAssociatedFieldSets()
    {
        if(objType != null && objType.fieldValue != null && objType.fieldValue != 'Select One' )
        {
            assocFieldSets = new List<selectOption>();
            fieldAPILabelMap = new Map<String,String>();
            List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
            System.debug('Object Type-->'+objType.fieldValue);
            fieldSetMembers = ProspectUtils.getFields(objType.fieldValue, isSRP);
            System.debug('fieldSetMembers-->'+fieldSetMembers);
            
            System.debug('Object Type-->'+objType.fieldValue);
            assocFieldSets.add(new SelectOption('', 'Select One'));
            for(Schema.FieldSetMember f : fieldSetMembers)
            {
                System.debug('f.getFieldPath()-->'+f.getFieldPath());
                assocFieldSets.add(new SelectOption(f.getFieldPath(), f.getLabel()));
                fieldAPILabelMap.put(f.getFieldPath(), f.getLabel());
            }
        }
        else
        {
            assocFieldSets.clear();
            fieldName.fieldValue = 'Select One';
            
        }
        return null;
    }
    
    
    
    public List<SelectOption> constructSRPPickLists(Schema.DescribeFieldResult fieldResult, Boolean showNone){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(showNone)
            options.add(new SelectOption('', 'Select One'));
        for( Schema.PicklistEntry f : ple)
        {
            if(ProspectUtils.isSRPObject(f.getLabel()))
            {
                System.debug('INSIDE-->'+ProspectUtils.getObjectAPIName(f.getLabel()));
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }       
        return options;
     }
     
     public List<SelectOption> constructSRMPickLists(Schema.DescribeFieldResult fieldResult, Boolean showNone){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(showNone)
            options.add(new SelectOption('', 'Select One'));
        for( Schema.PicklistEntry f : ple)
        {
            if(ProspectUtils.isSRMObject(f.getLabel()))
            {
                System.debug('INSIDE-->'+ProspectUtils.getObjectAPIName(f.getLabel()));
                
                options.add(new SelectOption(f.getLabel(), f.getValue()));
                
            }
        }       
        return options;
     }
    
    public List<SelectOption> constructPickLists(Schema.DescribeFieldResult fieldResult, Boolean showNone){
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(showNone)
            options.add(new SelectOption('', 'Select One'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
     }
     
     public List<SelectOption> getObjectTypeList(Boolean srpAcc){
        if(srpAcc)
        {
            return constructSRPPickLists(PRO_Rule_Set__c.p.Object_Name__c.getDescribe(), true);
        }else
        {
            return constructSRMPickLists(PRO_Rule_Set__c.p.Object_Name__c.getDescribe(), true);
        }
     }
     public List<SelectOption> getOperatorList(){
        return constructPickLists(PRO_Rule_Set__c.p.Operator__c.getDescribe(), true);
     }
     
 
}