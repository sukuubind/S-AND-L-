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
@isTest
global class LoginRequestMock implements WebserviceMock{

    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           	
           partnerSoapSforceCom.LoginResponse_element responseElement = new partnerSoapSforceCom.LoginResponse_element();
           partnerSoapSforceCom.DescribeSoftphoneLayoutResult obj1 = new partnerSoapSforceCom.DescribeSoftphoneLayoutResult();
           partnerSoapSforceCom.queryMore_element obj2 = new partnerSoapSforceCom.queryMore_element();
           partnerSoapSforceCom.DescribeAppMenuResult obj3 = new partnerSoapSforceCom.DescribeAppMenuResult();
           partnerSoapSforceCom.DescribeSoftphoneLayoutItem obj4 = new partnerSoapSforceCom.DescribeSoftphoneLayoutItem();
           partnerSoapSforceCom.executeListViewResponse_element obj5 = new partnerSoapSforceCom.executeListViewResponse_element();
           partnerSoapSforceCom.DescribeSoftphoneLayoutSection obj6 = new partnerSoapSforceCom.DescribeSoftphoneLayoutSection();
           partnerSoapSforceCom.PerformQuickActionRequest obj7 = new partnerSoapSforceCom.PerformQuickActionRequest();
           partnerSoapSforceCom.describeQuickActionsResponse_element obj8 = new partnerSoapSforceCom.describeQuickActionsResponse_element();
           partnerSoapSforceCom.DescribeSoqlListViewParams obj9 = new partnerSoapSforceCom.DescribeSoqlListViewParams();
           partnerSoapSforceCom.DescribeApprovalLayoutResult obj10 = new partnerSoapSforceCom.DescribeApprovalLayoutResult();
           partnerSoapSforceCom.SearchSnippet  obj11 = new partnerSoapSforceCom.SearchSnippet();
           partnerSoapSforceCom.ReportChartComponent  obj13 = new partnerSoapSforceCom.ReportChartComponent();
           partnerSoapSforceCom.KnowledgeLanguageItem  obj14 = new partnerSoapSforceCom.KnowledgeLanguageItem();
           partnerSoapSforceCom.loginResponse_element  obj15 = new partnerSoapSforceCom.loginResponse_element();
           partnerSoapSforceCom.describeAppMenuResponse_element  obj16 = new partnerSoapSforceCom.describeAppMenuResponse_element();
           partnerSoapSforceCom.email  obj17 = new partnerSoapSforceCom.Email();
           partnerSoapSforceCom.describeSoftphoneLayout_element obj18 = new partnerSoapSforceCom.describeSoftphoneLayout_element();
           partnerSoapSforceCom.getServerTimestamp_element obj12 = new partnerSoapSforceCom.getServerTimestamp_element();
           partnerSoapSforceCom.ChildRelationship obj19 = new partnerSoapSforceCom.ChildRelationship();
           partnerSoapSforceCom.process_element obj20 = new partnerSoapSforceCom.process_element();
           partnerSoapSforceCom.DescribeLayoutComponent obj21 = new partnerSoapSforceCom.DescribeLayoutComponent();
           partnerSoapSforceCom.SoqlSubQueryCondition obj22 = new partnerSoapSforceCom.SoqlSubQueryCondition();
           partnerSoapSforceCom.LimitInfo obj23 = new partnerSoapSforceCom.LimitInfo();
           partnerSoapSforceCom.LimitInfoHeader_element obj24 = new partnerSoapSforceCom.LimitInfoHeader_element();
           partnerSoapSforceCom.QueryOptions_element obj25 = new partnerSoapSforceCom.QueryOptions_element();
           partnerSoapSforceCom.CallOptions_element obj26 = new partnerSoapSforceCom.CallOptions_element();
           partnerSoapSforceCom.describeAvailableQuickActions_element obj27 = new partnerSoapSforceCom.describeAvailableQuickActions_element();
           partnerSoapSforceCom.SoqlCondition obj28 = new partnerSoapSforceCom.SoqlCondition();
           partnerSoapSforceCom.AllOrNoneHeader_element obj29 = new partnerSoapSforceCom.AllOrNoneHeader_element();
           partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField obj30 = new partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField();
           partnerSoapSforceCom.describeTabsResponse_element obj31 = new partnerSoapSforceCom.describeTabsResponse_element();
           partnerSoapSforceCom.describeTabs_element obj32 = new partnerSoapSforceCom.describeTabs_element();
           partnerSoapSforceCom.DescribeLayoutButton obj33 = new partnerSoapSforceCom.DescribeLayoutButton();
           partnerSoapSforceCom.describeGlobalResponse_element obj34 = new partnerSoapSforceCom.describeGlobalResponse_element();
           partnerSoapSforceCom.SendEmailError obj35 = new partnerSoapSforceCom.SendEmailError();
           partnerSoapSforceCom.ListViewColumn obj36 = new partnerSoapSforceCom.ListViewColumn();
           partnerSoapSforceCom.DescribeLayoutItem obj37 = new partnerSoapSforceCom.DescribeLayoutItem();
           partnerSoapSforceCom.emptyRecycleBin_element obj38 = new partnerSoapSforceCom.emptyRecycleBin_element();
           partnerSoapSforceCom.describeSoqlListViewsResponse_element obj39 = new partnerSoapSforceCom.describeSoqlListViewsResponse_element();
           partnerSoapSforceCom.DisableFeedTrackingHeader_element obj40 = new partnerSoapSforceCom.DisableFeedTrackingHeader_element();     
           partnerSoapSforceCom.searchResponse_element obj41 = new partnerSoapSforceCom.searchResponse_element();
           partnerSoapSforceCom.MergeResult obj42 = new partnerSoapSforceCom.MergeResult();
           partnerSoapSforceCom.describeAppMenu_element obj43 = new partnerSoapSforceCom.describeAppMenu_element();
           partnerSoapSforceCom.SoqlConditionGroup obj44 = new partnerSoapSforceCom.SoqlConditionGroup();
           partnerSoapSforceCom.sendEmail_element obj45 = new partnerSoapSforceCom.sendEmail_element();
           partnerSoapSforceCom.delete_element obj46 = new partnerSoapSforceCom.delete_element();
           partnerSoapSforceCom.DescribeQuickActionListResult obj47 = new partnerSoapSforceCom.DescribeQuickActionListResult();
           partnerSoapSforceCom.DescribeLayoutButtonSection obj48 = new partnerSoapSforceCom.DescribeLayoutButtonSection();
           partnerSoapSforceCom.updateResponse_element obj49 = new partnerSoapSforceCom.updateResponse_element();
           partnerSoapSforceCom.retrieve_element obj50 = new partnerSoapSforceCom.retrieve_element();
           partnerSoapSforceCom.DescribeComponentInstanceProperty obj51 = new partnerSoapSforceCom.DescribeComponentInstanceProperty();
           partnerSoapSforceCom.RelatedList obj52 = new partnerSoapSforceCom.RelatedList();
           partnerSoapSforceCom.describeGlobalThemeResponse_element obj53 = new partnerSoapSforceCom.describeGlobalThemeResponse_element();
           partnerSoapSforceCom.describeSearchScopeOrderResponse_element obj54 = new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
           partnerSoapSforceCom.describeApprovalLayout_element obj55 = new partnerSoapSforceCom.describeApprovalLayout_element();
           partnerSoapSforceCom.DescribeThemeItem obj56 = new partnerSoapSforceCom.DescribeThemeItem();
           partnerSoapSforceCom.create_element obj57 = new partnerSoapSforceCom.create_element();
           partnerSoapSforceCom.DescribeFlexiPageRegion obj58 = new partnerSoapSforceCom.DescribeFlexiPageRegion();
           partnerSoapSforceCom.describeThemeResponse_element obj59 = new partnerSoapSforceCom.describeThemeResponse_element();
           partnerSoapSforceCom.createResponse_element obj60 = new partnerSoapSforceCom.createResponse_element();
           partnerSoapSforceCom.describeKnowledgeSettings_element obj61 = new partnerSoapSforceCom.describeKnowledgeSettings_element();
           partnerSoapSforceCom.ProcessRequest obj62 = new partnerSoapSforceCom.ProcessRequest();
           partnerSoapSforceCom.SoqlNotCondition obj63 = new partnerSoapSforceCom.SoqlNotCondition();
           partnerSoapSforceCom.DescribeQuickActionListItemResult obj64 = new partnerSoapSforceCom.DescribeQuickActionListItemResult();
           partnerSoapSforceCom.QuickActionTemplateResult obj65 = new partnerSoapSforceCom.QuickActionTemplateResult();
           partnerSoapSforceCom.LocaleOptions_element obj66 = new partnerSoapSforceCom.LocaleOptions_element();
           partnerSoapSforceCom.DescribeSoftphoneScreenPopOption obj67 = new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption();
           partnerSoapSforceCom.DescribeSoqlListView obj68 = new partnerSoapSforceCom.DescribeSoqlListView();
           partnerSoapSforceCom.getUpdatedResponse_element obj69 = new partnerSoapSforceCom.getUpdatedResponse_element();
           partnerSoapSforceCom.StreamingEnabledHeader_element obj70 = new partnerSoapSforceCom.StreamingEnabledHeader_element();
           partnerSoapSforceCom.DescribeDataCategoryGroupResult obj71 = new partnerSoapSforceCom.DescribeDataCategoryGroupResult();
           partnerSoapSforceCom.FilteredLookupInfo obj72 = new partnerSoapSforceCom.FilteredLookupInfo();
           partnerSoapSforceCom.DataCategory obj73 = new partnerSoapSforceCom.DataCategory();
           partnerSoapSforceCom.describeSoqlListViews_element obj74 = new partnerSoapSforceCom.describeSoqlListViews_element();
           partnerSoapSforceCom.DescribeLayoutResult obj75 = new partnerSoapSforceCom.DescribeLayoutResult();
           partnerSoapSforceCom.GetDeletedResult obj76 = new partnerSoapSforceCom.GetDeletedResult();
           partnerSoapSforceCom.DescribeLayoutSection obj77 = new partnerSoapSforceCom.DescribeLayoutSection();
           partnerSoapSforceCom.AssignmentRuleHeader_element obj78 = new partnerSoapSforceCom.AssignmentRuleHeader_element();
           partnerSoapSforceCom.ListViewRecordColumn obj79 = new partnerSoapSforceCom.ListViewRecordColumn();
           partnerSoapSforceCom.PackageVersionHeader_element obj80 = new partnerSoapSforceCom.PackageVersionHeader_element();
           partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element obj81 = new partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element();
           partnerSoapSforceCom.login_element obj82 = new partnerSoapSforceCom.login_element();
           partnerSoapSforceCom.SendEmailResult obj83 = new partnerSoapSforceCom.SendEmailResult();
           partnerSoapSforceCom.getUpdated_element obj84 = new partnerSoapSforceCom.getUpdated_element();
           partnerSoapSforceCom.PicklistForRecordType obj85 = new partnerSoapSforceCom.PicklistForRecordType();
           partnerSoapSforceCom.upsertResponse_element obj86 = new partnerSoapSforceCom.upsertResponse_element();
           partnerSoapSforceCom.field obj87 = new partnerSoapSforceCom.field();
           partnerSoapSforceCom.describeFlexiPagesResponse_element obj88 = new partnerSoapSforceCom.describeFlexiPagesResponse_element();
           partnerSoapSforceCom.describeSObjectsResponse_element obj89 = new partnerSoapSforceCom.describeSObjectsResponse_element();
           partnerSoapSforceCom.undeleteResponse_element obj90 = new partnerSoapSforceCom.undeleteResponse_element();
           partnerSoapSforceCom.setPasswordResponse_element obj91 = new partnerSoapSforceCom.setPasswordResponse_element();
           partnerSoapSforceCom.describeLayout_element obj92 = new partnerSoapSforceCom.describeLayout_element();
           partnerSoapSforceCom.DescribeLayout obj93 = new partnerSoapSforceCom.DescribeLayout();
           partnerSoapSforceCom.sendEmailResponse_element obj94 = new partnerSoapSforceCom.sendEmailResponse_element();
           partnerSoapSforceCom.describeKnowledgeSettingsResponse_element obj95 = new partnerSoapSforceCom.describeKnowledgeSettingsResponse_element();
           partnerSoapSforceCom.PicklistEntry obj96 = new partnerSoapSforceCom.PicklistEntry();
           partnerSoapSforceCom.UserTerritoryDeleteHeader_element obj97 = new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
           partnerSoapSforceCom.describeApprovalLayoutResponse_element obj98 = new partnerSoapSforceCom.describeApprovalLayoutResponse_element();
           partnerSoapSforceCom.SearchRecord obj99 = new partnerSoapSforceCom.SearchRecord();
           partnerSoapSforceCom.NamedLayoutInfo obj101 = new partnerSoapSforceCom.NamedLayoutInfo();
           partnerSoapSforceCom.describeSObjectResponse_element obj102 = new partnerSoapSforceCom.describeSObjectResponse_element();
           partnerSoapSforceCom.EmailHeader_element obj103 = new partnerSoapSforceCom.EmailHeader_element();
           partnerSoapSforceCom.RelatedListColumn obj104 = new partnerSoapSforceCom.RelatedListColumn();
           partnerSoapSforceCom.GetUpdatedResult obj105 = new partnerSoapSforceCom.GetUpdatedResult();
           partnerSoapSforceCom.DescribeQuickActionDefaultValue obj106 = new partnerSoapSforceCom.DescribeQuickActionDefaultValue();
           partnerSoapSforceCom.performQuickActionsResponse_element obj107 = new partnerSoapSforceCom.performQuickActionsResponse_element();
           partnerSoapSforceCom.resetPassword_element obj108 = new partnerSoapSforceCom.resetPassword_element();
           partnerSoapSforceCom.UndeleteResult obj109 = new partnerSoapSforceCom.UndeleteResult();
           partnerSoapSforceCom.NameValuePair obj110 = new partnerSoapSforceCom.NameValuePair();
           partnerSoapSforceCom.DebuggingHeader_element obj111 = new partnerSoapSforceCom.DebuggingHeader_element();
           partnerSoapSforceCom.SetPasswordResult obj112 = new partnerSoapSforceCom.SetPasswordResult();
           partnerSoapSforceCom.describeSearchScopeOrder_element obj113 = new partnerSoapSforceCom.describeSearchScopeOrder_element();
           partnerSoapSforceCom.DescribeApprovalLayout obj114 = new partnerSoapSforceCom.DescribeApprovalLayout();
           partnerSoapSforceCom.getUserInfo_element obj115 = new partnerSoapSforceCom.getUserInfo_element();
           partnerSoapSforceCom.DescribeSoqlListViewsRequest obj116 = new partnerSoapSforceCom.DescribeSoqlListViewsRequest();
           partnerSoapSforceCom.describeCompactLayouts_element obj117 = new partnerSoapSforceCom.describeCompactLayouts_element();
           partnerSoapSforceCom.ProcessResult obj118 = new partnerSoapSforceCom.ProcessResult();
           partnerSoapSforceCom.logout_element obj119 = new partnerSoapSforceCom.logout_element();
           partnerSoapSforceCom.PerformQuickActionResult obj120 = new partnerSoapSforceCom.PerformQuickActionResult();
           partnerSoapSforceCom.ResetPasswordResult obj121 = new partnerSoapSforceCom.ResetPasswordResult();
           partnerSoapSforceCom.DescribeColor obj122 = new partnerSoapSforceCom.DescribeColor();
           partnerSoapSforceCom.merge_element obj123 = new partnerSoapSforceCom.merge_element();
           partnerSoapSforceCom.describeTheme_element obj124 = new partnerSoapSforceCom.describeTheme_element();
           partnerSoapSforceCom.describeSoftphoneLayoutResponse_element obj125 = new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element();
           partnerSoapSforceCom.describeGlobal_element obj126 = new partnerSoapSforceCom.describeGlobal_element();
           partnerSoapSforceCom.RecordTypeInfo  obj127 = new partnerSoapSforceCom.RecordTypeInfo ();
           partnerSoapSforceCom.queryResponse_element obj128 = new partnerSoapSforceCom.queryResponse_element();
           partnerSoapSforceCom.describeColumn obj129 = new partnerSoapSforceCom.describecolumn();
           partnerSoapSforceCom.emptyRecycleBinResponse_element obj130 = new partnerSoapSforceCom.emptyRecycleBinResponse_element();
           partnerSoapSforceCom.EmptyRecycleBinResult obj131 = new partnerSoapSforceCom.EmptyRecycleBinResult();
           partnerSoapSforceCom.RelatedContent obj132 = new partnerSoapSforceCom.RelatedContent();
           partnerSoapSforceCom.describeDataCategoryGroupStructures_element obj133 = new partnerSoapSforceCom.describeDataCategoryGroupStructures_element();
           partnerSoapSforceCom.DescribeComponentInstance obj134 = new partnerSoapSforceCom.DescribeComponentInstance();
           partnerSoapSforceCom.DescribeRelatedContentItem obj135 = new partnerSoapSforceCom.DescribeRelatedContentItem();
           partnerSoapSforceCom.GetUserInfoResult obj136 = new partnerSoapSforceCom.GetUserInfoResult();
           partnerSoapSforceCom.QueryResult obj137 = new partnerSoapSforceCom.QueryResult();
           partnerSoapSforceCom.performQuickActions_element obj138 = new partnerSoapSforceCom.performQuickActions_element();
           partnerSoapSforceCom.FieldLayoutComponent obj139 = new partnerSoapSforceCom.FieldLayoutComponent();
           partnerSoapSforceCom.sendEmailMessage_element obj140 = new partnerSoapSforceCom.sendEmailMessage_element();
           partnerSoapSforceCom.MruHeader_element obj141 = new partnerSoapSforceCom.MruHeader_element();
           partnerSoapSforceCom.processResponse_element obj142 = new partnerSoapSforceCom.processResponse_element();
           partnerSoapSforceCom.DescribeSearchScopeOrderResult obj143 = new partnerSoapSforceCom.DescribeSearchScopeOrderResult();
           partnerSoapSforceCom.ProcessWorkitemRequest obj144 = new partnerSoapSforceCom.ProcessWorkitemRequest();
           partnerSoapSforceCom.SoqlWhereCondition obj145 = new partnerSoapSforceCom.SoqlWhereCondition();
           partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult obj146 = new partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult();
           partnerSoapSforceCom.executeListView_element obj147 = new partnerSoapSforceCom.executeListView_element();
           partnerSoapSforceCom.DescribeFlexiPageResult obj148 = new partnerSoapSforceCom.DescribeFlexiPageResult();
           partnerSoapSforceCom.ListViewOrderBy obj149 = new partnerSoapSforceCom.ListViewOrderBy();
           partnerSoapSforceCom.describeDataCategoryGroups_element obj150 = new partnerSoapSforceCom.describeDataCategoryGroups_element();
           partnerSoapSforceCom.AllowFieldTruncationHeader_element obj151 = new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
           partnerSoapSforceCom.ActionOverride obj152 = new partnerSoapSforceCom.ActionOverride();
           partnerSoapSforceCom.getDeletedResponse_element obj153 = new partnerSoapSforceCom.getDeletedResponse_element();
           partnerSoapSforceCom.SaveResult obj154 = new partnerSoapSforceCom.SaveResult();
           partnerSoapSforceCom.deleteResponse_element obj155 = new partnerSoapSforceCom.deleteResponse_element();
           partnerSoapSforceCom.RecordTypeCompactLayoutMapping obj156 = new partnerSoapSforceCom.RecordTypeCompactLayoutMapping();
           partnerSoapSforceCom.describeSObjects_element obj157 = new partnerSoapSforceCom.describeSObjects_element();
           partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element obj158 = new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element();
           partnerSoapSforceCom.update_element obj159 = new partnerSoapSforceCom.update_element();
           partnerSoapSforceCom.search_element obj160 = new partnerSoapSforceCom.search_element();
           partnerSoapSforceCom.DescribeAvailableQuickActionResult obj161 = new partnerSoapSforceCom.DescribeAvailableQuickActionResult();
           partnerSoapSforceCom.describeQuickActions_element obj162 = new partnerSoapSforceCom.describeQuickActions_element();
           partnerSoapSforceCom.RelatedListSort obj163 = new partnerSoapSforceCom.RelatedListSort();
           partnerSoapSforceCom.describeSObject_element obj164 = new partnerSoapSforceCom.describeSObject_element();
           partnerSoapSforceCom.invalidateSessionsResponse_element obj165 = new partnerSoapSforceCom.invalidateSessionsResponse_element();
           partnerSoapSforceCom.LoginScopeHeader_element obj166 = new partnerSoapSforceCom.LoginScopeHeader_element();
           partnerSoapSforceCom.EmailFileAttachment obj167 = new partnerSoapSforceCom.EmailFileAttachment();
           partnerSoapSforceCom.convertLeadResponse_element obj168 = new partnerSoapSforceCom.convertLeadResponse_element();
           partnerSoapSforceCom.queryAll_element obj169 = new partnerSoapSforceCom.queryAll_element();
           partnerSoapSforceCom.describeSearchLayoutsResponse_element obj170 = new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
           partnerSoapSforceCom.GetServerTimestampResult obj171 = new partnerSoapSforceCom.GetServerTimestampResult();
           partnerSoapSforceCom.describePrimaryCompactLayouts_element obj172 = new partnerSoapSforceCom.describePrimaryCompactLayouts_element();
           partnerSoapSforceCom.retrieveResponse_element obj173 = new partnerSoapSforceCom.retrieveResponse_element();
           partnerSoapSforceCom.queryAllResponse_element obj174 = new partnerSoapSforceCom.queryAllResponse_element();
           partnerSoapSforceCom.invalidateSessions_element obj175 = new partnerSoapSforceCom.invalidateSessions_element();
           partnerSoapSforceCom.location obj176 = new partnerSoapSforceCom.location();
           partnerSoapSforceCom.ProcessSubmitRequest obj177 = new partnerSoapSforceCom.ProcessSubmitRequest();
           partnerSoapSforceCom.describeLayoutResponse_element obj178 = new partnerSoapSforceCom.describeLayoutResponse_element();
           partnerSoapSforceCom.DescribeSearchLayoutResult obj179 = new partnerSoapSforceCom.DescribeSearchLayoutResult();
           partnerSoapSforceCom.getServerTimestampResponse_element obj180 = new partnerSoapSforceCom.getServerTimestampResponse_element();
           partnerSoapSforceCom.DescribeIcon obj181 = new partnerSoapSforceCom.DescribeIcon();
           partnerSoapSforceCom.DeletedRecord obj182 = new partnerSoapSforceCom.DeletedRecord();
           partnerSoapSforceCom.SearchResult obj183 = new partnerSoapSforceCom.SearchResult();
           partnerSoapSforceCom.describeGlobalTheme_element obj184 = new partnerSoapSforceCom.describeGlobalTheme_element();
           partnerSoapSforceCom.query_element obj185 = new partnerSoapSforceCom.query_element();
           partnerSoapSforceCom.getDeleted_element obj186 = new partnerSoapSforceCom.getDeleted_element();
           partnerSoapSforceCom.DataCategoryGroupSobjectTypePair obj187 = new partnerSoapSforceCom.DataCategoryGroupSobjectTypePair();
           partnerSoapSforceCom.PackageVersion obj188 = new partnerSoapSforceCom.PackageVersion();
           partnerSoapSforceCom.DescribeGlobalResult obj189 = new partnerSoapSforceCom.DescribeGlobalResult();
           partnerSoapSforceCom.DescribeGlobalTheme obj190 = new partnerSoapSforceCom.DescribeGlobalTheme();
           partnerSoapSforceCom.describeCompactLayoutsResponse_element obj191 = new partnerSoapSforceCom.describeCompactLayoutsResponse_element();
           partnerSoapSforceCom.describeSearchLayouts_element obj192 = new partnerSoapSforceCom.describeSearchLayouts_element();
           partnerSoapSforceCom.describeAllTabs_element obj193 = new partnerSoapSforceCom.describeAllTabs_element();
           partnerSoapSforceCom.SingleEmailMessage obj194 = new partnerSoapSforceCom.SingleEmailMessage();
           partnerSoapSforceCom.MassEmailMessage obj195 = new partnerSoapSforceCom.MassEmailMessage();
           partnerSoapSforceCom.mergeResponse_element obj196 = new partnerSoapSforceCom.mergeResponse_element();
           partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element obj197 = new partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element();
           partnerSoapSforceCom.DescribeAppMenuItem obj198 = new partnerSoapSforceCom.DescribeAppMenuItem();
           partnerSoapSforceCom.DescribeTabSetResult obj199 = new partnerSoapSforceCom.DescribeTabSetResult();
           partnerSoapSforceCom.getUserInfoResponse_element obj200 = new partnerSoapSforceCom.getUserInfoResponse_element();
           partnerSoapSforceCom.DescribeCompactLayoutsResult obj201 = new partnerSoapSforceCom.DescribeCompactLayoutsResult();
           partnerSoapSforceCom.UpsertResult obj202 = new partnerSoapSforceCom.UpsertResult();
           partnerSoapSforceCom.DescribeSObjectResult obj203 = new partnerSoapSforceCom.DescribeSObjectResult();
           partnerSoapSforceCom.retrieveQuickActionTemplates_element obj204 = new partnerSoapSforceCom.retrieveQuickActionTemplates_element();
           partnerSoapSforceCom.logoutResponse_element obj205 = new partnerSoapSforceCom.logoutResponse_element();
           partnerSoapSforceCom.InvalidateSessionsResult obj206 = new partnerSoapSforceCom.InvalidateSessionsResult();
           partnerSoapSforceCom.ListViewRecord obj207 = new partnerSoapSforceCom.ListViewRecord();
           partnerSoapSforceCom.RecordTypeMapping obj208 = new partnerSoapSforceCom.RecordTypeMapping();
           partnerSoapSforceCom.DescribeGlobalSObjectResult obj209 = new partnerSoapSforceCom.DescribeGlobalSObjectResult();
           partnerSoapSforceCom.KnowledgeSettings obj210 = new partnerSoapSforceCom.KnowledgeSettings();
           partnerSoapSforceCom.DescribeQuickActionResult obj211 = new partnerSoapSforceCom.DescribeQuickActionResult();
           partnerSoapSforceCom.DescribeSoqlListViewResult obj212 = new partnerSoapSforceCom.DescribeSoqlListViewResult();
           partnerSoapSforceCom.DebuggingInfo_element obj213 = new partnerSoapSforceCom.DebuggingInfo_element();
           partnerSoapSforceCom.undelete_element obj214 = new partnerSoapSforceCom.undelete_element();
           partnerSoapSforceCom.DeleteResult obj215 = new partnerSoapSforceCom.DeleteResult();
           partnerSoapSforceCom.queryMoreResponse_element obj216 = new partnerSoapSforceCom.queryMoreResponse_element();
           partnerSoapSforceCom.upsert_element obj217 = new partnerSoapSforceCom.upsert_element();
           partnerSoapSforceCom.OwnerChangeOptions_element obj218 = new partnerSoapSforceCom.OwnerChangeOptions_element();
           partnerSoapSforceCom.DescribeLayoutRow obj219 = new partnerSoapSforceCom.DescribeLayoutRow();
           partnerSoapSforceCom.DescribeCompactLayout obj220 = new partnerSoapSforceCom.DescribeCompactLayout();
           partnerSoapSforceCom.describeAllTabsResponse_element obj221 = new partnerSoapSforceCom.describeAllTabsResponse_element();
           partnerSoapSforceCom.describeAvailableQuickActionsResponse_element obj222 = new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
           partnerSoapSforceCom.setPassword_element obj223 = new partnerSoapSforceCom.setPassword_element();
           partnerSoapSforceCom.DescribeSoftphoneLayoutCallType obj224 = new partnerSoapSforceCom.DescribeSoftphoneLayoutCallType();
           partnerSoapSforceCom.DescribeThemeResult obj225 = new partnerSoapSforceCom.DescribeThemeResult();
           partnerSoapSforceCom.describeFlexiPages_element obj226 = new partnerSoapSforceCom.describeFlexiPages_element();
           partnerSoapSforceCom.ExecuteListViewResult obj227 = new partnerSoapSforceCom.ExecuteListViewResult();
           partnerSoapSforceCom.sendEmailMessageResponse_element obj228 = new partnerSoapSforceCom.sendEmailMessageResponse_element();
           partnerSoapSforceCom.address obj229 = new partnerSoapSforceCom.address();
           partnerSoapSforceCom.resetPasswordResponse_element obj230 = new partnerSoapSforceCom.resetPasswordResponse_element();
           partnerSoapSforceCom.MergeRequest obj240 = new partnerSoapSforceCom.MergeRequest();
           partnerSoapSforceCom.DescribeTab obj231 = new partnerSoapSforceCom.DescribeTab();
           partnerSoapSforceCom.Soap obj232 = new partnerSoapSforceCom.Soap();
           //Map<String, Object> response,
        // Create response element from the autogenerated class.
        // Populate response element.
        // Add response element to the response parameter, as follows:
          response.put('response_x', responseElement); 
   }
}