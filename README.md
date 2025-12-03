# Zénith - Application Mobile de Recommandation d'Entraînement

## Description du Projet

**Zénith** est une application mobile Flutter de recommandation et de suivi d'entraînements sportifs personnalises. Le systeme propose des exercices adaptes aux objectifs, niveau et equipement de l'utilisateur, avec un moteur de recommandation intelligent base sur les performances et les retours utilisateur.

---

## Premiere Version de l'Application

Cette section presente l'implementation detaillee des differents composants de la premiere version de l'application.

### 1. Interface Complete

L'interface utilisateur est implementee de maniere complete et fonctionnelle, organisee autour d'une architecture de navigation par onglets.

#### Structure de Navigation Principale

**Fichier:** `lib/ui/pages/root_shell.dart`

La navigation principale est implementee via un `RootShell` qui utilise un `IndexedStack` pour gerer 5 onglets:

```
1. Accueil (DashboardPage) - Tableau de bord avec statistiques
2. Planning (PlanningPage) - Calendrier des seances planifiees
3. Programme (WorkoutProgramPage) - Gestion des programmes d'entrainement
4. Exercices (ExercisesPage) - Catalogue d'exercices
5. Profil (AdminPage) - Gestion du profil utilisateur
```

La barre de navigation inferieure est implementee via le composant `BottomNavBar` situe dans `lib/ui/widgets/bottom_nav/bottom_nav_bar.dart`.

#### Pages Principales Implementees

**Page d'Accueil (Dashboard)**

**Fichier:** `lib/ui/pages/dashboard_page.dart`

Interface complete affichant:
- En-tete personnalise avec nom de l'utilisateur et date du jour
- Trois cartes de metriques principales: Temps total, Streak (semaines consecutives), Seances totales
- Graphique en barres de l'activite hebdomadaire (via `WeeklyBarChart`)
- Graphique circulaire de repartition des groupes musculaires (via `MusclePieChart`)
- Carte "Focus" affichant le muscle le plus travaille

Les donnees sont reactives via un `StreamBuilder` connecte au `DashboardService`.

**Page de Planning**

**Fichier:** `lib/ui/pages/planning_page.dart`

Interface de calendrier permettant:
- Selection de dates via `CalendarCard`
- Affichage des seances planifiees pour la date selectionnee
- Visualisation des jours d'entrainement de l'utilisateur

**Page Programme**

**Fichier:** `lib/ui/pages/workout_program_page.dart`

Gestion des programmes d'entrainement actifs:
- Affichage des jours du programme
- Visualisation des exercices de chaque jour
- Lancement de seances depuis un programme

**Page Exercices**

**Fichier:** `lib/ui/pages/exercises_page.dart`

Catalogue d'exercices avec:
- Liste de tous les exercices disponibles
- Filtrage et recherche
- Details de chaque exercice

**Page Profil**

**Fichier:** `lib/ui/pages/admin_page.dart`

Gestion du profil utilisateur:
- Visualisation des informations personnelles
- Edition du profil (via `EditUserPage`)
- Gestion des objectifs et de l'equipement

#### Flux d'Onboarding

**Fichier:** `lib/ui/pages/onboarding/onboarding_flow.dart`

Processus d'integration complet en 8 etapes:

1. `WelcomePage` - Ecran de bienvenue
2. `ProfileBasicsPage` - Nom et prenom
3. `DobPage` - Date de naissance
4. `GenderPage` - Genre
5. `WeightPage` - Poids
6. `HeightPage` - Taille
7. `MetabolismPage` - Type de metabolisme (rapide/lent)
8. `LevelPage` - Niveau de pratique (debutant/intermediaire/avance)
9. `ObjectivesPage` - Selection des objectifs d'entrainement
10. `EquipmentPage` - Selection de l'equipement disponible

Les donnees collectees sont enregistrees via le `UserRepository` dans la base de donnees SQLite.

#### Widgets Reutilisables

**Localisation:** `lib/ui/widgets/`

Collection de composants reutilisables:

- **Banner:** `header_banner.dart` - En-tete de page personnalisable
- **Bottom Navigation:** `bottom_nav_bar.dart` - Barre de navigation inferieure
- **Session:** `session_card.dart` - Carte d'affichage de seance
- **Calendar:** `calendar_card.dart` - Selecteur de date
- **Charts:**
  - `weekly_bar_chart.dart` - Graphique en barres d'activite hebdomadaire (fl_chart)
  - `muscle_pie_chart.dart` - Graphique circulaire de repartition musculaire (fl_chart)
- **Progress:**
  - `progress_card.dart` - Carte de progression
  - `donut_gauge.dart` - Jauge circulaire de progression
- **Stats:** `stats_card.dart` - Carte de statistiques
- **Favorites:** `favorites_card.dart` - Carte d'exercices favoris
- **Match:** `exercise_swipe_card.dart` - Carte de swipe pour noter les exercices
- **Planning:** `scale_button.dart` - Bouton personnalise pour le planning
- **Bulle:** `bulle.dart` - Widget de bulle personnalisee

