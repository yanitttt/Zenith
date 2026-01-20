# Zénith 🏋️‍♂️

> **L'application de suivi sportif structurée & offline-first.** 
> Optimisez votre progression grâce à une architecture robuste et une UX fluide.

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.7.2+-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-4CAF50)
![Persistence](https://img.shields.io/badge/Persistence-Drift%20%28SQLite%29-inactive)

---

## Tech Stack

Le projet repose sur une stack moderne et performante :

*   **Framework :** [Flutter](https://flutter.dev/) (UI Toolkit)
*   **Langage :** [Dart](https://dart.dev/)
*   **Architecture :** MVVM (Model-View-ViewModel) + Repository Pattern
*   **Base de données locale (Offline-first) :** [Drift](https://drift.simonbinder.eu/) (SQLite abstraction)
*   **Gestion d'état :** `setState` (local) & Services (Global) / Provider (minimal)
*   **Graphiques :** `fl_chart`
*   **Notifications :** `flutter_local_notifications`

---

## Prérequis

Avant de commencer, assurez-vous d'avoir l'environnement suivant :

*   **SDK Dart :** `>=3.7.2 <4.0.0`
*   **SDK Flutter :** Compatible avec la version Dart.
*   **IDE Recommandé :** VS Code ou Android Studio avec les plugins Flutter/Dart.

---

## Installation & Lancement

### 1. Cloner et installer les dépendances

```bash
# Récupérer les dépendances listées dans pubspec.yaml
flutter pub get
```

### 2. Génération de code (Obligatoire)

Ce projet utilise `Drift` pour la base de données, qui nécessite une étape de génération de code pour créer les tables et les DAOs.

```bash
# Générer les fichiers .g.dart (one-shot)
dart run build_runner build --delete-conflicting-outputs

# OU pour lancer le watcher pendant le développement
dart run build_runner watch --delete-conflicting-outputs
```

> **Note :** Si vous rencontrez des erreurs liées à la base de données au lancement, assurez-vous d'avoir exécuté cette commande.

### 3. Lancer l'application

#### Mode Debug (Développement standard)
Pour le développement quotidien avec Hot Reload.
```bash
flutter run
```

#### Mode Performance (Test fluidité) 
Pour tester la fluidité réelle des animations et du scroll sans le surcoût du mode Debug (JIT compilation) et activer les outils de mesure.
```bash
flutter run --profile --dart-define=PERF_MODE=true
```
*Utilisez ce mode pour valider la performance du module "Perf Lab" et les transitions complexes.*

---

## Fonctionnalités Actuelles

L'application est structurée autour de plusieurs modules clés (visibles dans `lib/ui/pages`) :

*   **Dashboard :** Vue d'ensemble de l'activité, accès rapide aux fonctionnalités.
*   **Planning :** Calendrier des séances d'entraînement passées et futures.
*   **Programmes :** Gestion complète des programmes d'entraînement (génération, suivi).
*   **Exercices :** Bibliothèque d'exercices détaillée (Description, Muscles, Vidéos, Étapes).
*   **Session Active :** Interface d'exécution de séance avec chronomètre et saisie des performances.
*   **Profil & Admin :** Gestion de l'utilisateur, des données corporelles et panneau d'administration.
*   **Performance Lab :** Module dédié aux tests de rendu et d'optimisation (comparaison d'algorithmes).
*   **Offline-first :** Toutes les données sont persistées localement via SQLite (Drift), permettant une utilisation sans connexion.

---

## Structure Rapide

*   `lib/data/db` : Définition des tables et de la base de données Drift.
*   `lib/ui/pages` : Écrans de l'application.
*   `lib/ui/widgets` : Composants réutilisables.
*   `lib/services` : Logique métier (Notifications, Background, etc.).
