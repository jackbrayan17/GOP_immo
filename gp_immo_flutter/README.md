# GOP Immo (Gestion de Propriété Globale)

GOP Immo est une application Flutter premium conçue pour la gestion immobilière en Afrique. Elle centralise les annonces immobilières, la communication entre locataires et propriétaires, et le suivi financier sur une plateforme unique et fiable, même hors ligne.

## 🚀 Mise en Route

### Prérequis

Pour exécuter ce projet, assurez-vous d'avoir installé les éléments suivants :
- **Flutter SDK :** ^3.10.0 (Supporte SDK >=2.19.0 <4.0.0)
- **Dart SDK :** Inclus avec Flutter
- **Java Development Kit (JDK) :** Version 17 ou supérieure (Requis pour les builds Android)
- **Android Studio / Xcode :** Pour le développement mobile
- **VS Code / IntelliJ :** IDE recommandés avec les extensions Flutter/Dart

### Installation

1.  **Cloner le dépôt :**
    ```bash
    git clone https://github.com/votre-repo/gp_immo_flutter.git
    cd gp_immo_flutter
    ```

2.  **Installer les dépendances :**
    ```bash
    flutter pub get
    ```

## 🛠️ Instructions de Build et d'Exécution

### Exécution en Développement

Pour lancer l'application sur un appareil connecté ou un émulateur :

```bash
flutter run
```

Si vous avez plusieurs appareils, spécifiez-en un :
```bash
flutter run -d <id_appareil>
```

Pour le développement web :
```bash
flutter run -d chrome
```

### Builds de Production (Release)

#### Android (APK)
Pour générer un APK de production :
```bash
flutter build apk --release
```
Le fichier de sortie se trouvera à : `build/app/outputs/flutter-apk/app-release.apk`

#### Android (App Bundle)
Pour générer un Android App Bundle (pour le Play Store) :
```bash
flutter build appbundle --release
```

#### Web
Pour construire la version web :
```bash
flutter build web
```

## 🏗️ Architecture et Stack Technique

- **Framework :** Flutter (Multiplateforme)
- **Gestion d'État :** Provider
- **Base de Données Locale :** SQLite (via `sqflite`)
- **Architecture UI :** Structure modulaire propre avec le pattern Repository
- **Notifications :** `flutter_local_notifications`

## 📝 Fonctionnalités Clés

- **Tableau de Bord :** Indicateurs immobiliers et financiers en temps réel.
- **Marché (Marketplace) :** Recherche de propriétés avec filtres avancés.
- **Messagerie :** Chat en temps réel entre utilisateurs.
- **Mode Hors Ligne :** Persistance des données via SQLite.

## 🛠️ Dépannage

- **Échec du Build Android :** Si vous rencontrez des erreurs liées à `bigLargeIcon` ou aux versions de Java, assurez-vous que votre JDK est en version 17+. Le projet est configuré avec le "core library desugaring" pour supporter les fonctionnalités Java modernes.
- **Problèmes de Dépendances :** Exécutez `flutter clean` suivi de `flutter pub get` si vous remarquez des références de paquets obsolètes.

---
Développé par [Votre Nom/Équipe] - Projet GOP Immo.
