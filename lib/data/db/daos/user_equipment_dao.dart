import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_equipment_dao.g.dart';

@DriftAccessor(tables: [UserEquipment, Equipment])
class UserEquipmentDao extends DatabaseAccessor<AppDb>
    with _$UserEquipmentDaoMixin {
  UserEquipmentDao(AppDb db) : super(db);

  Future<List<UserEquipmentData>> equipmentOf(int userId) {
    return (select(userEquipment)..where((g) => g.userId.equals(userId))).get();
  }

  Future<List<EquipmentData>> allEquipmentList() {
    return select(equipment).get();
  }

  Future<void> deleteForUser(int userId) {
    return (delete(userEquipment)..where((g) => g.userId.equals(userId))).go();
  }

  Future<void> insertMany(int userId, List<int> equipments) async {
    await batch((batch) {
      batch.insertAll(
        userEquipment,
        equipments.map(
          (id) =>
              UserEquipmentCompanion.insert(userId: userId, equipmentId: id),
        ),
      );
    });
  }

  Future<void> replace(int userId, List<int> equipments) async {
    await transaction(() async {
      await deleteForUser(userId);
      await insertMany(userId, equipments);
    });
  }
}
