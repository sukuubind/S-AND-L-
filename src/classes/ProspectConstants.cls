public without sharing class ProspectConstants {
    public static final String COMPARISON_TYPE_EQUAL = 'EQUALS';
    public static final String COMPARISON_TYPE_NOT_EQUAL = 'NOT EQUALS';
    public static final String COMPARISON_TYPE_CONTAINS = 'CONTAINS';
    public static final String COMPARISON_TYPE_DNC = 'DOES NOT CONTAIN';
    public static final String COMPARISON_TYPE_SW = 'STARTS WITH';
    public static final String COMPARISON_TYPE_GT = 'GREATER THAN';
    public static final String COMPARISON_TYPE_GTE = 'GREATER THAN OR EQUAL';
    public static final String COMPARISON_TYPE_LTE = 'LESS THAN OR EQUAL';
    public static final String COMPARISON_TYPE_LT = 'LESS THAN';
    public static final String FORMULA_TYPE_AND = 'AND';
    public static final String FORMULA_TYPE_OR = 'OR';
    public static final String FORMULA_DATA_TYPE_TXT = 'TEXT';
    
    
    public static final String programString              = 'Academic_Program__c';
    public static final String srpprogramString           = 'DeltakSRP__Academic_Program__c';
    public static final String specializationString       = 'Academic_Specialization__c';
    public static final String srpspecializationString    = 'DeltakSRP__Academic_Specialization__c';
    public static final String accountString               = 'Account';
    public static final String campaignString              = 'Campaign';
    public static final String parentcampaignString     = 'Parent Campaign';
    public static final String opportunityString           = 'Opportunity';
    public static final String contactString              = 'Contact';
    public static final String termString               = 'Academic_Start_Date__c';
    public static final String srptermString            = 'DeltakSRP__Academic_Start_Date__c';
    public static final String caseString 				= 'Case';
    
    public static final String programLabelString = 'Academic Program*';
    public static final String srpprogramLabelString = 'Academic Program';
    public static final String specializationLabelString = 'Academic Specialization*';
    public static final String srpspecializationLabelString = 'Academic Specialization';
    public static final String campaignLabelString = 'Campaign';
    public static final String contactLabelString = 'Affiliation';
    public static final String termLabelString = 'Academic Start Date';
    public static final String srptermLabelString = 'Academic Term';
    
    public static final String defaultObject = 'Account';
    public static final String defaultField = 'Name';
    public static final String defaultOperator = 'EQUALS';
    
    public static final String id = 'Id';
    
    public static final String LOG_STATUS_RECVD = 'Received';
    public static final String LOG_STATUS_PROCD = 'Processed';
    public static final String LOG_STATUS_ESCTD = 'Escalated';
    public static final String LOG_STATUS_CLOSD = 'Closed';
    
    public static final String SRP_ACCOUNT_RECORDTYPE = 'SRP_Account';
    public static final String SRM_ACCOUNT_RECORDTYPE= 'Campus_Partner';
    public static Schema.DescribeSObjectResult describe = Schema.SObjectType.Account;
    public static Map<string, RecordTypeInfo> recordTypes = describe.getRecordTypeInfosByName();
    
    public static final String SRP_ACCOUNT_RECORDTYPEID = recordTypes.get('Campus/Partner').getRecordTypeId(); //'01260000000Q6Ja';
    public static final String SRM_ACCOUNT_RECORDTYPEID = recordTypes.get('SRP Academic Institution').getRecordTypeId(); //'01260000000Pz69';
    
    //public static final String PROLOG_SCHEDULE_QUERY = 'Select Account__r.Name, PRO_Team__r.ESC_Exempt__c, Team_Member__c, SystemModstamp, Status__c, Process_This_Log__c, SRP_Term__c, SRP_Specialization__c, SRP_Program__c, SRM_Term__c, SRM_Specialization__c, SRM_Program__c, Regular_Not_Escalated__c, Previous_Pro_Log__c, PRO_Team__c, OwnerId, Opportunity__c, Next_Run_Time__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Contact__c, Campaign__c, Account__c From PRO_Log__c  where Status__c != \''+ProspectConstants.LOG_STATUS_CLOSD+'\' and Process_This_Log__c = true and Next_Run_Time__c < ';
    public static final String PROLOG_SCHEDULE_QUERY =  system.Label.PROspect_PROLOG_Query;
    public static final String USER_AVBL_QUERY = 'Select id, Which_user__c, Is_Team_Member_Available__c, Widget_Override__c, Process_this_availability__c from Team_Member_Availability__c where Process_this_availability__c = true ';
   
    
}