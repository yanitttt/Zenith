# Application Mobile de Recommandation d'Entraînement

## Description du Projet

Application mobile Flutter de recommandation et de suivi d'entraînements sportifs personnalises. Le systeme propose des exercices adaptes aux objectifs, niveau et equipement de l'utilisateur, avec un moteur de recommandation intelligent base sur les performances et les retours utilisateur.

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

**Fichier:** `lib/data/db/app_db.dart`

**ORM:** Drift v2.29.0 (SQLite)

**Version du Schema:** 40

**Configuration:**
- Base de donnees pre-populee depuis `assets/db/BDD_V3.db`
- Foreign keys actives (`PRAGMA foreign_keys = ON`)
- Migrations incrementales avec gestion de versions
- Code genere automatiquement via `build_runner`

#### Schema de la Base de Donnees (20 Tables)

**Tables Catalogue (Lecture Seule, Pre-populees)**

1. **Exercise** - Exercices disponibles
   - `id`: Identifiant unique
   - `name`: Nom de l'exercice
   - `type`: Type (poly/iso) - Exercice polyarticulaire ou isolation
   - `difficulty`: Difficulte (1-5)
   - `cardio`: Intensite cardio (0.0-1.0)

2. **Muscle** - Groupes musculaires
   - `id`: Identifiant unique
   - `name`: Nom du muscle (UNIQUE)

3. **Equipment** - Equipements d'entrainement
   - `id`: Identifiant unique
   - `name`: Nom de l'equipement (UNIQUE)

4. **Objective** - Objectifs d'entrainement
   - `id`: Identifiant unique
   - `code`: Code unique (lose_weight, gain_muscle, etc.)
   - `name`: Nom de l'objectif

5. **TrainingModality** - Prescriptions d'exercices par objectif/niveau
   - `objective_id`: Reference vers Objective
   - `level`: Niveau (debutant/intermediaire/avance)
   - `name`: Nom de la modalite
   - `rep_min`, `rep_max`: Plage de repetitions
   - `set_min`, `set_max`: Plage de series
   - `rest_min_sec`, `rest_max_sec`: Temps de repos
   - `rpe_min`, `rpe_max`: Plage de RPE

**Tables de Relation (Tables de Jonction)**

6. **ExerciseMuscle** - Muscles cibles par exercice
   - `exercise_id`: Reference vers Exercise
   - `muscle_id`: Reference vers Muscle
   - `weight`: Poids de la relation (muscle principal = poids eleve)
   - Cle primaire composite: (exercise_id, muscle_id)

7. **ExerciseEquipment** - Equipement requis par exercice
   - `exercise_id`: Reference vers Exercise
   - `equipment_id`: Reference vers Equipment
   - Cle primaire composite: (exercise_id, equipment_id)

8. **ExerciseObjective** - Affinite exercice-objectif
   - `exercise_id`: Reference vers Exercise
   - `objective_id`: Reference vers Objective
   - `weight`: Poids de correlation (0.0-1.0)
   - Cle primaire composite: (exercise_id, objective_id)

9. **ExerciseRelation** - Relations entre exercices
   - `src_exercise_id`: Exercice source
   - `dst_exercise_id`: Exercice destination
   - `relation_type`: Type (variation, substitute, progression, regression)
   - `weight`: Force de la relation
   - Cle primaire composite: (src_exercise_id, dst_exercise_id, relation_type)

**Tables Utilisateur et Preferences**

10. **AppUser** - Profil utilisateur (Singleton)
    - `id`: Identifiant unique
    - `age`: Age (nullable)
    - `weight`: Poids en kg (nullable)
    - `height`: Taille en cm (nullable)
    - `gender`: Genre (homme/femme, nullable)
    - `birth_date`: Date de naissance (nullable)
    - `level`: Niveau (debutant/intermediaire/avance, nullable)
    - `metabolism`: Metabolisme (rapide/lent, nullable)
    - `nom`: Nom de famille (nullable)
    - `prenom`: Prenom (nullable)
    - `singleton`: Contrainte de singleton (DEFAULT 1, UNIQUE)

