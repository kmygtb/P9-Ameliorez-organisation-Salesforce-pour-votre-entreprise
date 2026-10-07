@isTest
private class OrdersControllerTest {

    @isTest
    static void testGetSumOrdersByAccount_FiltersCorrectlyByAccountAndStatus() {
        Account accountA = TestDataFactory.buildAccount('Compte A');
        Account accountB = TestDataFactory.buildAccount('Compte B');
        insert new List<Account>{ accountA, accountB };

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(1);

        Order orderA_Activated = TestDataFactory.buildDraftOrder(accountA.Id);
        Order orderA_Draft = TestDataFactory.buildDraftOrder(accountA.Id);
        Order orderB_Activated = TestDataFactory.buildDraftOrder(accountB.Id);
        insert new List<Order>{ orderA_Activated, orderA_Draft, orderB_Activated };

        insert new List<OrderItem>{
            TestDataFactory.buildOrderItem(orderA_Activated.Id, pbe.Id, 100, 1),
            TestDataFactory.buildOrderItem(orderA_Draft.Id, pbe.Id, 50, 1),
            TestDataFactory.buildOrderItem(orderB_Activated.Id, pbe.Id, 500, 1)
        };

        orderA_Activated.Status = 'Activated';
        orderB_Activated.Status = 'Activated';
        update new List<Order>{ orderA_Activated, orderB_Activated };

        Decimal result = OrdersController.getSumOrdersByAccount(accountA.Id);

        System.assertEquals(100, result, 'Le total doit correspondre uniquement au compte A, statut Activated');
    }
}