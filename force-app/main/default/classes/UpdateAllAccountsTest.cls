@isTest
private class UpdateAllAccountsTest {

    @isTest
    static void testBatch_RecalculatesChiffreAffaireFromScratch() {
        Account accountA = TestDataFactory.buildAccount('Compte A');
        Account accountB = TestDataFactory.buildAccount('Compte B');
        insert new List<Account>{ accountA, accountB };

        PricebookEntry pbe = TestDataFactory.createPricebookEntry(1);

        Order orderA1 = TestDataFactory.buildDraftOrder(accountA.Id);
        Order orderA2 = TestDataFactory.buildDraftOrder(accountA.Id);
        Order orderA3Draft = TestDataFactory.buildDraftOrder(accountA.Id);
        Order orderB1 = TestDataFactory.buildDraftOrder(accountB.Id);
        insert new List<Order>{ orderA1, orderA2, orderA3Draft, orderB1 };

        insert new List<OrderItem>{
            TestDataFactory.buildOrderItem(orderA1.Id, pbe.Id, 100, 1),
            TestDataFactory.buildOrderItem(orderA2.Id, pbe.Id, 50, 1),
            TestDataFactory.buildOrderItem(orderA3Draft.Id, pbe.Id, 999, 1),
            TestDataFactory.buildOrderItem(orderB1.Id, pbe.Id, 200, 1)
        };

        orderA1.Status = 'Activated';
        orderA2.Status = 'Activated';
        orderB1.Status = 'Activated';
        update new List<Order>{ orderA1, orderA2, orderB1 };

        // Simule une migration : le trigger n'a jamais calcule le bon CA
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
}