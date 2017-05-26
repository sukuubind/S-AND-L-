public class runleadbatch {

    public Boolean Showlabel {get; set;} 
    public String backlink {get;set;}
    
    public runleadbatch(ApexPages.Standardcontroller controller){
    	showlabel = false;
    }
    
	public Pagereference runBatch(){ 
		leadupdation batch = new leadupdation();
		database.executeBatch(batch);
		showlabel = true;
		backlink= Label.IPEDS_Lead_Batch_Back_Link;
		return null;
	}
	
}