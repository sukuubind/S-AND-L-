public class AcademicTermUtility {
    
    Public Static Map<ID, ID> mapProgramsToNextTerm = new Map<ID,ID>();
    Public Static Map<ID, ID> mapProgramsToCurrentTerm = new Map<ID, ID>();

    Public static void getCurrentAndNextAcademicTerms(Set<ID> setProgramIDs){
        /* This function will find current and next terms for academic programs and
         * populate public Maps for each with Program ID as the key
         * Developed by: Gabriel Chapman 1/24/16
         */
        
        //After discussing with Venkat, he says not to use Academic Term Master Object but only Academic Term Object based on Start Date
        List<DeltakSRP__Academic_Start_Date__c> lstAllProgramTerms = [Select id, DeltakSRP__Start_Date__c, DeltakSRP__Academic_Program__c 
               FROM DeltakSRP__Academic_Start_Date__c 
               WHERE DeltakSRP__Academic_Program__c IN :setProgramIDs ORDER BY DeltakSRP__Start_Date__c ASC];
        
        //System.debug('lstAllProgramTerms: ' + lstAllProgramTerms);
        
        ID idTermTemp;
        ID idProgramTemp;
        
        for (DeltakSRP__Academic_Start_Date__c term : lstAllProgramTerms){
            //system.debug('IN LOOP');
            if(term.DeltakSRP__Start_Date__c < Date.today()){
                //system.debug('Found Start date < today: ' + term.DeltakSRP__Start_Date__c);
                //store info for next cycle
                idTermTemp = term.Id; 
                idProgramTemp = term.DeltakSRP__Academic_Program__c;
            }
            if(term.DeltakSRP__Start_Date__c >= Date.today()){
                //System.debug('Found Next');
                if (mapProgramsToNextTerm.get(term.DeltakSRP__Academic_Program__c) == null){
                    mapProgramsToNextTerm.put(term.DeltakSRP__Academic_Program__c, term.Id);
                    If (idTermTemp != null && idProgramTemp == term.DeltakSRP__Academic_Program__c){
                        mapProgramsToCurrentTerm.put(term.DeltakSRP__Academic_Program__c, idTermTemp);
                    }
                if(mapProgramsToNextTerm != null && mapProgramsToNextTerm.size() > 0 &&
                   mapProgramsToCurrentTerm != null && mapProgramsToCurrentTerm.size() > 0){
                       break;
                   }
                    
                }
            }
        }
    }
    
}