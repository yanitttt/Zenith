# Architecture Détaillée du Code

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
