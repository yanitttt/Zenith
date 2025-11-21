// lib/data/db/app_db.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

/// ---------- Ouverture DB (copie depuis assets si nécessaire) ----------
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'BDD_V3.db'));

    if (!await file.exists()) {
      final data = await rootBundle.load('assets/db/BDD_V3.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}

/* ===================== Converters (fromSql/toSql) ===================== */

/// Convertisseur texte ↔ texte avec liste fermée de valeurs autorisées.
/// Non-nullable. Utiliser la version null-aware pour les colonnes NULL.
class EnumTextConverter extends TypeConverter<String, String> {
  final List<String> allowed;
  const EnumTextConverter(this.allowed);

  @override
  String fromSql(String fromDb) {
    if (!allowed.contains(fromDb)) {
      throw ArgumentError('Valeur "$fromDb" hors domaine autorisé: $allowed');
    }
    return fromDb;
  }

  @override
  String toSql(String value) {
    if (!allowed.contains(value)) {
      throw ArgumentError('Valeur "$value" hors domaine autorisé: $allowed');
    }
    return value;
  }
}

/// Converter tolérant pour gender: accepte male/female, m/f, etc., et normalise.
class GenderConverter extends TypeConverter<String, String> {
  const GenderConverter();

  static const _allowed = {'homme', 'femme'};

  static const _aliases = {
    'male': 'homme',
    'm': 'homme',
    'man': 'homme',
    'masculin': 'homme',
    'female': 'femme',
    'f': 'femme',
    'woman': 'femme',
    'feminin': 'femme',
  };

  String _normalize(String v) {
    final x = v.trim().toLowerCase();
    if (_allowed.contains(x)) return x;
    final mapped = _aliases[x];
    if (mapped != null) return mapped;
    throw ArgumentError('Valeur "$v" hors domaine autorisé: $_allowed');
  }

  @override
  String fromSql(String fromDb) => _normalize(fromDb);

  @override
  String toSql(String value) => _normalize(value);
}


// Instances réutilisables
const _convType         = EnumTextConverter(['poly', 'iso']);
const _convLevel        = EnumTextConverter(['debutant', 'intermediaire', 'avance']);
// Nouveau converter pour gender (mêmes valeurs que sex avant)
const _convGender = GenderConverter();
const _nullableGender = NullAwareTypeConverter.wrap(_convGender);

const _convMetabolism   = EnumTextConverter(['rapide', 'lent']);
const _convRelationType = EnumTextConverter(['variation', 'substitute', 'progression', 'regression']);

// Wrappers null-aware (pour colonnes NULL)
const _nullableLevel      = NullAwareTypeConverter.wrap(_convLevel);

const _nullableMetabolism = NullAwareTypeConverter.wrap(_convMetabolism);

/* ===================== TABLES — PARTIE 1 : CATALOGUE ===================== */

class Exercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('name')();
  TextColumn get type => text().named('type').map(_convType)(); // 'poly'|'iso'
  IntColumn get difficulty => integer().named('difficulty').check(difficulty.isBetweenValues(1, 5))();
  RealColumn get cardio => real().named('cardio').withDefault(const Constant(0.0))();
}

class Muscle extends Table {
  IntColumn get id => integer().autoIncrement()();
  // IMPORTANT: garder NOT NULL en plus de UNIQUE
  TextColumn get name => text().named('name').customConstraint('NOT NULL UNIQUE')();
}

class Equipment extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('name').customConstraint('NOT NULL UNIQUE')();
}

class Objective extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().named('code').customConstraint('NOT NULL UNIQUE')();
  TextColumn get name => text().named('name')();
}



class TrainingModality extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get objectiveId =>
      integer().named('objective_id').references(Objective, #id, onDelete: KeyAction.cascade)();
  TextColumn get level => text().named('level').map(_convLevel)(); // non-null
  TextColumn get name => text().named('name')();
  IntColumn get repMin => integer().named('rep_min').nullable()();
  IntColumn get repMax => integer().named('rep_max').nullable()();
  IntColumn get setMin => integer().named('set_min').nullable()();
  IntColumn get setMax => integer().named('set_max').nullable()();
  IntColumn get restMinSec => integer().named('rest_min_sec').nullable()();
  IntColumn get restMaxSec => integer().named('rest_max_sec').nullable()();
  RealColumn get rpeMin => real().named('rpe_min').nullable()();
  RealColumn get rpeMax => real().named('rpe_max').nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(objective_id, level, name)'];
}

