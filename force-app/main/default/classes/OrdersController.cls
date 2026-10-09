public with sharing class OrdersController {
  @AuraEnabled
  public static Decimal getSumOrdersByAccount(Id accountId) {
    Map<Id, Decimal> totalByAccount = OrderSelector.getActivatedTotalByAccountIds(
      new Set<Id>{ accountId }
    );
    return totalByAccount.get(accountId);
  }
}
