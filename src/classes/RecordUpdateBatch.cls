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

	// the field that has to be copied
	global String fieldToSetCopy { get; set; }

	// the field with the origin value
	global String originField { get; set; }

	global RecordUpdateBatch(String sObjectAPIName, Map<String, Object> fieldsToSetMap) {

		this.sObjectAPIName = sObjectAPIName;
		this.fieldsToSetMap = fieldsToSetMap;
	}

	global RecordUpdateBatch(String sObjectAPIName, String originField, String fieldToSetCopy, String whereCondition) {

		this.fieldToSetCopy = fieldToSetCopy;
		this.originField 	= originField;
		this.sObjectAPIName = sObjectAPIName;
		this.whereCondition = whereCondition;

	}

	global RecordUpdateBatch(String sObjectAPIName, String whereCondition, Map<String, Object> fieldsToSetMap) {

		this.sObjectAPIName 	= sObjectAPIName;
		this.whereCondition 	= whereCondition;
		this.fieldsToSetMap 	= fieldsToSetMap;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {

		String query = 'SELECT Id ';

		if (this.originField != null) {

			query += ', ' + this.originField;
		}

		query += ' FROM ' + this.sObjectAPIName;

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

			//if (this.fieldsToSetMap != null && !this.fieldsToSetMap.isEmpty()) {
			for (sObject obj : scope) {
				// set all relevant fields

				System.debug('this.fieldsToSetMap  ' + this.fieldsToSetMap);
				System.debug('this.fieldToSetCopy  ' + this.fieldToSetCopy);
				System.debug('this.originField  ' + this.originField);

				if(this.fieldsToSetMap != null) {

					for (String field : this.fieldsToSetMap.keySet()) {

						String fieldType = String.valueOf(obj.getSObjectType().getDescribe().fields.getMap().get(field).getDescribe().getType());
						System.debug(' fieldType ' + fieldType);

						if(fieldType == 'STRING') {

							obj.put(field, this.fieldsToSetMap.get(field));
						} else if (fieldType == 'BOOLEAN') {

							if(String.valueOf(this.fieldsToSetMap.get(field)).toLowerCase() == 'true') {

								obj.put(field, true);
							} else {

								obj.put(field, false);
							}
						}
					}
				} else if (this.fieldToSetCopy != null && this.originField != null) {

					System.debug('this.fieldToSetCopy  ' + this.fieldToSetCopy);
					System.debug('this.originField  ' + this.originField);

					if(!this.originField.contains('.')) {

						obj.put(this.fieldToSetCopy, obj.get(this.originField));
					} else {

						List<String> fieldList = this.originField.split('\\.');
						System.debug('fieldList  ' + fieldList);
						sObject testObj = obj.getSObject(fieldList[0]);
						System.debug('testObj  ' + testObj);
						obj.put(this.fieldToSetCopy, testObj.get(fieldList[1]));
					}
				}
			}
			//}

			update scope;

		} catch (Exception e) {

			// Include lines if logUtil is installed
			// LogUtil log = new LogUtil();
			// log.warn('RecordUpdateBatch', 'Error in execute method', e);
		}
	}

	global void finish(Database.BatchableContext BC) {

		System.debug('Batch Job Finished');
	}

}