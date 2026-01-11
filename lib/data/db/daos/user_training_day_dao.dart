import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_training_day_dao.g.dart';

@DriftAccessor(tables: [UserTrainingDay])
class UserTrainingDayDao extends DatabaseAccessor<AppDb>
    with _$UserTrainingDayDaoMixin {
  UserTrainingDayDao(AppDb db) : super(db);

  Future<List<UserTrainingDayData>> getDaysForUser(int userId) {
    return (select(userTrainingDay)
      ..where((d) => d.userId.equals(userId))).get();
  }

  Future<List<int>> getDayNumbersForUser(int userId) async {
    final days = await getDaysForUser(userId);
    return days.map((d) => d.dayOfWeek).toList();
  }

  Stream<List<int>> watchDayNumbersForUser(int userId) {
    return (select(userTrainingDay)..where(
      (d) => d.userId.equals(userId),
    )).watch().map((rows) => rows.map((r) => r.dayOfWeek).toList());
  }

  Future<void> deleteForUser(int userId) {
    return (delete(userTrainingDay)
      ..where((d) => d.userId.equals(userId))).go();
  }

  Future<void> insertMany(int userId, List<int> dayNumbers) async {
    await batch((batch) {
      batch.insertAll(
        userTrainingDay,
        dayNumbers.map(
          (dayNum) => UserTrainingDayCompanion.insert(
            userId: userId,
            dayOfWeek: dayNum,
          ),
        ),
      );
    });
  }

  Future<void> replace(int userId, List<int> dayNumbers) async {
    await transaction(() async {
      await deleteForUser(userId);
      await insertMany(userId, dayNumbers);
    });
  }
}
