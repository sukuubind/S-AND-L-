@isTest
public with sharing class testleadbatch {
static testmethod void test(){
    
    RecordType rt = [Select Id from RecordType where name='Business Development'];
    
    lead[] l1 = new list<lead>();
    for(integer i=0;i<5;i++)
    {
        lead l2 = new lead(company='Adams State University2',lastname='Burritt');
        l2.RecordTypeId = rt.id;
        l1.add(l2);
    }
    insert l1;
    
    
    ipeds__c[] i1 = new list<ipeds__c>();
   
        ipeds__c i2 = new ipeds__c(website_address__c='www.adams.edu',institution_name__c = 'Adams State University2');
        i1.add(i2);
  
    insert i1;
    
    test.starttest();
    leadupdation c = new leadupdation();
    database.executebatch(c);
    test.stoptest();
    
    list<lead> dplead = [select website_address__c from lead where company='Adams State University2'];
    if(dplead != null && dplead.size() > 0){
            System.assertEquals(5, dplead.size()); 
            for(lead l : dplead)
               System.assertEquals(l.website_address__c,'www.adams.edu' );      
        }
        
       
    
}
}