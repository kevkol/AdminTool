/**
 * Created by kevinimc on 09.07.24.
 */

@isTest
private class AdminToolCtrTest {

    @isTest
    static void testLoadAvailableSObjects() {
        Test.startTest();
        AdminToolCtr controller = new AdminToolCtr();
        Test.stopTest();

        System.assertNotEquals(0, controller.availableSObjects.size(), 'Available SObjects list should not be empty');
        Boolean containsAccount = false;
        for(SelectOption option : controller.availableSObjects) {
            if(option.getValue() == 'Account') {
                containsAccount = true;
                break;
            }
        }
        System.assert(containsAccount, 'Available SObjects should contain Account');
    }

    @isTest
    static void testLoadAvailableFields() {
        AdminToolCtr controller = new AdminToolCtr();
        controller.sObjectNameUpdate = 'Account';

        Test.startTest();
        controller.loadAvailableFields();
        Test.stopTest();

        System.assertNotEquals(0, controller.availableFields.size(), 'Available fields list should not be empty');
        Boolean containsName = false;
        for(SelectOption option : controller.availableFields) {
            if(option.getValue() == 'Name') {
                containsName = true;
                break;
            }
        }
        System.assert(containsName, 'Available fields should contain Name for Account object');
    }

    @isTest
    static void testPreviewQuery() {
        AdminToolCtr controller = new AdminToolCtr();
        controller.sObjectName = 'Account';
        controller.whereClause = 'Name LIKE \'Test%\'';

        Test.startTest();
        controller.previewQuery();
        Test.stopTest();

        System.assertEquals('SELECT Id FROM Account WHERE Name LIKE \'Test%\'', controller.previewQueryString, 'Preview query string is not as expected');
    }

    @isTest
    static void testDeleteBatch() {
        // Create test data
        Account testAccount = new Account(              Name = 'TestAccount',
                                                        BillingStreet = 'Teststr. 1',
                                                        BillingCountryCode = 'DE',
                                                        BillingPostalCode = '12345',
                                                        BillingCity = 'TestCity',
                                                        Industry = 'TestIndustry');
        insert testAccount;

        AdminToolCtr controller = new AdminToolCtr();
        controller.sObjectName = 'Account';
        controller.whereClause = 'Name = \'Test Account\'';
        controller.batchSize = 200;

        Test.startTest();
        controller.deleteBatch();
        Test.stopTest();

        // Verify that the batch job was called
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'A batch job should have been created');
        System.assertEquals('Completed', jobs[0].Status, 'The batch job should have completed');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'The batch job should have completed without errors');

        // Verify that the record was deleted
        List<Account> remainingAccounts = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        System.assertEquals(0, remainingAccounts.size(), 'The test account should have been deleted');
    }

    @isTest
    static void testUpdateBatch() {
        // Create test data
        Account testAccount = new Account(              Name = 'TestAccount',
                                                        BillingStreet = 'Teststr. 1',
                                                        BillingCountryCode = 'DE',
                                                        BillingPostalCode = '12345',
                                                        BillingCity = 'TestCity',
                                                        Industry = 'TestIndustry');
        insert testAccount;

        AdminToolCtr controller = new AdminToolCtr();
        controller.sObjectNameUpdate = 'Account';
        controller.whereClauseUpdate = 'Name = \'TestAccount\'';
        controller.fieldToUpdate = 'Description';
        controller.newValue = 'Updated Description';
        controller.allOrNone = true;
        controller.batchSize = 200;

        Test.startTest();
        controller.updateBatch();
        Test.stopTest();

        // Verify that the batch job was called
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'A batch job should have been created');
        System.assertEquals('Completed', jobs[0].Status, 'The batch job should have completed');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'The batch job should have completed without errors');

        // Verify that the record was updated
        Account updatedAccount = [SELECT Description FROM Account WHERE Name = 'TestAccount'];
        System.assertEquals('Updated Description', updatedAccount.Description, 'The test account description should have been updated');
    }

    @isTest
    static void testSetCopyBatch() {
        // Create test data
        Account testAccount = new Account(              Name = 'Test Account',
                                                        BillingStreet = 'Teststr. 1',
                                                        BillingCountryCode = 'DE',
                                                        BillingPostalCode = '12345',
                                                        BillingCity = 'TestCity',
                                                        Industry = 'TestIndustry');
        insert testAccount;

        AdminToolCtr controller = new AdminToolCtr();
        controller.sObjectSetCopy = 'Account';
        controller.whereClauseSetCopy = 'Name = \'Test Account\'';
        controller.originField = 'Name';
        controller.fieldToSetCopy = 'Description';
        controller.allOrNoneSetCopy = true;
        controller.batchSizeSetCopy = 200;

        Test.startTest();
        controller.setCopyBatch();
        Test.stopTest();

        // Verify that the batch job was called
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'A batch job should have been created');
        System.assertEquals('Completed', jobs[0].Status, 'The batch job should have completed');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'The batch job should have completed without errors');

        // Verify that the record was updated
        Account updatedAccount = [SELECT Description FROM Account WHERE Name = 'Test Account'];
        System.assertEquals('Test Account', updatedAccount.Description, 'The test account description should have been updated with the Name');
    }
}