global class UploadAttachmentForCampaigns {
     
     WebService static String parseAttachmentSheet(String uploadCampaignId){
        System.debug(uploadCampaignId);
        String message = '';
        List<Campain_Leads_Upload__c> campaignLeads = [Select Upload_Complete__c from Campain_Leads_Upload__c where Id = :uploadCampaignId.trim()];
        if(campaignLeads[0].Upload_Complete__c){
            message+= 'The upload is already complete. To upload again, delete the attachment and re-attach the file';
        }else{
            List <string> emailAddressList = NewInquiryUtil.getEmalAddresses();
            List<Attachment> attachmentList = [Select a.ParentId, 
                                                      a.LastModifiedDate, 
                                                      a.Body From Attachment a
                                                      where a.ParentId = :uploadCampaignId.trim()
                                                      order by a.LastModifiedDate desc limit 1
                                                ];
            List<Lead_Failure__c> lead_fail_List = new List<Lead_Failure__c>();
            List<String[]> inputFeed = new List<String[]>();
            Set<String> key5s = getAvailableKey5List();
            Set<String> campignCodes = getAvailableCampaignCodes();
            Set<String> errorValues = new Set<String>();
            
            if(attachmentList == null || attachmentList.size() == 0){
                message+= 'No Attachments found';
            }else{
                Attachment toUseAttachment = attachmentList[0];
                Blob body = toUseAttachment.Body;
                CSVReader reader = new CSVReader((body.toString()));
                String[] line1 = null;
                Integer lineNumber = 0;
                Boolean error = false;
                while( (line1 = reader.readLine()) != null){
                    if(lineNumber == 0){
                        lineNumber++;
                        continue;
                    }
                    String thisKey5 = line1[17];
                    String campaignCode = line1[0];
                    if(!key5s.contains(thisKey5)){
                        if(!errorValues.contains(thisKey5) || errorValues.size() == 0)
                            message+='Key5 ['+thisKey5+'] is not found in Deltak \n';
                        error = true;
                        errorValues.add(thisKey5);
                    }
                    if(!campignCodes.contains(campaignCode)){
                        if(!errorValues.contains(campaignCode) || errorValues.size() == 0)
                            message+='Campaign Code ['+campaignCode+'] is not found in Deltak \n';
                        error = true;
                        errorValues.add(campaignCode);
                    }
                    if(!error)
                        inputFeed.add(line1);
                    
                }
                System.Debug(inputFeed);
                 if(!error){
                     for(String[] line : inputFeed){
                        
                        Lead_Failure__c lead_fail = new Lead_Failure__c();
                        
                        
                        lead_fail.MassCampaignUpload__c = true;
                        lead_fail.ContactName__c = line[5]+' '+line[4];
                        //lead_fail.Key2__c = line[1];
                        lead_fail.Key5__c = line[17];
                        lead_fail.UADCampgn__c = line[0];
                        //lead_fail.phone3__c = line[9];
                        lead_fail.Address1__c= line[8];
                        lead_fail.City__c= line[10];
                        lead_fail.State__c= line[11];
                        lead_fail.Zip__c= line[13];
                        lead_fail.Phone1__c= line[15];
                        lead_fail.Phone2__c= line[14];
                        lead_fail.Email__c= line[16];
                        //lead_fail.Gender__c=line[11];
                        lead_fail.CourseInterest__c=line[18]; 
                        lead_fail.Duplicate_Opportunity__c = false;
                        lead_fail.Campain_Lead_Upload__c = uploadCampaignId.trim();
                        lead_fail.leadDate__c = line[2];
                        lead_fail.LeadTime__c = line[3];
                        //lead_fail.Source__c = line[26];
                        lead_fail.Title__c  =line[6];     
                        lead_fail.Company__c = line[7];  
                        String rating =  ( line[19] != null && line[19] != '' )? ((line[19].trim()).substring(0,3).toLowerCase()):'hig';  
                        System.Debug('Rating -- ' +rating);     
                        lead_fail.OwnerId__c = rating+line[20];
                        lead_fail_List.add(lead_fail);
                        
                        lineNumber++;
                    }
                    try{
                        insert lead_fail_List;
                        System.Debug(lead_fail_List);
                        Campain_Leads_Upload__c upload = new Campain_Leads_Upload__c(Id = uploadCampaignId.trim());
                        upload.Upload_Complete__c = true;
                        update upload;
                        message += 'File successfully uploaded';
                    }catch(Exception e){
                        System.Debug(e);
                        message+= 'Error Occurred - '+e;
                    }
                }else{
                    message += 'Please correct the above errors.';
                }
            }
            }
        return message;
        
    }
    private static Set<String> getAvailableKey5List(){
        Set<String> returnSet = new Set<String>();
        List<Account> accountList = [Select Goldmine_Key5__c from Account];
        if(accountList != null && accountList.size() > 0){
            for(Account a : accountList){
                returnSet.add(a.Goldmine_Key5__c);
            }
        }
        return returnSet;
    }
    private static Set<String> getAvailableCampaignCodes(){
        
          Set<String> returnSet = new Set<String>();
         List<Campaign> campList = [Select id, Campaign_Code__c, IsActive
                                                from Campaign 
                                                where (Lowest_Level_in_Hierarchy__c = true
                                                AND StartDate < today 
                                                AND EndDate >= today
                                                And IsActive = true) 
                                                ];
        if(campList != null && campList.size() > 0){
            for(Campaign a : campList){
                returnSet.add(a.Campaign_Code__c);
            }
        }
        return returnSet;
                                                
    }
}