**Pattern Singleton:** L'application ne supporte qu'un seul utilisateur. Ceci est applique via un index unique sur la colonne `singleton` qui a toujours la valeur 1.

11. **UserEquipment** - Equipement possede par l'utilisateur
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `equipment_id`: Reference vers Equipment
    - Cle primaire composite: (user_id, equipment_id)

12. **UserGoal** - Objectifs de l'utilisateur
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `objective_id`: Reference vers Objective
    - `weight`: Priorite de l'objectif
    - Cle primaire composite: (user_id, objective_id)

13. **UserTrainingDay** - Jours d'entrainement de l'utilisateur
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `day_of_week`: Jour de la semaine (1-7, 1=Lundi)
    - Cle primaire composite: (user_id, day_of_week)

14. **UserFeedback** - Retours utilisateur sur les exercices
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `exercise_id`: Reference vers Exercise
    - `session_id`: Reference vers Session (nullable, CASCADE DELETE)
    - `liked`: Exercice aime (0/1)
    - `difficult`: Exercice difficile (0/1)
    - `pleasant`: Exercice agreable (0/1)
    - `useless`: Exercice inutile (0/1)
    - `ts`: Timestamp Unix (secondes)
    - Cle primaire composite: (user_id, exercise_id, ts)

**Tables Journal d'Entrainement**

15. **Session** - Seances completees
    - `id`: Identifiant unique
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `program_day_id`: Reference vers ProgramDay (nullable, SET NULL)
    - `date_ts`: Timestamp Unix de la seance
    - `duration_min`: Duree en minutes (nullable)
    - `name`: Nom de la seance libre (nullable)

16. **SessionExercise** - Exercices realises dans une seance
    - `session_id`: Reference vers Session (CASCADE DELETE)
    - `exercise_id`: Reference vers Exercise
    - `position`: Ordre dans la seance (1, 2, 3...)
    - `sets`: Nombre de series (nullable)
    - `reps`: Nombre de repetitions (nullable)
    - `load`: Charge en kg (nullable)
    - `rpe`: Rate of Perceived Exertion (nullable)
    - Cle primaire composite: (session_id, exercise_id, position)

**Tables Module Programmes**

17. **WorkoutProgram** - Programmes d'entrainement predefinis
    - `id`: Identifiant unique
    - `name`: Nom du programme
    - `description`: Description (nullable)
    - `objective_id`: Reference vers Objective (nullable, SET NULL)
    - `level`: Niveau cible (nullable)
    - `duration_weeks`: Duree en semaines (nullable)

18. **ProgramDay** - Jours au sein d'un programme
    - `id`: Identifiant unique
    - `program_id`: Reference vers WorkoutProgram (CASCADE DELETE)
    - `name`: Nom du jour (ex: "Jour 1 - Push")
    - `day_order`: Ordre du jour dans le programme

19. **ProgramDayExercise** - Exercices d'un jour de programme
    - `id`: Identifiant unique
    - `program_day_id`: Reference vers ProgramDay (CASCADE DELETE)
    - `exercise_id`: Reference vers Exercise
    - `position`: Ordre dans la journee
    - `modality_id`: Reference vers TrainingModality (nullable, SET NULL)
    - `sets_suggestion`: Suggestion de series (texte, ex: "3 series")
    - `reps_suggestion`: Suggestion de repetitions (texte, ex: "10-12 reps")
    - `rest_suggestion_sec`: Suggestion de repos en secondes
    - `previous_sets_suggestion`: Anciennes suggestions (historique adaptation)
    - `previous_reps_suggestion`: Anciennes suggestions (historique adaptation)
    - `previous_rest_suggestion`: Anciennes suggestions (historique adaptation)
    - `notes`: Notes supplementaires (nullable)
    - `scheduled_date`: Date planifiee (nullable)

20. **UserProgram** - Programmes actifs de l'utilisateur
    - `id`: Identifiant unique
    - `user_id`: Reference vers AppUser (CASCADE DELETE)
    - `program_id`: Reference vers WorkoutProgram (CASCADE DELETE)
    - `start_date_ts`: Timestamp Unix de debut
    - `is_active`: Programme actif (0/1, DEFAULT 1)

