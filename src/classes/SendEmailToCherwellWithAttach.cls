public class SendEmailToCherwellWithAttach {
// Define variables

List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
List<Decimal> CountList = new List<Decimal>();
List<Case> NewCaseList;
// Constructor to expect values from the trigger

public SendEmailToCherwellWithAttach(List<Case> NewCaseTriggerList){
// Assign value to variables
NewCaseList = NewCaseTriggerList;

}

// Main method here

public void SendEmailWithAttachMethod () {


 // For custom settings for Recordtypeid    
String E;
String F;
Integer MaxEmails;




CherwellSettings__c  Csettings = CherwellSettings__c.getInstance();

if (Csettings != null && Csettings.DeltakPSCSupportID__c !=null && Csettings.DeltakPSCSupportReadOnlyID__c != null && Csettings.Email_Limit__c != null ){
E = Csettings.DeltakPSCSupportID__c;
F = Csettings.DeltakPSCSupportReadOnlyID__c;
MaxEmails = Integer.ValueOF(Csettings.Email_Limit__c);
}


//CherwellPSCRecordTypeID__c  Csettings1 = CherwellPSCRecordTypeID__c.getInstance('Deltak PSC Support Read Only');

//if (Csettings1 != null){
//F = Csettings1.RecordTypeID__c;
//}



// For custom settings for number of emails to Cherwell


//CherwellEmailLimit__c  Csettings3 = CherwellEmailLimit__c.getInstance('CherwellEmailLimit');

//if (Csettings3 != null){
//MaxEmails = Integer.ValueOF(Csettings3.Email_Limit__c);
//}






for(AggregateResult  result : [Select sum(Email_Counter__c) total from Case 
                               where (recordtypeid =: E or recordtypeid =: F) 
                               AND (
                                       IsClosed=false OR 
                                       (isClosed=true AND closeddate = LAST_90_DAYS)
                               	   )
                              ]) {
CountList.add((Decimal) result.get('total'));
}






Set<ID> AttachID = new Set<ID>();
for (Case NewCase : NewCaseList){
if(NewCase.Attachments != null){
AttachID.add(NewCase.id);
}
}

List<Attachment> attList = [select ID,Name,Parentid,ContentType,Body from Attachment where ParentID IN: AttachID];
Map<ID,Attachment> AttachmentMap = new Map<ID,Attachment>();

for (Attachment  A : attList){
AttachmentMap.put(A.ParentID,A);
}



for (Case NewCase : NewCaseList){
if(NewCase.sendAttachment__c == true &&  CountList[0] == MaxEmails){
NewCase.AddError('Emails limit with attachment for the day have already been sent, please inform PSC to manually get the Attachments');
}
else 

if(NewCase.sendAttachment__c == true && (CountList[0] < MaxEmails || CountList[0] == null )){

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

List<String> sendTo = new List<String>();
List<String> ccTo = new List<String>();
sendTo.add('help@personalsupportcenter.com');
//ccTo.add('sukumar.bindra@rasmussen.edu');
mail.setToAddresses(sendTo);
//mail.setBccAddresses(ccTo);

mail.setReplyTo(NewCase.Email__c);
mail.setSenderDisplayName('NA4');

mail.setSubject('The Cherwell case ID for this case is ' + NewCase.Cherwell_Case_ID__c);
String body = NewCase.Description;
mail.setPlainTextBody(body);





for(Attachment att : [select ID,Name,Parentid,ContentType,Body from Attachment where ParentID =: NewCase.ID])


{
Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
//if(efa != null) {
efa.setFileName(att.Name);
efa.setBody(att.body);
efa.setContentType(att.ContentType);
efa.setInline(false);
//efa.ParentID = NewCase.id;
attachmentList.add(efa);
}


mail.setFileAttachments(attachmentList);
mails.add(mail);
NewCase.sendAttachment__c = false;
if(NewCase.Email_Counter__c == null) {
NewCase.Email_Counter__c = 0;
}
NewCase.Email_Counter__c = NewCase.Email_Counter__c + 1;
}
}

Messaging.sendEmail(mails);

}




}