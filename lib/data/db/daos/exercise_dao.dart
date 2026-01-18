import 'package:drift/drift.dart';
import '../app_db.dart';
import '../../models/exercise_with_equipment.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(
  tables: [Exercise, Muscle, ExerciseMuscle, UserFeedback, ExerciseEquipment],
)
class ExerciseDao extends DatabaseAccessor<AppDb> with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  Future<List<ExerciseData>> all() {
    return (select(exercise)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<ExerciseData?> find(int id) {
    return (select(exercise)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<ExerciseData>> forMuscle(int muscleId) async {
    final j = select(exercise).join([
      innerJoin(
        exerciseMuscle,
        exerciseMuscle.exerciseId.equalsExp(exercise.id),
      ),
    ])..where(exerciseMuscle.muscleId.equals(muscleId));
    return j.map((row) => row.readTable(exercise)).get();
  }

  Future<List<ExerciseData>> suggestForUser(
    int userId, {
    int limit = 10,
  }) async {
    final likedJoin =
        select(exercise).join([
            innerJoin(
              userFeedback,
              userFeedback.exerciseId.equalsExp(exercise.id) &
                  userFeedback.userId.equals(userId) &
                  userFeedback.liked.equals(1),
            ),
          ])
          ..orderBy([OrderingTerm.desc(userFeedback.ts)])
          ..limit(limit);

    final liked = await likedJoin.map((row) => row.readTable(exercise)).get();
    if (liked.length >= limit) return liked.take(limit).toList();

    final remaining = limit - liked.length;
    final filler =
        await (select(exercise)
              ..orderBy([
                (t) => OrderingTerm.asc(t.difficulty),
                (t) => OrderingTerm.asc(t.name),
              ])
              ..limit(remaining))
            .get();

    final seen = <int>{};
    final result = <ExerciseData>[
      ...liked.where((e) => seen.add(e.id)),
      ...filler.where((e) => seen.add(e.id)),
    ];
    return result.take(limit).toList();
  }

  Stream<List<ExerciseData>> watchAll() {
    final q = (select(exercise)..orderBy([(t) => OrderingTerm.asc(t.name)]));
    return q.watch();
  }

  Stream<List<ExerciseWithEquipment>> watchAllWithEquipment() {
    final query = select(exercise).join([
      leftOuterJoin(
        exerciseEquipment,
        exerciseEquipment.exerciseId.equalsExp(exercise.id),
      ),
    ]);

    return query.watch().map((rows) {
      // On regroupe pour éviter les doublons (si un exercice a plusieurs équipements)
      // On prend arbitrairement le premier équipement rencontré pour chaque exercice
      final Map<int, ExerciseWithEquipment> uniqueExercises = {};

      for (final row in rows) {
        final ex = row.readTable(exercise);
        final eq = row.readTableOrNull(exerciseEquipment);

        if (!uniqueExercises.containsKey(ex.id)) {
          uniqueExercises[ex.id] = ExerciseWithEquipment(ex, eq?.equipmentId);
        }
      }

      // On trie par nom pour garder l'ordre alphabétique
      final result = uniqueExercises.values.toList();
      result.sort((a, b) => a.exercise.name.compareTo(b.exercise.name));

      return result;
    });
  }

  Future<int> insertOne(ExerciseCompanion data) => into(exercise).insert(data);
  Future<bool> updateOne(ExerciseData e) => update(exercise).replace(e);
  Future<int> deleteById(int id) =>
      (delete(exercise)..where((t) => t.id.equals(id))).go();
}
