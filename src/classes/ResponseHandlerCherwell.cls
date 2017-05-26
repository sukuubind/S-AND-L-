global class ResponseHandlerCherwell {
    
    //List of custom attributes that we want to check the status of the org
    public String Status {get; set;}
    public List<sObject> Data {get;set;}
    public String Message {get;set;}
    public String ErrorCode {get; set;}
    
    //Check if Object is NULL or Blank
    global static boolean isNotNullOrEmpty(string str)
    {
        return str!=null || !String.isBlank(str); 
    }   
}