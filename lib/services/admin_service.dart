import '../data/db/app_db.dart';
import '../data/db/daos/user_dao.dart';
import '../data/db/daos/user_training_day_dao.dart';

class AdminService {
  final AppDb db;
  late final UserDao _userDao;
  late final UserTrainingDayDao _trainingDayDao;

  AdminService(this.db) {
    _userDao = UserDao(db);
    _trainingDayDao = UserTrainingDayDao(db);
  }

  /// Watch all users ordered by ID
  Stream<List<AppUserData>> watchAllUsers() {
    return _userDao.watchAllOrdered();
  }

  /// Delete a user and all cascade data
  Future<void> deleteUser(int userId) async {
    await _userDao.deleteUserCascade(userId);
  }

  /// Get training days for a specific user
  Future<List<int>> getUserTrainingDays(int userId) {
    return _trainingDayDao.getDayNumbersForUser(userId);
  }

  /// Update training days for a specific user
  Future<void> updateUserTrainingDays(int userId, List<int> days) {
    return _trainingDayDao.replace(userId, days);
  }
}
