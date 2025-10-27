// lib/data/db/app_db.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // ✅ utiliser la base native
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dir.path}/bdd_recommandation_v2.db');

    // Copie la DB packagée au premier lancement
    if (!await dbFile.exists()) {
      final bytes = await rootBundle.load('assets/db/bdd_recommandation_v2.db');
      await dbFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }

    // Ouvre SQLite en tâche de fond (performant, pas de DriftFlutter ici)
    return NativeDatabase.createInBackground(dbFile);
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
  TextColumn get name => text().nullable()();
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
  int get schemaVersion => 1;

  // Active les FK à chaque ouverture
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  // Helpers debug (optionnels)
  Future<String> integrityCheck() async {
    final rows = await customSelect('PRAGMA integrity_check;').get();
    return rows.isNotEmpty ? (rows.first.data.values.first?.toString() ?? '') : '';
  }

  Future<int> pragmaUserVersion() async {
    final rows = await customSelect('PRAGMA user_version;').get();
    final v = rows.isNotEmpty ? rows.first.data.values.first : 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
