public with sharing class FindAllObjects {
	public List<String> standardObjectNames {get; set; }
	public List<String> customObjectNames {get; set; }
	public List<String> historyObjectNames {get; set; }
	public List<String> shareObjectNames {get; set; }
	public Integer standardObjectCount {get; set; }
	public Integer customObjectCount {get; set; }
	public Integer shareObjectCount {get; set; }
	public Integer historyObjectCount {get; set; }
	public Integer allObjectCount {get; set; }
	public List<String> objectNames = new List<String>();
	
	
	public String pdf {get; set; }
	public FindAllObjects(){
		
		pdf = '';
		standardObjectNames = new List<String>();
		customObjectNames = new List<String>();
		historyObjectNames = new List<String>();
		shareObjectNames = New List<String>();
		getAllObjects();
		standardObjectNames.sort();
		customObjectNames.sort();
		historyObjectNames.sort();
		shareObjectNames.sort();
		objectNames.sort();
		standardObjectCount = standardObjectNames.size();
		customObjectCount = customObjectNames.size();
		shareObjectCount = shareObjectNames.size();
		historyObjectCount = historyObjectNames.size();
		allObjectCount = objectNames.size();
	}
	public List<String> getAllObjects(){
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		List<selectOption> options=new List<selectOption>();
        List<String> objectLabels=new List<String>();
		
        //Need to filter this list more for relevence
        for (String objectName:gd.keyset()){
        //	Schema.SObjectType otype = gd.get(objectName);
        //	if(otype.getDescribe().isAccessible() && otype.getDescribe().getSObjectType()){
        	objectNames.add(objectName);
        	if(objectName.contains('history')){
        		historyObjectNames.add(objectName);
        	}else if(objectName.contains('__c')){
        		customObjectNames.add(objectName);
        	}else if(objectName.contains('share')){
        		shareObjectNames.add(objectName);
        	}else{
        		standardObjectNames.add(objectName);
        	}
        
   //     	}
        }
        return objectNames;
   
	}
	
	
	public void downloadPDF(){
		pdf = 'pdf';
	}
}