# Algorithme de Recommandation et Système de Tracking de Sessions

## Documentation Complète - De A à Z

---

## Table des Matières

1. [Vue d'ensemble du système](#1-vue-densemble-du-système)
2. [Structure de la base de données](#2-structure-de-la-base-de-données)
3. [Algorithme de recommandation](#3-algorithme-de-recommandation)
4. [Génération de programme personnalisé](#4-génération-de-programme-personnalisé)
5. [Système de tracking des sessions](#5-système-de-tracking-des-sessions)
6. [Flux complet utilisateur](#6-flux-complet-utilisateur)
7. [Requêtes SQL détaillées](#7-requêtes-sql-détaillées)
8. [Architecture du code](#8-architecture-du-code)

---

## 1. Vue d'ensemble du système

### Objectif
Créer un système intelligent qui :
- Recommande des exercices personnalisés basés sur les objectifs et équipement de l'utilisateur
- Génère des programmes d'entraînement structurés par jours
- Permet de suivre et enregistrer les performances réelles
- Adapte les recommandations futures basées sur l'historique

### Composants principaux
1. **RecommendationService** : Filtre et recommande les exercices
2. **ProgramGeneratorService** : Génère des programmes complets
3. **SessionTrackingService** : Enregistre et analyse les performances

---

## 2. Structure de la base de données

### 2.1 Tables du catalogue d'exercices

#### Table `exercise`
```sql
CREATE TABLE exercise (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('poly', 'iso')),
  difficulty INTEGER NOT NULL CHECK(difficulty BETWEEN 1 AND 5),
  cardio REAL NOT NULL DEFAULT 0.0
);
```
- **poly** : Exercice polyarticulaire (ex: Squat, Développé couché)
- **iso** : Exercice d'isolation (ex: Curl biceps, Extension triceps)
- **difficulty** : 1 (facile) à 5 (très difficile)
- **cardio** : Composante cardio de 0.0 à 1.0

#### Table `objective`
```sql
CREATE TABLE objective (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL
);
```
Exemples : Hypertrophie, Force, Endurance, Perte de poids

#### Table `equipment`
```sql
CREATE TABLE equipment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
```
Exemples : Haltères, Barre, Banc, Élastiques, Poids du corps

#### Table `muscle`
```sql
CREATE TABLE muscle (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
```
Exemples : Pectoraux, Quadriceps, Biceps, Deltoïdes

### 2.2 Tables de liaison (exercices ↔ attributs)

#### Table `exercise_equipment`
```sql
CREATE TABLE exercise_equipment (
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  equipment_id INTEGER NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
  PRIMARY KEY (exercise_id, equipment_id)
);
CREATE INDEX idx_ex_eq ON exercise_equipment(exercise_id);
```
Lie un exercice au matériel requis.

#### Table `exercise_objective`
```sql
CREATE TABLE exercise_objective (
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  objective_id INTEGER NOT NULL REFERENCES objective(id) ON DELETE CASCADE,
  weight REAL NOT NULL,
  PRIMARY KEY (exercise_id, objective_id)
);
CREATE INDEX idx_ex_obj ON exercise_objective(exercise_id);
```
- **weight** : Affinité de l'exercice avec l'objectif (0.0 à 1.0)
  - Ex: Squat pour hypertrophie = 0.9
  - Ex: Corde à sauter pour hypertrophie = 0.2

#### Table `exercise_muscle`
```sql
CREATE TABLE exercise_muscle (
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  muscle_id INTEGER NOT NULL REFERENCES muscle(id) ON DELETE CASCADE,
  weight REAL NOT NULL,
  PRIMARY KEY (exercise_id, muscle_id)
);
CREATE INDEX idx_ex_muscle ON exercise_muscle(exercise_id);
```
- **weight** : Importance du muscle dans l'exercice
  - Ex: Développé couché → Pectoraux (0.8), Triceps (0.5), Deltoïdes (0.3)

### 2.3 Tables utilisateur

#### Table `app_user`
```sql
CREATE TABLE app_user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  prenom TEXT,
  nom TEXT,
  age INTEGER,
  birth_date INTEGER,
  weight REAL,
  height REAL,
  gender TEXT CHECK(gender IN ('homme', 'femme')),
  level TEXT CHECK(level IN ('debutant', 'intermediaire', 'avance')),
  metabolism TEXT CHECK(metabolism IN ('rapide', 'lent')),
  singleton INTEGER NOT NULL DEFAULT 1 UNIQUE
);
```

#### Table `user_equipment`
```sql
CREATE TABLE user_equipment (
  user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  equipment_id INTEGER NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, equipment_id)
);
CREATE INDEX idx_user_eq ON user_equipment(user_id);
```
Stocke le matériel que possède l'utilisateur.

#### Table `user_goal`
```sql
CREATE TABLE user_goal (
  user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  objective_id INTEGER NOT NULL REFERENCES objective(id) ON DELETE CASCADE,
  weight REAL NOT NULL,
  PRIMARY KEY (user_id, objective_id)
);
CREATE INDEX idx_user_goal ON user_goal(user_id);
```
- **weight** : Importance de l'objectif pour l'utilisateur (1.0 par défaut)

### 2.4 Tables de programme

#### Table `workout_program`
```sql
CREATE TABLE workout_program (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  objective_id INTEGER REFERENCES objective(id) ON DELETE SET NULL,
  level TEXT CHECK(level IN ('debutant', 'intermediaire', 'avance')),
  duration_weeks INTEGER
);
```
Un programme = collection de jours d'entraînement.

#### Table `program_day`
```sql
CREATE TABLE program_day (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  program_id INTEGER NOT NULL REFERENCES workout_program(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  day_order INTEGER NOT NULL
);
CREATE INDEX idx_prog_day ON program_day(program_id);
```
Ex: Jour 1 - Haut du corps, Jour 2 - Bas du corps, Jour 3 - Full Body

#### Table `program_day_exercise`
```sql
CREATE TABLE program_day_exercise (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  program_day_id INTEGER NOT NULL REFERENCES program_day(id) ON DELETE CASCADE,
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  modality_id INTEGER REFERENCES training_modality(id) ON DELETE SET NULL,
  sets_suggestion TEXT,
  reps_suggestion TEXT,
  rest_suggestion_sec INTEGER,
  notes TEXT
);
CREATE INDEX idx_prog_ex ON program_day_exercise(program_day_id);
```
Lie un exercice à un jour avec ses paramètres d'entraînement.

#### Table `user_program`
```sql
CREATE TABLE user_program (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  program_id INTEGER NOT NULL REFERENCES workout_program(id) ON DELETE CASCADE,
  start_date_ts INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX idx_user_prog ON user_program(user_id, is_active);
```
Associe un programme à un utilisateur. **is_active = 1** pour le programme actuel.

### 2.5 Tables de session (performances)

#### Table `session`
```sql
CREATE TABLE session (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  program_day_id INTEGER REFERENCES program_day(id) ON DELETE SET NULL,
  date_ts INTEGER NOT NULL,
  duration_min INTEGER
);
CREATE INDEX idx_sess_user ON session(user_id, date_ts);
```
- **program_day_id** : Lien vers le jour du programme (permet de marquer comme terminé)
- **date_ts** : Timestamp Unix (secondes)
- **duration_min** : NULL pendant la session, rempli à la fin

#### Table `session_exercise`
```sql
CREATE TABLE session_exercise (
  session_id INTEGER NOT NULL REFERENCES session(id) ON DELETE CASCADE,
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  sets INTEGER,
  reps INTEGER,
  load REAL,
  rpe REAL,
  PRIMARY KEY (session_id, exercise_id, position)
);
```
- **sets** : Nombre de séries effectuées
- **reps** : Nombre de répétitions
- **load** : Charge utilisée (kg)
- **rpe** : Rate of Perceived Exertion (1-10, ressenti d'effort)

#### Table `user_feedback`
```sql
CREATE TABLE user_feedback (
  user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  exercise_id INTEGER NOT NULL REFERENCES exercise(id) ON DELETE CASCADE,
  liked INTEGER NOT NULL,
  difficult INTEGER NOT NULL DEFAULT 0,
  pleasant INTEGER NOT NULL DEFAULT 0,
  useless INTEGER NOT NULL DEFAULT 0,
  ts INTEGER NOT NULL,
  PRIMARY KEY (user_id, exercise_id, ts)
);
CREATE INDEX idx_fb_user ON user_feedback(user_id, ts);
```
Feedbacks qualitatifs pour améliorer les recommandations futures.

---

## 3. Algorithme de recommandation

### 3.1 Principe de base

L'algorithme recommande des exercices en 3 étapes :
1. **Filtrage par équipement** : Ne garder que les exercices réalisables
2. **Scoring par affinité** : Calculer un score basé sur l'objectif
3. **Tri et sélection** : Retourner les meilleurs exercices

### 3.2 Requête SQL de recommandation (Version de base)

```sql
WITH user_eq AS (
  -- Étape 1 : Récupérer l'équipement de l'utilisateur
  SELECT equipment_id
  FROM user_equipment
  WHERE user_id = :uid
),
ex_ok_eq AS (
  -- Étape 2 : Filtrer les exercices compatibles avec l'équipement
  SELECT e.id
  FROM exercise e
  LEFT JOIN exercise_equipment ee ON ee.exercise_id = e.id
  LEFT JOIN user_eq ue ON ue.equipment_id = ee.equipment_id
  GROUP BY e.id
  HAVING COUNT(ee.equipment_id) = COUNT(ue.equipment_id)
),
ex_obj AS (
  -- Étape 3 : Récupérer les affinités exercice ↔ objectif
  SELECT eo.exercise_id, eo.weight AS obj_weight
  FROM exercise_objective eo
  WHERE eo.objective_id = :obj_id
)
-- Étape 4 : Joindre tout et retourner les résultats
SELECT
  e.id,
  e.name,
  e.type,
  e.difficulty,
  e.cardio,
  COALESCE(ex_obj.obj_weight, 0) AS objective_affinity
FROM exercise e
JOIN ex_ok_eq k ON k.id = e.id
LEFT JOIN ex_obj ON ex_obj.exercise_id = e.id
ORDER BY objective_affinity DESC, e.difficulty ASC
LIMIT :limit;
```

### 3.3 Explication détaillée du filtrage par équipement

**Problème** : Un exercice peut nécessiter plusieurs équipements.
- Ex: Développé couché = {Barre, Banc}

**Solution** : Vérifier que TOUS les équipements requis sont disponibles.

**Logique SQL** :
```sql
LEFT JOIN exercise_equipment ee ON ee.exercise_id = e.id
LEFT JOIN user_eq ue ON ue.equipment_id = ee.equipment_id
GROUP BY e.id
HAVING COUNT(ee.equipment_id) = COUNT(ue.equipment_id)
```

**Cas 1 : Exercice sans équipement (Pompes)**
- `exercise_equipment` vide pour cet exercice
- `COUNT(ee.equipment_id) = 0`
- `COUNT(ue.equipment_id) = 0`
- ✅ 0 = 0 → Exercice inclus

**Cas 2 : Exercice avec équipement disponible**
- Développé couché nécessite {Barre, Banc}
- Utilisateur a {Barre, Banc, Haltères}
- Pour chaque équipement requis, une ligne dans `user_eq` correspond
- `COUNT(ee.equipment_id) = 2`
- `COUNT(ue.equipment_id) = 2`
- ✅ 2 = 2 → Exercice inclus

**Cas 3 : Équipement manquant**
- Développé couché nécessite {Barre, Banc}
- Utilisateur a {Haltères}
- `COUNT(ee.equipment_id) = 2` (requis)
- `COUNT(ue.equipment_id) = 0` (disponible)
- ❌ 2 ≠ 0 → Exercice exclu

### 3.4 Calcul du score d'affinité

**Score de base** : `objective_affinity` (0.0 à 1.0)

**Exemple de valeurs** :
| Exercice | Hypertrophie | Force | Endurance | Perte de poids |
|----------|-------------|-------|-----------|----------------|
| Squat | 0.9 | 0.95 | 0.5 | 0.7 |
| Développé couché | 0.85 | 0.9 | 0.4 | 0.6 |
| Corde à sauter | 0.2 | 0.1 | 0.9 | 0.95 |
| Curl biceps | 0.6 | 0.4 | 0.3 | 0.4 |

**Facteurs d'ajustement** (dans le code Dart) :
```dart
double baseScore = objectiveAffinity;
double difficultyBonus = 1.0 - ((difficulty - 3).abs() / 5.0) * 0.2;
double finalScore = baseScore * difficultyBonus;
```

- Si difficulté = 3 (moyenne) → bonus = 1.0 (optimal)
- Si difficulté = 1 (facile) → bonus = 0.92
- Si difficulté = 5 (très dur) → bonus = 0.92

---

## 4. Génération de programme personnalisé

### 4.1 Vue d'ensemble

Un programme complet contient :
- 3-6 jours d'entraînement
- Chaque jour contient 6 exercices (4 poly + 2 iso)
- Chaque exercice a des suggestions (séries, reps, repos)

### 4.2 Étapes de génération

#### Étape 1 : Créer le programme

```sql
INSERT INTO workout_program (name, description, objective_id, level, duration_weeks)
VALUES (
  'Programme Hypertrophie',
  'Programme personnalisé pour hypertrophie',
  :objective_id,
  'intermediaire',
  4
);
-- Retourne program_id
```

#### Étape 2 : Générer les jours

```sql
-- Pour chaque jour (1 à 3)
INSERT INTO program_day (program_id, name, day_order)
VALUES (
  :program_id,
  'Jour 1 - Haut du corps',
  1
);
-- Retourne program_day_id
```

**Noms de jours générés** :
- Jour 1 : Haut du corps
- Jour 2 : Bas du corps
- Jour 3 : Full Body
- Jour 4 : Push (si 4+ jours)
- Jour 5 : Pull (si 5+ jours)
- Jour 6 : Legs (si 6+ jours)

#### Étape 3 : Récupérer et répartir les exercices

```dart
// 1. Récupérer 30 exercices recommandés
final allExercises = await getRecommendedExercises(
  userId: userId,
  specificObjectiveId: objectiveId,
  limit: 30,
);

// 2. Séparer par type
final polyExercises = exercises.where((e) => e.type == 'poly').toList();
final isoExercises = exercises.where((e) => e.type == 'iso').toList();

// 3. Pour chaque jour, sélectionner 6 exercices
//    - 4 poly (60-70% du volume)
//    - 2 iso (30-40% du volume)
```

**Rotation des exercices entre jours** :
```dart
// Jour 1 : poly[0-3], iso[0-1]
// Jour 2 : poly[4-7], iso[2-3]
// Jour 3 : poly[8-11], iso[4-5]
```

#### Étape 4 : Calculer les suggestions par exercice

**Formule basée sur le niveau** :

| Niveau | Poly (séries × reps) | Repos | Iso (séries × reps) | Repos |
|--------|---------------------|-------|---------------------|-------|
| Débutant | 3 × 8-10 | 90s | 2 × 10-12 | 60s |
| Intermédiaire | 4 × 8-12 | 90s | 3 × 10-15 | 60s |
| Avancé | 4 × 6-10 | 120s | 3 × 12-15 | 60s |

```dart
Map<String, dynamic> _getSuggestionsForExercise({
  required RecommendedExercise exercise,
  required String userLevel,
  required int position,
}) {
  int sets;
  String reps;
  int rest;

  if (exercise.type == 'poly') {
    switch (userLevel) {
      case 'debutant':
        sets = 3; reps = '8-10'; rest = 90;
        break;
      case 'intermediaire':
        sets = 4; reps = '8-12'; rest = 90;
        break;
      case 'avance':
        sets = 4; reps = '6-10'; rest = 120;
        break;
    }
  } else { // iso
    switch (userLevel) {
      case 'debutant':
        sets = 2; reps = '10-12'; rest = 60;
        break;
      case 'intermediaire':
        sets = 3; reps = '10-15'; rest = 60;
        break;
      case 'avance':
        sets = 3; reps = '12-15'; rest = 60;
        break;
    }
  }

  return {
    'sets': '$sets séries',
    'reps': '$reps reps',
    'rest': rest,
  };
}
```

#### Étape 5 : Insérer les exercices

```sql
INSERT INTO program_day_exercise (
  program_day_id,
  exercise_id,
  position,
  modality_id,
  sets_suggestion,
  reps_suggestion,
  rest_suggestion_sec,
  notes
) VALUES (
  :program_day_id,
  :exercise_id,
  :position,
  :modality_id,
  '4 séries',
  '8-12 reps',
  90,
  'Exercice principal - charge maximale'
);
```

#### Étape 6 : Lier le programme à l'utilisateur

```sql
INSERT INTO user_program (user_id, program_id, start_date_ts, is_active)
VALUES (:user_id, :program_id, :current_timestamp, 1);
```

### 4.3 Exemple de programme généré

**Programme : Hypertrophie (Niveau intermédiaire)**

**Jour 1 - Haut du corps**
| # | Exercice | Type | Séries | Reps | Repos |
|---|----------|------|--------|------|-------|
| 1 | Développé couché | poly | 4 | 8-12 | 90s |
| 2 | Rowing barre | poly | 4 | 8-12 | 90s |
| 3 | Développé militaire | poly | 4 | 8-12 | 90s |
| 4 | Tractions | poly | 4 | 8-12 | 90s |
| 5 | Curl biceps | iso | 3 | 10-15 | 60s |
| 6 | Extension triceps | iso | 3 | 10-15 | 60s |

**Jour 2 - Bas du corps**
| # | Exercice | Type | Séries | Reps | Repos |
|---|----------|------|--------|------|-------|
| 1 | Squat | poly | 4 | 8-12 | 90s |
| 2 | Soulevé de terre | poly | 4 | 8-12 | 90s |
| 3 | Fentes | poly | 4 | 8-12 | 90s |
| 4 | Leg press | poly | 4 | 8-12 | 90s |
| 5 | Leg curl | iso | 3 | 10-15 | 60s |
| 6 | Mollets | iso | 3 | 10-15 | 60s |

---

## 5. Système de tracking des sessions

### 5.1 Cycle de vie d'une session

```
1. [START] Utilisateur clique "Commencer" sur un jour
   ↓
2. [CREATE SESSION] Création dans la table session
   ↓
3. [LOAD EXERCISES] Chargement des exercices du jour
   ↓
4. [DO EXERCISES] Pour chaque exercice :
   - Affichage des suggestions
   - Saisie des performances réelles
   - Enregistrement dans session_exercise
   ↓
5. [COMPLETE] Calcul de la durée, finalisation
   ↓
6. [MARK DONE] Le jour est marqué comme terminé
```

### 5.2 Création de session

**Requête SQL** :
```sql
INSERT INTO session (user_id, program_day_id, date_ts, duration_min)
VALUES (:user_id, :program_day_id, :current_timestamp, NULL);
-- Retourne session_id
```

- **program_day_id** : ESSENTIEL pour lier la session au jour du programme
- **date_ts** : Timestamp Unix actuel (ex: 1700000000)
- **duration_min** : NULL tant que la session n'est pas terminée

### 5.3 Chargement des exercices du jour

**Requête SQL** :
```sql
SELECT
  pde.exercise_id,
  e.name,
  e.type,
  e.difficulty,
  pde.position,
  pde.sets_suggestion,
  pde.reps_suggestion,
  pde.rest_suggestion_sec
FROM program_day_exercise pde
JOIN exercise e ON e.id = pde.exercise_id
WHERE pde.program_day_id = :program_day_id
ORDER BY pde.position ASC;
```

**Exemple de résultat** :
```
exercise_id | name              | type | difficulty | sets_suggestion | reps_suggestion | rest
------------|-------------------|------|------------|-----------------|-----------------|-----
45          | Développé couché  | poly | 3          | 4 séries        | 8-12 reps       | 90
67          | Rowing barre      | poly | 4          | 4 séries        | 8-12 reps       | 90
23          | Curl biceps       | iso  | 2          | 3 séries        | 10-15 reps      | 60
```

### 5.4 Enregistrement des performances

**Pour chaque exercice complété** :

```sql
INSERT INTO session_exercise (
  session_id,
  exercise_id,
  position,
  sets,
  reps,
  load,
  rpe
) VALUES (
  :session_id,
  :exercise_id,
  :position,
  :actual_sets,      -- Ex: 4
  :actual_reps,      -- Ex: 10
  :actual_load,      -- Ex: 80.0 (kg)
  :actual_rpe        -- Ex: 7.5 (sur 10)
);
```

**Mode INSERT OR REPLACE** : Permet de modifier une performance déjà enregistrée.

### 5.5 Finalisation de la session

**Calcul de la durée** :
```dart
final now = DateTime.now();
final durationMin = now.difference(startTime).inMinutes;
```

**Mise à jour de la session** :
```sql
UPDATE session
SET duration_min = :duration_min
WHERE id = :session_id;
```

**Une fois `duration_min` rempli, la session est considérée comme TERMINÉE**.

### 5.6 Vérification si un jour est terminé

**Requête SQL** :
```sql
SELECT id, date_ts, duration_min
FROM session
WHERE program_day_id = :program_day_id
  AND duration_min IS NOT NULL
ORDER BY date_ts DESC
LIMIT 1;
```

**Résultat** :
- **Vide** : Jour jamais fait
- **1 ligne** : Jour complété, retourne la session la plus récente

### 5.7 Récupération de l'état de tous les jours

**Requête optimisée pour charger les états de plusieurs jours** :

```sql
SELECT
  s.program_day_id,
  s.id,
  s.date_ts,
  s.duration_min
FROM session s
WHERE s.program_day_id IN (:day_id_1, :day_id_2, :day_id_3)
  AND s.duration_min IS NOT NULL
ORDER BY s.program_day_id ASC, s.date_ts DESC;
```

**Post-traitement Dart** :
```dart
// Créer une Map avec la session la plus récente par jour
final Map<int, SessionData> result = {};
for (final session in sessions) {
  final dayId = session.programDayId;
  if (dayId != null && !result.containsKey(dayId)) {
    result[dayId] = session; // Première occurrence = plus récente
  }
}
```

---

## 6. Flux complet utilisateur

### 6.1 Inscription et configuration initiale

```
ÉTAPE 1 : Informations personnelles
├─ Prénom, nom, date de naissance
├─ Poids, taille, genre
└─ Niveau (débutant/intermédiaire/avancé)

ÉTAPE 2 : Sélection des objectifs
├─ Affichage de tous les objectifs (table objective)
├─ Sélection multiple
└─ INSERT INTO user_goal (user_id, objective_id, weight) VALUES ...

ÉTAPE 3 : Sélection de l'équipement
├─ Affichage de tous les équipements (table equipment)
├─ Sélection multiple
└─ INSERT INTO user_equipment (user_id, equipment_id) VALUES ...

ÉTAPE 4 : Génération automatique du programme
├─ Récupération de l'objectif principal (weight le plus élevé)
├─ Génération de 3 jours d'entraînement
└─ INSERT INTO workout_program, program_day, program_day_exercise
```

### 6.2 Consultation du programme

```
PAGE : Mon Programme

┌─────────────────────────────────────────┐
│ Programme Hypertrophie                  │
│ Programme personnalisé pour...          │
│                          [🔄 Régénérer]  │
├─────────────────────────────────────────┤
│ [Jour 1] [Jour 2 ✓] [Jour 3]          │ ← Sélecteur horizontal
├─────────────────────────────────────────┤
│ Jour 1 - Haut du corps    [Commencer]  │
│ 6 exercices                             │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 1 │ Développé couché        POLY   │ │
│ │   │ 4 séries × 8-12 reps   🕐 90s │ │
│ │   │ ⭐ Affinité: 85%               │ │
│ └─────────────────────────────────────┘ │
│ ... (5 autres exercices)                │
└─────────────────────────────────────────┘
```

**Requêtes exécutées** :
1. Récupérer le programme actif de l'utilisateur
2. Récupérer les jours du programme
3. Pour chaque jour, récupérer ses exercices
4. Vérifier l'état de complétion de chaque jour

### 6.3 Exécution d'une session

```
CLIC SUR "Commencer"
   ↓
[Page Active Session]

┌─────────────────────────────────────────┐
│ Jour 1 - Haut du corps       ⏱️ 0:34   │
├─────────────────────────────────────────┤
│ Progression: 2/6 exercices   ████░░    │
├─────────────────────────────────────────┤
│                                         │
│ ✓ 1. Développé couché                  │
│      4 séries × 10 reps @ 80kg         │
│      RPE: 7.5                           │
│                                         │
│ ✓ 2. Rowing barre                      │
│      4 séries × 12 reps @ 70kg         │
│      RPE: 8.0                           │
│                                         │
│ → 3. Développé militaire      [Faire]  │ ← En cours
│      Suggéré: 4 séries × 8-12 reps     │
│                                         │
│ ○ 4. Tractions                [Faire]  │
│ ○ 5. Curl biceps              [Faire]  │
│ ○ 6. Extension triceps        [Faire]  │
│                                         │
├─────────────────────────────────────────┤
│           [Terminer la séance]          │
└─────────────────────────────────────────┘
```

### 6.4 Dialogue de saisie des performances

```
CLIC SUR "Faire" (Exercice 3)
   ↓
[Dialog Modal]

┌─────────────────────────────────────────┐
│ Développé militaire                     │
│ Suggéré: 4 séries × 8-12 reps          │
│                                         │
│ 💡 Historique                           │ ← Pré-remplissage intelligent
│ Dernières fois: 4 séries × 10 reps     │
│ @ 45.0 kg                               │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🔁 Nombre de séries                 │ │
│ │ [        4        ]                 │ │ ← Pré-rempli
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 🏋️ Nombre de répétitions            │ │
│ │ [       10        ]                 │ │ ← Pré-rempli
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ ⚖️ Charge (kg)                       │ │
│ │ [      45.0       ]                 │ │ ← Pré-rempli
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 💪 RPE (Ressenti d'effort)          │ │
│ │ 1────────●──────────10               │ │ ← Slider à 7.0
│ │                    7.5               │ │
│ └─────────────────────────────────────┘ │
│                                         │
│        [Annuler]      [Valider]         │
└─────────────────────────────────────────┘
```

**Requête d'analyse historique** (exécutée au chargement du dialogue) :
```sql
SELECT se.sets, se.reps, se.load, se.rpe, s.date_ts
FROM session_exercise se
JOIN session s ON s.id = se.session_id
WHERE s.user_id = :user_id
  AND se.exercise_id = :exercise_id
ORDER BY s.date_ts DESC
LIMIT 5;
```

**Calcul des moyennes** :
```dart
double totalSets = 0, totalReps = 0, totalLoad = 0, totalRpe = 0;
int count = results.length;

for (final row in results) {
  totalSets += row['sets'];
  totalReps += row['reps'];
  totalLoad += row['load'];
  totalRpe += row['rpe'];
}

final avgSets = totalSets / count;  // Ex: 4.0
final avgReps = totalReps / count;  // Ex: 10.2
final avgLoad = totalLoad / count;  // Ex: 44.5
final avgRpe = totalRpe / count;    // Ex: 7.3
```

### 6.5 Finalisation de la session

```
CLIC SUR "Terminer la séance"
   ↓
VÉRIFICATION : Tous les exercices complétés ?
   ├─ OUI → Finaliser directement
   └─ NON → Demander confirmation
      ↓
   [Dialog]
   ┌───────────────────────────────────┐
   │ Séance incomplète                 │
   │                                   │
   │ Tu n'as pas complété tous les     │
   │ exercices. Veux-tu quand même     │
   │ terminer la séance ?              │
   │                                   │
   │  [Continuer]      [Terminer]      │
   └───────────────────────────────────┘
      ↓
CALCUL DE LA DURÉE
   now = DateTime.now()
   duration = now - startTime
   ↓
UPDATE session SET duration_min = :duration WHERE id = :session_id
   ↓
RETOUR À LA PAGE PROGRAMME
   ↓
RECHARGEMENT DES ÉTATS
   ↓
[Jour 1 devient VERT avec ✓]
```

### 6.6 État visuel après complétion

```
PAGE : Mon Programme (après session)

┌─────────────────────────────────────────┐
│ Programme Hypertrophie                  │
├─────────────────────────────────────────┤
│ [Jour 1 ✓] [Jour 2] [Jour 3]          │ ← Jour 1 en VERT
├─────────────────────────────────────────┤
│ Jour 1 - Haut du corps                  │
│ Terminée le aujourd'hui (45 min)        │ ← Infos de la session
│                         [Terminée]      │ ← Bouton GRISÉ
│ 6 exercices                             │
│                                         │
│ ... (liste des exercices)               │
└─────────────────────────────────────────┘
```

**Bouton désactivé** :
```dart
ElevatedButton.icon(
  onPressed: isCompleted ? null : () => _startSession(currentDay),
  icon: Icon(isCompleted ? Icons.check_circle : Icons.play_arrow),
  label: Text(isCompleted ? 'Terminée' : 'Commencer'),
  style: ElevatedButton.styleFrom(
    backgroundColor: isCompleted ? Colors.grey : AppTheme.gold,
  ),
)
```

---

## 7. Requêtes SQL détaillées

### 7.1 Recommandation d'exercices

```sql
-- Requête complète de recommandation
-- Paramètres : :uid (user_id), :obj_id (objective_id), :limit (nombre max)

WITH user_eq AS (
  -- CTE 1 : Équipement de l'utilisateur
  SELECT equipment_id FROM user_equipment WHERE user_id = :uid
),
ex_ok_eq AS (
  -- CTE 2 : Exercices compatibles avec l'équipement
  SELECT e.id
  FROM exercise e
  LEFT JOIN exercise_equipment ee ON ee.exercise_id = e.id
  LEFT JOIN user_eq ue ON ue.equipment_id = ee.equipment_id
  GROUP BY e.id
  -- Si l'exercice nécessite N équipements, l'utilisateur doit TOUS les avoir
  HAVING COUNT(ee.equipment_id) = COUNT(ue.equipment_id)
),
ex_obj AS (
  -- CTE 3 : Affinités exercice ↔ objectif
  SELECT eo.exercise_id, eo.weight AS obj_weight
  FROM exercise_objective eo
  WHERE eo.objective_id = :obj_id
)
-- Requête finale : Joindre tout et trier
SELECT
  e.id,
  e.name,
  e.type,                                        -- 'poly' ou 'iso'
  e.difficulty,                                  -- 1-5
  e.cardio,                                      -- 0.0-1.0
  COALESCE(ex_obj.obj_weight, 0) AS objective_affinity  -- 0.0-1.0
FROM exercise e
INNER JOIN ex_ok_eq k ON k.id = e.id           -- Filtrage équipement
LEFT JOIN ex_obj ON ex_obj.exercise_id = e.id  -- Ajout affinité
ORDER BY objective_affinity DESC, e.difficulty ASC
LIMIT :limit;
```

**Exemple de résultat** (objectif = Hypertrophie, user a {Haltères, Barre}) :
```
id  | name                 | type | difficulty | cardio | objective_affinity
----|----------------------|------|------------|--------|-------------------
45  | Développé couché     | poly | 3          | 0.1    | 0.85
67  | Rowing barre         | poly | 4          | 0.2    | 0.75
23  | Squat               | poly | 5          | 0.3    | 0.90
89  | Curl biceps         | iso  | 2          | 0.0    | 0.60
12  | Extension triceps   | iso  | 2          | 0.0    | 0.55
```

### 7.2 Génération de programme

```sql
-- 1. Créer le programme principal
INSERT INTO workout_program (name, description, objective_id, level, duration_weeks)
VALUES (
  'Programme Hypertrophie',
  'Programme personnalisé pour hypertrophie',
  2,  -- ID de l'objectif hypertrophie
  'intermediaire',
  4
)
RETURNING id;  -- Retourne program_id

-- 2. Créer les jours (boucle pour 3 jours)
INSERT INTO program_day (program_id, name, day_order)
VALUES
  (1, 'Jour 1 - Haut du corps', 1),
  (1, 'Jour 2 - Bas du corps', 2),
  (1, 'Jour 3 - Full Body', 3)
RETURNING id;  -- Retourne program_day_id pour chaque ligne

-- 3. Ajouter les exercices à chaque jour (boucle pour 6 exercices × 3 jours = 18 insertions)
INSERT INTO program_day_exercise (
  program_day_id,
  exercise_id,
  position,
  sets_suggestion,
  reps_suggestion,
  rest_suggestion_sec,
  notes
) VALUES
  -- Jour 1, Exercice 1
  (1, 45, 1, '4 séries', '8-12 reps', 90, 'Exercice principal - charge maximale'),
  -- Jour 1, Exercice 2
  (1, 67, 2, '4 séries', '8-12 reps', 90, NULL),
  -- ... (16 autres lignes)
;

-- 4. Lier le programme à l'utilisateur
INSERT INTO user_program (user_id, program_id, start_date_ts, is_active)
VALUES (1, 1, 1700000000, 1);
```

### 7.3 Récupération d'un programme avec tous ses détails

```sql
-- Requête pour récupérer un programme complet
SELECT
  wp.id AS program_id,
  wp.name AS program_name,
  wp.description,
  wp.level,
  pd.id AS day_id,
  pd.name AS day_name,
  pd.day_order,
  pde.id AS day_exercise_id,
  pde.exercise_id,
  e.name AS exercise_name,
  e.type,
  e.difficulty,
  pde.position,
  pde.sets_suggestion,
  pde.reps_suggestion,
  pde.rest_suggestion_sec
FROM workout_program wp
JOIN program_day pd ON pd.program_id = wp.id
JOIN program_day_exercise pde ON pde.program_day_id = pd.id
JOIN exercise e ON e.id = pde.exercise_id
WHERE wp.id = :program_id
ORDER BY pd.day_order ASC, pde.position ASC;
```

**Résultat** (extrait) :
```
program_id | day_id | day_name            | exercise_name         | position | sets      | reps      | rest
-----------|--------|---------------------|-----------------------|----------|-----------|-----------|-----
1          | 1      | Jour 1 - Haut corps | Développé couché      | 1        | 4 séries  | 8-12 reps | 90
1          | 1      | Jour 1 - Haut corps | Rowing barre          | 2        | 4 séries  | 8-12 reps | 90
1          | 1      | Jour 1 - Haut corps | Curl biceps           | 5        | 3 séries  | 10-15 reps| 60
1          | 2      | Jour 2 - Bas corps  | Squat                 | 1        | 4 séries  | 8-12 reps | 90
```

### 7.4 Création et gestion de session

```sql
-- 1. Créer une nouvelle session
INSERT INTO session (user_id, program_day_id, date_ts, duration_min)
VALUES (1, 1, 1700000000, NULL)
RETURNING id;  -- Retourne session_id

-- 2. Enregistrer les performances d'un exercice
INSERT INTO session_exercise (session_id, exercise_id, position, sets, reps, load, rpe)
VALUES (1, 45, 1, 4, 10, 80.0, 7.5);

-- 3. Finaliser la session (calculer la durée)
UPDATE session
SET duration_min = 45
WHERE id = 1;

-- 4. Vérifier si un jour est terminé
SELECT id, date_ts, duration_min
FROM session
WHERE program_day_id = 1
  AND duration_min IS NOT NULL
ORDER BY date_ts DESC
LIMIT 1;
-- Résultat vide = jour jamais fait
-- 1 ligne = jour terminé

-- 5. Récupérer l'historique des sessions d'un utilisateur
SELECT
  s.id,
  s.date_ts,
  s.duration_min,
  pd.name AS day_name,
  COUNT(se.exercise_id) AS exercises_count
FROM session s
LEFT JOIN program_day pd ON pd.id = s.program_day_id
LEFT JOIN session_exercise se ON se.session_id = s.id
WHERE s.user_id = 1
  AND s.duration_min IS NOT NULL
GROUP BY s.id
ORDER BY s.date_ts DESC;
```

### 7.5 Analyse des performances

```sql
-- Récupérer les 5 dernières sessions pour un exercice spécifique
SELECT
  se.sets,
  se.reps,
  se.load,
  se.rpe,
  se.position,
  s.date_ts
FROM session_exercise se
JOIN session s ON s.id = se.session_id
WHERE s.user_id = :user_id
  AND se.exercise_id = :exercise_id
ORDER BY s.date_ts DESC
LIMIT 5;
```

**Exemple de résultat** (exercice = Développé couché) :
```
date_ts    | sets | reps | load | rpe
-----------|------|------|------|-----
1700050000 | 4    | 10   | 82.5 | 8.0   ← Session la plus récente
1699800000 | 4    | 10   | 80.0 | 7.5
1699550000 | 4    | 11   | 77.5 | 7.0
1699300000 | 4    | 12   | 75.0 | 6.5
1699050000 | 3    | 12   | 75.0 | 6.0
```

**Analyse des tendances** (dans le code Dart) :
```dart
// Progression de la charge
final firstLoad = results.last['load'];  // 75.0
final lastLoad = results.first['load'];  // 82.5

if (lastLoad > firstLoad * 1.1) {
  trend = 'improving';  // +10% → progression
} else if (lastLoad < firstLoad * 0.9) {
  trend = 'declining';  // -10% → régression
} else {
  trend = 'neutral';    // stable
}

// RPE moyen
final avgRpe = totalRpe / count;  // 7.0

// Recommandations
if (avgRpe > 8.5) {
  return 'Trop difficile - réduis la charge de 10%';
} else if (avgRpe < 6.5 && trend == 'improving') {
  return 'Tu progresses - augmente de 5%';
}
```

### 7.6 Récupération de l'état de tous les jours d'un programme

```sql
-- Requête optimisée pour charger toutes les sessions des jours en une fois
SELECT
  s.program_day_id,
  s.id,
  s.date_ts,
  s.duration_min,
  s.user_id
FROM session s
WHERE s.program_day_id IN (1, 2, 3)  -- IDs des jours du programme
  AND s.duration_min IS NOT NULL     -- Uniquement les sessions terminées
ORDER BY s.program_day_id ASC, s.date_ts DESC;
```

**Exemple de résultat** :
```
program_day_id | session_id | date_ts    | duration_min
---------------|------------|------------|-------------
1              | 5          | 1700060000 | 45          ← Jour 1 : terminé
1              | 2          | 1699800000 | 42          ← Ancienne session du jour 1
2              | 7          | 1700070000 | 38          ← Jour 2 : terminé
-- Jour 3 absent → pas encore fait
```

**Post-traitement** (garder seulement la session la plus récente par jour) :
```dart
final Map<int, SessionData> result = {};
for (final session in sessions) {
  final dayId = session.programDayId;
  // On garde seulement la première occurrence (la plus récente)
  if (dayId != null && !result.containsKey(dayId)) {
    result[dayId] = session;
  }
}
// Résultat : {1: session_5, 2: session_7}
```

---

## 8. Architecture du code

### 8.1 Structure des services

```
lib/services/
├── recommendation_service.dart
│   ├── getRecommendedExercises()     → Filtre et recommande
│   ├── generateWorkoutSession()      → Génère une session équilibrée
│   └── getUserObjectives()           → Récupère les objectifs
│
├── program_generator_service.dart
│   ├── generateUserProgram()         → Crée un programme complet
│   ├── getProgramDays()              → Récupère les jours
│   ├── _generateProgramDays()        → Génère les jours
│   ├── _getSuggestionsForExercise()  → Calcule les suggestions
│   └── regenerateUserProgram()       → Régénère un nouveau programme
│
└── session_tracking_service.dart
    ├── startSession()                → Crée une session
    ├── getSessionExercises()         → Charge les exercices du jour
    ├── saveExercisePerformance()     → Enregistre une performance
    ├── completeSession()             → Finalise la session
    ├── isDayCompleted()              → Vérifie si un jour est terminé
    ├── getCompletedSessionsForDays() → État de plusieurs jours
    ├── analyzePerformance()          → Analyse l'historique
    └── getSuggestedAdjustments()     → Suggère des ajustements
```

### 8.2 Flux de données (Recommandation → Programme → Session)

```
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 1 : INSCRIPTION                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    [user_goal créé]
                    [user_equipment créé]
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              PHASE 2 : GÉNÉRATION DE PROGRAMME              │
└─────────────────────────────────────────────────────────────┘
                              │
      ┌───────────────────────┴───────────────────────┐
      ▼                                               ▼
[RecommendationService]                    [ProgramGeneratorService]
getRecommendedExercises()                   generateUserProgram()
      │                                               │
      │ Exécute requête SQL de filtrage              │
      │ (équipement + affinité)                      │
      │                                               │
      └─────────────────┬─────────────────────────────┘
                        ▼
          [Liste de 30 exercices recommandés]
                        │
                        ▼
        ┌───────────────┴───────────────┐
        │   Répartition intelligente    │
        │   • 4 poly + 2 iso par jour   │
        │   • Rotation entre jours      │
        │   • Calcul des suggestions    │
        └───────────────┬───────────────┘
                        ▼
                [workout_program]
                [program_day × 3]
                [program_day_exercise × 18]
                [user_program]
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 3 : EXÉCUTION SESSION                 │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
            [Utilisateur clique "Commencer"]
                        │
                        ▼
          [SessionTrackingService.startSession()]
                        │
                        ▼
                  [session créée]
              program_day_id = X
              date_ts = now
              duration_min = NULL
                        │
                        ▼
    [SessionTrackingService.getSessionExercises()]
                        │
                        ▼
        [Chargement des 6 exercices du jour]
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
  [Exercice 1]                    [Exercice 6]
  Suggéré: 4×10                   Suggéré: 3×12
        │                               │
        ▼                               ▼
  [User saisit]                   [User saisit]
  Réel: 4×10 @ 80kg              Réel: 3×15 @ 20kg
  RPE: 7.5                        RPE: 6.0
        │                               │
        └───────────────┬───────────────┘
                        ▼
    [SessionTrackingService.saveExercisePerformance()]
                        │
                        ▼
          [session_exercise × 6 créés]
                        │
                        ▼
  [SessionTrackingService.completeSession()]
                        │
                        ▼
        [session.duration_min = 45]
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              PHASE 4 : ANALYSE & ADAPTATION                 │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
   [SessionTrackingService.analyzePerformance()]
                        │
                        ▼
    [Récupération des 5 dernières sessions]
                        │
                        ▼
          [Calcul des moyennes et tendances]
          • Charge moyenne : 78kg
          • RPE moyen : 7.2
          • Tendance : improving
                        │
                        ▼
  [SessionTrackingService.getSuggestedAdjustments()]
                        │
                        ▼
        [Recommandation: "Augmente de 5%"]
                        │
                        ▼
    [Prochaine session: pré-remplissage à 82kg]
```

### 8.3 Modèles de données Dart

```dart
// Exercice recommandé (résultat de l'algo)
class RecommendedExercise {
  final int id;
  final String name;
  final String type;              // 'poly' ou 'iso'
  final int difficulty;           // 1-5
  final double cardio;            // 0.0-1.0
  final double objectiveAffinity; // 0.0-1.0

  double get score {
    double baseScore = objectiveAffinity;
    double difficultyBonus = 1.0 - ((difficulty - 3).abs() / 5.0) * 0.2;
    return baseScore * difficultyBonus;
  }
}

// Jour de programme avec exercices
class ProgramDaySession {
  final int programDayId;         // Pour tracker la complétion
  final int dayOrder;             // 1, 2, 3...
  final String dayName;           // "Jour 1 - Haut du corps"
  final List<ProgramExerciseDetail> exercises;
}

// Détail d'un exercice dans le programme
class ProgramExerciseDetail {
  final int exerciseId;
  final String exerciseName;
  final String exerciseType;
  final int difficulty;
  final int position;             // 1-6
  final String? setsSuggestion;   // "4 séries"
  final String? repsSuggestion;   // "8-12 reps"
  final int? restSuggestionSec;   // 90
  final TrainingModalityData? modality;
}

// Exercice en cours de session
class ActiveSessionExercise {
  final int exerciseId;
  final String exerciseName;
  final int position;

  // Suggestions
  final String? setsSuggestion;
  final String? repsSuggestion;
  final int? restSuggestionSec;

  // Performances réelles
  int? actualSets;
  int? actualReps;
  double? actualLoad;
  double? actualRpe;
  bool isCompleted;
}
```

---

## 9. Exemples de données complètes

### 9.1 Exemple d'utilisateur complet

**Table app_user**
```
id | prenom | nom    | weight | height | gender | level         | metabolism
---|--------|--------|--------|--------|--------|---------------|------------
1  | Jean   | Dupont | 75.0   | 180.0  | homme  | intermediaire | rapide
```

**Table user_equipment** (Jean possède)
```
user_id | equipment_id | equipment_name
--------|--------------|---------------
1       | 1            | Haltères
1       | 2            | Barre
1       | 3            | Banc
1       | 5            | Élastiques
```

**Table user_goal** (Objectifs de Jean)
```
user_id | objective_id | objective_name | weight
--------|--------------|----------------|-------
1       | 2            | Hypertrophie   | 1.0
1       | 4            | Force          | 0.5
```

### 9.2 Exemple de programme généré

**Table workout_program**
```
id | name                     | description                      | objective_id | level         | duration_weeks
---|--------------------------|----------------------------------|--------------|---------------|---------------
1  | Programme Hypertrophie   | Programme personnalisé pour...   | 2            | intermediaire | 4
```

**Table program_day**
```
id | program_id | name                   | day_order
---|------------|------------------------|----------
1  | 1          | Jour 1 - Haut du corps | 1
2  | 1          | Jour 2 - Bas du corps  | 2
3  | 1          | Jour 3 - Full Body     | 3
```

**Table program_day_exercise** (extrait Jour 1)
```
id | program_day_id | exercise_id | exercise_name         | position | sets_suggestion | reps_suggestion | rest_suggestion_sec
---|----------------|-------------|-----------------------|----------|-----------------|-----------------|--------------------
1  | 1              | 45          | Développé couché      | 1        | 4 séries        | 8-12 reps       | 90
2  | 1              | 67          | Rowing barre          | 2        | 4 séries        | 8-12 reps       | 90
3  | 1              | 89          | Développé militaire   | 3        | 4 séries        | 8-12 reps       | 90
4  | 1              | 23          | Tractions             | 4        | 4 séries        | 8-12 reps       | 90
5  | 1              | 56          | Curl biceps           | 5        | 3 séries        | 10-15 reps      | 60
6  | 1              | 78          | Extension triceps     | 6        | 3 séries        | 10-15 reps      | 60
```

### 9.3 Exemple de session complète

**Table session**
```
id | user_id | program_day_id | date_ts    | duration_min
---|---------|----------------|------------|-------------
1  | 1       | 1              | 1700000000 | 45
```

**Table session_exercise**
```
session_id | exercise_id | exercise_name        | position | sets | reps | load | rpe
-----------|-------------|----------------------|----------|------|------|------|-----
1          | 45          | Développé couché     | 1        | 4    | 10   | 80.0 | 7.5
1          | 67          | Rowing barre         | 2        | 4    | 12   | 70.0 | 8.0
1          | 89          | Développé militaire  | 3        | 4    | 10   | 45.0 | 7.0
1          | 23          | Tractions            | 4        | 4    | 8    | 0.0  | 8.5
1          | 56          | Curl biceps          | 5        | 3    | 12   | 15.0 | 6.5
1          | 78          | Extension triceps    | 6        | 3    | 15   | 20.0 | 6.0
```

### 9.4 Historique de progression (Développé couché)

```
date       | session_id | sets | reps | load | rpe | notes
-----------|------------|------|------|------|-----|---------------------------
2023-11-15 | 1          | 4    | 10   | 80.0 | 7.5 | Première fois
2023-11-18 | 5          | 4    | 10   | 82.5 | 7.5 | Augmentation de 2.5kg
2023-11-21 | 9          | 4    | 11   | 82.5 | 7.0 | Progression en reps
2023-11-24 | 13         | 4    | 10   | 85.0 | 8.0 | Nouvelle augmentation
2023-11-27 | 17         | 4    | 10   | 87.5 | 8.0 | Charge en augmentation
```

**Analyse** :
- Progression constante (+7.5kg en 12 jours)
- RPE stable (7.0-8.0) → bon équilibre
- Tendance : **improving**
- Recommandation : "Tu progresses bien - continue comme ça !"

---

## Conclusion

Ce système complet permet :

✅ **Recommandations personnalisées** basées sur objectifs et équipement
✅ **Programmes structurés** avec suggestions adaptées au niveau
✅ **Tracking précis** des performances réelles
✅ **Analyse intelligente** de la progression
✅ **Adaptation dynamique** des recommandations futures

**Tous les composants sont interconnectés** :
- La recommandation alimente la génération de programme
- Le programme guide les sessions
- Les sessions alimentent l'analyse
- L'analyse améliore les futures recommandations

**Base pour évolutions futures** :
- Ajustement automatique des charges basé sur RPE
- Détection de surmenage (RPE trop élevé)
- Suggestions de décharge (RPE bas → augmenter)
- Variation automatique des exercices
- Programmes progressifs multi-semaines
