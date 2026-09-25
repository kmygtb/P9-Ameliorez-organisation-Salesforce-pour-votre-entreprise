@isTest
private class CalculMontantTest {

    @isTest
    static void testBulkUpdate_AllOrdersAreRecalculated() {
        Account acc = new Account(Name = 'Test CalculMontant Account', Chiffre_d_affaire__c = 0);
        insert acc;

        Product2 pd = new Product2(Name = 'Produit Test', IsActive = true);
        insert pd;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = pd.Id,
                UnitPrice = 100,
                IsActive = true
        );
        insert pbe;

        Order order1 = new Order(AccountId = acc.Id, EffectiveDate = Date.today(),
                Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), ShipmentCost__c = 10);
        Order order2 = new Order(AccountId = acc.Id, EffectiveDate = Date.today(),
                Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId(), ShipmentCost__c = 10);
        insert new List<Order>{ order1, order2 };

        insert new List<OrderItem>{
                new OrderItem(OrderId = order1.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100),
                new OrderItem(OrderId = order2.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100)
        };

        update new List<Order>{ order1, order2 };

        Order updatedOrder1 = [SELECT NetAmount__c FROM Order WHERE Id = :order1.Id];
        Order updatedOrder2 = [SELECT NetAmount__c FROM Order WHERE Id = :order2.Id];

        System.assertEquals(90, updatedOrder1.NetAmount__c, 'La 1ere commande doit etre correctement recalculee');
        System.assertEquals(90, updatedOrder2.NetAmount__c, 'La 2eme commande doit AUSSI etre correctement recalculee (bulkification)');
    }
}