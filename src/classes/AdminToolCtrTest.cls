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
}