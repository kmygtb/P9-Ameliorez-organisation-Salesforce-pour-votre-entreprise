public with sharing class OrdersController {
  @AuraEnabled
  public static Decimal getSumOrdersByAccount(Id accountId) {
    AggregateResult groupedResults = [
      SELECT SUM(TotalAmount) total
      FROM Order
      WHERE status = 'Activated' AND AccountId = :accountId
    ];
    return (Decimal) groupedResults.get('total');
  }
}