#### Data Access Objects (DAOs)

**Localisation:** `lib/data/db/daos/`

Couche d'acces aux donnees avec operations CRUD:

1. **UserDao** (`user_dao.dart`)
   - Operations CRUD sur AppUser
   - Application du pattern singleton
   - Gestion des suppressions en cascade
   - Methodes: `firstUser()`, `countUsers()`, `ensureSingleton()`, `insertOne()`, etc.

2. **ExerciseDao** (`exercise_dao.dart`)
   - Requetes d'exercices
   - Filtrage par muscle
   - Suggestions d'exercices
   - Methodes: `allExercises()`, `exercisesByMuscle()`, etc.

3. **SessionDao** (`session_dao.dart`)
   - Requetes de sessions/journal
   - Historique des seances
   - Statistiques de sessions

4. **UserGoalDao** (`user_goal_dao.dart`)
   - Gestion des objectifs utilisateur
   - Ajout/suppression d'objectifs
   - Mise a jour des priorites

5. **UserEquipmentDao** (`user_equipment_dao.dart`)
   - Gestion de l'equipement utilisateur
   - Ajout/suppression d'equipements

6. **UserTrainingDayDao** (`user_training_day_dao.dart`)
   - Gestion du planning hebdomadaire
   - Selection des jours d'entrainement

#### Repositories

**Localisation:** `lib/data/repositories/`

Couche d'abstraction au-dessus des DAOs:

1. **UserRepository** (`user_repository.dart`)
   - Operations de haut niveau sur les utilisateurs
   - Gestion du profil complet
   - Validation des donnees

2. **ExerciseRepository** (`exercise_repository.dart`)
   - Operations de haut niveau sur les exercices
   - Patterns observables (watch)

#### Modeles de Transfert de Donnees

**Fichier:** `lib/data/models/session_model.dart`

Modeles serializables pour le transfert de donnees:

- `SessionModel`: Representation d'une seance avec metadata
- `ExerciseModel`: Representation simplifiee d'un exercice avec prescription

Ces modeles sont utilises par les services pour manipuler les donnees sans dependre directement des entites Drift.

#### Type Converters

**Fichiers:** `lib/data/db/app_db.dart`

Convertisseurs personnalises pour garantir l'integrite des donnees:

1. **EnumTextConverter**: Validation des valeurs textuelles contraintes
   - `_convType`: 'poly' | 'iso'
   - `_convLevel`: 'debutant' | 'intermediaire' | 'avance'
   - `_convRelationType`: 'variation' | 'substitute' | 'progression' | 'regression'

2. **GenderConverter**: Normalisation du genre avec aliases
   - Accepte: 'homme', 'femme', 'male', 'female', 'm', 'f', etc.
   - Normalise vers: 'homme' | 'femme'

3. **MetabolismConverter**: Validation du metabolisme
   - Valeurs: 'rapide' | 'lent'

#### Systeme de Migrations

**Gestion des Versions:**

Le systeme de migration gere l'evolution du schema de la version 1 a 40:

**Strategie de Migration:**
- `onCreate`: Creation complete du schema + index
- `beforeOpen`: Verification et ajout de colonnes manquantes (idempotent)
- `onUpgrade`: Migration incrementale de version N a N+1

**Migrations Principales:**

- V38: Ajout des colonnes `previous_*` dans `program_day_exercise` pour historique d'adaptation
- V39: Ajout de `session_id` dans `user_feedback`
- V40: Ajout de `name` dans `session` pour nommer les seances libres

**Index Crees:**

```sql
CREATE UNIQUE INDEX ux_app_user_singleton ON app_user(singleton);
CREATE INDEX idx_ex_muscle ON exercise_muscle(exercise_id);
CREATE INDEX idx_ex_obj ON exercise_objective(exercise_id);
CREATE INDEX idx_fb_user ON user_feedback(user_id, ts);
CREATE INDEX idx_user_eq ON user_equipment(user_id);
CREATE INDEX idx_user_goal ON user_goal(user_id);
CREATE INDEX idx_sess_user ON session(user_id, date_ts);
CREATE INDEX idx_rel_src ON exercise_relation(src_exercise_id);
CREATE INDEX idx_modality ON training_modality(objective_id, level);
CREATE INDEX idx_prog_day ON program_day(program_id);
CREATE INDEX idx_prog_ex ON program_day_exercise(program_day_id);
CREATE INDEX idx_user_prog ON user_program(user_id, is_active);
```

