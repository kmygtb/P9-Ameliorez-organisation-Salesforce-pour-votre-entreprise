@isTest
private class AccountServiceTest {
  @isTest
  static void testRecalculateChiffreAffaire_ResetsToZeroWhenNoActivatedOrder() {
    Account acc = TestDataFactory.buildAccount('Compte Sans Commande Activee');
    acc.Chiffre_d_affaire__c = 12345;
    insert acc;

    AccountService.recalculateChiffreAffaire(new Set<Id>{ acc.Id });

    Account updated = [
      SELECT Chiffre_d_affaire__c
      FROM Account
      WHERE Id = :acc.Id
    ];
    System.assertEquals(
      0,
      updated.Chiffre_d_affaire__c,
      'Un compte sans commande activee doit voir son CA remis a zero'
    );
  }
}
