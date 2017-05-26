public without sharing class SRPReviewPDFReferenceController{

	public String currentAppId {get; set; }
	public Boolean dataExists {get; set;}
	public List<DeltakSRP__Student_Letter_of_Reference__c> slr {get; set; }
	
	 // Constructor
    public SRPReviewPDFReferenceController(ApexPages.StandardController controller)
    {
    	currentAppId = (Id) System.currentPageReference().getParameters().get('id');
 
   		 slr = new  List<DeltakSRP__Student_Letter_of_Reference__c>();
   		 slr = slrList();
    }
    
    // fetch refernce's  skills/strenghts details
    public List<Schema.FieldSetMember> getFields() {

        return SObjectType.DeltakSRP__Student_Letter_of_Reference__c.FieldSets.Student_References_Skills_FieldSet.getFields();

    }
    
    public List<DeltakSRP__Student_Letter_of_Reference__c> slrList(){
    	
    // Select reference IDs from Reference Selection for currentAppIDs
    
    	List<DeltakSRP__Student_Letter_of_Reference_Selection__c> refIds = 
												    	 [SELECT DeltakSRP__Student_Letter_of_Reference__c
												    	  From DeltakSRP__Student_Letter_of_Reference_Selection__c 
												    	  Where DeltakSRP__Student_Online_Application__c = :currentAppId];
     // List of all reference Ids   
        List<ID> refIdList = new List<ID>();  
        for(DeltakSRP__Student_Letter_of_Reference_Selection__c ids : refids)
        {
        	refIdList.add(ids.DeltakSRP__Student_Letter_of_Reference__c);
        }
        
       String queryRef = 'SELECT ';
		for(Schema.FieldSetMember f : this.getFields())
		{
			queryRef +=  f.getFieldPath() + ', ';
		}
		string newQueryRef = queryRef.substring(0,queryRef.length()-2);
		string val = 'Complete';
      
        newQueryRef += ' ,Name,DeltakSRP__Student_Name__c,DeltakSRP__Reference_Name__c,' +
         			   ' DeltakSRP__Reference_Email__c,Reference_Phone__c,Title_Position__c,'+
         			   ' Address__c,City__c,DeltakSRP__How_do_you_know_this_Person__c, '+
          			   ' How_Long__c, Zip__c, State__c, Need_Additional_Information_for_Own__c,'+
          			   ' DeltakSRP__Reference_Text__c,SRP_Academic_Institution__c, Capacity__c, '+
          			   ' Capacity_CJ__c, Need_Additional_Info_for_TeamMembers__c'+
         			   ' FROM DeltakSRP__Student_Letter_of_Reference__c d'; 
        newQueryRef += ' WHERE d.Id IN'; 
        newQueryRef += ' :refIdList';
        newQueryRef += ' AND d.DeltakSRP__Status__c = ';
        newQueryRef += ' :val';
      
    	slr = Database.query(newQueryRef);
        
        if(slr.size() > 0) 
        	dataExists = true;
        
        return slr;
    		            
    }
   
}