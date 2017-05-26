public with sharing class SRMUserContactHandler {
    public static final String DELTAK_STAFF_RT = 'Deltak_Staff';
    public static final String Deltak_Innovation = 'Deltak Innovation';
    
    @future
    public static void createNewStaffContact(List<Id> uid){
        List<Contact> contactList = new List <Contact>();
        List<Person__c> personList = new List<Person__c>();
        List<Contact> contactNameList = new List<Contact>();
        List<User> userList =[SELECT id,FirstName,LastName,Email FROM User WHERE id in :uid];
        List<Account> acctlist = new list <Account> ([SELECT Id from Account WHERE Name=:Deltak_Innovation]);     
        List<RecordType> rtList = new List <RecordType>([SELECT Id FROM RecordType 
                                                                WHERE SObjectType='Contact' AND 
                                                                      DeveloperName= :DELTAK_STAFF_RT]);
        Set<String> contactNameSet = new Set<String>();
        Set<String> newContactFullName = new Set<String>(); 
        
                                                                  
        for(User usacct : userList){
        	newContactFullName.add(usacct.FirstName+' '+usacct.LastName);
        }
        contactNameList = [Select id,Name from Contact where Name in:newContactFullName];
        for(Contact c:contactNameList) {
        	contactNameSet.add(c.Name);
        }
        
        for(User usacct:userlist){
        	if(contactNameSet.contains(usacct.FirstName+' '+usacct.LastName)){
            	// DO NOTHING 
        	}else{
	        	if(acctlist != null && acctList.size() > 0 && rtList != null && rtList.size() > 0){
		        	Contact c = new Contact(FirstName = usacct.FirstName, LastName = usacct.LastName,
		                            //TODO SET THE ORGANIZATION ID
		                            Accountid =acctlist[0].id,
		                            Employee_Status__c='Active',Email = usacct.Email,
		                            RecordTypeid = rtList[0].id);
		            System.Debug('contact created -->' +c);                        
		            contactList.add(c);
		            /*Person__c pt = new Person__c(First_name__c = usacct.FirstName, Last_name__c = usacct.LastName);
		            System.Debug('person account created -->' +pt);
		            personList.add(pt);*/
		        	
	        	}
        	}
        }
        try{
        	if(contactList != null && contactList.size() > 0){
        		insert contactList;
        	}
        }
        catch (System.DmlException e) {
        	System.debug('The following exception has occurred: ' + e.getMessage());
        } 
        //insert personList;
    }
}