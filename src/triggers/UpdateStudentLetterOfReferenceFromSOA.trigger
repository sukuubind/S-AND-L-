/**
 * Created by sukumar on 3/20/2017.
 */

trigger UpdateStudentLetterOfReferenceFromSOA on DeltakSRP__Student_Letter_of_Reference_Selection__c (after insert) {
StudentOnlineAppToLetterOfReference.valuesFromSOAToSLRAfterInsert(Trigger.new,Trigger.newMap);
}