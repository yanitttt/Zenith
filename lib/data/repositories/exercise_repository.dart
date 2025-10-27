import '../db/app_db.dart';
import '../db/daos/exercise_dao.dart';

class ExerciseRepository {
  final ExerciseDao _dao;

  ExerciseRepository(AppDb db) : _dao = ExerciseDao(db);

  Stream<List<ExerciseData>> watchAll() => _dao.watchAll();

  Future<List<ExerciseData>> all() => _dao.all();
}
