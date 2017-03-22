/**
 * Test class for AdminToolCtr controller
 *
 * @see         AdminToolCtr.cls
 *
 * @version     2016-07-13 kevin.kolditz@die-interaktiven.de      first version
 * 			    
 */	


@isTest
private class AdminToolCtrTest {

	@isTest
	static void executeMethods() {
		
		AdminToolCtr ctr = new AdminToolCtr();
		ctr.sObjectName = 'Account';
		ctr.whereClause = 'Id != null';
		ctr.sObjectNameUpdate = 'Account';
		ctr.whereClauseUpdate = 'Id != null';
		ctr.deleteBatch();
		ctr.updateBatch();
		ctr.previewQuery();	
		ctr.previewQueryUpdate();
		String fieldToUpdate = ctr.fieldToUpdate;
		Object newValue = ctr.newValue;
	}


	@isTest
	static void executeController() {
		
		AdminToolCtr ctr = new AdminToolCtr();
		ctr.sObjectName = 'Account';
		ctr.whereClause = 'Id != null';
		ctr.sObjectNameUpdate = 'Account';
		ctr.whereClauseUpdate = 'Id != null';

		String fieldToUpdate = ctr.fieldToUpdate;
		Object newValue = ctr.newValue;
	}

	@isTest
	static void executeDeleteBatch() {
		
		AdminToolCtr ctr = new AdminToolCtr();
		ctr.sObjectName = 'Account';
		ctr.whereClause = 'Id != null';

		ctr.previewQuery();	
		ctr.deleteBatch();

	}

	@isTest
	static void executeUpdateBatch() {
		
		AdminToolCtr ctr = new AdminToolCtr();

		ctr.sObjectNameUpdate = 'Account';
		ctr.whereClauseUpdate = 'Id != null';
		ctr.fieldToUpdate = 'Name';
		ctr.newValue = 'UpdateTest';

		ctr.previewQueryUpdate();
		ctr.updateBatch();

	}	

	@isTest
	static void executeSetCopyBatch() {
		
		AdminToolCtr ctr = new AdminToolCtr();

		ctr.sObjectSetCopy = 'Account';
		ctr.whereClauseSetCopy = 'Id != null';
		ctr.originField = 'Name';
		ctr.fieldToSetCopy = 'Username__c';

		ctr.setCopyBatch();
	}		
}