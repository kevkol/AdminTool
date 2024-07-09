/**
 * This Batch Job is able to mass update records of a sObject. The records are selected by a sObject API name and an optional
 * where clause.
 *
 * @version     2023-07-08  Updated version with improvements
 */
global with sharing class RecordUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {

    private final String sObjectAPIName;
    private final String whereCondition;
    private final Map<String, Object> fieldsToSetMap;
    private final String fieldToSetCopy;
    private final String originField;
    private final Boolean allOrNone;
    private Integer recordsProcessed = 0;
    private final Integer batchSize;

    global RecordUpdateBatch(String sObjectAPIName, String whereCondition, Map<String, Object> fieldsToSetMap, Boolean allOrNone, Integer batchSize) {
        this.sObjectAPIName = sObjectAPIName;
        this.whereCondition = whereCondition;
        this.fieldsToSetMap = fieldsToSetMap;
        this.fieldToSetCopy = null;
        this.originField = null;
        this.allOrNone = allOrNone;
        this.batchSize = batchSize > 0 ? batchSize : 200;
    }

    global RecordUpdateBatch(String sObjectAPIName, String originField, String fieldToSetCopy, String whereCondition, Boolean allOrNone, Integer batchSize) {
        this.sObjectAPIName = sObjectAPIName;
        this.whereCondition = whereCondition;
        this.fieldsToSetMap = null;
        this.fieldToSetCopy = fieldToSetCopy;
        this.originField = originField;
        this.allOrNone = allOrNone;
        this.batchSize = batchSize > 0 ? batchSize : 200;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> fieldsToQuery = new Set<String>{'Id'};
        if (String.isNotBlank(this.originField)) {
            fieldsToQuery.add(this.originField);
        }

        String query = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ', ') +
                       ' FROM ' + String.escapeSingleQuotes(this.sObjectAPIName);

        if (String.isNotBlank(this.whereCondition)) {
            query += ' WHERE ' + this.whereCondition;
        }

        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }

        System.debug(LoggingLevel.DEBUG, 'Batch Job Query: ' + query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            List<sObject> recordsToUpdate = new List<sObject>();

            for (sObject obj : scope) {
                if (this.fieldsToSetMap != null) {
                    for (String field : this.fieldsToSetMap.keySet()) {
                        obj.put(field, this.fieldsToSetMap.get(field));
                    }
                } else if (String.isNotBlank(this.fieldToSetCopy) && String.isNotBlank(this.originField)) {
                    Object valueToSet = obj.get(this.originField);
                    obj.put(this.fieldToSetCopy, valueToSet);
                }
                recordsToUpdate.add(obj);
            }

            if (!recordsToUpdate.isEmpty()) {
                List<Database.SaveResult> results = Database.update(recordsToUpdate, this.allOrNone);
                recordsProcessed += results.size();
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Batch Job Exception: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'Batch Job Finished. Total records processed: ' + recordsProcessed);
    }
}