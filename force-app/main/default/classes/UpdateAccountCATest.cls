@isTest
private class UpdateAccountCATest {

    @isTest
    static void testBulkUpdate_FailsOnOriginalBuggyTrigger() {
        Account testAccount = new Account(Name = 'Test Bulk Account', Chiffre_d_affaire__c = 0);
        insert testAccount;

        Product2 pd = new Product2(Name = 'Produit Test Bulk', IsActive = true);
        insert pd;

        PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = pd.Id,
                UnitPrice = 100,
                IsActive = true
        );
        insert pbe;

        List<Order> ordersToInsert = new List<Order>();
        for (Integer i = 0; i < 150; i++) {
            ordersToInsert.add(new Order(
                    AccountId = testAccount.Id,
                    EffectiveDate = Date.today(),
                    Status = 'Draft',
                    Pricebook2Id = Test.getStandardPricebookId(),
                    ShipmentCost__c = 10
            ));
        }
        insert ordersToInsert;

        List<OrderItem> itemsToInsert = new List<OrderItem>();
        for (Order o : ordersToInsert) {
            itemsToInsert.add(new OrderItem(
                    OrderId = o.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = 100
            ));
        }
        insert itemsToInsert;

        Test.startTest();
        update ordersToInsert;
        Test.stopTest();
    }
}