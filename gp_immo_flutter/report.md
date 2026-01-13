# Rapport de Projet : GOP Immo

## 1. Description de l'Application

### Problématique
La gestion immobilière dans de nombreuses régions d'Afrique fait face à des défis majeurs liés au manque de transparence, à la fragmentation des données et à l'inefficacité de la communication entre les parties prenantes (propriétaires, locataires, gestionnaires et agents). Les méthodes traditionnelles entraînent souvent des litiges, des retards de paiement et un suivi médiocre de la maintenance.

### Utilisateurs Cibles
- **Propriétaires :** Souhaitant une supervision détaillée et une gestion automatisée de leurs actifs.
- **Locataires :** Recherchant des moyens simples de trouver des propriétés, de payer le loyer et de communiquer avec les gestionnaires.
- **Agents Immobiliers :** Ayant besoin d'une plateforme robuste pour lister et vendre ou louer des propriétés.
- **Gestionnaires Immobiliers :** Nécessitant un outil centralisé pour gérer plusieurs bâtiments et tâches.

### Fonctionnalités Clés
- **Tableau de Bord Intelligent :** Aperçu en temps réel des indicateurs financiers, des alertes immobilières et des tâches de gestion.
- **Marché Bilingue (Marketplace) :** Une interface de recherche premium avec des filtres avancés.
- **Gestion Collaborative :** Outils pour la gestion des locations, de la maintenance et de la communication entre les acteurs.
- **Messagerie Intégrée :** Système de chat en temps réel pour une communication directe entre les utilisateurs.
- **Fiabilité Hors Ligne :** Conçu avec un stockage local (SQLite) pour garantir le fonctionnement même avec une connexion internet intermittente.

## 2. Processus de Conception

### Explication de l'Architecture
L'application suit une architecture propre et modulaire conçue pour l'évolutivité :
- **Couche Présentation :** Construite avec Flutter, utilisant le pattern **Provider** pour une gestion d'état réactive. Cela garantit une interface utilisateur fluide qui se met à jour efficacement.
- **Couche Service :** Des services abstraits (ex: `NotificationService`, `LoggerService`) gèrent les préoccupations transversales.
- **Couche Données :** Utilise un **Pattern Repository** (`AppRepository`) pour fournir une API unifiée, faisant abstraction de la source des données.
- **Stockage Local :** Implémenté avec **SQLite**, offrant une base de données relationnelle robuste pour les capacités "offline-first".

### Design UI/UX
Le design se concentre sur une "Esthétique Africaine Premium", utilisant une palette de couleurs professionnelle (Orange/Blanc pour le mode clair, Bleu Foncé pour le mode sombre) et une typographie moderne (Google Fonts - Inter/Outfit).

## 3. Points Forts de l'Implémentation

### Choix Techniques
- **Flutter :** Sélectionné pour son développement multiplateforme haute performance à partir d'une base de code unique.
- **SQLite :** Choisi pour gérer des données relationnelles complexes (relations propriété-propriétaire-locataire).
- **Provider :** Une solution de gestion d'état légère et puissante, adaptée à l'échelle de l'application.

### Réalisation des Exigences
- **Support Bilingue :** Prévu pour le français et l'anglais afin de servir un marché africain diversifié.
- **Accès par Rôles :** Structuré pour gérer différentes permissions (Admins, Propriétaires, Utilisateurs).
- **Gestion des Médias :** Intégration d' `image_picker` pour documenter les propriétés avec des photos et vidéos.

## 4. Tests

### Tests Manuels
- **Cohérence de l'UI :** Tests rigoureux sur différentes tailles d'écran pour assurer un design adaptatif.
- **Validation des Flux :** Parcours complets des flux "Inscription à l'Annonce" et "Recherche au Chat".
- **Tests de Connectivité :** Simulation de scénarios hors ligne pour vérifier la synchronisation SQLite.

### Processus de Débogage
- **Débogage des Builds CI/CD :** Résolution récente d'un échec critique du build `assembleRelease` causé par des options Java 8 obsolètes et des références ambiguës. Correction par la mise à jour des dépendances et l'activation du "core library desugaring" pour la compatibilité Java 17+.
- **Intégration du Logger :** Journalisation complète via `LoggerService` pour capturer et diagnostiquer les erreurs d'exécution.

## 5. Réflexion

### Défis Rencontrés
L'un des principaux défis a été de garantir la performance de l'application tout en gérant de grands ensembles de données localement. La gestion des dépendances dans un écosystème Flutter en évolution rapide (comme les problèmes de compatibilité Gradle/Java) a également nécessité une attention particulière.

### Solutions Apportées
- **Optimisation de la Base de Données :** Requêtes relationnelles efficaces et indexation dans SQLite.
- **Débogage Systématique :** Alignement du SDK Android et des versions Java du projet sur les standards modernes.

### Leçons Apprises
L'importance d'un pattern repository robuste a été confirmée, permettant des transitions fluides entre les sources de données simulées et réelles.

### Travail Futur
- **Intégration de Paiement :** Mise en place de passerelles sécurisées pour le Mobile Money et les cartes bancaires.
- **Recherche Propulsée par l'IA :** Ajout de recommandations de propriétés basées sur le comportement de l'utilisateur.
- **Gestion Avancée des Documents :** Sécurisation des documents d'identité avec chiffrement.
