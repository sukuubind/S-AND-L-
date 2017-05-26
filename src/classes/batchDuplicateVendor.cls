/*
 * Author: Chris Baker
 * 
 * Description:
 * For the Duplicate Vendor reports
 * The requirement is to identify which Opportunities are considered duplicates based on the email address of the related student (Affiliation).  Within a group of Opportunities with the same email, the first Opportunity to be created will be considered the ‘original’, and each subsequently created Opportunity will be considered a ‘duplicate’.  For each duplicate, we need be able to show the Campaign and the CreatedDate of the original Opportunity.
 * 
 * 
 * Created Date: 10/27/2010
 * Chris Baker - 11/30/2010 - Added a check to have the code not count duplicates if they belong to different schools
 *
 * 
 */

global class batchDuplicateVendor implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    global integer dupCounter = 0;
    global string email = null, originalCampaignName = null;    
    global Id originalOpportunity = null, school = null;
    global Datetime originalOpportunityCreatedDate = null;
    
    private List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
    global batchDuplicateVendor(String q, String e, String f, String v){        
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('Beginning of new batch...');
        
        for(integer i=0; i<scope.size(); i++){
             //Only process it if it's an Opportunity record
             if(scope[i].getsObjectType() == Opportunity.sObjectType) {
                Opportunity o = (Opportunity) scope[i];
                
                //If the email is null or the current opportunity's email does not match 
                //the previously saved email, then this is a unique opportunity
                //Otherwise, we mark this as a duplicate
                if (school != null && email != null && o.AccountId == school && o.LP_Email__c == email) {
                    System.debug('Duplicate email found: ' + email);
                    
                    dupCounter++;
                    System.debug('dupCounter is now: ' + dupCounter);
                    o.Duplicate_Number__c = dupCounter;
                    
                    System.debug('Original_Opportunity__c : ' + originalOpportunity);
                    
                    //Make sure this record is not trying to point to itself
                    if (originalOpportunity != o.Id) {
                        o.Original_Opportunity__c = originalOpportunity;
                        System.debug('Original_Opportunity__c set to ' + originalOpportunity);
                    }
                    
                    else {
                        o.Original_Opportunity__c = null;
                        System.debug('Error: This opportunity\'s Original_Opportunity__c was about to point to itself. Set to NULL instead. Opportunity --> ' + o); 
                    }               
                    
                    System.debug('Original_Campaign__c : ' + originalCampaignName);
                    o.Original_Campaign__c = originalCampaignName;
                    
                    System.debug('Original_Created_Date__c : ' + originalOpportunityCreatedDate);
                    o.Original_Created_Date__c = originalOpportunityCreatedDate;
                    
                    System.debug('Add this opportunity to the list to update: ' + o);
                    oppsToUpdate.add(o);
                }
                
                //No match found. This Opportunity is not a duplicate               
                else {                      
                    System.debug('No email match found: ' + o.LP_Email__c);
                    //Save the school                   
                    school = o.AccountId;
                    //Save the email
                    email = o.LP_Email__c;  
                    //set the dup counter to 0                  
                    dupCounter = 0;
                    //save this opportuity's ID
                    originalOpportunity = o.Id;
                    System.debug('originalOpportunity = ' + originalOpportunity);                   
                    //save the create date of this Opp
                    originalOpportunityCreatedDate = o.CreatedDate;
                    //save this campaign name                   
                    originalCampaignName = o.Campaign.Name;
                    //set the opportunity's dup number to 0 on the record
                    o.Duplicate_Number__c = 0;
                    //NULL the Opportunity's oOriginal_Opportunity__c, Original_Created_Date__c, & Original_Campaign__c
                    o.Original_Opportunity__c  = null;
                    o.Original_Created_Date__c = null;
                    o.Original_Campaign__c     = NULL;
                    
                    System.debug('Add this opportunity to the list to update: ' + o);
                    oppsToUpdate.add(o);
                }
            }
        }
        
        System.debug('Update the opportunities for this batch...');
        
        try {
            update oppsToUpdate;
        }
        
        catch(Exception e){
            System.Debug('Error' + e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    
    static testMethod void testBatchDuplicateVendor() {
        
        DateTime t=System.now();
        date d = Date.newInstance(t.year(),t.month(),t.day());
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;
        
        Account a2 = new Account();
        a2.Name = 'Test Account 2';
        insert a2;
        
        //Get the Student Record Type
        RecordType [] rt = [Select Id FROM RecordType WHERE Name = 'Student Opportunity'];
        Id studentRT = null;
        if (rt.size()>0) {
            studentRT = rt[0].Id;
        }
        else {
            System.debug('Student Opportunity recordtype not found');
        }
        
        List <Opportunity> opps = new List<Opportunity>();
        
        Opportunity o = new Opportunity();
        o.CloseDate=d;
        o.StageName='New Inquiry';
        o.Name='A';
        o.LP_Email__c = 'test@test.com';        
        if (studentRT != null) {
            o.RecordTypeId = studentRT;
        }
        o.AccountID=a.Id;
        
        Opportunity o2 = new Opportunity();
        o2.CloseDate=d;
        o2.StageName='New Inquiry';
        o2.Name='B';
        o2.LP_Email__c = 'test@test.com';
        if (studentRT != null) {
            o2.RecordTypeId = studentRT;
        }
        o2.AccountID=a.Id;
        
        Opportunity o3 = new Opportunity();
        o3.CloseDate=d;
        o3.StageName='New Inquiry';
        o3.Name='C';
        o3.LP_Email__c = 'test@test.com';
        if (studentRT != null) {
            o3.RecordTypeId = studentRT;
        }
        o3.AccountID=a2.Id;
        
        opps.add(o);
        opps.add(o2);
        opps.add(o3);
        
        insert opps;
        
        string query = 
            'SELECT Duplicate_Number__c, Original_Opportunity__c, Original_Campaign__c, Id, ' + 
            'LP_Email__c, AccountId, Campaign.Name, CreatedDate, Original_Created_Date__c ' +
            'FROM Opportunity ' + 
            'WHERE RecordType.Name = \'Student Opportunity\' ' + 
            'AND Id IN (\'' + opps[0].Id + '\',\'' + opps[1].Id + '\',\'' + opps[2].Id + '\') ' +
            'Order By AccountId, LP_Email__c, CreatedDate ASC';
       
        Test.startTest();  
        
        System.debug('Query ----> ' + query);   
        ID batchId = null;
        
        batchDuplicateVendor updateDuplicateVendor = new batchDuplicateVendor (query, '', '', '');
        batchId = Database.executeBatch(updateDuplicateVendor);
        
        Test.stopTest();
        
        Opportunity [] updatedOpps = [SELECT Duplicate_Number__c, Name
            FROM Opportunity
            WHERE Id IN :opps
            ORDER By Name ASC ];            
        System.debug('updatedOpps --->' + updatedOpps);
        
        System.assertEquals(3, updatedOpps.size());
        System.assertEquals(0, updatedOpps[0].Duplicate_Number__c);
        /*System.assertEquals(1, updatedOpps[1].Duplicate_Number__c); 
        System.assertEquals(0, updatedOpps[2].Duplicate_Number__c);*/
        
        
        
    }
}