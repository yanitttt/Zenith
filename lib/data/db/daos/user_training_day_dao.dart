import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_training_day_dao.g.dart';

@DriftAccessor(tables: [UserTrainingDay])
class UserTrainingDayDao extends DatabaseAccessor<AppDb> with _$UserTrainingDayDaoMixin {
  UserTrainingDayDao(AppDb db) : super(db);

  /// Récupère tous les jours d'entraînement d'un utilisateur
  Future<List<UserTrainingDayData>> getDaysForUser(int userId) {
    return (select(userTrainingDay)..where((d) => d.userId.equals(userId))).get();
  }

  /// Récupère les numéros de jours (1-7) pour un utilisateur
  Future<List<int>> getDayNumbersForUser(int userId) async {
    final days = await getDaysForUser(userId);
    return days.map((d) => d.dayOfWeek).toList();
  }

  /// Supprime tous les jours d'un utilisateur
  Future<void> deleteForUser(int userId) {
    return (delete(userTrainingDay)..where((d) => d.userId.equals(userId))).go();
  }

  /// Insère plusieurs jours pour un utilisateur
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

  /// Remplace tous les jours d'un utilisateur
  Future<void> replace(int userId, List<int> dayNumbers) async {
    await transaction(() async {
      await deleteForUser(userId);
      await insertMany(userId, dayNumbers);
    });
  }
}
