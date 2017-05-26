trigger SRPOpportunityAfterUpdate on Opportunity (after update) {


Id rtSRPOpportunityId = (Schema.SObjectType.Opportunity).getRecordTypeInfosByName().get('SRP Opportunity').getRecordTypeId();

SrpTriggerOverrideInSrm__c triggerOverride = SrpTriggerOverrideInSrm__c.getInstance(); 
    Boolean bypassTrigger = triggerOverride != null && 
    (triggerOverride.Override_All__c || triggerOverride.SRPOpportunityAfterUpdateTrigger__c); 

if(triggerOverride != null)
{
  System.debug('triggerOverride >---> '+triggerOverride);     
}

if(bypassTrigger)   return;

Set<Id> studentIdSet = new Set<Id>();
Set<Id> oppIdSet = new Set<Id>();

for(Opportunity opp : Trigger.New)
{
  
  Opportunity oldOpp = Trigger.OldMap.get(opp.Id);
  
  if(opp.Program_Enrollment_Update__c != null && oldOpp.Program_Enrollment_Update__c != opp.Program_Enrollment_Update__c && opp.RecordTypeId == rtSRPOpportunityId)
  {
    studentIdSet.add(opp.DeltakSRP__Student__c);
    oppIdSet.add(opp.Id);  
  }
    
}    

if(studentIdSet.size() > 0)
{
  
  Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>([SELECT Id, DeltakSRP__Academic_Program__r.DeltakSRP__School__r.Abbreviation__c,
                            DeltakSRP__Student__r.DeltakSRP__Student_ID__c, DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c, 
                            DeltakSRP__Academic_Start_Date__c, DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c
                             FROM Opportunity WHERE Id IN :oppIdSet]);  

  List<DeltakSRP__Program_Enrollment__c> peList = [SELECT Id, DeltakSRP__Enrolled_Student__c, DeltakSRP__Academic_Program__c, DeltakSRP__Enrollment_Start__c, 
                            DeltakSRP__Opportunity__c, DeltakSRP__Enrollment_Status__c, DeltakSRP__Academic_Specialization__c, 
                            DeltakSRP__Start_Date__c
                      FROM DeltakSRP__Program_Enrollment__c WHERE DeltakSRP__Enrolled_Student__c IN :studentIdSet];
  
  system.debug('peLIst>>>>'+peList);
  Map<String, DeltakSRP__Program_Enrollment__c> peMap = new Map<String, DeltakSRP__Program_Enrollment__c>();
  
  for(DeltakSRP__Program_Enrollment__c pe : peList)
  {
    peMap.put(pe.DeltakSRP__Enrolled_Student__c + '_' + pe.DeltakSRP__Academic_Program__c, pe);
  }
  
  List<DeltakSRP__Program_Enrollment__c> peToInsert = new List<DeltakSRP__Program_Enrollment__c>();
  List<DeltakSRP__Program_Enrollment__c> peToUpdate = new List<DeltakSRP__Program_Enrollment__c>();
  
  for(Opportunity opp : Trigger.New)
  {
    Opportunity oldOpp = Trigger.OldMap.get(opp.Id);
    
    if(opp.Program_Enrollment_Update__c != null && oldOpp.Program_Enrollment_Update__c != opp.Program_Enrollment_Update__c && opp.RecordTypeId == rtSRPOpportunityId)
    {
      system.debug('inside IF>>>>');
      DeltakSRP__Program_Enrollment__c tmpPE = peMap.get(opp.DeltakSRP__Student__c + '_' + opp.DeltakSRP__Academic_Program__c);
      
      if(tmpPE == null)
      {
        
        tmpPE = new DeltakSRP__Program_Enrollment__c();
        tmpPE.DeltakSRP__Enrolled_Student__c = opp.DeltakSRP__Student__c;
        tmpPE.DeltakSRP__Academic_Program__c = opp.DeltakSRP__Academic_Program__c;
        tmpPE.DeltakSRP__Enrollment_Start__c = opp.DeltakSRP__Academic_Start_Date__c;
        tmpPE.DeltakSRP__Opportunity__c = opp.Id;
        tmpPE.DeltakSRP__Enrollment_Status__c = opp.Program_Enrollment_Update__c;
        tmpPE.DeltakSRP__Academic_Specialization__c = opp.DeltakSRP__Academic_Specialization__c;
        tmpPE.DeltakSRP__Start_Date__c = oppMap.get(opp.Id).DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c;
        
        String abbrv = oppMap.get(opp.Id).DeltakSRP__Academic_Program__r.DeltakSRP__School__r.Abbreviation__c;
        String studentExternalId = oppMap.get(opp.Id).DeltakSRP__Student__r.DeltakSRP__Student_ID__c;
        String programExternalId = oppMap.get(opp.Id).DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
        
        if(abbrv != null && studentExternalId != null && programExternalId != null)
        {
            tmpPE.DeltakSRP__SIS_External_Id__c = abbrv + '-' + studentExternalId.replace(abbrv + '-','') + '-' + programExternalId.replace(abbrv + '-','');   
        }
        
        system.debug('tmpPE>>>>'+tmpPE);
        peToInsert.add(tmpPE);
        
      }
      else
      {
        system.debug('inside else>>>>');
        if(tmpPE.DeltakSRP__Enrollment_Status__c != opp.Program_Enrollment_Update__c)
        {
          if(opp.DeltakSRP__Academic_Start_Date__c != null)
          {
            tmpPE.DeltakSRP__Enrollment_Start__c = opp.DeltakSRP__Academic_Start_Date__c;
          }
          tmpPE.DeltakSRP__Opportunity__c = opp.Id;
          tmpPE.Account_Id__c = opp.AccountId;
          if(oldOpp.Program_Enrollment_Update__c == 'Roll'){
                tmpPE.DeltakSRP__Enrollment_Status__c = 'Roll';
          }else if(oldOpp.Program_Enrollment_Update__c == 'Drop'){
            tmpPE.DeltakSRP__Enrollment_Status__c = 'Drop';
          }else{
            tmpPE.DeltakSRP__Enrollment_Status__c = opp.Program_Enrollment_Update__c;
          }
          tmpPE.DeltakSRP__Academic_Specialization__c = opp.DeltakSRP__Academic_Specialization__c;
          if(oppMap.get(opp.Id).DeltakSRP__Academic_Start_Date__c != null && oppMap.get(opp.Id).DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c != null)
          {
            tmpPE.DeltakSRP__Start_Date__c = oppMap.get(opp.Id).DeltakSRP__Academic_Start_Date__r.DeltakSRP__Start_Date__c;
          }
          String abbrv = oppMap.get(opp.Id).DeltakSRP__Academic_Program__r.DeltakSRP__School__r.Abbreviation__c;
          String studentExternalId = oppMap.get(opp.Id).DeltakSRP__Student__r.DeltakSRP__Student_ID__c;
          String programExternalId = oppMap.get(opp.Id).DeltakSRP__Academic_Program__r.DeltakSRP__SIS_External_Id__c;
          
          if(abbrv != null && studentExternalId != null && programExternalId != null)
          {
              tmpPE.DeltakSRP__SIS_External_Id__c = abbrv + '-' + studentExternalId.replace(abbrv + '-','') + '-' + programExternalId.replace(abbrv + '-','');   
          }
          
          peToUpdate.add(tmpPE);
            
        }
        
      }
          
    }
      
  } 
  
  system.debug('peToinsert>>>'+peToinsert);
  system.debug('peToUpdate>>>'+peToUpdate);
  
  insert peToInsert;
  
  update peToUpdate;
  
}

List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
    Map<Id,Id> contactidsMap = new Map<Id,Id>();
    for(Opportunity o: Trigger.New){
        if(Trigger.NewMap.get(o.id).stagename == 'Start'){
            opportunitiesToProcess.add(o);
            contactidsMap.put(o.DeltakSRP__Student__c, o.id);
        }
    } 
    system.debug('contactidsmap>>>>'+contactidsMap);
    if(contactidsMap.size() > 0)
    {
	    List<Contact> contacts = [Select Id, Opportunity_in_Start_Stage__c from contact where id in: contactidsMap.keyset()];
	    List<Contact> contactsToUpdate = new List<Contact>();
	    
	    for(Contact c: contacts){
	        c.Opportunity_in_Start_Stage__c = contactidsMap.get(c.id);
	        contactsToUpdate.add(c);
	    }
	    system.debug('contactsToUpdate>>>>'+contactsToUpdate);
	    if(contactsToUpdate.size()>0)
	        update contactsToUpdate;
    } 

//Girija : SRP-2060 added condition to create new Task after clicking on Offer Appointment
if(checkRecursive.runOnce())
{
    if(!triggerOverride.Override_Offer_Appt_Task_creation__c)
    {
        List<Id> taskForoppIds = new List<Id>();    
        for(Opportunity opp : Trigger.New)
        {
            Opportunity oldOpp = Trigger.OldMap.get(opp.Id);
            system.debug('oldOpp.DeltakSRP__webschedulerstatus__c-->>'+oldOpp.DeltakSRP__webschedulerstatus__c);
             system.debug('opp.DeltakSRP__webschedulerstatus__c-->>'+opp.DeltakSRP__webschedulerstatus__c);
            if(oldOpp.DeltakSRP__webschedulerstatus__c != 'New' && oldOpp.DeltakSRP__webschedulerstatus__c != opp.DeltakSRP__webschedulerstatus__c)         
            { 
            	system.debug('inside this if-->>');
                taskForoppIds.add(opp.id);
            }
        }           
        if(taskForoppIds!=null && taskForoppIds.size() > 0)
        {
            SRPOfferAppointmentCreateTask.createOfferAppointmentTask(taskForoppIds);    
        }
          
    }
}

}