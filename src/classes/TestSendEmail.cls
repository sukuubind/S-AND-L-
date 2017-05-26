@isTest(SeeAllData=true) 
public class TestSendEmail{
static testMethod void TestEmail(){

List<Messaging.EmailFileAttachment> AttachList = new List<Messaging.EmailFileAttachment>();
List<Case> CaseList = new List<Case>();
List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

List<Case> CaseListV = new List<Case>();


Contact Cont = new Contact();
Cont.FirstName = 'TestName';
Cont.LastName = 'TestName';
Cont.Email = 'sukubind@gmail.com';

Insert Cont;




Case C = new Case();
C.Origin = 'Cherwell';
C.ContactID = Cont.id;
C.Description = 'ABC Test';
C.sendAttachment__c = true;
 CaseListV.add(C);
// insert C;
 
 
 
 Case Z = new Case();
Z.Origin = 'Cherwell';
Z.ContactID = Cont.id;
Z.Description = 'ABC Test';
Z.sendAttachment__c = true;
 CaseListV.add(Z);
 //insert Z;
 
 insert CaseListV;
 
 List<Attachment> AttachListV = new List<Attachment>();
 
 
 String V = 'This is a Test Attachment';
 Attachment  U = new Attachment();
 U.Body = Blob.ValueOF(V);
 U.Name = 'TestAttachment';
 U.ParentID = Z.ID;
 AttachListV.add(U);
 
 //Insert U;
 
 
 String B = 'This is a Test Attachment';
 Attachment  A = new Attachment();
 A.Body = Blob.ValueOF(B);
 A.Name = 'TestAttachment';
 A.ParentID = C.ID;
 
 AttachListV.add(A);
 //Insert A;
 
 
 String F = 'This is a Test Attachment2';
 Attachment  D = new Attachment();
 D.Body = Blob.ValueOF(F);
 D.Name = 'TestAttachment';
 D.ParentID = C.ID;
AttachListV.add(D);

insert AttachListV;
 //Insert D;
 
 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 List<String> sendTo = new List<String>();
 sendTo.add('Test@mail.com');
 mail.setToAddresses(sendTo);
 mail.setSubject('The ID for this case is ' + C.ID);
 String body = C.Description;
 mail.setPlainTextBody(body);
 
 Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
 {
 efa.setFileName(A.Name);
 efa.setBody(A.Body);
 efa.setContentType(A.ContentType);
 efa.setinline(false);
 AttachList.add(efa);
 }
 
 
 mail.setFileAttachments(AttachList);
 mails.add(mail);
 
 Messaging.sendEmail(mails);
 
 Case G = new Case();
 G.Origin = 'Cherwell';
G.ContactID = Cont.id;
G.Description = 'ABC changed Test';
G.sendAttachment__c = true;
G.ID = C.ID;
CaseList.add(G);


Case X = new Case();
 X.Origin = 'Cherwell';
X.ContactID = Cont.id;
X.Description = 'ABC changed Test';
X.sendAttachment__c = true;
X.ID = Z.ID;
CaseList.add(X);



Update CaseList;

List<Attachment> AttachList1 = [Select Id from Attachment where parentid =: C.id];
System.assertEquals(AttachList1.size(),2);

List<Case> CaseList10 = [Select id from Case where Email_Counter__c != 0 limit 1];
System.assertEquals(CaseList10.size(),1);

List<Case> CaseListV1 = new List<Case>();

Case C1 = new Case();
C1.Origin = 'Cherwell';
C1.ContactID = Cont.id;
C1.Description = 'ABC Test';
C1.sendAttachment__c = true;
 CaseListV1.add(C1);
 //insert C1;
 
 
Case C2 = new Case();
C2.Origin = 'Cherwell';
C2.ContactID = Cont.id;
C2.Description = 'ABC Test';
C2.sendAttachment__c = true;
 
 CaseListV1.add(C2);
 //insert C2;
 
Insert CaseListV1;
 
 List<Case> CaseListWithCounter = [Select ID from Case where Email_Counter__c != 0 limit 1];
 System.assertEquals(CaseListWithCounter.size(),1);
 
 
 
 
 
 Contact Cont1 = new Contact();
Cont1.FirstName = 'TestName1';
Cont1.LastName = 'TestName1';
Cont1.Email = 'sukubind@hotmail.com';

Insert Cont1;



List<Case> CaseListV2 = new List<Case>();

Case C55 = new Case();
C55.Origin = 'Cherwell';
C55.ContactID = Cont.id;
C55.Description = 'ABC Test';
C55.sendAttachment__c = false;
 
 CaseListV2.add(C55);
 //insert C55;
 
 
 
 Case Z5 = new Case();
Z5.Origin = 'Cherwell';
Z5.ContactID = Cont.id;
Z5.Description = 'ABC Test';
Z5.sendAttachment__c = false;
 
 CaseListV2.add(Z5);
 //insert Z5;
 
 Insert CaseListV2;
 
 List<Attachment> AttachListV1 = new List<Attachment>();
 
 String V1 = 'This is a Test Attachment';
 Attachment  U1 = new Attachment();
 U1.Body = Blob.ValueOF(V);
 U1.Name = 'TestAttachment';
 U1.ParentID = Z5.ID;
 
 AttachListV1.add(U1);
 
 //Insert U1;
 
 
 String B1 = 'This is a Test Attachment';
 Attachment  A1 = new Attachment();
 A1.Body = Blob.ValueOF(B);
 A1.Name = 'TestAttachment';
 A1.ParentID = C55.ID;
 
 AttachListV1.add(A1);
 //Insert A1;
 
 
 String F1 = 'This is a Test Attachment2';
 Attachment  D1 = new Attachment();
 D1.Body = Blob.ValueOF(F);
 D1.Name = 'TestAttachment';
 D1.ParentID = C55.ID;
 
 AttachListV1.add(D1);
 
 Insert AttachListV1;
 //Insert D1;
 
 Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
 List<String> sendTo1 = new List<String>();
 sendTo1.add('Test@mail.com');
 mail1.setToAddresses(sendTo);
 mail1.setSubject('The ID for this case is ' + C55.ID);
 String body1 = C55.Description;
 mail1.setPlainTextBody(body1);
 
 Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
 {
 efa1.setFileName(A1.Name);
 efa1.setBody(A1.Body);
 efa1.setContentType(A1.ContentType);
 efa1.setinline(false);
 AttachList.add(efa1);
 }
 
 
 mail1.setFileAttachments(AttachList);
 mails.add(mail1);
 
 Messaging.sendEmail(mails);
 
 

 }}