#### Contraintes d'Integrite

**Foreign Keys:**
- Toutes les relations utilisent des contraintes de cle etrangere
- Actions configurees: CASCADE DELETE, SET NULL selon le contexte
- Verification activee via `PRAGMA foreign_keys = ON`

**Contraintes CHECK:**
- `difficulty`: Valeur entre 1 et 5
- `day_of_week`: Valeur entre 1 et 7
- Validation des enums via TypeConverter

**Contraintes UNIQUE:**
- Nom de muscle unique
- Nom d'equipement unique
- Code d'objectif unique
- Singleton utilisateur applique via index unique
- Cles composites pour tables de jonction

---

## Architecture Detaillee du Code

### Pattern Architectural Global

L'application suit une **Clean Architecture** a 3 couches avec separation stricte des responsabilites:

```
┌─────────────────────────────────────┐
│   Couche Presentation (UI)          │
│   - Pages (Screens)                 │
│   - Widgets (Components)            │
│   - Theme                           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Couche Business Logic (Services)  │
│   - RecommendationService           │
│   - SessionTrackingService          │
│   - DashboardService                │
│   - PlanningService                 │
│   - ProgramGeneratorService         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Couche Data Access                │
│   - Repositories                    │
│   - DAOs (Data Access Objects)      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Couche Persistence                │
│   - Drift ORM                       │
│   - SQLite Database                 │
└─────────────────────────────────────┘
```

### Flux de Donnees

#### Exemple: Generation d'une Seance Recommandee

```
WorkoutSessionPage (UI)
    │
    ├─ Appelle RecommendationService.generateWorkoutSession()
    │
    └─> RecommendationService (Business Logic)
        │
        ├─ 1. Recupere les objectifs utilisateur (UserGoalDao)
        │
        ├─ 2. Execute requete SQL avec filtres:
        │     - Equipement disponible (UserEquipment)
        │     - Affinite avec objectif (ExerciseObjective)
        │     - Difficulte adaptee
        │
        ├─ 3. Applique _applyAdaptiveAdjustments()
        │     │
        │     ├─ _calculatePerformanceAdjustment()
        │     │   └─ Analyse des 5 dernieres sessions (SessionDao)
        │     │
        │     └─ _calculateFeedbackAdjustment()
        │         └─ Analyse des feedbacks recents (UserFeedback)
        │
        └─ 4. Retourne List<RecommendedExercise> triee par score
            │
            └─> WorkoutSessionPage affiche la liste
```

#### Exemple: Completion d'une Seance

```
ActiveSessionPage (UI)
    │
    ├─ Utilisateur complete les exercices
    │
    └─> SessionTrackingService.completeSession()
        │
        ├─ 1. Met a jour Session.duration_min
        │
        ├─ 2. Enregistre chaque SessionExercise avec:
        │     - sets, reps, load, rpe
        │
        ├─ 3. Genere la prochaine seance:
        │     └─ ProgramGeneratorService.scheduleNextSession()
        │
        └─ 4. Mise a jour du widget:
            └─ HomeWidgetService.updateHomeWidget()
```

### Gestion de l'Etat

**Approche Hybride:**

1. **Local State (StatefulWidget):**
   - Etat des pages individuelles
   - Formulaires et champs de saisie
   - Navigation temporaire

2. **Stream-based Reactivity:**
   - `DashboardService.watchDashboardData()` retourne un `Stream<DashboardData>`
   - Consomme via `StreamBuilder` dans les widgets
   - Reactif aux changements de la base de donnees

3. **SharedPreferences (AppPrefs):**
   - Etat global de l'application
   - Indicateur d'onboarding complete
   - ID utilisateur courant

**Aucun Framework de Gestion d'Etat** (GetX, Riverpod, Provider, BLoC) n'est utilise.

### Dependances et Injection

