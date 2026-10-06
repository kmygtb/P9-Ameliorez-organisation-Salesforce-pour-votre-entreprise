/**
 * Batch de recalcul global du chiffre d'affaires des comptes.
 *
 * Prévu pour la migration de données (note de cadrage) : il recalcule, pour
 * chaque compte ayant au moins une commande Activated, son chiffre d'affaires
 * depuis zéro, sans dépendre du trigger UpdateAccountCA. Le résultat est le
 * même quel que soit le nombre d'exécutions.
 *
 * Lancement manuel : Database.executeBatch(new UpdateAllAccounts());
 */


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