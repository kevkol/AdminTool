global with sharing class RecordDeleteBatch implements Database.Batchable<sObject>, Database.Stateful {

    private final String sObjectAPIName;
    private final String whereCondition;
    private Integer recordsProcessed = 0;
    private final Integer batchSize;

    global RecordDeleteBatch(String sObjectAPIName, String whereCondition, Integer batchSize) {
        this.sObjectAPIName = sObjectAPIName;
        this.whereCondition = whereCondition;
        this.batchSize = batchSize > 0 ? batchSize : 200;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM ' + String.escapeSingleQuotes(this.sObjectAPIName);

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
            delete scope;
            recordsProcessed += scope.size();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Batch Job Exception: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'Batch Job Finished. Total records processed: ' + recordsProcessed);
    }
}