#### Theme et Stylisation

**Fichier:** `lib/ui/theme/app_theme.dart`

Theme sombre applique globalement:
- Couleur d'arriere-plan principale: `#0b0f1a` (scaffold)
- Couleur d'accentuation: `#D9BE77` (gold)
- Cartes et conteneurs: `#1E1E1E`
- Design Material 3

### 2. Backend Mis en Place (Controllers et Services)

Le backend est organise en couche de services implementant la logique metier de l'application.

#### Services Principaux

**Service de Recommandation**

**Fichier:** `lib/services/recommendation_service.dart`

Moteur de recommandation d'exercices base sur:

**Algorithme de Scoring:**
```
score = objectiveAffinity × difficultyBonus × performanceMultiplier × feedbackMultiplier
```

**Composants du Score:**
- `objectiveAffinity`: Poids de correlation entre exercice et objectif utilisateur (0.0 - 1.0)
- `difficultyBonus`: Bonus pour difficulte adaptee (difficulte proche de 3/5 = optimale)
- `performanceMultiplier`: Ajustement base sur les performances passees (-1.0 a +1.0)
- `feedbackMultiplier`: Ajustement base sur les retours utilisateur (-1.0 a +0.5)

**Methodes Principales:**
- `getRecommendedExercises()`: Retourne les exercices recommandes pour un utilisateur
- `getRecommendedExercisesByMuscleGroup()`: Filtrage par groupe musculaire (haut/bas du corps)
- `generateWorkoutSession()`: Generation d'une seance complete (60% poly, 40% iso)
- `_calculatePerformanceAdjustment()`: Analyse des performances passees (RPE, series, reps, charge)
- `_calculateFeedbackAdjustment()`: Analyse des feedbacks utilisateur (like, difficult, pleasant, useless)
- `_applyAdaptiveAdjustments()`: Application des ajustements adaptatifs aux exercices

**Algorithme d'Ajustement des Performances:**

L'algorithme analyse les 5 dernieres sessions de l'utilisateur pour chaque exercice:

1. Comparaison des performances reelles vs suggestions (series, repetitions)
2. Analyse du RPE moyen (Rate of Perceived Exertion)
3. Calcul de la progression de charge
4. Application de penalites ou bonus:
   - Performance < 50% des suggestions: -0.8 (trop difficile)
   - Performance 50-70%: -0.5 (difficile)
   - Performance 70-90%: -0.2 (legerement difficile)
   - Performance >= 100% + RPE > 8.5: -0.3 (encore trop dur)
   - Performance >= 100% + RPE < 5.5: +0.5 (trop facile)
   - Bonus progression de charge > 20%: +0.2
   - Penalite regression de charge < -10%: -0.2

**Service de Generation de Programme**

**Fichier:** `lib/services/program_generator_service.dart`

Generation automatique de programmes d'entrainement:
- Creation de programmes multi-semaines
- Calcul des dates d'entrainement basees sur les jours selectionnes par l'utilisateur
- Mapping des exercices aux jours du programme
- Gestion de la progression et adaptation

**Service de Suivi de Seance**

**Fichier:** `lib/services/session_tracking_service.dart`

Gestion des seances actives:
- Creation de sessions dans la base de donnees
- Suivi des exercices realises (series, repetitions, charge, RPE)
- Enregistrement du temps de completion
- Generation automatique d'une nouvelle seance apres completion

**Service de Tableau de Bord**

**Fichier:** `lib/services/dashboard_service.dart`

