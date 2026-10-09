# Fasha — Optimisation de l'application Salesforce

Projet 9 de la formation Développeur Salesforce (OpenClassrooms). Mission pour Fasha, distributeur de vêtements : corriger des bugs, remettre le code en ordre, mesurer les performances et automatiser les déploiements avec GitHub Actions.

## Ce que contient ce dépôt

| Élément                                                         | Emplacement                                     |
| --------------------------------------------------------------- | ----------------------------------------------- |
| Triggers `UpdateAccountCA` et `CalculMontant`                   | `force-app/main/default/triggers`               |
| Classes Apex : services, selectors, contrôleur, batch, et tests | `force-app/main/default/classes`                |
| Composant LWC `accountOrdersTotal`                              | `force-app/main/default/lwc/accountOrdersTotal` |
| Pipeline CI/CD                                                  | `.github/workflows/main_deploy.yml`             |

## Les problèmes corrigés

| Problème de départ                                                                           | Correction                                                                                    |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `UpdateAccountCA` : une requête et une écriture par commande, erreur au-delà de 100 requêtes | le trigger filtre, `AccountService` lit les comptes une fois et écrit une fois                |
| `UpdateAccountCA` : le chiffre d'affaires est recompté à chaque modification                 | seules les commandes qui viennent de passer à `Activated` sont prises en compte               |
| `CalculMontant` : seule la première commande du lot est calculée                             | une boucle sur toutes les commandes du lot                                                    |
| Contrôleur : total de toutes les commandes de tous les comptes                               | `OrdersController` filtre par compte et par statut, et délègue la lecture à `OrderSelector`   |
| Composant LWC : aucune donnée affichée                                                       | `accountOrdersTotal` appelle le contrôleur et affiche le total ou le message d'erreur         |
| Batch `UpdateAllAccounts` : squelette vide                                                   | il recalcule le chiffre d'affaires depuis zéro, pour les comptes qui ont une commande activée |

## Architecture

- Un **trigger** filtre les commandes concernées, puis appelle un service.
- Le **service** (`AccountService`) contient la règle métier et fait une seule écriture.
- Les **selectors** (`AccountSelector`, `OrderSelector`) lisent les données, avec une requête chacun.
- `TestDataFactory` crée les données de test.

## Installation

Prérequis : [Git](https://git-scm.com/), [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli), et Node.js 22 ou plus (exigé par le CLI Salesforce).

```bash
git clone https://github.com/kmygtb/P9-Ameliorez-organisation-Salesforce-pour-votre-entreprise.git
cd P9-Ameliorez-organisation-Salesforce-pour-votre-entreprise
npm install --legacy-peer-deps
sf org login web --alias fasha
```

L'option `--legacy-peer-deps` est nécessaire : sans elle, `npm install` s'arrête sur un conflit de versions entre deux outils d'analyse du code.

## Tests

```bash
# Tests Apex, avec la couverture de code
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --synchronous -o fasha

# Tests du composant LWC (Jest)
npm run test:unit
```

Résultat attendu : 8 tests Apex réussis, avec 100 % de couverture sur les 7 classes et triggers de production, et 3 tests Jest réussis.

## Mise en forme du code

Le projet utilise Prettier. Pour vérifier la mise en forme sans rien modifier :

```bash
npx prettier --check "force-app/**/*.{cls,trigger,js,html}"
```

## Le pipeline CI/CD

Le fichier [`.github/workflows/main_deploy.yml`](.github/workflows/main_deploy.yml) décrit le pipeline GitHub Actions.

| Événement                | Ce que fait le pipeline                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| Pull request vers `main` | calcule ce qui a changé, puis **valide en simulation** (`--dry-run`) avec tous les tests Apex |
| Fusion dans `main`       | **déploie** ce qui a changé, supprime ce qui a disparu du dépôt, avec tous les tests Apex     |

- Le déploiement ne contient que les composants modifiés (le « delta », calculé avec le plugin `sfdx-git-delta`). Un delta vide ne déploie rien.
- La connexion à l'org utilise le secret GitHub `SFDX_AUTH_URL`, jamais écrit dans le dépôt. Pour le créer : `sf org display --verbose --target-org fasha`, puis copier la valeur de « Sfdx Auth Url » dans _Settings > Secrets and variables > Actions_.
- Circuit de travail : une branche de fonctionnalité, puis `DEV`, puis `main`. Seuls `main` et les pull requests vers `main` lancent le pipeline.
- Un test en échec fait échouer la validation : démontré sur la [pull request n°7](https://github.com/kmygtb/P9-Ameliorez-organisation-Salesforce-pour-votre-entreprise/pull/7), fermée sans fusion.

## Limites connues

- `CalculMontant` échoue si le champ `ShipmentCost__c` d'une commande est vide : ce cas n'est pas traité.
- Aucune règle de protection de branche n'est configurée : une pull request en échec peut être fusionnée.
- Les tests Jest ne sont pas dans le pipeline.
- Les versions du CLI et du plugin ne sont pas figées.
- La valeur `'Activated'` est écrite en dur dans plusieurs fichiers, et les classes n'ont pas de commentaires de documentation systématiques.
- Les performances sont mesurées en requêtes et en écritures, pas en durée, et aucune mesure d'énergie n'a été faite. Les volumes testés sont petits (org de développement de 5 Mo).

## Documents

Les rapports de tests et de couverture, de performance, et la documentation technique sont remis en PDF avec ce dépôt.

Réalisé par [kmygtb](https://github.com/kmygtb).
