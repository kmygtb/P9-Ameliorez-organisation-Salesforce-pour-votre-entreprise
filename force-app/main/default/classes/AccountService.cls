public with sharing class AccountService {
    public static void updateChiffreAffaire(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : orders) {
            accountIds.add(ord.AccountId);
        }

        Map<Id, Account> accountsByID = AccountSelector.getByIds(accountIds);

        for (Order ord : orders) {
            Account acc = accountsByID.get(ord.AccountId);
            Decimal currentCA = acc.Chiffre_d_affaire__c == null ? 0 : acc.Chiffre_d_affaire__c;
            acc.Chiffre_d_affaire__c = currentCA + ord.TotalAmount;
        }

        update accountsByID.values();
    }
}