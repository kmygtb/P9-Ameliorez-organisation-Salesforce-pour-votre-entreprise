/**
 * @description Règles métier du chiffre d'affaires des comptes
 * (champ Account.Chiffre_d_affaire__c).
 *
 * Cette classe contient la logique de calcul. Elle ne fait aucune requête
 * SOQL elle-même : la lecture des données est confiée aux selectors
 * (AccountSelector et OrderSelector).
 *
 * Elle est appelée par :
 * - le trigger UpdateAccountCA, avec updateChiffreAffaire ;
 * - le batch UpdateAllAccounts, avec recalculateChiffreAffaire.
 *
 * Chaque méthode traite un lot complet : une lecture, un calcul en mémoire,
 * puis une seule écriture, quel que soit le nombre d'enregistrements.
 */
public with sharing class AccountService {
  /**
   * @description Ajoute le montant de chaque commande au chiffre d'affaires de
   * son compte. Les comptes sont lus en une seule requête, puis mis à jour en
   * une seule opération, même si plusieurs commandes concernent le même compte.
   * Un chiffre d'affaires vide est traité comme 0.
   *
   * Le trigger ne doit envoyer ici que les commandes qui viennent de passer au
   * statut Activated : sinon, une commande serait comptée plusieurs fois.
   * @param orders commandes qui viennent de passer au statut Activated
   */
  public static void updateChiffreAffaire(List<Order> orders) {
    Set<Id> accountIds = new Set<Id>();
    for (Order ord : orders) {
      accountIds.add(ord.AccountId);
    }

    Map<Id, Account> accountsById = AccountSelector.getByIds(accountIds);

    for (Order ord : orders) {
      Account acc = accountsById.get(ord.AccountId);
      Decimal currentCA = acc.Chiffre_d_affaire__c == null
        ? 0
        : acc.Chiffre_d_affaire__c;
      acc.Chiffre_d_affaire__c = currentCA + ord.TotalAmount;
    }

    update accountsById.values();
  }

  /**
   * @description Recalcule depuis zéro le chiffre d'affaires de chaque compte :
   * somme des montants de ses commandes activées, ou 0 s'il n'en a aucune.
   * La valeur existante est remplacée, pas augmentée : le résultat est le même
   * à chaque exécution.
   * @param accountIds comptes dont le chiffre d'affaires est à recalculer
   */
  public static void recalculateChiffreAffaire(Set<Id> accountIds) {
    Map<Id, Decimal> totalByAccount = OrderSelector.getActivatedTotalByAccountIds(
      accountIds
    );

    List<Account> accountsToUpdate = new List<Account>();
    for (Id accId : accountIds) {
      Decimal total = totalByAccount.containsKey(accId)
        ? totalByAccount.get(accId)
        : 0;
      accountsToUpdate.add(
        new Account(Id = accId, Chiffre_d_affaire__c = total)
      );
    }

    update accountsToUpdate;
  }
}
