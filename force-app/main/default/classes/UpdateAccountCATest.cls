@isTest
private class UpdateAccountCATest {

    @isTest
    static void testBulkActivation_UpdatesChiffreAffaireOnce() {
        Account testAccount = TestDataFactory.buildAccount('Test Bulk Account');
        insert testAccount;

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

        List<Order> ordersToInsert = new List<Order>();
        for (Integer i = 0; i < 150; i++) {
            Order o = TestDataFactory.buildDraftOrder(testAccount.Id);
            o.ShipmentCost__c = 10;
            ordersToInsert.add(o);
        }
        insert ordersToInsert;

        List<OrderItem> itemsToInsert = new List<OrderItem>();
        for (Order o : ordersToInsert) {
            itemsToInsert.add(TestDataFactory.buildOrderItem(o.Id, pbe.Id, 1, 100));
        }
        insert itemsToInsert;

        for (Order o : ordersToInsert) {
            o.Status = 'Activated';
        }

        Test.startTest();
        update ordersToInsert;
        Test.stopTest();

        Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(15000, updatedAccount.Chiffre_d_affaire__c, 'Les 150 commandes activees doivent etre comptees une seule fois chacune');
    }
        @isTest
    static void testModifyingAlreadyActivatedOrder_DoesNotCountItAgain() {
        Account testAccount = TestDataFactory.buildAccount('Compte Double Comptage');
        insert testAccount;

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

        Order order = TestDataFactory.buildDraftOrder(testAccount.Id);
        insert order;

        OrderItem item = TestDataFactory.buildOrderItem(order.Id, pbe.Id, 1, 100);
        insert item;

        order.Status = 'Activated';
        update order;

        Account afterActivation = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(100, afterActivation.Chiffre_d_affaire__c, 'La commande activee doit etre comptee une fois');

        update new Order(Id = order.Id, Description = 'Modification sans changement de statut');

        Account afterModification = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(100, afterModification.Chiffre_d_affaire__c, 'Modifier une commande deja activee ne doit pas la recompter');
    }
}