**Pattern Utilise:** Injection manuelle via constructeurs

```dart
class ExamplePage extends StatefulWidget {
  final AppDb db;  // Injection de la base de donnees

  ExamplePage({required this.db});
}

class _ExamplePageState extends State<ExamplePage> {
  late final ExampleService _service;

  @override
  void initState() {
    super.initState();
    _service = ExampleService(widget.db);  // Instanciation locale
  }
}
```

**Instanciation Globale:**

Dans `main.dart`, une instance unique de `AppDb` est creee et passee a travers l'arbre de widgets:

```dart
final db = AppDb();
runApp(MaterialApp(home: RootShell(db: db)));
```

### Organisation des Fichiers

```
lib/
├── core/                     # Composants partages
│   ├── prefs/               # Gestion des preferences
│   │   └── app_prefs.dart   # Wrapper SharedPreferences
│   ├── theme/               # Theme de l'application
│   │   └── app_theme.dart   # Theme sombre + couleurs
│   └── widgets/             # Widgets globaux
│       └── primary_button.dart
│
├── data/                     # Couche de donnees
│   ├── db/                  # Base de donnees
│   │   ├── app_db.dart      # Schema Drift principal
│   │   ├── app_db.g.dart    # Code genere
│   │   └── daos/            # Data Access Objects
│   │       ├── user_dao.dart
│   │       ├── exercise_dao.dart
│   │       ├── session_dao.dart
│   │       ├── user_goal_dao.dart
│   │       ├── user_equipment_dao.dart
│   │       └── user_training_day_dao.dart
│   ├── models/              # Modeles de transfert
│   │   └── session_model.dart
│   └── repositories/        # Couche repository
│       ├── user_repository.dart
│       └── exercise_repository.dart
│
├── services/                 # Logique metier
│   ├── recommendation_service.dart
│   ├── session_tracking_service.dart
│   ├── dashboard_service.dart
│   ├── planning_service.dart
│   ├── program_generator_service.dart
│   ├── session_service.dart
│   ├── home_widget_service.dart
│   ├── notification_service.dart
│   └── ImcService.dart
│
├── ui/                       # Interface utilisateur
│   ├── pages/               # Ecrans complets
│   │   ├── root_shell.dart
│   │   ├── dashboard_page.dart
│   │   ├── planning_page.dart
│   │   ├── workout_program_page.dart
│   │   ├── exercises_page.dart
│   │   ├── admin_page.dart
│   │   ├── active_session_page.dart
│   │   ├── workout_session_page.dart
│   │   ├── match_page.dart
│   │   ├── session_preview_page.dart
│   │   ├── edit_user_page.dart
│   │   └── onboarding/      # Flux d'integration
│   │       ├── onboarding_flow.dart
│   │       ├── welcome_page.dart
│   │       ├── profile_basics_page.dart
│   │       ├── dob_page.dart
│   │       ├── gender_page.dart
│   │       ├── weight_page.dart
│   │       ├── height_page.dart
│   │       ├── metabolism_page.dart
│   │       ├── level_page.dart
│   │       ├── objectives_page.dart
│   │       └── equipment_page.dart
│   │
│   ├── widgets/             # Composants reutilisables
│   │   ├── banner/
│   │   ├── bottom_nav/
│   │   ├── session/
│   │   ├── calendar/
│   │   ├── charts/
│   │   ├── progress/
│   │   ├── stats/
│   │   ├── favorites/
│   │   ├── match/
│   │   ├── planning/
│   │   └── bulle/
│   │
│   └── theme/
│       └── app_theme.dart
│
└── main.dart                 # Point d'entree
```

### Decisions Architecturales Cles

1. **Pattern Singleton Utilisateur:**
   - Un seul utilisateur par installation
   - Applique au niveau de la base de donnees via index unique
   - Simplifie la gestion des sessions et preferences

2. **Base de Donnees Pre-populee:**
   - Catalogue d'exercices bundle dans l'application
   - Copie depuis assets lors de la premiere execution
   - Permet un demarrage rapide sans appel API

3. **Generation de Code Drift:**
   - Type-safety pour toutes les requetes
   - Requetes SQL compilees a la compilation
   - Reduction des erreurs runtime

