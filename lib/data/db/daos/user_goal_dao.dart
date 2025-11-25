import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_goal_dao.g.dart';

@DriftAccessor(tables: [UserGoal, Objective])
class UserGoalDao extends DatabaseAccessor<AppDb> with _$UserGoalDaoMixin {
  UserGoalDao(AppDb db) : super(db);

  Future<List<UserGoalData>> goalsOf(int userId) {
    return (select(userGoal)..where((g) => g.userId.equals(userId))).get();
  }

  Future<List<ObjectiveData>> allObjectivesList() {
    return select(objective).get();
  }

  Future<void> deleteForUser(int userId) {
    return (delete(userGoal)..where((g) => g.userId.equals(userId))).go();
  }

  Future<void> insertMany(int userId, List<int> objectives) async {
    await batch((batch) {
      batch.insertAll(
        userGoal,
        objectives.map(
          (id) => UserGoalCompanion.insert(
            userId: userId,
            objectiveId: id,
            weight: 1.0,
          ),
        ),
      );
    });
  }

  Future<void> replace(int userId, List<int> objectives) async {
    await transaction(() async {
      await deleteForUser(userId);
      await insertMany(userId, objectives);
    });
  }
}
