public with sharing class AdminToolCtr {
    // Constants
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    private static final Integer MAX_BATCH_SIZE = 2000;
    private static final Integer MAX_LIST_SIZE = 1000;

    // Properties for Delete operation
    public String sObjectName { get; set; }
    public String whereClause { get; set; }
    public String previewQueryString { get; set; }

    // Properties for Update operation
    public String sObjectNameUpdate { get; set; }
    public String whereClauseUpdate { get; set; }
    public String previewQueryStringUpdate { get; set; }
    public String fieldToUpdate { get; set; }
    public String newValue { get; set; }
    public Boolean allOrNone { get; set; }
    public Integer batchSize { get; set; }

    // Properties for Copy Field operation
    public String sObjectSetCopy { get; set; }
    public String originField { get; set; }
    public String fieldToSetCopy { get; set; }
    public String whereClauseSetCopy { get; set; }
    public Boolean allOrNoneSetCopy { get; set; }
    public Integer batchSizeSetCopy { get; set; }

    // Property for available SObjects and Fields
    public List<SelectOption> availableSObjects { get; set; }
    public List<SelectOption> availableFields { get; set; }
    public List<SelectOption> availableFieldsForCopy { get; set; }


    public AdminToolCtr() {
        this.allOrNone = true;
        this.allOrNoneSetCopy = true;
        this.batchSize = DEFAULT_BATCH_SIZE;
        this.batchSizeSetCopy = DEFAULT_BATCH_SIZE;
        loadAvailableSObjects();
    }

    public void loadAvailableSObjects() {
        availableSObjects = new List<SelectOption>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        List<String> sortedSObjectNames = new List<String>(globalDescribe.keySet());
        sortedSObjectNames.sort();

        for(String objName : sortedSObjectNames) {
            if(availableSObjects.size() >= MAX_LIST_SIZE) break;
            Schema.SObjectType objType = globalDescribe.get(objName);
            Schema.DescribeSObjectResult describe = objType.getDescribe();
            if(describe.isAccessible() && describe.isQueryable()) {
                availableSObjects.add(new SelectOption(objName, describe.getLabel()));
            }
        }
    }

    public void loadAvailableFields() {
        availableFields = getFieldOptions(sObjectNameUpdate);
    }

    public void loadAvailableFieldsForCopy() {
        availableFieldsForCopy = getFieldOptions(sObjectSetCopy);
    }

    @RemoteAction
    public static List<String> loadAvailableFieldsRemote(String sObjectName) {
        System.debug('Entering static loadAvailableFieldsRemote method');
        List<String> fieldNames = getFieldNames(sObjectName);
        System.debug('Available fields: ' + fieldNames);
        System.debug('Exiting static loadAvailableFieldsRemote method');
        return fieldNames;
    }

    private static List<String> getFieldNames(String sObjectName) {
        List<String> fieldNames = new List<String>();
        if (String.isNotBlank(sObjectName)) {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
            if (objType != null) {
                Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
                fieldNames = new List<String>(fieldMap.keySet());
                fieldNames.sort();
            }
        }
        return fieldNames;
    }

    private static List<SelectOption> getFieldOptions(String sObjectName) {
        List<SelectOption> fieldOptions = new List<SelectOption>();
        if (String.isNotBlank(sObjectName)) {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
            if (objType != null) {
                Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
                List<String> sortedApiNames = new List<String>(fieldMap.keySet());
                sortedApiNames.sort();
                for (String fieldName : sortedApiNames) {
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                    String apiName = fieldDescribe.getName();
                    String label = fieldDescribe.getLabel();
                    fieldOptions.add(new SelectOption(apiName, apiName + ' (' + label + ')'));
                }
            }
        }
        return fieldOptions;
    }


    public void deleteBatch() {
        try {
            validateInput(sObjectName, 'sObject Name is required for delete operation.');
            Integer batchSizeToUse = validateBatchSize(batchSize);
            Database.executeBatch(new RecordDeleteBatch(sObjectName, whereClause, batchSizeToUse), batchSizeToUse);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deletion initialized.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error initializing deletion: ' + e.getMessage()));
        }
    }

    public void updateBatch() {
        try {
            validateInput(sObjectNameUpdate, 'sObject Name is required for update operation.');
            validateInput(fieldToUpdate, 'Field to update is required.');
            Integer batchSizeToUse = validateBatchSize(batchSize);
            Map<String, Object> fieldValueMap = new Map<String, Object>{fieldToUpdate => newValue};
            Database.executeBatch(new RecordUpdateBatch(sObjectNameUpdate, whereClauseUpdate, fieldValueMap, allOrNone, batchSizeToUse), batchSizeToUse);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Update initialized.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error initializing update: ' + e.getMessage()));
        }
    }

    public void setCopyBatch() {
        try {
            validateInput(sObjectSetCopy, 'sObject Name is required for copy operation.');
            validateInput(originField, 'Origin Field is required.');
            validateInput(fieldToSetCopy, 'Target Field is required.');
            Integer batchSizeToUse = validateBatchSize(batchSizeSetCopy);
            Database.executeBatch(new RecordUpdateBatch(sObjectSetCopy, originField, fieldToSetCopy, whereClauseSetCopy, allOrNoneSetCopy, batchSizeToUse), batchSizeToUse);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Copy Field Update initialized.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error initializing copy field update: ' + e.getMessage()));
        }
    }

    public void previewQuery() {
        this.previewQueryString = buildQuery(this.sObjectName, this.whereClause);
    }

    public void previewQueryUpdate() {
        System.debug('Entering previewQueryUpdate method');
        System.debug('sObjectNameUpdate: ' + sObjectNameUpdate);
        System.debug('fieldToUpdate: ' + fieldToUpdate);
        System.debug('whereClauseUpdate: ' + whereClauseUpdate);

        try {
            if (String.isBlank(sObjectNameUpdate)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an sObject.'));
                return;
            }

            if (String.isBlank(fieldToUpdate)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a field to update.'));
                return;
            }

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectNameUpdate);
            if (objType == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid sObject selected.'));
                return;
            }

            Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
            String cleanFieldToUpdate = fieldToUpdate.replaceAll('\\s+', ' ').trim();

            if (!fieldMap.containsKey(cleanFieldToUpdate.toLowerCase())) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected field does not exist for the chosen sObject.'));
                return;
            }

            this.previewQueryStringUpdate = buildQuery(this.sObjectNameUpdate, this.whereClauseUpdate);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Query preview generated successfully.'));
            System.debug('Query preview: ' + this.previewQueryStringUpdate);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error generating query preview: ' + e.getMessage()));
            System.debug('Exception in previewQueryUpdate: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        System.debug('Exiting previewQueryUpdate method');
    }

    private String buildQuery(String objectName, String whereCondition) {
        validateInput(objectName, 'sObject Name is required for query preview.');
        String query = 'SELECT Id FROM ' + String.escapeSingleQuotes(objectName);
        if (String.isNotBlank(whereCondition)) {
            query += ' WHERE ' + whereCondition;
        }
        return query;
    }

    private void validateInput(String input, String errorMessage) {
        if (String.isBlank(input)) {
            throw new AdminToolException(errorMessage);
        }
    }

    private Integer validateBatchSize(Integer size) {
        if (size == null || size <= 0) {
            return DEFAULT_BATCH_SIZE;
        } else if (size > MAX_BATCH_SIZE) {
            return MAX_BATCH_SIZE;
        }
        return size;
    }

    public class AdminToolException extends Exception {}
}