trigger SendEmailToCherwellWithAttachForClass on Case (
  before insert, after insert, 
  before update, after update, 
  before delete, after delete) {

  if (Trigger.isBefore) {
    if (Trigger.isUpdate) {
     SendEmailToCherwellWithAttach  T = new SendEmailToCherwellWithAttach(Trigger.new);
     T.SendEmailWithAttachMethod();
    } 
   }
   
   
   
   
   
    if (Trigger.isDelete) {}
  

  if (Trigger.IsAfter) {} 
    
    if (Trigger.isInsert) {}
  
}