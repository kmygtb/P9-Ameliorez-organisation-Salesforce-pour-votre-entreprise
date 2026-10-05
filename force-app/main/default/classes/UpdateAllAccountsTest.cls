@isTest
private class UpdateAllAccountsTest {

    @isTest
    static void testBatch_RecalculatesChiffreAffaireFromScratch() {
        Account accountA = new Account(Name = 'Compte A', Chiffre_d_affaire__c = 0);
        Account accountB = new Account(Name = 'Compte B', Chiffre_d_affaire__c = 0);
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

        Order orderA1 = buildDraftOrder(accountA.Id);
        Order orderA2 = buildDraftOrder(accountA.Id);
        Order orderA3Draft = buildDraftOrder(accountA.Id);
        Order orderB1 = buildDraftOrder(accountB.Id);
        insert new List<Order>{ orderA1, orderA2, orderA3Draft, orderB1 };

        insert new List<OrderItem>{
                new OrderItem(OrderId = orderA1.Id, PricebookEntryId = pbe.Id, Quantity = 100, UnitPrice = 1),
                new OrderItem(OrderId = orderA2.Id, PricebookEntryId = pbe.Id, Quantity = 50, UnitPrice = 1),
                new OrderItem(OrderId = orderA3Draft.Id, PricebookEntryId = pbe.Id, Quantity = 999, UnitPrice = 1),
                new OrderItem(OrderId = orderB1.Id, PricebookEntryId = pbe.Id, Quantity = 200, UnitPrice = 1)
        };

        orderA1.Status = 'Activated';
        orderA2.Status = 'Activated';
        orderB1.Status = 'Activated';
        update new List<Order>{ orderA1, orderA2, orderB1 };

        // Simule une migration : le trigger n'a jamais calculé le bon CA
        update new List<Account>{
                new Account(Id = accountA.Id, Chiffre_d_affaire__c = 12345),
                new Account(Id = accountB.Id, Chiffre_d_affaire__c = 0)
        };

        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts());
        Test.stopTest();

        Account updatedA = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :accountA.Id];
        Account updatedB = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :accountB.Id];

        System.assertEquals(150, updatedA.Chiffre_d_affaire__c, 'Le CA du compte A doit etre recalcule depuis zero, sans la commande Draft');
        System.assertEquals(200, updatedB.Chiffre_d_affaire__c, 'Le CA du compte B doit correspondre a sa commande activee');
    }

    private static Order buildDraftOrder(Id accountId) {
        return new Order(
                AccountId = accountId,
                EffectiveDate = Date.today(),
                Status = 'Draft',
                Pricebook2Id = Test.getStandardPricebookId(),
                ShipmentCost__c = 0
        );
    }
}