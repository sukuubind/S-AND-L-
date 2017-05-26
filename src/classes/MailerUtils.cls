public class MailerUtils {

public static void sendMailnBCC(String message,String subjectmsg, String [] toAddresses, String ereply, String esender){
 
           
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        mail.setToAddresses(toAddresses);
    //mail.setbCcAddresses(bccAddresses);
    
    mail.setReplyTo(ereply);
    mail.setSenderDisplayName(esender);

        mail.setSubject(subjectmsg);
 
        mail.setUseSignature(false);
        mail.setHtmlBody(message);

 
        //set the attachments
    //mail.setFileAttachments(attach);

    // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
 
        }   
 
 
 
public static void sendMailwAttachments(String message,String subjectmsg, String [] toAddresses, String [] bccAddresses, String ereply, String esender, Messaging.EmailFileAttachment[] attach){
 
           
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        mail.setToAddresses(toAddresses);
    mail.setbCcAddresses(bccAddresses);
    
    mail.setReplyTo(ereply);
    mail.setSenderDisplayName(esender);

        mail.setSubject(subjectmsg);
 
        mail.setUseSignature(false);
        mail.setHtmlBody(message);

 
        //set the attachments
    mail.setFileAttachments(attach);

    // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
 
        }   

 public static void sendMail(String message,String subjectmsg, String [] toAddresses, String [] bccAddresses, String ereply, String esender){
 
           
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        mail.setToAddresses(toAddresses);
    mail.setbCcAddresses(bccAddresses);
    
    mail.setReplyTo(ereply);
    mail.setSenderDisplayName(esender);

        mail.setSubject(subjectmsg);
 
        mail.setUseSignature(false);
        mail.setHtmlBody(message);

 
    // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 
        }   
 
    public static testMethod void testSendMail() {
    String bodymsg = 'This is my email message';
    String sub = 'This is my subject';

    List <String> emailAddresses = new List <String>();
    emailAddresses.add('none@rasmussen.edu');

    List <String> bccAddresses = new List <String>();
    bccAddresses.add('asha.calderon@personalsupportcenter.com');

    String ereply  = 'enrollments@rasmussen.edu';   
    String esender = 'asha.calderon@rasmussen.edu';

    //create dummy attachment
    Messaging.EmailFileAttachment mailAttachment;
    mailAttachment = new Messaging.EmailFileAttachment();
    String myString = 'This is my attachment';
    Blob myBlob = Blob.valueof(myString);
    mailAttachment.setFileName('TestFilename.txt');
    mailAttachment.setBody(myBlob);

    sendMailnBCC(bodymsg,sub, emailAddresses, ereply, esender);
        sendMail(bodymsg,sub, emailAddresses, bccAddresses,ereply, esender);
    sendMailwAttachments(bodymsg,sub, emailAddresses, bccAddresses,ereply,esender,new Messaging.EmailFileAttachment[]{mailAttachment});
    }
 
}