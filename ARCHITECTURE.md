# Architecture Détaillée du Code

### Pattern Architectural Global

**Zénith** suit une **Clean Architecture** a 3 couches avec separation stricte des responsabilites:

```
┌─────────────────────────────────────┐
│   Couche Presentation (UI)          │
│   - Pages (Screens)                 │
│   - ViewModels (State & Logic)      │
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

**Approche Hybride:**

1. **MVVM avec Provider (Nouveau Standard):**
   - **ViewModel** (`ChangeNotifier`) pour la logique de presentation et l'etat
   - **View** (Widget) se lie au ViewModel via `Consumer` ou `Selector`
   - Injection de dependances via `Provider`
   - Exemple: `DashboardPage` (View) -> `DashboardViewModel` (ViewModel)

2. **Stream-based Reactivity:**
   - `DashboardService.watchDashboardData()` retourne un `Stream<DashboardData>`
   - Consomme par le ViewModel ou directement via `StreamBuilder`

3. **SharedPreferences (AppPrefs):**
   - Etat global persistant (onboarding, user ID)

**Framework de Gestion d'Etat:** Utilisation de `provider` pour lier View et ViewModel.

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
│   ├── perf/                # Monitoring de performance
│   ├── prefs/               # Gestion des preferences
│   ├── theme/               # Theme de l'application
│   └── widgets/             # Widgets globaux
│
├── data/                     # Couche de donnees
│   ├── db/                  # Base de donnees (Drift)
│   ├── models/              # Modeles de transfert
│   └── repositories/        # Couche repository
│
├── services/                 # Logique metier (Business Logic)
│
├── ui/                       # Interface utilisateur
│   ├── pages/               # Ecrans complets
│   ├── viewmodels/          # ViewModels (MVVM)
│   │   └── dashboard_view_model.dart
│   ├── widgets/             # Composants reutilisables
│   └── theme/
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

---

## Stratégie de Tests

L'application met en œuvre une stratégie de tests, concentrée sur la logique métier critique (Services). Les tests sont situés dans `test/services/` et utilisent une base de données en mémoire (`sqlite3` via `drift/native`) pour garantir l'isolation et la rapidité.

### 1. Tests du Service de Recommandation (`recommendation_service_test.dart`)

C'est la suite de tests la plus complète, validant le cœur de l'application. Elle couvre 10 scénarios d'utilisation réalistes :

- **Scénarios Profils :**
  - **Débutant (Poids du corps) :** Vérifie que seuls des exercices sans matériel sont proposés.
  - **Intermédiaire (Hypertrophie) :** Vérifie la présence d'exercices d'isolation.
  - **Avancé (Force) :** Vérifie la priorité aux exercices polyarticulaires lourds (Squat, Bench).
  - **Perte de Poids :** Vérifie la priorité aux exercices cardio/intensifs (Burpees).
- **Scénarios Techniques :**
  - **Objectifs Multiples :** Vérifie que les recommandations s'adaptent si l'utilisateur change d'objectif principal vs secondaire.
  - **Matériel Incompatible :** Vérifie qu'aucun exercice n'est proposé si le matériel requis est absent.
  - **Génération de Séance :** Valide la structure d'une séance complète (ratio Poly/Iso ~60/40).
  - **Calcul de Score :** Vérifie que le score de recommandation est cohérent (affinité >= score).

### 2. Tests du Générateur de Programme (`program_generator_adjustment_test.dart` & `instant_update_test.dart`)

Ces tests valident la capacité du système à s'adapter dynamiquement :

- **Ajustement de Performance :** Simule une "mauvaise" séance (1 série, 1 rep, RPE 9) et vérifie que le générateur réduit les suggestions pour la prochaine séance (ex: passage de 3 à 2 séries).
- **Mise à Jour Instantanée :** Vérifie que la régénération d'un programme en cours (suite à une séance) modifie bien les jours futurs sans altérer l'historique.

### 3. Tests du Dashboard (`dashboard_service_test.dart`)

Valide l'exactitude des calculs statistiques affichés à l'utilisateur. Le test utilise un jeu de données "seedé" complet (Utilisateur, Programme, Sessions passées) pour vérifier :

- **Métriques Hebdomadaires :** Nombre de séances, durée totale, volume total.
- **Records (PR) :** Récupération correcte de la charge maximale soulevée.
- **Assiduité :** Vérification des données du graphique d'activité.
- **Répartition Musculaire :** Calcul correct des muscles les plus travaillés.

### 4. Tests Unitaires Divers (`service_test.dart`)

- **IMCService :** Validation des formules de calcul de l'IMC et des catégories de poids (Sous-poids, Normal, Surpoids).

---

## Schema de la Base de Donnees

### Architecture de la Base de Donnees

**Fichier:** `lib/data/db/app_db.dart`

**ORM:** Drift v2.29.0 (SQLite)

**Version du Schema:** 40

**Configuration:**
- Base de donnees pre-populee depuis `assets/db/BDD_V3.db`
- Foreign keys actives (`PRAGMA foreign_keys = ON`)
- Migrations incrementales avec gestion de versions
- Code genere automatiquement via `build_runner`

### Schema de la Base de Donnees (20 Tables)

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

### Data Access Objects (DAOs)

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

### Repositories

**Localisation:** `lib/data/repositories/`

Couche d'abstraction au-dessus des DAOs:

1. **UserRepository** (`user_repository.dart`)
   - Operations de haut niveau sur les utilisateurs
   - Gestion du profil complet
   - Validation des donnees

2. **ExerciseRepository** (`exercise_repository.dart`)
   - Operations de haut niveau sur les exercices
   - Patterns observables (watch)

### Modeles de Transfert de Donnees

**Fichier:** `lib/data/models/session_model.dart`

Modeles serializables pour le transfert de donnees:

- `SessionModel`: Representation d'une seance avec metadata
- `ExerciseModel`: Representation simplifiee d'un exercice avec prescription

Ces modeles sont utilises par les services pour manipuler les donnees sans dependre directement des entites Drift.

### Type Converters

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

### Systeme de Migrations

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

### Contraintes d'Integrite

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

## Widget Android d'Ecran d'Accueil (Détails Techniques)

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