4. **Reactivite via Streams:**
   - Certains services exposent des streams observables
   - Mise a jour automatique de l'UI via StreamBuilder
   - Pas de polling manuel

5. **Injection Manuelle:**
   - Pas de framework DI complexe
   - Construction explicite dans les pages
   - Traçabilite complete des dependances

6. **Suppressions en Cascade:**
   - Suppression utilisateur = suppression de toutes ses donnees
   - Applique via contraintes de cle etrangere
   - Coherence des donnees garantie

7. **Versionnage de Schema:**
   - Migrations incrementales numerotees
   - Fonction `_addColumnIfMissing()` idempotente
   - Support des migrations progressives

8. **Converters de Type:**
   - Validation des valeurs enum au niveau BD
   - Normalisation automatique (ex: 'male' → 'homme')
   - Prevention des valeurs invalides

9. **Foreign Keys Actives:**
   - `PRAGMA foreign_keys = ON`
   - Integrite referentielle appliquee par SQLite
   - Actions configurables (CASCADE, SET NULL)

---

## Widget Android d'Ecran d'Accueil

L'application inclut un widget Android natif pour afficher la prochaine seance d'entrainement directement sur l'ecran d'accueil du telephone.

### Architecture du Widget

Le widget utilise une architecture pont entre Flutter et Android natif:

```
Flutter (Dart)                    Android Native (Kotlin)
─────────────                     ──────────────────────
HomeWidgetService                 SessionWidgetProvider
      │                                   │
      ├─ Ecrit dans                       ├─ Lit depuis
      │  SharedPreferences                │  SharedPreferences
      │                                   │
      └──────────────┬────────────────────┘
                     │
                     ▼
              SharedPreferences
              (Fichier XML Android)
```

### Implementation Cote Flutter

**Fichier:** `lib/services/home_widget_service.dart`

**Classe:** `HomeWidgetService`

**Methode Principale:** `updateHomeWidget()`

**Fonctionnement:**

1. Generation d'une seance aleatoire via `SessionService.getRandomSessionInfo()`
2. Extraction des donnees de la seance:
   - Nom du jour (`dayName`)
   - Numero du jour (`dayNumber`)
   - Nom du mois (`monthName`)
   - Duree en minutes (`durationMinutes`)
   - Type de seance (`sessionType`)
   - Exercices (nom, series, reps, charge)

3. Ecriture dans `SharedPreferences`:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('dayName', sessionInfo.dayName);
await prefs.setInt('dayNumber', sessionInfo.dayNumber);
await prefs.setString('monthName', sessionInfo.monthName);
await prefs.setInt('durationMinutes', sessionInfo.durationMinutes);
await prefs.setString('sessionType', sessionInfo.sessionType);
await prefs.setString('exercise1', '${ex1.name}\n${ex1.sets} / ${ex1.reps} / ${ex1.load}');
await prefs.setString('exercise2', '${ex2.name}\n${ex2.sets} / ${ex2.reps} / ${ex2.load}');
```

**Initialisation:**

Le widget est initialise au demarrage de l'application dans `main.dart`:

```dart
final widgetService = HomeWidgetService(db);
await widgetService.initializeWidget();
```

### Implementation Cote Android

**Fichier:** `android/app/src/main/kotlin/com/example/recommandation_mobile/SessionWidgetProvider.kt`

**Classe:** `SessionWidgetProvider extends AppWidgetProvider`

**Methode Principale:** `updateAppWidget()`

**Fonctionnement:**

1. Recuperation des donnees depuis `SharedPreferences`:
```kotlin
val sharedPref = context.getSharedPreferences(
    context.packageName + "_preferences",
    Context.MODE_PRIVATE
)
```

2. Mise a jour des vues du widget via `RemoteViews`:
```kotlin
val views = RemoteViews(context.packageName, R.layout.widget_session)
views.setTextViewText(R.id.widget_day_name, sharedPref.getString("dayName", "Lundi"))
views.setTextViewText(R.id.widget_day_number, sharedPref.getString("dayNumber", "15"))
// ...
```

3. Configuration du clic pour ouvrir l'application:
```kotlin
val intent = Intent(context, MainActivity::class.java)
val pendingIntent = PendingIntent.getActivity(context, 0, intent, FLAGS)
views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
```

4. Application des modifications:
```kotlin
appWidgetManager.updateAppWidget(appWidgetId, views)
```

**Tag DEMO:**

Le widget affiche un tag "DEMO" lorsque les donnees ne sont pas relles:
```kotlin
val hasRealData = sharedPref.contains("dayName") &&
                  sharedPref.getString("dayName", "")?.isNotEmpty()
