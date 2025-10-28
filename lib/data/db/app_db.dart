// lib/data/db/app_db.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // ✅ utiliser la base native
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bdd_recommandation_v2.db'));

    if (!await file.exists()) {
      // copie depuis assets vers file
      final data = await rootBundle.load('assets/db/bdd_recommandation_v2.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}

/* ======== TABLES ======== */

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

  // déjà ajoutés
  TextColumn get prenom => text().nullable()();
  TextColumn get nom => text().nullable()();

  // ➕ aligne sur la BDD existante (tous en nullable)
  IntColumn get age => integer().nullable()();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  IntColumn get level => integer().nullable()();
  TextColumn get metabolism => text().nullable()();
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

/* ======== DB ======== */

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

  @override
  int get schemaVersion => 4; // ⬅️ bump

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
    onUpgrade: (migrator, from, to) async {
      // v2/v3 : tes migrations existantes (prenom/nom, etc.)
      if (from < 2) {
        await _ensureUserNameColumns();
        if (await _columnExists('app_user', 'name')) {
          await customStatement('UPDATE app_user SET nom = name WHERE nom IS NULL;');
        }
      }
      if (from < 3) {
        await _ensureUserNameColumns();
      }

      // v4 : colonne singleton + contrainte d'unicité + dédoublonnage
      if (from < 4) {
        await _safeAddColumn('app_user', 'singleton', 'INTEGER NOT NULL DEFAULT 0');

        // Garder une seule ligne si plusieurs existent déjà
        await customStatement('DELETE FROM app_user WHERE id NOT IN (SELECT MIN(id) FROM app_user);');
        // S’assurer que la (seule) ligne a singleton=0
        await customStatement('UPDATE app_user SET singleton = 0;');
        // Créer un index unique (empêche toute 2e ligne)
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS ux_app_user_singleton ON app_user(singleton);');
      }
    },
  );

// ---------- Helpers (déjà vus plus haut, garde-les dans AppDb) ----------
  Future<void> _ensureUserNameColumns() async {
    await _safeAddColumn('app_user', 'prenom', 'TEXT');
    await _safeAddColumn('app_user', 'nom', 'TEXT');
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table);').get();
    for (final r in rows) {
      if ((r.data['name'] ?? '').toString() == column) return true;
    }
    return false;
  }

  Future<void> _safeAddColumn(String table, String column, String sqlType) async {
    if (!await _columnExists(table, column)) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $sqlType;');
    }
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
