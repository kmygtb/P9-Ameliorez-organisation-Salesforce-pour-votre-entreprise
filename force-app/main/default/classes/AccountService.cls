public with sharing class AccountService {
  public static void updateChiffreAffaire(List<Order> orders) {
    Set<Id> accountIds = new Set<Id>();
    for (Order ord : orders) {
      accountIds.add(ord.AccountId);
    }

    Map<Id, Account> accountsById = AccountSelector.getByIds(accountIds);

    for (Order ord : orders) {
      Account acc = accountsById.get(ord.AccountId);
      Decimal currentCA = acc.Chiffre_d_affaire__c == null
        ? 0
        : acc.Chiffre_d_affaire__c;
      acc.Chiffre_d_affaire__c = currentCA + ord.TotalAmount;
    }

    update accountsById.values();
  }

  public static void recalculateChiffreAffaire(Set<Id> accountIds) {
    Map<Id, Decimal> totalByAccount = OrderSelector.getActivatedTotalByAccountIds(
      accountIds
    );

    List<Account> accountsToUpdate = new List<Account>();
    for (Id accId : accountIds) {
      Decimal total = totalByAccount.containsKey(accId)
        ? totalByAccount.get(accId)
        : 0;
      accountsToUpdate.add(
        new Account(Id = accId, Chiffre_d_affaire__c = total)
      );
    }

    update accountsToUpdate;
  }
}
