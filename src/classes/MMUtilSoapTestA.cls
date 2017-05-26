@IsTest
public class MMUtilSoapTestA {
   public static testMethod void Test() {
      Test.startTest();
      
      Contact c1 = createAffiliation('Test','Affiliation1');
      Contact c2 = createAffiliation('Test','Affiliation2');
      Contact c3 = createAffiliation('Test','Affiliation3');            
      List<MMUtilSMSObject> objList = new List<MMUtilSMSObject>();
      objList.add(new MMUtilSMSObject(c1.Id,'443453031718',2,true,'United States','Test SMS 1'));
      objList.add(new MMUtilSMSObject(c2.Id,'443453031719',2,true,'United States','Test SMS 2'));
      objList.add(new MMUtilSMSObject(c3.Id,'443453031720',2,true,'United States','Test SMS 3'));
      
      MMUtilSoap.sendSMS(objList, 'Test SMS');
     
      Test.stopTest();       
   }
   public static Contact createAffiliation(string fname, string lname) {
       Contact c = new Contact(FirstName = fname, LastName = lname);
       insert c;
       return c;
   }
}