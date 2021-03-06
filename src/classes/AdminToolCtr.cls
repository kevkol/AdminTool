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
	public Boolean allOrNone { get; set; }
	public Integer batchSize { get; set; }

	public String sObjectSetCopy { get; set; }
	public String originField { get; set; }
	public String fieldToSetCopy { get; set; }
	public String whereClauseSetCopy { get; set; }
	public Boolean allOrNoneSetCopy { get; set; }
	public Integer batchSizeSetCopy { get; set; }

	public AdminToolCtr() {
		this.allOrNone = true;
		this.allOrNoneSetCopy = true;
		this.batchSize = 200;
		this.batchSizeSetCopy = 200;
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

		Database.executeBatch(new RecordUpdateBatch(sObjectNameUpdate, whereClauseUpdate, fieldValueMap, allOrNone),this.batchSize);
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'Update initialized.'));
	}

	public void setCopyBatch() {

		Database.executeBatch(new RecordUpdateBatch(sObjectSetCopy, originField, fieldToSetCopy, whereClauseSetCopy, allOrNoneSetCopy),this.batchSIzeSetCopy);
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, 'Copy Field Update initialized.'));
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