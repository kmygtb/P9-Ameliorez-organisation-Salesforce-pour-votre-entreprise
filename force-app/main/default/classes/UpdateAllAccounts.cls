global class UpdateAllAccounts implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator([
            SELECT Id FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }

    global void execute(Database.BatchableContext info, List<Account> scope) {
        Set<Id> setAccountIds = (new Map<Id, SObject>(scope)).keySet();
        AccountService.recalculateChiffreAffaire(setAccountIds);
    }

    global void finish(Database.BatchableContext info) {
    }
}