Calcul des metriques et statistiques:
- Calcul du streak (semaines consecutives d'entrainement)
- Suivi de l'assiduite hebdomadaire
- Analyse de la variation de volume
- Calcul de l'efficacite
- Statistiques par groupe musculaire
- Total d'heures d'entrainement

**Methode:** `watchDashboardData(int userId)` retourne un `Stream<DashboardData>` reactif.

**Service de Planning**

**Fichier:** `lib/services/planning_service.dart`

Gestion du calendrier:
- Liste des seances pour des dates selectionnees
- Gestion de la planification des jours de programme
- Suivi des seances planifiees vs completees

**Service de Session**

**Fichier:** `lib/services/session_service.dart`

Generation de seances aleatoires (mode demo):
- Generation de seances avec exercices aleatoires
- Mapping des icones pour les types d'exercices
- Modele de session generique

**Service de Notifications**

**Fichier:** `lib/services/notification_service.dart`

Systeme de notifications push:
- Initialisation du systeme de notifications locales
- Envoi de rappels d'entrainement

**Service IMC**

**Fichier:** `lib/services/ImcService.dart`

Calculs de metriques de sante:
- Calcul de l'IMC (Indice de Masse Corporelle)

#### Architecture des Services

**Pattern d'Injection de Dependances:**

Tous les services recoivent une instance de `AppDb` via leur constructeur:

```dart
class RecommendationService {
  final AppDb db;
  RecommendationService(this.db);
}
```

Instanciation manuelle dans les pages:
```dart
final service = RecommendationService(widget.db);
```

**Aucun Framework DI** (Dependency Injection) externe n'est utilise.

### 3. Model (Persistence, BDD)

#### Architecture de la Base de Donnees

Une documentation détaillée du schéma de la base de données (tables, relations, DAOs, migrations) est disponible dans le fichier [ARCHITECTURE.md](ARCHITECTURE.md#schema-de-la-base-de-donnees).


---

## Architecture Détaillée

Une documentation approfondie de l'architecture technique (patterns, flux de données, organisation) est disponible dans le fichier [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Widget Android d'Ecran d'Accueil

L'application inclut un widget Android natif pour afficher la prochaine seance d'entrainement directement sur l'ecran d'accueil du telephone.

### Comment Ajouter le Widget a l'Ecran d'Accueil

**Methode 1: Via le Menu des Widgets Android**

1. Appuyez longuement sur l'ecran d'accueil de votre telephone Android
2. Selectionnez "Widgets" dans le menu qui apparait
3. Faites defiler jusqu'a trouver "Zénith"
4. Appuyez longuement sur le widget "Prochaine seance"
5. Faites-le glisser vers l'emplacement desire sur l'ecran d'accueil
6. Relachez pour placer le widget
7. Redimensionnez si necessaire en tirant sur les bords

**Methode 2: Via le Lanceur d'Applications**

Sur certains lanceurs Android (ex: Nova Launcher, Microsoft Launcher):

1. Ouvrez le tiroir d'applications
2. Appuyez longuement sur l'icone de l'application
3. Selectionnez "Widgets" ou "Ajouter widget"
4. Choisissez le widget "Prochaine seance"
5. Placez-le sur l'ecran d'accueil

**Methode 3: Via les Parametres du Lanceur**

1. Accedez aux parametres de votre lanceur d'accueil
2. Recherchez l'option "Widgets" ou "Personnalisation"
3. Parcourez la liste des widgets disponibles
4. Trouvez "Zénith - Prochaine seance"
5. Ajoutez-le a l'ecran d'accueil

**Note Importante:**

- Le widget affichera un tag "DEMO" avec des donnees par defaut jusqu'a ce que l'application genere une vraie seance
- Pour actualiser les donnees, ouvrez l'application et generez ou completez une seance
- Le widget se met automatiquement a jour toutes les 30 minutes
- Cliquer sur le widget ouvre directement l'application

Pour les détails techniques de l'implémentation du widget, veuillez consulter [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Technologies Utilisees

### Framework et Langage

- **Flutter:** 3.7.2+
- **Dart:** 3.7.2+
- **Android:** Kotlin pour le widget natif

### Dependances Principales

**Base de Donnees:**
- `drift: ^2.29.0` - ORM SQLite type-safe
- `drift_flutter: ^0.2.7` - Integration Flutter pour Drift
- `sqlite3_flutter_libs: ^0.5.40` - Binaires SQLite
- `path_provider: ^2.1.5` - Acces aux repertoires systeme

**Interface Utilisateur:**
- `flutter_svg: ^2.2.1` - Support des images SVG
- `fl_chart: ^1.1.1` - Graphiques (barres, circulaires)
- `cupertino_icons: ^1.0.8` - Icones iOS

**Localisation:**
- `flutter_localizations` (SDK) - Support multilingue
- `intl: ^0.20.2` - Formatage de dates et nombres

**Stockage et Preferences:**
- `shared_preferences: ^2.5.3` - Stockage cle-valeur persistant

**Widgets et Notifications:**
- `home_widget: ^0.4.0` - Integration widget Android/iOS
- `flutter_local_notifications: ^19.5.0` - Notifications push locales

**Outils de Developpement:**
- `drift_dev: ^2.29.0` - Generateur de code Drift
- `build_runner: ^2.10.1` - Systeme de generation de code
- `flutter_lints: ^5.0.0` - Regles de linting

### Assets et Ressources

- `assets/illustrations/highfive.svg` - Illustration de celebration
- `assets/db/BDD_V3.db` - Base de donnees pre-populee
- `assets/images/exercises/` - Images d'exercices

---

## Configuration et Installation

### Prerequis

- Flutter SDK 3.7.2 ou superieur
- Android Studio ou Xcode (selon la plateforme cible)
- Dart SDK 3.7.2 ou superieur

### Installation

1. Cloner le depot:
```bash
git clone https://github.com/yanitttt/recommandation_mobile.git
cd recommandation_mobile
```

2. Installer les dependances:
```bash
flutter pub get
```

3. Generer le code Drift:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Lancer l'application:
```bash
flutter run
```

### Build en Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## Conclusion

Cette premiere version de **Zénith** presente une architecture solide et complete avec:

- Une interface fonctionnelle couvrant tous les cas d'usage principaux
- Un backend structure avec separation claire des responsabilites
- Un modele de donnees robuste avec systeme de persistence SQLite via Drift
- Un moteur de recommandation intelligent base sur performances et feedbacks
- Un widget Android natif pour affichage sur ecran d'accueil

L'application respecte les principes de Clean Architecture, garantissant maintenabilite et evolutivite pour les iterations futures.
