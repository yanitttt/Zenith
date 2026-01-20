# Architecture du Projet Zénith

Ce document décrit les choix techniques et l'organisation du code source de l'application Zénith. Il est destiné à guider les développeurs dans la compréhension et l'évolution du projet.

##  Structure Globale

Le projet suit les principes de la **Clean Architecture** adaptée à Flutter, structurée autour du pattern **MVVM (Model-View-ViewModel)**.

### Séparation des Responsabilités

1.  **Presentation Layer (`lib/ui`)** :
    *   **Pages :** Écrans de l'application (ex: `ActiveSessionPage`, `DashboardPage`). Elles ne contiennent que la logique d'affichage et délèguent les actions aux ViewModels ou Services.
    *   **ViewModels (`lib/ui/viewmodels`)** : Gèrent l'état des vues et font le pont avec la couche de données.
    *   **Widgets :** Composants visuels réutilisables.

2.  **Domain/Service Layer (`lib/services` & `lib/core`)** :
    *   Contient la logique métier pure et les services globaux (Notifications, Logique de fond, Préférences).
    *   Vient orchestrer les appels entre l'UI et la Data.

3.  **Data Layer (`lib/data`)** :
    *   **DB (`lib/data/db`)** : Implémentation concrète de la persistance avec **Drift**.
    *   **Repositories (`lib/data/repositories`)** : Abstraction de l'accès aux données.

---

##  Choix Techniques

### Base de Données : Drift (SQLite)

Nous utilisons **Drift** comme solution ORM pour SQLite.
*   **Pourquoi ?**
    *   **Typage fort :** Évite les erreurs SQL à l'exécution grâce à la génération de code Dart.
    *   **Réactivité :** Permet d'observer les tables (Streams) et de mettre à jour l'UI automatiquement.
    *   **Offline-first :** Les données sont stockées sur l'appareil.
*   **Fichiers clés :**
    *   `lib/data/db/app_db.dart` : Définition des tables (`Exercises`, `Sessions`, `AppUser`, etc.) et configuration de la base.
    *   `assets/db/BDD_V3.db` : Base de données pré-peuplée utilisée lors de la première installation.

### Gestion des Assets

Les images, icônes et vidéos sont stockées dans `assets/` et déclarées dans le `pubspec.yaml`.
La base de données contient des références (chemins relatifs) vers ces fichiers (ex: colonne `video_asset` de la table `Exercise`).

---

##  Arborescence Simplifiée

Voici une vue d'ensemble des dossiers clés du dossier `lib/` :

```text
lib/
├── core/                   # Cœur de l'application (Configuration, Thèmes, Utils globaux)
│   ├── perf/               # Services de mesure de performance
│   ├── prefs/              # Gestion des SharedPreferences (clé-valeur)
│   └── theme/              # Définitions des couleurs et styles (AppTheme)
│
├── data/                   # Couche Données
│   ├── db/                 # Définition de la BDD Drift & DAOs
│   │   ├── daos/           # Data Access Objects (Requêtes spécifiques)
│   │   └── app_db.dart     # Point d'entrée de la BDD
│   └── repositories/       # Abstractions d'accès aux données
│
├── services/               # Services Métier (Feature-agnostic)
│   ├── notification_service.dart
│   ├── background_service.dart
│   └── ...
│
├── ui/                     # Couche Présentation
│   ├── pages/              # Écrans principaux (Dashboard, Planning, etc.)
│   ├── viewmodels/         # Logique de présentation (State management)
│   └── widgets/            # Composants UI atomiques
│
└── main.dart               # Point d'entrée, initialisation des services et injection
```

##  Conventions

*   **Langue :** Tout le code (commentaires, noms de variables, logs) et la documentation doivent être en **Français** (sauf contraintes techniques strictes).
*   **Nommage :** CamelCase pour le code Dart, snake_case pour les fichiers.
