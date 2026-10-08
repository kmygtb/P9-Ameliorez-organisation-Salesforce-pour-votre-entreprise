public with sharing class OrderSelector {
  public static Map<Id, Decimal> getActivatedTotalByAccountIds(
    Set<Id> accountIds
  ) {
    Map<Id, Decimal> totalByAccount = new Map<Id, Decimal>();

    for (AggregateResult ar : [
      SELECT AccountId acc, SUM(TotalAmount) total
      FROM Order
      WHERE AccountId IN :accountIds AND Status = 'Activated'
      WITH SECURITY_ENFORCED
      GROUP BY AccountId
    ]) {
      totalByAccount.put((Id) ar.get('acc'), (Decimal) ar.get('total'));
    }

    return totalByAccount;
  }
}
