public class EmailUtils {
@future
public static void sendTextEmail(List<String> recipients,String emailSubject,String textBody) {      
    // Create a new single email message object       
    // that will send out a single email to the addresses in the To, CC & BCC list.       
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();             
    //the email is not saved as an activity.       
    mail.setSaveAsActivity(false);      
    // Assign the addresses for the To lists to the mail object.    
    mail.setToAddresses(recipients);                  
    // Specify the subject line for your email address.       
     mail.setSubject(emailSubject);        
    // Set to True if you want to BCC yourself on the email.      
    mail.setBccSender(false);     
    // The email address of the user executing the Apex Code will be used.       
    mail.setUseSignature(false);       
     // Specify the text content of the email.     
    mail.setPlainTextBody(textBody);      
     // Send the email you have created.       
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }
}