import '../db/app_db.dart';
import '../db/daos/exercise_dao.dart';

import '../models/exercise_with_equipment.dart';

class ExerciseRepository {
  final ExerciseDao _dao;

  ExerciseRepository(AppDb db) : _dao = ExerciseDao(db);

  Stream<List<ExerciseData>> watchAll() => _dao.watchAll();

  Stream<List<ExerciseWithEquipment>> watchAllWithEquipment() =>
      _dao.watchAllWithEquipment();

  Future<List<ExerciseData>> all() => _dao.all();
}
