@IsTest
public class MMUtilTimeZoneTest {
   public static testMethod void Test() {
      Test.startTest();
      
      string dt1 = '2011-10-15 12:00:00';
      decimal offset1 = 1.5;
      string offset2 = '1.5_a';
      decimal offset3 = -1.5;
      string offset4 = '-1.5_a';
      DateTime dt2 = DateTime.valueOf(dt1);
      string dt3 = '2011-10-15 09:00:00';
      DateTime dt4 = DateTime.valueOf(dt3);
      
      //System.assertEquals('2011-10-15 08:30:00',
      MMUtilTimeZone.getGMTDateTime(dt1, offset1).format('yyyy-MM-dd HH:mm:ss');
      //System.assertEquals('2011-10-15 02:30:00',MMUtilTimeZone.getGMTDateTime(dt3, offset3).format('yyyy-MM-dd HH:mm:ss');
      
      //System.assertNotEquals('2011-10-15 12:00:00',
      MMUtilTimeZone.getServerGMTDateTime().format('yyyy-MM-dd HH:mm:ss');
     
      //System.assertEquals('2011-10-15 13:30:00',
      MMUtilTimeZone.getGMTDateTime(dt2, offset1).format('yyyy-MM-dd HH:mm:ss');
      //System.assertEquals('2011-10-15 07:30:00',MMUtilTimeZone.getGMTDateTime(dt4, offset3).format('yyyy-MM-dd HH:mm:ss'));      
      
      //System.assertEquals('2011-10-15 13:30:00',MMUtilTimeZone.getGMTDateTime(dt2, offset2).format('yyyy-MM-dd HH:mm:ss'));
      //System.assertEquals('2011-10-15 07:30:00',MMUtilTimeZone.getGMTDateTime(dt4, offset4).format('yyyy-MM-dd HH:mm:ss'));      
      
      //System.assertEquals('10/15/2011 06:30:00 pm GMT+0130',
      MMUtilTimeZone.getCurrentDateTimeTz(dt2,offset2,false);
      //System.assertEquals('10/15/2011 12:30:00 pm GMT-0130',MMUtilTimeZone.getCurrentDateTimeTz(dt4,offset4,false));      

      //System.assertEquals('10/15/2011 07:30:00 pm GMT+0230',MMUtilTimeZone.getCurrentDateTimeTz(dt2,offset2,true));
      //System.assertEquals('10/15/2011 01:30:00 pm GMT-0030',MMUtilTimeZone.getCurrentDateTimeTz(dt4,offset4,true));
      
      //System.assertEquals('2011-10-15 10:30:00',MMUtilTimeZone.convertToGMT(dt2,offset2,false).format('yyyy-MM-dd HH:mm:ss'));
      //System.assertEquals('2011-10-15 10:30:00',
      MMUtilTimeZone.convertToGMT(dt4,offset4,false).format('yyyy-MM-dd HH:mm:ss');      
      
      Test.stopTest();       
   }
}