val demoTagVisibility = if (hasRealData) View.GONE else View.VISIBLE
views.setViewVisibility(R.id.widget_demo_tag, demoTagVisibility)
```

### Layout du Widget

**Fichier:** `android/app/src/main/res/layout/widget_session.xml`

**Structure:**

```xml
<LinearLayout> <!-- Conteneur principal -->
  <LinearLayout> <!-- Header -->
    <TextView>Prochaine seance</TextView>
    <FrameLayout> <!-- Tag DEMO -->
      <TextView>DEMO</TextView>
    </FrameLayout>
  </LinearLayout>

  <LinearLayout> <!-- Date et duree -->
    <LinearLayout> <!-- Jour -->
      <TextView id="widget_day_name">Lundi</TextView>
      <TextView id="widget_day_number">15</TextView>
      <TextView id="widget_month_name">Novembre</TextView>
    </LinearLayout>
    <TextView id="widget_duration">60 min</TextView>
    <FrameLayout> <!-- Type de seance -->
      <TextView id="widget_session_type">PUSH</TextView>
    </FrameLayout>
  </LinearLayout>

  <LinearLayout> <!-- Exercices -->
    <TextView id="widget_exercise_1">Squat\n4 series / 8 reps / 60kg</TextView>
    <TextView id="widget_exercise_2">Tapis\n4 series / 8 reps / 60kg</TextView>
  </LinearLayout>

  <FrameLayout> <!-- Bouton Suite -->
    <TextView>Suite</TextView>
  </FrameLayout>
</LinearLayout>
```

**Design:**

- Arriere-plan sombre (`@drawable/widget_background`)
- Textes blancs pour contraste
- Tag dore pour le type de seance (`@drawable/widget_tag_background`)
- Tag orange pour le mode DEMO (`@drawable/widget_demo_tag_background`)
- Bouton dore "Suite" (`@drawable/widget_button_background`)

### Configuration du Widget

**Fichier:** `android/app/src/main/res/xml/widget_session_info.xml`

**Parametres:**

```xml
<appwidget-provider
    android:minHeight="110dp"
    android:minWidth="280dp"
    android:updatePeriodMillis="1800000"  <!-- 30 minutes -->
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen|keyguard"
    android:initialLayout="@layout/widget_session"
    android:previewLayout="@layout/widget_session" />
```

**Proprietes:**
- Taille minimale: 280x110 dp (4x4 cellules)
- Mise a jour automatique toutes les 30 minutes
- Redimensionnable horizontalement et verticalement
- Disponible sur ecran d'accueil et ecran de verrouillage

### Declaration dans le Manifest

**Fichier:** `android/app/src/main/AndroidManifest.xml`

```xml
<receiver
    android:name=".SessionWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_session_info" />
