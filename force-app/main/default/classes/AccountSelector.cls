public with sharing class AccountSelector {
public static Map<Id, Account> getByIds(Set<Id> accountIds) {
return new Map<Id, Account>([SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds WITH SECURITY_ENFORCED]);
}
}