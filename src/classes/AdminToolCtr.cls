/**
 * Administation tool for database operations.
 *
 * @see         AdminTool.page
 *
 * @version     2016-07-06 kevin.kolditz@die-interaktiven.de      first version
 * 			    
 */	

public with sharing class AdminToolCtr {


	public String sObjectName { get; set; }
	public String whereClause { get; set; }
	public String previewQueryString { get; set; }

	public String sObjectNameUpdate { get; set; }
	public String whereClauseUpdate { get; set; }
	public String previewQueryStringUpdate { get; set; }

	public String fieldToUpdate { get; set; }
	public Object newValue { get; set; }


	public AdminToolCtr() {
		
	}

	public void deleteBatch() {

		Database.executeBatch(new RecordDeleteBatch(sObjectName, whereClause));
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'Deletion initialized.'));
	}

	public void updateBatch() {

		Map<String, Object> fieldValueMap = new Map<String, Object> ();
		if (fieldToUpdate != null && fieldToUpdate != '') {
			
			fieldValueMap.put(fieldToUpdate,newValue);
		}

		Database.executeBatch(new RecordUpdateBatch(sObjectNameUpdate, whereClauseUpdate, fieldValueMap));
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'Update initialized.'));
	}

	public void previewQuery() {

		String query = 'SELECT Id FROM ' + this.sObjectName;
        
		if (this.whereClause != null && this.whereClause.length() > 0) {

			query += ' WHERE ' + this.whereClause;
		}

		this.previewQueryString = query;
	}

	public void previewQueryUpdate() {

		String query = 'SELECT Id FROM ' + this.sObjectNameUpdate;
        
		if (this.whereClauseUpdate != null && this.whereClauseUpdate.length() > 0) {

			query += ' WHERE ' + this.whereClauseUpdate;
		}

		this.previewQueryStringUpdate = query;
	}

}