</receiver>
```

### Comment Ajouter le Widget a l'Ecran d'Accueil

**Methode 1: Via le Menu des Widgets Android**

1. Appuyez longuement sur l'ecran d'accueil de votre telephone Android
2. Selectionnez "Widgets" dans le menu qui apparait
3. Faites defiler jusqu'a trouver "recommandation_mobile"
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
4. Trouvez "recommandation_mobile - Prochaine seance"
5. Ajoutez-le a l'ecran d'accueil

**Note Importante:**

- Le widget affichera un tag "DEMO" avec des donnees par defaut jusqu'a ce que l'application genere une vraie seance
- Pour actualiser les donnees, ouvrez l'application et generez ou completez une seance
- Le widget se met automatiquement a jour toutes les 30 minutes
- Cliquer sur le widget ouvre directement l'application

### Rafraichissement du Widget

**Automatique:**
- Toutes les 30 minutes (`updatePeriodMillis="1800000"`)
- A chaque redemarrage du telephone
- Lorsque le widget est ajoute a l'ecran d'accueil

**Manuel via l'Application:**
- Appeler `HomeWidgetService.updateHomeWidget()` dans le code Flutter
- Actuellement appele au demarrage de l'application (`main.dart`)
- Peut etre appele apres completion d'une seance

**Declenchement Programmatique:**

Pour mettre a jour le widget depuis Flutter:

```dart
final widgetService = HomeWidgetService(db);
await widgetService.updateHomeWidget();
```

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
git clone [URL_DU_DEPOT]
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

## Points Techniques Remarquables

### Systeme de Recommandation Intelligent

Le moteur de recommandation utilise un algorithme de scoring multi-criteres:

- Analyse des performances historiques (RPE, charge, volume)
- Integration des retours utilisateur (like, difficulte, plaisir)
- Adaptation dynamique basee sur 5 dernieres sessions
- Penalites progressives pour exercices trop difficiles
- Bonus pour progression de charge avec RPE controle

### Gestion de la Performance

- Requetes SQL optimisees avec index strategiques
- Utilisation de CTEs (Common Table Expressions) pour requetes complexes
- Streams reactifs pour mise a jour UI sans polling
- Chargement paresseux de la base de donnees (`LazyDatabase`)

### Securite et Integrite des Donnees

- Contraintes de cle etrangere actives
- Validation des enums au niveau base de donnees
- Pattern singleton pour utilisateur unique
- Suppressions en cascade configurees
- Type-safety via Drift et converters personnalises

### Internationalisation

- Support francais et anglais
- Formatage de dates en francais (`intl` + `fr_FR`)
- Localisation des composants Material

---

## Limitations Connues et Travail Futur

### Limitations Actuelles

1. **Recommandation Pas Encore Optimisee:**
   - Algorithme de scoring fonctionnel mais perfectible
   - Manque d'apprentissage automatique (ML)
   - Pas de prise en compte de la fatigue cumulative

2. **Model de Persistence Non Finalise:**
   - Schema en evolution (v40)
   - Certaines relations pourraient etre optimisees
   - Manque de validation complete des contraintes metier

3. **Interface Fonctionnelle Mais Perfectible:**
   - Design fonctionnel mais esthetique a ameliorer
   - Animations minimales
   - Retours visuels a enrichir

4. **Widget Android Uniquement:**
   - Pas de widget iOS pour le moment
   - Mise a jour manuelle du widget

5. **Mode Mono-Utilisateur:**
   - Un seul utilisateur par installation
   - Pas de synchronisation cloud
   - Pas de partage de donnees

### Ameliorations Futures Prevues

1. **Optimisation de la Recommandation:**
   - Integration d'algorithmes de machine learning
   - Prise en compte de la periodisation
   - Analyse de la fatigue cumulative
   - Recommandations contextuelles (heure, lieu)

2. **Finalisation du Modele:**
   - Ajout de tables pour historique de poids/mensurations
   - Gestion de la nutrition
   - Integration de plans alimentaires
   - Historique de progression photos

3. **Amelioration de l'Interface:**
   - Redesign graphique complet
   - Animations fluides
   - Mode clair/sombre commutable
   - Personnalisation des themes

4. **Fonctionnalites Sociales:**
   - Partage de programmes
   - Classements et defis
   - Communaute d'entrainement

5. **Synchronisation Cloud:**
   - Backup automatique
   - Multi-dispositifs
   - Mode hors ligne ameliore

---

## Conclusion

Cette premiere version de l'application de recommandation d'entrainement presente une architecture solide et complete avec:

- Une interface fonctionnelle couvrant tous les cas d'usage principaux
- Un backend structure avec separation claire des responsabilites
- Un modele de donnees robuste avec systeme de persistence SQLite via Drift
- Un moteur de recommandation intelligent base sur performances et feedbacks
- Un widget Android natif pour affichage sur ecran d'accueil

L'application respecte les principes de Clean Architecture, garantissant maintenabilite et evolutivite pour les iterations futures.