/* ===================== PARTIE 2 : LIAISONS CATALOGUE ===================== */

class ExerciseMuscle extends Table {
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get muscleId =>
      integer().named('muscle_id').references(Muscle, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}

class ExerciseEquipment extends Table {
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get equipmentId =>
      integer().named('equipment_id').references(Equipment, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

class ExerciseObjective extends Table {
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get objectiveId =>
      integer().named('objective_id').references(Objective, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {exerciseId, objectiveId};
}

class ExerciseRelation extends Table {
  @ReferenceName('asSrc')
  IntColumn get srcExerciseId =>
      integer().named('src_exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('asDst')
  IntColumn get dstExerciseId =>
      integer().named('dst_exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();

  TextColumn get relationType => text().named('relation_type').map(_convRelationType)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {srcExerciseId, dstExerciseId, relationType};
}

/* ===================== PARTIE 3 : UTILISATEUR & PRÉFÉRENCES ===================== */

class AppUser extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get age => integer().named('age').nullable()();
  RealColumn get weight => real().named('weight').nullable()();
  RealColumn get height => real().named('height').nullable()();

  // NEW: on remplace sex par gender
  TextColumn get gender => text().named('gender').map(_nullableGender).nullable()();

  // NEW: birthDate (stocké en INTEGER/epoch par SQLite)
  DateTimeColumn get birthDate => dateTime().named('birth_date').nullable()();

  // Toujours là
  TextColumn get level => text().named('level').map(_nullableLevel).nullable()();
  TextColumn get metabolism => text().named('metabolism').map(_nullableMetabolism).nullable()();

  // Ajout(s) précédents
  TextColumn get nom => text().named('nom').nullable()();
  TextColumn get prenom => text().named('prenom').nullable()();

  // Singleton: un seul user dans l’app
  IntColumn get singleton => integer()
      .named('singleton')
      .withDefault(const Constant(1))();
}





class UserEquipment extends Table {
  IntColumn get userId =>
      integer().named('user_id').references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get equipmentId =>
      integer().named('equipment_id').references(Equipment, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {userId, equipmentId};
}

class UserGoal extends Table {
  IntColumn get userId =>
      integer().named('user_id').references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get objectiveId =>
      integer().named('objective_id').references(Objective, #id, onDelete: KeyAction.cascade)();
  RealColumn get weight => real().named('weight')();
  @override
  Set<Column> get primaryKey => {userId, objectiveId};
}

class UserFeedback extends Table {
  IntColumn get userId =>
      integer().named('user_id').references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get liked => integer().named('liked')(); // 0/1
  IntColumn get difficult => integer().named('difficult').withDefault(const Constant(0))();
  IntColumn get pleasant => integer().named('pleasant').withDefault(const Constant(0))();
  IntColumn get useless => integer().named('useless').withDefault(const Constant(0))();
  IntColumn get ts => integer().named('ts')(); // unix seconds
  @override
  Set<Column> get primaryKey => {userId, exerciseId, ts};
}

/* ===================== PARTIE 4 : JOURNAL (SÉANCES) ===================== */

class Session extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().named('user_id').references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get programDayId =>
      integer().named('program_day_id').references(ProgramDay, #id, onDelete: KeyAction.setNull).nullable()();
  IntColumn get dateTs => integer().named('date_ts')();
  IntColumn get durationMin => integer().named('duration_min').nullable()();
}

class SessionExercise extends Table {
  IntColumn get sessionId =>
      integer().named('session_id').references(Session, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().named('position')(); // ordre 1,2,3...
  IntColumn get sets => integer().named('sets').nullable()();
  IntColumn get reps => integer().named('reps').nullable()();
  RealColumn get load => real().named('load').nullable()();
  RealColumn get rpe => real().named('rpe').nullable()();
  @override
  Set<Column> get primaryKey => {sessionId, exerciseId, position};
}

/* ===================== PARTIE 5 : MODULE PROGRAMMES ===================== */

class WorkoutProgram extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().named('description').nullable()();
  IntColumn get objectiveId =>
      integer().named('objective_id').references(Objective, #id, onDelete: KeyAction.setNull).nullable()();
  TextColumn get level => text().named('level').map(_nullableLevel).nullable()();
  IntColumn get durationWeeks => integer().named('duration_weeks').nullable()();
}

class ProgramDay extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId =>
      integer().named('program_id').references(WorkoutProgram, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().named('name')();
  IntColumn get dayOrder => integer().named('day_order')();
}

class ProgramDayExercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programDayId =>
      integer().named('program_day_id').references(ProgramDay, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().named('exercise_id').references(Exercise, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().named('position')();
  IntColumn get modalityId =>
      integer().named('modality_id').references(TrainingModality, #id, onDelete: KeyAction.setNull).nullable()();
  TextColumn get setsSuggestion => text().named('sets_suggestion').nullable()();
  TextColumn get repsSuggestion => text().named('reps_suggestion').nullable()();
  IntColumn get restSuggestionSec => integer().named('rest_suggestion_sec').nullable()();
  TextColumn get notes => text().named('notes').nullable()();
}

class UserProgram extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().named('user_id').references(AppUser, #id, onDelete: KeyAction.cascade)();
  IntColumn get programId =>
      integer().named('program_id').references(WorkoutProgram, #id, onDelete: KeyAction.cascade)();
  IntColumn get startDateTs => integer().named('start_date_ts')();
  IntColumn get isActive => integer().named('is_active').withDefault(const Constant(1))();
}

/* ===================== BASE DE DONNÉES ===================== */

@DriftDatabase(
  tables: [
    Exercise,
    Muscle,
    Equipment,
    Objective,
    TrainingModality,
    ExerciseMuscle,
    ExerciseEquipment,
    ExerciseObjective,
    ExerciseRelation,
    AppUser,
    UserEquipment,
    UserGoal,
    UserFeedback,
    Session,
    SessionExercise,
    WorkoutProgram,
    ProgramDay,
    ProgramDayExercise,
    UserProgram,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  /// Bump quand tu touches au schéma.
  @override
  int get schemaVersion => 34;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await _ensureAppUserSingletonColumnAndIndex(); // <<--- AJOUT CLEF
      if (await _tableExists('app_user')) {
        await _addColumnIfMissing('app_user', 'singleton', 'INTEGER NOT NULL DEFAULT 1');
        // Ajouter la colonne birth_date si manquante
        await _addColumnIfMissing('app_user', 'birth_date', 'INTEGER');
      }
      // Ajouter program_day_id à la table session si manquante
      if (await _tableExists('session')) {
        await _addColumnIfMissing('session', 'program_day_id', 'INTEGER REFERENCES program_day(id) ON DELETE SET NULL');
      }
      await customStatement('PRAGMA foreign_keys = ON;');
    },


    onCreate: (m) async {
      await m.createAll();            // crée toutes les tables de @DriftDatabase
      await _createAllIndexes();      // puis les index idempotents
    },
    onUpgrade: (m, from, to) async {
      await _ensureAppUserSingletonColumnAndIndex(); // assure colonne+index
      if (await _tableExists('app_user')) {
        await _addColumnIfMissing('app_user', 'singleton', 'INTEGER NOT NULL DEFAULT 1');
        // Ajouter la colonne birth_date si manquante
        await _addColumnIfMissing('app_user', 'birth_date', 'INTEGER');
      }
      // Garantir la colonne singleton avant de créer l'index unique
      await _addColumnIfMissing('app_user', 'singleton', 'INTEGER NOT NULL DEFAULT 1');

      // Ajouter program_day_id à la table session si manquante
      if (await _tableExists('session')) {
        await _addColumnIfMissing('session', 'program_day_id', 'INTEGER REFERENCES program_day(id) ON DELETE SET NULL');
      }

      await _ensureExerciseRelationTable();

      // On évite toute magie sur tables existantes (source d'erreurs).
      // On ne crée que les INDEX manquants, de façon idempotente.
      await _createAllIndexes();
    },

  );

  Future<void> _createSingletonIndexIfSafe() async {
    if (await _tableExists('app_user') && await _columnExists('app_user', 'singleton')) {
      await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);'
      );
    }
  }

  Future<void> _createAllIndexes() async {
    await _createSingletonIndexIfSafe();
    Future<void> _idxIf(String table, String sql) async {
      if (await _tableExists(table)) {
        await customStatement(sql);
      }
    }

    await _idxIf('exercise_muscle',  'CREATE INDEX IF NOT EXISTS idx_ex_muscle  ON exercise_muscle(exercise_id);');
    await _idxIf('exercise_objective','CREATE INDEX IF NOT EXISTS idx_ex_obj     ON exercise_objective(exercise_id);');
    await _idxIf('user_feedback',     'CREATE INDEX IF NOT EXISTS idx_fb_user    ON user_feedback(user_id, ts);');
    await _idxIf('user_equipment',    'CREATE INDEX IF NOT EXISTS idx_user_eq    ON user_equipment(user_id);');
    await _idxIf('user_goal',         'CREATE INDEX IF NOT EXISTS idx_user_goal  ON user_goal(user_id);');
    await _idxIf('session',           'CREATE INDEX IF NOT EXISTS idx_sess_user  ON session(user_id, date_ts);');
    await _idxIf('exercise_relation', 'CREATE INDEX IF NOT EXISTS idx_rel_src    ON exercise_relation(src_exercise_id);');
    await _idxIf('training_modality', 'CREATE INDEX IF NOT EXISTS idx_modality   ON training_modality(objective_id, level);');
    await _idxIf('program_day',       'CREATE INDEX IF NOT EXISTS idx_prog_day   ON program_day(program_id);');
    await _idxIf('program_day_exercise','CREATE INDEX IF NOT EXISTS idx_prog_ex  ON program_day_exercise(program_day_id);');
    await _idxIf('user_program',      'CREATE INDEX IF NOT EXISTS idx_user_prog  ON user_program(user_id, is_active);');

  }


  /// ---------- Utilitaires ----------
  Future<String> integrityCheck() async {
    final row = await customSelect('PRAGMA integrity_check;').getSingle();
    return (row.data.values.first ?? '').toString();
  }

  Future<int> pragmaUserVersion() async {
    final row = await customSelect('PRAGMA user_version;').getSingle();
    final v = (row.data.values.first ?? '0').toString();
    return int.tryParse(v) ?? 0;
  }

  Future<bool> _tableExists(String table) async {
    final r = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?;",
      variables: [Variable.withString(table)],
    ).get();
    return r.isNotEmpty;
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect("PRAGMA table_info('$table');").get();
    return rows.any((e) => (e.data['name'] ?? '').toString() == column);
  }

  Future<void> _addColumnIfMissing(String table, String column, String sqlType) async {
    if (!await _columnExists(table, column)) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $sqlType;');
    }
  }


  Future<void> _ensureExerciseRelationTable() async {
    // crée la table si absente (schéma V3)
    if (!await _tableExists('exercise_relation')) {
      await customStatement('''
      CREATE TABLE IF NOT EXISTS exercise_relation (
        src_exercise_id INTEGER NOT NULL,
        dst_exercise_id INTEGER NOT NULL,
        relation_type   TEXT    NOT NULL,
        weight          REAL    NOT NULL,
        FOREIGN KEY (src_exercise_id) REFERENCES exercise (id) ON DELETE CASCADE,
        FOREIGN KEY (dst_exercise_id) REFERENCES exercise (id) ON DELETE CASCADE,
        PRIMARY KEY (src_exercise_id, dst_exercise_id, relation_type)
      );
    ''');
    }
  }

  Future<void> _ensureAppUserSingletonColumnAndIndex() async {
    if (await _tableExists('app_user')) {
      final hasSingleton = await _columnExists('app_user', 'singleton');
      if (!hasSingleton) {
        await customStatement(
            'ALTER TABLE app_user ADD COLUMN singleton INTEGER NOT NULL DEFAULT 1;'
        );
      }
      // L’index ne sera créé que si la colonne existe (maintenant c’est sûr)
      await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);'
      );
    }
  }




}
