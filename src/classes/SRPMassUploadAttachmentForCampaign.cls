global without sharing class SRPMassUploadAttachmentForCampaign {
    WebService static String parseAttachmentSheet(String uploadCampaignId){
        System.debug(uploadCampaignId);
        String message = '';
        List<Campain_Leads_Upload__c> campaignLeads = [Select Mass_Upload_Status__c, Upload_Complete__c from Campain_Leads_Upload__c where Id = :uploadCampaignId.trim()];
        if(campaignLeads[0].Mass_Upload_Status__c == 'In Progress' || campaignLeads[0].Mass_Upload_Status__c == 'Complete'){
            message+= 'The upload is already complete or in Progress. To upload again, delete the attachment and re-attach the file';
        }else{
            List<Attachment> attachmentList = [Select a.ParentId, 
                                                      a.LastModifiedDate, 
                                                      a.Body From Attachment a
                                                      where a.ParentId = :uploadCampaignId.trim()
                                                      order by a.LastModifiedDate desc limit 1
                                                ];
            
            
            Map<Lead, String> leadownermap = new Map<Lead, String>();
            
            List<String[]> inputFeed = new List<String[]>();
            Set<String> campignCodes = getAvailableCampaignCodes();
            Set<String> errorValues = new Set<String>();
            
            if(attachmentList == null || attachmentList.size() == 0){
                message+= 'No Attachments found';
            }else{
                Attachment toUseAttachment = attachmentList[0];
                Blob body = toUseAttachment.Body;
                system.debug('body.toString()>>>>'+body.toString());
                CSVReader reader = new CSVReader((body.toString()));
                system.debug('body.toString()>>>>'+body.toString());
                String[] line1 = null;
                Integer lineNumber = 0;
                Boolean error = false;
                while( (line1 = reader.readLine()) != null){
                    system.debug('inside while loop>>>>'+line1);
                    if(lineNumber == 0){
                        lineNumber++;
                        continue;
                    }
                    
                    String campaignCode = line1[3];
                    String homephone = line1[17];
                    string workphone = line1[18];
                    system.debug('campaignCode>>>>'+campaignCode);
                    
                    if(!campignCodes.contains(campaignCode)){
                        if(!errorValues.contains(campaignCode) || errorValues.size() == 0)
                            message+='Campaign Code ['+campaignCode+'] is not found in Deltak \n';
                        error = true;
                        errorValues.add(campaignCode);
                    }
                    
               /*     if(homephone!=null && homephone.length()>0 &&  !homephone.startswith('+')){
                        error = true;
                        message+= 'Home Phone number ['+homephone +'] should start with +.\n'; 
                    }else{
                        if(homephone!=null && unformattedphone(homephone)!=null && unformattedphone(homephone).length()>0){
                            if(unformattedphone(homephone).startswith('0')){
                                error = true;
                                message+= 'Home Phone number ['+homephone +'] should not start with 0.\n';  
                            }else{  
                                if(homephone!=null && homephone.length()>0){
                                    if(unformattedphone(homephone).length()<10){
                                        error = true;
                                        message+= 'Home Phone number ['+homephone +'] should have atleast 10 digits.\n'; 
                                    }
                                        
                                }
                           }   
                        }    
                    }
                    
                    if(workphone!=null && workphone.length()>0 && !workphone.startswith('+')){
                        error = true;
                        message+= 'Work Phone number ['+workphone +'] should start with +.\n'; 
                    }else{
                        if(workphone!=null && unformattedphone(workphone)!=null && unformattedphone(workphone).length()>0){
                            if(unformattedphone(workphone).startswith('0')){
                                error = true;
                                message+= 'Work Phone number ['+workphone +'] should not start with 0.\n';  
                            }else{ 
                                if(workphone!=null && workphone.length()>0){
                                    if(unformattedphone(workphone).length()<10){
                                        error = true;
                                        message+= 'Work Phone number ['+workphone +'] should have atleast 10 digits.\n'; 
                                    }
                                        
                                }
                           }   
                        }    
                    }  
                    */
                    
                    if(!error)
                        inputFeed.add(line1);
                    
                }
                System.Debug('inputfeed>>>>'+inputFeed);
                 if(!error){
                     /*Set<Id> userIds = new set<Id>();
                     for(String[] line : inputFeed){
                        
                        if(line.size()>21 && line[21] != null && line[21]!='' && line[21].length()>=15){
                            system.debug('line[21]>>>>'+line[21]);
                            userIds.add(line[21].trim());
                        }else{
                            userids.add(userinfo.getuserid());
                        }   
                     }
                    
                     system.debug('userids>>>>'+userids);
                     List<User> owners = new List<User>();
                     owners = [Select Id from User where Id in:userids];
                     system.debug('owners>>>>'+owners);*/
                     
                     List<SRP_Mass_Upload_Data__c> datalist = new List<SRP_Mass_Upload_Data__c>();
                     for(String[] line : inputFeed){
                        SRP_Mass_Upload_Data__c data = new SRP_MAss_Upload_Data__c();
                        data.Mass_Lead_Upload__c = attachmentList[0].parentid;
                        data.Is_SRP_record__c = line[0];
                        data.RFI_Campaign_Code__c = line[3];
                        data.source__c = line[4];
                        data.lead_Source__c = 'Mass Upload Lead';
                        data.accountid__c = line[6];
                        data.last_name__c = line[8];
                        data.first_name__c = line[7];
                        data.title__c = line[9];
                        data.company__c = line[10];
                        data.street__c = line[11] + ' ' + line[12];
                        data.city__c = line[13];
                        data.state__c = line[14];
                        data.country__c = line[15];
                        data.postal_code__c = line[16];
                        data.home_phone__c = line[17];
                        data.work_phone__c = line[18];
                        data.email__c = line[19];
                        data.academic_program__c = line[20];
                        data.ownerid__c = line[21];
                        data.inquiry_rating__c = line[2];
                        datalist.add(data);
                     }
                   
                   // Girija: added onBeforeInsert for SRP:1292  
                     SRPMassUploadHandler.onBeforeInsert(datalist);
                     insert datalist;
                     
                     message = message + 'Data Upload is in progress. You will be notified by email once it is complete.';
                     
                     campaignLeads[0].Mass_Upload_Status__c = 'In Progress';
                     campaignLeads[0].SRP_Running_User__c = userinfo.getuserid();
                     update campaignLeads[0];
                    
                     SRPMassUploadDataBatch uploadData = new SRPMassUploadDataBatch (campaignLeads[0]);
                     Id Batchid = Database.executeBatch(uploaddata,100);
                     
                }else{
                    message += 'Please correct the above errors.';
                }
            }
        }
        
        
        
        return message;
        
    }
    
    public static String unformattedPhone(String pnumber){
        if(pnumber == null)
            return null;
        String phonenumber = pnumber;
        phonenumber = phonenumber.replace('-','');
        phonenumber = phonenumber.replace('.','');
        phonenumber=phonenumber.replace(')','');
        phonenumber=phonenumber.replace('(','');
        phonenumber=phonenumber.replace(' ','');
        phonenumber=phonenumber.replace('x','');
        phonenumber=phonenumber.replace('+','');
        phonenumber.trim();
        
        system.debug('phonenumber.size()>>>>'+ phonenumber + '>>>>'+ phonenumber.length());
        
        return phonenumber; 
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
        system.debug('camplist>>>>'+camplist);
        return returnSet;
                                                
    }
}