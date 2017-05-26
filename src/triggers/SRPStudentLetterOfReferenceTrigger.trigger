trigger SRPStudentLetterOfReferenceTrigger on DeltakSRP__Student_Letter_of_Reference__c (after insert, after update) {
	
	
	if(Trigger.isAfter && Trigger.isUpdate){
		SRPStudentLORHandler.handleAfterUpdate(trigger.old, trigger.new);
	}
}