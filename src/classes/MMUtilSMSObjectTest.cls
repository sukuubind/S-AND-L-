@IsTest
public class MMUtilSMSObjectTest {
   public static testMethod void Test() {
      Test.startTest();
      MMUtilSMSObject obj = new MMUtilSMSObject();
      obj.setEntityId('E001');
      obj.setSelectedPhone('443453031719');
      obj.setReceiptNumber(1);
      obj.setIsTrack(true);
      obj.setCountry('United Kingdom');
      obj.setMessage('Test SMS');
      
      System.assertEquals('E001',obj.getEntityId());
      System.assertEquals('443453031719',obj.getSelectedPhone());
      System.assertEquals(1,obj.getReceiptNumber());
      System.assertEquals(true,obj.getIsTrack());
      System.assertEquals('United Kingdom',obj.getCountry());                        
      System.assertEquals('Test SMS',obj.getMessage());                        
      
      obj = new MMUtilSMSObject('E002','443453031720',2,false,'United States','Test SMS 1');
      
      System.assertEquals('E002',obj.getEntityId());
      System.assertEquals('443453031720',obj.getSelectedPhone());
      System.assertEquals(2,obj.getReceiptNumber());
      System.assertEquals(false,obj.getIsTrack());
      System.assertEquals('United States',obj.getCountry());                        
      System.assertEquals('Test SMS 1',obj.getMessage());
      
      obj = new MMUtilSMSObject('E002','443453031720',2,false,'United States','Test SMS 1','af','0_a');
      
      System.assertEquals('E002',obj.getEntityId());
      System.assertEquals('443453031720',obj.getSelectedPhone());
      System.assertEquals(2,obj.getReceiptNumber());
      System.assertEquals(false,obj.getIsTrack());
      System.assertEquals('United States',obj.getCountry());                        
      System.assertEquals('Test SMS 1',obj.getMessage());                        
      System.assertEquals('af',obj.getEntityType());                        
      System.assertEquals('0_a',obj.getTimeZone());                                    
      
      Test.stopTest();       
   }
}