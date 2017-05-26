/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seealldata=true)
private class ProspectRuleEvaluationUtilsTest {

	private static PRO_Rule_Set__c getRuleSet(String fieldName, String ObjectName, String operator, String value, Integer sequence, PRO_Rule__c thisRule){
    	String namespace = 'DeltakSRP__';
    	PRO_Rule_Set__c ruleSet = new PRO_Rule_Set__c();
    	ruleSet.Field_Name__c = namespace+fieldName;
    	ruleSet.Rule__c = thisRule.Id;
    	ruleSet.Object_API_Name__c = namespace+objectName;
    	ruleSet.Operator__c = operator;
    	ruleSet.Value__c = value;
    	ruleSet.Sequence__c = sequence;
    	return ruleSet;
    }
    
    static testMethod void testRuleSetTrigger(){
    	PRO_Rule__c rule = new PRO_Rule__c();
    	insert rule;
    	List<PRO_Rule_Set__c> ruleSetList = new List<PRO_Rule_Set__c>();
    	ruleSetList.add(getRuleSet('Undergraduate_College_Name__c','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'IL',1,rule));
    	ruleSetList.add(getRuleSet('Graduate_GPA__c','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',2,rule));
    	ruleSetList.add(getRuleSet('Integrate__c','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',3,rule));
    	ruleSetList.add(getRuleSet('Graduate_Start_Date__c','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',4,rule));
    	ruleSetList.add(getRuleSet('CreatedDate','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',5,rule));
    	ruleSetList.add(getRuleSet('Online_Application_Config__c','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',6,rule));
    	ruleSetList.add(getRuleSet('HelloWorld','Student_Online_Application__c',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',7,rule));
    	ruleSetList.add(getRuleSet('TickerSymbol','Account',ProspectConstants.COMPARISON_TYPE_EQUAL,'Text',7,rule));
    	try{
    	insert ruleSetList;
    	System.Assert(false);
    	}catch(Exception e){
    		System.Assert(true);
    	}	
    	
    }

	 static testMethod void testfindFieldType() {
    	System.AssertEquals(Schema.DisplayType.String, ProspectRuleEvaluationUtils.findFieldType(null, 'Account', 'Name'));
    }
    static testMethod void testComparison(){
    	Datetime t = Datetime.now();
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(t, String.valueOf(t), ProspectConstants.COMPARISON_TYPE_NOT_EQUAL,Schema.DisplayType.Datetime));
    	
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison('test', String.valueOf('test'), ProspectConstants.COMPARISON_TYPE_EQUAL, Schema.DisplayType.String));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison('test', String.valueOf('est'), ProspectConstants.COMPARISON_TYPE_CONTAINS, Schema.DisplayType.String));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison('test', String.valueOf('does not contain'), ProspectConstants.COMPARISON_TYPE_DNC, Schema.DisplayType.String));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison('test', String.valueOf('est'), ProspectConstants.COMPARISON_TYPE_NOT_EQUAL, Schema.DisplayType.String));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison('test', String.valueOf('te'), ProspectConstants.COMPARISON_TYPE_SW, Schema.DisplayType.String));
    	
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('5.0'), '5.0', ProspectConstants.COMPARISON_TYPE_EQUAL, Schema.Displaytype.Double));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('5.0'), String.valueOf('4.0'), ProspectConstants.COMPARISON_TYPE_GT, Schema.Displaytype.Double));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('5.0'), String.valueOf('4.0'), ProspectConstants.COMPARISON_TYPE_GTE, Schema.Displaytype.Double));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('4.0'), String.valueOf('5.0'), ProspectConstants.COMPARISON_TYPE_LT, Schema.Displaytype.Double));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('4.0'), String.valueOf('5.0'), ProspectConstants.COMPARISON_TYPE_LTE, Schema.Displaytype.Double));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Double.valueOf('5.0'), String.valueOf('4.0'), ProspectConstants.COMPARISON_TYPE_NOT_EQUAL, Schema.Displaytype.Double));
    	
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today(), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_EQUAL, Schema.DisplayType.Date));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today().addDays(1), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_GT, Schema.DisplayType.Date));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today().addDays(1), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_GTE, Schema.DisplayType.Date));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today().addDays(-1), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_LT, Schema.DisplayType.Date));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today().addDays(-1), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_LTE, Schema.DisplayType.Date));
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(Date.today().addDays(-1), String.valueOf(Date.today()), ProspectConstants.COMPARISON_TYPE_NOT_EQUAL, Schema.DisplayType.Date));
    	
    	System.AssertEquals(true, ProspectRuleEvaluationUtils.comparison(null, '', ProspectConstants.COMPARISON_TYPE_NOT_EQUAL, Schema.Displaytype.Double));
    	System.AssertEquals(false, ProspectRuleEvaluationUtils.comparison(null, 'test', ProspectConstants.COMPARISON_TYPE_NOT_EQUAL, Schema.Displaytype.Double));
    	
    }
    static testMethod void evaluateLogicalExpression(){
    	System.AssertEquals('true', ProspectRuleEvaluationUtils.evaluateLogicalExpression('(AND, true, true, (OR, true, false))'));
    }

    static testMethod void testProspectRuleEvaluationUtils() {
        System.AssertNotEquals(0, ProspectRuleEvaluationUtils.supportedFieldTypeForRules().size());
    }
    static testMethod void testFindFormulaToRender(){
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        a.Prospect_Enabled__c = true;
	        insert a;
	        
	        contact c = new Contact();
	        c.FirstName = 'fname1';
	        c.LastName = 'lname1';
	        c.Email = 'testemail@salesforce.com';
	        c.Phone = '1234567890';
	        c.AccountId = a.Id;
	        c.RecordTypeId = rt4.Id;
	        insert c;
    		DeltakSRP__Academic_Program__c ap = new DeltakSRP__Academic_Program__c();
	        ap.Name = 'abcd';
	        ap.DeltakSRP__School__c = a.id;
	        ap.DeltakSRP__Degree_Type__c = 'Certificate';
	        ap.DeltakSRP__Abbrev__c = 'CID';
	        ap.DeltakSRP__Program_Title__c = 'Certificate in CS';
	        insert ap;
	        
	        PRO_Rule__c rule = new PRO_Rule__c();
	        rule.Academic_Institution__c = a.id;
	        rule.Active__c = true;
	        insert rule;
	        
	        List<PRO_Rule_Set__c> rulesetList = new List<PRO_Rule_Set__c>();
	        PRO_Rule_Set__c ruleset = new PRO_Rule_Set__c();
	        ruleset.Object_API_Name__c = 'Account';
	        ruleset.Field_Name__c = 'Name';
	        ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
	        ruleset.Value__c = 'test account';
	        ruleset.Rule__c = rule.id;
	        ruleset.Sequence__c = 1;
	        rulesetList.add(ruleset);
	        
	        ruleset = new PRO_Rule_Set__c();
	        ruleset.Object_API_Name__c = 'DeltakSRP__Academic_Program__c';
	        ruleset.Field_Name__c = 'Name';
	        ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
	        ruleset.Value__c = 'abcd';
	        ruleset.Rule__c = rule.id;
	        ruleset.Sequence__c = 2;
	        rulesetList.add(ruleset);
	        
	        ruleset = new PRO_Rule_Set__c();
	        ruleset.Object_API_Name__c = 'DeltakSRP__Academic_Program__c';
	        ruleset.Field_Name__c = 'Name';
	        ruleset.Operator__c = ProspectConstants.COMPARISON_TYPE_EQUAL;
	        ruleset.Value__c = 'abcd';
	        ruleset.Rule__c = rule.id;
	        ruleset.Sequence__c = 2;
	        rulesetList.add(ruleset);
	        List<id> thisrulesetids = new List<id>();
	        Database.SaveResult[] lsr =  Database.insert(rulesetList, false); 
	        for(Database.SaveResult thislsr : lsr){
	        	thisrulesetids.add(thislsr.getid());
	        }
	        rule.Formula__c = '(AND,1,2)';
	        update rule;
	        
	        Opportunity o2 = new Opportunity();
	        o2.RecordTypeId = rt3.Id;
	        o2.Name = 'Test Opportunity';
	        o2.StageName = 'New Inquiry';
	        o2.CloseDate = system.today()+100;
	        o2.DeltakSRP__Student__c = c.Id;
	        o2.Student__c = c.Id;
	        o2.DeltakSRP__Lead_Source_ID__c = '12345';
	        o2.DeltakSRP__Academic_Program__c = ap.Id;
	        o2.AccountId = a.Id;
	        
	        List<Opportunity> oplist = new List<Opportunity>();
	        oplist.add(o2);
	        Prospect_Setting__c setting = Prospect_Setting__c.getInstance(); 
	        Id prospectuserid = setting.PROspect_User_ID__c;
	        for(integer i=0; i<10; i++){
		        o2 = new Opportunity();
		        o2.RecordTypeId = rt3.Id;
		        o2.Name = 'Test Opportunity';
		        o2.StageName = 'New Inquiry';
		        o2.CloseDate = system.today()+100;
		        o2.DeltakSRP__Student__c = c.Id;
		        o2.Student__c = c.Id;
		        o2.DeltakSRP__Lead_Source_ID__c = '12345';
		        o2.DeltakSRP__Academic_Program__c = ap.Id;
		        o2.AccountId = a.Id;
		        o2.OwnerId = prospectuserid;
		        oplist.add(o2);
	        }   
	        
	        insert oplist;
	        List<PRO_Rule_Set__c> prorulesetList = [Select Object_API_Name__c, Field_Name__c, Operator__c, Value__c, Rule__c, Sequence__c, Rule__r.Formula__c, Rule__r.Academic_Institution__c, Rule__r.Active__c from PRO_Rule_Set__c where Id in :thisrulesetids];
	        List<Opportunity> olist = [Select Student__c, Program__c, Specialization__c, Academic_Start_Date__c, DeltakSRP__Academic_Specialization__c, DeltakSRP__Academic_Start_Date__c, CampaignId, Campaign.ParentId, Email__c, DeltakSRP__Email__c, id, RecordTypeId, Name, StageName, CloseDate, DeltakSRP__Student__c, DeltakSRP__Lead_Source_ID__c, DeltakSRP__Academic_Program__c, AccountId, Ownerid from Opportunity where DeltakSRP__Student__c = :c.id];
	       
	       System.AssertNotEquals(0, ProspectRuleEvaluationUtils.findFormulaToRender(prorulesetList, oplist[0]).size());
	       
	       
	        
	        
    }
    static testMethod void testFindNextRunTime() {
        RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        a.Prospect_Enabled__c = true;
	        a.PRO_Distribution_Start_Hours__c = '9';
	        a.PRO_Distribution_Hours_Start_Minutes__c = '0';
	        a.PRO_Distribution_End_Hours__c = '17';
	        a.PRO_Distribution_Hours_End_Minutes__c = '0';
	        a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
	        insert a;
	        Datetime currentTimeStamp = Datetime.newInstance(2015, 10, 12, 18, 0, 0);
	        ProspectLogHandler handler = new ProspectLogHandler();
	        Datetime nextRunTime = handler.findNextRunTime(handler.accountIdToDistrbutionHourSetting.get(a.id), currentTimeStamp);
	        System.AssertNotEquals(null, nextRunTime);
	        
    }
    static testMethod void testFindNewStatus(){
    	RecordType rt1 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Academic Institution' limit 1];
	        RecordType rt2 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Lead' limit 1];
	        RecordType rt3 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Opportunity' limit 1];
	        RecordType rt4 = [Select r.Name, r.Id From RecordType r where r.Name = 'SRP Student' limit 1];
	        
	        
	        Account a = new Account();
	        a.recordTypeid = rt1.Id;
	        a.Abbreviation__c = 'TAC';
	        a.name = 'test account';
	        a.Prospect_Enabled__c = true;
	        a.PRO_Distribution_Start_Hours__c = '9';
	        a.PRO_Distribution_Hours_Start_Minutes__c = '0';
	        a.PRO_Distribution_End_Hours__c = '17';
	        a.PRO_Distribution_Hours_End_Minutes__c = '0';
	        a.PRO_Distribution_Hours_Escalation_Minute__c = 120;
	        insert a;
	        
	        ProspectLogHandler handler = new ProspectLogHandler();
	        System.AssertEquals(ProspectConstants.LOG_STATUS_PROCD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, handler.accountIdToDistrbutionHourSetting.get(a.id)));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_CLOSD, handler.findNewStatus(ProspectConstants.LOG_STATUS_RECVD, null));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_PROCD, null));
	        System.AssertEquals(ProspectConstants.LOG_STATUS_ESCTD, handler.findNewStatus(ProspectConstants.LOG_STATUS_ESCTD, null));
	        
	        
	        
	        
	        
	        
	        
    }
    
}