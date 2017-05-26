/**
 * SRPException
 * @description Exception class for SRP related functionality
 * @author Pratik Tanna
 * @date 07/31/2013
 */
public class SRPException extends Exception{
  
    // Running test here so we can access the private secret string.
    static testMethod void testException() {
        boolean caughtException = false;
        try{
            throw new SRPException('Threw exception');
        }catch(SRPException e){
            System.assertEquals('Threw exception',e.getMessage());
            caughtException = true;
        }
        System.assert(caughtException);
    }
}