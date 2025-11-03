// lib/data/db/app_db.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bdd_recommandation_v2.db'));

    // Copier la DB packagée uniquement si elle n'existe pas encore
    if (!await file.exists()) {
      final data = await rootBundle.load('assets/db/bdd_recommandation_v2.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}

/* ===================== TABLES ===================== */

class Exercise extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get difficulty => integer()();
  RealColumn get cardio => real().withDefault(const Constant(0.0))();
}

class Muscle extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class ExerciseMuscle extends Table {
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get muscleId => integer().named('muscle_id')();
  RealColumn get weight => real()();
  @override
  Set<Column> get primaryKey => {exerciseId, muscleId};
}

class Equipment extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class ExerciseEquipment extends Table {
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get equipmentId => integer().named('equipment_id')();
  @override
  Set<Column> get primaryKey => {exerciseId, equipmentId};
}

class AppUser extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get prenom => text().nullable()();
  TextColumn get nom => text().nullable()();

  // Colonnes existantes de ta DB packagée (laisse en nullable)
  IntColumn get age => integer().nullable()();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  TextColumn get level => text().nullable()(); // "debutant" | "intermediaire" | "avance"
  TextColumn get metabolism => text().nullable()(); // "rapide" | "lent"

  /// Nouveaux champs (Drift => SQL: birth_date, gender)
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()(); // "female" | "male"
}

class UserFeedback extends Table {
  IntColumn get userId => integer().named('user_id')();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get liked => integer()(); // 0/1
  IntColumn get difficult => integer().withDefault(const Constant(0))();
  IntColumn get pleasant => integer().withDefault(const Constant(0))();
  IntColumn get useless => integer().withDefault(const Constant(0))();
  IntColumn get ts => integer()(); // timestamp sec
  @override
  Set<Column> get primaryKey => {userId, exerciseId, ts};
}

class Session extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().named('user_id')();
  IntColumn get dateTs => integer().named('date_ts')();
  IntColumn get durationMin => integer().named('duration_min').nullable()();
}

class SessionExercise extends Table {
  IntColumn get sessionId => integer().named('session_id')();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get sets => integer().nullable()();
  IntColumn get reps => integer().nullable()();
  RealColumn get load => real().nullable()();
  RealColumn get rpe => real().nullable()();
  @override
  Set<Column> get primaryKey => {sessionId, exerciseId};
}

/* ===================== DB ===================== */

@DriftDatabase(
  tables: [
    Exercise,
    Muscle,
    ExerciseMuscle,
    Equipment,
    ExerciseEquipment,
    AppUser,
    UserFeedback,
    Session,
    SessionExercise,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  // 🔼 Bump pour déclencher l’upgrade si une vieille DB est présente
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Filet de sécurité : s’assurer des colonnes à chaque ouverture
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await _safeAddColumn('app_user', 'prenom', 'TEXT');
      await _safeAddColumn('app_user', 'nom', 'TEXT');
      await _safeAddColumn('app_user', 'birth_date', 'INTEGER'); // DateTime
      await _safeAddColumn('app_user', 'gender', 'TEXT');
    },

    onUpgrade: (migrator, from, to) async {
      // v2 : introduction prenom/nom + migration éventuelle depuis "name"
      if (from < 2) {
        await _safeAddColumn('app_user', 'prenom', 'TEXT');
        await _safeAddColumn('app_user', 'nom', 'TEXT');
        if (await _columnExists('app_user', 'name')) {
          await customStatement('UPDATE app_user SET nom = name WHERE nom IS NULL;');
        }
      }

      // v3 : ceinture
      if (from < 3) {
        await _safeAddColumn('app_user', 'prenom', 'TEXT');
        await _safeAddColumn('app_user', 'nom', 'TEXT');
      }

      // v4 : (optionnel) gestion singleton — laissons en migration seulement
      if (from < 4) {
        await _safeAddColumn('app_user', 'singleton', 'INTEGER NOT NULL DEFAULT 0');
        await customStatement('DELETE FROM app_user WHERE id NOT IN (SELECT MIN(id) FROM app_user);');
        await customStatement('UPDATE app_user SET singleton = 0;');
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);',
        );
      }

      // v5+ : nouveaux champs profil
      if (from < 5) {
        await _safeAddColumn('app_user', 'birth_date', 'INTEGER');
        await _safeAddColumn('app_user', 'gender', 'TEXT');
      }
      // v6 → v7 : garde-fou (au cas où)
      if (from < 7) {
        await _safeAddColumn('app_user', 'birth_date', 'INTEGER');
        await _safeAddColumn('app_user', 'gender', 'TEXT');
      }
    },
  );

  /* ---------- Helpers ---------- */

  Future<void> _safeAddColumn(String table, String column, String sqlType) async {
    if (!await _columnExists(table, column)) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $sqlType;');
    }
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table);').get();
    for (final r in rows) {
      final name = (r.data['name'] ?? '').toString();
      if (name == column) return true;
    }
    return false;
  }

  Future<String> integrityCheck() async {
    final row = await customSelect('PRAGMA integrity_check;').getSingle();
    return (row.data.values.first ?? '').toString();
  }

  Future<int> pragmaUserVersion() async {
    final row = await customSelect('PRAGMA user_version;').getSingle();
    final v = (row.data.values.first ?? '0').toString();
    return int.tryParse(v) ?? 0;
  }
}
