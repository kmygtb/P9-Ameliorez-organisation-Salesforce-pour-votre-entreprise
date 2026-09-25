@isTest
private class MyTeamOrdersControllerTest {

    @isTest
    static void testGetSumOrdersByAccount_FiltersCorrectlyByAccountAndStatus() {
        Account accountA = new Account(Name = 'Compte A');
        Account accountB = new Account(Name = 'Compte B');
        insert new List<Account>{ accountA, accountB };

        Product2 pd = new Product2(Name = 'Produit Test', IsActive = true);
        insert pd;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = pd.Id,
                UnitPrice = 1,
                IsActive = true
        );
        insert pbe;

        Order orderA_Activated = new Order(AccountId = accountA.Id, EffectiveDate = Date.today(),
                Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(),  ShipmentCost__c = 0);
        Order orderA_Draft = new Order(AccountId = accountA.Id, EffectiveDate = Date.today(),
                Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(),  ShipmentCost__c = 0);
        Order orderB_Activated = new Order(AccountId = accountB.Id, EffectiveDate = Date.today(),
                Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(),  ShipmentCost__c = 0    );
        insert new List<Order>{ orderA_Activated, orderA_Draft, orderB_Activated };

        insert new List<OrderItem>{
                new OrderItem(OrderId = orderA_Activated.Id, PricebookEntryId = pbe.Id, Quantity = 100, UnitPrice = 1),
                new OrderItem(OrderId = orderA_Draft.Id, PricebookEntryId = pbe.Id, Quantity = 50, UnitPrice = 1),
                new OrderItem(OrderId = orderB_Activated.Id, PricebookEntryId = pbe.Id, Quantity = 500, UnitPrice = 1)
        };

        orderA_Activated.Status = 'Activated';
        orderB_Activated.Status = 'Activated';

        update new List<Order>{ orderA_Activated, orderB_Activated };

        Decimal result = MyTeamOrdersController.getSumOrdersByAccount(accountA.Id);

        System.assertEquals(100, result, 'Le total doit correspondre uniquement au compte A, statut Activated');
    }
}