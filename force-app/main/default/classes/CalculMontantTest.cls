@isTest
private class CalculMontantTest {
  @isTest
  static void testBulkUpdate_AllOrdersAreRecalculated() {
    Account acc = TestDataFactory.buildAccount('Test CalculMontant Account');
    insert acc;

    PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

    Order order1 = TestDataFactory.buildDraftOrder(acc.Id);
    order1.ShipmentCost__c = 10;
    Order order2 = TestDataFactory.buildDraftOrder(acc.Id);
    order2.ShipmentCost__c = 10;
    insert new List<Order>{ order1, order2 };

    insert new List<OrderItem>{
      TestDataFactory.buildOrderItem(order1.Id, pbe.Id, 1, 100),
      TestDataFactory.buildOrderItem(order2.Id, pbe.Id, 1, 100)
    };

    update new List<Order>{ order1, order2 };

    Order updatedOrder1 = [
      SELECT NetAmount__c
      FROM Order
      WHERE Id = :order1.Id
    ];
    Order updatedOrder2 = [
      SELECT NetAmount__c
      FROM Order
      WHERE Id = :order2.Id
    ];

    System.assertEquals(
      90,
      updatedOrder1.NetAmount__c,
      'La 1ere commande doit etre correctement recalculee'
    );
    System.assertEquals(
      90,
      updatedOrder2.NetAmount__c,
      'La 2eme commande doit AUSSI etre correctement recalculee (bulkification)'
    );
  }
}
