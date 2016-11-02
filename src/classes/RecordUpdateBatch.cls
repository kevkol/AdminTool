/**
 * This Batch Job is able to mass update records of a sObject. The records are selected by a sObject API name and an optional
 * where clause. 
 * 
 * @version 	2016-07-15  	kevin.kolditz@die-interaktiven.de 	initial version
 */
global without sharing class RecordUpdateBatch implements Database.Batchable<sObject> {
	
	// API Name of related sObject for dynamic query e.g. SCRM_Node__c
	global String sObjectAPIName { get; set; }
	
	// additional filtering for query 
	global String whereCondition { get; set; }

	// a map with the field name and the value that has to be set
	global Map<String, Object> fieldsToSetMap { get; set; }
	
	global RecordUpdateBatch(String sObjectAPIName, Map<String, Object> fieldsToSetMap) {

		this.sObjectAPIName 	= sObjectAPIName;
		this.fieldsToSetMap 	= fieldsToSetMap;
	}	

	global RecordUpdateBatch(String sObjectAPIName, String whereCondition, Map<String, Object> fieldsToSetMap) {

		this.sObjectAPIName 	= sObjectAPIName;
		System.debug('this.sObjectAPIName: ' + this.sObjectAPIName);
		this.whereCondition 	= whereCondition;
		System.debug('this.whereCondition: ' + this.whereCondition);
		this.fieldsToSetMap 	= fieldsToSetMap;
		System.debug('this.fieldsToSetMap: ' + this.fieldsToSetMap);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		String query = 'SELECT Id FROM ' + this.sObjectAPIName;
        
		if (this.whereCondition != null && this.whereCondition != '') {
			System.debug('this.whereCondition  ' + this.whereCondition);
			query += ' WHERE ' + this.whereCondition;
		}

		if (Test.isRunningTest()) {
			query += ' limit 10';
		}

		System.debug('Batch Job Query:  ' + query);

		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try {
			
				if (this.fieldsToSetMap != null && !this.fieldsToSetMap.isEmpty()) {
					for (sObject obj : scope) {
						// set all relevant fields
						for (String field : this.fieldsToSetMap.keySet()) {
							obj.put(field, this.fieldsToSetMap.get(field));
						}
					}
				}
				
				update scope;

			} catch (Exception e) {

				LogUtil log = new LogUtil();
				log.warn('RecordUpdateBatch', 'Error in execute method', e);
		    }
	}
	
	global void finish(Database.BatchableContext BC) {
		
		System.debug('Batch Job Finished'); 
	}
	
}