Global class OpportunitySwitchOwnerForNurtureSch  implements Schedulable{
	Global void execute(SchedulableContext sc){ 
        OpportunitySwitchOwnerForNurtureBatch b = new OpportunitySwitchOwnerForNurtureBatch();
        Database.executeBatch(b, 2000);
    }
}