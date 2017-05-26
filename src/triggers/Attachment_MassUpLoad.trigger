trigger Attachment_MassUpLoad on Attachment (before delete, before insert) {
	
	String currentProfileId = userinfo.getProfileId();
	currentProfileId = currentProfileId.substring(0, 15);
	List<SRP_Profiles_List__c> SRPProfilesList = new List<SRP_Profiles_List__c>();
	Set<String> srpProfiles = new Set<String>();
	SRPProfilesList = SRP_Profiles_List__c.getall().values();
	for(SRP_Profiles_List__c spl: SRPProfilesList){
		srpProfiles.add(spl.ProfileId__c);
	}
	if(srpProfiles.contains(currentProfileId))
		return;
	
	User loggedInUser = [SELECT LastName, Profile.Name FROM User WHERE Id = :userinfo.getuserid() LIMIT 1];
	   if (!(loggedInUser.Profile.Name.contains('Integration'))) {
	   		
	   		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Map<String,String> keyPrefixMap = new Map<String,String>{};
		Set<String> keyPrefixSet = gd.keySet();
		for(String sObj : keyPrefixSet){
		   Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
		   String tempName = r.getName();
		   String tempPrefix = r.getKeyPrefix();
		   System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
		   keyPrefixMap.put(tempPrefix,tempName);
		}
	   		
	   		
	   		
	   		
	   		Set<Id> ids = new Set<Id>();
	   		Set<Id> campaignId = new Set<Id>();
	   		Map<Id, Integer> campaignToAttachmentCount = new Map<Id, Integer>();
	   		Map<Id, Id> attachmentToCampaign = new Map<Id, Id>();
	   		if(Trigger.isInsert){
		   		for(Attachment attach : Trigger.new){
		   			ids.add(attach.id);
		   			campaignId.add(attach.ParentId);
		   		}
	   		}else if(Trigger.isDelete){
	   			for(Attachment attach : Trigger.old){
		   			ids.add(attach.id);
		   			campaignId.add(attach.ParentId);
		   		}
	   		}
	   		List<Attachment> attachmentList = [Select a.id, a.ParentId
	                                                  From Attachment a
	                                                  where a.ParentId IN :campaignId
	                             				 ];
	            if(attachmentList != null && attachmentList.size() > 0){
	            	for(Attachment thisAttachment : attachmentList){
	            		attachmentToCampaign.put(thisAttachment.Id, thisAttachment.ParentId);
	            		if(campaignToAttachmentCount.containsKey(thisAttachment.ParentId)){
	            			Integer thisCounter = campaignToAttachmentCount.get(thisAttachment.ParentId);
	            			thisCounter++;
	            			campaignToAttachmentCount.put(thisAttachment.ParentId, thisCounter);
	            		}else{
	            			campaignToAttachmentCount.put(thisAttachment.ParentId, 1);
	            		}
	            	}
	            }
	   		if(Trigger.isInsert){
	   			for(integer i = 0;i<trigger.size ; i++){
	   				String tPrefix = trigger.new[i].ParentId;
	        	tPrefix = tPrefix.subString(0,3);
	           		if(keyPrefixMap.get(tPrefix) == 'Campain_Leads_Upload__c' && campaignToAttachmentCount.get(trigger.new[i].ParentId) == 1){
	           			trigger.new[i].addError('The Upload record already contains an attachment. Only one attachment record is allowed per upload.');
	           		}
	           }
	             
	   		}
	   		List<Campain_Leads_Upload__c> uploads = new List<Campain_Leads_Upload__c>();
	   		if(Trigger.isDelete){
	   			for(Attachment aa : Trigger.old){
	   				String tPrefix = aa.parentId;
	        	tPrefix = tPrefix.subString(0,3);
	   				if(keyPrefixMap.get(tPrefix) == 'Campain_Leads_Upload__c' && campaignToAttachmentCount.get(aa.parentId) == 1){
	   					Campain_Leads_Upload__c upload = new Campain_Leads_Upload__c(Id = aa.ParentId);
	   					upload.Upload_Complete__c = false;
	   					uploads.add(upload);
	   					
	   					
	   				}
	   			}
	   			if(uploads != null && uploads.size() > 0){
	   				update uploads;
	   			}
	   			
	   			
	   		}
	   }
}