public with sharing class SRPPrintProgramPageConfigs {

    private final DeltakSRP__Student_Online_Application__c onlineAppId;

    public List<DeltakSRP__Program_Field_Config__c> programFieldConfigs { get; set; }
    public List<DeltakSRP__Program_Page_Config__c> pageConfigName { get; set; }
    public List<DeltakSRP__Student_Online_Application__c> appDetails { get; set; }
    public List<DeltakSRP__Program_Online_Application_Config__c > submissionText { get; set; }

    public List<String> distpageConfigName { get; set; }
    public List<String> distpageConfigNameList { get; set; }
    public List<String> refNames { get; set; }

    public Map<String, Map<String, String>> displayData { get; set; }
    public Map<String, Map<String, String>> displayDataList { get; set; }
    public Map<String, List<String>> dispOrderedData { get; set; }
    public Map<String, List<String>> dispOrderedDataList { get; set; }
    public Map<String, String> tupleNametoPageconfigName { get; set; }
    public Map<String, String> refNameToRefEmail { get; set; }
    public Map<String, Map<String, String>> displayShortData { get; set; }
    public Map<String, Map<String, String>> displayLongData { get; set; }
    public List<Id> tupleName_Id { get; set; }
    public Map<String, String> tupleNametoPageconfigID { get; set; }
    public Map<String, Map<String, String>> dispDataLabel { get; set; }

    public Map<String, Map<String, String>> displayShortDataList { get; set; }
    public Map<String, Map<String, String>> displayLongDataList { get; set; }

    public Boolean listFlag { get; set; }

    public SRPPrintProgramPageConfigs(ApexPages.StandardController controller) {
        this.onlineAppId = (DeltakSRP__Student_Online_Application__c) controller.getRecord();

        listFlag = true;
        appDetails = new List<DeltakSRP__Student_Online_Application__c>();
        appDetails = applicationDetails();

        refNameToRefEmail = new Map<String, String>();
        refNames = new List<String>();
        pgmConfigsForReferences();

        submissionText = new List<DeltakSRP__Program_Online_Application_Config__c >();
        printSubmissionText();

        distpageConfigName = new List<String>();
        distpageConfigNameList = new List<String>();


        dispOrderedData = new Map<String, List<String>>();
        displayData = new Map<String, Map<String, String>>();
        displayShortData = new Map<String, Map<String, String>>();
        displayLongData = new Map<String, Map<String, String>>();
        dispDataLabel = new Map<String, Map<String, String>>();
        pgmConfigs();

        tupleNametoPageconfigName = new Map<String, String>();
        tupleNametoPageconfigID = new Map<String, String>();
        tupleName_Id = new List<id>();
        dispOrderedDataList = new Map<String, List<String>>();
        displayDataList = new Map<String, Map<String, String>>();
        displayShortDataList = new Map<String, Map<String, String>>();
        displayLongDataList = new Map<String, Map<String, String>>();
        pgmConfigsForList();

    }

// this method fetches application related data like applicant name, application number etc 
    public List<DeltakSRP__Student_Online_Application__c> applicationDetails() {
        List<DeltakSRP__Student_Online_Application__c> appDetails = [
                Select d.DeltakSRP__Online_Application_Config__r.Name,
                        d.DeltakSRP__Affiliation__r.Name,Name,
                        d.DeltakSRP__Academic_Program__r.Name,
                        d.DeltakSRP__Academic_Program__r.DeltakSRP__Program_Title__c,
                        // d.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c,
                        d.DeltakSRP__Academic_Start_Date__r.DeltakSRP__Online_Application_Label__c,


                        d.DeltakSRP__Academic_Start_Date__r.DeltakSRP__End_Date__c
                From DeltakSRP__Student_Online_Application__c d
                WHERE DeltakSRP__Student_Online_Application__c.Id = :onlineAppId.id
        ];

        return appDetails;
    }


    public PageReference pgmConfigs() {
        List<DeltakSRP__Student_Online_Application__c> onlineAppConfig = [
                SELECT DeltakSRP__Online_Application_Config__c
                FROM DeltakSRP__Student_Online_Application__c d
                WHERE DeltakSRP__Student_Online_Application__c.Id = :onlineAppId.id
        ];

// onlineConfigID stores current Online Application Config ID
        List<ID> onlineConfigID = new List<ID>();
        for (DeltakSRP__Student_Online_Application__c ids : onlineAppConfig) {
            onlineConfigID.add(ids.DeltakSRP__Online_Application_Config__c);
        }

        if (onlineConfigID != null) {

            List<DeltakSRP__Program_Field_Config__c> programFieldConfigs = [
                    SELECT d.Name, d.Id, d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c,
                            d.DeltakSRP__Page__r.Name, d.DeltakSRP__Page__c, d.DeltakSRP__Order__c,
                            d.DeltakSRP__Page__r.DeltakSRP__Order__c, d.DeltakSRP__Page__r.DeltakSRP__Type__c,
                            d.DeltakSRP__Application_Field_Name__c
                    FROM DeltakSRP__Program_Field_Config__c d
                    WHERE d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c IN :onlineConfigID
                    AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'List' AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'Payment'
                    AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'References' AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'Documents'
                    order by d.DeltakSRP__Order__c, d.DeltakSRP__Page__r.DeltakSRP__Order__c
            ];

            List<DeltakSRP__Program_Page_Config__c> pageConfigName = [
                    SELECT d.Name
                    FROM DeltakSRP__Program_Page_Config__c d
                    WHERE d.DeltakSRP__Online_Application_Config__c IN :onlineConfigID
                    AND d.DeltakSRP__Type__c != 'List' AND d.DeltakSRP__Type__c != 'Payment'
                    AND d.DeltakSRP__Type__c != 'References' AND d.DeltakSRP__Type__c != 'Documents'
                    AND d.Do_not_show_on_PDF__c = false
                    order by DeltakSRP__Order__c
            ];

            for (DeltakSRP__Program_Page_Config__c d : pageConfigName) {
                distpageConfigName.add(d.Name);
            }
            system.debug('distpageConfigName>>>>' + distpageConfigName);

            // All the field labels in fieldLabels
            List<String> fieldLabels = new List<String>();

            if (programFieldConfigs != null && programFieldConfigs.size() > 0) {
                for (DeltakSRP__Program_Field_Config__c pfc : programFieldConfigs) {
                    fieldLabels.add(pfc.Name);
                }

            }

            // map of field label to API name
            Map<String, String> fieldLblAPIName = new Map <String, String>();
            Map<String, String> fieldNametoId = new Map <String, String>();

            // longDispField will store the field labels that dont have API names. Those are long display fields.
            List<String> longDispField = new List<String>();
            if (programFieldConfigs != null) {
                for (DeltakSRP__Program_Field_Config__c f : programFieldConfigs) {
                    if (f.DeltakSRP__Application_Field_Name__c == null || f.DeltakSRP__Application_Field_Name__c == '') {
                        longDispField.add(f.id);
                    } else {

                        fieldLblAPIName.put(f.id, f.DeltakSRP__Application_Field_Name__c);
                        fieldNametoId.put(f.Name, f.id);
                        system.debug('fieldLblAPIName--->>>' + fieldLblAPIName);
                    }
                }
            }
            Set<String> fieldLbl = new Set<String>();
            Set<String> fieldname = new Set<String>();
            fieldLbl = fieldLblAPIName.keySet();
            fieldname = fieldNametoId.keySet();

            // convert fieldLbl Set to List
            List<String> fieldLbls = new List<String>();
            fieldLbls.addAll(fieldLbl);

            List<String> fieldnames = new List<String>();
            fieldnames.addAll(fieldname);

            listFlag = true;
            Map<String, Schema.DisplayType> fieldDisplayType = new Map<String, Schema.DisplayType>();
            // fieldLblAPIName stores the filed API names pre-attached with 'DeltakSRP__' . it overwrites the existing API names with modified names
            for (Integer i = 0; i < fieldLbls.size(); i++) {
                String fieldLabelName = fieldLbls[i];
                //String fieldapi = fieldLbls[i];

                String tempName = fieldLblAPIName.get(fieldLabelName);
                System.debug('API NAMES-->>>' + tempname);
                string tempField = AttachDeltakSRP(tempName);
                if (tempField == 'Ethnicity__c')
                    tempField = 'DeltakSRP__Ethnicity__c';
                fieldDisplayType.put(tempField, ProspectRuleEvaluationUtils.findFieldType('', 'DeltakSRP__Student_Online_Application__c', tempField));
                fieldLblAPIName.remove(fieldLbls[i]);
                fieldLblAPIName.put(fieldLabelName, tempField);
            }
            List<String> apiNames = fieldLblAPIName.values();
            System.debug('NEW API NAMES-->' + apiNames);

            //dynamic query to select API names from DeltakSRP__Student_Online_Application for current appID
            String query = 'SELECT ';
            for (Integer i = 0; i < apiNames.size(); i++) {
                query += apiNames[i] + ',' ;
            }
            query += ' DeltakSRP__Online_Application_Config__c FROM DeltakSRP__Student_Online_Application__c';
            query += ' WHERE id = \'';
            query += onlineAppId.id + '\'';

            SObject sObj = new DeltakSRP__Student_Online_Application__c();
            sObj = Database.query(query);

            System.debug('Query-->>' + query);
            // map of API Name to field data
            Map<String, String> APINameToData = new Map<String, String>();

            for (Integer i = 0; i < apiNames.size(); i++) {

                String apiNameToSave = apiNames.get(i);
                System.debug('API NAME TO SAVE-->>' + apiNameToSave);
                APINameToData.put(apiNameToSave, String.valueOF(sObj.get(apiNameToSave)));
                System.debug('NEW MAP-->>' + APINameToData);
            }

            Map<String, List<DeltakSRP__Program_Field_Config__c> > pageConfigToFieldConfigList = new Map<String, List<DeltakSRP__Program_Field_Config__c> >();
            Map<String, List<id> > pagenameTofieldid = new Map<String, List<id> >();

            List<DeltakSRP__Program_Field_Config__c> fldLabels = [
                    SELECT d.Id,d.Name, d.DeltakSRP__Page__r.Name, d.DeltakSRP__Page__c,d.DeltakSRP__Description__c,
                            d.DeltakSRP__Long_Description__c
                    FROM DeltakSRP__Program_Field_Config__c d
                    WHERE d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c = :onlineConfigID
                    AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'List' AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'Payment'
                    AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'References' AND d.DeltakSRP__Page__r.DeltakSRP__Type__c != 'Documents'
                    AND d.DeltakSRP__Page__r.Name IN :distpageConfigName
                    order by d.DeltakSRP__Page__r.DeltakSRP__Order__c, d.DeltakSRP__Order__c asc
            ];


            system.debug('fldLabels-->>' + fldLabels);
            //    List<DeltakSRP__Program_Field_Config__c> tempList = null;

            for (DeltakSRP__Program_Field_Config__c thisFieldConfig : fldLabels) {
                List<DeltakSRP__Program_Field_Config__c> tempList = new List<DeltakSRP__Program_Field_Config__c>();
                List<id> tempList2 = new List<id>();
                if (pageConfigToFieldConfigList.containsKey(thisFieldConfig.DeltakSRP__Page__r.Name)) {
                    tempList = pageConfigToFieldConfigList.get(thisFieldConfig.DeltakSRP__Page__r.Name);
                    tempList2 = pagenameTofieldid.get(thisFieldConfig.DeltakSRP__Page__r.Name);
                }
                tempList.add(thisFieldConfig);
                tempList2.add(thisFieldConfig.id);
                System.debug('Added Id' + thisFieldConfig.id);
                pageConfigToFieldConfigList.put(thisFieldConfig.DeltakSRP__Page__r.Name, tempList);
                pagenameTofieldid.put(thisFieldConfig.DeltakSRP__Page__r.Name, tempList2);

                system.debug('MAP WITH FIELD ID-->>' + pagenameTofieldid);
            }

            //  system.debug('pageConfigToFieldConfigList'+pageConfigToFieldConfigList);
            system.debug('DIST PAGE' + distpageConfigName.size());
            for (Integer i = 0; i < distpageConfigName.size(); i++) {
                List<DeltakSRP__Program_Field_Config__c> fieldConfigList = new List<DeltakSRP__Program_Field_Config__c>();
                if (pageConfigToFieldConfigList != null && pageConfigToFieldConfigList.containsKey(distpageConfigName[i]))
                //if(pagenameTofieldid != null && pagenameTofieldid.containsKey(distpageConfigName[i]))
                {
                    fieldConfigList = pageConfigToFieldConfigList.get(distpageConfigName[i]);
                    system.debug('Different Page-->>' + distpageConfigName[i]);
                    system.debug('Separete page fields-->>' + fieldConfigList);
                }
                Map<String, String> shortDescriptionMap = new Map<String, String>();
                Map<String, String> longDescriptionMap = new Map<String, String>();

                Map<String, String> m = new Map<String, String>();
                Map<String, String> mLabel = new Map<String, String>();
                List<String> lblFld = new List<String>();
                for (Integer j = 0; j < fieldConfigList.size(); j++) {
                    String fData = '';
                    String fLabel = '';

                    String description = '';
                    String longDesc = '';
                    system.debug('distpageConfigName if' + distpageConfigName[i]);
                    system.debug('fieldConfigList[j]' + fieldConfigList[j].DeltakSRP__Page__r.Name);
                    if (distpageConfigName[i] == fieldConfigList[j].DeltakSRP__Page__r.Name) {
                        System.debug('Page Name Matched-->>>');
                        if (fieldConfigList[j].Name != null) {
                            fLabel = (fieldConfigList[j].Name);
                        } else {
                            fLabel = '';
                        }
                        System.debug('FIELD API NAME THROUGH MAP->' + fieldLblAPIName.get(fieldConfigList[j].id));
                        if (fieldLblAPIName.get(fieldConfigList[j].id) != NULL) {
                            String apiName = fieldLblAPIName.get(fieldConfigList[j].id);
                            String daata = '';

                            system.debug('FLDTYPE' + fieldDisplayType);
                            system.debug('DATE-->>>!' + Schema.displayType.Date);
                            system.debug('APINameToData-->>>>' + APINameToData);
                            if (fieldDisplayType.get(apiName) == Schema.displayType.Date) {
                                if (APINameToData.get(apiName) != null) {
                                    Date d = Date.valueOf(APINameToData.get(apiName));
                                    daata = d.format();
                                } else {
                                    daata = null;

                                }
                            } else {
                                daata = APINameToData.get(apiName);

                            }
                            if (daata != null)
                                fData = daata; else
                                    fData = '';
                        } else {
                            fData = '';
                        }

                        m.put(fieldConfigList[j].id, fData);
                        mLabel.put(fieldConfigList[j].id, fLabel);
                        system.debug('Map m' + m);
                        lblFld.add(fieldConfigList[j].id);
                        system.debug('FLABEL' + fLabel);

                        description = fieldConfigList[j].DeltakSRP__Description__c;
                        if (description == null)
                            description = '';
                        system.debug('description' + description);
                        longDesc = fieldConfigList[j].DeltakSRP__Long_Description__c;
                        if (longDesc == null)
                            longDesc = '';
                        system.debug('longDesc' + longDesc);
                        system.debug('FLABEL' + fLabel);
                        shortDescriptionMap.put(fieldConfigList[j].id, description);
                        system.debug('Short descriptionMap' + shortDescriptionMap);
                        longDescriptionMap.put(fieldConfigList[j].id, longDesc);
                        system.debug('Long descriptionMap' + longDescriptionMap);

                    }
                }
                system.debug('DISTAPAGE config' + distpageConfigName[i]);
                dispOrderedData.put(distpageConfigName[i], lblFld);

                system.debug('dispOrderedData' + dispOrderedData);
                displayData.put(distpageConfigName[i], m);
                dispDataLabel.put(distpageConfigName[i], mLabel);
                system.debug('displayData' + displayData);
                system.debug('shortDescriptionMap' + shortDescriptionMap);
                displayShortData.put(distpageConfigName[i], shortDescriptionMap);
                system.debug('displayShortData' + displayShortData);
                displayLongData.put(distpageConfigName[i], longDescriptionMap);
                system.debug('displayLongData' + displayLongData);
            }
        }
        return null;
    }

    // version2
    public PageReference pgmConfigsForList() {
        List<DeltakSRP__Student_Online_Application__c> onlineAppConfig = [
                SELECT DeltakSRP__Online_Application_Config__c
                FROM DeltakSRP__Student_Online_Application__c d
                WHERE DeltakSRP__Student_Online_Application__c.Id = :onlineAppId.id
        ];

// onlineConfigID stores current Online Application Config ID
        List<ID> onlineConfigID = new List<ID>();
        for (DeltakSRP__Student_Online_Application__c ids : onlineAppConfig) {
            onlineConfigID.add(ids.DeltakSRP__Online_Application_Config__c);
        }

        if (onlineConfigID != null) {
            List<DeltakSRP__Program_Field_Config__c> programFieldConfigs = [
                    SELECT d.Name, d.Id, d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c,
                            d.DeltakSRP__Page__r.Name, d.DeltakSRP__Page__c, d.DeltakSRP__Order__c,
                            d.DeltakSRP__Page__r.DeltakSRP__Order__c,
                            d.DeltakSRP__Page__r.DeltakSRP__Type__c,d.DeltakSRP__Application_Field_Name__c
                    FROM DeltakSRP__Program_Field_Config__c d
                    WHERE d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c IN :onlineConfigID
                    AND d.DeltakSRP__Page__r.DeltakSRP__Type__c = 'List'
                    order by d.DeltakSRP__Page__c, d.DeltakSRP__Order__c
            ];

            for (DeltakSRP__Program_Field_Config__c p : programFieldConfigs) {
                system.debug('programFieldConfigs--->>' + p.Name);
            }
            system.debug('programFieldConfigsSize--->>' + programFieldConfigs.size());

            List<DeltakSRP__Program_Page_Config__c> pageConfigName = [
                    SELECT d.Name, d.id
                    FROM DeltakSRP__Program_Page_Config__c d
                    WHERE d.DeltakSRP__Online_Application_Config__c IN :onlineConfigID
                    AND d.DeltakSRP__Type__c = 'List'
                    order by DeltakSRP__Order__c asc
            ];

            List<id> pgconfigId = new List<id>();
            for (DeltakSRP__Program_Page_Config__c d : pageConfigName) {
                distpageConfigNameList.add(d.Name);
                pgconfigId.add(d.id);
            }

            system.debug('distpageConfigNameList--->>>' + distpageConfigNameList);

            List<DeltakSRP__Student_Online_Application_Tuple__c> tupleId = new List<DeltakSRP__Student_Online_Application_Tuple__c>();
            //List<DeltakSRP__Student_Online_Application_Tuple__c> tupleId_pr = new List<DeltakSRP__Student_Online_Application_Tuple__c>();
            Map<Id, String> tupIdToTupName = new Map<Id, String>();
            tupleId = [
                    Select d.Name, d.Id, d.DeltakSRP__Program_Page_Config__r.Name, d.DeltakSRP__Program_Page_Config__c
                    From DeltakSRP__Student_Online_Application_Tuple__c d
                    where d.DeltakSRP__Student_Online_Application__c = :onlineAppId.id
                    and d.DeltakSRP__Program_Page_Config__c IN :pgconfigId
                    order by d.DeltakSRP__Program_Page_Config__r.Name, d.CreatedDate asc
            ];


            for (DeltakSRP__Student_Online_Application_Tuple__c t :tupleId) {
                tupleName_Id.add(t.id);
                tupleNametoPageconfigName.put(t.id, t.DeltakSRP__Program_Page_Config__r.Name);
                tupIdToTupName.put(t.id, t.Name);
            }

            system.debug('tupleNametoPageconfigName' + tupleNametoPageconfigName);

            // All the field labels in fieldLabels
            List<String> fieldLabels = new List<String>();

            if (programFieldConfigs.size() > 0) {
                for (DeltakSRP__Program_Field_Config__c pfc : programFieldConfigs) {
                    fieldLabels.add(pfc.Name);
                }
            }
            // map of field label to API name
            Map<String, String> fieldLblAPIName = new Map <String, String>();

            // longDispField will store the field labels that dont have API names. Those are long display fields.
            List<String> longDispField = new List<String>();

            for (DeltakSRP__Program_Field_Config__c f : programFieldConfigs) {
                if (f.DeltakSRP__Application_Field_Name__c == null || f.DeltakSRP__Application_Field_Name__c == '') {
                    longDispField.add(f.id);
                } else {

                    fieldLblAPIName.put(f.id, f.DeltakSRP__Application_Field_Name__c);
                }
            }

            Set<String> fieldLbl = new Set<String>();
            fieldLbl = fieldLblAPIName.keySet();
            system.debug('fieldLbl--->>>' + fieldLbl.size());

            // convert fieldLbl Set to List
            List<String> fieldLbls = new List<String>();
            fieldLbls.addAll(fieldLbl);
            system.debug('fieldLbls--->>>' + fieldLbls.size());

            listFlag = false;
            Map<String, Schema.DisplayType> fieldDisplayType = new Map<String, Schema.DisplayType>();

            // fieldLblAPIName stores the field API names pre-attached with 'DeltakSRP__' . it overwrites the existing API names with modified names
            for (Integer i = 0; i < fieldLbls.size(); i++) {
                String fieldLabelName = fieldLbls[i];
                String tempName = fieldLblAPIName.get(fieldLabelName);
                string tempField = AttachDeltakSRP(tempName);
                fieldDisplayType.put(tempField, ProspectRuleEvaluationUtils.findFieldType('', 'DeltakSRP__Student_Online_Application_Tuple__c', tempField));
                fieldLblAPIName.remove(fieldLbls[i]);
                fieldLblAPIName.put(fieldLabelName, tempField);
            }

            List<String> apiNames = fieldLblAPIName.values();

            //dynamic query to select API names from DeltakSRP__Student_Online_Application_tuple for current appID
            String query = 'SELECT ';
            for (Integer i = 0; i < apiNames.size(); i++) {
                system.debug('apiNames[i]--->>>' + apiNames[i]);
                query += apiNames[i] + ',' ;
            }
            query += ' DeltakSRP__Student_Online_Application__c,DeltakSRP__Program_Page_Config__r.Name FROM DeltakSRP__Student_Online_Application_Tuple__c';
            query += ' WHERE DeltakSRP__Student_Online_Application__c = \'';
            query += onlineAppId.id + '\' order by DeltakSRP__Program_Page_Config__r.Name,CreatedDate asc';

            system.debug('query--->>>' + query);

            List<SObject> sObj = new List<DeltakSRP__Student_Online_Application_Tuple__c>();
            if (tupleId != null && tupleId.size() > 0) {
                sObj = Database.query(query);
                system.debug('START DATE OF COLLEGE-->>' + sObj);
                // map of API Name to field data
                Map<String, String> APINameToData = new Map<String, String>();
                Map<String, Map<String, String>> tupleMap = new Map<String, Map<String, String>>();

                for (SObject sos : sObj) {
                    for (Integer i = 0; i < apiNames.size(); i++) {
                        if (tupleMap.containsKey(sos.id)) {
                            String apiNameToSave = apiNames.get(i);
                            Map<String, String> newAPINameToDataMap = tupleMap.get(sos.id);
                            newAPINameToDataMap.put(apiNameToSave, String.valueOF(sos.get(apiNameToSave)));
                            tupleMap.put(sos.id, newAPINameToDataMap);
                        } else {
                            String apiNameToSave = apiNames.get(i);
                            Map<String, String> newAPINameToDataMap = new Map<String, String>();
                            newAPINameToDataMap.put(apiNameToSave, String.valueOF(sos.get(apiNameToSave)));
                            tupleMap.put(sos.id, newAPINameToDataMap);
                        }

                    }
                }
                System.debug('ISOLATED TUPLES-->>' + tupleMap);
                Map<String, Map<String, String>> displayData = new Map<String, Map<String, String>>();
                Map<String, List<DeltakSRP__Program_Field_Config__c> > pageConfigToFieldConfigList = new Map<String, List<DeltakSRP__Program_Field_Config__c> >();
                Map<String, List<id> > pagenameTofieldid = new Map<String, List<id> >();
                List<DeltakSRP__Program_Field_Config__c> fldLabels = [
                        SELECT d.Id,d.Name, d.DeltakSRP__Page__r.Name, d.DeltakSRP__Page__c,d.DeltakSRP__Description__c,
                                d.DeltakSRP__Long_Description__c
                        FROM DeltakSRP__Program_Field_Config__c d
                        WHERE d.DeltakSRP__Page__r.DeltakSRP__Online_Application_Config__c = :onlineConfigID
                        AND d.DeltakSRP__Page__r.DeltakSRP__Type__c = 'List'
                        AND d.DeltakSRP__Page__r.Name IN :distpageConfigNameList
                        order by d.DeltakSRP__Page__r.DeltakSRP__Order__c, d.DeltakSRP__Order__c asc
                ];
                Set<string> fids = new set<string>();
                for (DeltakSRP__Program_Field_Config__c f : fldLabels) {
                    fids.add(f.id);
                }
                List<string> fieldids = new List<string>();
                fieldids.addAll(fids);
                List<string> field_ids = new List<string>();
                for (DeltakSRP__Program_Field_Config__c thisFieldConfig : fldLabels) {
                    List<DeltakSRP__Program_Field_Config__c> tempList = new List<DeltakSRP__Program_Field_Config__c>();
                    List<id> tempList2 = new List<id>();
                    if (pageConfigToFieldConfigList.containsKey(thisFieldConfig.DeltakSRP__Page__r.Name)) {
                        tempList = pageConfigToFieldConfigList.get(thisFieldConfig.DeltakSRP__Page__r.Name);
                        tempList2.add(thisFieldConfig.id);
                        //field_ids.add(thisFieldConfig.id);
                    }
                    tempList.add(thisFieldConfig);
                    tempList2.add(thisFieldConfig.id);
                    pageConfigToFieldConfigList.put(thisFieldConfig.DeltakSRP__Page__r.Name, tempList);
                    pagenameTofieldid.put(thisFieldConfig.DeltakSRP__Page__r.Name, tempList2);
                    system.debug('pageConfigToFieldConfigList--->>>' + pageConfigToFieldConfigList);
                }

                List<String> pgconfigNames = tupleNametoPageconfigName.values();

                System.debug('pAGECONFIGNAMES' + pgconfigNames);
                Set<String> pgconfSet = tupleMap.keyset();
                List<String> pgconfSetList = new List<String>();
                pgconfSetList.addAll(pgconfSet);
                System.debug('TOUPLEIDS' + pgconfSetList);
                integer g = 0;
                Set<id> isthere = new Set<id>();

                for (Integer i = 0; i < pgconfSetList.size(); i++) {
                    System.debug('IDBYID' + pgconfSetList[i]);
                    List<DeltakSRP__Program_Field_Config__c> fieldConfigList = new List<DeltakSRP__Program_Field_Config__c>();
                    List<id> separatefieldids = new List<id>();
                    List<id> takeoutids = new List<id>();
                    //if(pageConfigToFieldConfigList != null && pageConfigToFieldConfigList.containsKey(pgconfigNames[i]))
                    if (pagenameTofieldid != null && pagenameTofieldid.containsKey(pgconfigNames[i])) {
                        fieldConfigList = pageConfigToFieldConfigList.get(pgconfigNames[i]);
                        System.debug('Separate List:' + fieldConfigList);

                    }
                    for (integer u = 0; u < fieldConfigList.size(); u++) {
                        takeoutids.add(fieldConfigList[u].id);
                    }
                    System.debug('Take out ids' + takeoutids);

                    Map<String, String> shortDescriptionMap = new Map<String, String>();
                    Map<String, String> longDescriptionMap = new Map<String, String>();

                    Map<String, String> m = new Map<String, String>();
                    List<String> lblFld = new List<String>();
                    for (Integer j = 0; j < fieldConfigList.size(); j++) {
                        String fData = '';
                        String fLabel = '';

                        String description = '';
                        String longDesc = '';
                        system.debug('fieldConfigList[j].DeltakSRP__Page__r.Name' + fieldConfigList[j].DeltakSRP__Page__r.Name);
                        if (pgconfigNames[i] == fieldConfigList[j].DeltakSRP__Page__r.Name) {
                            if (fieldConfigList[j].Name != null) {
                                fLabel = (fieldConfigList[j].Name);
                            } else
                                    fLabel = '';

                            System.debug('MAP field to API' + fieldLblAPIName);
                            if (fieldLblAPIName.get(takeoutids[j]) != NULL) {
                                System.debug('FOUND API NAME');
                                String apiName = fieldLblAPIName.get(takeoutids[j]);
                                String daata = '';

                                system.debug('fieldDisplayType.get(apiName)-->>' + fieldDisplayType.get(apiName));

                                //added 8june Girija for date format
                                if (fieldDisplayType.get(apiName) == Schema.displayType.Date) {
                                    system.debug('in if of fieldDisplayType.get(apiName)');
                                    if ((tupleMap.get(pgconfSetList[i])).get(apiName) != null) {
                                        system.debug('in date format -->>' + apiName);
                                        system.debug('in date format -->>' + apiName);
                                        Date d = Date.valueOf((tupleMap.get(pgconfSetList[i])).get(apiName));
                                        daata = d.format();
                                        system.debug('in date format -->>' + daata);
                                    } else {
                                        daata = null;

                                    }
                                } else {
                                    daata = (tupleMap.get(pgconfSetList[i])).get(apiName);
                                }

                                //end 8june Girija

                                if (daata != null) {

                                    system.debug('APINameToData.get(apiName)' + (tupleMap.get(pgconfSetList[i])).get(apiName));
                                    // commented 8june       fData = (tupleMap.get(pgconfSetList[i])).get(apiName);
                                    fData = daata;
                                    System.debug('FDATAAA' + fdata);
                                } else
                                        fData = '';
                            } else {
                                fData = '';
                            }

                            m.put(fLabel, fData);
                            System.debug('check' + displayDataList);
                            system.debug('mapm--->>>' + m);
                            lblFld.add(fLabel);

                            description = fieldConfigList[j].DeltakSRP__Description__c;
                            if (description == null)
                                description = '';
                            system.debug('description' + description);
                            longDesc = fieldConfigList[j].DeltakSRP__Long_Description__c;
                            if (longDesc == null)
                                longDesc = '';
                            system.debug('longDesc' + longDesc);
                            system.debug('FLABEL' + fLabel);
                            shortDescriptionMap.put(fLabel, description);
                            system.debug('Short descriptionMap' + shortDescriptionMap);


                            longDescriptionMap.put(fLabel, longDesc);
                            system.debug('Long descriptionMap' + longDescriptionMap);

                        }
                    }
                    dispOrderedDataList.put(pgconfSetList[i], lblFld);
                    displayDataList.put(pgconfSetList[i], m);
                    System.debug('FINALTUPLES' + displayDataList);
                    System.debug('UNIQUETOUPLEID' + pgconfSetList[i]);


                    displayShortDataList.put(pgconfSetList[i], shortDescriptionMap);
                    system.debug('displayShortData' + displayShortData);

                    displayLongDataList.put(pgconfSetList[i], longDescriptionMap);
                    system.debug('displayLongData' + displayLongData);

                }
                for (integer t = 0; t < 4; t++) {
                    System.debug('Different Touples' + displayDataList);
                }

            }

        } else {
            distpageConfigNameList.clear();
        }

        return null;
    }


    public PageReference pgmConfigsForReferences() {
        system.debug('in method pgmConfigsForReferences');
        List<DeltakSRP__Student_Online_Application__c> onlineAppConfig = [
                SELECT DeltakSRP__Online_Application_Config__c
                FROM DeltakSRP__Student_Online_Application__c d
                WHERE DeltakSRP__Student_Online_Application__c.Id = :onlineAppId.id
        ];

// onlineConfigID stores current Online Application Config ID
        List<ID> onlineConfigID = new List<ID>();
        for (DeltakSRP__Student_Online_Application__c ids : onlineAppConfig) {
            onlineConfigID.add(ids.DeltakSRP__Online_Application_Config__c);
        }

        List<DeltakSRP__Program_Page_Config__c> pageConfigName = [
                SELECT d.Name
                FROM DeltakSRP__Program_Page_Config__c d
                WHERE d.DeltakSRP__Online_Application_Config__c IN :onlineConfigID
                AND d.DeltakSRP__Type__c = 'References'
        ];


        system.debug('pageConfigNameRef' + pageConfigName);

        if (pageConfigName != null && pageConfigName.size() > 0) {

            List<DeltakSRP__Student_Letter_of_Reference_Selection__c> refIds = [
                    SELECT DeltakSRP__Student_Letter_of_Reference__c
                    From DeltakSRP__Student_Letter_of_Reference_Selection__c
                    Where DeltakSRP__Student_Online_Application__c = :onlineAppId.id
            ];

            List<ID> refIdList = new List<ID>();
            for (DeltakSRP__Student_Letter_of_Reference_Selection__c ids : refids) {
                refIdList.add(ids.DeltakSRP__Student_Letter_of_Reference__c);
            }

            List<DeltakSRP__Student_Letter_of_Reference__c> letterOfRef = new List<DeltakSRP__Student_Letter_of_Reference__c>();

            letterOfRef = [
                    Select d.DeltakSRP__Reference_Name__c, d.DeltakSRP__Reference_Email__c,d.Name
                    From DeltakSRP__Student_Letter_of_Reference__c d
                    where id in :refIdList
            ];

            for (DeltakSRP__Student_Letter_of_Reference__c lor : letterOfRef) {
                refNameToRefEmail.put(lor.Name, lor.DeltakSRP__Reference_Email__c);
                refNames.add(lor.Name);
            }

        }

        return null;

    }

    public List<DeltakSRP__Program_Online_Application_Config__c> printSubmissionText() {
        List<DeltakSRP__Student_Online_Application__c> onlineAppConfig = [
                SELECT DeltakSRP__Online_Application_Config__c
                FROM DeltakSRP__Student_Online_Application__c d
                WHERE DeltakSRP__Student_Online_Application__c.Id = :onlineAppId.id
        ];

// onlineConfigID stores current Online Application Config ID
        List<ID> onlineConfigID = new List<ID>();
        for (DeltakSRP__Student_Online_Application__c ids : onlineAppConfig) {
            onlineConfigID.add(ids.DeltakSRP__Online_Application_Config__c);
        }

        submissionText = [Select d.DeltakSRP__Submission_Text__c From DeltakSRP__Program_Online_Application_Config__c d where id IN :onlineConfigID];
        system.debug('submissionText' + submissionText);
        return submissionText;
    }

    public string AttachDeltakSRP(String fieldName) {
        if (listFlag == false) {
            SObject obj = Schema.DeltakSRP__Student_Online_Application_Tuple__c.getSoBjectType().newSObject();
            try {
                obj.get(fieldName);
            } catch (Exception exc) {
                fieldName = 'DeltakSRP__' + fieldName;
            }

            return fieldName;
        }
        if (listFlag == true) {
            SObject obj = Schema.DeltakSRP__Student_Online_Application__c.getSoBjectType().newSObject();
            try {
                obj.get(fieldName);
            } catch (Exception exc) {
                fieldName = 'DeltakSRP__' + fieldName;
            }

            return fieldName;
        }
        return null;
    }

}