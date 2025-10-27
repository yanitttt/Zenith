// lib/data/db/daos/session_dao.dart
import 'package:drift/drift.dart';
import '../app_db.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Session, SessionExercise, Exercise])
class SessionDao extends DatabaseAccessor<AppDb> with _$SessionDaoMixin {
  SessionDao(AppDb db) : super(db);

  Future<List<SessionData>> sessionsForUser(int userId, {int? limit}) {
    final q = (select(session)
      ..where((s) => s.userId.equals(userId))
      ..orderBy([(s) => OrderingTerm.desc(s.dateTs)]));
    if (limit != null) q.limit(limit);
    return q.get();
  }

  Future<List<(SessionExerciseData, ExerciseData)>> sessionDetails(int sessionId) {
    final j = select(sessionExercise).join([
      innerJoin(exercise, exercise.id.equalsExp(sessionExercise.exerciseId)),
    ])
      ..where(sessionExercise.sessionId.equals(sessionId));

    return j.map((row) => (
    row.readTable(sessionExercise),
    row.readTable(exercise),
    )).get();
  }

  Future<int> createSession(SessionCompanion data) => into(session).insert(data);

  Future<int> addExerciseToSession(SessionExerciseCompanion data) =>
      into(sessionExercise).insert(data, mode: InsertMode.insertOrReplace);

  Future<int> deleteSession(int sessionId) =>
      (delete(session)..where((s) => s.id.equals(sessionId))).go();

  Future<bool> updateSession(SessionData s) => update(session).replace(s);

  Future<bool> updateSessionExercise(SessionExerciseData se) =>
      update(sessionExercise).replace(se);
}
