@isTest(seealldata=true)
private class SRPTaskUpdateBatchTest {
	
	@isTest static void test_taskupdateBatchclass() {
		Test.startTest();
        SRPTaskUpdateBatch tup = new SRPTaskUpdateBatch(System.today() - 30, System.today());
        Database.executeBatch(tup);
    Test.stopTest();   
	}
	
	
	
}